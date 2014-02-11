#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import random

from mafia.exceptions import GameError


logger = logging.getLogger(__name__)


class ActionResult(object):

    class Message(object):

        def __init__(self, text, visibility):
            self.text = text
            self.visibility = visibility

    def __init__(self, action_name):
        self.action_name = action_name
        self.messages = []
        self.out_players = []

    def log(self, text, visibility):
        logger.info('[%s] %s - %s' % (visibility, self.action_name, text))
        self.messages.append(self.Message(text, visibility))

    def log_public(self, text):
        self.log(text, visibility='*')

    def log_private(self, text):
        self.log(text, visibility='')

    def add_out_player(self, player):
        self.log_public('%s is out.' % player)
        self.out_players.append(player)


class Action(object):

    role = None
    tag = None
    is_optional = False

    def __init__(self, **kwargs):
        pass

    @property
    def name(self):
        return self.__class__.__name__

    def __unicode__(self):
        return self.name

    def __str__(self):
        return unicode(self).encode('utf-8')

    def get_data(self):
        """
        Returns the data of this action to be persisted. The dict returned by this method will be
        used as keyword arguments to ``__init__()`` to re-create the action.
        """
        return {}

    def get_min_max_num_targets(self):
        """
        Returns the min/max number of target players on whom this action should be executed.
        By default, this method returns (1, 1), indicating that exactly one target player.
        """
        return 1, 1

    def is_executable(self, players):
        """
        Checks if this action is executable or should be skipped.
        """
        for player in players:
            if self.is_executable_by(player):
                return True
        return False

    def is_executable_by(self, player):
        """
        Checks if this action is executable by the given player. By default, an action is
        executable by the player who is not out and has the corresponding role.
        """
        return not player.is_out and player.role == self.role

    def is_executable_on(self, target):
        """
        Checks if this action is executable on the given player. By default, an action is
        executable on any active player.
        """
        return not target.is_out

    def execute(self, players, targets, options):
        """
        Executes this action.
        """
        # Perform some checks before executing this action.
        if not self.is_executable(players):
            raise GameError('%s is not executable.' % self.name)
        min_num_targets, max_num_targets = self.get_min_max_num_targets()
        if not (min_num_targets <= len(targets) <= max_num_targets):
            raise GameError('%s should be executed on [%d, %d] targets but got %d.'
                            % (self.name, min_num_targets, max_num_targets, len(targets)))
        for target in targets:
            if not self.is_executable_on(target):
                raise GameError('%s is not executable on %s.' % (self.name, target))
        # Execute this action.
        result = ActionResult(self.name)
        self.pre_execute(players, options, result)
        for target in targets:
            self.do_execute(players, target, options, result)
        self.post_execute(players, options, result)
        return result

    def pre_execute(self, players, options, result):
        """
        This method is called before the action is executed on any players.
        """
        pass

    def do_execute(self, players, target, options, result):
        """
        This method is called to execute the action on the given target player.
        By default, it adds the action tag to the target player (tag should not be None).
        """
        if self.tag is None:
            raise GameError('Tag is undefined for %s.' % self.name)
        target.add_tag(self.tag)
        text = '%s selected %s' % (self.role, target)
        answer = self.get_answer(target)
        if answer is not None:
            text += ': %s' % answer
        result.log(text, visibility=self.role)

    def get_answer(self, target):
        return None

    def post_execute(self, players, options, result):
        """
        This method is called after the action is executed on all target players.
        """
        pass


