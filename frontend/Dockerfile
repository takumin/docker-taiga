# vim: set ft=dockerfile :

#
# Build Container
#

FROM alpine AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN apk --update add --no-cache wget
ENV DOCKERIZE_VERSION v0.6.1
RUN wget -O- https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar -C /taiga-frontend -xzvf -
RUN chmod 0755 /taiga-frontend/dockerize

COPY ./upstream/dist /taiga-frontend
COPY ./conf.json.tmpl /taiga-frontend
COPY ./nginx.conf.tmpl /taiga-frontend
COPY ./entrypoint.sh /taiga-frontend/entrypoint.sh
RUN chmod 0755 /taiga-frontend/entrypoint.sh

#
# Deploy Container
#

FROM nginx:alpine AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

COPY --from=build /taiga-frontend /taiga-frontend

RUN echo Start! \
 && set -ex \
 && mv /taiga-frontend/dockerize /usr/local/bin/dockerize \
 && mv /taiga-frontend/entrypoint.sh /usr/local/bin/entrypoint.sh \
 && apk --update add --no-cache runit \
 && echo Complete!

WORKDIR /taiga-frontend
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8000
