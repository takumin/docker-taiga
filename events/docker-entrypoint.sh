#!/bin/sh

if [ "$1" = 'taiga-events' ]; then
  set -e

  ##############################################################################
  # Wait
  ##############################################################################

  dockerize -wait tcp://${RABBITMQ_HOST}:${RABBITMQ_PORT} -timeout 10s

  ##############################################################################
  # Service Initialized
  ##############################################################################

  if [ ! -f "config.json.tmpl" ]; then
    echo "Require config.json.tmpl"
    exit 1
  else
    dockerize -template config.json.tmpl:config.json
  fi

  ##############################################################################
  # Daemon Initialized
  ##############################################################################

  mkdir -p coffee
  echo '#!/bin/sh'              >  coffee/run
  echo 'cd /taiga-events'       >> coffee/run
  echo 'exec 2>&1'              >> coffee/run
  echo 'exec coffee index.coffee' >> coffee/run
  chmod 0755 coffee/run

  ##############################################################################
  # Daemon Enabled
  ##############################################################################

  mkdir -p service
  ln -fs ../coffee service/coffee

  ##############################################################################
  # Daemon Running
  ##############################################################################

  echo "Starting Server"
  exec runsvdir service
fi

exec "$@"
