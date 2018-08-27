FROM ubuntu

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG NO_PROXY
ARG FTP_PROXY
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG UBUNTU_MIRROR="http://jp.archive.ubuntu.com/ubuntu"
ARG NODEJS_MIRROR="https://deb.nodesource.com/node_10.x"
ARG PIP_CACHE_HOST
ARG PIP_CACHE_PORT="3141"

COPY nodesource.gpg.key /tmp/nodesource.gpg.key
COPY taiga-back /opt/taiga-back
COPY taiga-front /opt/taiga-front
COPY taiga-events /opt/taiga-events
COPY taiga-circus.ini /opt/taiga-circus.ini
COPY taiga-entrypoint.sh /opt/taiga-entrypoint.sh
COPY taiga-back-local.py /opt/taiga-back/settings/local.py
COPY taiga-front-conf.json /opt/taiga-front/dist/conf.json
COPY taiga-events-config.json /opt/taiga-events/config.json

RUN echo Start! \
 && set -ex \
 && APT_RUN_PACKAGES="python3 nodejs" \
 && APT_DEV_PACKAGES="build-essential" \
 && if [ "x${NO_PROXY}" != "x" ]; then export no_proxy="${NO_PROXY}"; fi \
 && if [ "x${FTP_PROXY}" != "x" ]; then export ftp_proxy="${FTP_PROXY}"; fi \
 && if [ "x${HTTP_PROXY}" != "x" ]; then export http_proxy="${HTTP_PROXY}"; fi \
 && if [ "x${HTTPS_PROXY}" != "x" ]; then export https_proxy="${HTTPS_PROXY}"; fi \
 && if [ "x${PIP_CACHE_HOST}" != "x" ]; then export PIP_TRUSTED_HOST="${PIP_CACHE_HOST}"; export PIP_INDEX_URL="http://${PIP_CACHE_HOST}:${PIP_CACHE_PORT}/root/pypi/"; fi \
 && echo "deb ${UBUNTU_MIRROR} xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && export DEBIAN_FRONTEND="noninteractive" \
 && export DEBIAN_PRIORITY="critical" \
 && export DEBCONF_NONINTERACTIVE_SEEN="true" \
 && apt-get -qq update \
 && apt-get -qq dist-upgrade \
 && apt-get -qq install --no-install-recommends gnupg \
 && apt-key add /tmp/nodesource.gpg.key \
 && rm /tmp/nodesource.gpg.key \
 && apt-get -qq purge gnupg \
 && echo "deb ${NODEJS_MIRROR} xenial main" > /etc/apt/sources.list.d/nodejs.list \
 && apt-get -qq update \
 && apt-get -qq dist-upgrade \
 && apt-get -qq install --no-install-recommends ${APT_RUN_PACKAGES} \
 && apt-get -qq install --no-install-recommends ${APT_DEV_PACKAGES} \
 && apt-get clean autoclean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
 && pip3 --no-cache-dir install -r /opt/taiga-back/requirements.txt \
 && pip3 --no-cache-dir install circus \
 && npm install --production --prefix /opt/taiga-events /opt/taiga-events \
 && npm install -g coffee-script \
 && npm cache clean \
 && apt-get -qq purge gnupg ${APT_DEV_PACKAGES} \
 && apt-get -qq autoremove --purge \
 && useradd -U -M -d /nonexistent -s /usr/sbin/nologin taiga \
 && echo Complete!

USER taiga
ENTRYPOINT ["/opt/taiga-entrypoint.sh"]
