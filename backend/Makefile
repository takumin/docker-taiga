#
# Build Arguments
#

ARGS ?=

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
build:
	@docker build $(ARGS) -t takumi/taiga-backend:latest .

.PHONY: release
release: clean
	@docker build $(ARGS) --no-cache=true -t takumi/taiga-backend .

#
# Clean Rules
#

.PHONY: clean
clean:
ifneq (x$(shell docker ps -aqf label=taiga-backend-build),x)
	@docker stop $(shell docker ps -aqf label=taiga-backend-build)
	@docker rm $(shell docker ps -aqf label=taiga-backend-build)
endif
ifneq (x$(shell docker images -aqf label=taiga-backend-build),x)
	@docker rmi $(shell docker images -aqf label=taiga-backend-build)
endif
# ifneq (x$(shell docker ps -aqf label=taiga-backend),x)
# 	@docker stop $(shell docker ps -aqf label=taiga-backend)
# 	@docker rm $(shell docker ps -aqf label=taiga-backend)
# endif
# ifneq (x$(shell docker images -aqf label=taiga-backend),x)
# 	@docker rmi $(shell docker images -aqf label=taiga-backend)
# endif
ifneq (x$(shell docker images -aqf dangling=true),x)
	@docker rmi $(shell docker images -aqf dangling=true)
endif
	@docker system prune -f
