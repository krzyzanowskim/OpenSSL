#!/usr/bin/env bash

# Yay shell scripting! This script builds a static version of
# OpenSSL for iOS and OSX that contains code for armv6, armv7, armv7s, arm64, x86_64.

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Setup paths to stuff we need

OPENSSL_VERSION="1.1.1h"
export OPENSSL_LOCAL_CONFIG_DIR="${SCRIPT_DIR}/config"

DEVELOPER=$(xcode-select --print-path)

export IPHONEOS_DEPLOYMENT_VERSION="7.0"
IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)

IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)

OSX_SDK_VERSION=$(xcrun --sdk macosx --show-sdk-version)
export OSX_DEPLOYMENT_VERSION="10.10"
export OSX_SDK=$(xcrun --sdk macosx --show-sdk-path)

# Turn versions like 1.2.3 into numbers that can be compare by bash.
version()
{
   printf "%03d%03d%03d%03d" $(tr '.' ' ' <<<"$1");
}

BUILD_MACOS_ARM64=
BUILD_IPHONESIMULATOR_ARM64=
if [ $(version $OSX_SDK_VERSION) -ge $(version 11.0) ]; then
   BUILD_MACOS_ARM64=YES
   # BUILD_IPHONESIMULATOR_ARM64=YES
fi

configure() {
   local OS=$1
   local ARCH=$2
   local BUILD_DIR=$3
   local SRC_DIR=$4

   echo "Configuring for ${OS} ${ARCH}"

   local SDK=
   case "$OS" in
      iPhoneOS)
	 SDK="${IPHONEOS_SDK}"
	 ;;
      iPhoneSimulator)
	 SDK="${IPHONESIMULATOR_SDK}"
	 ;;
      MacOSX)
	 SDK="${OSX_SDK}"
	 ;;
      *)
	 echo "Unsupported OS '${OS}'!" >&1
	 exit 1
	 ;;
   esac

   local PREFIX="${BUILD_DIR}/${OPENSSL_VERSION}-${OS}-${ARCH}"

   export CROSS_TOP="${SDK%%/SDKs/*}"
   export CROSS_SDK="${SDK##*/SDKs/}"
   if [ -z "$CROSS_TOP" -o -z "$CROSS_SDK" ]; then
      echo "Failed to parse SDK path '${SDK}'!" >&1
      exit 2
   fi
   

   if [ "$ARCH" == "x86_64" ]; then
      if [ "$OS" == "MacOSX" ]; then
         ${SRC_DIR}/Configure darwin64-x86_64-cc no-asm no-shared no-async --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      else
         ${SRC_DIR}/Configure ios-sim-cross-$ARCH no-asm no-shared no-async --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      fi
   elif [ "$ARCH" == "i386" ]; then
      ${SRC_DIR}/Configure ios-sim-cross-$ARCH no-asm no-shared no-async --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$ARCH" == "arm64" -a "$OS" == "MacOSX" ]; then
      ${SRC_DIR}/Configure darwin64-arm64-cc no-asm no-shared no-async --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   else
      ${SRC_DIR}/Configure ios-cross-$ARCH no-asm no-shared no-async --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   fi
}

build()
{
   local ARCH=$1
   local OS=$2
   local BUILD_DIR=$3
   local TYPE=$4

   local SRC_DIR="${BUILD_DIR}/openssl-${OPENSSL_VERSION}-${TYPE}"
   local PREFIX="${BUILD_DIR}/${OPENSSL_VERSION}-${OS}-${ARCH}"

   mkdir -p "${SRC_DIR}"
   tar xzf "${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1

   echo "Building for ${OS} ${ARCH}"

   # export BUILD_TOOLS="${DEVELOPER}"

   # Change dir
   cd "${SRC_DIR}"

   # fix headers for Swift

   sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/crypto/rsa/rsa_local.h

   # -bundle and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together 
   # sed -ie "s/'-bundle'/''/g" ${SRC_DIR}/Configurations/shared-info.pl

   if [ "$OS" == "iPhoneSimulator" ]; then
      configure "${OS}" $ARCH ${BUILD_DIR} ${SRC_DIR}
   elif [ "$OS" == "iPhoneOS" ]; then
   
      configure "${OS}" $ARCH ${BUILD_DIR} ${SRC_DIR}
   elif [ "$OS" == "MacOSX" ]; then
      configure "${OS}" $ARCH ${BUILD_DIR} ${SRC_DIR}
   else
      exit 1
   fi

   LOG_PATH="${PREFIX}.build.log"
   echo "Building ${LOG_PATH}"
   make &> ${LOG_PATH}
   make install &> ${LOG_PATH}
   cd ${BASE_PWD}

   # Add arch to library
   if [ -f "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a" ]; then
      xcrun lipo "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a" "${PREFIX}/lib/libcrypto.a" -create -output "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a"
      xcrun lipo "${SCRIPT_DIR}/${TYPE}/lib/libssl.a" "${PREFIX}/lib/libssl.a" -create -output "${SCRIPT_DIR}/${TYPE}/lib/libssl.a"
   else
      cp "${PREFIX}/lib/libcrypto.a" "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a"
      cp "${PREFIX}/lib/libssl.a" "${SCRIPT_DIR}/${TYPE}/lib/libssl.a"
   fi

   mv ${PREFIX}/include/openssl/opensslconf.h ${PREFIX}/include/openssl/opensslconf-${ARCH}.h

   rm -rf "${SRC_DIR}"
}

