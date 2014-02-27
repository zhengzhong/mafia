#!/usr/bin/env python
# -*- coding: utf-8 -*-

from django.utils.translation import ugettext_lazy as _

from mafia.classic.constants import Role


TRANSLATIONS = {

    # Role names.
    Role.CIVILIAN: _('Civilian'),
    Role.KILLER: _('Killer'),
    Role.DETECTIVE: _('Detective'),
    Role.GUARDIAN: _('Guardian'),
    Role.DOCTOR: _('Doctor'),
    Role.TRAITOR: _('Traitor'),

    # Action names.
    'GuardianAction': _('Guardian Action'),
    'KillerAction': _('Killer Action'),
    'DetectiveAction': _('Detective Action'),
    'DoctorAction': _('Doctor Action'),
    'TraitorAction': _('Traitor Action'),
    'SettleTags': _('Settle Tags'),
    'VoteAndLynch': _('Vote and Lynch'),
}
