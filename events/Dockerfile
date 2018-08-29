# vim: set ft=dockerfile :

#
# Build Container
#

FROM alpine AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN apk --update add --no-cache nodejs npm wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget -O- https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar -C /usr/local/bin -xzvf -

COPY ./upstream events
RUN npm install --production --prefix /usr/local -g events
RUN npm install --production --prefix /usr -g coffee-script
RUN coffee -o /usr/local/events -c events

COPY ./config.json.tmpl /usr/local/events/config.json.tmpl
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

#
# Deploy Container
#

FROM alpine AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

COPY --from=build /usr/local /usr/local

RUN echo "Deploy Config Starting" \
 && mv /usr/local/events /taiga-events \
 && apk --update add --no-cache nodejs runit \
 && echo "Deploy Config Complete!"

WORKDIR /taiga-events
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8888
