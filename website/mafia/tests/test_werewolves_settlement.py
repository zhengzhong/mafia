#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.models import Game
from mafia.werewolves.constants import Role, Tag
from mafia.tests.base import BaseMafiaEngineStartedTestCase


class WerewolvesSettlementTestCase(BaseMafiaEngineStartedTestCase):

    variant = Game.VARIANT_WEREWOLVES

    def test_player_was_attacked(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WEREWOLF, civilian)
        result = self.settle_tags()
        # Player should be killed.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)

    def test_player_was_attacked_and_cured(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WEREWOLF, civilian)
        self.execute_action_for_role(Role.WITCH, civilian, 'cure')
        result = self.settle_tags()
        # Player should not be killed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)

    def test_player_was_poisoned(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WITCH, civilian, 'poison')
        self.assertTrue(civilian.has_tag(Tag.POISONED_BY_WITCH))
        result = self.settle_tags()
        # Player should be killed.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)

    def test_player_was_attacked_and_poisoned(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WEREWOLF, civilian)
        self.execute_action_for_role(Role.WITCH, civilian, 'poison')
        self.assertTrue(civilian.has_tag(Tag.ATTACKED_BY_WEREWOLF))
        self.assertTrue(civilian.has_tag(Tag.POISONED_BY_WITCH))
        result = self.settle_tags()
        # Player should be killed by werewolf.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)
        self.assertEqual(civilian.out_tag, Tag.ATTACKED_BY_WEREWOLF)

    def test_player_was_attacked_and_protected(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WEREWOLF, civilian)
        self.execute_action_for_role(Role.BODYGUARD, civilian)
        self.assertTrue(civilian.has_tag(Tag.ATTACKED_BY_WEREWOLF))
        self.assertTrue(civilian.has_tag(Tag.PROTECTED_BY_BODYGUARD))
        result = self.settle_tags()
        # Player should not be killed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)

    def test_player_was_poisoned_and_protected(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WITCH, civilian, 'poison')
        self.execute_action_for_role(Role.BODYGUARD, civilian)
        self.assertTrue(civilian.has_tag(Tag.POISONED_BY_WITCH))
        self.assertTrue(civilian.has_tag(Tag.PROTECTED_BY_BODYGUARD))
        result = self.settle_tags()
        # Player should be killed.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)
        self.assertEqual(civilian.out_tag, Tag.POISONED_BY_WITCH)

    def test_player_was_attacked_and_cured_and_protected(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WEREWOLF, civilian)
        self.execute_action_for_role(Role.WITCH, civilian, 'cure')
        self.execute_action_for_role(Role.BODYGUARD, civilian)
        self.assertTrue(civilian.has_tag(Tag.ATTACKED_BY_WEREWOLF))
        self.assertTrue(civilian.has_tag(Tag.CURED_BY_WITCH))
        self.assertTrue(civilian.has_tag(Tag.PROTECTED_BY_BODYGUARD))
        result = self.settle_tags()
        # Player should not be killed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)

    def test_player_was_attacked_and_poisoned_and_protected(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.WEREWOLF, civilian)
        self.execute_action_for_role(Role.WITCH, civilian, 'poison')
        self.execute_action_for_role(Role.BODYGUARD, civilian)
        self.assertTrue(civilian.has_tag(Tag.ATTACKED_BY_WEREWOLF))
        self.assertTrue(civilian.has_tag(Tag.POISONED_BY_WITCH))
        self.assertTrue(civilian.has_tag(Tag.PROTECTED_BY_BODYGUARD))
        result = self.settle_tags()
        # Player should be killed.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)
        self.assertEqual(civilian.out_tag, Tag.POISONED_BY_WITCH)

    def test_player_was_voted(self):
        civilian = self.get_player(Role.CIVILIAN)
        result = self.vote(civilian)
        # Player should be lynched.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)

    def test_nobody_was_voted(self):
        # When nobody was voted, scapegoat bears the blame.
        result = self.vote(None)
        scapegoat = self.get_player(Role.SCAPEGOAT)
        self.assertEqual(result.out_players, [scapegoat])
        self.assertTrue(scapegoat.is_out)
        self.assertEqual(scapegoat.out_tag, Tag.BORE_THE_BLAME)
        # If scapegoat is dead, nobody should be lynched.
        result = self.vote(None)
        self.assertEqual(result.out_players, [])
