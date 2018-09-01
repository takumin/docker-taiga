#!/bin/sh

################################################################################
# Compile
################################################################################

python3 -B -m compileall .
python3 -B -m compileall /usr/lib
python3 -B -m compileall /usr/local/lib

if [ "$1" = 'default' ]; then
  set -e

  ##############################################################################
  # Configure
  ##############################################################################

  if [ -f "settings/local.py.tmpl" ]; then
    dockerize -template settings/local.py.tmpl:settings/local.py
  else
    echo "Require settings/local.py.tmpl"
    exit 1
  fi

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    if [ -f "settings/celery_local.py.tmpl" ]; then
      dockerize -template settings/celery_local.py.tmpl:settings/celery_local.py
    else
      echo "Require settings/celery_local.py.tmpl"
      exit 1
    fi
  fi

  ##############################################################################
  # Waiting
  ##############################################################################

  if [ -n "${POSTGRESQL_HOST}" -a -n "${POSTGRESQL_PORT}" ]; then
    dockerize -wait tcp://${POSTGRESQL_HOST}:${POSTGRESQL_PORT} -timeout 10s
  else
    echo "Require environment variable: POSTGRESQL_HOST, POSTGRESQL_PORT"
    exit 1
  fi

  if [ -n "${RABBITMQ_HOST}" -a -n "${RABBITMQ_PORT}" ]; then
    dockerize -wait tcp://${RABBITMQ_HOST}:${RABBITMQ_PORT} -timeout 10s
  else
    echo "Require environment variable: RABBITMQ_HOST, RABBITMQ_PORT"
    exit 1
  fi

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    if [ -n "${REDIS_HOST}" -a -n "${REDIS_PORT}" ]; then
      dockerize -wait tcp://${REDIS_HOST}:${REDIS_PORT} -timeout 10s
    else
      echo "Require environment variable: REDIS_HOST, REDIS_PORT"
      exit 1
    fi
  fi

  ##############################################################################
  # Initialize
  ##############################################################################

  PYTHON_MEJOR="$(python3 -c 'import sys; print(sys.version_info.major)')"
  PYTHON_MINOR="$(python3 -c 'import sys; print(sys.version_info.minor)')"
  export PYTHONPATH=".:/usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}/site-packages"

  python3 manage.py migrate --noinput
  python3 manage.py loaddata initial_user
  python3 manage.py loaddata initial_project_templates

  ##############################################################################
  # Running
  ##############################################################################

  if [ -z "${BACKEND_GUNICORN_WORKER}" ]; then
    BACKEND_GUNICORN_WORKER=1
  fi

  if [ -z "${BACKEND_GUNICORN_TIMEOUT}" ]; then
    BACKEND_GUNICORN_TIMEOUT=10
  fi

  echo "Starting Server"
  exec gunicorn -w ${BACKEND_GUNICORN_WORKER} -t ${BACKEND_GUNICORN_TIMEOUT} -b 0.0.0.0:8080 taiga.wsgi
fi

exec "$@"
