#!/usr/bin/env bash

# Yay shell scripting! This script builds a static version of
# OpenSSL for iOS and OSX that contains code for armv6, armv7, armv7s, arm64, x86_64.

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Setup paths to stuff we need

OPENSSL_VERSION="1.0.2u"
export OPENSSL_LOCAL_CONFIG_DIR="${SCRIPT_DIR}/../config"

DEVELOPER=$(xcode-select --print-path)

export IPHONEOS_DEPLOYMENT_VERSION="11.0"
DEPLOYMENT_VERSION=$IPHONEOS_DEPLOYMENT_VERSION
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
      ${SRC_DIR}/Configure darwin64-x86_64-cc no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      sed -ie "s!^CFLAG=!CFLAG=-mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -fembed-bitcode -arch $ARCH !" "${SRC_DIR}/Makefile"
      sed -ie "s!^CFLAGS=!CFLAGS=-mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -fembed-bitcode -arch $ARCH !" "${SRC_DIR}/Makefile"
   elif [ "$OS" == "iPhoneSimulator" ]; then
      if [ "$ARCH" == "i386" ]; then
         ${SRC_DIR}/Configure iphoneos-cross no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      else
         ${SRC_DIR}/Configure iphoneos-cross no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      fi

      sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -mios-simulator-version-min=${IPHONEOS_DEPLOYMENT_VERSION} -fembed-bitcode -arch ${ARCH} !" "${SRC_DIR}/Makefile"
      sed -ie "s!^CFLAGS=!CFLAGS=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -mios-simulator-version-min=${IPHONEOS_DEPLOYMENT_VERSION} -fembed-bitcode -arch ${ARCH} !" "${SRC_DIR}/Makefile"
      perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' ${SRC_DIR}/crypto/ui/ui_openssl.c
   elif [ "$OS" == "iPhoneOS" ]; then
      ${SRC_DIR}/Configure iphoneos-cross no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
      sed -ie "s!^CFLAG=!CFLAG=-miphoneos-version-min=${DEPLOYMENT_VERSION} -fembed-bitcode -arch ${ARCH} !" "${SRC_DIR}/Makefile"
      sed -ie "s!^CFLAGS=!CFLAGS=-miphoneos-version-min=${DEPLOYMENT_VERSION} -fembed-bitcode -arch ${ARCH} !" "${SRC_DIR}/Makefile"
      perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' ${SRC_DIR}/crypto/ui/ui_openssl.c
   fi
}

build()
{
   local ARCH=$1
   local OS=$2
   local BUILD_DIR=$3
   local TYPE=$4 # iphoneos/iphonesimulator/macosx

   local SRC_DIR="${BUILD_DIR}/openssl-${OPENSSL_VERSION}-${TYPE}"
   local PREFIX="${BUILD_DIR}/${OPENSSL_VERSION}-${OS}-${ARCH}"

   mkdir -p "${SRC_DIR}"
   tar xzf "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1

   echo "Building for ${OS} ${ARCH}"

   # Change dir
   cd "${SRC_DIR}"

   # fix headers for Swift

   sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/crypto/rsa/rsa.h

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

   rm -rf "${SRC_DIR}"
}

build_ios() {
#   local TMP_BUILD_DIR=$( mktemp -d )
   local TMP_BUILD_DIR="${SCRIPT_DIR}/../build/"

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}

   build "x86_64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"
   build "arm64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"

   rm -rf "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}

   build "arm64" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"

   # Copy headers
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl" "${SCRIPT_DIR}/../iphoneos/include/openssl"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../iphoneos/include/openssl/shim.h"

   # Copy headers
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl" "${SCRIPT_DIR}/../iphonesimulator/include/openssl"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../iphonesimulator/include/openssl/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../iphoneos/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;
   find "${SCRIPT_DIR}/../iphonesimulator/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;

   # fix RC4_INT redefinition
   # find "${SCRIPT_DIR}/../iphoneos/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/\#define RC4_INT unsigned char/\#if \!defined(RC4_INT)\n#define RC4_INT unsigned char\n\#endif\n/g" {} \;
   # find "${SCRIPT_DIR}/../iphonesimulator/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/\#define RC4_INT unsigned char/\#if \!defined(RC4_INT)\n#define RC4_INT unsigned char\n\#endif\n/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../iphonesimulator/include/openssl/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   OPENSSLCONF_PATH="${SCRIPT_DIR}/../iphoneos/include/openssl/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

#   rm -rf ${TMP_BUILD_DIR}
}

build_macos() {
   local TMP_BUILD_DIR="${SCRIPT_DIR}/../build/"

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{macosx/include,macosx/lib}
   mkdir -p "${SCRIPT_DIR}"/../{macosx/include,macosx/lib}

   build "x86_64" "MacOSX" ${TMP_BUILD_DIR} "macosx"

   # Copy headers
   ditto ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl "${SCRIPT_DIR}/../macosx/include/openssl"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../macosx/include/openssl/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../macosx/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;

   # fix RC4_INT redefinition
   # find "${SCRIPT_DIR}/../macosx/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/\#define RC4_INT unsigned char/\#if \!defined(RC4_INT)\n#define RC4_INT unsigned char\n\#endif\n/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../macosx/include/openssl/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

#   rm -rf ${TMP_BUILD_DIR}
}

# Start

if [ ! -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" ]; then
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256" -o ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256
   DIGEST=$( cat ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256 )
   echo "${DIGEST} ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum --check --strict
   rm -f ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256
fi

build_ios
#build_macos
