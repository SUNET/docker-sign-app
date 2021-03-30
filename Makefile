VERSION := 1.1.0
EIDAS_BUILD_ARGS := "--you --forgot --username --and --passw"
-include local.mk

all: build push

build: 
	./build.sh $(EIDAS_BUILD_ARGS) --version $(VERSION) -i upload-sign-app --tag $(VERSION)

push:
	docker tag upload-sign-app:$(VERSION) docker.sunet.se/upload-sign-app:$(VERSION)
	docker push docker.sunet.se/upload-sign-app:$(VERSION)
