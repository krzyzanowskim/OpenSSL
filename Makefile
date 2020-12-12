.PHONY: build
.PHONY: frameworks

build:
	./scripts/build.sh

frameworks:
	./scripts/create-frameworks.sh

all: build frameworks
