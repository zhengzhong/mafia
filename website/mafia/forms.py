#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import logging
import re

from django.conf import settings
from django import forms
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth.models import User

from mafia.models import Game, Player


logger = logging.getLogger(__name__)


class GameForm(forms.ModelForm):

    class Meta:
        model = Game
        fields = ('name', 'is_two_handed', 'variant')

    num_killers = forms.IntegerField(initial=2, min_value=1, max_value=3)
    num_detectives = forms.IntegerField(initial=2, min_value=1, max_value=3)
    has_guardian = forms.BooleanField(initial=True, required=False)
    has_doctor = forms.BooleanField(initial=True, required=False)
    has_traitor = forms.BooleanField(initial=True, required=False)
    username = forms.CharField(label=_('Username'), max_length=20)

    def __init__(self, hoster=None, *args, **kwargs):
        super(GameForm, self).__init__(*args, **kwargs)
        self._hoster = hoster

    def save(self):
        game = super(GameForm, self).save(commit=False)
        game.config_json = json.dumps(self.cleaned_data)
        game.save()
        if self._hoster:
            Player.objects.create_players(game=game, user=self._hoster, is_host=True)
        return game

