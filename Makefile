.PHONY: build
.PHONY: frameworks
.PHONY: xcframework

build:
	./scripts/build.sh

framework: build
	./scripts/create-framework.sh

xcframework: framework
	./scripts/create-xcframework.sh

all: build framework xcframework