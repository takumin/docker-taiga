#!/bin/sh

if [ ! -e /var/lib/postgresql/data/pgdata ]; then
  mkdir -p /var/lib/postgresql/data/pgdata
fi
chown -R postgres:postgres /var/lib/postgresql
