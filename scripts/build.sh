#!/usr/bin/env bash

# Yay shell scripting! This script builds a static version of
# OpenSSL for iOS and OSX that contains code for arm64, x86_64.

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

FWNAME="OpenSSL"
NPROCS="$(sysctl -n hw.ncpu)"

# Setup paths to stuff we need

if [[ -z $OPENSSL_VERSION ]]; then
 echo "OPENSSL_VERSION not set"
 exit 1
fi

export OPENSSL_LOCAL_CONFIG_DIR="${SCRIPT_DIR}/../config"


DEVELOPER=$(xcode-select --print-path)

IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
OSX_SDK=$(xcrun --sdk macosx --show-sdk-path)
XROS_SDK=$(xcrun --sdk xros --show-sdk-path)
XRSIMULATOR_SDK=$(xcrun --sdk xrsimulator --show-sdk-path)
APPLETVOS_SDK=$(xcrun --sdk appletvos --show-sdk-path)
APPLETVSIMULATOR_SDK=$(xcrun --sdk appletvsimulator --show-sdk-path)
WATCHOS_SDK=$(xcrun --sdk watchos --show-sdk-path)
WATCHSIMULATOR_SDK=$(xcrun --sdk watchsimulator --show-sdk-path)


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
      visionOS)
    SDK="${XROS_SDK}"
    ;;
      visionSimulator)
    SDK="${XRSIMULATOR_SDK}"
    ;;
      AppleTVOS)
	 SDK="${APPLETVOS_SDK}"
	 ;;
      AppleTVSimulator)
	 SDK="${APPLETVSIMULATOR_SDK}"
	 ;;
      watchOS)
	 SDK="${WATCHOS_SDK}"
	 ;;
      watchSimulator)
	 SDK="${WATCHSIMULATOR_SDK}"
	 ;;
      MacOSX)
	 SDK="${OSX_SDK}"
	 ;;
      MacOSX_Catalyst)
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
      ${SRC_DIR}/Configure macos-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "MacOSX_Catalyst" ]; then
      ${SRC_DIR}/Configure mac-catalyst-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "iPhoneSimulator" ]; then
      ${SRC_DIR}/Configure ios-sim-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "iPhoneOS" ]; then
      ${SRC_DIR}/Configure ios-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "visionSimulator" ]; then
      ${SRC_DIR}/Configure xros-sim-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "visionOS" ]; then
      ${SRC_DIR}/Configure xros-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "AppleTVSimulator" ]; then
      ${SRC_DIR}/Configure tvos-sim-cross-$ARCH no-asm no-shared no-tests --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "AppleTVOS" ]; then
      ${SRC_DIR}/Configure tvos-cross-$ARCH no-asm no-shared no-tests --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "watchSimulator" ]; then
      ${SRC_DIR}/Configure watchos-sim-cross-$ARCH no-asm no-shared no-tests --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "watchOS" ]; then
      ${SRC_DIR}/Configure watchos-cross-$ARCH no-asm no-shared no-tests --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   fi
}

build()
{
   local ARCH=$1
   local OS=$2
   local BUILD_DIR=$3
   local TYPE=$4 # iphoneos/iphonesimulator/macosx/macosx_catalyst/visionos/visionsimulator

   local SRC_DIR="${BUILD_DIR}/${FWNAME}-${OPENSSL_VERSION}-${TYPE}"
   local PREFIX="${BUILD_DIR}/${OPENSSL_VERSION}-${OS}-${ARCH}"

   mkdir -p "${SRC_DIR}"
   tar xzf "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1

   # Apply patches if needed
   local PATCH_FILE="${SCRIPT_DIR}/../patches/openssl-${OPENSSL_VERSION}.patch"
   if [ -f "$PATCH_FILE" ]; then
      patch -d "${SRC_DIR}" -p1 < $PATCH_FILE
   fi

   echo "Building for ${OS} ${ARCH}"

   # Change dir
   cd "${SRC_DIR}"

   # fix headers for Swift

   sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/crypto/rsa/rsa_local.h

   configure "${OS}" $ARCH ${BUILD_DIR} ${SRC_DIR}

   LOG_PATH="${PREFIX}.build.log"
   echo "Building ${LOG_PATH}"
   make -j${NPROCS} &> ${LOG_PATH}
   make -j${NPROCS} install &> ${LOG_PATH}
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
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}

   build "x86_64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"
   build "arm64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"

   # The World is not ready for arm64e!
   # build "arm64e" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"

   rm -rf "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}

   build "arm64" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"

   # The World is not ready for arm64e!
   # build "arm64e" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"

   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl" "${SCRIPT_DIR}/../iphoneos/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../iphoneos/include/${FWNAME}/shim.h"

   # Copy headers
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl" "${SCRIPT_DIR}/../iphonesimulator/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../iphonesimulator/include/${FWNAME}/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../iphoneos/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;
   find "${SCRIPT_DIR}/../iphonesimulator/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../iphonesimulator/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   OPENSSLCONF_PATH="${SCRIPT_DIR}/../iphoneos/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Update include "openssl/" to "OpenSSL/"
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../iphoneos/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../iphonesimulator/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @

   rm -rf ${TMP_BUILD_DIR}
}

