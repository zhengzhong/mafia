#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError
from mafia.gameplay import Action, ActionList
from mafia.werewolves.constants import Role, Tag
from mafia.werewolves.settlement import RULES


class _WerewolvesAction(Action):

    def is_executable_by(self, player):
        if not super(_WerewolvesAction, self).is_executable_by(player):
            return False
        if player.role != Role.WEREWOLF and player.has_tag(Tag.INCAPACITATED):
            return False
        return True

    def execute(self, players, targets, option):
        """
        TODO: if elder is dead with his lover, will idiot also die?
        """
        result = super(_WerewolvesAction, self).execute(players, targets, option)
        # Process lovers.
        out_lover = next((p for p in result.out_players if p.has_tag(Tag.CHOSEN_AS_LOVERS)), None)
        if out_lover is not None:
            for lover in [p for p in players if not p.is_out and p.has_tag(Tag.CHOSEN_AS_LOVERS)]:
                result.log_private('%s died for love.' % lover)
                lover.mark_out(Tag.DIED_FOR_LOVE)
                result.add_out_player(lover)
        # Process elder.
        out_elder = next((p for p in result.out_players if p.role == Role.ELDER), None)
        if out_elder is not None and out_elder.out_tag != Tag.ATTACKED_BY_WEREWOLF:
            for idiot in [p for p in players if not p.is_out and p.role == Role.IDIOT]:
                if idiot.has_tag(Tag.EXPOSED_AS_IDIOT):
                    result.log_private('%s was dead with elder.' % idiot)
                    idiot.mark_out(Tag.EXPOSED_AS_IDIOT)
                    result.add_out_player(idiot)
            for player in players:
                if player.role not in (Role.WEREWOLF, Role.CIVILIAN):
                    result.log_private('%s was incapacitated.' % player)
                    player.add_tag(Tag.INCAPACITATED)
        return result


class ThiefAction(_WerewolvesAction):

    role = Role.THIEF
    tag = None
    is_optional = True

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_on(self, target):
        return target.is_unused

    def execute_with_result(self, players, targets, option, result):
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


class CupidoAction(_WerewolvesAction):

    role = Role.CUPIDO
    tag = Tag.CHOSEN_AS_LOVERS
    is_optional = True

    def get_min_max_num_targets(self):
        return 2, 2  # Cupido must select 2 players.

    def is_executable_on(self, target):
        return not target.is_out and target.role != self.role


class WerewolfAction(_WerewolvesAction):

    role = Role.WEREWOLF
    tag = Tag.ATTACKED_BY_WEREWOLF


class SeerAction(_WerewolvesAction):

    role = Role.SEER
    tag = Tag.FORESEEN_BY_SEER

    def is_executable_on(self, target):
        return target.role != self.role

    def get_answer(self, target):
        return 'YES' if target.role == Role.WEREWOLF else 'NO'


class WitchAction(_WerewolvesAction):

    role = Role.WITCH
    is_optional = True

    OPTION_CURE = 'cure'
    OPTION_POISON = 'poison'

    def __init__(self, is_cure_used=False, is_poison_used=False, **kwargs):
        super(WitchAction, self).__init__()
        self.is_cure_used = is_cure_used
        self.is_poison_used = is_poison_used

    def get_data(self):
        return {
            'is_cure_used': self.is_cure_used,
            'is_poison_used': self.is_poison_used,
        }

    def get_min_max_num_targets(self):
        if self.is_cure_used and self.is_poison_used:
            return 0, 0
        else:
            return 0, 1

    def is_executable_by(self, player):
        if self.is_cure_used and self.is_poison_used:
            return False
        return super(WitchAction, self).is_executable_by(player)

    def is_executable_on(self, target):
        return not target.is_out and not target.role == self.role

    def get_option_choices(self):
        choices = []
        if not self.is_cure_used:
            choices.append(self.OPTION_CURE)
        if not self.is_poison_used:
            choices.append(self.OPTION_POISON)
        return choices

    def get_tag(self, option):
        if option == self.OPTION_CURE and not self.is_cure_used:
            self.is_cure_used = True
            return Tag.CURED_BY_WITCH
        elif option == self.OPTION_POISON and not self.is_poison_used:
            self.is_poison_used = True
            return Tag.POISONED_BY_WITCH
        else:
            raise GameError('Invalid option for witch: %s' % option)


class BodyguardAction(_WerewolvesAction):

    role = Role.BODYGUARD
    tag = Tag.PROTECTED_BY_BODYGUARD
    is_optional = True

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_on(self, target):
        return not target.is_out and not target.has_tag(Tag.UNPROTECTABLE)


