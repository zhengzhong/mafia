#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError


class Role(object):

    CIVILIAN = 'Civilian'
    THIEF = 'Thief'
    CUPIDO = 'Cupido'
    WEREWOLF = 'Werewolf'
    SEER = 'Seer'
    WITCH = 'Witch'
    HUNTER = 'Hunter'
    BODYGUARD = 'Bodyguard'
    IDIOT = 'Idiot'
    ELDER = 'Elder'
    SCAPEGOAT = 'Scapegoat'
    FLUTE_PLAYER = 'FlutePlayer'

    ALIGNMENTS = {
        '': 0,
        CIVILIAN: +1,
        THIEF: +1,
        CUPIDO: +1,
        WEREWOLF: -3,
        SEER: +3,
        WITCH: +1,
        HUNTER: +1,
        BODYGUARD: +1,
        IDIOT: +1,
        ELDER: +1,
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

    APPOINTED_AS_MAYOR = 'appointed_as_mayor'
    CHOSEN_AS_LOVERS = 'chosen_as_lovers'
    DIED_FOR_LOVE = 'died_for_love'
    PROTECTED_BY_BODYGUARD = 'protected_by_bodyguard'
    UNPROTECTABLE = 'unprotectable'
    ATTACKED_BY_WEREWOLF = 'attacked_by_werewolf'
    FORESEEN_BY_SEER = 'foreseen_by_seer'
    CURED_BY_WITCH = 'cured_by_witch'
    POISONED_BY_WITCH = 'poisoned_by_witch'
    SHOT_BY_HUNTER = 'shot_by_hunter'
    EXPOSED_AS_IDIOT = 'exposed_as_idiot'
    INJURED_BY_WEREWOLF = 'injured_by_werewolf'
    INCAPACITATED = 'incapacitated'
    LYNCHED = 'lynched'
    BORE_THE_BLAME = 'bore_the_blame'
    DEBARRED_FROM_VOTING = 'debarred_from_voting'
    TEMPTED_BY_FLUTE_PLAYER = 'tempted_by_flute_player'
