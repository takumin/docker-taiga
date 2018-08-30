# -*- coding: utf-8 -*-

import os

# Require Django
SECRET_KEY = os.environ['DJANGO_SECRET_KEY']

# Require Django
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'USER': os.environ['POSTGRESQL_USER'],
        'PASSWORD': os.environ['POSTGRESQL_PASS'],
        'HOST': os.environ['POSTGRESQL_HOST'],
        'PORT': os.environ['POSTGRESQL_PORT'],
        'NAME': os.environ['POSTGRESQL_NAME'],
    }
}
