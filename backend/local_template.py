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
        'scheme': 'TAIGA_BACKEND_API_SCHEME',
        'domain': 'TAIGA_BACKEND_API_DOMAIN:TAIGA_BACKEND_API_PORT',
    },
    'front': {
        'name': 'front'
        'scheme': 'TAIGA_BACKEND_FRONT_SCHEME',
        'domain': 'TAIGA_BACKEND_FRONT_DOMAIN:TAIGA_BACKEND_FRONT_PORT',
    },
}

MEDIA_URL = "TAIGA_BACKEND_MEDIA_URL"
STATIC_URL = "TAIGA_BACKEND_STATIC_URL"

SECRET_KEY = "TAIGA_BACKEND_SECRET_KEY"
