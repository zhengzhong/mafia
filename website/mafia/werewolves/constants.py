#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError


class Role(object):

    CIVILIAN = 'Civilian'
    THIEF = 'Thief'
    WEREWOLF = 'Werewolf'
    PROPHET = 'Prophet'
    HUNTER = 'Hunter'
    WIZARD = 'Wizard'
    GIRL = 'Girl'
    CUPID = 'Cupid'

    ALIGNMENTS = {
        '': 0,
        THIEF: +1,
        CIVILIAN: +1,
        WEREWOLF: -3,
        PROPHET: +3,
        HUNTER: +1,
        WIZARD: +1,
        GIRL: +1,
        CUPID: +1,
    }

    @classmethod
    def get_alignment(cls, *roles):
        alignment = 0
        for role in roles:
            if role not in cls.ALIGNMENTS:
                raise GameError('Invalid role %s.' % role)
            alignment += cls.ALIGNMENTS[role]
        return alignment


class Tag(object):

    MAYOR = 'mayor'
    LOVER = 'lover'
    BITTEN = 'bitten'
    INVESTIGATED = 'investigated'
    CURED = 'cured'
    POISONED = 'poisoned'
