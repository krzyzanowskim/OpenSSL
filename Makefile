.PHONY: build
.PHONY: frameworks
.PHONY: project

.EXPORT_ALL_VARIABLES:

OPENSSL_VERSION=3.3.2
IPHONEOS_DEPLOYMENT_VERSION=12.0
MACOSX_DEPLOYMENT_TARGET=10.15
XROS_DEPLOYMENT_VERSION=1.0
APPLETVOS_DEPLOYMENT_VERSION=12.0
WATCHOS_DEPLOYMENT_VERSION=8.0

SIGNING_IDENTITY ?= "Apple Distribution: Marcin Krzyzanowski (67RAULRX93)"

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

all: project build frameworks

project:
	tuist generate --no-open --no-binary-cache -p $(CWD)

build:
	$(CWD)/scripts/build.sh

frameworks:
	$(CWD)/scripts/create-frameworks.sh $(SIGNING_IDENTITY)
