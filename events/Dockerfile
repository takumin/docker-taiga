# vim: set ft=dockerfile :

#
# Build Container
#

FROM alpine AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN apk --update add --no-cache nodejs npm

RUN npm install --production --prefix /usr/local -g coffee-script

COPY ./upstream /usr/local/events
RUN npm install --production --prefix /usr/local -g /usr/local/events

COPY ./config.json /usr/local/events/config.json
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
