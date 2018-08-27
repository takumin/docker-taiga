#!/bin/sh

python3 /opt/taiga-back/manage.py migrate --noinput
python3 /opt/taiga-back/manage.py loaddata initial_user
python3 /opt/taiga-back/manage.py loaddata initial_project_templates
python3 /opt/taiga-back/manage.py loaddata initial_role
python3 /opt/taiga-back/manage.py compilemessages

exec /usr/local/bin/circusd /opt/taiga-circus.ini
