#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging

from django.test import TestCase
from mafia.models import Game, Player
from mafia.classic import ClassicEngine
from mafia.werewolves import WerewolvesEngine


logger = logging.getLogger(__name__)


class MafiaTestCase(TestCase):

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
                'has_thief': True,
                'has_cupid': True,
                'has_bodyguard': True,
                'has_wizard': True,
                'has_hunter': True,
            },
        }
    }

    def setUp(self):
        logger.info('Setting up mafia game test case (variant: %s)...' % self.variant)
        self.game = Game.objects.get(pk=1)
        self.game.variant = self.variant
        self.game.config = self.settings[self.variant]['config']
        self.game.save()
        self.engine = self.settings[self.variant]['engine'](self.game)
        self.engine.start_game(force=True)

    def get_player(self, role):
        return next(p for p in self.engine.player_list if p.role == role)

    def execute_action_for_role(self, role, target):
        action = next(a for a in self.engine.action_list if a.role == role)
        return action.execute(self.engine.player_list, [target], None)

    def settle_tags(self):
        action = next(a for a in self.engine.action_list if a.name == 'SettleTags')
        return action.execute(self.engine.player_list, [], None)

    def vote(self, target):
        action = next(a for a in self.engine.action_list if a.name == 'VoteAndLynch')
        return action.execute(self.engine.player_list, [target], None)
