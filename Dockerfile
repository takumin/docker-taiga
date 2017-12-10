FROM ubuntu

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG NO_PROXY
ARG FTP_PROXY
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG UBUNTU_MIRROR="http://jp.archive.ubuntu.com/ubuntu"
ARG NODEJS_MIRROR="https://deb.nodesource.com/node_6.x"

COPY taiga-back /opt/taiga-back
COPY taiga-front /opt/taiga-front
COPY taiga-events /opt/taiga-events
COPY taiga-circus.ini /opt/taiga-circus.ini

RUN echo Start! \
 && APT_RUN_PACKAGES="python3 python3-pkg-resources libpython3.5 libjpeg-turbo8 libfreetype6 zlib1g libzmq5 libgdbm3 libncurses5 libffi6 libxml2 libxslt1.1 libssl1.0.0 libcroco3 libgomp1 libunistring0 nodejs" \
 && APT_DEV_PACKAGES="python3-dev python3-pip python3-setuptools python3-wheel build-essential autoconf automake libtool flex bison libjpeg-turbo8-dev libfreetype6-dev zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev libffi-dev libxml2-dev libxslt1-dev libssl-dev gettext git" \
 && echo "deb ${UBUNTU_MIRROR} xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${NODEJS_MIRROR} xenial main" > /etc/apt/sources.list.d/nodejs.list \
 && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 0x1655a0ab68576280 \
 && export DEBIAN_FRONTEND="noninteractive" \
 && export DEBIAN_PRIORITY="critical" \
 && export DEBCONF_NONINTERACTIVE_SEEN="true" \
 && apt-get update -y \
 && apt-get dist-upgrade -y \
 && apt-get install -y --no-install-recommends ${APT_RUN_PACKAGES} \
 && apt-get install -y --no-install-recommends ${APT_DEV_PACKAGES} \
 && apt-get clean autoclean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
 && pip3 --no-cache-dir install -r /opt/taiga-back/requirements.txt \
 && pip3 --no-cache-dir install circus \
 && npm install --prefix /opt/taiga-events /opt/taiga-events \
 && npm install -g coffee-script \
 && npm cache clean \
 && apt-get remove -y --purge ${APT_DEV_PACKAGES} \
 && apt-get autoremove -y --purge \
 && useradd -U -M -d /nonexistent -s /usr/sbin/nologin taiga \
 && echo Complete!
