#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging

from django.conf import settings


logger = logging.getLogger(__name__)


class SetLanguageMiddleware(object):

    def process_request(self, request):
        if hasattr(request, 'session') and hasattr(settings, 'LANGUAGE_CODE'):
            current_language = request.session.get('django_language')
            if not current_language:
                logger.info('Setting current language to: %s' % settings.LANGUAGE_CODE)
                request.session['django_language'] = settings.LANGUAGE_CODE
            elif current_language != settings.LANGUAGE_CODE:
                logger.info('Current language is: %s' % current_language)
        return None


class LogErrorMiddleware(object):

    def process_exception(self, request, exception):
        logger.exception('Error occurred serving %s' % request.path)
        return None
