#!/bin/sh

################################################################################
# Compile
################################################################################

PYTHON_MEJOR="$(python3 -c 'import sys; print(sys.version_info.major)')"
PYTHON_MINOR="$(python3 -c 'import sys; print(sys.version_info.minor)')"

python3 -B -m compileall .
python3 -B -m compileall /usr/lib/python${PYTHON_MEJOR}
python3 -B -m compileall /usr/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}
python3 -B -m compileall /usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}

unset PYTHON_MEJOR
unset PYTHON_MINOR

if [ "$1" = 'default' ]; then
  ##############################################################################
  # Check
  ##############################################################################

  set -e

  if [ ! -f "settings/local.py" ]; then
    echo "Require settings/local.py"
    exit 1
  fi

  ##############################################################################
  # Wait
  ##############################################################################

  wait-for-it.sh ${POSTGRESQL_HOST}:${POSTGRESQL_PORT} -- echo "PostgreSQL is Up"
  wait-for-it.sh ${RABBITMQ_HOST}:${RABBITMQ_PORT} -- echo "RabbitMQ Peer is Up"

  if [ "x${BACKEND_CELERY_ENABLED}" = 'xTrue' ]; then
    wait-for-it.sh ${REDIS_HOST}:${REDIS_PORT} -- echo "Redis is Up"
  fi

  ##############################################################################
  # Daemon
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

  if [ -n "${BACKEND_CELERY_CHILD}" ]; then
    sed -i -e "s/CELERY_CHILD/${BACKEND_CELERY_CHILD}/" celery/run
  else
    sed -i -e 's/CELERY_CHILD/1/' celery/run
  fi

  if [ -n "${BACKEND_CELERY_TIMELIMIT}" ]; then
    sed -i -e "s/CELERY_TIMELIMIT/${BACKEND_CELERY_TIMELIMIT}/" celery/run
  else
    sed -i -e 's/CELERY_TIMELIMIT/3/' celery/run
  fi

  ln -s ../gunicorn service/gunicorn

  if [ "x${BACKEND_CELERY_ENABLED}" = 'xTrue' ]; then
    ln -s ../celery service/celery
  fi

  ##############################################################################
  # Initialize
  ##############################################################################

  echo "Starting Initialize"
  python3 manage.py migrate --noinput
  python3 manage.py loaddata initial_user
  python3 manage.py loaddata initial_project_templates

  ##############################################################################
  # Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
