#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.models import Game
from mafia.classic.constants import Role, Tag
from mafia.tests.base import BaseMafiaEngineStartedTestCase


class ClassicSettlementTestCase(BaseMafiaEngineStartedTestCase):

    variant = Game.VARIANT_CLASSIC

    def test_player_was_shot(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.KILLER, civilian)
        result = self.settle_tags()
        # Player should be killed.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)

    def test_player_was_shot_and_cured(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.KILLER, civilian)
        self.execute_action_for_role(Role.DOCTOR, civilian)
        result = self.settle_tags()
        # Player should not be killed nor misdiagnosed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)
        self.assertFalse(civilian.has_tag(Tag.MISDIAGNOSED))

    def test_player_was_cured_but_not_shot(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.DOCTOR, civilian)
        self.assertTrue(civilian.has_tag(Tag.CURED))
        self.assertFalse(civilian.has_tag(Tag.MISDIAGNOSED))
        result = self.settle_tags()
        # Player should be misdiagnosed.
        self.assertEqual(result.out_players, [])
        self.assertTrue(civilian.has_tag(Tag.MISDIAGNOSED))
        self.assertFalse(civilian.has_tag(Tag.CURED))
        self.assertFalse(civilian.is_out)

    def test_player_was_misdiagnosed_twice(self):
        civilian = self.get_player(Role.CIVILIAN)
        # Misdiagnosed for the first time.
        self.execute_action_for_role(Role.DOCTOR, civilian)
        self.settle_tags()
        self.assertFalse(civilian.is_out)
        self.assertTrue(civilian.has_tag(Tag.MISDIAGNOSED))
        # Misdiagnosed for the second time.
        self.execute_action_for_role(Role.DOCTOR, civilian)
        result = self.settle_tags()
        # Player should be killed.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)

    def test_player_was_guarded_and_shot(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.execute_action_for_role(Role.KILLER, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.assertTrue(civilian.has_tag(Tag.SHOT))
        result = self.settle_tags()
        # Player should not be killed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)

    def test_guardian_angel_was_guarded_and_shot(self):
        guardian_angel = self.get_player(Role.GUARDIAN_ANGEL)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, guardian_angel)
        self.execute_action_for_role(Role.KILLER, guardian_angel)
        self.assertTrue(guardian_angel.has_tag(Tag.GUARDED))
        self.assertTrue(guardian_angel.has_tag(Tag.SHOT))
        result = self.settle_tags()
        # Guardian angel should be killed.
        self.assertEqual(result.out_players, [guardian_angel])
        self.assertTrue(guardian_angel.is_out)

    def test_player_was_guarded_and_cured(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.execute_action_for_role(Role.DOCTOR, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.assertTrue(civilian.has_tag(Tag.CURED))
        result = self.settle_tags()
        # Player should not be misdiagnosed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.has_tag(Tag.MISDIAGNOSED))
        self.assertFalse(civilian.has_tag(Tag.CURED))
        self.assertFalse(civilian.is_out)

    def test_player_was_cured_while_doctor_was_guarded(self):
        civilian = self.get_player(Role.CIVILIAN)
        doctor = self.get_player(Role.DOCTOR)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, doctor)
        self.execute_action_for_role(Role.DOCTOR, civilian)
        self.assertTrue(civilian.has_tag(Tag.CURED))
        self.assertTrue(doctor.has_tag(Tag.GUARDED))
        result = self.settle_tags()
        # Player should not be misdiagnosed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.has_tag(Tag.MISDIAGNOSED))

    def test_player_was_shot_while_killer_was_guarded(self):
        civilian = self.get_player(Role.CIVILIAN)
        killer = self.get_player(Role.KILLER)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, killer)
        self.execute_action_for_role(Role.KILLER, civilian)
        self.assertTrue(killer.has_tag(Tag.GUARDED))
        self.assertTrue(civilian.has_tag(Tag.SHOT))
        result = self.settle_tags()
        # Player should not be killed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)

    def test_guardian_angel_was_shot_while_killer_was_guarded(self):
        guardian_angel = self.get_player(Role.GUARDIAN_ANGEL)
        killer = self.get_player(Role.KILLER)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, killer)
        self.execute_action_for_role(Role.KILLER, guardian_angel)
        self.assertTrue(killer.has_tag(Tag.GUARDED))
        self.assertTrue(guardian_angel.has_tag(Tag.SHOT))
        result = self.settle_tags()
        # Both guardian angel and killer should be killed.
        self.assertEqual(set(result.out_players), set([guardian_angel, killer]))
        self.assertTrue(guardian_angel.is_out)
        self.assertTrue(killer.is_out)

    def test_player_was_guarded_while_guardian_angel_was_shot(self):
        civilian = self.get_player(Role.CIVILIAN)
        guardian_angel = self.get_player(Role.GUARDIAN_ANGEL)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.execute_action_for_role(Role.KILLER, guardian_angel)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.assertTrue(guardian_angel.has_tag(Tag.SHOT))
        result = self.settle_tags()
        # Both guardian angel and the guarded player should be killed.
        self.assertEqual(set(result.out_players), set([civilian, guardian_angel]))
        self.assertTrue(civilian.is_out)
        self.assertTrue(guardian_angel.is_out)

    def test_player_was_guarded_and_shot_and_cured(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.execute_action_for_role(Role.KILLER, civilian)
        self.execute_action_for_role(Role.DOCTOR, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.assertTrue(civilian.has_tag(Tag.SHOT))
        self.assertTrue(civilian.has_tag(Tag.CURED))
        result = self.settle_tags()
        # Player should not be killed, nor be misdiagnosed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)
        self.assertFalse(civilian.has_tag(Tag.MISDIAGNOSED))

    def test_guardian_angel_was_guarded_and_shot_and_cured(self):
        """
        When guardian angel was guarded and shot, he could still have been killed.
        But doctor cured guardian angel, so guardian angel is not killed (nor misdiagnosed).
        Thus, killer should not be out either.
        """
        guardian_angel = self.get_player(Role.GUARDIAN_ANGEL)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, guardian_angel)
        self.execute_action_for_role(Role.KILLER, guardian_angel)
        self.execute_action_for_role(Role.DOCTOR, guardian_angel)
        self.assertTrue(guardian_angel.has_tag(Tag.GUARDED))
        self.assertTrue(guardian_angel.has_tag(Tag.SHOT))
        self.assertTrue(guardian_angel.has_tag(Tag.CURED))
        result = self.settle_tags()
        # Guardian angel should be killed but not misdiagnosed.
        self.assertEqual(result.out_players, [guardian_angel])
        self.assertTrue(guardian_angel.is_out)
        self.assertFalse(guardian_angel.has_tag(Tag.MISDIAGNOSED))

    def test_guardian_angel_was_shot_and_cured_while_killer_was_guarded(self):
        """
        When guardian angel guarded killer and was shot, he could still have been killed.
        But doctor cured guardian angel, so guardian angel is not killed (nor misdiagnosed).
        Thus, killer should not be out either.
        """
        guardian_angel = self.get_player(Role.GUARDIAN_ANGEL)
        killer = self.get_player(Role.KILLER)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, killer)
        self.execute_action_for_role(Role.KILLER, guardian_angel)
        self.execute_action_for_role(Role.DOCTOR, guardian_angel)
        self.assertTrue(killer.has_tag(Tag.GUARDED))
        self.assertTrue(guardian_angel.has_tag(Tag.SHOT))
        self.assertTrue(guardian_angel.has_tag(Tag.CURED))
        result = self.settle_tags()
        # Guardian angel should not be killed nor be misdiagnosed.
        self.assertEqual(result.out_players, [])
        self.assertFalse(guardian_angel.is_out)
        self.assertFalse(guardian_angel.has_tag(Tag.MISDIAGNOSED))
        # Killer should not be killed.
        self.assertFalse(killer.is_out)

    def test_guardian_angel_was_shot_and_cured_while_doctor_was_guarded(self):
        """
        When doctor was guarded, his action has no effect.
        When guardian angel was shot and cured, he should still be killed.
        Thus doctor should also be out (as he was guarded).
        """
        guardian_angel = self.get_player(Role.GUARDIAN_ANGEL)
        doctor = self.get_player(Role.DOCTOR)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, doctor)
        self.execute_action_for_role(Role.KILLER, guardian_angel)
        self.execute_action_for_role(Role.DOCTOR, guardian_angel)
        self.assertTrue(doctor.has_tag(Tag.GUARDED))
        self.assertTrue(guardian_angel.has_tag(Tag.SHOT))
        self.assertTrue(guardian_angel.has_tag(Tag.CURED))
        result = self.settle_tags()
        # Both guardian angel and doctor should be out.
        self.assertEqual(set(result.out_players), set([guardian_angel, doctor]))
        self.assertTrue(guardian_angel.is_out)
        self.assertTrue(doctor.is_out)

    def test_player_was_guarded_twice_continuously(self):
        civilian = self.get_player(Role.CIVILIAN)
        # Guarded for the first time.
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.settle_tags()
        self.assertFalse(civilian.has_tag(Tag.UNGUARDABLE))
        # Guarded for the second time.
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.settle_tags()
        self.assertTrue(civilian.has_tag(Tag.UNGUARDABLE))

    def test_player_was_guarded_but_not_continuously(self):
        civilian = self.get_player(Role.CIVILIAN)
        # Guarded for the first time.
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.settle_tags()
        self.assertFalse(civilian.has_tag(Tag.UNGUARDABLE))
        # Not guarded for the second time.
        self.settle_tags()
        self.assertFalse(civilian.has_tag(Tag.UNGUARDABLE))
        # Guarded for the second time, but not continuously.
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.settle_tags()
        self.assertFalse(civilian.has_tag(Tag.UNGUARDABLE))

    def test_player_was_voted(self):
        civilian = self.get_player(Role.CIVILIAN)
        result = self.vote(civilian)
        # Player should be lynched.
        self.assertEqual(result.out_players, [civilian])
        self.assertTrue(civilian.is_out)

    def test_player_was_guarded_and_voted(self):
        civilian = self.get_player(Role.CIVILIAN)
        self.execute_action_for_role(Role.GUARDIAN_ANGEL, civilian)
        self.assertTrue(civilian.has_tag(Tag.GUARDED))
        self.settle_tags()
        self.assertTrue(civilian.has_tag(Tag.PREVIOUSLY_GUARDED))
        result = self.vote(civilian)
        # Player should be exempted.
        self.assertEqual(result.out_players, [])
        self.assertFalse(civilian.is_out)
