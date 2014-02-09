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
            [Role.WEREWOLF] * 2
            + [Role.PROPHET, Role.HUNTER, Role.WIZARD, Role.GIRL, Role.CUPID]
        )

    def get_alignment(self, role1, role2):
        return Role.get_alignment(role1, role2)

    def get_civilian_role(self):
        return Role.CIVILIAN

    def update_game_over(self):
        player_list = self.game.player_set.all()
        active_player_list = [player for player in player_list if not player.is_out]
        werewolf_list = [player for player in active_player_list if player.role == Role.WEREWOLF]
        if not werewolf_list:
            logger.info('All werewolves were dead: civilians win!')
            self.game.is_over = True
        if len(werewolf_list) * 2 >= len(active_player_list):
            logger.info('Werewolves killed too many people: werewolves win!')
            self.game.is_over = True

    def start_game(self, force=False):
        super(WerewolvesEngine, self).start_game(force=force)
        # Randomly assign mayor to a player.
        player_list = list(self.game.player_set.all())
        random.shuffle(player_list)
        player_list[0].add_tag(Tag.MAYOR)
        player_list[0].save()
