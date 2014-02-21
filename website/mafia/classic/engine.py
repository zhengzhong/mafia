#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging

from mafia.gameplay import Engine
from mafia.classic.constants import Role
from mafia.classic.actions import ClassicActionList


logger = logging.getLogger(__name__)


class ClassicEngine(Engine):

    action_list_class = ClassicActionList

    def get_role_list_on_stage(self):
        return (
            [Role.KILLER] * self.game.config['num_killers']
            + [Role.DETECTIVE] * self.game.config['num_detectives']
            + [Role.GUARDIAN] * (1 if self.game.config['has_guardian'] else 0)
            + [Role.DOCTOR] * (1 if self.game.config['has_doctor'] else 0)
            + [Role.TRAITOR] * (1 if self.game.config['has_traitor'] else 0)
        )

    def get_alignment(self, role1, role2):
        return Role.get_alignment(role1, role2)

    def get_civilian_role(self):
        return Role.CIVILIAN

    def update_game_over(self):
        active_player_list = [player for player in self.player_list if not player.is_out]
        killer_list = [player for player in active_player_list if player.role == Role.KILLER]
        if not killer_list:
            logger.info('All killers were dead: civlians win!')
            self.game.is_over = True
        detective_list = [player for player in active_player_list if player.role == Role.DETECTIVE]
        if not detective_list:
            logger.info('All detectives were dead: killers win!')
            self.game.is_over = True
        if len(killer_list) * 2 >= len(active_player_list):
            logger.info('Killers killed too many people: killers win!')
            self.game.is_over = True
