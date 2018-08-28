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

ENV NO_PROXY ${NO_PROXY}
ENV no_proxy ${NO_PROXY}
ENV FTP_PROXY ${FTP_PROXY}
ENV ftp_proxy ${FTP_PROXY}
ENV HTTP_PROXY ${HTTP_PROXY}
ENV http_proxy ${HTTP_PROXY}
ENV HTTPS_PROXY ${HTTPS_PROXY}
ENV https_proxy ${HTTPS_PROXY}

RUN echo "Build Config Starting" \
 && echo "deb ${UBUNTU_MIRROR} xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && cp /etc/apt/sources.list /usr/local/sources.list \
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
 && unset DEBIAN_FRONTEND \
 && unset DEBIAN_PRIORITY \
 && unset DEBCONF_NONINTERACTIVE_SEEN \
 && echo "Build Config Complete!"

COPY ./upstream /usr/local/backend
RUN git config --global url."https://".insteadOf git://
RUN pip3 install --install-option="--prefix=/usr/local" -r /usr/local/backend/requirements.txt

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

RUN wget -O /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
RUN chmod 0755 /usr/local/bin/wait-for-it.sh

#
# Deploy Container
#

FROM ubuntu:xenial
MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

COPY --from=build /usr/local /usr/local

RUN echo "Deploy Config Starting" \
 && cp /usr/local/sources.list /etc/apt/sources.list \
 && rm /usr/local/sources.list \
 && export DEBIAN_FRONTEND="noninteractive" \
 && export DEBIAN_PRIORITY="critical" \
 && export DEBCONF_NONINTERACTIVE_SEEN="true" \
 && apt-get -y update \
 && apt-get -y dist-upgrade \
 && apt-get -y install --no-install-recommends \
    gettext \
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
 && unset DEBIAN_FRONTEND \
 && unset DEBIAN_PRIORITY \
 && unset DEBCONF_NONINTERACTIVE_SEEN \
 && [ -n "${NO_PROXY}" ] && unset NO_PROXY \
 && [ -n "${FTP_PROXY}" ] && unset FTP_PROXY \
 && [ -n "${HTTP_PROXY}" ] && unset HTTP_PROXY \
 && [ -n "${HTTPS_PROXY}" ] && unset HTTPS_PROXY \
 && find /usr/local \
 && printenv | sort \
 && echo "Deploy Config Complete!"

ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8000 9000
