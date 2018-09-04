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

  if [ -n "${MEMCACHED_LOCATION}" ]; then
    dockerize -wait tcp://${MEMCACHED_LOCATION} -timeout 10s
  else
    echo 'Require environment variable: MEMCACHED_LOCATION'
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
  # Check UID/GID
  ##############################################################################

  if [ -z "${BACKEND_UID}" ]; then
    BACKEND_UID=1001
  fi
  if echo -n "${BACKEND_UID}" | grep -Eqsv '^[0-9]+$'; then
    echo 'Please numric value: BACKEND_UID'
    exit 1
  fi
  if [ "${BACKEND_UID}" -le 0 ]; then
    echo 'Please 0 or more: BACKEND_UID'
    exit 1
  fi
  if [ "${BACKEND_UID}" -ge 60000 ]; then
    echo 'Please 60000 or less: BACKEND_UID'
    exit 1
  fi

  if [ -z "${BACKEND_GID}" ]; then
    BACKEND_GID=1001
  fi
  if echo -n "${BACKEND_GID}" | grep -Eqsv '^[0-9]+$'; then
    echo 'Please numric value: BACKEND_GID'
    exit 1
  fi
  if [ "${BACKEND_GID}" -le 0 ]; then
    echo 'Please 0 or more: BACKEND_GID'
    exit 1
  fi
  if [ "${BACKEND_GID}" -ge 60000 ]; then
    echo 'Please 60000 or less: BACKEND_GID'
    exit 1
  fi

  ##############################################################################
  # Clear User/Group
  ##############################################################################

  if getent passwd | awk -F ':' -- '{print $1}' | grep -Eqs '^taiga$'; then
    deluser 'taiga'
  fi
  if getent passwd | awk -F ':' -- '{print $3}' | grep -Eqs "^${BACKEND_UID}$"; then
    deluser "${BACKEND_UID}"
  fi
  if getent group | awk -F ':' -- '{print $1}' | grep -Eqs '^taiga$'; then
    delgroup 'taiga'
  fi
  if getent group | awk -F ':' -- '{print $3}' | grep -Eqs "^${BACKEND_GID}$"; then
    delgroup "${BACKEND_GID}"
  fi

  ##############################################################################
  # Group
  ##############################################################################

  addgroup -g "${BACKEND_GID}" 'taiga'

  ##############################################################################
  # User
  ##############################################################################

  adduser -h '/nonexistent' \
          -g 'Taiga Backend,,,' \
          -s '/usr/sbin/nologin' \
          -G 'taiga' \
          -D \
          -H \
          -u "${BACKEND_UID}" \
          'taiga'

  ##############################################################################
  # Volumes
  ##############################################################################

  mkdir -m 0755 -p volume/media
  mkdir -m 0755 -p volume/static
  chown -R taiga:taiga volume/media
  chown -R taiga:taiga volume/static

  ##############################################################################
  # Initialize
  ##############################################################################

  PYTHON_MEJOR="$(python3 -c 'import sys; print(sys.version_info.major)')"
  PYTHON_MINOR="$(python3 -c 'import sys; print(sys.version_info.minor)')"
  export PYTHONPATH=".:/usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR}/site-packages"

  if grep -qs '^DEBUG = False$' settings/local.py; then
    su-exec taiga:taiga python3 manage.py check --deploy
  fi

  if [ "$2" = 'migrate' ]; then
    su-exec taiga:taiga python3 manage.py migrate --noinput
  fi

  if [ "$2" = 'inituser' ]; then
    su-exec taiga:taiga python3 manage.py loaddata initial_user
  fi

  if [ "$2" = 'initproj' ]; then
    su-exec taiga:taiga python3 manage.py loaddata initial_project_templates
  fi

  if [ "$2" = 'example' ]; then
    su-exec taiga:taiga python3 manage.py sample_data
  fi

  ##############################################################################
  # Create Static Files
  ##############################################################################

  su-exec taiga:taiga python3 manage.py compilemessages
  su-exec taiga:taiga python3 manage.py collectstatic --noinput

  ##############################################################################
  # Environment Variables
  ##############################################################################

  if [ -z "${BACKEND_UWSGI_LISTEN}" ]; then
    BACKEND_UWSGI_LISTEN=$(cat /proc/sys/net/core/somaxconn)
  fi

  if [ -z "${BACKEND_UWSGI_LIMIT_AS}" ]; then
    BACKEND_UWSGI_LIMIT_AS=1024
  fi

  if [ -z "${BACKEND_UWSGI_PROCESSES}" ]; then
    BACKEND_UWSGI_PROCESSES=1
  fi

  if [ -z "${BACKEND_UWSGI_THREADS}" ]; then
    BACKEND_UWSGI_THREADS=1
  fi

  if [ -z "${BACKEND_UWSGI_MAX_REQUESTS}" ]; then
    BACKEND_UWSGI_MAX_REQUESTS=4096
  fi

  if [ -z "${BACKEND_UWSGI_MAX_REQUESTS_DELTA}" ]; then
    BACKEND_UWSGI_MAX_REQUESTS_DELTA=512
  fi

  if [ -z "${BACKEND_UWSGI_MIN_WORKER_LIFETIME}" ]; then
    BACKEND_UWSGI_MIN_WORKER_LIFETIME=60
  fi

  if [ -z "${BACKEND_UWSGI_MAX_WORKER_LIFETIME}" ]; then
    BACKEND_UWSGI_MAX_WORKER_LIFETIME=0
  fi

  if [ -z "${BACKEND_UWSGI_BUFFER_SIZE}" ]; then
    BACKEND_UWSGI_BUFFER_SIZE=4096
  fi

  if [ -z "${BACKEND_UWSGI_POST_BUFFERING}" ]; then
    BACKEND_UWSGI_POST_BUFFERING=4096
  fi

  if [ -z "${BACKEND_UWSGI_HARAKIRI}" ]; then
    BACKEND_UWSGI_HARAKIRI=10
  fi

  if [ -z "${BACKEND_UWSGI_DISABLE_LOGGING}" ]; then
    BACKEND_UWSGI_DISABLE_LOGGING=false
  fi

  if [ -z "${BACKEND_CELERY_WORKER}" ]; then
    BACKEND_CELERY_WORKER=1
  fi

  if [ -z "${BACKEND_CELERY_TIMEOUT}" ]; then
    BACKEND_CELERY_TIMEOUT=10
  fi

  ##############################################################################
  # Daemon
  ##############################################################################

  echo '[uwsgi]'                                                    >  main.ini
  echo 'http = 0.0.0.0:8000'                                        >> main.ini
  echo 'socket = 0.0.0.0:8080'                                      >> main.ini
  echo 'stats = 0.0.0.0:8888'                                       >> main.ini
  echo 'stats-min = true'                                           >> main.ini
  echo 'stats-http = true'                                          >> main.ini
  echo 'chdir = /taiga-backend'                                     >> main.ini
  echo 'module = taiga.wsgi:application'                            >> main.ini
  echo 'master = true'                                              >> main.ini
  echo "listen = ${BACKEND_UWSGI_LISTEN}"                           >> main.ini
  echo "limit-as = ${BACKEND_UWSGI_LIMIT_AS}"                       >> main.ini
  echo "processes = ${BACKEND_UWSGI_PROCESSES}"                     >> main.ini
  echo "threads = ${BACKEND_UWSGI_THREADS}"                         >> main.ini
  echo "max-requests = ${BACKEND_UWSGI_MAX_REQUESTS}"               >> main.ini
  echo "max-requests-delta = ${BACKEND_UWSGI_MAX_REQUESTS_DELTA}"   >> main.ini
  echo "min-worker-lifetime = ${BACKEND_UWSGI_MIN_WORKER_LIFETIME}" >> main.ini
  echo "max-worker-lifetime = ${BACKEND_UWSGI_MAX_WORKER_LIFETIME}" >> main.ini
  echo "buffer-size = ${BACKEND_UWSGI_BUFFER_SIZE}"                 >> main.ini
  echo "post-buffering = ${BACKEND_UWSGI_POST_BUFFERING}"           >> main.ini
  echo "harakiri = ${BACKEND_UWSGI_HARAKIRI}"                       >> main.ini
  echo 'harakiri-verbose = true'                                    >> main.ini
  echo 'thunder-lock = true'                                        >> main.ini
  echo 'lazy-apps = true'                                           >> main.ini
  echo 'pcre-jit = true'                                            >> main.ini
  echo 'vacuum = true'                                              >> main.ini
  echo "disable-logging = ${BACKEND_UWSGI_DISABLE_LOGGING}"         >> main.ini

  mkdir -p main
  echo '#!/bin/sh'                                  >  main/run
  echo 'set -e'                                     >> main/run
  echo 'OPTS=""'                                    >> main/run
  echo 'OPTS="${OPTS} --uid taiga"'                 >> main/run
  echo 'OPTS="${OPTS} --gid taiga"'                 >> main/run
  echo "OPTS=\"\${OPTS} ${BACKEND_UWSGI_OPTIONS}\"" >> main/run
  echo 'exec 2>&1'                                  >> main/run
  echo "exec uwsgi \${OPTS} \"$(pwd)/main.ini\""    >> main/run
  chmod 0755 main/run

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    mkdir -p async
    echo '#!/bin/sh'                                                >  async/run
    echo 'set -e'                                                   >> async/run
    echo 'OPTS=""'                                                  >> async/run
    echo 'OPTS="${OPTS} -A taiga"'                                  >> async/run
    echo 'OPTS="${OPTS} -l INFO"'                                   >> async/run
    echo 'OPTS="${OPTS} --uid taiga"'                               >> async/run
    echo 'OPTS="${OPTS} --gid taiga"'                               >> async/run
    echo "OPTS=\"\${OPTS} --workdir /taiga-backend\""               >> async/run
    echo "OPTS=\"\${OPTS} -c ${BACKEND_CELERY_WORKER}\""            >> async/run
    echo "OPTS=\"\${OPTS} --time-limit ${BACKEND_CELERY_TIMEOUT}\"" >> async/run
    echo 'exec 2>&1'                                                >> async/run
    echo 'exec celery worker ${OPTS}'                               >> async/run
    chmod 0755 async/run
  fi

  ##############################################################################
  # Service
  ##############################################################################

  mkdir -p service
  ln -fs ../main service/main

  if grep -qs '^CELERY_ENABLED = True$' settings/local.py; then
    ln -fs ../async service/async
  else
    rm -f service/async
  fi

  ##############################################################################
  # Running
  ##############################################################################

  echo 'Starting Server'
  exec runsvdir service
fi

exec "$@"
