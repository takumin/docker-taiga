#!/bin/sh

if [ "$1" = 'default' ]; then
  if [ ! -f "/taiga-backend/settings/local.py" ]; then
    echo "Require /taiga-backend/settings/local.py"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_DEBUG}" ]; then
    echo "TAIGA_BACKEND_DEBUG: \"${TAIGA_BACKEND_DEBUG}\""
    sed -i -e "s#TAIGA_BACKEND_DEBUG#${TAIGA_BACKEND_DEBUG}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_DEBUG"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_ADMIN_NAME}" ]; then
    echo "TAIGA_BACKEND_ADMIN_NAME: \"${TAIGA_BACKEND_ADMIN_NAME}\""
    sed -i -e "s#TAIGA_BACKEND_ADMIN_NAME#${TAIGA_BACKEND_ADMIN_NAME}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_ADMIN_NAME"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_ADMIN_EMAIL}" ]; then
    echo "TAIGA_BACKEND_ADMIN_EMAIL: \"${TAIGA_BACKEND_ADMIN_EMAIL}\""
    sed -i -e "s#TAIGA_BACKEND_ADMIN_EMAIL#${TAIGA_BACKEND_ADMIN_EMAIL}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_ADMIN_EMAIL"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_HOST}" ]; then
    echo "TAIGA_BACKEND_POSTGRESQL_HOST: \"${TAIGA_BACKEND_POSTGRESQL_HOST}\""
    sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_HOST#${TAIGA_BACKEND_POSTGRESQL_HOST}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_HOST"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_PORT}" ]; then
    echo "TAIGA_BACKEND_POSTGRESQL_PORT: \"${TAIGA_BACKEND_POSTGRESQL_PORT}\""
    sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_PORT#${TAIGA_BACKEND_POSTGRESQL_PORT}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PORT"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_NAME}" ]; then
    echo "TAIGA_BACKEND_POSTGRESQL_NAME: \"${TAIGA_BACKEND_POSTGRESQL_NAME}\""
    sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_NAME#${TAIGA_BACKEND_POSTGRESQL_NAME}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_NAME"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_USER}" ]; then
    echo "TAIGA_BACKEND_POSTGRESQL_USER: \"${TAIGA_BACKEND_POSTGRESQL_USER}\""
    sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_USER#${TAIGA_BACKEND_POSTGRESQL_USER}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_USER"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_POSTGRESQL_PASS}" ]; then
    echo "TAIGA_BACKEND_POSTGRESQL_PASS: \"${TAIGA_BACKEND_POSTGRESQL_PASS}\""
    sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_PASS#${TAIGA_BACKEND_POSTGRESQL_PASS}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PASS"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_API_SCHEME}" ]; then
    echo "TAIGA_BACKEND_API_SCHEME: \"${TAIGA_BACKEND_API_SCHEME}\""
    sed -i -e "s#TAIGA_BACKEND_API_SCHEME#${TAIGA_BACKEND_API_SCHEME}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_API_SCHEME"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_API_DOMAIN}" ]; then
    echo "TAIGA_BACKEND_API_DOMAIN: \"${TAIGA_BACKEND_API_DOMAIN}\""
    sed -i -e "s#TAIGA_BACKEND_API_DOMAIN#${TAIGA_BACKEND_API_DOMAIN}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_API_DOMAIN"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_API_PORT}" ]; then
    echo "TAIGA_BACKEND_API_PORT: \"${TAIGA_BACKEND_API_PORT}\""
    sed -i -e "s#TAIGA_BACKEND_API_PORT#${TAIGA_BACKEND_API_PORT}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_API_PORT"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_FRONT_SCHEME}" ]; then
    echo "TAIGA_BACKEND_FRONT_SCHEME: \"${TAIGA_BACKEND_FRONT_SCHEME}\""
    sed -i -e "s#TAIGA_BACKEND_FRONT_SCHEME#${TAIGA_BACKEND_FRONT_SCHEME}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_FRONT_SCHEME"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_FRONT_DOMAIN}" ]; then
    echo "TAIGA_BACKEND_FRONT_DOMAIN: \"${TAIGA_BACKEND_FRONT_DOMAIN}\""
    sed -i -e "s#TAIGA_BACKEND_FRONT_DOMAIN#${TAIGA_BACKEND_FRONT_DOMAIN}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_FRONT_DOMAIN"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_FRONT_PORT}" ]; then
    echo "TAIGA_BACKEND_FRONT_PORT: \"${TAIGA_BACKEND_FRONT_PORT}\""
    sed -i -e "s#TAIGA_BACKEND_FRONT_PORT#${TAIGA_BACKEND_FRONT_PORT}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_FRONT_PORT"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_MEDIA_URL}" ]; then
    echo "TAIGA_BACKEND_MEDIA_URL: \"${TAIGA_BACKEND_MEDIA_URL}\""
    sed -i -e "s#TAIGA_BACKEND_MEDIA_URL#${TAIGA_BACKEND_MEDIA_URL}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_MEDIA_URL"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_STATIC_URL}" ]; then
    echo "TAIGA_BACKEND_STATIC_URL: \"${TAIGA_BACKEND_STATIC_URL}\""
    sed -i -e "s#TAIGA_BACKEND_STATIC_URL#${TAIGA_BACKEND_STATIC_URL}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_STATIC_URL"
    exit 1
  fi

  if [ -n "${TAIGA_BACKEND_SECRET_KEY}" ]; then
    echo "TAIGA_BACKEND_SECRET_KEY: \"${TAIGA_BACKEND_SECRET_KEY}\""
    sed -i -e "s#TAIGA_BACKEND_SECRET_KEY#${TAIGA_BACKEND_SECRET_KEY}#" /taiga-backend/settings/local.py
  else
    echo "Set require environment variable: TAIGA_BACKEND_SECRET_KEY"
    exit 1
  fi

  wait-for-it.sh ${TAIGA_BACKEND_POSTGRESQL_HOST}:${TAIGA_BACKEND_POSTGRESQL_PORT} -- echo "postgresql is up"

  python3 /taiga-backend/manage.py migrate --noinput
  python3 /taiga-backend/manage.py loaddata initial_user
  python3 /taiga-backend/manage.py loaddata initial_project_templates
  python3 /taiga-backend/manage.py compilemessages
  python3 /taiga-backend/manage.py collectstatic --noinput

  exec runsv taiga-backend
fi

exec "$@"