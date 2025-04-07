.PHONY: build
.PHONY: frameworks
.PHONY: project
.PHONY: check-signing-identity
.PHONY: debug-signing
.PHONY: all

.EXPORT_ALL_VARIABLES:

OPENSSL_VERSION=3.3.3
MARKETING_VERSION=3.3.3001
IPHONEOS_DEPLOYMENT_VERSION=12.0
MACOSX_DEPLOYMENT_TARGET=10.15
XROS_DEPLOYMENT_VERSION=1.0
APPLETVOS_DEPLOYMENT_VERSION=12.0
WATCHOS_DEPLOYMENT_VERSION=8.0

# Store the filtered output of security command in a file for processing
TEMP_IDENTITIES_FILE := $(shell mktemp)
SECURITY_OUTPUT := $(shell security find-identity -v -p codesigning | grep "Apple Distribution" | sort -u > $(TEMP_IDENTITIES_FILE))

# Count unique identity names (not hashes)
APPLE_DIST_COUNT := $(shell cut -d '"' -f 2 $(TEMP_IDENTITIES_FILE) | sort -u | wc -l | tr -d ' ')

# Determine if SIGNING_IDENTITY was explicitly set or needs to be auto-detected
ifndef SIGNING_IDENTITY
    # If exactly one identity name is found, use it for auto-detection
    ifeq ($(APPLE_DIST_COUNT),1)
        SIGNING_IDENTITY := $(shell cut -d '"' -f 2 $(TEMP_IDENTITIES_FILE) | sort -u)
    endif
endif

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

# Make check-signing-identity the first task for 'all' only
all: check-signing-identity project build frameworks

project:
ifdef SIGNING_IDENTITY
    # Extract team ID from signing identity
	$(eval TEAM_ID := $(shell echo "$(SIGNING_IDENTITY)" | grep -o '([A-Z0-9]\+)' | tr -d '()'))
    # Verify team ID was extracted
	@if [ -z "$(TEAM_ID)" ]; then \
		echo "Error: Could not extract Team ID from signing identity: $(SIGNING_IDENTITY)"; \
		echo "The signing identity must be in the format 'Apple Distribution: Name (TEAMID)'"; \
		exit 1; \
	fi

	TUIST_DEVELOPMENT_TEAM="$(TEAM_ID)" TUIST_MARKETING_VERSION="$(MARKETING_VERSION)" tuist generate --no-open --no-binary-cache -p $(CWD)
else
	@echo "Error: SIGNING_IDENTITY is not set. Cannot update Project.swift."
	@exit 1
endif

build:
	$(CWD)/scripts/build.sh

frameworks:
	$(CWD)/scripts/create-frameworks.sh "$(SIGNING_IDENTITY)"

# Validation target to check signing identity
check-signing-identity:
ifdef SIGNING_IDENTITY
    # Check if manually specified identity exists
	@if ! security find-identity -v -p codesigning | grep -q "$(SIGNING_IDENTITY)"; then \
		echo "Error: The specified signing identity does not exist in keychain:"; \
		echo "\"$(SIGNING_IDENTITY)\""; \
		echo ""; \
		echo "Available Apple Distribution identities:"; \
		cat $(TEMP_IDENTITIES_FILE) || echo "None found"; \
		exit 1; \
	fi
    
    # Extract and verify team ID
	$(eval TEAM_ID := $(shell echo "$(SIGNING_IDENTITY)" | grep -o '([A-Z0-9]\+)' | tr -d '()'))
	@if [ -z "$(TEAM_ID)" ]; then \
		echo "Error: Could not extract Team ID from signing identity: $(SIGNING_IDENTITY)"; \
		echo "The signing identity must be in the format 'Apple Distribution: Name (TEAMID)'"; \
		exit 1; \
	fi
    
	@echo "Using signing identity: $(SIGNING_IDENTITY)"
	@echo "Team ID: $(TEAM_ID)"
else
    # No identity specified or auto-detected
	@echo "Error: No signing identity specified or auto-detected."
	@echo "Available Apple Distribution identities:"
	@cat $(TEMP_IDENTITIES_FILE) || echo "None found"
	@echo ""
	@echo "Please specify which one to use by setting SIGNING_IDENTITY, for example:"
	@echo "make SIGNING_IDENTITY=\"Apple Distribution: YourCompany (TEAMID)\""
	@exit 1
endif

# Debug target to show signing info
debug-signing:
	@echo "Number of unique Apple Distribution identities: $(APPLE_DIST_COUNT)"
	@echo "Available identities (duplicates filtered):"
	@cat $(TEMP_IDENTITIES_FILE)
	@echo ""
	@echo "Currently selected identity: $(SIGNING_IDENTITY)"
ifdef SIGNING_IDENTITY
	$(eval TEAM_ID := $(shell echo "$(SIGNING_IDENTITY)" | grep -o '([A-Z0-9]\+)' | tr -d '()'))
	@if [ -n "$(TEAM_ID)" ]; then \
		echo "Team ID: $(TEAM_ID)"; \
	else \
		echo "Warning: Could not extract Team ID from signing identity"; \
	fi
endif