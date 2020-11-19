#!/usr/bin/env bash

# Yay shell scripting! This script builds a static version of
# OpenSSL for iOS and OSX that contains code for armv6, armv7, armv7s, arm64, x86_64.

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Setup paths to stuff we need

OPENSSL_VERSION="1.1.1h"
export OPENSSL_LOCAL_CONFIG_DIR="${SCRIPT_DIR}/../config"

DEVELOPER=$(xcode-select --print-path)

export IPHONEOS_DEPLOYMENT_VERSION="7.0"
IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
OSX_SDK=$(xcrun --sdk macosx --show-sdk-path)

export MACOSX_DEPLOYMENT_TARGET="10.10" # 

# Turn versions like 1.2.3 into numbers that can be compare by bash.
version()
{
   printf "%03d%03d%03d%03d" $(tr '.' ' ' <<<"$1");
}

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
   

   if [ "$OS" == "MacOSX" ]; then
      if [ "$ARCH" == "x86_64" ]; then
         ${SRC_DIR}/Configure macos-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      elif [ "$ARCH" == "arm64" ]; then
         ${SRC_DIR}/Configure macos-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      fi
   elif [ "$OS" == "iPhoneSimulator" ]; then
      ${SRC_DIR}/Configure ios-sim-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "iPhoneOS" ]; then
      ${SRC_DIR}/Configure ios-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   fi
}

build()
{
   local ARCH=$1
   local OS=$2
   local BUILD_DIR=$3
   local TYPE=$4 # iphoneos/iphonesimulator/macos

   local SRC_DIR="${BUILD_DIR}/openssl-${OPENSSL_VERSION}-${TYPE}"
   local PREFIX="${BUILD_DIR}/${OPENSSL_VERSION}-${OS}-${ARCH}"

   mkdir -p "${SRC_DIR}"
   tar xzf "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1

   echo "Building for ${OS} ${ARCH}"

   # export BUILD_TOOLS="${DEVELOPER}"

   # Change dir
   cd "${SRC_DIR}"

   # fix headers for Swift

   sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/crypto/rsa/rsa_local.h

   # -bundle and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together 
   # sed -ie "s/'-bundle'/''/g" ${SRC_DIR}/Configurations/shared-info.pl

   configure "${OS}" $ARCH ${BUILD_DIR} ${SRC_DIR}

   LOG_PATH="${PREFIX}.build.log"
   echo "Building ${LOG_PATH}"
   make &> ${LOG_PATH}
   make install &> ${LOG_PATH}
   cd ${BASE_PWD}

   # Add arch to library
   if [ -f "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a" ]; then
      xcrun lipo "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a" "${PREFIX}/lib/libcrypto.a" -create -output "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a"
      xcrun lipo "${SCRIPT_DIR}/../${TYPE}/lib/libssl.a" "${PREFIX}/lib/libssl.a" -create -output "${SCRIPT_DIR}/../${TYPE}/lib/libssl.a"
   else
      cp "${PREFIX}/lib/libcrypto.a" "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a"
      cp "${PREFIX}/lib/libssl.a" "${SCRIPT_DIR}/../${TYPE}/lib/libssl.a"
   fi

   mv "${PREFIX}/include/openssl/opensslconf.h" "${PREFIX}/include/openssl/opensslconf-${ARCH}.h"

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
   local TMP_BUILD_DIR=$( mktemp -d )

   # TODO: Becasue arm64 is in iphoneos and iphonesimulator slice, it can't co-exists together in the same static library
   #       Separate iphoneos and iphonesimulator

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}

   build "i386" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"
   build "x86_64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"
   build "arm64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"

   rm -rf "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}

   build "armv7" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"
   build "armv7s" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"
   build "arm64" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"
   build "arm64e" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"

   # Copy headers
   cp -r "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl" "${SCRIPT_DIR}/../iphoneos/include"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../iphoneos/include/openssl/shim.h"

   # Copy headers
   cp -r "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl" "${SCRIPT_DIR}/../iphonesimulator/include"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../iphonesimulator/include/openssl/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../iphoneos/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;
   find "${SCRIPT_DIR}/../iphonesimulator/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;

   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-x86_64/include/openssl/opensslconf-x86_64.h "${SCRIPT_DIR}/../iphonesimulator/include/openssl"
   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-i386/include/openssl/opensslconf-i386.h "${SCRIPT_DIR}/../iphonesimulator/include/openssl"
   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl/opensslconf-arm64.h "${SCRIPT_DIR}/../iphonesimulator/include/openssl"
   
   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-armv7/include/openssl/opensslconf-armv7.h "${SCRIPT_DIR}/../iphoneos/include/openssl"
   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-armv7s/include/openssl/opensslconf-armv7s.h "${SCRIPT_DIR}/../iphoneos/include/openssl"
   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl/opensslconf-arm64.h "${SCRIPT_DIR}/../iphoneos/include/openssl"
   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64e/include/openssl/opensslconf-arm64e.h "${SCRIPT_DIR}/../iphoneos/include/openssl"

   generate_opensslconfh "${SCRIPT_DIR}/../iphoneos/include/openssl/opensslconf.h"
   generate_opensslconfh "${SCRIPT_DIR}/../iphonesimulator/include/openssl/opensslconf.h"

   rm -rf ${TMP_BUILD_DIR}
}

build_macos() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{macos/include,macos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{macos/include,macos/lib}

   build "x86_64" "MacOSX" ${TMP_BUILD_DIR} "macos"
   build "arm64" "MacOSX" ${TMP_BUILD_DIR} "macos"

   # Copy headers
   cp -r ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl "${SCRIPT_DIR}/../macos/include"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../macos/include/openssl/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../macos/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;

   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl/opensslconf-x86_64.h "${SCRIPT_DIR}/../macos/include/openssl"
   cp -f ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-arm64/include/openssl/opensslconf-arm64.h "${SCRIPT_DIR}/../macos/include/openssl"

   generate_opensslconfh "${SCRIPT_DIR}/../macos/include/openssl/opensslconf.h"

   rm -rf ${TMP_BUILD_DIR}
}

# Start

if [ ! -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" ]; then
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz"
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256" -o "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256"
   DIGEST=$( cat ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256 )

   if [[ "$(shasum -a 256 "openssl-${OPENSSL_VERSION}.tar.gz" | awk '{print $1}')" != "${DIGEST}" ]]
   then
      echo "openssl-${OPENSSL_VERSION}.tar.gz: checksum mismatch"
      exit 1
   fi
   rm -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256"
fi

build_ios
build_macos
