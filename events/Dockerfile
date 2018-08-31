# vim: set ft=dockerfile :

#
# Build Container
#

FROM alpine AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN apk --update add --no-cache nodejs npm wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY ./upstream /usr/local/events
WORKDIR /usr/local/events
RUN npm install --production
RUN npm install --production --prefix=/usr/local -g coffee-script

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
 && apk --no-cache add --update nodejs runit \
 && echo "Deploy Config Complete!"

WORKDIR /taiga-events
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8888
