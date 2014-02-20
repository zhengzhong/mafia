#!/usr/bin/env python
# -*- coding: utf-8 -*-

from django.conf.urls import patterns, url
from django.views.generic import TemplateView

from mafia.views import (MafiaHomeView, MafiaGameHostView, MafiaGameDetailView,
    MafiaGameHeartbeatView, MafiaGamePlayView)


urlpatterns = patterns(
    '',
    url(r'^$', MafiaHomeView.as_view(), name='mafia-home'),
    url(r'^host/$', MafiaGameHostView.as_view(), name='mafia-game-host'),
    url(r'^detail/(?P<pk>\d+)/$', MafiaGameDetailView.as_view(), name='mafia-game-detail'),
    url(r'^heartbeat/(?P<pk>\d+)/$', MafiaGameHeartbeatView.as_view(), name='mafia-game-heartbeat'),
    url(r'^play/(?P<pk>\d+)/$', MafiaGamePlayView.as_view(), name='mafia-game-play'),

    url(r'^manual/$', TemplateView.as_view(template_name='mafia/manual.html'), name='mafia-manual'),
)
