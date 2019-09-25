#!/usr/bin/env bash

# Yay shell scripting! This script builds a static version of
# OpenSSL ${OPENSSL_VERSION} for iOS and OSX that contains code for armv6, armv7, armv7s, arm64, x86_64.

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Setup paths to stuff we need

OPENSSL_VERSION="1.0.2t"

DEVELOPER=$(xcode-select --print-path)

IPHONEOS_SDK_VERSION=$(xcrun --sdk iphoneos --show-sdk-version)
IPHONEOS_DEPLOYMENT_VERSION="6.0"
IPHONEOS_PLATFORM=$(xcrun --sdk iphoneos --show-sdk-platform-path)
IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)

IPHONESIMULATOR_PLATFORM=$(xcrun --sdk iphonesimulator --show-sdk-platform-path)
IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)

OSX_SDK_VERSION=$(xcrun --sdk macosx --show-sdk-version)
OSX_DEPLOYMENT_VERSION="10.8"
OSX_PLATFORM=$(xcrun --sdk macosx --show-sdk-platform-path)
OSX_SDK=$(xcrun --sdk macosx --show-sdk-path)

configure() {
   local OS=$1
   local ARCH=$2
   local PLATFORM=$3
   local SDK_VERSION=$4
   local DEPLOYMENT_VERSION=$5
   local BUILD_DIR=$6
   local SRC_DIR=$7

   echo "Configuring for ${PLATFORM##*/} ${ARCH}"

   export CROSS_TOP="${PLATFORM}/Developer"
   export CROSS_SDK="${OS}${SDK_VERSION}.sdk"

   if [ "$ARCH" == "x86_64" ]; then
       ${SRC_DIR}/Configure darwin64-x86_64-cc --prefix="${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}" &> "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}.log"
       sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -arch $ARCH -mios-simulator-version-min=${DEPLOYMENT_VERSION} -miphoneos-version-min=${DEPLOYMENT_VERSION} !" "${SRC_DIR}/Makefile"
       sed -ie "s!^CFLAGS=!CFLAGS=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -arch $ARCH -mios-simulator-version-min=${DEPLOYMENT_VERSION} -miphoneos-version-min=${DEPLOYMENT_VERSION} !" "${SRC_DIR}/Makefile"
   elif [ "$ARCH" == "i386" ]; then
       ${SRC_DIR}/Configure darwin-i386-cc --prefix="${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}" &> "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}-conf.log"
       sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -arch $ARCH -mios-simulator-version-min=${DEPLOYMENT_VERSION} -miphoneos-version-min=${DEPLOYMENT_VERSION} !" "${SRC_DIR}/Makefile"
       sed -ie "s!^CFLAGS=!CFLAGS=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -arch $ARCH -mios-simulator-version-min=${DEPLOYMENT_VERSION} -miphoneos-version-min=${DEPLOYMENT_VERSION} !" "${SRC_DIR}/Makefile"
   else
       ${SRC_DIR}/Configure iphoneos-cross -no-asm --prefix="${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}" &> "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}.log"
       sed -ie "s!^CFLAG=!CFLAG=-mios-simulator-version-min=${DEPLOYMENT_VERSION} -miphoneos-version-min=${DEPLOYMENT_VERSION} -arch ${ARCH} !" "${SRC_DIR}/Makefile"
       sed -ie "s!^CFLAGS=!CFLAGS=-mios-simulator-version-min=${DEPLOYMENT_VERSION} -miphoneos-version-min=${DEPLOYMENT_VERSION} -arch ${ARCH} !" "${SRC_DIR}/Makefile"
       perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' ${SRC_DIR}/crypto/ui/ui_openssl.c
   fi
}

