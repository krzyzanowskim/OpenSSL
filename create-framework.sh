#!/usr/bin/env bash

# Bitcode is not working for a dynamic framework

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

FWNAME="OpenSSL"
OSX_MIN="10.9"
IOS_MIN="8.0"

export IPHONEOS_DEPLOYMENT_TARGET=${IOS_MIN}
export CODESIGN_ALLOCATE=$( xcrun -f codesign_allocate )

create_dynamiclib() {
    local ARCH=$1
    local SDK=$2
    local PLATFORM_DIR_NAME=$( echo $3 | sed -E 's/^.*\/(.*)\/'"${FWNAME}.framework"'/\1/g')

    if [ ${SDK} == "macosx" ]; then
        local PLATFORM_MIN_VERSION_ARG="-mmacosx-version-min=${OSX_MIN}"
    fi
    
    if [ ${PLATFORM_DIR_NAME} == "iphonesimulator" ]; then
        local PLATFORM_MIN_VERSION_ARG="-mios-simulator-version-min=${IOS_MIN}"
    fi

    if [ ${PLATFORM_DIR_NAME} == "iphoneos" ]; then
        local PLATFORM_MIN_VERSION_ARG="-mios-version-min=${IOS_MIN}"
    fi

    xcrun clang -arch ${ARCH} \
        -L${SCRIPT_DIR}/${PLATFORM_DIR_NAME}/lib \
        -isysroot $(xcrun --sdk ${SDK} --show-sdk-path) \
        -Xlinker -no_deduplicate \
        -Xlinker -all_load -lssl -lcrypto -compatibility_version 1 -current_version 1 \
        -Xlinker -export_dynamic \
        -dynamiclib \
        -install_name @rpath/$FWNAME.framework/$FWNAME \
        -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
        -Xlinker -rpath -Xlinker @loader_path/Frameworks ${PLATFORM_MIN_VERSION_ARG} \
        -o ${SCRIPT_DIR}/Frameworks/${PLATFORM_DIR_NAME}/$FWNAME.framework/Versions/A/$FWNAME-${ARCH}

        cp -r ${SCRIPT_DIR}/${PLATFORM_DIR_NAME}/include/openssl/* ${SCRIPT_DIR}/Frameworks/${PLATFORM_DIR_NAME}/$FWNAME.framework/Versions/A/Headers/
        sed -i '' 's/include <openssl/include <'"${FWNAME}"'/' ${SCRIPT_DIR}/Frameworks/${PLATFORM_DIR_NAME}/$FWNAME.framework/Versions/A/Headers/*.h
        # cp -f ${SCRIPT_DIR}/Frameworks/ios/Info.plist ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Resources
}

create_module() {
    local fw_path=$1

    # Special case because of OpenSSL reasons
    if [ -f $fw_path/Headers/ssl.h ]
    then
        echo "#include \"ssl.h\"" >> $fw_path/Headers/$FWNAME.h
    fi

    # Create umbrella header
    for header in $fw_path/Headers/*
    do
        header=$(basename $header)
        # [[ "$header" = opensslconf-* ]] && continue
        [ "$header" = "$FWNAME.h" ] && continue
        [ "$header" = "ssl.h" ] && continue
        echo "#include \"$header\"" >> $fw_path/Headers/$FWNAME.h
    done

    # Create module map
    cat << EOF > $fw_path/Modules/module.modulemap
framework module $FWNAME {
    umbrella header "$FWNAME.h"
    header "shim.h"

    export *
    module * { export * }
}
EOF

    # Copy shim
    cp -f ${SCRIPT_DIR}/shim/shim.h $fw_path/Headers/shim.h
}

echo "Creating $FWNAME.framework"

rm -rf ${SCRIPT_DIR}/Frameworks/{ios,macos}/$FWNAME.framework

mkdir -p ${SCRIPT_DIR}/Frameworks/{ios,macos}/$FWNAME.framework/Versions/A/{Headers,Modules,Resources}
ln -s Versions/A/Headers ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Headers
ln -s Versions/A/Modules ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Modules
ln -s Versions/A/Resources ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Resources
ln -s Versions/A/Headers ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Headers
ln -s Versions/A/Modules ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Modules
ln -s Versions/A/Resources ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Resources

create_dynamiclib x86_64 "macosx" ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework

create_dynamiclib x86_64 "iphonesimulator" ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework

create_dynamiclib arm64 "iphoneos" ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework
create_dynamiclib armv7 "iphoneos" ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework
create_dynamiclib armv7s "iphoneos" ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework

# Fat binary macos
xcrun lipo -create ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Versions/A/$FWNAME-* -output ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/$FWNAME
rm ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Versions/A/$FWNAME-*

# Fat binary ios
xcrun lipo -create ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Versions/A/$FWNAME-* -output ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/$FWNAME
rm ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Versions/A/$FWNAME-*

# OpenSSL.modulemap

create_module ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework
create_module ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework

# Info.plist

# builtin-infoPlistUtility /Users/marcinkrzyzanowski/Devel/OpenSSL/Frameworks/ios/Info.plist -producttype com.apple.product-type.framework -expandbuildsettings -format binary -platform iphonesimulator -o /Users/marcinkrzyzanowski/Devel/OpenSSL/DerivedData/OpenSSL/Build/Products/Debug-iphonesimulator/openssl.framework/Info.plist

# Codesign

/usr/bin/codesign --force --sign - --timestamp=none ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework
/usr/bin/codesign --force --sign - --timestamp=none ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework

echo "Created $FWNAME.framework"
