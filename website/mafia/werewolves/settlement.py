#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError
from mafia.werewolves.constants import Tag


class Rule(object):

    tag = None

    def settle(self, players, result):
        if self.tag is None:
            raise GameError('Tag is undefined for rule %s.' % self.__class__.__name__)
        for player in players:
            if not player.is_out and player.has_tag(self.tag):
                self.settle_tagged_player(player, players, result)
        # Finally, for the 2 lovers, if any of them is dead, the other should also die.
        for out_player in result.out_players:
            if out_player.has_tag(Tag.LOVER):
                lovers = self.filter_players_by_tag(players, Tag.LOVER)
                for lover in lovers:
                    result.log_private('%s was dead with his lover %s.' % (lover, out_player))
                    lover.is_out = True
                    lover.save()
                    result.add_out_player(lover)
                break

    def filter_players_by_tag(self, players, tag):
        return [player for player in players if not player.is_out and player.has_tag(tag)]

    def settle_tagged_player(self, tagged_player, players, result):
        raise NotImplementedError()


class Bitten(Rule):

    tag = Tag.BITTEN

    def settle_tagged_player(self, tagged_player, players, result):
        bitten = tagged_player
        # If a player is bitten, he's killed unless he's cured.
        if bitten.has_tag(Tag.CURED):
            result.log_private('%s was bitten but cured.' % bitten)
            bitten.remove_tag(Tag.BITTEN)
        else:
            result.log_private('%s was bitten and killed.' % bitten)
            bitten.is_out = True
            bitten.save()
            result.add_out_player(bitten)


class Poisoned(Rule):

    tag = Tag.POISONED

    def settle_tagged_player(self, tagged_player, players, result):
        poisoned = tagged_player
        result.log_private('%s was poisoned to death.' % poisoned)
        poisoned.is_out = True
        poisoned.save()
        result.add_out_player(poisoned)


RULES = (Bitten(), Poisoned())
