#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import hashlib
import json
import logging
import urllib

from django.conf import settings
from django.db import models
from django.utils import timezone
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth.models import User


logger = logging.getLogger(__name__)


TABLE_PREFIX = getattr(settings, 'MAFIA_TABLE_PREFIX', 'mafia_')


class Game(models.Model):

    VARIANT_CLASSIC = 'classic'
    VARIANT_WEREWOLVES = 'werewolves'

    VARIANT_CHOICES = (
        (VARIANT_CLASSIC, VARIANT_CLASSIC),
        (VARIANT_WEREWOLVES, VARIANT_WEREWOLVES),
    )

    MIN_DELAY_SECONDS = 0
    DEFAULT_DELAY_SECONDS = 10

    name = models.CharField(_('Game Name'), max_length=100)
    is_two_handed = models.BooleanField(_('Two-Handed'), default=True)
    variant = models.CharField(_('Variant'), max_length=20, choices=VARIANT_CHOICES, default=VARIANT_CLASSIC)
    delay_seconds = models.PositiveIntegerField(default=DEFAULT_DELAY_SECONDS)
    config_json = models.TextField(blank=True)
    context_json = models.TextField(blank=True)
    logs_json = models.TextField(blank=True)
    round = models.PositiveIntegerField(default=0)
    is_over = models.BooleanField(default=False)
    create_date = models.DateTimeField(auto_now_add=True)
    update_date = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = TABLE_PREFIX + 'game'
        ordering = ['-create_date']

    def __unicode__(self):
        return self.name

    @property
    def config(self):
        if not hasattr(self, '_config'):
            self._config = json.loads(self.config_json or '{}')
        return self._config

    @config.setter
    def config(self, value):
        if not value:
            self._config = {}
        else:
            if not isinstance(value, dict):
                raise ValueError('Game.config must be a dict.')
            self._config = value

    @property
    def context(self):
        if not hasattr(self, '_context'):
            self._context = json.loads(self.context_json or '{}')
        return self._context

    @context.setter
    def context(self, value):
        if not value:
            self._context = {}
        else:
            if not isinstance(value, dict):
                raise ValueError('Game.context must be a dict.')
            self._context = value

    @property
    def logs(self):
        if not hasattr(self, '_logs'):
            self._logs = json.loads(self.logs_json or '[]')
        return self._logs

    @logs.setter
    def logs(self, value):
        if not value:
            self._logs = []
        else:
            if not isinstance(value, list):
                raise ValueError('Game.logs must be a list.')
            self._logs = value

    @property
    def is_ongoing(self):
        return self.round > 0 and not self.is_over

    def _load_player_list(self, refresh):
        if not hasattr(self, '_player_list') or refresh:
            self._player_list = list(self.player_set.all())
        return self._player_list

    @property
    def player_list(self):
        return self._load_player_list(refresh=False)

    @models.permalink
    def get_absolute_url(self):
        return 'mafia-game-detail', (), {'pk': self.pk}

    def save(self, *args, **kwargs):
        self.delay_seconds = max(self.delay_seconds, self.MIN_DELAY_SECONDS)
        if hasattr(self, '_config'):
            self.config_json = json.dumps(self._config, ensure_ascii=False)
        if hasattr(self, '_context'):
            self.context_json = json.dumps(self._context, ensure_ascii=False)
        if hasattr(self, '_logs'):
            self.logs_json = json.dumps(self._logs, ensure_ascii=False)
        super(Game, self).save(*args, **kwargs)

    def get_elapsed_seconds_since_last_update(self):
        dt = timezone.now() - self.update_date
        return int(dt.total_seconds())

    def add_players(self, user):
        if self.is_two_handed:
            hand_side_list = [Player.HAND_SIDE_LEFT, Player.HAND_SIDE_RIGHT]
        else:
            hand_side_list = [Player.HAND_SIDE_NA]
        player_list = []
        for hand_side in hand_side_list:
            player, __ = Player.objects.get_or_create(game=self, user=user, hand_side=hand_side)
            player_list.append(player)
        self._load_player_list(refresh=True)
        self.ensure_host()
        return player_list

    def remove_players(self, user):
        for player in self.player_list:
            if player.user == user:
                player.delete()
        self._load_player_list(refresh=True)
        self.ensure_host()

    def ensure_host(self):
        for out_host in [p for p in self.player_list if p.is_host and p.is_out]:
            out_host.is_host = False
            out_host.save()
        host_candidates = [p for p in self.player_list if p.user is not None and not p.is_out]
        if next((p for p in host_candidates if p.is_host), None) is not None:
            return True
        elif host_candidates:
            new_host = host_candidates[0]
            new_host.is_host = True
            new_host.save()
            return True
        else:
            return False

    def ensure_unused_players(self, num_unused_players):
        current_unused_players = [p for p in self.player_list if p.user is None]
        delta = num_unused_players - len(current_unused_players)
        if delta != 0:
            if delta > 0:
                for i in range(0, delta):
                    player = Player(game=self, user=None)
                    player.save()
            elif delta < 0:
                for i in range(0, -delta):
                    current_unused_players[i].delete()
            self._load_player_list(refresh=True)

    def reset(self):
        # Remove unused players; reset ordinary players.
        for player in self.player_list:
            if player.is_unused:
                player.delete()
            else:
                player.reset()
        self._load_player_list(refresh=True)
        # Reset game.
        self.context = None
        self.logs = None
        self.round = 0
        self.is_over = False
        self.save()

    def log_action_result(self, result):
        for message in result.messages:
            entry = {
                'round': self.round,
                'action_name': result.action_name,
                'text': message.text,
                'visibility': message.visibility
            }
            self.logs.append(entry)


