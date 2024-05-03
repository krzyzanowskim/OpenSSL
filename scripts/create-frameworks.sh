#!/usr/bin/env bash

set -e
# set -x

XC_USER_DEFINED_VARS=""

while getopts ":s" option; do
   case $option in
      s) # Build XCFramework as static instead of dynamic
         XC_USER_DEFINED_VARS="MACH_O_TYPE=staticlib"
   esac
done

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
IDENTITY=$1
FWNAME="OpenSSL"
OUTPUT_DIR=$( mktemp -d )
COMMON_SETUP=" -project ${SCRIPT_DIR}/../${FWNAME}.xcodeproj -configuration Release BUILD_LIBRARY_FOR_DISTRIBUTION=YES $XC_USER_DEFINED_VARS"

# macOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (macOS)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=macOS'

mkdir -p "${OUTPUT_DIR}/macosx"
rm -rf "${OUTPUT_DIR}/macosx/${FWNAME}.framework"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release/${FWNAME}.framework" "${OUTPUT_DIR}/macosx/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

# macOS Catalyst
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (Catalyst)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=macOS,variant=Mac Catalyst'

mkdir -p "${OUTPUT_DIR}/macosx_catalyst"
rm -rf "${OUTPUT_DIR}/macosx_catalyst/${FWNAME}.framework"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-maccatalyst/${FWNAME}.framework" "${OUTPUT_DIR}/macosx_catalyst/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

# iOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (iOS)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS'

rm -rf "${OUTPUT_DIR}/iphoneos"
mkdir -p "${OUTPUT_DIR}/iphoneos"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-iphoneos/${FWNAME}.framework" "${OUTPUT_DIR}/iphoneos/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

# iOS Simulator
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (iOS Simulator)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS Simulator'

rm -rf "${OUTPUT_DIR}/iphonesimulator"
mkdir -p "${OUTPUT_DIR}/iphonesimulator"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-iphonesimulator/${FWNAME}.framework" "${OUTPUT_DIR}/iphonesimulator/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

# visionOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
    $COMMON_SETUP \
    -scheme "${FWNAME} (visionOS)" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -destination 'generic/platform=XROS'

rm -rf "${OUTPUT_DIR}/visionos"
mkdir -p "${OUTPUT_DIR}/visionos"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-xros/${FWNAME}.framework" "${OUTPUT_DIR}/visionos/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

# visionOS Simulator
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
    $COMMON_SETUP \
    -scheme "${FWNAME} (visionOS Simulator)" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -destination 'generic/platform=XROS Simulator'

rm -rf "${OUTPUT_DIR}/visionsimulator"
mkdir -p "${OUTPUT_DIR}/visionsimulator"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-xrsimulator/${FWNAME}.framework" "${OUTPUT_DIR}/visionsimulator/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

# tvOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (tvOS)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=tvOS'

rm -rf "${OUTPUT_DIR}/appletvos"
mkdir -p "${OUTPUT_DIR}/appletvos"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-appletvos/${FWNAME}.framework" "${OUTPUT_DIR}/appletvos/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

# tvOS Simulator
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
    -scheme "${FWNAME} (tvOS Simulator)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=tvOS Simulator'

rm -rf "${OUTPUT_DIR}/appletvsimulator"
mkdir -p "${OUTPUT_DIR}/appletvsimulator"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-appletvsimulator/${FWNAME}.framework" "${OUTPUT_DIR}/appletvsimulator/${FWNAME}.framework"
rm -rf "${DERIVED_DATA_PATH}"

#

rm -rf "${BASE_PWD}/Frameworks/iphoneos"
mkdir -p "${BASE_PWD}/Frameworks/iphoneos"
ditto "${OUTPUT_DIR}/iphoneos/${FWNAME}.framework" "${BASE_PWD}/Frameworks/iphoneos/${FWNAME}.framework"

rm -rf "${BASE_PWD}/Frameworks/iphonesimulator"
mkdir -p "${BASE_PWD}/Frameworks/iphonesimulator"
ditto "${OUTPUT_DIR}/iphonesimulator/${FWNAME}.framework" "${BASE_PWD}/Frameworks/iphonesimulator/${FWNAME}.framework"

rm -rf "${BASE_PWD}/Frameworks/visionos"
mkdir -p "${BASE_PWD}/Frameworks/visionos"
ditto "${OUTPUT_DIR}/visionos/${FWNAME}.framework" "${BASE_PWD}/Frameworks/visionos/${FWNAME}.framework"

rm -rf "${BASE_PWD}/Frameworks/visionsimulator"
mkdir -p "${BASE_PWD}/Frameworks/visionsimulator"
ditto "${OUTPUT_DIR}/visionsimulator/${FWNAME}.framework" "${BASE_PWD}/Frameworks/visionsimulator/${FWNAME}.framework"

rm -rf "${BASE_PWD}/Frameworks/appletvos"
mkdir -p "${BASE_PWD}/Frameworks/appletvos"
ditto "${OUTPUT_DIR}/appletvos/${FWNAME}.framework" "${BASE_PWD}/Frameworks/appletvos/${FWNAME}.framework"

rm -rf "${BASE_PWD}/Frameworks/appletvsimulator"
mkdir -p "${BASE_PWD}/Frameworks/appletvsimulator"
ditto "${OUTPUT_DIR}/appletvsimulator/${FWNAME}.framework" "${BASE_PWD}/Frameworks/appletvsimulator/${FWNAME}.framework"

rm -rf "${BASE_PWD}/Frameworks/macosx"
mkdir -p "${BASE_PWD}/Frameworks/macosx"
ditto "${OUTPUT_DIR}/macosx/${FWNAME}.framework" "${BASE_PWD}/Frameworks/macosx/${FWNAME}.framework"

rm -rf "${BASE_PWD}/Frameworks/macosx_catalyst"
mkdir -p "${BASE_PWD}/Frameworks/macosx_catalyst"
ditto "${OUTPUT_DIR}/macosx_catalyst/${FWNAME}.framework" "${BASE_PWD}/Frameworks/macosx_catalyst/${FWNAME}.framework"

# XCFramework
rm -rf "${BASE_PWD}/Frameworks/${FWNAME}.xcframework"

xcrun xcodebuild -create-xcframework \
	-framework "${BASE_PWD}/Frameworks/iphoneos/${FWNAME}.framework" \
	-framework "${BASE_PWD}/Frameworks/iphonesimulator/${FWNAME}.framework" \
    -framework "${BASE_PWD}/Frameworks/visionos/${FWNAME}.framework" \
    -framework "${BASE_PWD}/Frameworks/visionsimulator/${FWNAME}.framework" \
	-framework "${BASE_PWD}/Frameworks/appletvos/${FWNAME}.framework" \
	-framework "${BASE_PWD}/Frameworks/appletvsimulator/${FWNAME}.framework" \
	-framework "${BASE_PWD}/Frameworks/macosx/${FWNAME}.framework" \
	-framework "${BASE_PWD}/Frameworks/macosx_catalyst/${FWNAME}.framework" \
	-output "${BASE_PWD}/Frameworks/${FWNAME}.xcframework"
	
# Sign
echo "Signing xcframework as ${IDENTITY}"
xcrun codesign --timestamp -s "${IDENTITY}" "${BASE_PWD}/Frameworks/${FWNAME}.xcframework"

# Zip archive
pushd "${BASE_PWD}/Frameworks"
zip --symlinks -r "./${FWNAME}.xcframework.zip" "./${FWNAME}.xcframework"
popd

rm -rf "${OUTPUT_DIR}"
