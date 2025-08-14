APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := apr1ori
VERSION := $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)



format: 
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

clean:
	rm -rf kbot
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGET_ARCH}
get:
	go get

TARGETOS=linux #darwin windows linux
TARGETARCH=arm64 #adm64

get:
	go get

build: format
	@echo "Building production version..."
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/barabidjan/kbot/cmd.appVersion=${VERSION}

image:
	@echo "Building Docker image..."
	@docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg VERSION=$(VERSION)

push:
	@echo "Pushing Docker image..."
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

