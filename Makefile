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

.PHONY: all
all: up

.PHONY: build
build:
	@docker-compose build

.PHONY: up
up:
	@docker-compose up -d --build
	@echo "Boot Wait..."
	@while true; do echo Waiting taiga-front... && curl -s -I -o /dev/null http://localhost:${TAIGA_FRONTEND_PORT} && break || sleep 1; done
	@while true; do echo Waiting taiga-events... && curl -s -I -o /dev/null http://localhost:${TAIGA_EVENTS_PORT} && break || sleep 1; done
	@while true; do echo Waiting taiga-events... && curl -s -I -o /dev/null http://localhost:${TAIGA_BACKEND_PORT} && break || sleep 1; done

.PHONY: down
down:
	@docker-compose down

.PHONY: clean
clean:
	@docker system prune -f
ifneq (x$(shell docker images -aqf "dangling=true"),x)
	@docker rmi $(shell docker images -aqf "dangling=true")
endif

.PHONY: clean-frontend
clean-frontend:
ifneq (x$(shell docker ps -aqf name=taiga-frontend),x)
	@docker stop $(shell docker ps -aqf taiga-frontend)
	@docker rm $(shell docker ps -aqf taiga-frontend)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-frontend),x)
	@docker rmi takumi/taiga-frontend
endif

.PHONY: clean-events
clean-events:
ifneq (x$(shell docker ps -aqf name=taiga-events),x)
	@docker stop $(shell docker ps -aqf taiga-events)
	@docker rm $(shell docker ps -aqf taiga-events)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-events),x)
	@docker rmi takumi/taiga-events
endif

.PHONY: clean-backend
clean-backend:
ifneq (x$(shell docker ps -aqf name=taiga-backend),x)
	@docker stop $(shell docker ps -aqf taiga-backend)
	@docker rm $(shell docker ps -aqf taiga-backend)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-backend),x)
	@docker rmi takumi/taiga-backend
endif
