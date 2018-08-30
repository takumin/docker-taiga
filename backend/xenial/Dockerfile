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

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY ../upstream /usr/local/backend
RUN git config --global url."https://".insteadOf git://
RUN env PYTHONDONTWRITEBYTECODE=1 pip3 install --install-option="--prefix=/usr/local" -r /usr/local/backend/requirements.txt

WORKDIR /usr/local/backend
RUN python3 -B manage.py compilemessages
RUN python3 -B manage.py collectstatic --noinput

RUN find /usr/lib -type d -name '__pycache__' | xargs rm -fr
RUN find /usr/local/lib -type d -name '__pycache__' | xargs rm -fr

COPY ../local.py.tmpl /usr/local/backend/settings/local.py.tmpl

COPY ../entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

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
    python3-six \
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
 && echo "Deploy Config Complete!"

# Debug Configration
# COPY ./local.py.tmpl /taiga-backend/settings/local.py.tmpl
# COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod 0755 /usr/local/bin/entrypoint.sh

WORKDIR /taiga-backend
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8080