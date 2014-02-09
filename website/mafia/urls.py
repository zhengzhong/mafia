#!/usr/bin/env python
# -*- coding: utf-8 -*-

from django.conf.urls import patterns, url

from mafia.views import MafiaHomeView, GameHostView, GameDetailView, GamePlayView


urlpatterns = patterns(
    '',
    url(r'^$', MafiaHomeView.as_view(), name='mafia-home'),
    url(r'^host/$', GameHostView.as_view(), name='mafia-game-host'),
    url(r'^detail/(?P<pk>\d+)/$', GameDetailView.as_view(), name='mafia-game-detail'),
    url(r'^play/(?P<pk>\d+)/$', GamePlayView.as_view(), name='mafia-game-play'),
)
