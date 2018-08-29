#!/bin/sh

if [ "$1" = 'default' ]; then
  set -e

  ##############################################################################
  # Wait
  ##############################################################################

  dockerize -wait tcp://${RABBITMQ_HOST}:${RABBITMQ_PORT} -timeout 10s

  ##############################################################################
  # Service Check
  ##############################################################################

  if [ ! -f "config.json.tmpl" ]; then
    echo "Require config.json.tmpl"
    exit 1
  fi

  ##############################################################################
  # Service Initialize
  ##############################################################################

  dockerize -template config.json.tmpl:config.json

  ##############################################################################
  # Daemon Initialized & Enabled
  ##############################################################################

  mkdir /taiga-events/service
  echo '#!/bin/sh'          >  /taiga-events/service/run
  echo 'cd /taiga-events'   >> /taiga-events/service/run
  echo 'exec 2>&1'          >> /taiga-events/service/run
  echo 'exec node index.js' >> /taiga-events/service/run
  chmod 0755 /taiga-events/service/run

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
