#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import logging

from django.core.exceptions import PermissionDenied
from django.http import HttpResponse, HttpResponseRedirect
from django.views.generic import TemplateView, CreateView, DetailView
from django.contrib.auth.models import User

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

    # DEBUG ONLY!
    def form_valid(self, form):
        result = super(MafiaGameHostView, self).form_valid(form)
        game = self.object
        users = User.objects.filter(is_active=True)[:6]
        Player.objects.create_players(game=game, user=users[0], is_host=True)
        for user in users[1:]:
            Player.objects.create_players(game=game, user=user, is_host=False)
        return result


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


class MafiaGameHeartbeatView(_MafiaGameEngineDetailView):

    template_name = 'mafia/game_detail.json'

    def render_to_response(self, context, **response_kwargs):
        response_kwargs['mimetype'] = 'application/json'
        return super(MafiaGameHeartbeatView, self).render_to_response(context, **response_kwargs)


class MafiaGamePlayView(_MafiaGameEngineDetailView):

    template_name = 'mafia/game_detail.json'

    def post(self, request, *args, **kwargs):
        engine = self.get_engine()
        action = request.POST.get('action', '')
        if action == 'start':
            message = engine.start_game(force=True)
        elif action == 'execute':
            targets = Player.objects.filter(pk__in=request.POST.getlist('target_pk[]'))
            options = {'magic': request.POST.get('magic', '').lower()}  # TODO: hard-coded!
            message = engine.execute_action(targets, options)
        else:
            message = 'Unknown action %s' % action
        result = {'message': message}
        if request.is_ajax():
            return HttpResponse(json.dumps(result, ensure_ascii=False), mimetype='application/json')
        else:
            return HttpResponseRedirect(engine.game.get_absolute_url())
