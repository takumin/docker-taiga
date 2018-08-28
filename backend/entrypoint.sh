#!/bin/sh

if [ "$1" = 'default' ]; then
  ##############################################################################
  # Check
  ##############################################################################

  set -e

  if [ ! -f "settings/local.py" ]; then
    echo "Require settings/local.py"
    exit 1
  fi

  if [ "x${TAIGA_BACKEND_DEBUG}" = 'xTrue' ]; then
    echo "TAIGA_BACKEND_POSTGRESQL_HOST: \"${TAIGA_BACKEND_POSTGRESQL_HOST}\""
    echo "TAIGA_BACKEND_POSTGRESQL_PORT: \"${TAIGA_BACKEND_POSTGRESQL_PORT}\""
    echo "TAIGA_BACKEND_POSTGRESQL_NAME: \"${TAIGA_BACKEND_POSTGRESQL_NAME}\""
    echo "TAIGA_BACKEND_POSTGRESQL_USER: \"${TAIGA_BACKEND_POSTGRESQL_USER}\""
    echo "TAIGA_BACKEND_POSTGRESQL_PASS: \"${TAIGA_BACKEND_POSTGRESQL_PASS}\""
    echo "TAIGA_BACKEND_RABBITMQ_USER: \"${TAIGA_BACKEND_RABBITMQ_USER}\""
    echo "TAIGA_BACKEND_RABBITMQ_PASS: \"${TAIGA_BACKEND_RABBITMQ_PASS}\""
    echo "TAIGA_BACKEND_RABBITMQ_HOST: \"${TAIGA_BACKEND_RABBITMQ_HOST}\""
    echo "TAIGA_BACKEND_RABBITMQ_PORT: \"${TAIGA_BACKEND_RABBITMQ_PORT}\""
    echo "TAIGA_BACKEND_RABBITMQ_PATH: \"${TAIGA_BACKEND_RABBITMQ_PATH}\""
    echo "TAIGA_BACKEND_SCHEME: \"${TAIGA_BACKEND_SCHEME}\""
    echo "TAIGA_BACKEND_DOMAIN: \"${TAIGA_BACKEND_DOMAIN}\""
    echo "TAIGA_BACKEND_PORT: \"${TAIGA_BACKEND_PORT}\""
    echo "TAIGA_BACKEND_MEDIA_URL: \"${TAIGA_BACKEND_MEDIA_URL}\""
    echo "TAIGA_BACKEND_STATIC_URL: \"${TAIGA_BACKEND_STATIC_URL}\""
    echo "TAIGA_BACKEND_SECRET_KEY: \"${TAIGA_BACKEND_SECRET_KEY}\""
    echo "TAIGA_BACKEND_DEBUG: \"${TAIGA_BACKEND_DEBUG}\""
    echo "TAIGA_BACKEND_CELERY_ENABLED: \"${TAIGA_BACKEND_CELERY_ENABLED}\""
    echo "TAIGA_BACKEND_ADMIN_NAME: \"${TAIGA_BACKEND_ADMIN_NAME}\""
    echo "TAIGA_BACKEND_ADMIN_EMAIL: \"${TAIGA_BACKEND_ADMIN_EMAIL}\""
  fi

  ##############################################################################
  # PostgreSQL
  ##############################################################################

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_HOST}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_HOST'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_HOST}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_HOST"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_PORT}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_PORT'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_PORT}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PORT"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_NAME}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_NAME'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_NAME}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_NAME"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_USER}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_USER'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_USER}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_USER"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_PASS}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_PASS'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_PASS}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PASS"
    exit 1
  fi

  ##############################################################################
  # RabbitMQ
  ##############################################################################

  if [ -n "${TAIGA_BACKEND_RABBITMQ_USER}" -a -n "${TAIGA_BACKEND_RABBITMQ_PASS}" -a -n "${TAIGA_BACKEND_RABBITMQ_HOST}" -a -n "${TAIGA_BACKEND_RABBITMQ_PORT}" ]; then
    sed -i -e "s^# \(EVENTS_PUSH_BACKEND = 'taiga.events.backends.rabbitmq.EventsPushBackend'\)$^\1^" settings/local.py
    sed -i -e "s^# \(.*\) {'url': 'ampq//TAIGA_BACKEND_RABBITMQ_USER:TAIGA_BACKEND_RABBITMQ_PASS@TAIGA_BACKEND_RABBITMQ_HOST:TAIGA_BACKEND_RABBITMQ_PORT/TAIGA_BACKEND_RABBITMQ_PATH'}$^\1 {'url': 'ampq//${TAIGA_BACKEND_RABBITMQ_USER}:${TAIGA_BACKEND_RABBITMQ_PASS}@${TAIGA_BACKEND_RABBITMQ_HOST}:${TAIGA_BACKEND_RABBITMQ_PORT}/${TAIGA_BACKEND_RABBITMQ_PATH}'}^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_RABBITMQ_USER,"
    echo "                                  TAIGA_BACKEND_RABBITMQ_PASS,"
    echo "                                  TAIGA_BACKEND_RABBITMQ_HOST,"
    echo "                                  TAIGA_BACKEND_RABBITMQ_PORT"
    exit 1
  fi

  ##############################################################################
  # Sites
  ##############################################################################

  if [ -n "${TAIGA_BACKEND_SCHEME}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_SCHEME'$^\1 = '${TAIGA_BACKEND_SCHEME}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_SCHEME"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_DOMAIN}" -a -n "${TAIGA_BACKEND_PORT}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_DOMAIN:TAIGA_BACKEND_PORT'$^\1 = '${TAIGA_BACKEND_DOMAIN}:${TAIGA_BACKEND_PORT}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_DOMAIN,"
    echo "                                  TAIGA_BACKEND_PORT"
    exit 1
  fi

  ##############################################################################
  # URL
  ##############################################################################

  if [ -n "${TAIGA_BACKEND_MEDIA_URL}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_MEDIA_URL'$^\1 = '${TAIGA_BACKEND_MEDIA_URL}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_MEDIA_URL"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_STATIC_URL}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_STATIC_URL'$^\1 = '${TAIGA_BACKEND_STATIC_URL}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_STATIC_URL"
    exit 1
  fi

  ##############################################################################
  # Secret
  ##############################################################################

  if [ -n "${TAIGA_BACKEND_SECRET_KEY}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_SECRET_KEY'$^\1 = '${TAIGA_BACKEND_SECRET_KEY}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_SECRET_KEY"
    exit 1
  fi

  ##############################################################################
  # Debug
  ##############################################################################

  if [ "x${TAIGA_BACKEND_DEBUG}" = 'xTrue' -o "x${TAIGA_BACKEND_DEBUG}" = 'xFalse' ]; then
    echo ""                                   >> settings/local.py
    echo "DEBUG = \"${TAIGA_BACKEND_DEBUG}\"" >> settings/local.py
  fi

  ##############################################################################
  # Celery
  ##############################################################################

  if [ "x${TAIGA_BACKEND_CELERY_ENABLED}" = 'xTrue' -o "x${TAIGA_BACKEND_CELERY_ENABLED}" = 'xFalse' ]; then
    echo ""                                                     >> settings/local.py
    echo "CELERY_ENABLED = \"${TAIGA_BACKEND_CELERY_ENABLED}\"" >> settings/local.py
  fi

  ##############################################################################
  # Admin
  ##############################################################################
  if [ -n "${TAIGA_BACKEND_ADMIN_NAME}" -a -n "${TAIGA_BACKEND_ADMIN_EMAIL}" ]; then
    echo ""                                                                     >> settings/local.py
    echo "ADMINS = ("                                                           >> settings/local.py
    echo "    ('${TAIGA_BACKEND_ADMIN_NAME}', '${TAIGA_BACKEND_ADMIN_EMAIL}')," >> settings/local.py
    echo ")"                                                                    >> settings/local.py
  fi

  ##############################################################################
  # Wait
  ##############################################################################

  wait-for-it.sh ${TAIGA_BACKEND_POSTGRESQL_HOST}:${TAIGA_BACKEND_POSTGRESQL_PORT} -- echo "PostgreSQL is Up"
  wait-for-it.sh ${TAIGA_BACKEND_RABBITMQ_HOST}:${TAIGA_BACKEND_RABBITMQ_PORT} -- echo "RabbitMQ is Up"

  ##############################################################################
  # Initialize
  ##############################################################################

  echo "Starting Initialize"
  python3 manage.py migrate --noinput
  python3 manage.py loaddata initial_user
  python3 manage.py loaddata initial_project_templates

  ##############################################################################
  # Daemon
  ##############################################################################

  echo "[watcher:taiga]"                                               >  circusd.ini
  echo "working_dir = $(pwd)"                                          >> circusd.ini
  echo "cmd = gunicorn"                                                >> circusd.ini
  echo "args = -w 4 -t 60 -b 0.0.0.0:${TAIGA_BACKEND_PORT} taiga.wsgi" >> circusd.ini
  echo "numprocesses = 1"                                              >> circusd.ini
  echo "autostart = true"                                              >> circusd.ini
  echo "send_hup = true"                                               >> circusd.ini
  echo ""                                                              >> circusd.ini
  echo "[env:taiga]"                                                   >> circusd.ini
  echo "PATH = ${PATH}"                                                >> circusd.ini
  echo "PYTHONPATH = $(pwd)"                                           >> circusd.ini

  ##############################################################################
  # Running
  ##############################################################################

  echo "Starting Server"
  exec circusd circusd.ini
fi

exec "$@"
