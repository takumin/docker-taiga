# vim: set ft=dockerfile :

#
# Build Container
#

FROM ubuntu:xenial AS build
MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG NO_PROXY
ARG FTP_PROXY
ARG HTTP_PROXY
ARG HTTPS_PROXY
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
    zlib1g-dev \
    libjpeg-turbo8-dev \
    libfreetype6-dev \
    libxslt1-dev \
    libncurses5-dev \
    libffi-dev \
 && apt-get -y autoremove --purge \
 && apt-get -y clean \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/lib/apt/lists/* \
 && echo "Build Config Complete!"

COPY ./upstream/requirements.txt /requirements.txt
RUN git config --global url."https://".insteadOf git://
RUN pip3 install --install-option="--prefix=/srv" -r /requirements.txt

RUN mkdir -m 0755 -p /srv/bin
RUN wget -q -O /srv/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
RUN chmod 0755 /srv/bin/wait-for-it.sh
COPY ./entrypoint.sh /srv/bin/entrypoint.sh
RUN chmod 0755 /srv/bin/entrypoint.sh

#
# Deploy Container
#

FROM ubuntu:xenial
MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

COPY --from=build /srv /usr/local

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
    python3 \
    python3-six \
    python3-pkg-resources \
    zlib1g \
    libssl1.0.0 \
    libpq5 \
    libjpeg-turbo8 \
    libfreetype6 \
    libxslt1.1 \
    libncurses5 \
    libffi6 \
 && apt-get -y autoremove --purge \
 && apt-get -y clean \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/lib/apt/lists/* \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "Check Environment Variable" \
 && printenv | sort \
 && echo "Deploy Config Complete!"

ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8000 9000
