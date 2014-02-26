#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError


class Role(object):

    CIVILIAN = 'Civilian'
    THIEF = 'Thief'
    CUPID = 'Cupid'
    WEREWOLF = 'Werewolf'
    PSYCHIC = 'Psychic'
    WIZARD = 'Wizard'
    HUNTER = 'Hunter'
    BODYGUARD = 'Bodyguard'
    IDIOT = 'Idiot'
    SENIOR = 'Senior'
    SCAPEGOAT = 'Scapegoat'
    FLUTE_PLAYER = 'FlutePlayer'

    ALIGNMENTS = {
        '': 0,
        CIVILIAN: +1,
        THIEF: +1,
        CUPID: +1,
        WEREWOLF: -3,
        PSYCHIC: +3,
        WIZARD: +1,
        HUNTER: +1,
        BODYGUARD: +1,
        IDIOT: +1,
        SENIOR: +1,
        SCAPEGOAT: +1,
        FLUTE_PLAYER: +1,
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
    GUARDED = 'guarded'
    UNGUARDABLE = 'unguardable'
    BITTEN = 'bitten'
    MINDREAD = 'mindread'
    CURED = 'cured'
    POISONED = 'poisoned'
    SHOT_BY_HUNTER = 'shot_by_hunter'
    IDIOT_EXPOSED = 'idiot_exposed'
    INJURED = 'injured'
    INCAPACITATED = 'incapacitated'
    LYNCHED = 'lynched'
    BORE_THE_BLAME = 'bore_the_blame'
    DEBARRED_FROM_VOTING = 'debarred_from_voting'
    TEMPTED = 'tempted'
