#
# Default Rules
#

.PHONY: all
all: up

#
# Test Rules
#

.PHONY: up
up:
	@docker-compose up -d

.PHONY: migrate
migrate:
ifeq (x$(shell docker-compose config | grep 'FRONTEND_LISTEN_SSL' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/"//g; s/ //g')x,xtruex)
	@$(eval WAIT_HOST := $(shell docker-compose config | grep 'FRONTEND_LISTEN_HOST' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@$(eval WAIT_PORT := $(shell docker-compose config | grep 'FRONTEND_LISTEN_PORT' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@while true; do echo uWSGI HTTP Listen Waiting... && curl -I -s -o /dev/null https://$(WAIT_HOST):$(WAIT_PORT) && break || sleep 3; done
else
	@$(eval WAIT_HOST := $(shell docker-compose config | grep 'FRONTEND_LISTEN_HOST' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@$(eval WAIT_PORT := $(shell docker-compose config | grep 'FRONTEND_LISTEN_PORT' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@while true; do echo uWSGI HTTP Listen Waiting... && curl -I -s -o /dev/null http://$(WAIT_HOST):$(WAIT_PORT) && break || sleep 3; done
endif
	@docker exec taiga-test-backend django_migrate.sh

.PHONY: initialize
initialize:
ifeq (x$(shell docker-compose config | grep 'FRONTEND_LISTEN_SSL' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/"//g; s/ //g')x,xtruex)
	@$(eval WAIT_HOST := $(shell docker-compose config | grep 'FRONTEND_LISTEN_HOST' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@$(eval WAIT_PORT := $(shell docker-compose config | grep 'FRONTEND_LISTEN_PORT' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@while true; do echo uWSGI HTTP Listen Waiting... && curl -I -s -o /dev/null https://$(WAIT_HOST):$(WAIT_PORT) && break || sleep 3; done
else
	@$(eval WAIT_HOST := $(shell docker-compose config | grep 'FRONTEND_LISTEN_HOST' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@$(eval WAIT_PORT := $(shell docker-compose config | grep 'FRONTEND_LISTEN_PORT' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E "s/'//g; s/ //g"))
	@while true; do echo uWSGI HTTP Listen Waiting... && curl -I -s -o /dev/null http://$(WAIT_HOST):$(WAIT_PORT) && break || sleep 3; done
endif
	@docker exec taiga-test-backend django_initialize.sh

.PHONY: down
down:
ifneq (x$(shell docker-compose --log-level ERROR ps -q),x)
	@docker-compose down
endif

#
# Clean Rules
#

.PHONY: clean
clean:
	@docker system prune -f
	@docker volume prune -f
