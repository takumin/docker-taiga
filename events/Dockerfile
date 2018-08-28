# vim: set ft=dockerfile :

FROM alpine

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
 && mkdir -p /sv/taiga-events \
 && echo "#!/bin/sh"                                                                 >  /sv/taiga-events/run \
 && echo "set -e"                                                                    >> /sv/taiga-events/run \
 && echo "exec 2>&1"                                                                 >> /sv/taiga-events/run \
 && echo "exec coffee /taiga-events/index.coffee --config /taiga-events/config.json" >> /sv/taiga-events/run \
 && chmod 0755 /sv/taiga-events/run \
 && echo Complete!

WORKDIR /sv
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8888