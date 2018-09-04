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
	@docker exec taiga-backend django_migrate.sh

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
	@docker exec taiga-backend django_initialize.sh

.PHONY: backup
backup:
	@$(eval BACKUP_DATE := $(shell date '+%Y%m%d_%H%M%S_%3N'))
	@$(eval DATABASE_NAME := $(shell docker-compose config | grep 'POSTGRES_DB' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/ //g'))
	@$(eval DATABASE_USER := $(shell docker-compose config | grep 'POSTGRES_USER' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/ //g'))
	@$(eval DATABASE_PASS := $(shell docker-compose config | grep 'POSTGRES_PASSWORD' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/ //g'))
	@mkdir -p $(CURDIR)/recovery/$(BACKUP_DATE)
	@docker-compose stop
	@docker-compose start taiga-postgres
	@docker exec taiga-postgres nc -z -v -w10 localhost 5432
	@docker exec taiga-postgres pg_dump -U $(DATABASE_NAME) -Fc $(DATABASE_NAME) > $(CURDIR)/recovery/$(BACKUP_DATE)/postgres.custom.dump
	@docker run --rm -v taiga-backend-data:/volume:ro -v $(CURDIR)/recovery/$(BACKUP_DATE):/backup alpine tar czvf /backup/backend_media.tar.gz -C /volume/media .
	@docker-compose start

.PHONY: restore
restore:
	@$(eval RESTORE_DATE := $(shell ls $(CURDIR)/recovery | sort -V | tail -n 1))
	@$(eval DATABASE_NAME := $(shell docker-compose config | grep 'POSTGRES_DB' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/ //g'))
	@$(eval DATABASE_USER := $(shell docker-compose config | grep 'POSTGRES_USER' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/ //g'))
	@$(eval DATABASE_PASS := $(shell docker-compose config | grep 'POSTGRES_PASSWORD' | head -n 1 | awk -F ':' -- '{print $$2}' | sed -E 's/ //g'))
	@docker-compose stop
	@docker-compose up -d taiga-postgres
	@sleep 3
	@docker exec taiga-postgres nc -z -v -w10 localhost 5432
	@cat $(CURDIR)/recovery/$(RESTORE_DATE)/postgres.custom.dump | docker exec -i taiga-postgres pg_restore -v -e -U $(DATABASE_NAME) -d $(DATABASE_NAME) -Fc
	@docker run --rm -v taiga-backend-data:/volume alpine mkdir -p /volume/media
	@docker run --rm -v taiga-backend-data:/volume -v $(CURDIR)/recovery/$(RESTORE_DATE):/restore:ro alpine tar xvf /restore/backend_media.tar.gz -C /volume/media
	@docker-compose up -d

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
