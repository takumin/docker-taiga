#!/bin/sh

################################################################################
# Compile
################################################################################

python3 -B -m compileall .
python3 -B -m compileall /usr/lib
python3 -B -m compileall /usr/local/lib

if [ "$1" = 'taiga-backend' ]; then
  set -e

  ##############################################################################
  # Configure
  ##############################################################################

  if [ -f 'settings/local.py.tmpl' ]; then
    dockerize -template settings/local.py.tmpl:settings/local.py
  else
    echo 'Require settings/local.py.tmpl'
    exit 1
  fi

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    if [ -f 'settings/celery_local.py.tmpl' ]; then
      dockerize -template settings/celery_local.py.tmpl:settings/celery_local.py
    else
      echo 'Require settings/celery_local.py.tmpl'
      exit 1
    fi
  fi

  ##############################################################################
  # Waiting
  ##############################################################################

  if [ -n "${POSTGRESQL_HOST}" -a -n "${POSTGRESQL_PORT}" ]; then
    dockerize -wait tcp://${POSTGRESQL_HOST}:${POSTGRESQL_PORT} -timeout 10s
  else
    echo 'Require environment variable: POSTGRESQL_HOST, POSTGRESQL_PORT'
    exit 1
  fi

  if [ -n "${RABBITMQ_EVENTS_HOST}" -a -n "${RABBITMQ_EVENTS_PORT}" ]; then
    dockerize -wait tcp://${RABBITMQ_EVENTS_HOST}:${RABBITMQ_EVENTS_PORT} -timeout 10s
  else
    echo 'Require environment variable: RABBITMQ_EVENTS_HOST, RABBITMQ_EVENTS_PORT'
    exit 1
  fi

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    if [ -n "${RABBITMQ_ASYNC_HOST}" -a -n "${RABBITMQ_ASYNC_PORT}" ]; then
      dockerize -wait tcp://${RABBITMQ_ASYNC_HOST}:${RABBITMQ_ASYNC_PORT} -timeout 10s
    else
      echo 'Require environment variable: RABBITMQ_ASYNC_HOST, RABBITMQ_ASYNC_PORT'
      exit 1
    fi

    if [ -n "${REDIS_HOST}" -a -n "${REDIS_PORT}" ]; then
      dockerize -wait tcp://${REDIS_HOST}:${REDIS_PORT} -timeout 10s
    else
      echo 'Require environment variable: REDIS_HOST, REDIS_PORT'
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

  if [ -z "${BACKEND_CELERY_WORKER}" ]; then
    BACKEND_CELERY_WORKER=1
  fi

  if [ -z "${BACKEND_CELERY_TIMEOUT}" ]; then
    BACKEND_CELERY_TIMEOUT=10
  fi

  mkdir -p main
  echo '#!/bin/sh'                                                                                                 >  main/run
  echo 'cd /taiga-backend'                                                                                         >> main/run
  echo 'exec 2>&1'                                                                                                 >> main/run
  echo "exec gunicorn -w "${BACKEND_GUNICORN_WORKER}" -t "${BACKEND_GUNICORN_TIMEOUT}" -b 0.0.0.0:8080 taiga.wsgi" >> main/run
  chmod 0755 main/run

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    mkdir -p async
    echo '#!/bin/sh'                                                                                              >  async/run
    echo 'cd /taiga-backend'                                                                                      >> async/run
    echo 'export C_FORCE_ROOT="true"'                                                                             >> async/run
    echo 'exec 2>&1'                                                                                              >> async/run
    echo "exec celery -A taiga worker -l INFO -c ${BACKEND_CELERY_WORKER} --time-limit ${BACKEND_CELERY_TIMEOUT}" >> async/run
    chmod 0755 async/run
  fi

  mkdir -p service
  ln -fs ../main service/main

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    ln -fs ../async service/async
  fi

  echo 'Starting Server'
  exec runsvdir service
fi

exec "$@"
