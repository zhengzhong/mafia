#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json

from django import forms
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth.models import User

from mafia.models import Game, Player


class GameForm(forms.ModelForm):

    class Meta:
        model = Game
        fields = ('name', 'is_two_handed', 'variant', 'delay_seconds')

    add_test_players = forms.BooleanField(label=_('Add test players (debug mode)'), initial=False, required=False)

    num_killers = forms.IntegerField(initial=2, min_value=1, max_value=3)
    num_detectives = forms.IntegerField(initial=2, min_value=1, max_value=3)
    has_guardian = forms.BooleanField(initial=True, required=False)
    has_doctor = forms.BooleanField(initial=True, required=False)
    has_traitor = forms.BooleanField(initial=True, required=False)

    num_werewolves = forms.IntegerField(initial=2, min_value=2, max_value=5)
    has_thief = forms.BooleanField(initial=False, required=False)
    has_cupid = forms.BooleanField(initial=True, required=False)
    has_bodyguard = forms.BooleanField(initial=True, required=False)
    has_wizard = forms.BooleanField(initial=True, required=False)
    has_hunter = forms.BooleanField(initial=True, required=False)

    BASIC_FIELD_NAMES = (
        'name', 'is_two_handed', 'variant', 'delay_seconds', 'add_test_players',
    )
    CLASSIC_FIELD_NAMES = (
        'num_killers', 'num_detectives', 'has_guardian', 'has_doctor', 'has_traitor',
    )
    WEREWOLVES_FIELD_NAMES = (
        'num_werewolves', 'has_thief', 'has_cupid', 'has_bodyguard', 'has_wizard', 'has_hunter',
    )

    def __init__(self, host=None, *args, **kwargs):
        super(GameForm, self).__init__(*args, **kwargs)
        self._host = host
        # Patch CSS class for Twitter Bootstrap.
        for field in self.fields.values():
            if not isinstance(field.widget, forms.CheckboxInput):
                field.widget.attrs['class'] = 'form-control'

    def get_basic_fields(self):
        return self._get_fields(self.BASIC_FIELD_NAMES)

    def get_classic_fields(self):
        return self._get_fields(self.CLASSIC_FIELD_NAMES)

    def get_werewolves_fields(self):
        return self._get_fields(self.WEREWOLVES_FIELD_NAMES)

    def _get_fields(self, names):
        """
        Returns a list of 2-tuple: the BoundField and a boolean indicating if it's a checkbox.
        """
        return [
            (self[name], isinstance(self.fields[name].widget, forms.CheckboxInput))
            for name in names
        ]

    def save(self):
        game = super(GameForm, self).save(commit=False)
        config_field_names = {
            Game.VARIANT_CLASSIC: self.CLASSIC_FIELD_NAMES,
            Game.VARIANT_WEREWOLVES: self.WEREWOLVES_FIELD_NAMES,
        }[game.variant]
        config = dict((k, v) for k, v in self.cleaned_data.items() if k in config_field_names)
        game.config_json = json.dumps(config)
        game.save()
        Player.objects.get_or_create_players(game=game, user=self._host, is_host=True)
        if self.cleaned_data['add_test_players']:
            num_test_users = 5 if game.is_two_handed else 10
            test_users = User.objects.filter(is_active=True)[:num_test_users]
            for user in test_users:
                Player.objects.get_or_create_players(game=game, user=user, is_host=False)
        return game
