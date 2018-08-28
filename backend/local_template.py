# -*- coding: utf-8 -*-

from .common import *

DEBUG = TAIGA_BACKEND_DEBUG

ADMINS = (
    ("TAIGA_BACKEND_ADMIN_NAME", "TAIGA_BACKEND_ADMIN_EMAIL"),
)

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': 'TAIGA_BACKEND_POSTGRESQL_HOST',
        'PORT': 'TAIGA_BACKEND_POSTGRESQL_PORT',
        'NAME': 'TAIGA_BACKEND_POSTGRESQL_NAME',
        'USER': 'TAIGA_BACKEND_POSTGRESQL_USER',
        'PASSWORD': 'TAIGA_BACKEND_POSTGRESQL_PASS',
    }
}

SITES = {
    'api': {
        'name': 'api'
        'scheme': 'TAIGA_BACKEND_SITES_API_SCHEME',
        'domain': 'TAIGA_BACKEND_SITES_API_DOMAIN:TAIGA_BACKEND_SITES_API_PORT',
    },
    'front': {
        'name': 'front'
        'scheme': 'TAIGA_BACKEND_SITES_FRONT_SCHEME',
        'domain': 'TAIGA_BACKEND_SITES_FRONT_DOMAIN:TAIGA_BACKEND_SITES_FRONT_PORT',
    },
}

EVENTS_PUSH_BACKEND = "taiga.events.backends.rabbitmq.EventsPushBackend"
EVENTS_PUSH_BACKEND_OPTIONS = {"url": "ampq//TAIGA_BACKEND_RABBITMQ_USER:TAIGA_BACKEND_RABBITMQ_PASS@TAIGA_BACKEND_RABBITMQ_HOST:TAIGA_BACKEND_RABBITMQ_PORT/TAIGA_BACKEND_RABBITMQ_PATH"}

MEDIA_URL = "TAIGA_BACKEND_MEDIA_URL"
STATIC_URL = "TAIGA_BACKEND_STATIC_URL"

SECRET_KEY = "TAIGA_BACKEND_SECRET_KEY"
