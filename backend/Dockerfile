# vim: set ft=dockerfile :

#
# Build Container
#

FROM ubuntu:xenial AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

ARG UBUNTU_MIRROR="http://jp.archive.ubuntu.com/ubuntu"

RUN echo "Build Config Starting" \
 && echo "deb ${UBUNTU_MIRROR} xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && export DEBIAN_FRONTEND="noninteractive" \
 && export DEBIAN_PRIORITY="critical" \
 && export DEBCONF_NONINTERACTIVE_SEEN="true" \
 && apt-get -y update \
 && apt-get -y dist-upgrade \
 && apt-get -y install --no-install-recommends \
    gettext \
    build-essential \
    wget \
    git \
    python3 \
    python3-six \
    python3-setuptools \
    python3-pip \
    python3-dev \
    zlib1g-dev \
    libssl-dev \
    libpq-dev \
    libgdbm-dev \
    libzmq3-dev \
    libjpeg-turbo8-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt1-dev \
    libncurses5-dev \
    libffi-dev \
 && apt-get -y autoremove --purge \
 && apt-get -y clean \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/lib/apt/lists/* \
 && unset DEBIAN_FRONTEND \
 && unset DEBIAN_PRIORITY \
 && unset DEBCONF_NONINTERACTIVE_SEEN \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "Build Config Complete!"

RUN wget -O /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
RUN chmod 0755 /usr/local/bin/wait-for-it.sh

COPY ./upstream /usr/local/backend
RUN git config --global url."https://".insteadOf git://
RUN echo "django-environ==0.4.5" >> /usr/local/backend/requirements.txt
RUN env PYTHONDONTWRITEBYTECODE=1 pip3 install --install-option="--prefix=/usr/local" -r /usr/local/backend/requirements.txt

WORKDIR /usr/local/backend
RUN python3 -B manage.py compilemessages
RUN python3 -B manage.py collectstatic --noinput

RUN export PYTHON_MEJOR="$(python3 -B -c 'import sys; print(sys.version_info.major)')"
RUN export PYTHON_MINOR="$(python3 -B -c 'import sys; print(sys.version_info.minor)')"

RUN find /usr/lib/python${PYTHON_MEJOR} -type d -name '__pycache__' | xargs rm -fr
RUN find /usr/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR} -type d -name '__pycache__' | xargs rm -fr
RUN find /usr/local/lib/python${PYTHON_MEJOR}.${PYTHON_MINOR} -type d -name '__pycache__' | xargs rm -fr

RUN unset PYTHON_MEJOR
RUN unset PYTHON_MINOR

COPY ./local.py /usr/local/backend/settings/local.py
COPY ./celery.py /usr/local/backend/settings/celery.py
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

RUN find /usr/local

#
# Deploy Container
#

FROM ubuntu:xenial AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

COPY --from=build /usr/local /usr/local

RUN echo "Deploy Config Starting" \
 && echo "deb http://jp.archive.ubuntu.com/ubuntu xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb http://jp.archive.ubuntu.com/ubuntu xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://jp.archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && export DEBIAN_FRONTEND="noninteractive" \
 && export DEBIAN_PRIORITY="critical" \
 && export DEBCONF_NONINTERACTIVE_SEEN="true" \
 && apt-get -y update \
 && apt-get -y dist-upgrade \
 && apt-get -y install --no-install-recommends \
    runit \
    python3 \
    python3-pkg-resources \
    zlib1g \
    libssl1.0.0 \
    libpq5 \
    libgdbm3 \
    libzmq5 \
    libjpeg-turbo8 \
    libfreetype6 \
    libxml2 \
    libxslt1.1 \
    libncurses5 \
    libffi6 \
 && apt-get -y autoremove --purge \
 && apt-get -y clean \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/lib/apt/lists/* \
 && unset DEBIAN_FRONTEND \
 && unset DEBIAN_PRIORITY \
 && unset DEBCONF_NONINTERACTIVE_SEEN \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && mv /usr/local/backend /taiga-backend \
 && mkdir /taiga-backend/gunicorn \
 && echo '#!/bin/sh'                                                                       >  /taiga-backend/gunicorn/run \
 && echo 'cd /taiga-backend'                                                               >> /taiga-backend/gunicorn/run \
 && echo 'exec 2>&1'                                                                       >> /taiga-backend/gunicorn/run \
 && echo 'exec gunicorn -w GUNICORN_WORKER -t GUNICORN_TIMEOUT -b 0.0.0.0:8000 taiga.wsgi' >> /taiga-backend/gunicorn/run \
 && chmod 0755 /taiga-backend/gunicorn/run \
 && mkdir /taiga-backend/celery \
 && echo '#!/bin/sh'                                                                 >  /taiga-backend/celery/run \
 && echo 'cd /taiga-backend'                                                         >> /taiga-backend/celery/run \
 && echo 'exec 2>&1'                                                                 >> /taiga-backend/celery/run \
 && echo 'exec celery worker -A taiga -c CELERY_CHILD --time-limit CELERY_TIMELIMIT' >> /taiga-backend/celery/run \
 && chmod 0755 /taiga-backend/celery/run \
 && mkdir /taiga-backend/service \
 && echo "Deploy Config Complete!"

WORKDIR /taiga-backend
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8000
