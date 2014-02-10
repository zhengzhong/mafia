#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.gameplay import Action, ActionList
from mafia.classic.constants import Role, Tag
from mafia.classic.settlement import RULES


class GuardianAction(Action):

    role = Role.GUARDIAN
    tag = Tag.GUARDED
    is_optional = True

    def is_executable_on(self, target):
        return not target.is_out and not target.has_tag(Tag.UNGUARDABLE)


class KillerAction(Action):

    role = Role.KILLER
    tag = Tag.SHOT


class DetectiveAction(Action):

    role = Role.DETECTIVE
    tag = Tag.INVESTIGATED

    def is_executable_on(self, target):
        # A detectives can check any player except detectives, even if the player is out.
        return target.role != self.role

    def get_answer(self, target):
        return 'YES' if target.role == Role.KILLER else 'NO'


class DoctorAction(Action):

    role = Role.DOCTOR
    tag = Tag.CURED
    is_optional = True


class TraitorAction(Action):

    role = Role.TRAITOR
    tag = Tag.CONTACTED_BY_TRAITOR
    is_optional = True

    def is_executable_on(self, target):
        # A traitor can check any player except traitors, even if the player is out.
        return target.role != self.role

    def get_answer(self, target):
        return 'YES' if target.role == Role.KILLER else 'NO'


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
    tag = Tag.LYNCHED

    def is_executable_by(self, player):
        return player.is_host

    def do_execute(self, players, target, options, result):
        if target.has_tag(Tag.GUARDED):
            text = '%s was voted but exempted.' % target
        else:
            target.mark_out(self.tag)
            text = '%s was voted and lynched.' % target
        result.log_public(text)

    def post_execute(self, players, options, result):
        # Remove previous PREVIOUSLY_GUARDED tag.
        for player in players:
            if player.has_tag(Tag.PREVIOUSLY_GUARDED):
                player.remove_tag(Tag.PREVIOUSLY_GUARDED)
        # Update the GUARDED tag to PREVIOUSLY_GUARDED.
        for player in players:
            if player.has_tag(Tag.GUARDED):
                player.remove_tag(Tag.GUARDED)
                player.add_tag(Tag.PREVIOUSLY_GUARDED)


class ClassicActionList(ActionList):

    initial_action_classes = (
        GuardianAction,
        KillerAction,
        DetectiveAction,
        DoctorAction,
        TraitorAction,
        SettleTags,
        VoteAndLynch,
    )

    action_classes = initial_action_classes
