# vim: set ft=dockerfile :

FROM alpine AS build

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG NO_PROXY
ARG FTP_PROXY
ARG HTTP_PROXY
ARG HTTPS_PROXY

COPY taiga-events /taiga-events
COPY taiga-events-config.json /taiga-events/config.json
COPY taiga-events-entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo Start! \
 && set -ex \
 && apk --update add --no-cache nodejs npm runit \
 && npm install --production --prefix /usr/local -g /taiga-events \
 && npm install --production --prefix /usr/local -g coffee-script \
 && rm -fr ~/.npm \
 && apk del --no-cache --purge npm \
 && apk del --no-cache --purge \
 && rm -fr /var/tmp/* \
 && rm -fr /tmp/* \
 && echo Complete!

ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8888