class FlutePlayerAction(_WerewolvesAction):

    role = Role.FLUTE_PLAYER
    tag = Tag.TEMPTED_BY_FLUTE_PLAYER
    is_optional = True

    def get_min_max_num_targets(self):
        return 0, 2

    def is_executable_on(self, target):
        return not target.is_out and target.role != self.role and not target.has_tag(self.tag)


class SettleTags(_WerewolvesAction):

    role = None

    def get_min_max_num_targets(self):
        return 0, 0

    def is_executable_by(self, player):
        return player.is_host

    def is_executable_on(self, target):
        return False

    def execute_with_result(self, players, targets, option, result):
        for rule in RULES:
            rule.settle(players, result)


class ElectMayor(_WerewolvesAction):

    role = None
    tag = Tag.APPOINTED_AS_MAYOR

    def is_executable_by(self, player):
        return player.is_host

    def execute_with_result(self, players, targets, option, result):
        targets[0].add_tag(self.tag)
        result.log_public('%s was elected as mayor' % targets[0])


class VoteAndLynch(_WerewolvesAction):

    role = None
    tag = Tag.LYNCHED

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_by(self, player):
        return player.is_host

    def execute_with_result(self, players, targets, option, result):
        if targets:
            for target in targets:
                if target.role == Role.IDIOT:
                    target.add_tag(Tag.EXPOSED_AS_IDIOT)
                    result.log_public('%s was found to be an idiot, and was exempted.' % target)
                else:
                    target.mark_out(self.tag)
                    result.log_public('%s was voted and lynched.' % target)
                    result.add_out_player(target)
        else:
            scapegoat = next((p for p in players if p.role == Role.SCAPEGOAT), None)
            if scapegoat is not None and not scapegoat.is_out:
                scapegoat.mark_out(Tag.BORE_THE_BLAME)
                result.log_public('%s bore the blame.' % scapegoat)
                result.add_out_player(scapegoat)
            else:
                result.log_public('Nobody was voted.')


class AppointNewMayor(_WerewolvesAction):

    role = None
    tag = Tag.APPOINTED_AS_MAYOR

    def is_executable_by(self, player):
        return player.is_out and player.has_tag(Tag.APPOINTED_AS_MAYOR)


class HunterAction(_WerewolvesAction):

    role = Role.HUNTER
    tag = Tag.SHOT_BY_HUNTER

    def get_min_max_num_targets(self):
        return 0, 1

    def is_executable_by(self, player):
        return player.is_out and player.role == self.role and not player.has_tag(Tag.INCAPACITATED)

    def execute_with_result(self, players, targets, option, result):
        for target in targets:
            target = targets[0]
            target.mark_out(self.tag)
            result.log_public('%s shot %s' % (self.role, target))
            result.add_out_player(target)


class ScapegoatAction(_WerewolvesAction):

    role = Role.SCAPEGOAT
    tag = Tag.DEBARRED_FROM_VOTING

    def is_executable_by(self, player):
        return player.is_out and player.role == self.role and not player.has_tag(Tag.INCAPACITATED)


class WerewolvesActionList(ActionList):

    initial_action_classes = (
        ThiefAction,
        CupidoAction,
        WerewolfAction,
        SeerAction,
        WitchAction,
        BodyguardAction,
        FlutePlayerAction,
        SettleTags,
        ElectMayor,
        VoteAndLynch,
    )

    action_classes = initial_action_classes + (AppointNewMayor, HunterAction, ScapegoatAction)

    def move_to_next(self, result):
        one_off_action_classes = (
            ThiefAction, CupidoAction, ElectMayor, AppointNewMayor, HunterAction, ScapegoatAction
        )
        if isinstance(self[self.index], one_off_action_classes):
            self.pop(self.index)
            if self.index >= len(self):
                self.index = self.index % len(self)
                return True
            else:
                return False
        else:
            is_hunter_action_enabled = False
            is_scapegoat_action_enabled = False
            is_mayor_action_enabled = False
            for out_player in result.out_players:
                if out_player.role == Role.HUNTER and out_player.out_tag != Tag.POISONED_BY_WITCH:
                    if not out_player.has_tag(Tag.INCAPACITATED):
                        is_hunter_action_enabled = True
                if out_player.role == Role.SCAPEGOAT and out_player.out_tag == Tag.BORE_THE_BLAME:
                    if not out_player.has_tag(Tag.INCAPACITATED):
                        is_scapegoat_action_enabled = True
                if out_player.has_tag(Tag.APPOINTED_AS_MAYOR):
                    is_mayor_action_enabled = True
            if is_hunter_action_enabled:
                self.insert(self.index + 1, HunterAction())
            if is_scapegoat_action_enabled:
                self.insert(self.index + 1, ScapegoatAction())
            if is_mayor_action_enabled:
                self.insert(self.index + 1, AppointNewMayor())
            return super(WerewolvesActionList, self).move_to_next(result)
