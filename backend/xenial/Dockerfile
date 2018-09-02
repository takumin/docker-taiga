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
    python3-setuptools \
    python3-pip \
    python3-dev \
    zlib1g-dev \
    libncurses5-dev \
    libpcre3-dev \
    libgdbm-dev \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    libzmq3-dev \
    libjpeg-turbo8-dev \
    libpng12-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt1-dev \
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

# Install Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Copy Source Code
COPY ./upstream /usr/local/backend

# Require Proxy Environment
RUN git config --global url."https://".insteadOf git://

# Workaround Minimum Install
RUN grep '^six==.*' /usr/local/backend/requirements.txt > six.txt
RUN pip3 install --no-cache-dir --install-option="--prefix=/usr/local" -r six.txt

# Workaround Security Update
RUN sed -i -e 's/^Django==.*/Django==1.11.16/' /usr/local/backend/requirements.txt

# Workaround Running Celery
RUN sed -i -e 's/^celery==.*/celery[redis]==4.2.1/' /usr/local/backend/requirements.txt
RUN sed -i -e 's/^kombu==.*/kombu==4.2.1/' /usr/local/backend/requirements.txt

# Workaround Running uWSGI
RUN sed -i -e '/^gunicorn==.*/d' /usr/local/backend/requirements.txt

# Workaround Performance Tuning
RUN sed -i -e 's/^lxml==.*/lxml==4.2.4/' /usr/local/backend/requirements.txt

# Install Require Python Module
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" pip3 --no-cache-dir install --install-option="--prefix=/usr/local" -r /usr/local/backend/requirements.txt

# Workaround Running uWSGI
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" pip3 --no-cache-dir install --install-option="--prefix=/usr/local" uwsgi

# Workaround Database Cache
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" pip3 --no-cache-dir install --install-option="--prefix=/usr/local" python-memcached

# Cleanup Python Cache
RUN find /usr/lib -type d -name '__pycache__' | xargs rm -fr
RUN find /usr/local/lib -type d -name '__pycache__' | xargs rm -fr

# Copy Config File
COPY ./local.py.tmpl /usr/local/backend/settings/local.py.tmpl
COPY ./celery_local.py.tmpl /usr/local/backend/settings/celery_local.py.tmpl

# Copy Entrypoint Script
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

#
# Deploy Container
#

FROM ubuntu:xenial AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

ARG UBUNTU_MIRROR="http://jp.archive.ubuntu.com/ubuntu"

COPY --from=build /usr/local /usr/local

RUN echo "Deploy Config Starting" \
 && echo "deb ${UBUNTU_MIRROR} xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
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
    libncurses5 \
    libpcre3 \
    libpcre16-3 \
    libpcre32-3 \
    libgdbm3 \
    libffi6 \
    libssl1.0.0 \
    libpq5 \
    libzmq5 \
    libjpeg-turbo8 \
    libpng12-0 \
    libfreetype6 \
    libxml2 \
    libxslt1.1 \
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
 && echo "Deploy Config Complete!"

WORKDIR /taiga-backend
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["taiga-backend"]
EXPOSE 8000 8080 8888
