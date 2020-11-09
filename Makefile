.PHONY: build_script
.PHONY: create_framework

build_script:
	./scripts/build.sh

create_framework: build_script
	./scripts/create_framework

all: build_script create_framework