#!/bin/sh

if [ "$1" = 'default' ]; then
  set -e

  ##############################################################################
  # Wait
  ##############################################################################

  if [ -n "${EVENTS_LISTEN_HOST}" ]; then
    dockerize -wait tcp://${EVENTS_LISTEN_HOST} -timeout 30s
  else
    echo "Require environment variable: EVENTS_LISTEN_HOST"
    exit 1
  fi

  if [ -n "${BACKEND_LISTEN_HOST}" ]; then
    dockerize -wait tcp://${BACKEND_LISTEN_HOST} -timeout 60s
  else
    echo "Require environment variable: BACKEND_LISTEN_HOST"
    exit 1
  fi

  ##############################################################################
  # Service Initialized
  ##############################################################################

  if [ -f "nginx.conf.tmpl" ]; then
    dockerize -template nginx.conf.tmpl:/etc/nginx/nginx.conf
  else
    echo "Require nginx.conf.tmpl"
    exit 1
  fi

  if [ -f "webroot/conf.json.tmpl" ]; then
    dockerize -template webroot/conf.json.tmpl:webroot/conf.json
  else
    echo "Require nginx.conf.tmpl"
    exit 1
  fi

  ##############################################################################
  # Daemon Initialized
  ##############################################################################

  mkdir -p nginx
  echo '#!/bin/sh'                   >  nginx/run
  echo 'cd /taiga-frontend'          >> nginx/run
  echo 'exec 2>&1'                   >> nginx/run
  echo 'exec nginx -g "daemon off;"' >> nginx/run
  chmod 0755 nginx/run

  ##############################################################################
  # Daemon Enabled
  ##############################################################################

  mkdir -p service
  ln -fs ../nginx service/nginx

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
