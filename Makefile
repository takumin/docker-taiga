ifeq (x${TAIGA_EVENTS_PORT},x)
export TAIGA_EVENTS_PORT=8888
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
	@while true; do echo Waiting... && curl -s -o /dev/null http://localhost:${TAIGA_EVENTS_PORT} && break || sleep 3; done

.PHONY: down
down:
	@docker-compose down

.PHONY: clean
clean:
ifneq (x$(shell docker ps -aq),x)
	@docker stop $(shell docker ps -aq)
	@docker rm $(shell docker ps -aq)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-front),x)
	@docker rmi takumi/taiga-front
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-events),x)
	@docker rmi takumi/taiga-events
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-back),x)
	@docker rmi takumi/taiga-back
endif
	@docker system prune -f
