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

  if [ -n "${RABBITMQ_HOST}" -a -n "${RABBITMQ_PORT}" ]; then
    dockerize -wait tcp://${RABBITMQ_HOST}:${RABBITMQ_PORT} -timeout 10s
  else
    echo 'Require environment variable: RABBITMQ_HOST, RABBITMQ_PORT'
    exit 1
  fi

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
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

  if [ -z "${BACKEND_UWSGI_PROCESS}" ]; then
    BACKEND_UWSGI_PROCESS=1
  fi

  if [ -z "${BACKEND_UWSGI_THREADS}" ]; then
    BACKEND_UWSGI_THREADS=2
  fi

  if [ -z "${BACKEND_UWSGI_MAX_REQUEST}" ]; then
    BACKEND_UWSGI_MAX_REQUEST=1024
  fi

  if [ -z "${BACKEND_UWSGI_HARAKIRI}" ]; then
    BACKEND_UWSGI_HARAKIRI=10
  fi

  if [ -z "${BACKEND_CELERY_WORKER}" ]; then
    BACKEND_CELERY_WORKER=1
  fi

  if [ -z "${BACKEND_CELERY_TIMEOUT}" ]; then
    BACKEND_CELERY_TIMEOUT=10
  fi

  echo '[uwsgi]'                                  >  main.ini
  echo 'socket = 0.0.0.0:8080'                    >> main.ini
  echo 'http = 0.0.0.0:8000'                      >> main.ini
  echo 'stats = 0.0.0.0:8888'                     >> main.ini
  echo 'chdir = /taiga-backend'                   >> main.ini
  echo 'module = taiga.wsgi:application'          >> main.ini
  echo 'master = true'                            >> main.ini
  echo "processes = ${BACKEND_UWSGI_PROCESS}"     >> main.ini
  echo "threads = ${BACKEND_UWSGI_THREADS}"       >> main.ini
  echo "harakiri = ${BACKEND_UWSGI_HARAKIRI}"     >> main.ini
  echo 'harakiri-verbose = true'                  >> main.ini
  echo 'vacuum = true'                            >> main.ini
  echo 'pidfile = /run/uwsgi.%(project_name).pid' >> main.ini

  mkdir -p main
  echo '#!/bin/sh'                  >  main/run
  echo 'exec 2>&1'                  >> main/run
  echo "exec uwsgi $(pwd)/main.ini" >> main/run
  chmod 0755 main/run

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    mkdir -p async
    echo '#!/bin/sh'                                                                                              >  async/run
    echo 'cd /taiga-backend'                                                                                      >> async/run
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
