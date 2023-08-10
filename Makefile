.PHONY: build
.PHONY: frameworks

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

all: build frameworks

build:
	OPENSSL_VERSION="1.1.1v" $(CWD)/scripts/build.sh

frameworks:
	$(CWD)/scripts/create-frameworks.sh