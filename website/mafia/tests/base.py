#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging

from django.test import TestCase
from mafia.models import Game, Player
from mafia.classic import ClassicEngine
from mafia.werewolves import WerewolvesEngine


logger = logging.getLogger(__name__)


class BaseMafiaEngineTestCase(TestCase):

    fixtures = ['mafia_users', 'mafia_game']

    variant = None

    settings = {
        Game.VARIANT_CLASSIC: {
            'engine': ClassicEngine,
            'config': {
                'num_killers': 2,
                'num_detectives': 2,
                'has_guardian': True,
                'has_doctor': True,
                'has_traitor': True,
            },
        },
        Game.VARIANT_WEREWOLVES: {
            'engine': WerewolvesEngine,
            'config': {
                'num_werewolves': 2,
                'has_thief': False,
                'has_cupido': True,
                'has_witch': True,
                'has_hunter': True,
                'has_bodyguard': True,
                'has_idiot': True,
                'has_senior': True,
                'has_scapegoat': True,
                'has_flute_player': True,
            },
        }
    }

    def setUp(self):
        logger.info('Setting up mafia engine (variant: %s)...' % self.variant)
        self.game = Game.objects.get(pk=1)
        self.game.variant = self.variant
        self.game.config = self.settings[self.variant]['config']
        self.game.save()
        self.engine = self.settings[self.variant]['engine'](self.game)


class BaseMafiaEngineStartedTestCase(BaseMafiaEngineTestCase):

    def setUp(self):
        super(BaseMafiaEngineStartedTestCase, self).setUp()
        logger.info('Starting game...')
        self.engine.start_game(force=True)

    def get_player(self, role):
        return next(p for p in self.game.player_list if p.role == role)

    def execute_action_for_role(self, role, target, option=None):
        action = next(a for a in self.engine.action_list if a.role == role)
        return action.execute(self.game.player_list, [target], option)

    def settle_tags(self):
        action = next(a for a in self.engine.action_list if a.name == 'SettleTags')
        return action.execute(self.game.player_list, [], None)

    def vote(self, target):
        action = next(a for a in self.engine.action_list if a.name == 'VoteAndLynch')
        targets = [target] if target is not None else []
        return action.execute(self.game.player_list, targets, None)


class EngineTestCaseMixin(object):

    def test_ensure_host(self):
        # Prepare players.
        for player in self.game.player_list:
            player.is_host = False
            player.save()
        # Ensure host and assert.
        self.game.ensure_host()
        self.assertTrue(self.game.player_list[0].is_host)
        for player in self.game.player_list[1:]:
            self.assertFalse(player.is_host)

    def test_ensure_host_when_host_is_out(self):
        # Prepare players.
        first_player = self.game.player_list[0]
        first_player.is_host = True
        first_player.save()
        for player in self.game.player_list[1:]:
            player.is_host = False
            player.save()
        # Mark host out.
        first_player.mark_out(self.get_lynched_tag())
        # Ensure host and assert.
        self.game.ensure_host()
        self.assertFalse(self.game.player_list[0].is_host)
        self.assertTrue(self.game.player_list[1].is_host)
        for player in self.game.player_list[2:]:
            self.assertFalse(player.is_host)

    def test_ensure_host_when_host_is_removed(self):
        # Prepare players.
        first_player = self.game.player_list[0]
        first_player.is_host = True
        first_player.save()
        for player in self.game.player_list[1:]:
            player.is_host = False
            player.save()
        # Remove players.
        self.game.remove_players(first_player.user)
        # Ensure host and assert.
        self.game.ensure_host()
        self.assertNotEqual(self.game.player_list[0].user, first_player.user)
        self.assertTrue(self.game.player_list[0].is_host)
        for player in self.game.player_list[1:]:
            self.assertNotEqual(player.user, first_player.user)
            self.assertFalse(player.is_host)

    def get_lynched_tag(self):
        raise NotImplementedError()
