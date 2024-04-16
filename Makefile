.PHONY: build
.PHONY: frameworks

.EXPORT_ALL_VARIABLES:

OPENSSL_VERSION=3.1.5
IPHONEOS_DEPLOYMENT_VERSION=12.0
MACOSX_DEPLOYMENT_TARGET=10.15

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

all: build frameworks

build:
	$(CWD)/scripts/build.sh

frameworks:
	$(CWD)/scripts/create-frameworks.sh "Apple Distribution"