#!/usr/bin/env python
# -*- coding: utf-8 -*-

from django.utils.translation import ugettext_lazy as _

from mafia.werewolves.constants import Role


TRANSLATIONS = {

    # Role names.
    Role.CIVILIAN: _('Civilian'),
    Role.THIEF: _('Thief'),
    Role.CUPIDO: _('Cupido'),
    Role.WEREWOLF: _('Werewolf'),
    Role.SEER: _('Seer'),
    Role.WITCH: _('Witch'),
    Role.HUNTER: _('Hunter'),
    Role.BODYGUARD: _('Bodyguard'),
    Role.IDIOT: _('Idiot'),
    Role.ELDER: _('Elder'),
    Role.SCAPEGOAT: _('Scapegoat'),
    Role.FLUTE_PLAYER: _('Flute Player'),

    # Action names.
    'ThiefAction': _('Thief Action'),
    'CupidoAction': _('Cupido Action'),
    'WerewolfAction': _('Werewolf Action'),
    'SeerAction': _('Seer Action'),
    'WitchAction': _('Witch Action'),
    'BodyguardAction': _('Bodyguard Action'),
    'FlutePlayerAction': _('Flute Player Action'),
    'SettleTags': _('Settle Tags'),
    'ElectMayor': _('Elect Mayor'),
    'VoteAndLynch': _('Vote and Lynch'),
    'AppointNewMayor': _('Appoint New Mayor'),
    'HunterAction': _('Hunter Action'),
    'ScapegoatAction': _('Scapegoat Action'),
}
