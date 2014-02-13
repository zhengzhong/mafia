#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError
from mafia.gameplay import SettlementRule
from mafia.werewolves.constants import Tag


class Guarded(SettlementRule):

    tag = Tag.GUARDED

    def settle_tagged_player(self, tagged_player, players, result):
        guarded = tagged_player
        # If a player is guarded, he cannot be killed by werewolves.
        if guarded.has_tag(Tag.BITTEN):
            result.log_private('%s was bitten but guarded.' % guarded)
            guarded.remove_tag(Tag.BITTEN)
        # Mark guarded player as unguardable.
        guarded.remove_tag(Tag.GUARDED)
        guarded.add_tag(Tag.UNGUARDABLE)
        result.log_private('%s was guarded and became unguardable.' % guarded)


class Bitten(SettlementRule):

    tag = Tag.BITTEN

    def settle_tagged_player(self, tagged_player, players, result):
        bitten = tagged_player
        # If a player is bitten, he's killed unless he's cured.
        if bitten.has_tag(Tag.CURED):
            result.log_private('%s was bitten but cured.' % bitten)
            bitten.remove_tag(Tag.BITTEN)
        else:
            result.log_private('%s was bitten and killed.' % bitten)
            bitten.mark_out(self.tag)
            result.add_out_player(bitten)


class Poisoned(SettlementRule):

    tag = Tag.POISONED

    def settle_tagged_player(self, tagged_player, players, result):
        poisoned = tagged_player
        result.log_private('%s was poisoned to death.' % poisoned)
        poisoned.mark_out(self.tag)
        result.add_out_player(poisoned)


RULES = (Guarded(), Bitten(), Poisoned())
