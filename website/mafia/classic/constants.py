#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError


class Role(object):

    CIVILIAN = 'Civilian'
    KILLER = 'Killer'
    DETECTIVE = 'Detective'
    GUARDIAN = 'Guardian'
    DOCTOR = 'Doctor'
    TRAITOR = 'Traitor'

    ALIGNMENTS = {
        '': 0,
        CIVILIAN: +1,
        KILLER: -3,
        DETECTIVE: +3,
        GUARDIAN: +1,
        DOCTOR: +1,
        TRAITOR: -2,
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

    SHOT = 'shot'
    INVESTIGATED = 'investigated'
    GUARDED = 'guarded'
    PREVIOUSLY_GUARDED = 'previously_guarded'
    UNGUARDABLE = 'unguardable'
    CURED = 'cured'
    MISDIAGNOSED = 'misdiagnosed'
    CONTACTED_BY_TRAITOR = 'contacted_by_traitor'
