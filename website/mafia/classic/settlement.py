#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError
from mafia.gameplay import SettlementRule
from mafia.classic.constants import Role, Tag


class Guarded(SettlementRule):

    tag = Tag.GUARDED

    def settle_tagged_player(self, tagged_player, players, result):
        guarded = tagged_player
        # If killer is guarded, nobody can be shot except guardian.
        if guarded.role == Role.KILLER:
            for shot in self.filter_players_by_tag(players, Tag.SHOT):
                if shot.role != Role.GUARDIAN:
                    result.log_private('%s was guarded and failed to shoot.' % guarded)
                    shot.remove_tag(Tag.SHOT)
                else:
                    result.log_private('%s was guarded and shot %s.' % (guarded, shot))
        # If doctor is guarded, nobody can be cured.
        if guarded.role == Role.DOCTOR:
            result.log_private('%s was guarded and failed to cure.' % guarded)
            for cured in self.filter_players_by_tag(players, Tag.CURED):
                cured.remove_tag(Tag.CURED)
        # If a player is guarded, he cannot be cured.
        if guarded.has_tag(Tag.CURED):
            result.log_private('%s was guarded and could not be cured.' % guarded)
            guarded.remove_tag(Tag.CURED)
        # If a player is guarded, he cannot be shot unless he is guardian.
        if guarded.has_tag(Tag.SHOT) and guarded.role != Role.GUARDIAN:
            result.log_private('%s was guarded and could not be shot.' % guarded)
            guarded.remove_tag(Tag.SHOT)
        # If a player is guarded twice continuously, he becomes unguardable.
        if guarded.has_tag(Tag.PREVIOUSLY_GUARDED):
            result.log_private('%s was guarded twice and became unguardable.' % guarded)
            guarded.add_tag(Tag.UNGUARDABLE)


class Shot(SettlementRule):

    tag = Tag.SHOT

    def settle_tagged_player(self, tagged_player, players, result):
        shot = tagged_player
        # If a player is shot, he's killed unless he's cured.
        if shot.has_tag(Tag.CURED):
            result.log_private('%s was shot but cured.' % shot)
            shot.remove_tag(Tag.SHOT)
            shot.remove_tag(Tag.CURED)
        else:
            result.log_private('%s was shot and killed.' % shot)
            shot.mark_out(self.tag)
            result.add_out_player(shot)
            # If guardian is killed, the player he guarded is also killed.
            if shot.role == Role.GUARDIAN:
                for guarded in self.filter_players_by_tag(players, Tag.GUARDED):
                    result.log_private('%s was guarded and was dead with guardian.' % guarded)
                    guarded.mark_out(Tag.GUARDED)
                    result.add_out_player(guarded)


class Cured(SettlementRule):

    tag = Tag.CURED

    def settle_tagged_player(self, tagged_player, players, result):
        cured = tagged_player
        if cured.has_tag(Tag.SHOT):
            result.log_private('%s was shot and cured.' % cured)
            cured.remove_tag(Tag.CURED)
            cured.remove_tag(Tag.SHOT)
        elif cured.has_tag(Tag.MISDIAGNOSED):
            result.log_private('%s was misdiagnosed twice and killed.' % cured)
            cured.mark_out(Tag.MISDIAGNOSED)
            result.add_out_player(cured)
        else:
            result.log_private('%s was misdiagnosed.' % cured)
            cured.remove_tag(Tag.CURED)
            cured.add_tag(Tag.MISDIAGNOSED)


RULES = (Guarded(), Shot(), Cured())
