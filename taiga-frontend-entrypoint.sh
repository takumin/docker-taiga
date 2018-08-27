#!/bin/sh

set -eu

echo "TAIGA_FRONTEND_EVENTS_BASE_URI: \"${TAIGA_FRONTEND_EVENTS_BASE_URI}\""
if [ -f "/taiga-frontend/conf.json" -a -n "${TAIGA_FRONTEND_EVENTS_BASE_URI}" ]; then
  sed -i -e "s#TAIGA_FRONTEND_EVENTS_BASE_URI#${TAIGA_FRONTEND_EVENTS_BASE_URI}#" /taiga-frontend/conf.json
else
  echo "Set require environment variable: TAIGA_FRONTEND_EVENTS_BASE_URI"
  exit 1
fi

echo "TAIGA_FRONTEND_BACKEND_BASE_URI: \"${TAIGA_FRONTEND_BACKEND_BASE_URI}\""
if [ -f "/taiga-frontend/conf.json" -a -n "${TAIGA_FRONTEND_BACKEND_BASE_URI}" ]; then
  sed -i -e "s#TAIGA_FRONTEND_BACKEND_BASE_URI#${TAIGA_FRONTEND_BACKEND_BASE_URI}#" /taiga-frontend/conf.json
else
  echo "Set require environment variable: TAIGA_FRONTEND_BACKEND_BASE_URI"
  exit 1
fi

if [ "$1" = 'default' ]; then
  exec runsv taiga-frontend
fi

exec "$@"
