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
