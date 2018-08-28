#
# Configuration
#

ifeq (x${TAIGA_FRONTEND_PORT},x)
export TAIGA_FRONTEND_PORT=8880
endif

ifeq (x${TAIGA_EVENTS_PORT},x)
export TAIGA_EVENTS_PORT=8888
endif

ifeq (x${TAIGA_BACKEND_PORT},x)
export TAIGA_BACKEND_PORT=8088
endif

ifeq (x${TAIGA_FRONTEND_EVENTS_BASE_URI},x)
export TAIGA_FRONTEND_EVENTS_BASE_URI=http://$(shell hostname):${TAIGA_EVENTS_PORT}/api/v1/
endif

ifeq (x${TAIGA_FRONTEND_BACKEND_BASE_URI},x)
export TAIGA_FRONTEND_BACKEND_BASE_URI=ws://$(shell hostname):${TAIGA_BACKEND_PORT}/events
endif

ifeq (x${TAIGA_EVENTS_SECRET},x)
export TAIGA_EVENTS_SECRET=$(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
endif

#
# Build Arguments
#

ARGS ?= --rm --force-rm

ifneq (x${NO_PROXY},x)
ARGS += --build-arg NO_PROXY=${NO_PROXY}
endif

ifneq (x${FTP_PROXY},x)
ARGS += --build-arg FTP_PROXY=${FTP_PROXY}
endif

ifneq (x${HTTP_PROXY},x)
ARGS += --build-arg HTTP_PROXY=${HTTP_PROXY}
endif

ifneq (x${HTTPS_PROXY},x)
ARGS += --build-arg HTTPS_PROXY=${HTTPS_PROXY}
endif

ifneq (x${UBUNTU_MIRROR},x)
ARGS += --build-arg UBUNTU_MIRROR=${UBUNTU_MIRROR}
endif

#
# Default Rules
#

.PHONY: all
all: up

#
# Common Rules
#

.PHONY: up
up:
	@docker-compose up -d --build

.PHONY: down
down:
	@docker-compose down

#
# Build Rules
#

.PHONY: build
build: build-frontend build-events build-backend

.PHONY: build-frontend
build-frontend: clean-frontend
	@docker build $(ARGS) -f Dockerfile.frontend -t takumi/taiga-frontend .

.PHONY: build-events
build-events: clean-events
	@docker build $(ARGS) -f Dockerfile.events -t takumi/taiga-events .

.PHONY: build-backend
build-backend: clean-backend
	@docker build $(ARGS) -f Dockerfile.backend -t takumi/taiga-backend .

#
# Clean Rules
#

.PHONY: clean
clean: clean-frontend clean-events clean-backend
	@docker system prune -f
ifneq (x$(shell docker images -aqf "dangling=true"),x)
	@docker rmi $(shell docker images -aqf "dangling=true")
endif

.PHONY: clean-frontend
clean-frontend:
ifneq (x$(shell docker ps -aqf name=taiga-frontend),x)
	@docker stop $(shell docker ps -aqf name=taiga-frontend)
	@docker rm $(shell docker ps -aqf name=taiga-frontend)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-frontend),x)
	@docker rmi takumi/taiga-frontend
endif

.PHONY: clean-events
clean-events:
ifneq (x$(shell docker ps -aqf name=taiga-events),x)
	@docker stop $(shell docker ps -aqf name=taiga-events)
	@docker rm $(shell docker ps -aqf name=taiga-events)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-events),x)
	@docker rmi takumi/taiga-events
endif

.PHONY: clean-backend
clean-backend:
ifneq (x$(shell docker ps -aqf name=taiga-backend),x)
	@docker stop $(shell docker ps -aqf name=taiga-backend)
	@docker rm $(shell docker ps -aqf name=taiga-backend)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-backend),x)
	@docker rmi takumi/taiga-backend
endif
