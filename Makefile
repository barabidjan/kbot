APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := ghcr.io/barabidjan
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



linux:
	@echo "Building Docker image for linux"
	@docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg VERSION=$(VERSION)


build_macOs: 
	@echo "Building production version macOS"
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -v -o kbot -ldflags "-X="github.com/barabidjan/kbot/cmd.appVersion=${VERSION}
macOS:
	@echo "Building Docker image for macOS"
	make build_macOs
	docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg VERSION=$(VERSION)
push_macOs:
	@echo "Pushing Docker image for macOS"
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH)	

build_windows:
	@echo "Building production version windows"
	CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -v -o kbot -ldflags "-X="github.com/barabidjan/kbot/cmd.appVersion=${VERSION}

windows:
	@echo "Building Docker image for windows"
	make build_windows
	docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg VERSION=$(VERSION)
push_windows:
	@echo "Pushing Docker image for windows"
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH)
