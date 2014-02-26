#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.models import Game
from mafia.classic.constants import Role, Tag
from mafia.tests.base import BaseMafiaEngineTestCase, EngineTestCaseMixin


class ClassicEngineTestCase(BaseMafiaEngineTestCase, EngineTestCaseMixin):

    variant = Game.VARIANT_CLASSIC

    def get_lynched_tag(self):
        return Tag.LYNCHED
