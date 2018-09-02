# vim: set ft=dockerfile :

#
# Build Container
#

FROM alpine AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN mkdir /taiga-frontend

RUN apk --update add --no-cache wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /taiga-frontend -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY ./upstream/dist /taiga-frontend/webroot
RUN rm /taiga-frontend/webroot/conf.example.json

COPY ./conf.json.tmpl /taiga-frontend/webroot
COPY ./nginx.conf.tmpl /taiga-frontend

COPY ./docker-entrypoint.sh /taiga-frontend/docker-entrypoint.sh
RUN chmod 0755 /taiga-frontend/docker-entrypoint.sh

#
# Deploy Container
#

FROM nginx:alpine AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

COPY --from=build /taiga-frontend /taiga-frontend

RUN echo Start! \
 && set -ex \
 && mv /taiga-frontend/dockerize /usr/local/bin/dockerize \
 && mv /taiga-frontend/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh \
 && apk --update add --no-cache runit \
 && echo Complete!

WORKDIR /taiga-frontend
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["default"]
EXPOSE 80
