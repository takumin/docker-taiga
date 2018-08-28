#!/bin/sh

if [ "$1" = 'default' ]; then
  if [ ! -f "settings/local.py" ]; then
    echo "Require settings/local.py"
    exit 1
  fi

  ##############################################################################
  # PostgreSQL
  ##############################################################################

  echo "TAIGA_BACKEND_POSTGRESQL_HOST: \"${TAIGA_BACKEND_POSTGRESQL_HOST}\""
  if [ -n "${TAIGA_BACKEND_POSTGRESQL_HOST}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_HOST'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_HOST}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_HOST"
    exit 1
  fi

  echo "TAIGA_BACKEND_POSTGRESQL_PORT: \"${TAIGA_BACKEND_POSTGRESQL_PORT}\""
  if [ -n "${TAIGA_BACKEND_POSTGRESQL_PORT}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_PORT'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_PORT}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PORT"
    exit 1
  fi

  echo "TAIGA_BACKEND_POSTGRESQL_NAME: \"${TAIGA_BACKEND_POSTGRESQL_NAME}\""
  if [ -n "${TAIGA_BACKEND_POSTGRESQL_NAME}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_NAME'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_NAME}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_NAME"
    exit 1
  fi

  echo "TAIGA_BACKEND_POSTGRESQL_USER: \"${TAIGA_BACKEND_POSTGRESQL_USER}\""
  if [ -n "${TAIGA_BACKEND_POSTGRESQL_USER}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_USER'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_USER}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_USER"
    exit 1
  fi

  echo "TAIGA_BACKEND_POSTGRESQL_PASS: \"${TAIGA_BACKEND_POSTGRESQL_PASS}\""
  if [ -n "${TAIGA_BACKEND_POSTGRESQL_PASS}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_POSTGRESQL_PASS'$^\1 = '${TAIGA_BACKEND_POSTGRESQL_PASS}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PASS"
    exit 1
  fi

  ##############################################################################
  # RabbitMQ
  ##############################################################################

  echo "TAIGA_BACKEND_RABBITMQ_USER: \"${TAIGA_BACKEND_RABBITMQ_USER}\""
  echo "TAIGA_BACKEND_RABBITMQ_PASS: \"${TAIGA_BACKEND_RABBITMQ_PASS}\""
  echo "TAIGA_BACKEND_RABBITMQ_HOST: \"${TAIGA_BACKEND_RABBITMQ_HOST}\""
  echo "TAIGA_BACKEND_RABBITMQ_PORT: \"${TAIGA_BACKEND_RABBITMQ_PORT}\""
  echo "TAIGA_BACKEND_RABBITMQ_PATH: \"${TAIGA_BACKEND_RABBITMQ_PATH}\""
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

  echo "TAIGA_BACKEND_SITES_API_SCHEME: \"${TAIGA_BACKEND_SITES_API_SCHEME}\""
  if [ -n "${TAIGA_BACKEND_SITES_API_SCHEME}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_SITES_API_SCHEME'$^\1 = '${TAIGA_BACKEND_SITES_API_SCHEME}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_SITES_API_SCHEME"
    exit 1
  fi

  echo "TAIGA_BACKEND_SITES_API_DOMAIN: \"${TAIGA_BACKEND_SITES_API_DOMAIN}\""
  echo "TAIGA_BACKEND_SITES_API_PORT: \"${TAIGA_BACKEND_SITES_API_PORT}\""
  if [ -n "${TAIGA_BACKEND_SITES_API_DOMAIN}" -a -n "${TAIGA_BACKEND_SITES_API_PORT}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_SITES_API_DOMAIN:TAIGA_BACKEND_SITES_API_PORT'$^\1 = '${TAIGA_BACKEND_SITES_API_DOMAIN}:${TAIGA_BACKEND_SITES_API_PORT}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_SITES_API_DOMAIN,"
    echo "                                  TAIGA_BACKEND_SITES_API_PORT"
    exit 1
  fi

  echo "TAIGA_BACKEND_SITES_FRONT_SCHEME: \"${TAIGA_BACKEND_SITES_FRONT_SCHEME}\""
  if [ -n "${TAIGA_BACKEND_SITES_FRONT_SCHEME}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_SITES_FRONT_SCHEME'$^\1 = '${TAIGA_BACKEND_SITES_FRONT_SCHEME}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_SITES_FRONT_SCHEME"
    exit 1
  fi

  echo "TAIGA_BACKEND_SITES_FRONT_DOMAIN: \"${TAIGA_BACKEND_SITES_FRONT_DOMAIN}\""
  echo "TAIGA_BACKEND_SITES_FRONT_PORT: \"${TAIGA_BACKEND_SITES_FRONT_PORT}\""
  if [ -n "${TAIGA_BACKEND_SITES_FRONT_DOMAIN}" -a -n "${TAIGA_BACKEND_SITES_FRONT_PORT}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_SITES_FRONT_DOMAIN:TAIGA_BACKEND_SITES_FRONT_PORT'$^\1 = '${TAIGA_BACKEND_SITES_FRONT_DOMAIN}:${TAIGA_BACKEND_SITES_FRONT_PORT}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_SITES_FRONT_DOMAIN,"
    echo "                                  TAIGA_BACKEND_SITES_FRONT_PORT"
    exit 1
  fi

  ##############################################################################
  # URL
  ##############################################################################

  echo "TAIGA_BACKEND_MEDIA_URL: \"${TAIGA_BACKEND_MEDIA_URL}\""
  if [ -n "${TAIGA_BACKEND_MEDIA_URL}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_MEDIA_URL'$^\1 = '${TAIGA_BACKEND_MEDIA_URL}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_MEDIA_URL"
    exit 1
  fi

  echo "TAIGA_BACKEND_STATIC_URL: \"${TAIGA_BACKEND_STATIC_URL}\""
  if [ -n "${TAIGA_BACKEND_STATIC_URL}" ]; then
    sed -i -e "s^# \(.*\) = 'TAIGA_BACKEND_STATIC_URL'$^\1 = '${TAIGA_BACKEND_STATIC_URL}'^" settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_STATIC_URL"
    exit 1
  fi

  ##############################################################################
  # Secret
  ##############################################################################

  echo "TAIGA_BACKEND_SECRET_KEY: \"${TAIGA_BACKEND_SECRET_KEY}\""
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
    echo "TAIGA_BACKEND_DEBUG: \"${TAIGA_BACKEND_DEBUG}\""
    echo ""                                   >> settings/local.py
    echo "DEBUG = \"${TAIGA_BACKEND_DEBUG}\"" >> settings/local.py
  fi

  ##############################################################################
  # Celery
  ##############################################################################

  if [ "x${TAIGA_BACKEND_CELERY_ENABLED}" = 'xTrue' -o "x${TAIGA_BACKEND_CELERY_ENABLED}" = 'xFalse' ]; then
    echo "TAIGA_BACKEND_CELERY_ENABLED: \"${TAIGA_BACKEND_CELERY_ENABLED}\""
    echo ""                                                     >> settings/local.py
    echo "CELERY_ENABLED = \"${TAIGA_BACKEND_CELERY_ENABLED}\"" >> settings/local.py
  fi

  ##############################################################################
  # Admin
  ##############################################################################
  if [ -n "${TAIGA_BACKEND_ADMIN_NAME}" -a -n "${TAIGA_BACKEND_ADMIN_EMAIL}" ]; then
    echo "TAIGA_BACKEND_ADMIN_NAME: \"${TAIGA_BACKEND_ADMIN_NAME}\""
    echo "TAIGA_BACKEND_ADMIN_EMAIL: \"${TAIGA_BACKEND_ADMIN_EMAIL}\""
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

  python3 manage.py migrate --noinput
  python3 manage.py loaddata initial_user
  python3 manage.py loaddata initial_project_templates

  exec celery -A taiga worker -c 4
fi

exec "$@"
