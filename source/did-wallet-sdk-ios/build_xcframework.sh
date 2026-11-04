#!/bin/bash
set -xe

#[ -z "$1" ] && echo "Need output directory based on current directory" && exit 1
REVEAL_ARCHIVE_IN_FINDER=true

FRAMEWORK_NAME="DIDWalletSDK"
SCHEME_NAME="DIDWalletSDK"
FOLDER_NAME="did-wallet-sdk-ios"
CMD_BUILD="xcodebuild"

VERSION=$("$CMD_BUILD" -target "$SCHEME_NAME" -showBuildSettings | grep MARKETING_VERSION | awk -F= '{print $2}' | xargs)

#BUILD_DIR="./$1"
#BUILD_DIR="./output"

BUILD_DIR="../release/${FOLDER_NAME}-${VERSION}"


#! [ -z "$2" ] && CMD_BUILD="$2/Contents/Developer/usr/bin/${CMD_BUILD}"  # The $2 is Xcode App path for diffrent version. Need to input path with extension.

rm -rf "${BUILD_DIR}"

ARCHIVE_PATH_IOS="${BUILD_DIR}/ios.xcarchive"
ARCHIVE_PATH_IOS_SIM="${BUILD_DIR}/ios_sim.xcarchive"
echo "start build xcframework... framework name: ${FRAMEWORK_NAME}, scheme name: ${SCHEME_NAME}, ios archive path: ${ARCHIVE_PATH_IOS}, ios_sim archive path: ${ARCHIVE_PATH_IOS_SIM}"

# Swift 6.4 (Xcode 27) prints `Self.Element` in a .swiftinterface as a module-qualified
# `OrderedCollections::Element`, which it then cannot resolve, so verifying swift-collections'
# interface fails. That interface is never shipped -- swift-collections is an internal import,
# statically linked -- but the flag applies to every module, so the build-time verification is
# skipped for all of them and DIDWalletSDK's own interface is verified explicitly below.
NO_VERIFY_FLAGS='OTHER_SWIFT_FLAGS=$(inherited) -no-verify-emitted-module-interface'

$CMD_BUILD archive -scheme ${SCHEME_NAME} -archivePath $ARCHIVE_PATH_IOS -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES "${NO_VERIFY_FLAGS}"
$CMD_BUILD archive -scheme ${SCHEME_NAME} -archivePath $ARCHIVE_PATH_IOS_SIM -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES "${NO_VERIFY_FLAGS}"
$CMD_BUILD -create-xcframework \
-framework "${ARCHIVE_PATH_IOS}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
-framework "${ARCHIVE_PATH_IOS_SIM}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
-output "${BUILD_DIR}/${FRAMEWORK_NAME}.xcframework"

# Verify every shipped .swiftinterface of the framework, the check the build no longer runs.
# Each one is typechecked against the SDK of its own slice; any failure stops the script (set -e).
VERIFY_CACHE_DIR=$(mktemp -d)
for INTERFACE in $(find "${BUILD_DIR}/${FRAMEWORK_NAME}.xcframework" -name '*.swiftinterface'); do
  case "${INTERFACE}" in
    *-simulator.*) VERIFY_SDK=iphonesimulator ;;
    *) VERIFY_SDK=iphoneos ;;
  esac
  xcrun --sdk "${VERIFY_SDK}" swift-frontend -typecheck-module-from-interface "${INTERFACE}" \
    -module-name "${FRAMEWORK_NAME}" \
    -sdk "$(xcrun --sdk "${VERIFY_SDK}" --show-sdk-path)" \
    -module-cache-path "${VERIFY_CACHE_DIR}"
done
rm -rf "${VERIFY_CACHE_DIR}"

# .abi.json embeds absolute source paths of the build machine and is only used by
# swift-api-digester; apps consume the .swiftinterface, so it is not shipped.
find "${BUILD_DIR}/${FRAMEWORK_NAME}.xcframework" -name '*.abi.json' -delete

rm -rf "${ARCHIVE_PATH_IOS}" "${ARCHIVE_PATH_IOS_SIM}"

echo "Succeeded to create xcframework"

if [ ${REVEAL_ARCHIVE_IN_FINDER} = true ]; then
open "${BUILD_DIR}/"
fi
