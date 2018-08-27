#!/bin/sh

if [ ! -f "/taiga-backend/settings/local.py" ]; then
  echo "Require /taiga-backend/settings/local.py"
  exit 1
fi

echo "TAIGA_BACKEND_DEBUG: \"${TAIGA_BACKEND_DEBUG}\""
if [ -n "${TAIGA_BACKEND_DEBUG}" ]; then
  sed -i -e "s#TAIGA_BACKEND_DEBUG#${TAIGA_BACKEND_DEBUG}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_DEBUG"
  exit 1
fi

echo "TAIGA_BACKEND_ADMIN_NAME: \"${TAIGA_BACKEND_ADMIN_NAME}\""
if [ -n "${TAIGA_BACKEND_ADMIN_NAME}" ]; then
  sed -i -e "s#TAIGA_BACKEND_ADMIN_NAME#${TAIGA_BACKEND_ADMIN_NAME}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_ADMIN_NAME"
  exit 1
fi

echo "TAIGA_BACKEND_ADMIN_EMAIL: \"${TAIGA_BACKEND_ADMIN_EMAIL}\""
if [ -n "${TAIGA_BACKEND_ADMIN_EMAIL}" ]; then
  sed -i -e "s#TAIGA_BACKEND_ADMIN_EMAIL#${TAIGA_BACKEND_ADMIN_EMAIL}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_ADMIN_EMAIL"
  exit 1
fi

echo "TAIGA_BACKEND_POSTGRESQL_HOST: \"${TAIGA_BACKEND_POSTGRESQL_HOST}\""
if [ -n "${TAIGA_BACKEND_POSTGRESQL_HOST}" ]; then
  sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_HOST#${TAIGA_BACKEND_POSTGRESQL_HOST}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_HOST"
  exit 1
fi

echo "TAIGA_BACKEND_POSTGRESQL_PORT: \"${TAIGA_BACKEND_POSTGRESQL_PORT}\""
if [ -n "${TAIGA_BACKEND_POSTGRESQL_PORT}" ]; then
  sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_PORT#${TAIGA_BACKEND_POSTGRESQL_PORT}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PORT"
  exit 1
fi

echo "TAIGA_BACKEND_POSTGRESQL_NAME: \"${TAIGA_BACKEND_POSTGRESQL_NAME}\""
if [ -n "${TAIGA_BACKEND_POSTGRESQL_NAME}" ]; then
  sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_NAME#${TAIGA_BACKEND_POSTGRESQL_NAME}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_NAME"
  exit 1
fi

echo "TAIGA_BACKEND_POSTGRESQL_USER: \"${TAIGA_BACKEND_POSTGRESQL_USER}\""
if [ -n "${TAIGA_BACKEND_POSTGRESQL_USER}" ]; then
  sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_USER#${TAIGA_BACKEND_POSTGRESQL_USER}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_USER"
  exit 1
fi

echo "TAIGA_BACKEND_POSTGRESQL_PASS: \"${TAIGA_BACKEND_POSTGRESQL_PASS}\""
if [ -n "${TAIGA_BACKEND_POSTGRESQL_PASS}" ]; then
  sed -i -e "s#TAIGA_BACKEND_POSTGRESQL_PASS#${TAIGA_BACKEND_POSTGRESQL_PASS}#" /taiga-backend/settings/local.py
else
  echo "Set require environment variable: TAIGA_BACKEND_POSTGRESQL_PASS"
  exit 1
fi

wait-for-it.sh ${TAIGA_BACKEND_POSTGRESQL_HOST}:${TAIGA_BACKEND_POSTGRESQL_PORT} -- echo "postgresql is up"

python3 /taiga-backend/manage.py migrate --noinput
python3 /taiga-backend/manage.py loaddata initial_user
python3 /taiga-backend/manage.py loaddata initial_project_templates
python3 /taiga-backend/manage.py compilemessages
python3 /taiga-backend/manage.py collectstatic --noinput

if [ "$1" = 'default' ]; then
  exec runsv taiga-backend
fi

exec "$@"
