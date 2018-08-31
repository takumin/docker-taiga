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
  # Wait
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

  if [ -n "${REDIS_HOST}" -a -n "${REDIS_PORT}" ]; then
    dockerize -wait tcp://${RABBITMQ_HOST}:${RABBITMQ_PORT} -timeout 10s
  else
    echo "Require environment variable: REDIS_HOST, REDIS_PORT"
    exit 1
  fi

  ##############################################################################
  # Service Configure
  ##############################################################################

  if [ -f "settings/local.py.tmpl" ]; then
    dockerize -template settings/local.py.tmpl:settings/local.py
  else
    echo "Require settings/local.py.tmpl"
    exit 1
  fi

  if [ -f "settings/celery_local.py.tmpl" ]; then
    dockerize -template settings/celery_local.py.tmpl:settings/celery_local.py
  else
    echo "Require settings/celery_local.py.tmpl"
    exit 1
  fi

  ##############################################################################
  # Service Initialize
  ##############################################################################

  PYTHON_MEJOR="$(python3 -c 'import sys; print(sys.version_info.major)')"
  PYTHON_MINOR="$(python3 -c 'import sys; print(sys.version_info.minor)')"
  export PYTHONPATH="/usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}/site-packages"

  python3 manage.py migrate --noinput
  python3 manage.py loaddata initial_user
  python3 manage.py loaddata initial_project_templates

  ##############################################################################
  # Daemon Initialize
  ##############################################################################

  echo "" > taiga.ini

  echo "[watcher:taiga]"                                                                 >> taiga.ini
  echo "working_dir = /taiga-backend"                                                    >> taiga.ini
  echo "cmd = gunicorn"                                                                  >> taiga.ini
  echo "args = -w GUNICORN_WORKER -t GUNICORN_TIMEOUT -b 0.0.0.0:8080 taiga.wsgi"        >> taiga.ini
  echo "numprocesses = 1"                                                                >> taiga.ini
  echo "autostart = true"                                                                >> taiga.ini
  echo "send_hup = true"                                                                 >> taiga.ini
  echo ""                                                                                >> taiga.ini
  echo "[env:taiga]"                                                                     >> taiga.ini
  echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"               >> taiga.ini
  echo "PYTHONPATH=.:/usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}/site-packages" >> taiga.ini

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    echo "[watcher:taiga-celery]"                                                          >> taiga.ini
    echo "working_dir = /taiga-backend"                                                    >> taiga.ini
    echo "cmd = celery"                                                                    >> taiga.ini
    echo "args = -A taiga worker -c CELERY_WORKER --time-limit CELERY_TIMEOUT"             >> taiga.ini
    echo "numprocesses = 1"                                                                >> taiga.ini
    echo "autostart = true"                                                                >> taiga.ini
    echo "send_hup = true"                                                                 >> taiga.ini
    echo ""                                                                                >> taiga.ini
    echo "[env:taiga-celery]"                                                              >> taiga.ini
    echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"               >> taiga.ini
    echo "PYTHONPATH=.:/usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}/site-packages" >> taiga.ini
  fi

  ##############################################################################
  # Daemon Parameter
  ##############################################################################

  if [ -n "${BACKEND_GUNICORN_WORKER}" ]; then
    sed -i -e "s/GUNICORN_WORKER/${BACKEND_GUNICORN_WORKER}/" taiga.ini
  else
    sed -i -e "s/GUNICORN_WORKER/1/" taiga.ini
  fi

  if [ -n "${BACKEND_GUNICORN_TIMEOUT}" ]; then
    sed -i -e "s/GUNICORN_TIMEOUT/${BACKEND_GUNICORN_TIMEOUT}/" taiga.ini
  else
    sed -i -e "s/GUNICORN_TIMEOUT/3/" taiga.ini
  fi

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    if [ -n "${BACKEND_CELERY_WORKER}" ]; then
      sed -i -e "s/CELERY_WORKER/${BACKEND_CELERY_WORKER}/" taiga.ini
    else
      sed -i -e 's/CELERY_WORKER/1/' taiga.ini
    fi

    if [ -n "${BACKEND_CELERY_TIMEOUT}" ]; then
      sed -i -e "s/CELERY_TIMEOUT/${BACKEND_CELERY_TIMEOUT}/" taiga.ini
    else
      sed -i -e 's/CELERY_TIMEOUT/3/' taiga.ini
    fi
  fi

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec circusd taiga.ini
fi

exec "$@"
