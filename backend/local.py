# -*- coding: utf-8 -*-

from .common import *
import environ

env = environ.Env(
    TZ=(str, 'UTC'),
    BACKEND_DEBUG=(bool, False),
    BACKEND_SECRET=(str),
    BACKEND_SCHEME=(str, 'http'),
    BACKEND_HOSTNAME=(str, 'localhost'),
    FRONTEND_SCHEME=(str, 'http'),
    FRONTEND_HOSTNAME=(str, 'localhost'),
    FRONTEND_MEDIA_URL=(str, 'http://localhost:8080/media/'),
    FRONTEND_STATIC_URL=(str, 'http://localhost:8080/static/'),
    POSTGRESQL_USER=(str, 'taiga'),
    POSTGRESQL_PASS=(str, 'taiga'),
    POSTGRESQL_HOST=(str, 'postgres'),
    POSTGRESQL_PORT=(int, 5432),
    POSTGRESQL_NAME=(str, 'taiga'),
    RABBITMQ_USER=(str, 'taiga'),
    RABBITMQ_PASS=(str, 'taiga'),
    RABBITMQ_HOST=(str, 'rabbitmq'),
    RABBITMQ_PORT=(int, 5672),
    RABBITMQ_NAME=(str, 'taiga'),
    BACKEND_ADMIN_NAME=(str, 'Admin'),
    BACKEND_ADMIN_EMAIL=(str, 'admin@example.com'),
    BACKEND_CELERY_ENABLED=(bool, False),
)

USE_TZ = True
TIME_ZONE = env('TZ')

DEBUG = env('BACKEND_DEBUG')

SECRET_KEY = env('BACKEND_SECRET')

CELERY_ENABLED = env('BACKEND_CELERY_ENABLED')

ADMINS = (
    (env('BACKEND_ADMIN_NAME'), env('BACKEND_ADMIN_EMAIL')),
)

SITES = {
    'api': {
        'name': 'api',
        'scheme': env('BACKEND_SCHEME'),
        'domain': env('BACKEND_HOSTNAME'),
    },
    'front': {
        'name': 'front',
        'scheme': env('FRONTEND_SCHEME'),
        'domain': env('FRONTEND_HOSTNAME'),
    },
}

MEDIA_URL = env('FRONTEND_MEDIA_URL')
STATIC_URL = env('FRONTEND_STATIC_URL')

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'USER': env('POSTGRESQL_USER'),
        'PASSWORD': env('POSTGRESQL_PASS'),
        'HOST': env('POSTGRESQL_HOST'),
        'PORT': env('POSTGRESQL_PORT'),
        'NAME': env('POSTGRESQL_NAME'),
    }
}

EVENTS_PUSH_BACKEND = 'taiga.events.backends.rabbitmq.EventsPushBackend'
EVENTS_PUSH_BACKEND_OPTIONS = {
    'url': 'ampq//{USER}:{PASS}@{HOST}:{PORT}/{NAME}'.format(
        USER=env('RABBITMQ_USER'),
        PASS=env('RABBITMQ_PASS'),
        HOST=env('RABBITMQ_HOST'),
        PORT=env('RABBITMQ_PORT'),
        NAME=env('RABBITMQ_NAME'),
    ),
}
