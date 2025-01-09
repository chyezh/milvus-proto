GO		?= go
PWD 	:= $(shell pwd)
GOPATH 	:= $(shell $(GO) env GOPATH)
PROTOC	:= $(shell which protoc)
PROTOC_VER := $(shell protoc --version)
INSTALL_PATH := $(PWD)/bin

all: generate-proto-api generate-proto-internal

build:
	@(env bash $(PWD)/scripts/core_build.sh)

install-proto: build
	@echo "Installing protoc-gen-go to ./bin" && GOBIN=$(INSTALL_PATH) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.33.0
	@echo "Installing protoc-gen-go-grpc to ./bin" && GOBIN=$(INSTALL_PATH)  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0

generate-proto-api: install-proto
	@echo "Generating api proto files"
	@(env bash $(PWD)/scripts/proto_gen_go_api.sh $(INSTALL_PATH))

generate-proto-internal: install-proto
	@echo "Generating internal proto files"
#	 @export protoc=${PWD}/cmake-build/protobuf/protobuf-build/protoc
	@(env bash $(PWD)/scripts/proto_gen_go_internal.sh $(INSTALL_PATH))

clean:
	@echo "Cleaning up all the generated files"
	@rm -rf cmake-build