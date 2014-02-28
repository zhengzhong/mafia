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

    def execute(self, players, targets, option):
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
        self.execute_with_result(players, targets, option, result)
        return result

    def execute_with_result(self, players, targets, option, result):
        """
        Executes this action and fills the result. By default, this method adds the action tag
        to all the target players (tag should not be None).
        """
        if not targets:
            result.log('%s did not select anyone' % self.role, visibility=self.role)
        else:
            tag = self.get_tag(option)
            if not tag:
                raise GameError('Tag is undefined for %s.' % self.name)
            for target in targets:
                target.add_tag(tag)
                text = '%s tagged %s with %s' % (self.role, target, tag)
                answer = self.get_answer(target)
                if answer is not None:
                    text += ': %s' % answer
                result.log(text, visibility=self.role)

    def get_option_choices(self):
        return []

    def get_tag(self, option):
        """
        Returns the action tag to be added on targets. This method is called only when there's
        at least one target. By default, it returns the ``tag`` class attribute.
        """
        return self.tag

    def get_answer(self, target):
        return None

    def skip(self, players):
        """
        Skips this action. Only non-executable action can be skipped.
        """
        # Perform some checks before skipping this action.
        if self.is_executable(players):
            raise GameError('%s is executable thus cannot be skipped.' % self.name)
        # Skip this action.
        result = ActionResult(self.name)
        result.log('Skipped', visibility=self.role)
        return result

    def get_json_dict(self):
        min_num_targets, max_num_targets = self.get_min_max_num_targets()
        return {
            'name': self.name,
            'role': self.role,
            'option_choices': self.get_option_choices(),
            'min_num_targets': min_num_targets,
            'max_num_targets': max_num_targets,
        }


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

    def move_to_next(self, result):
        self.index = (self.index + 1) % len(self)
        return self.index == 0

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


class SettlementRule(object):

    tag = None

    def settle(self, players, result):
        if self.tag is None:
            raise GameError('Tag is undefined for rule %s.' % self.__class__.__name__)
        for player in players:
            if not player.is_out and player.has_tag(self.tag):
                self.settle_tagged_player(player, players, result)

    def filter_players_by_tag(self, players, tag):
        return [p for p in players if not p.is_out and p.has_tag(tag)]

    def settle_tagged_player(self, tagged_player, players, result):
        raise NotImplementedError()


class Engine(object):

    action_list_class = None

    def __init__(self, game):
        assert issubclass(self.action_list_class, ActionList)
        self.game = game
        self.action_list = self.action_list_class.load_json_data(game.context.get('action_list'))

    def get_translations(self):
        return {}

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

    def get_num_unused_players(self):
        return 0

    def get_game_state(self):
        if self.game.is_over:
            return 'Game Over'
        if self.game.is_ongoing:
            return 'Ongoing'
        min_num_players, max_num_players = self.get_min_max_num_players()
        num_players = len(self.game.player_list)
        if num_players < min_num_players:
            return 'Waiting for Players'
        elif num_players < max_num_players:
            return 'Ready / Waiting for Players'
        else:
            return 'Ready'

    def is_joinable(self):
        if self.game.is_ongoing or self.game.is_over:
            return False
        __, max_num_players = self.get_min_max_num_players()
        return len(self.game.player_list) < max_num_players

    def is_startable(self):
        if self.game.is_ongoing or self.game.is_over:
            return False
        min_num_players, max_num_players = self.get_min_max_num_players()
        return min_num_players <= len(self.game.player_list) <= max_num_players

    def get_current_action(self):
        if not self.game.is_ongoing:
            return None
        return self.action_list.current()

    def reset_game(self):
        self.game.reset()
        self.action_list = self.action_list_class()
        self.save_game()

    def start_game(self, force=False):
        # Check if game can be started.
        if self.game.is_ongoing and not force:
            raise GameError('Cannot start game %s: game is ongoing.' % self.game)
        # Reset the game.
        logger.info('Resetting game...')
        self.reset_game()
        self.game.ensure_unused_players(self.get_num_unused_players())
        min_num_players, max_num_players = self.get_min_max_num_players()
        num_players = len(self.game.player_list)
        if not (min_num_players <= num_players <= max_num_players):
            raise GameError('Cannot start game %s: there are %d players but requires [%d, %d].'
                            % (self.game, num_players, min_num_players, max_num_players))
        # Assign roles to players randomly.
        player_list = list(self.game.player_list)
        logger.info('Assigning roles to players...')
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

    def skip_action_if_not_executable(self):
        # Check if the game is still ongoing.
        if not self.game.is_ongoing:
            return
        # Skip the current action if it's not executable.
        action = self.get_current_action()
        if not action.is_executable(self.game.player_list):
            elapsed_seconds = self.game.get_elapsed_seconds_since_last_update()
            threshold = self.game.delay_seconds + random.randint(0, self.game.delay_seconds)
            if elapsed_seconds >= threshold:
                logger.info('Skipping %s after %d seconds...' % (action, elapsed_seconds))
                result = action.skip(self.game.player_list)
                self.game.log_action_result(result)
                self.move_to_next_action(result)
                self.save_game()

    def execute_action(self, action_name, targets, option=None):
        # Execute the current action and check if game is over.
        if not self.game.is_ongoing:
            raise GameError('Cannot execute action because game is not ongoing.')
        action = self.get_current_action()
        if action.name != action_name:
            raise GameError('Invalid action name %s, expected %s.' % (action_name, action.name))
        logger.info('About to execute %s...' % action)
        result = action.execute(self.game.player_list, targets, option)
        self.game.log_action_result(result)
        self.update_game_over()
        # Move to next action.
        if not self.game.is_over:
            self.move_to_next_action(result)
        self.save_game()

    def move_to_next_action(self, result):
        is_new_round = self.action_list.move_to_next(result)
        if is_new_round:
            self.game.round += 1

    def save_game(self):
        logger.info('Saving game...')
        self.game.context = {'action_list': self.action_list.as_json_data()}
        self.game.ensure_host()
        self.game.save()

    def get_json_dict(self):
        json_dict = {
            'logs': self.game.logs,
            'round': self.game.round,
            'is_over': self.game.is_over,
            'update_date': self.game.update_date.isoformat(),
            'elapsed_seconds_since_last_update': self.game.get_elapsed_seconds_since_last_update(),
        }
        player_dict_list = []
        for player in self.game.player_list:
            player_dict = {
                'pk': player.pk,
                'username': player.username,
                'hand_side': player.hand_side,
                'is_host': player.is_host,
                'role': player.role,
                'tags': list(player.get_tags()),
                'is_unused': player.is_unused,
                'is_out': player.is_out,
            }
            player_dict_list.append(player_dict)
        json_dict['players'] = player_dict_list
        current_action = self.get_current_action()
        if current_action is not None:
            json_dict.update({
                'current_action': current_action.get_json_dict(),
                'actor_pk_list': [
                    p.pk for p in self.game.player_list if current_action.is_executable_by(p)
                ],
                'possible_target_pk_list': [
                    p.pk for p in self.game.player_list if current_action.is_executable_on(p)
                ],
            })
        else:
            json_dict.update({
                'current_action': None,
                'actor_pk_list': [],
                'possible_target_pk_list': [],
            })
        return json_dict
