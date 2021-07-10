.PHONY: build
.PHONY: frameworks

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

build:
	$(CWD)/scripts/build.sh

frameworks:
	$(CWD)/scripts/create-frameworks.sh

all: build frameworks
