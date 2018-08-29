# vim: set ft=dockerfile :

#
# Build Container
#

# FROM alpine AS build
# LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"
#
# RUN apk --update add --no-cache wget
#
# ENV DOCKERIZE_VERSION v0.6.1
# RUN wget -O- https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar -C /usr/local/bin -xzvf -
#
# COPY ./upstream /usr/local/events
# COPY ./config.json.tmpl /usr/local/events/config.json.tmpl
# COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod 0755 /usr/local/bin/entrypoint.sh

#
# Deploy Container
#

FROM alpine AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

# COPY --from=build /usr/local /usr/local
COPY ./upstream /taiga-events
COPY ./config.json.tmpl /taiga-events/config.json.tmpl
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo "Deploy Config Starting" \
 && apk --no-cache add --update nodejs runit \
 && apk --no-cache add --update --virtual .deps npm wget \
 && wget -O- https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-alpine-linux-amd64-v0.6.1.tar.gz | tar -C /usr/local/bin -xzvf - \
 && cd /taiga-events \
 && npm install --production \
 && npm install --production -g coffee-script \
 && apk --no-cache del --purge .deps \
 && rm -fr ~/.npm \
 && echo "Deploy Config Complete!"

WORKDIR /taiga-events
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8888
