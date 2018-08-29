#!/bin/sh

if [ "$1" = 'default' ]; then
  set -e

  ##############################################################################
  # Wait
  ##############################################################################

  dockerize -wait tcp://${RABBITMQ_HOST}:${RABBITMQ_PORT} -timeout 10s

  ##############################################################################
  # Service Initialize
  ##############################################################################

  if [ ! -f "config.json.tmpl" ]; then
    echo "Require config.json.tmpl"
    exit 1
  else
    dockerize -template config.json.tmpl:config.json
  fi

  ##############################################################################
  # Daemon Initialized & Enabled
  ##############################################################################

  mkdir service
  echo '#!/bin/sh'          >  service/run
  echo 'cd /taiga-events'   >> service/run
  echo 'exec 2>&1'          >> service/run
  echo 'exec node index.js' >> service/run
  chmod 0755 service/run

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
