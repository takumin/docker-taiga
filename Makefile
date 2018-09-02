#
# Default Rules
#

.PHONY: all
all: up

#
# Test Rules
#

.PHONY: up
up: down
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
clean: down
	@docker system prune -f
	@docker volume prune -f
