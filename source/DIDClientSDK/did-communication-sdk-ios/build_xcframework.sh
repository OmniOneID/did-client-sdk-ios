#!/bin/bash
set -xe

#[ -z "$1" ] && echo "Need output directory based on current directory" && exit 1
REVEAL_ARCHIVE_IN_FINDER=true

FRAMEWORK_NAME="DIDCommunicationSDK"
SCHEME_NAME="DIDCommunicationSDK"

#BUILD_DIR="./$1"
BUILD_DIR="./output"

CMD_BUILD="xcodebuild"
#! [ -z "$2" ] && CMD_BUILD="$2/Contents/Developer/usr/bin/${CMD_BUILD}"  # The $2 is Xcode App path for diffrent version. Need to input path with extension.

rm -rf "${BUILD_DIR}"

ARCHIVE_PATH_IOS="${BUILD_DIR}/ios.xcarchive"
ARCHIVE_PATH_IOS_SIM="${BUILD_DIR}/ios_sim.xcarchive"
echo "start build xcframework... framework name: ${FRAMEWORK_NAME}, scheme name: ${SCHEME_NAME}, ios archive path: ${ARCHIVE_PATH_IOS}, ios_sim archive path: ${ARCHIVE_PATH_IOS_SIM}"

$CMD_BUILD archive -scheme ${SCHEME_NAME} -archivePath $ARCHIVE_PATH_IOS -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
$CMD_BUILD archive -scheme ${SCHEME_NAME} -archivePath $ARCHIVE_PATH_IOS_SIM -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
$CMD_BUILD -create-xcframework \
-framework "${ARCHIVE_PATH_IOS}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
-framework "${ARCHIVE_PATH_IOS_SIM}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
-output "${BUILD_DIR}/${FRAMEWORK_NAME}.xcframework"

rm -rf "${ARCHIVE_PATH_IOS}" "${ARCHIVE_PATH_IOS_SIM}"

echo "Succeeded to create xcframework"

if [ ${REVEAL_ARCHIVE_IN_FINDER} = true ]; then
open "${BUILD_DIR}/"
fi
