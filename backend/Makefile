#
# Environment Variables
#

BUILD_ARGS ?=

ifneq (x${NO_PROXY},x)
BUILD_ARGS += --build-arg NO_PROXY=${NO_PROXY}
endif

ifneq (x${FTP_PROXY},x)
BUILD_ARGS += --build-arg FTP_PROXY=${FTP_PROXY}
endif

ifneq (x${HTTP_PROXY},x)
BUILD_ARGS += --build-arg HTTP_PROXY=${HTTP_PROXY}
endif

ifneq (x${HTTPS_PROXY},x)
BUILD_ARGS += --build-arg HTTPS_PROXY=${HTTPS_PROXY}
endif

ifneq (x${UBUNTU_MIRROR},x)
BUILD_ARGS += --build-arg UBUNTU_MIRROR=${UBUNTU_MIRROR}
endif

TEST_ARGS ?=
TEST_ARGS += -e TAIGA_BACKEND_SECRET_KEY="taiga"
TEST_ARGS += -e TAIGA_BACKEND_POSTGRESQL_HOST="localhost"
TEST_ARGS += -e TAIGA_BACKEND_POSTGRESQL_PORT="5432"
TEST_ARGS += -e TAIGA_BACKEND_POSTGRESQL_NAME="taiga"
TEST_ARGS += -e TAIGA_BACKEND_POSTGRESQL_USER="taiga"
TEST_ARGS += -e TAIGA_BACKEND_POSTGRESQL_PASS="taiga"
TEST_ARGS += -e TAIGA_BACKEND_RABBITMQ_USER="taiga"
TEST_ARGS += -e TAIGA_BACKEND_RABBITMQ_PASS="taiga"
TEST_ARGS += -e TAIGA_BACKEND_RABBITMQ_HOST="localhost"
TEST_ARGS += -e TAIGA_BACKEND_RABBITMQ_PORT="4396"
TEST_ARGS += -e TAIGA_BACKEND_RABBITMQ_PATH=""
TEST_ARGS += -e TAIGA_BACKEND_SITES_API_SCHEME="http"
TEST_ARGS += -e TAIGA_BACKEND_SITES_API_DOMAIN="localhost"
TEST_ARGS += -e TAIGA_BACKEND_SITES_API_PORT="8000"
TEST_ARGS += -e TAIGA_BACKEND_SITES_FRONT_SCHEME="http"
TEST_ARGS += -e TAIGA_BACKEND_SITES_FRONT_DOMAIN="localhost"
TEST_ARGS += -e TAIGA_BACKEND_SITES_FRONT_PORT="9000"
TEST_ARGS += -e TAIGA_BACKEND_MEDIA_URL="http://localhost/media/"
TEST_ARGS += -e TAIGA_BACKEND_STATIC_URL="http://localhost/static/"

#
# Default Rules
#

.PHONY: all
all: build

#
# Build Rules
#

.PHONY: build
build:
	@docker build $(BUILD_ARGS) --target build -t takumi/taiga-backend:build .
	@docker build $(BUILD_ARGS) -t takumi/taiga-backend:latest .

.PHONY: release
release: clean-all
	@docker build $(BUILD_ARGS) --no-cache=true --target build -t takumi/taiga-backend:build .
	@docker build $(BUILD_ARGS) --no-cache=true -t takumi/taiga-backend:latest .

#
# Test Rules
#
.PHONY: test
test:
	@docker run $(TEST_ARGS) takumi/taiga-backend:latest

#
# Clean Rules
#

.PHONY: clean
clean:
ifneq (x$(shell docker ps -aqf "status=exited"),x)
	@docker rm $(shell docker ps -aqf "status=exited")
endif
ifneq (x$(shell docker images -aqf "dangling=true"),x)
	@docker rmi $(shell docker images -aqf "dangling=true")
endif
	@docker system prune -f

.PHONY: clean-build
clean-build:
ifneq (x$(shell docker ps -aqf "label=taiga-backend-build"),x)
	docker stop $(shell docker ps -aqf "label=taiga-backend-build")
	docker rm $(shell docker ps -aqf "label=taiga-backend-build")
endif
ifneq (x$(shell docker images -aq "takumi/taiga-backend:build"),x)
	docker rmi $(shell docker images -aq "takumi/taiga-backend:build")
endif

.PHONY: clean-latest
clean-latest:
ifneq (x$(shell docker ps -aqf "label=taiga-backend"),x)
	docker stop $(shell docker ps -aqf "label=taiga-backend")
	docker rm $(shell docker ps -aqf "label=taiga-backend")
endif
ifneq (x$(shell docker images -aq "takumi/taiga-backend:latest"),x)
	docker rmi $(shell docker images -aq "takumi/taiga-backend:latest")
endif

.PHONY: clean-all
clean-all: clean-build clean-latest clean
