# -*- coding: utf-8 -*-

from .common import *
from environ import environ

env = Env(
    BACKEND_DEBUG=(bool, False),
    BACKEND_SECRET=(str),
    BACKEND_SCHEME=(str, 'http'),
    BACKEND_HOSTNAME=(str, 'localhost'),
    FRONTEND_SCHEME=(str, 'http'),
    FRONTEND_HOSTNAME=(str, 'localhost'),
    FRONTEND_MEDIA_URL=(str, 'http://localhost/media/'),
    FRONTEND_STATIC_URL=(str, 'http://localhost/static/'),
    POSTGRESQL_HOST=(str, 'postgres'),
    POSTGRESQL_PORT=(int, 5432),
    POSTGRESQL_NAME=(str, 'taiga'),
    POSTGRESQL_USER=(str, 'taiga'),
    POSTGRESQL_PASS=(str, 'taiga'),
    RABBITMQ_PEER_HOST=(str, 'rabbitmq'),
    RABBITMQ_PEER_PORT=(int, 4369),
    RABBITMQ_PEER_NAME=(str, 'peer'),
    RABBITMQ_PEER_USER=(str, 'taiga'),
    RABBITMQ_PEER_PASS=(str, 'taiga'),
    BACKEND_ADMIN_NAME=(str, 'Admin'),
    BACKEND_ADMIN_EMAIL=(str, 'admin@example.com'),
    BACKEND_CELERY_ENABLED=(bool, False),
)

DEBUG = env('BACKEND_DEBUG')

SECRET_KEY = env('BACKEND_SECRET')

SITES = {
    'api': {
        'name': 'api',
        'scheme': env('BACKEND_SCHEME'),
        'domain': env('BACKEND_HOSTNAME'),
    },
    'front': {
        'name': 'front'
        'scheme': env('FRONTEND_SCHEME'),
        'domain': env('FRONTEND_HOSTNAME'),
    },
}

MEDIA_URL = env('FRONTEND_MEDIA_URL')
STATIC_URL = env('FRONTEND_STATIC_URL')

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': env('POSTGRESQL_HOST'),
        'PORT': env('POSTGRESQL_PORT'),
        'NAME': env('POSTGRESQL_NAME'),
        'USER': env('POSTGRESQL_USER'),
        'PASSWORD': env('POSTGRESQL_PASS'),
    }
}

EVENTS_PUSH_BACKEND = 'taiga.events.backends.rabbitmq.EventsPushBackend'
EVENTS_PUSH_BACKEND_OPTIONS = {
    'url': 'ampq//{USER}:{PASS}@{HOST}:{PORT}/{NAME}'.format(
        USER=env('RABBITMQ_PEER_USER'),
        PASS=env('RABBITMQ_PEER_PASS'),
        HOST=env('RABBITMQ_PEER_HOST'),
        PORT=env('RABBITMQ_PEER_PORT'),
        NAME=env('RABBITMQ_PEER_NAME'),
    ),
}

ADMINS = (
    env('BACKEND_ADMIN_NAME'): env('BACKEND_ADMIN_EMAIL')
)

CELERY_ENABLED = env('BACKEND_CELERY_ENABLED')
