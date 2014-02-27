#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError
from mafia.gameplay import SettlementRule
from mafia.werewolves.constants import Role, Tag


class ProtectedByBodyguard(SettlementRule):

    tag = Tag.PROTECTED_BY_BODYGUARD

    def settle_tagged_player(self, tagged_player, players, result):
        protected = tagged_player
        # If a player is protected by bodyguard, he cannot be killed by werewolves.
        if protected.has_tag(Tag.ATTACKED_BY_WEREWOLF):
            result.log_private('%s was attacked by werewolf but was protected.' % protected)
            protected.remove_tag(Tag.ATTACKED_BY_WEREWOLF)
        # Mark protected player as unprotectable.
        protected.remove_tag(self.tag)
        protected.add_tag(Tag.UNPROTECTABLE)
        result.log_private('%s was protected by bodyguard and became unprotectable.' % protected)


class AttackedByWerewolf(SettlementRule):

    tag = Tag.ATTACKED_BY_WEREWOLF

    def settle_tagged_player(self, tagged_player, players, result):
        attacked = tagged_player
        if attacked.has_tag(Tag.CURED_BY_WITCH):
            # Player is attacked by werewolf and cured.
            result.log_private('%s was attacked by werewolf but was cured.' % attacked)
            attacked.remove_tag(self.tag)
        elif attacked.role == Role.ELDER:
            if attacked.has_tag(Tag.INJURED_BY_WEREWOLF):
                # Elder is attacked by werewolf twice.
                result.log_private('%s was attacked by werewolf twice and killed.' % attacked)
                attacked.mark_out(self.tag)
                result.add_out_player(attacked)
            else:
                # Elder is attacked by werewolf for the first time.
                result.log_private('%s was attacked by werewolf and injured.' % attacked)
                attacked.add_tag(Tag.INJURED_BY_WEREWOLF)
                attacked.remove_tag(self.tag)
        else:
            # Player is attacked by werewolf.
            result.log_private('%s was attacked by werewolf and killed.' % attacked)
            attacked.mark_out(self.tag)
            result.add_out_player(attacked)


class PoisonedByWitch(SettlementRule):

    tag = Tag.POISONED_BY_WITCH

    def settle_tagged_player(self, tagged_player, players, result):
        poisoned = tagged_player
        result.log_private('%s was poisoned to death.' % poisoned)
        poisoned.mark_out(self.tag)
        result.add_out_player(poisoned)


RULES = (ProtectedByBodyguard(), AttackedByWerewolf(), PoisonedByWitch())
