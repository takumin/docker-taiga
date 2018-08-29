#!/bin/sh

if [ "$1" = 'default' ]; then
  set -e

  ##############################################################################
  # Wait
  ##############################################################################

  dockerize -wait tcp://${BACKEND_LISTEN_HOST}:${BACKEND_LISTEN_PORT} -timeout 10s
  dockerize -wait tcp://${EVENTS_LISTEN_HOST}:${EVENTS_LISTEN_PORT} -timeout 10s

  ##############################################################################
  # Service Check
  ##############################################################################

  if [ ! -f "settings/local.py" ]; then
    echo "Require settings/local.py"
    exit 1
  fi

  ##############################################################################
  # Service Initialize
  ##############################################################################

  echo "Starting Initialize"
  python3 manage.py migrate --noinput
  python3 manage.py loaddata initial_user
  python3 manage.py loaddata initial_project_templates

  ##############################################################################
  # Daemon Initialize
  ##############################################################################

  mkdir /taiga-backend/gunicorn
  echo '#!/bin/sh'                                                                       >  /taiga-backend/gunicorn/run
  echo 'cd /taiga-backend'                                                               >> /taiga-backend/gunicorn/run
  echo 'exec 2>&1'                                                                       >> /taiga-backend/gunicorn/run
  echo 'exec gunicorn -w GUNICORN_WORKER -t GUNICORN_TIMEOUT -b 0.0.0.0:8000 taiga.wsgi' >> /taiga-backend/gunicorn/run
  chmod 0755 /taiga-backend/gunicorn/run

  mkdir /taiga-backend/celery
  echo '#!/bin/sh'                                                                 >  /taiga-backend/celery/run
  echo 'cd /taiga-backend'                                                         >> /taiga-backend/celery/run
  echo 'exec 2>&1'                                                                 >> /taiga-backend/celery/run
  echo 'exec celery worker -A taiga -c CELERY_CHILD --time-limit CELERY_TIMELIMIT' >> /taiga-backend/celery/run
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

  ##############################################################################
  # Daemon Enabled
  ##############################################################################

  mkdir /taiga-backend/service

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
