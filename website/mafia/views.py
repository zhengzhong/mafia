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


class _UserMixin(object):

    def get_username_from_request(self, request, required=False):
        if 'username' in request.REQUEST:
            return request.REQUEST['username'].strip()
        elif request.user.is_authenticated():
            return request.user.username
        else:
            if required:
                logger.warning('Username not found in request.')
                raise PermissionDenied()
            else:
                return None

    def get_user_from_request(self, request, required=False):
        username = self.get_username_from_request(request, required=required)
        if username:
            return User.objects.get(username=username)
        elif not required:
            return None
        else:
            logger.warning('User not found in request.')
            raise PermissionDenied()


class GameHostView(CreateView, _UserMixin):

    template_name = 'mafia/game_host.html'
    model = Game
    form_class = GameForm

    def get_form_kwargs(self):
        form_kwargs = super(GameHostView, self).get_form_kwargs()
        form_kwargs['hoster'] = self.get_username_from_request(self.request)
        return form_kwargs

    # DEBUG ONLY!
    def form_valid(self, form):
        result = super(GameHostView, self).form_valid(form)
        dummy_users = ['AAA', 'BBB', 'CCC', 'DDD', 'EEE']
        for user in dummy_users:
            Player.objects.create_players(game=self.object, user=user, is_host=False)
        return result


class GameDetailView(DetailView, _UserMixin):

    template_name = 'mafia/game_detail.html'
    model = Game


class GamePlayView(DetailView, _UserMixin):

    template_name = 'mafia/game_detail.json'
    model = Game

    def get_context_data(self, **kwargs):
        context_data = super(GamePlayView, self).get_context_data(**kwargs)
        context_data['engine'] = self.get_engine()
        return context_data

    def render_to_response(self, context, **response_kwargs):
        return super(GamePlayView, self).render_to_response(context, mimetype='application/json', **response_kwargs)

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

    def get_engine(self):
        if not hasattr(self, '_engine'):
            game = self.get_object()
            if game.variant == Game.VARIANT_WEREWOLVES:
                self._engine = WerewolvesEngine(game)
            else:
                self._engine = ClassicEngine(game)
        return self._engine
