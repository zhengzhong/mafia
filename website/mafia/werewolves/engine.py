#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import random

from mafia.gameplay import Engine
from mafia.werewolves.constants import Role, Tag
from mafia.werewolves.actions import WerewolvesActionList


logger = logging.getLogger(__name__)


class WerewolvesEngine(Engine):

    action_list_class = WerewolvesActionList

    def get_role_list_on_stage(self):
        return (
            [Role.WEREWOLF] * self.game.config['num_werewolves'] + [Role.PSYCHIC]
            + [Role.THIEF] * (1 if self.game.config['has_thief'] else 0)
            + [Role.CUPID] * (1 if self.game.config['has_cupid'] else 0)
            + [Role.BODYGUARD] * (1 if self.game.config['has_bodyguard'] else 0)
            + [Role.WIZARD] * (1 if self.game.config['has_wizard'] else 0)
            + [Role.HUNTER] * (1 if self.game.config['has_hunter'] else 0)
        )

    def get_alignment(self, role1, role2):
        return Role.get_alignment(role1, role2)

    def get_civilian_role(self):
        return Role.CIVILIAN

    def get_num_unused_players(self):
        if self.game.config['has_thief']:
            return 2
        else:
            return 0

    def update_game_over(self):
        active_player_list = [player for player in self.game.player_list if not player.is_out]
        werewolf_list = [player for player in active_player_list if player.role == Role.WEREWOLF]
        if not werewolf_list:
            logger.info('All werewolves were dead: civilians win!')
            self.game.is_over = True
        if len(werewolf_list) * 2 >= len(active_player_list):
            logger.info('Werewolves killed too many people: werewolves win!')
            self.game.is_over = True
