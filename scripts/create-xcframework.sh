#!/usr/bin/env bash

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

TMP_DIR=$( mktemp -d )

extract_arch()
{
    local PLATFORM=$1
    local ARCH=$2
    local EXTRACT=$3

    mkdir -p ${TMP_DIR}/${PLATFORM}/${ARCH}
    cp -r "${SCRIPT_DIR}/../Frameworks/${PLATFORM}/OpenSSL.framework" ${TMP_DIR}/${PLATFORM}/${ARCH}
    rm ${TMP_DIR}/${PLATFORM}/${ARCH}/OpenSSL.framework/OpenSSL
    lipo ${EXTRACT} -output ${TMP_DIR}/${PLATFORM}/${ARCH}/OpenSSL.framework/OpenSSL "${SCRIPT_DIR}/../Frameworks/${PLATFORM}/OpenSSL.framework/OpenSSL"
}

extract_arch "ios" "iphoneos" "-extract armv7 -extract arm64"
extract_arch "ios" "iphonesimulator" "-extract i386 -extract x86_64 -extract arm64"
extract_arch "macos" "combined" "-extract arm64 -extract x86_64"

rm -rf "${SCRIPT_DIR}/../Frameworks/OpenSSL.xcframework"

xcrun xcodebuild -create-xcframework \
    -framework "${TMP_DIR}/ios/iphoneos/OpenSSL.framework" \
    -framework "${TMP_DIR}/ios/iphonesimulator/OpenSSL.framework" \
    -framework "${TMP_DIR}/macos/combined/OpenSSL.framework" \
    -output "${SCRIPT_DIR}/../Frameworks/OpenSSL.xcframework"

rm -rf ${TMP_DIR}