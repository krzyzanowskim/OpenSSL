#!/usr/bin/env bash

# Bitcode is not working for a dynamic framework

set -e

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

FWNAME="OpenSSL"
OSX_MIN="10.9"
IOS_MIN="8.0"

rm -rf Frameworks/ios/$FWNAME.framework
rm -rf Frameworks/macos/$FWNAME.framework

echo "Creating $FWNAME.framework"
mkdir -p ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Headers
mkdir -p ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Modules
mkdir -p ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Headers
mkdir -p ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Modules

# xcrun --sdk iphoneos ld -dylib -arch armv7  -bitcode_bundle -ios_version_min $IOS_MIN lib-ios/libcrypto.a -o Frameworks/ios/$FWNAME.framework/$FWNAME-armv7
# xcrun --sdk iphoneos ld -dylib -arch armv7s -bitcode_bundle -ios_version_min $IOS_MIN lib-ios/libcrypto.a -o Frameworks/ios/$FWNAME.framework/$FWNAME-armv7s
# xcrun --sdk iphoneos ld -dylib -arch arm64  -bitcode_bundle -ios_version_min $IOS_MIN lib-ios/libcrypto.a -o Frameworks/ios/$FWNAME.framework/$FWNAME-arm64
# xcrun --sdk iphoneos lipo -create Frameworks/ios/$FWNAME.framework/$FWNAME-* -output Frameworks/ios/$FWNAME.framework/$FWNAME
# rm -rf Frameworks/ios/$FWNAME.framework/$FWNAME-*

xcrun -n --sdk iphoneos libtool -dynamic -no_warning_for_no_symbols -undefined dynamic_lookup -ios_version_min $IOS_MIN -o ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/$FWNAME ${SCRIPT_DIR}/lib-ios/libcrypto.a ${SCRIPT_DIR}/lib-ios/libssl.a
# rdar://41396876 - macosx fails randomly
xcrun -n --sdk macosx   libtool -dynamic -no_warning_for_no_symbols -undefined dynamic_lookup -macosx_version_min $OSX_MIN -o ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/$FWNAME ${SCRIPT_DIR}/lib-macos/libcrypto.a ${SCRIPT_DIR}/lib-macos/libssl.a

cp -r ${SCRIPT_DIR}/include-ios/$FWNAME/* ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Headers/
sed -i '' 's/include <openssl/include <OpenSSL/' ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework/Headers/*.h

cp -r ${SCRIPT_DIR}/include-macos/$FWNAME/* ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Headers/
sed -i '' 's/include <openssl/include <OpenSSL/' ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework/Headers/*.h

echo "Create module"

create_module() {
    local fw_path=$1
    local fw_name

    fw_name=$(basename $fw_path)
    fw_name=${fw_name%.framework}

    # Special case because of OpenSSL reasons
    if [ -f $fw_path/Headers/ssl.h ]
    then
        echo "#include \"ssl.h\"" >> $fw_path/Headers/$fw_name.h
    fi

    # Create umbrella header
    for header in $fw_path/Headers/*
    do
        header=$(basename $header)
        [ "$header" = "$fw_name.h" ] && continue
        [ "$header" = "ssl.h" ] && continue
        echo "#include \"$header\"" >> $fw_path/Headers/$fw_name.h
    done

    # Create module map
    cat << EOF > $fw_path/Modules/module.modulemap
framework module $fw_name {
    umbrella header "$fw_name.h"

    export *
    module * { export * }
}
EOF
}

create_module ${SCRIPT_DIR}/Frameworks/ios/$FWNAME.framework
create_module ${SCRIPT_DIR}/Frameworks/macos/$FWNAME.framework

echo "Created $FWNAME.framework"