class ActionList(list):

    initial_action_classes = None
    action_classes = None

    def __init__(self, actions=None, index=0):
        super(ActionList, self).__init__(actions or [])
        self.index = index

    def current(self):
        if not (0 <= self.index < len(self)):
            raise GameError('Action index out of bound: %d' % self.index)
        return self[self.index]

    def move_to_next(self, result, players):
        for step in range(1, len(self)):
            next_index = (self.index + step) % len(self)
            if self[next_index].is_executable(players):
                self.index = next_index
                return
        raise GameError('Cannot find index for the next executable action.')

    def as_json_data(self):
        list_data = []
        for action in self:
            action_data = {'_name': action.__class__.__name__}
            action_data.update(action.get_data())
            list_data.append(action_data)
        return {'_list': list_data, 'index': self.index}

    @classmethod
    def load_json_data(cls, json_data):
        if not json_data:
            return cls()
        # Load actions.
        actions = []
        list_data = json_data.get('_list', [])
        for action_data in list_data:
            class_name = action_data.pop('_name')
            action_class = next(
                (clas for clas in cls.action_classes if clas.__name__ == class_name),
                None
            )
            if action_class is None:
                raise GameError('Invalid action class name: %s' % class_name)
            action = action_class(**action_data)
            actions.append(action)
        # Load index.
        index = json_data.get('index', 0)
        # Recreate action list.
        return cls(actions, index)

    @classmethod
    def create_initial(cls, role_list):
        actions = []
        for action_class in cls.initial_action_classes:
            if not action_class.is_optional or action_class.role in role_list:
                actions.append(action_class())
        return cls(actions)


class Engine(object):

    action_list_class = None

    def __init__(self, game):
        assert issubclass(self.action_list_class, ActionList)
        self.game = game
        self.action_list = self.action_list_class.load_json_data(game.context.get('action_list'))

    def get_role_list_on_stage(self):
        raise NotImplementedError()

    def get_alignment(self, role1, role2):
        raise NotImplementedError()

    def get_civilian_role(self):
        raise NotImplementedError()

    def update_game_over(self):
        raise NotImplementedError()

    def get_min_max_num_players(self):
        num_roles = len(self.get_role_list_on_stage())
        return int(1.5 * num_roles), 3 * num_roles

    def get_current_action(self):
        if not self.game.is_ongoing:
            return None
        return self.action_list.current()

    def get_possible_target_list(self):
        current_action = self.get_current_action()
        if current_action is None:
            return []
        else:
            return [
                player for player in self.game.player_set.all()
                if current_action.is_executable_on(player)
            ]

    def start_game(self, force=False):
        # Check if game can be started.
        if not force:
            if self.game.is_over:
                raise GameError('Cannot start game %s: game is over.' % self.game)
            if self.game.round > 0:
                raise GameError('Cannot start game %s: game is already started.' % self.game)
        min_num_players, max_num_players = self.get_min_max_num_players()
        player_list = list(self.game.player_set.all())
        if not (min_num_players <= len(player_list) <= max_num_players):
            raise GameError('Cannot start game %s: there are %d players but requires [%d, %d].'
                            % (self.game, len(player_list), min_num_players, max_num_players))
        # Now start the game by randomly assigning roles to players.
        logger.info('Assigning roles to players...')
        [player.reset() for player in player_list]
        random.shuffle(player_list)
        for role in self.get_role_list_on_stage():
            assigned_player = None
            for player in player_list:
                if player.twin is None or self.get_alignment(player.twin.role, role) != 0:
                    player.role = role
                    player.save()
                    assigned_player = player
                    break
            assert assigned_player is not None
            player_list.remove(assigned_player)
        for player in player_list:
            player.role = self.get_civilian_role()
            player.save()
        # Initialize action list.
        logger.info('Initializing action list...')
        self.action_list = self.action_list_class.create_initial(self.get_role_list_on_stage())
        # Update game state.
        logger.info('Updating game state...')
        self.game.round = 1
        self.game.is_over = False
        self.save_game()

    def execute_action(self, targets, options):
        # Execute the current action and check if game is over.
        action = self.get_current_action()
        players = self.game.player_set.all()
        logger.info('About to execute %s...' % action)
        result = action.execute(players, targets, options)
        self.game.log_action_result(result)
        self.update_game_over()
        # Move to next action.
        if not self.game.is_over:
            self.action_list.move_to_next(result, players)
            if self.action_list.index == 0:
                self.game.round += 1
        self.save_game()

    def save_game(self):
        logger.info('Saving game...')
        self.game.context = {'action_list': self.action_list.as_json_data()}
        self.game.save()