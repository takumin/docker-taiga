#
# Configuration
#

ifeq (x${LISTEN_PORT},x)
export LISTEN_PORT=8088
endif

#
# Build Arguments
#

ARGS ?= --rm=true --force-rm=true

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
all: build

#
# Build Rules
#

.PHONY: build
build: clean
	@docker build $(ARGS) -t takumi/taiga-backend .

.PHONY: release
release: clean
	@docker build $(ARGS) --no-cache=true -t takumi/taiga-backend .

#
# Clean Rules
#

.PHONY: clean
clean:
ifneq (x$(shell docker ps -aqf name=taiga-backend),x)
	@docker stop $(shell docker ps -aqf name=taiga-backend)
	@docker rm $(shell docker ps -aqf name=taiga-backend)
endif
ifneq (x$(shell docker image ls -aq takumi/taiga-backend),x)
	@docker rmi takumi/taiga-backend
endif
ifneq (x$(shell docker images -aqf "dangling=true"),x)
	@docker rmi $(shell docker images -aqf "dangling=true")
endif
	@docker system prune -f
