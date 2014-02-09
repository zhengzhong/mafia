#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging


logger = logging.getLogger(__name__)


class LogErrorMiddleware(object):

    def process_exception(self, request, exception):
        logger.exception('Error occurred serving %s' % request.path)
        return None
