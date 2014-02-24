#!/usr/bin/env python
# -*- coding: utf-8 -*-

from django.contrib import admin
from mafia.models import Game, Player


class GameAdmin(admin.ModelAdmin):

    list_display = ('name', 'is_two_handed', 'variant', 'is_over', 'create_date', 'update_date')

admin.site.register(Game, GameAdmin)


class PlayerAdmin(admin.ModelAdmin):

    list_display = ('game', 'user', 'hand_side', 'is_host', 'role', 'out_tag', 'join_date')

admin.site.register(Player, PlayerAdmin)

