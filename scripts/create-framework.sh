#!/usr/bin/env bash

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
FWNAME="OpenSSL"

# Laverage Carthage to build frameworks

BUILD_DIR=$( mktemp -d )
echo ${BUILD_DIR}

# Build

cd ${BUILD_DIR}
carthage build --configuration Release --no-use-binaries --no-skip-current --derived-data "${BUILD_DIR}/DerivedData" --project-directory "${SCRIPT_DIR}/.."
rm -rf ${BUILD_DIR}
cd ${BASE_PWD}

rm -rf Frameworks/{ios,macos}/${FWNAME}.framework*
mkdir -p Frameworks/{ios,macos}

mv -f Carthage/Build/iOS/${FWNAME}.framework Frameworks/ios
mv -f Carthage/Build/iOS/${FWNAME}.framework.dSYM Frameworks/ios

mv -f Carthage/Build/Mac/${FWNAME}.framework Frameworks/macos
mv -f Carthage/Build/Mac/${FWNAME}.framework.dSYM Frameworks/macos

# Cleanup
rm -rf Carthage
rm -rf DerivedData