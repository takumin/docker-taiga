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

  if [ ! -f "settings/local.py.tmpl" ]; then
    echo "Require settings/local.py.tmpl"
    exit 1
  else
    dockerize -template settings/local.py.tmpl:settings/local.py
  fi

  if [ ! -f "settings/celery_local.py.tmpl" ]; then
    echo "Require settings/celery_local.py.tmpl"
    exit 1
  else
    dockerize -template settings/celery_local.py.tmpl:settings/celery_local.py
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

  mkdir /taiga-backend/gunicorn
  echo '#!/bin/sh'                                                                                >  /taiga-backend/gunicorn/run
  echo "export PYTHONPATH=\"/usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}/site-packages\"" >> /taiga-backend/gunicorn/run
  echo 'cd /taiga-backend'                                                                        >> /taiga-backend/gunicorn/run
  echo 'exec 2>&1'                                                                                >> /taiga-backend/gunicorn/run
  echo 'exec gunicorn -w GUNICORN_WORKER -t GUNICORN_TIMEOUT -b 0.0.0.0:8080 taiga.wsgi'          >> /taiga-backend/gunicorn/run
  chmod 0755 /taiga-backend/gunicorn/run

  mkdir /taiga-backend/celery
  echo '#!/bin/sh'                                                                                >  /taiga-backend/celery/run
  echo "export PYTHONPATH=\"/usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}/site-packages\"" >> /taiga-backend/celery/run
  echo 'cd /taiga-backend'                                                                        >> /taiga-backend/celery/run
  echo 'exec 2>&1'                                                                                >> /taiga-backend/celery/run
  echo 'exec celery -A taiga worker -c CELERY_WORKER --time-limit CELERY_TIMEOUT'                 >> /taiga-backend/celery/run
  chmod 0755 /taiga-backend/celery/run

  ##############################################################################
  # Daemon Parameter
  ##############################################################################

  if [ -n "${BACKEND_GUNICORN_WORKER}" ]; then
    sed -i -e "s/GUNICORN_WORKER/${BACKEND_GUNICORN_WORKER}/" gunicorn/run
  else
    sed -i -e "s/GUNICORN_WORKER/1/" gunicorn/run
  fi

  if [ -n "${BACKEND_GUNICORN_TIMEOUT}" ]; then
    sed -i -e "s/GUNICORN_TIMEOUT/${BACKEND_GUNICORN_TIMEOUT}/" gunicorn/run
  else
    sed -i -e "s/GUNICORN_TIMEOUT/3/" gunicorn/run
  fi

  if [ -n "${BACKEND_CELERY_WORKER}" ]; then
    sed -i -e "s/CELERY_WORKER/${BACKEND_CELERY_WORKER}/" celery/run
  else
    sed -i -e 's/CELERY_WORKER/1/' celery/run
  fi

  if [ -n "${BACKEND_CELERY_TIMEOUT}" ]; then
    sed -i -e "s/CELERY_TIMEOUT/${BACKEND_CELERY_TIMEOUT}/" celery/run
  else
    sed -i -e 's/CELERY_TIMEOUT/3/' celery/run
  fi

  ##############################################################################
  # Daemon Enabled
  ##############################################################################

  mkdir service

  ln -s ../gunicorn service/gunicorn

  if [ "x${BACKEND_CELERY_ENABLED}" = 'xTrue' ]; then
    ln -s ../celery service/celery
  fi

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
