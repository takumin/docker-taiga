#!/bin/sh

if [ "$1" = 'default' ]; then
  set -e

  ##############################################################################
  # Wait
  ##############################################################################

  dockerize -wait ${BACKEND_LISTEN_SCHEME}://${BACKEND_LISTEN_HOST}:${BACKEND_LISTEN_PORT} -timeout 10s
  dockerize -wait ${EVENTS_LISTEN_SCHEME}://${EVENTS_LISTEN_HOST}:${EVENTS_LISTEN_PORT} -timeout 10s

  ##############################################################################
  # Service Initialize
  ##############################################################################

  dockerize -template nginx.conf.tmpl:/etc/nginx/nginx.conf
  dockerize -template conf.json.tmpl:conf.json

  ##############################################################################
  # Daemon Initialized & Enabled
  ##############################################################################

  mkdir service
  echo '#!/bin/sh'                   >  service/run
  echo 'cd /taiga-frontend'          >> service/run
  echo 'exec 2>&1'                   >> service/run
  echo 'exec nginx -g "daemon off;"' >> service/run
  chmod 0755 service/run

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
