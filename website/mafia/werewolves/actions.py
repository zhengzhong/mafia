#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError
from mafia.gameplay import Action, ActionList
from mafia.werewolves.constants import Role, Tag
from mafia.werewolves.settlement import RULES


class ThiefAction(Action):

    role = Role.THIEF
    tag = None
    is_optional = True

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_on(self, target):
        return not target.is_out and target.role != self.role

    def do_execute(self, players, target, options, result):
        thief = next(player for player in players if player.role == self.role)
        thief.role = target.role
        thief.save()
        #result.log(text, visibility=self.role)
        pass


class CupidAction(Action):

    role = Role.CUPID
    tag = Tag.LOVER
    is_optional = True

    def get_min_max_num_targets(self):
        return 2, 2  # Cupid must select 2 players.

    def is_executable_on(self, target):
        return not target.is_out and target.role != self.role


class WerewolfAction(Action):

    role = Role.WEREWOLF
    tag = Tag.BITTEN


class ProphetAction(Action):

    role = Role.PROPHET
    tag = Tag.INVESTIGATED

    def is_executable_on(self, target):
        return target.role != self.role

    def get_answer(self, target):
        return target.role


class WizardAction(Action):

    role = Role.WIZARD
    is_optional = True

    def __init__(self, is_white_magic_used=False, is_black_magic_used=False):
        super(WizardAction, self).__init__()
        self.is_white_magic_used = is_white_magic_used
        self.is_black_magic_used = is_black_magic_used

    def get_data(self):
        return {
            'is_white_magic_used': self.is_white_magic_used,
            'is_black_magic_used': self.is_black_magic_used,
        }

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_by(self, player):
        if self.is_white_magic_used and self.is_black_magic_used:
            return False
        return not player.is_out and player.role == self.role

    def do_execute(self, players, target, options, result):
        magic = options['magic']
        if magic == 'white' and not self.is_white_magic_used:
            target.add_tag(Tag.CURED)
            self.is_white_magic_used = True
            text = '%s cured %s' % (self.role, target)
        elif magic == 'black' and not self.is_black_magic_used:
            target.add_tag(Tag.POISONED)
            self.is_black_magic_used = True
            text = '%s poisoned %s' % (self.role, target)
        else:
            raise GameError('Invalid magic option for wizard: %s' % magic)
        result.log(text, visibility=self.role)

    def post_execute(self, players, options, result):
        if not self.is_white_magic_used and not self.is_black_magic_used:
            result.log('%s did not take any action.' % self.role, visibility=self.role)


class SettleTags(Action):

    role = None

    def get_min_max_num_targets(self):
        return 0, 0

    def is_executable_by(self, player):
        return player.is_host

    def is_executable_on(self, target):
        return False

    def post_execute(self, players, options, result):
        for rule in RULES:
            rule.settle(players, result)


class VoteAndLynch(Action):

    role = None

    def is_executable_by(self, player):
        return player.is_host

    def do_execute(self, players, target, options, result):
        target.is_out = True
        target.save()
        result.log_public('%s was voted and lynched.' % target)
        result.add_out_player(target)


class MayorAction(Action):

    role = None
    tag = Tag.MAYOR

    def is_executable_by(self, player):
        # TODO: is_out in the current round.
        return player.is_out and player.has_tag(Tag.MAYOR)


class HunterAction(Action):

    role = Role.HUNTER

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_by(self, player):
        # TODO: is_out in the current round.
        return player.is_out and player.role == self.role

    def do_execute(self, players, target, options, result):
        target.is_out = True
        target.save()
        result.log_public('%s shot %s' % (self.role, target))
        result.add_out_player(target)


class WerewolvesActionList(ActionList):

    initial_action_classes = (
        CupidAction,
        WerewolfAction,
        ProphetAction,
        WizardAction,
        SettleTags,
        VoteAndLynch,
    )

    action_classes = initial_action_classes + (MayorAction, HunterAction)

    def move_to_next(self, result, players):
        if isinstance(self[self.index], (CupidAction, MayorAction, HunterAction)):
            self.pop(self.index)
        else:
            is_hunter_out = False
            is_mayor_out = False
            for out_player in result.out_players:
                if out_player.role == Role.HUNTER:
                    is_hunter_out = True
                if out_player.has_tag(Tag.MAYOR):
                    is_mayor_out = True
            if is_hunter_out:
                self.insert(self.index + 1, HunterAction())
            if is_mayor_out:
                self.insert(self.index + 1, MayorAction())
            super(WerewolvesActionList, self).move_to_next(result, players)
