#!/bin/sh

if [ "$1" = 'default' ]; then
  set -e

  ##############################################################################
  # Wait
  ##############################################################################

  dockerize -wait tcp://${BACKEND_LISTEN_HOST} -timeout 30s
  dockerize -wait tcp://${EVENTS_LISTEN_HOST} -timeout 30s

  ##############################################################################
  # Service Initialized
  ##############################################################################

  dockerize -template nginx.conf.tmpl:/etc/nginx/nginx.conf
  dockerize -template conf.json.tmpl:conf.json

  ##############################################################################
  # Daemon Initialized
  ##############################################################################

  mkdir nginx
  echo '#!/bin/sh'                   >  nginx/run
  echo 'cd /taiga-frontend'          >> nginx/run
  echo 'exec 2>&1'                   >> nginx/run
  echo 'exec nginx -g "daemon off;"' >> nginx/run
  chmod 0755 nginx/run

  ##############################################################################
  # Daemon Enabled
  ##############################################################################

  mkdir service
  ln -s ../nginx service/nginx

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
