#!/bin/sh

set -eu

echo "TAIGA_EVENTS_SECRET: \"${TAIGA_EVENTS_SECRET}\""
if [ -f "/taiga-events/config.json" -a -n "${TAIGA_EVENTS_SECRET}" ]; then
  sed -i -e "s#TAIGA_EVENTS_SECRET#${TAIGA_EVENTS_SECRET}#" /taiga-events/config.json
else
  echo "Set require environment variable: TAIGA_EVENTS_SECRET"
  exit 1
fi

echo "TAIGA_EVENTS_RABBITMQ_HOST: \"${TAIGA_EVENTS_RABBITMQ_HOST}\""
if [ -f "/taiga-events/config.json" -a -n "${TAIGA_EVENTS_RABBITMQ_HOST}" ]; then
  sed -i -e "s#TAIGA_EVENTS_RABBITMQ_HOST#${TAIGA_EVENTS_RABBITMQ_HOST}#" /taiga-events/config.json
else
  echo "Set require environment variable: TAIGA_EVENTS_RABBITMQ_HOST"
  exit 1
fi

echo "TAIGA_EVENTS_RABBITMQ_PORT: \"${TAIGA_EVENTS_RABBITMQ_PORT}\""
if [ -f "/taiga-events/config.json" -a -n "${TAIGA_EVENTS_RABBITMQ_PORT}" ]; then
  sed -i -e "s#TAIGA_EVENTS_RABBITMQ_PORT#${TAIGA_EVENTS_RABBITMQ_PORT}#" /taiga-events/config.json
else
  echo "Set require environment variable: TAIGA_EVENTS_RABBITMQ_PORT"
  exit 1
fi

echo "TAIGA_EVENTS_RABBITMQ_USER: \"${TAIGA_EVENTS_RABBITMQ_USER}\""
if [ -f "/taiga-events/config.json" -a -n "${TAIGA_EVENTS_RABBITMQ_USER}" ]; then
  sed -i -e "s#TAIGA_EVENTS_RABBITMQ_USER#${TAIGA_EVENTS_RABBITMQ_USER}#" /taiga-events/config.json
else
  echo "Set require environment variable: TAIGA_EVENTS_RABBITMQ_USER"
  exit 1
fi

echo "TAIGA_EVENTS_RABBITMQ_PASS: \"${TAIGA_EVENTS_RABBITMQ_PASS}\""
if [ -f "/taiga-events/config.json" -a -n "${TAIGA_EVENTS_RABBITMQ_PASS}" ]; then
  sed -i -e "s#TAIGA_EVENTS_RABBITMQ_PASS#${TAIGA_EVENTS_RABBITMQ_PASS}#" /taiga-events/config.json
else
  echo "Set require environment variable: TAIGA_EVENTS_RABBITMQ_PASS"
  exit 1
fi

if [ "$1" = 'default' ]; then
  exec runsv taiga-events
fi

exec "$@"
