#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import hashlib
import json
import logging
import urllib

from django.conf import settings
from django.db import models
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth.models import User


logger = logging.getLogger(__name__)


TABLE_PREFIX = getattr(settings, 'V5_TABLE_PREFIX', 'mafia_')


class GameManager(models.Manager):

    def available_game_list(self):
        from_create_date = datetime.datetime.now() - datetime.timedelta(hours=2)
        return self.get_query_set().filter(
            create_date__gte=from_create_date,
            round=0,
            is_over=False
        )


class Game(models.Model):

    VARIANT_CLASSIC = 'classic'
    VARIANT_WEREWOLVES = 'werewolves'

    VARIANT_CHOICES = (
        (VARIANT_CLASSIC, VARIANT_CLASSIC),
        (VARIANT_WEREWOLVES, VARIANT_WEREWOLVES),
    )

    name = models.CharField(_('Game Name'), max_length=100)
    is_two_handed = models.BooleanField(_('Two-Handed'), default=True)
    variant = models.CharField(_('Variant'), max_length=20, choices=VARIANT_CHOICES, default=VARIANT_CLASSIC)
    config_json = models.TextField(blank=True)
    context_json = models.TextField(blank=True)
    round = models.PositiveIntegerField(default=0)
    is_over = models.BooleanField(default=False)
    create_date = models.DateTimeField(auto_now_add=True)
    update_date = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = TABLE_PREFIX + 'game'
        ordering = ['-create_date']

    objects = GameManager()

    def __unicode__(self):
        return self.name

    @property
    def config(self):
        if not hasattr(self, '_config'):
            self._config = json.loads(self.config_json or '{}')
        return self._config

    @config.setter
    def config(self, value):
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
        if not isinstance(value, dict):
            raise ValueError('Game.context must be a dict.')
        self._context = value

    @property
    def is_ongoing(self):
        return self.round > 0 and not self.is_over

    @models.permalink
    def get_absolute_url(self):
        return 'mafia-game-detail', (), {'pk': self.pk}

    def save(self, *args, **kwargs):
        if hasattr(self, '_config'):
            self.config_json = json.dumps(self._config, ensure_ascii=False)
        if hasattr(self, '_context'):
            self.context_json = json.dumps(self._context, ensure_ascii=False)
        super(Game, self).save(*args, **kwargs)

    def ensure_unused_players(self, num_unused_players):
        current_unused_players = self.player_set.filter(user=None)
        delta = num_unused_players - current_unused_players.count()
        if delta > 0:
            for i in range(0, delta):
                player = Player(game=self, user=None)
                player.save()
        elif delta < 0:
            for i in range(0, -delta):
                current_unused_players[i].delete()

    def log_action_result(self, result):
        for message in result.messages:
            GameLog.objects.create(
                game=self,
                round=self.round,
                action_name=result.action_name,
                text=message.text,
                visibility=message.visibility
            )


class PlayerManager(models.Manager):

    def create_players(self, game, user, is_host):
        if game.is_two_handed:
            hand_side_list = [self.model.HAND_SIDE_LEFT, self.model.HAND_SIDE_RIGHT]
        else:
            hand_side_list = [self.model.HAND_SIDE_NA]
        player_list = []
        for hand_side in hand_side_list:
            player, __ = self.get_or_create(game=game, user=user, hand_side=hand_side)
            player.is_host = is_host
            player.save()
            player_list.append(player)
        return player_list


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

    objects = PlayerManager()

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
        self.role = ''
        self.tags_json = ''
        self.out_tag = ''


class GameLog(models.Model):

    class Meta:
        db_table = TABLE_PREFIX + 'gamelog'
        ordering = ['log_date']

    game = models.ForeignKey(Game, related_name='log_set')
    round = models.PositiveIntegerField()
    action_name = models.CharField(max_length=20)
    text = models.CharField(max_length=240)
    visibility = models.CharField(max_length=20, blank=True)
    log_date = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return '[%s] #%02d / %s - %s [%s]' % (
            self.game,
            self.round,
            self.action_name,
            self.text,
            self.visibility,
        )
