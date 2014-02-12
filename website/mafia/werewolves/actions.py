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
        return target.is_unused

    def execute_with_result(self, players, targets, options, result):
        thief = next(player for player in players if player.role == self.role)
        if targets:
            target = targets[0]
            thief.role, target.role = target.role, thief.role
            thief.save()
            target.save()
        else:
            unused_players = [p for p in players if p.is_unused]
            unused_werewolves = [p for p in unused_players if p.role == Role.WEREWOLF]
            if unused_players == unused_werewolves:
                unused_werewolf = unused_werewolves[0]
                thief.role, unused_werewolf.role = unused_werewolf.role, thief.role
        if thief.role != self.role:
            result.log('%s changed role to %s' % (self.role, thief.role), visibility=self.role)
        else:
            result.log('%s did not change the role.' % self.role, visibility=self.role)


class CupidAction(Action):

    role = Role.CUPID
    tag = Tag.LOVER
    is_optional = True

    def get_min_max_num_targets(self):
        return 2, 2  # Cupid must select 2 players.

    def is_executable_on(self, target):
        return not target.is_out and target.role != self.role


class BodyguardAction(Action):

    role = Role.BODYGUARD
    tag = Tag.GUARDED
    is_optional = True

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_on(self, target):
        return not target.is_out and not target.has_tag(Tag.UNGUARDABLE)


class WerewolfAction(Action):

    role = Role.WEREWOLF
    tag = Tag.BITTEN


class PsychicAction(Action):

    role = Role.PSYCHIC
    tag = Tag.MINDREAD

    def is_executable_on(self, target):
        return target.role != self.role

    def get_answer(self, target):
        return 'YES' if target.role == Role.WEREWOLF else 'NO'


class WizardAction(Action):

    role = Role.WIZARD
    is_optional = True

    MAGIC_OPTION = 'magic'
    MAGIC_WHITE = 'white'
    MAGIC_BLACK = 'black'

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
        if self.is_white_magic_used and self.is_black_magic_used:
            return 0, 0
        else:
            return 0, 1

    def is_executable_by(self, player):
        if self.is_white_magic_used and self.is_black_magic_used:
            return False
        return not player.is_out and player.role == self.role

    def is_executable_on(self, target):
        return not target.is_out and not target.role == self.role

    def get_option_choices(self):
        return {self.MAGIC_OPTION: [self.MAGIC_WHITE, self.MAGIC_BLACK]}

    def get_tag(self, options):
        magic = options.get(self.MAGIC_OPTION, None)
        if magic == self.MAGIC_WHITE and not self.is_white_magic_used:
            self.is_white_magic_used = True
            return Tag.CURED
        elif magic == self.MAGIC_BLACK and not self.is_black_magic_used:
            self.is_black_magic_used = True
            return Tag.POISONED
        else:
            raise GameError('Invalid magic option for wizard: %s' % magic)


class SettleTags(Action):

    role = None

    def get_min_max_num_targets(self):
        return 0, 0

    def is_executable_by(self, player):
        return player.is_host

    def is_executable_on(self, target):
        return False

    def execute_with_result(self, players, targets, options, result):
        for rule in RULES:
            rule.settle(players, result)


class ElectMayor(Action):

    role = None
    tag = Tag.MAYOR

    def is_executable_by(self, player):
        return player.is_host

    def execute_with_result(self, players, targets, options, result):
        targets[0].add_tag(self.tag)
        result.log_public('%s was elected as mayor' % targets[0])


class VoteAndLynch(Action):

    role = None
    tag = Tag.LYNCHED

    def is_executable_by(self, player):
        return player.is_host

    def execute_with_result(self, players, targets, options, result):
        for target in targets:
            target.mark_out(self.tag)
            result.log_public('%s was voted and lynched.' % target)
            result.add_out_player(target)


class MayorAction(Action):

    role = None
    tag = Tag.MAYOR

    def is_executable_by(self, player):
        return player.is_out and player.has_tag(Tag.MAYOR)


class HunterAction(Action):

    role = Role.HUNTER
    tag = Tag.SHOT_BY_HUNTER

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_by(self, player):
        return player.is_out and player.role == self.role

    def execute_with_result(self, players, targets, options, result):
        for target in targets:
            target = targets[0]
            target.mark_out(self.tag)
            result.log_public('%s shot %s' % (self.role, target))
            result.add_out_player(target)


class WerewolvesActionList(ActionList):

    initial_action_classes = (
        ThiefAction,
        CupidAction,
        BodyguardAction,
        WerewolfAction,
        PsychicAction,
        WizardAction,
        SettleTags,
        ElectMayor,
        VoteAndLynch,
    )

    action_classes = initial_action_classes + (MayorAction, HunterAction)

    def move_to_next(self, result):
        if isinstance(self[self.index], (ThiefAction, CupidAction, ElectMayor, MayorAction, HunterAction)):
            self.pop(self.index)
        else:
            is_hunter_action_enabled = False
            is_mayor_action_enabled = False
            for out_player in result.out_players:
                if out_player.role == Role.HUNTER and out_player.out_tag != Tag.POISONED:
                    is_hunter_action_enabled = True
                if out_player.has_tag(Tag.MAYOR):
                    is_mayor_action_enabled = True
            if is_hunter_action_enabled:
                self.insert(self.index + 1, HunterAction())
            if is_mayor_action_enabled:
                self.insert(self.index + 1, MayorAction())
            super(WerewolvesActionList, self).move_to_next(result)
