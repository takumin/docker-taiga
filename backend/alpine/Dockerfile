# vim: set ft=dockerfile :

#
# Build Container
#

FROM alpine:3.8 AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN echo "Build Config Starting" \
 && apk --update add \
    gcc \
    musl-dev \
    wget \
    ca-certificates \
    git \
    python3 \
    python3-dev \
    zlib \
    zlib-dev \
    ncurses-libs \
    ncurses-dev \
    gdbm \
    gdbm-dev \
    libffi \
    libffi-dev \
    libressl \
    libressl-dev \
    libpq \
    postgresql-libs \
    postgresql-dev \
    libzmq \
    zeromq-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libpng \
    libpng-dev \
    freetype \
    freetype-dev \
    libxml2 \
    libxml2-dev \
    libxslt \
    libxslt-dev \
 && echo "Build Config Complete!"

# Installed Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Copy Source Code
COPY ./upstream /usr/local/backend

# Workaround Alpine Linux Python Prefix Install
RUN grep '^six==.*' /usr/local/backend/requirements.txt > six.txt
RUN pip3 install --install-option="--prefix=/usr/local" -r six.txt

# Workaround Alpine Linux 3.8 & LibreSSL 2.7
RUN sed -i -e 's/^cryptography==.*/cryptography==2.3.1/' /usr/local/backend/requirements.txt

# Require Proxy Environment
RUN git config --global url."https://".insteadOf git://

# Install Require Python Module
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" pip3 install --install-option="--prefix=/usr/local" -r /usr/local/backend/requirements.txt

# Cleanup Python Cache
RUN find /usr/lib -type d -name '__pycache__' | xargs rm -fr
RUN find /usr/local/lib -type d -name '__pycache__' | xargs rm -fr

# Copy Config File
COPY ./local.py.tmpl /usr/local/backend/settings/local.py.tmpl

# Copy Entrypoint Script
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

#
# Deploy Container
#

FROM alpine:3.8 AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

COPY --from=build /usr/local /usr/local

RUN echo "Deploy Config Starting" \
 && apk --no-cache --update add \
    runit \
    gettext \
    python3 \
    zlib \
    ncurses-libs \
    gdbm \
    libffi \
    libressl \
    libpq \
    libzmq \
    libjpeg-turbo \
    libpng \
    freetype \
    libxml2 \
    libxslt \
 && mv /usr/local/backend /taiga-backend \
 && echo "Deploy Config Complete!"

WORKDIR /taiga-backend
ENTRYPOINT ["entrypoint.sh"]
CMD ["default"]
EXPOSE 8080
