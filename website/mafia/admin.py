#!/usr/bin/env python
# -*- coding: utf-8 -*-

from django.contrib import admin
from mafia.models import Game, Player


class GameAdmin(admin.ModelAdmin):
    pass

admin.site.register(Game, GameAdmin)


class PlayerAdmin(admin.ModelAdmin):
    pass

admin.site.register(Player, PlayerAdmin)

