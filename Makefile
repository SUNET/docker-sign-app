VERSION := 1.0.0
EIDAS_BUILD_ARGS := "--you --forgot --username --and --passw"
-include local.mk

all: build push

build: 
	./build.sh $(EIDAS_BUILD_ARGS) --version $(VERSION) -i docker-sign-sp --tag $(VERSION)

push:
	docker tag docker-sign-sp:$(VERSION) docker.sunet.se/docker-sign-sp:$(VERSION)
	docker push docker.sunet.se/docker-sign-sp:$(VERSION)