build_visionos() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{visionsimulator/include,visionsimulator/lib}
   mkdir -p "${SCRIPT_DIR}"/../{visionsimulator/include,visionsimulator/lib}

   build "x86_64" "visionSimulator" ${TMP_BUILD_DIR} "visionsimulator"
   build "arm64" "visionSimulator" ${TMP_BUILD_DIR} "visionsimulator"

   # The World is not ready for arm64e!
   # build "arm64e" "visionSimulator" ${TMP_BUILD_DIR} "visionsimulator"

   rm -rf "${SCRIPT_DIR}"/../{visionos/include,visionos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{visionos/include,visionos/lib}

   build "arm64" "visionOS" ${TMP_BUILD_DIR} "visionos"

   # The World is not ready for arm64e!
   # build "arm64e" "visionOS" ${TMP_BUILD_DIR} "visionos"

   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-visionOS-arm64/include/openssl" "${SCRIPT_DIR}/../visionos/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../visionos/include/${FWNAME}/shim.h"

   # Copy headers
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-visionSimulator-arm64/include/openssl" "${SCRIPT_DIR}/../visionsimulator/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../visionsimulator/include/${FWNAME}/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../visionos/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;
   find "${SCRIPT_DIR}/../visionsimulator/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../visionsimulator/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-visionSimulator-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-visionSimulator-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-visionSimulator-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   OPENSSLCONF_PATH="${SCRIPT_DIR}/../visionos/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-visionOS-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-visionOS-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Update include "openssl/" to "OpenSSL/"
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../visionos/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../visionsimulator/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @

   rm -rf ${TMP_BUILD_DIR}
}

build_appletvos() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{appletvsimulator/include,appletvsimulator/lib}
   mkdir -p "${SCRIPT_DIR}"/../{appletvsimulator/include,appletvsimulator/lib}

   build "x86_64" "AppleTVSimulator" ${TMP_BUILD_DIR} "appletvsimulator"
   build "arm64" "AppleTVSimulator" ${TMP_BUILD_DIR} "appletvsimulator"

   # The World is not ready for arm64e!
   # build "arm64e" "AppleTVSimulator" ${TMP_BUILD_DIR} "appletvsimulator"

   rm -rf "${SCRIPT_DIR}"/../{appletvos/include,appletvos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{appletvos/include,appletvos/lib}

   build "arm64" "AppleTVOS" ${TMP_BUILD_DIR} "appletvos"

   # The World is not ready for arm64e!
   # build "arm64e" "AppleTVOS" ${TMP_BUILD_DIR} "appletvos"

   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-AppleTVOS-arm64/include/openssl" "${SCRIPT_DIR}/../appletvos/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../appletvos/include/${FWNAME}/shim.h"

   # Copy headers
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-AppleTVSimulator-arm64/include/openssl" "${SCRIPT_DIR}/../appletvsimulator/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../appletvsimulator/include/${FWNAME}/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../appletvos/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;
   find "${SCRIPT_DIR}/../appletvsimulator/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../appletvsimulator/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-AppleTVSimulator-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-AppleTVSimulator-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-AppleTVSimulator-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   OPENSSLCONF_PATH="${SCRIPT_DIR}/../appletvos/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-AppleTVOS-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-AppleTVOS-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Update include "openssl/" to "OpenSSL/"
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../appletvos/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../appletvsimulator/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @

   rm -rf ${TMP_BUILD_DIR}
}

