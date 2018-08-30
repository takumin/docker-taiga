# -*- coding: utf-8 -*-

################################################################################
# Taiga
################################################################################

# Default project template
DEFAULT_PROJECT_TEMPLATE = "scrum"

# Public register
PUBLIC_REGISTER_ENABLED = False

# Celery module settings
CELERY_ENABLED = False

# Webhook module settings
WEBHOOKS_ENABLED = False

# Feedback module settings
FEEDBACK_ENABLED = False
FEEDBACK_EMAIL = "support@taiga.io"

# Stats module settings
STATS_ENABLED = False
STATS_CACHE_TIMEOUT = 60*60  # In second

# Sitemap module settings
FRONT_SITEMAP_ENABLED = False
FRONT_SITEMAP_CACHE_TIMEOUT = 24*60*60  # In second

# ???
EXTRA_BLOCKING_CODES = []

# ???
MAX_PRIVATE_PROJECTS_PER_USER = None # None == no limit
MAX_PUBLIC_PROJECTS_PER_USER = None # None == no limit
MAX_MEMBERSHIPS_PRIVATE_PROJECTS = None # None == no limit
MAX_MEMBERSHIPS_PUBLIC_PROJECTS = None # None == no limit

# ???
MAX_PENDING_MEMBERSHIPS = 30 # Max number of unconfirmed memberships in a project

# ???
SR = {
    'taigaio_url': 'https://taiga.io',
    'social': {
        'twitter_url': 'https://twitter.com/taigaio',
        'github_url': 'https://github.com/taigaio',
    },
    'support': {
        'url': 'https://tree.taiga.io/support',
        'email': 'support@taiga.io',
        'mailing_list': 'https://groups.google.com/forum/#!forum/taigaio',
    }
}

# ???
IMPORTERS = {
    'github': {
        'active': False,
        'client_id': '',
        'client_secret': '',
    },
    'trello': {
        'active': False,
        'api_key': '',
        'secret_key': '',
    },
    'jira': {
        'active': False,
        'consumer_key': '',
        'cert': '',
        'pub_cert': '',
    },
    'asana': {
        'active': False,
        'callback_url': '',
        'app_id': '',
        'app_secret': '',
    }
}

################################################################################
# Django
################################################################################

import string
import random

SECRET_KEY = ''.join([random.choice(string.ascii_letters + string.digits) for i in range(20)])

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': 'taiga',
    }
}

MIDDLEWARE_CLASSES = [
    "taiga.base.middleware.cors.CoorsMiddleware",
    "taiga.events.middleware.SessionIDMiddleware",

    # Common middlewares
    "django.middleware.common.CommonMiddleware",
    "django.middleware.locale.LocaleMiddleware",

    # Only needed by django admin
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
]

INSTALLED_APPS = [
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.admin",
    "django.contrib.staticfiles",
    "django.contrib.sitemaps",
    "django.contrib.postgres",

    "taiga.base",
    "taiga.base.api",
    "taiga.locale",
    "taiga.events",
    "taiga.front",
    "taiga.users",
    "taiga.userstorage",
    "taiga.external_apps",
    "taiga.projects",
    "taiga.projects.references",
    "taiga.projects.custom_attributes",
    "taiga.projects.history",
    "taiga.projects.notifications",
    "taiga.projects.attachments",
    "taiga.projects.likes",
    "taiga.projects.votes",
    "taiga.projects.milestones",
    "taiga.projects.epics",
    "taiga.projects.userstories",
    "taiga.projects.tasks",
    "taiga.projects.issues",
    "taiga.projects.wiki",
    "taiga.projects.contact",
    "taiga.searches",
    "taiga.timeline",
    "taiga.mdrender",
    "taiga.export_import",
    "taiga.feedback",
    "taiga.stats",
    "taiga.hooks.github",
    "taiga.hooks.gitlab",
    "taiga.hooks.bitbucket",
    "taiga.hooks.gogs",
    "taiga.webhooks",
    "taiga.importers",

    "djmail",
    "django_jinja",
    "django_jinja.contrib._humanize",
    "sr",
    "easy_thumbnails",
    "raven.contrib.django.raven_compat",
]