build()
{
   local ARCH=$1
   local SDK=$2
   local BUILD_DIR=$3
   local TYPE=$4

   local SRC_DIR="${BUILD_DIR}/openssl-${OPENSSL_VERSION}-${TYPE}"

   mkdir -p "${SRC_DIR}"
   tar xzf "${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1

   echo "Building for ${SDK##*/} ${ARCH}"

   export BUILD_TOOLS="${DEVELOPER}"
   export CC="${BUILD_TOOLS}/usr/bin/gcc"
   export CFLAGS="-fembed-bitcode -arch ${ARCH}"

   # Change dir
   cd "${SRC_DIR}"

   # fix headers for Swift

   sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/crypto/rsa/rsa.h

   if [ "$TYPE" == "ios" ]; then
      # IOS
      if [ "$ARCH" == "x86_64" ] || [ "$ARCH" == "i386" ]; then
         configure "iPhoneSimulator" $ARCH ${IPHONESIMULATOR_PLATFORM} ${IPHONEOS_SDK_VERSION} ${IPHONEOS_DEPLOYMENT_VERSION} ${BUILD_DIR} ${SRC_DIR}
      else
         configure "iPhoneOS" $ARCH ${IPHONEOS_PLATFORM} ${IPHONEOS_SDK_VERSION} ${IPHONEOS_DEPLOYMENT_VERSION} ${BUILD_DIR} ${SRC_DIR}
      fi
   elif [ "$TYPE" == "macos" ]; then
      #OSX
      if [ "$ARCH" == "x86_64" ]; then
         ${SRC_DIR}/Configure darwin64-x86_64-cc --prefix="${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}" &> "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}.log"
         sed -ie "s!^CFLAG=!CFLAG=-isysroot ${SDK} -arch $ARCH -mmacosx-version-min=${OSX_DEPLOYMENT_VERSION} !" "${SRC_DIR}/Makefile"
         sed -ie "s!^CFLAGS=!CFLAGS=-isysroot ${SDK} -arch $ARCH -mmacosx-version-min=${OSX_DEPLOYMENT_VERSION} !" "${SRC_DIR}/Makefile"
      fi
   fi

   LOG_PATH="${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}.log"
   echo "Building ${LOG_PATH}"
   make &> ${LOG_PATH}
   make install &> ${LOG_PATH}
   cd ${BASE_PWD}

   # Add arch to library
   if [ -f "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a" ]; then
      xcrun lipo "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a" "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libcrypto.a" -create -output "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a"
      xcrun lipo "${SCRIPT_DIR}/${TYPE}/lib/libssl.a" "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libssl.a" -create -output "${SCRIPT_DIR}/${TYPE}/lib/libssl.a"
   else
      cp "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libcrypto.a" "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a"
      cp "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libssl.a" "${SCRIPT_DIR}/${TYPE}/lib/libssl.a"
   fi

   mv ${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/include/openssl/opensslconf.h ${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/include/openssl/opensslconf-${ARCH}.h

   rm -rf "${SRC_DIR}"
}

generate_opensslconfh() {
   local OPENSSLCONF_PATH=$1
   # opensslconf.h
   echo "
/* opensslconf.h */
#if defined(__APPLE__) && defined (__x86_64__)
# include <openssl/opensslconf-x86_64.h>
#endif

#if defined(__APPLE__) && defined (__i386__)
# include <openssl/opensslconf-i386.h>
#endif

#if defined(__APPLE__) && defined (__arm__) && defined (__ARM_ARCH_7A__)
# include <openssl/opensslconf-armv7.h>
#endif

#if defined(__APPLE__) && defined (__arm__) && defined (__ARM_ARCH_7S__)
# include <openssl/opensslconf-armv7s.h>
#endif

#if defined(__APPLE__) && (defined (__arm64__) || defined (__aarch64__))
# include <openssl/opensslconf-arm64.h>
#endif
" > ${OPENSSLCONF_PATH}
}

build_ios() {
   local TMP_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf ${SCRIPT_DIR}/{ios/include,ios/lib}
   mkdir -p ${SCRIPT_DIR}/{ios/include,ios/lib}

   build "i386" ${IPHONESIMULATOR_SDK} ${TMP_DIR} "ios"
   build "x86_64" ${IPHONESIMULATOR_SDK} ${TMP_DIR} "ios"
   build "armv7"  ${IPHONEOS_SDK} ${TMP_DIR} "ios"
   build "armv7s" ${IPHONEOS_SDK} ${TMP_DIR} "ios"
   build "arm64"  ${IPHONEOS_SDK} ${TMP_DIR} "ios"

   # Copy headers
   cp -r ${TMP_DIR}/${OPENSSL_VERSION}-arm64/include/openssl ${SCRIPT_DIR}/ios/include
   cp -f ${SCRIPT_DIR}/shim/shim.h ${SCRIPT_DIR}/ios/include/openssl/shim.h

   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-x86_64/include/openssl/opensslconf-x86_64.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-i386/include/openssl/opensslconf-i386.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-armv7/include/openssl/opensslconf-armv7.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-armv7s/include/openssl/opensslconf-armv7s.h ${SCRIPT_DIR}/ios/include/openssl
   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-arm64/include/openssl/opensslconf-arm64.h ${SCRIPT_DIR}/ios/include/openssl

   generate_opensslconfh ${SCRIPT_DIR}/ios/include/openssl/opensslconf.h

   rm -rf ${TMP_DIR}
}

build_macos() {
   local TMP_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf ${SCRIPT_DIR}/{macos/include,macos/lib}
   mkdir -p ${SCRIPT_DIR}/{macos/include,macos/lib}

   build "x86_64" ${OSX_SDK} ${TMP_DIR} "macos"

   # Copy headers
   cp -r ${TMP_DIR}/${OPENSSL_VERSION}-x86_64/include/openssl ${SCRIPT_DIR}/macos/include
   cp -f ${SCRIPT_DIR}/shim/shim.h ${SCRIPT_DIR}/macos/include/openssl/shim.h

   cp -f ${TMP_DIR}/${OPENSSL_VERSION}-x86_64/include/openssl/opensslconf-x86_64.h ${SCRIPT_DIR}/macos/include/openssl

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
