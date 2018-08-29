# vim: set ft=dockerfile :

FROM alpine AS build

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

COPY taiga-frontend/dist /taiga-frontend-build
COPY taiga-frontend-conf.json /taiga-frontend-build/conf.json

RUN rm -f /taiga-frontend-build/conf.example.json

FROM nginx:alpine

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

COPY --from=build /taiga-frontend-build /taiga-frontend
COPY taiga-frontend-nginx.conf /etc/nginx/nginx.conf
COPY taiga-frontend-entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo Start! \
 && set -ex \
 && apk --update add --no-cache runit \
 && apk del --no-cache --purge \
 && rm -fr /var/tmp/* \
 && rm -fr /tmp/* \
 && mkdir -p /sv/taiga-frontend \
 && echo "#!/bin/sh"                   >  /sv/taiga-frontend/run \
 && echo "set -e"                      >> /sv/taiga-frontend/run \
 && echo "exec 2>&1"                   >> /sv/taiga-frontend/run \
 && echo "exec nginx -g 'daemon off;'" >> /sv/taiga-frontend/run \
 && chmod 0755 /sv/taiga-frontend/run \
 && echo Complete!

WORKDIR /sv
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
