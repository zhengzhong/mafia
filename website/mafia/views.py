#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import logging

from django.http import HttpResponse, HttpResponseRedirect, HttpResponseBadRequest
from django.views.generic import TemplateView, CreateView, DetailView
from django.utils.decorators import method_decorator
from django.contrib.auth.decorators import login_required

from mafia.exceptions import GameError
from mafia.models import Game, Player
from mafia.forms import GameForm
from mafia.classic import ClassicEngine
from mafia.werewolves import WerewolvesEngine


logger = logging.getLogger(__name__)


class MafiaHomeView(TemplateView):

    template_name = 'mafia/home.html'

    def get_context_data(self, **kwargs):
        context_data = super(MafiaHomeView, self).get_context_data(**kwargs)
        context_data['available_game_list'] = Game.objects.available_game_list()
        return context_data


class MafiaGameHostView(CreateView):

    template_name = 'mafia/game_host.html'
    model = Game
    form_class = GameForm


class _MafiaGameEngineDetailView(DetailView):

    model = Game

    def get_context_data(self, **kwargs):
        context_data = super(_MafiaGameEngineDetailView, self).get_context_data(**kwargs)
        context_data['engine'] = self.get_engine()
        return context_data

    def get_engine(self):
        if not hasattr(self, '_engine'):
            game = self.get_object()
            if game.variant == Game.VARIANT_WEREWOLVES:
                self._engine = WerewolvesEngine(game)
            else:
                self._engine = ClassicEngine(game)
        return self._engine


class MafiaGameDetailView(_MafiaGameEngineDetailView):

    template_name = 'mafia/game_detail.html'

    def get_context_data(self, **kwargs):
        context_data = super(MafiaGameDetailView, self).get_context_data(**kwargs)
        context_data['mode'] = self.request.GET.get('mode', None)
        if self.request.user.is_authenticated():
            engine = self.get_engine()
            current_players = Player.objects.filter(game=engine.game, user=self.request.user)
            context_data['current_players'] = current_players
        return context_data

    @method_decorator(login_required)
    def post(self, request, *args, **kwargs):
        engine = self.get_engine()
        action = request.POST.get('action')
        handler_mappings = {
            'join': self._join_game,
            'quit': self._quit_game,
            'kickoff': self._kickoff_user,
            'reset': self._reset_game,
            'start': self._start_game,
        }
        try:
            handler = handler_mappings.get(action)
            if not handler:
                raise GameError('Unknown action %s.' % action)
            handler(request, engine)
            return HttpResponseRedirect(engine.game.get_absolute_url())
        except GameError, exc:
            message = 'Fail to perform action %s on game %s: %s' % (action, engine.game, exc)
            logger.warning(message)
            return HttpResponseBadRequest(message)

    def _join_game(self, request, engine):
        if engine.game.is_ongoing:
            raise GameError('Cannot join game while game is ongoing.')
        Player.objects.get_or_create_players(game=engine.game, user=request.user, is_host=False)

    def _quit_game(self, request, engine):
        if engine.game.is_ongoing:
            raise GameError('Cannot quit game while game is ongoing.')
        players = Player.objects.filter(game=engine.game, user=request.user)
        for player in players:
            player.delete()

    def _kickoff_user(self, request, engine):
        if engine.game.is_ongoing:
            raise GameError('Cannot kickoff user while game is ongoing.')
        if not Player.objects.filter(game=engine.game, user=request.user, is_host=True).exists():
            raise GameError('Current user is not allowed to kickoff user.')
        username = request.POST.get('username', '').strip()
        if not username:
            raise GameError('Username is not provided.')
        players = Player.objects.filter(game=engine.game, user__username=username)
        for player in players:
            player.delete()

    def _reset_game(self, request, engine):
        engine.reset_game()

    def _start_game(self, request, engine):
        engine.start_game(force=True)


class MafiaGameHeartbeatView(_MafiaGameEngineDetailView):

    def get(self, request, *args, **kwargs):
        engine = self.get_engine()
        engine.skip_action_if_not_executable()
        json_dict = engine.get_json_dict()
        return HttpResponse(json.dumps(json_dict, ensure_ascii=False), mimetype='application/json')


class MafiaGamePlayView(_MafiaGameEngineDetailView):

    def post(self, request, *args, **kwargs):
        engine = self.get_engine()
        targets = Player.objects.filter(pk__in=request.POST.getlist('target_pk[]'))
        options = {'magic': request.POST.get('magic', '').lower()}  # TODO: hard-coded!
        message = engine.execute_action(targets, options)
        result = {'message': message}
        return HttpResponse(json.dumps(result, ensure_ascii=False), mimetype='application/json')