generate_opensslconfh() {
   local OPENSSLCONF_PATH=$1
   # opensslconf.h
   echo "
/* opensslconf.h */
#if defined(__APPLE__) && defined (__x86_64__)
#include <openssl/opensslconf-x86_64.h>
#endif

#if defined(__APPLE__) && defined (__i386__)
#include <openssl/opensslconf-i386.h>
#endif

#if defined(__APPLE__) && defined (__arm__) && defined (__ARM_ARCH_7A__)
#include <openssl/opensslconf-armv7.h>
#endif

#if defined(__APPLE__) && defined (__arm__) && defined (__ARM_ARCH_7S__)
#include <openssl/opensslconf-armv7s.h>
#endif

#if defined(__APPLE__) && defined (__arm64__)
#include <openssl/opensslconf-arm64.h>
#endif

#if defined(__APPLE__) && defined (__arm64e__)
#include <openssl/opensslconf-arm64e.h>
#endif
" > ${OPENSSLCONF_PATH}
}

build_ios() {
   local TMP_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf ${SCRIPT_DIR}/{ios/include,ios/lib}
   mkdir -p ${SCRIPT_DIR}/{ios/include,ios/lib}

   build "i386" "iPhoneSimulator" ${TMP_DIR} "ios"
   build "x86_64" "iPhoneSimulator" ${TMP_DIR} "ios"
   [ -n "$BUILD_IPHONESIMULATOR_ARM64" ] && build "arm64" "iPhoneSimulator" ${TMP_DIR} "ios"
   build "armv7" "iPhoneOS" ${TMP_DIR} "ios"
   build "armv7s" "iPhoneOS" ${TMP_DIR} "ios"
   build "arm64" "iPhoneOS" ${TMP_DIR} "ios"
   build "arm64e" "iPhoneOS" ${TMP_DIR} "ios"

   # Copy headers
   cp -r ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl ${SCRIPT_DIR}/ios/include
   cp -f ${SCRIPT_DIR}/shim/shim.h ${SCRIPT_DIR}/ios/include/openssl/shim.h

   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-x86_64/include/openssl/opensslconf-x86_64.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-i386/include/openssl/opensslconf-i386.h ${SCRIPT_DIR}/ios/include/openssl
   [ -n "$BUILD_IPHONESIMULATOR_ARM64" ] && cp -f ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl/opensslconf-arm64.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneOS-armv7/include/openssl/opensslconf-armv7.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneOS-armv7s/include/openssl/opensslconf-armv7s.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl/opensslconf-arm64.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64e/include/openssl/opensslconf-arm64e.h ${SCRIPT_DIR}/ios/include/openssl

   generate_opensslconfh ${SCRIPT_DIR}/ios/include/openssl/opensslconf.h

   rm -rf ${TMP_DIR}
}

build_macos() {
   local TMP_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf ${SCRIPT_DIR}/{macos/include,macos/lib}
   mkdir -p ${SCRIPT_DIR}/{macos/include,macos/lib}

   build "x86_64" "MacOSX" ${TMP_DIR} "macos"
   [ -n "$BUILD_MACOS_ARM64" ] && build "arm64" "MacOSX" ${TMP_DIR} "macos"

   # Copy headers
   cp -r ${TMP_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl ${SCRIPT_DIR}/macos/include
   cp -f ${SCRIPT_DIR}/shim/shim.h ${SCRIPT_DIR}/macos/include/openssl/shim.h

   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl/opensslconf-x86_64.h ${SCRIPT_DIR}/macos/include/openssl
   [ -n "$BUILD_MACOS_ARM64" ] && cp -f ${TMP_DIR}/${OPENSSL_VERSION}-MacOSX-arm64/include/openssl/opensslconf-arm64.h ${SCRIPT_DIR}/macos/include/openssl

   generate_opensslconfh ${SCRIPT_DIR}/macos/include/openssl/opensslconf.h

   rm -rf ${TMP_DIR}
}

# Start

if [ ! -f "${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz" ]; then
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o ${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256" -o ${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz.sha256
   DIGEST=$( cat ${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz.sha256 )
   echo "${DIGEST} ${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum --check --strict
   rm -f ${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz.sha256
fi

build_ios
build_macos

${SCRIPT_DIR}/create-framework.sh

echo "all done"
