#!/bin/sh

set -eu

if [ -n "${TAIGA_EVENTS_BASE_URI}" ]; then
  sed -i -e "s/TAIGA_EVENTS_BASE_URI/${TAIGA_EVENTS_BASE_URI}/" /taiga-front/conf.json
else
  echo "Set require environment variable: TAIGA_EVENTS_BASE_URI"
  exit 1
fi

if [ -n "${TAIGA_BACKEND_BASE_URI}" ]; then
  sed -i -e "s/TAIGA_BACKEND_BASE_URI/${TAIGA_BACKEND_BASE_URI}/" /taiga-front/conf.json
else
  echo "Set require environment variable: TAIGA_BACKEND_BASE_URI"
  exit 1
fi

echo "#!/bin/sh"                   >  /sv/taiga-front/run
echo "set -e"                      >> /sv/taiga-front/run
echo "exec 2>&1"                   >> /sv/taiga-front/run
echo "exec nginx -g 'daemon off;'" >> /sv/taiga-front/run
chmod 0755 /sv/taiga-front/run

if [ "$1" = 'default' ]; then
  exec runsv taiga-front
fi

exec "$@"
