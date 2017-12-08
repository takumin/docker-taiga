ARGS ?= --no-cache

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

ifneq (x${NODEJS_MIRROR},x)
ARGS += --build-arg NODEJS_MIRROR=${NODEJS_MIRROR}
endif

.PHONY: build
build:
	@docker build $(ARGS) -t takumi/taiga .

.PHONY: run
run:
	@docker run --name taiga -d takumi/taiga

.PHONY: clean
clean:
	@docker image prune -f
	@docker rmi takumi/taiga