class Player(models.Model):

    HAND_SIDE_LEFT = 'left'
    HAND_SIDE_RIGHT = 'right'

    HAND_SIDE_CHOICES = (
        (HAND_SIDE_LEFT, HAND_SIDE_LEFT),
        (HAND_SIDE_RIGHT, HAND_SIDE_RIGHT),
    )

    game = models.ForeignKey(Game)
    user = models.ForeignKey(User, blank=True, null=True)
    hand_side = models.CharField(max_length=10, choices=HAND_SIDE_CHOICES, blank=True)
    is_host = models.BooleanField(default=False)
    role = models.CharField(max_length=20, blank=True)
    tags_json = models.TextField(blank=True)
    out_tag = models.CharField(max_length=20, blank=True)
    join_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = TABLE_PREFIX + 'player'
        unique_together = ('game', 'user', 'hand_side')

    @property
    def username(self):
        return self.user.username if self.user else 'Unused'

    @property
    def gravatar_url(self):
        if self.user:
            email_md5 = hashlib.md5(self.user.email.lower()).hexdigest().lower()
            params = urllib.urlencode({'s': 48, 'd': 'retro'})
            return 'http://www.gravatar.com/avatar/%s?%s' % (email_md5, params)
        else:
            return 'http://placehold.it/48x48'

    @property
    def twin(self):
        manager = self.__class__.objects
        queryset = manager.filter(game=self.game, user=self.user).exclude(hand_side=self.hand_side)
        if queryset.exists():
            return queryset.get()
        else:
            return None

    @property
    def is_unused(self):
        return self.user is None

    @property
    def is_out(self):
        return self.is_unused or self.out_tag != ''

    def __unicode__(self):
        string = unicode(self.user) if self.user else 'Unused'
        if self.hand_side:
            string += ' [%s]' % self.hand_side
        return string

    def get_tags(self):
        if not self.tags_json:
            return set()
        else:
            tag_list = json.loads(self.tags_json)
            assert isinstance(tag_list, list)
            return set(tag_list)

    def has_tag(self, tag):
        return tag in self.get_tags()

    def add_tag(self, tag, save=True):
        tags = self.get_tags()
        tags.add(tag)
        self.tags_json = json.dumps(list(tags), ensure_ascii=False)
        if save:
            self.save()

    def remove_tag(self, tag, save=True):
        tags = self.get_tags()
        tags.remove(tag)
        self.tags_json = json.dumps(list(tags), ensure_ascii=False)
        if save:
            self.save()

    def mark_out(self, out_tag):
        self.out_tag = out_tag
        self.add_tag(out_tag, save=True)

    def reset(self):
        self.is_host = False
        self.role = ''
        self.tags_json = ''
        self.out_tag = ''
        self.save()


class Players(list):

    def __init__(self, game, user):
        if user is not None and user.is_anonymous():
            player_list = []
        else:
            player_list = Player.objects.filter(game=game, user=user)
        super(Players, self).__init__(player_list)

    def is_host(self):
        for player in self:
            if player.is_host:
                return True
        return False
