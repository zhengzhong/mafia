#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import json
import logging

from django.http import HttpResponse, HttpResponseRedirect, HttpResponseBadRequest
from django.views.generic import TemplateView, CreateView, DetailView
from django.utils import timezone
from django.utils.decorators import method_decorator
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User

from mafia.exceptions import GameError
from mafia.models import Game, Player, Players
from mafia.forms import GameForm
from mafia.classic import ClassicEngine
from mafia.werewolves import WerewolvesEngine


logger = logging.getLogger(__name__)


class MafiaHomeView(TemplateView):

    template_name = 'mafia/home.html'

    def get_context_data(self, **kwargs):
        context_data = super(MafiaHomeView, self).get_context_data(**kwargs)
        since_date = timezone.now() - datetime.timedelta(days=1)
        context_data['recent_game_list'] = Game.objects.filter(update_date__gte=since_date)
        return context_data


class MafiaGameHostView(CreateView):

    template_name = 'mafia/game_host.html'
    model = Game
    form_class = GameForm

    @method_decorator(login_required)
    def dispatch(self, request, *args, **kwargs):
        return super(MafiaGameHostView, self).dispatch(request, *args, **kwargs)

    def get_form_kwargs(self):
        form_kwargs = super(MafiaGameHostView, self).get_form_kwargs()
        form_kwargs['host'] = self.request.user
        return form_kwargs


class _MafiaGameEngineDetailView(DetailView):

    model = Game

    def get_context_data(self, **kwargs):
        context_data = super(_MafiaGameEngineDetailView, self).get_context_data(**kwargs)
        context_data.update({
            'engine': self.get_engine(),
            'current_players': self.get_current_players(),
        })
        return context_data

    def get_engine(self):
        if not hasattr(self, '_engine'):
            game = self.get_object()
            if game.variant == Game.VARIANT_WEREWOLVES:
                self._engine = WerewolvesEngine(game)
            else:
                self._engine = ClassicEngine(game)
        return self._engine

    def get_current_players(self):
        if not hasattr(self, '_current_players'):
            engine = self.get_engine()
            self._current_players = Players(engine.game, self.request.user)
        return self._current_players


class MafiaGameDetailView(_MafiaGameEngineDetailView):

    template_name = 'mafia/game_detail.html'

    def get_context_data(self, **kwargs):
        context_data = super(MafiaGameDetailView, self).get_context_data(**kwargs)
        context_data['is_god_mode'] = (self.request.GET.get('mode', None) == 'god')
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
            if request.is_ajax():
                return HttpResponse('success', mimetype='text/plain')
            else:
                return HttpResponseRedirect(engine.game.get_absolute_url())
        except GameError, exc:
            message = 'Fail to perform action %s on game %s: %s' % (action, engine.game, exc)
            logger.warning(message)
            return HttpResponseBadRequest(message)

    def _join_game(self, request, engine):
        if engine.game.is_ongoing:
            raise GameError('Cannot join game while game is ongoing.')
        engine.game.add_players(request.user)

    def _quit_game(self, request, engine):
        if engine.game.is_ongoing:
            raise GameError('Cannot quit game while game is ongoing.')
        engine.game.remove_players(request.user)

    def _kickoff_user(self, request, engine):
        if engine.game.is_ongoing:
            raise GameError('Cannot kickoff user while game is ongoing.')
        username = request.POST.get('username', '').strip()
        if not username:
            raise GameError('Username is not provided.')
        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            raise GameError('User %s does not exist.' % username)
        engine.game.remove_players(user)

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
        target_pk_list = [int(target_pk) for target_pk in request.POST.getlist('target_pk[]')]
        targets = [p for p in engine.game.player_list if p.pk in target_pk_list]
        option = request.POST.get('option')
        try:
            engine.execute_action(targets, option)
            return HttpResponse('success', mimetype='text/plain')
        except GameError, exc:
            message = unicode(exc)
            logger.warning('Failed to execute action: %s' % message)
            return HttpResponseBadRequest(message, mimetype='text/plain')