build_watchos() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{watchsimulator/include,watchsimulator/lib}
   mkdir -p "${SCRIPT_DIR}"/../{watchsimulator/include,watchsimulator/lib}

   build "i386" "watchSimulator" ${TMP_BUILD_DIR} "watchsimulator"
   build "x86_64" "watchSimulator" ${TMP_BUILD_DIR} "watchsimulator"
   build "arm64" "watchSimulator" ${TMP_BUILD_DIR} "watchsimulator"

   rm -rf "${SCRIPT_DIR}"/../{watchos/include,watchos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{watchos/include,watchos/lib}

   build "arm64" "watchOS" ${TMP_BUILD_DIR} "watchos"
   build "arm64_32" "watchOS" ${TMP_BUILD_DIR} "watchos"
   build "armv7k" "watchOS" ${TMP_BUILD_DIR} "watchos"

   # Copy headers
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchOS-arm64/include/openssl" "${SCRIPT_DIR}/../watchos/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../watchos/include/${FWNAME}/shim.h"

   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchSimulator-arm64/include/openssl" "${SCRIPT_DIR}/../watchsimulator/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../watchsimulator/include/${FWNAME}/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../watchos/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;
   find "${SCRIPT_DIR}/../watchsimulator/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../watchsimulator/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchSimulator-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchSimulator-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchSimulator-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   OPENSSLCONF_PATH="${SCRIPT_DIR}/../watchos/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchOS-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchOS-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64_32__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-watchOS-arm64_32/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Update include "openssl/" to "OpenSSL/"
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../watchos/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../watchsimulator/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @

   rm -rf ${TMP_BUILD_DIR}
}

build_macos() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{macosx/include,macosx/lib}
   mkdir -p "${SCRIPT_DIR}"/../{macosx/include,macosx/lib}

   build "x86_64" "MacOSX" ${TMP_BUILD_DIR} "macosx"
   build "arm64" "MacOSX" ${TMP_BUILD_DIR} "macosx"
   # The World is not ready for arm64e!
   # build "arm64e" "MacOSX" ${TMP_BUILD_DIR} "macosx"

   # Copy headers
   ditto ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl "${SCRIPT_DIR}/../macosx/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../macosx/include/${FWNAME}/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../macosx/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../macosx/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   # The World is not ready for arm64e!
   # echo "#elif defined(__APPLE__) && defined (__arm64e__)" >> ${OPENSSLCONF_PATH}
   # cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-arm64e/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Update include "openssl/" to "OpenSSL/"
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../macosx/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @

   rm -rf ${TMP_BUILD_DIR}
}

build_catalyst() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{macosx_catalyst/include,macosx_catalyst/lib}
   mkdir -p "${SCRIPT_DIR}"/../{macosx_catalyst/include,macosx_catalyst/lib}

   build "x86_64" "MacOSX_Catalyst" ${TMP_BUILD_DIR} "macosx_catalyst"
   build "arm64" "MacOSX_Catalyst" ${TMP_BUILD_DIR} "macosx_catalyst"
   # build "arm64e" "MacOSX_Catalyst" ${TMP_BUILD_DIR} "macosx_catalyst"

   # Copy headers
   ditto ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX_Catalyst-x86_64/include/openssl "${SCRIPT_DIR}/../macosx_catalyst/include/${FWNAME}"
   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${SCRIPT_DIR}/../macosx_catalyst/include/${FWNAME}/shim.h"

   # fix inttypes.h
   find "${SCRIPT_DIR}/../macosx_catalyst/include/${FWNAME}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <stdint\.h>/g" {} \;

   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../macosx_catalyst/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX_Catalyst-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX_Catalyst-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Update include "openssl/" to "OpenSSL/"
   grep -rl '#\s*include\s*<openssl' --include \*.h ${SCRIPT_DIR}/../macosx_catalyst/include | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @

   rm -rf ${TMP_BUILD_DIR}
}

# Start

if [ ! -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" ]; then
   curl -fL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" -o "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz"
   curl -fL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz.sha256" -o "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256"
   DIGEST=$( cat ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256 )

   if [[ "$(shasum -a 256 "openssl-${OPENSSL_VERSION}.tar.gz" | awk '{ print " "$1}')" != "${DIGEST}" ]]
   then
      echo "openssl-${OPENSSL_VERSION}.tar.gz: checksum mismatch"
      exit 1
   fi
   rm -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256"
fi

build_watchos
build_appletvos
build_ios
build_visionos
build_macos
build_catalyst