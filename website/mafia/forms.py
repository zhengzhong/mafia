#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json

from django import forms

from mafia.models import Game, Player


class GameForm(forms.ModelForm):

    class Meta:
        model = Game
        fields = ('name', 'is_two_handed', 'variant')

    num_killers = forms.IntegerField(initial=2, min_value=1, max_value=3)
    num_detectives = forms.IntegerField(initial=2, min_value=1, max_value=3)
    has_guardian = forms.BooleanField(initial=True, required=False)
    has_doctor = forms.BooleanField(initial=True, required=False)
    has_traitor = forms.BooleanField(initial=True, required=False)

    num_werewolves = forms.IntegerField(initial=2, min_value=2, max_value=5)
    has_thief = forms.BooleanField(initial=False, required=False)
    has_cupid = forms.BooleanField(initial=True, required=False)
    has_protector = forms.BooleanField(initial=True, required=False)
    has_wizard = forms.BooleanField(initial=True, required=False)
    has_hunter = forms.BooleanField(initial=True, required=False)

    BASIC_FIELD_NAMES = ('name', 'is_two_handed', 'variant')

    CLASSIC_FIELD_NAMES = (
        'num_killers', 'num_detectives', 'has_guardian', 'has_doctor', 'has_traitor'
    )

    WEREWOLVES_FIELD_NAMES = (
        'num_werewolves', 'has_thief', 'has_cupid', 'has_protector', 'has_wizard', 'has_hunter'
    )

    def __init__(self, *args, **kwargs):
        super(GameForm, self).__init__(*args, **kwargs)
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
        game.config_json = json.dumps(self.cleaned_data)
        game.save()
        return game

