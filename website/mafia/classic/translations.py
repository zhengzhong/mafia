#!/usr/bin/env python
# -*- coding: utf-8 -*-

from django.utils.translation import ugettext_lazy as _

from mafia.classic.constants import Role


TRANSLATIONS = {

    # Role names.
    Role.CIVILIAN: _('Civilian'),
    Role.KILLER: _('Killer'),
    Role.DETECTIVE: _('Detective'),
    Role.GUARDIAN_ANGEL: _('Guardian Angel'),
    Role.DOCTOR: _('Doctor'),
    Role.TRAITOR: _('Traitor'),

    # Action names.
    'GuardianAngelAction': _('Guardian Angel Action'),
    'KillerAction': _('Killer Action'),
    'DetectiveAction': _('Detective Action'),
    'DoctorAction': _('Doctor Action'),
    'TraitorAction': _('Traitor Action'),
    'SettleTags': _('Settle Tags'),
    'VoteAndLynch': _('Vote and Lynch'),
}
