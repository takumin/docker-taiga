# vim: set ft=dockerfile :

#
# Build Container
#

FROM alpine:3.8 AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN echo "Build Config Starting" \
 && apk --update add \
    gettext \
    gcc \
    musl-dev \
    linux-headers \
    wget \
    ca-certificates \
    git \
    python3 \
    python3-dev \
    zlib \
    zlib-dev \
    ncurses-libs \
    ncurses-dev \
    pcre2 \
    libpcre2-16 \
    libpcre2-32 \
    pcre2-dev \
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

# Require Proxy Environment
RUN git config --global url."https://".insteadOf git://

# Workaround Minimum Install
RUN grep '^six==.*' /usr/local/backend/requirements.txt > six.txt
RUN pip3 install --no-cache-dir --install-option="--prefix=/usr/local" -r six.txt

# Workaround Running Celery
RUN sed -i -e 's/^celery==.*/celery[redis]==4.2.1/' /usr/local/backend/requirements.txt
RUN sed -i -e 's/^kombu==.*/kombu==4.2.1/' /usr/local/backend/requirements.txt

# Workaround Running uWSGI
RUN sed -i -e '/^gunicorn==.*/d' /usr/local/backend/requirements.txt

# Workaround Alpine Linux 3.8 & LibreSSL 2.7
RUN sed -i -e 's/^cryptography==.*/cryptography==2.3.1/' /usr/local/backend/requirements.txt

# Install Require Python Module
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" pip3 --no-cache-dir install --install-option="--prefix=/usr/local" -r /usr/local/backend/requirements.txt

# Workaround Running uWSGI
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" pip3 --no-cache-dir install --install-option="--prefix=/usr/local" uwsgi

# Compile Static Files
RUN cp -r /usr/local/backend /build
WORKDIR /build
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" python3 manage.py compilemessages
RUN env PYTHONPATH="/usr/local/lib/python3.6/site-packages" python3 manage.py collectstatic --noinput

# Cleanup Python Cache
RUN find /usr/lib -type d -name '__pycache__' | xargs rm -fr
RUN find /usr/local/lib -type d -name '__pycache__' | xargs rm -fr

# Copy Config File
COPY ./local.py.tmpl /usr/local/backend/settings/local.py.tmpl
COPY ./celery_local.py.tmpl /usr/local/backend/settings/celery_local.py.tmpl

# Copy Entrypoint Script
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

#
# Deploy Container
#

FROM alpine:3.8 AS prod
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

COPY --from=build /usr/local /usr/local

RUN echo "Deploy Config Starting" \
 && apk --no-cache --update add \
    runit \
    python3 \
    zlib \
    ncurses-libs \
    pcre2 \
    libpcre2-16 \
    libpcre2-32 \
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
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["taiga-backend"]
EXPOSE 8000 8080 8888
