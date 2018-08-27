#!/bin/sh

set -eu

if [ -n "${TAIGA_FRONTEND_EVENTS_BASE_URI}" ]; then
  sed -i -e "s/TAIGA_FRONTEND_EVENTS_BASE_URI/${TAIGA_FRONTEND_EVENTS_BASE_URI}/" /taiga-frontend/conf.json
else
  echo "Set require environment variable: TAIGA_FRONTEND_EVENTS_BASE_URI"
  exit 1
fi

if [ -n "${TAIGA_FRONTEND_BACKEND_BASE_URI}" ]; then
  sed -i -e "s/TAIGA_FRONTEND_BACKEND_BASE_URI/${TAIGA_FRONTEND_BACKEND_BASE_URI}/" /taiga-frontend/conf.json
else
  echo "Set require environment variable: TAIGA_FRONTEND_BACKEND_BASE_URI"
  exit 1
fi

echo "#!/bin/sh"                   >  /sv/taiga-frontend/run
echo "set -e"                      >> /sv/taiga-frontend/run
echo "exec 2>&1"                   >> /sv/taiga-frontend/run
echo "exec nginx -g 'daemon off;'" >> /sv/taiga-frontend/run
chmod 0755 /sv/taiga-frontend/run

if [ "$1" = 'default' ]; then
  exec runsv taiga-frontend
fi

exec "$@"
