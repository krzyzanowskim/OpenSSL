#!/usr/bin/env bash

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
FWNAME="OpenSSL"
OUTPUT_DIR=$( mktemp -d )
COMMON_SETUP="-project ${SCRIPT_DIR}/../${FWNAME}.xcodeproj -configuration Release -quiet SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"

# macOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (macOS)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=macOS'

mkdir -p "${OUTPUT_DIR}/macos"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release/${FWNAME}.framework" "${OUTPUT_DIR}/macos"
rm -rf "${DERIVED_DATA_PATH}"

# iOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (iOS)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS'

mkdir -p "${OUTPUT_DIR}/iphoneos"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release-iphoneos/${FWNAME}.framework" "${OUTPUT_DIR}/iphoneos"
rm -rf "${DERIVED_DATA_PATH}"

# iOS Simulator
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (iOS Simulator)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS Simulator'

mkdir -p "${OUTPUT_DIR}/iphonesimulator"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release-iphonesimulator/${FWNAME}.framework" "${OUTPUT_DIR}/iphonesimulator"
rm -rf "${DERIVED_DATA_PATH}"

mkdir -p "${BASE_PWD}/Frameworks/iphoneos"
cp -rf "${OUTPUT_DIR}/iphoneos/${FWNAME}.framework" "${BASE_PWD}/Frameworks/iphoneos"

mkdir -p "${BASE_PWD}/Frameworks/iphonesimulator"
cp -rf "${OUTPUT_DIR}/iphonesimulator/${FWNAME}.framework" "${BASE_PWD}/Frameworks/iphonesimulator"

mkdir -p "${BASE_PWD}/Frameworks/macos"
cp -rf "${OUTPUT_DIR}/macos/${FWNAME}.framework" "${BASE_PWD}/Frameworks/macos"

# XCFramework
rm -rf "${BASE_PWD}/Frameworks/${FWNAME}.xcframework"

xcrun xcodebuild -quiet -create-xcframework \
	-framework "${OUTPUT_DIR}/iphoneos/${FWNAME}.framework" \
	-framework "${OUTPUT_DIR}/iphonesimulator/${FWNAME}.framework" \
	-framework "${OUTPUT_DIR}/macos/${FWNAME}.framework" \
	-output "${BASE_PWD}/Frameworks/${FWNAME}.xcframework"

rm -rf ${OUTPUT_DIR}

# # Laverage Carthage to build frameworks

# BUILD_DIR=$( mktemp -d )
# echo ${BUILD_DIR}

# # Build

# cd ${BUILD_DIR}
# carthage build --configuration Release --no-use-binaries --no-skip-current --derived-data "${BUILD_DIR}/DerivedData" --project-directory "${SCRIPT_DIR}/.."
# rm -rf ${BUILD_DIR}
# cd ${BASE_PWD}

# rm -rf Frameworks/{ios,macos}/${FWNAME}.framework*
# mkdir -p Frameworks/{ios,macos}

# mv -f Carthage/Build/iOS/${FWNAME}.framework Frameworks/ios
# mv -f Carthage/Build/iOS/${FWNAME}.framework.dSYM Frameworks/ios

# mv -f Carthage/Build/Mac/${FWNAME}.framework Frameworks/macos
# mv -f Carthage/Build/Mac/${FWNAME}.framework.dSYM Frameworks/macos

# # Cleanup
# rm -rf Carthage
# rm -rf DerivedData