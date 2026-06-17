#!/bin/bash
set -xe

# Build BigInt.xcframework from the vendored pure-Swift sources at
# DIDWalletSDK/OpenSource/BigInt, compiled in Release so that consumers
# referencing the SDK via SPM in Debug (-Onone) still get optimized BigInt.
#
# Run from: source/did-wallet-sdk-ios/

# Module is named BigIntKit (not BigInt) to avoid the module-name == type-name
# ("struct BigInt") collision that breaks .swiftinterface verification under
# BUILD_LIBRARY_FOR_DISTRIBUTION. The vendored sources still declare the types
# BigInt / BigUInt; only the wrapping module name differs.
MODULE_NAME="BigIntKit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/DIDWalletSDK/OpenSource/BigInt"
OUT_DIR="${SCRIPT_DIR}/Frameworks"
BUILD_ROOT="$(mktemp -d)/BigIntPackage"
DEPLOYMENT_TARGET="15.0"

# 1. Assemble a throwaway SwiftPM package wrapping the vendored sources.
mkdir -p "${BUILD_ROOT}/Sources/${MODULE_NAME}"
cp "${SRC_DIR}"/*.swift "${BUILD_ROOT}/Sources/${MODULE_NAME}/"

cat > "${BUILD_ROOT}/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "${MODULE_NAME}",
    platforms: [.iOS(.v15)],
    products: [
        // .dynamic so that 'xcodebuild archive' wraps the output in a
        // .framework (a default/static SwiftPM library archives to a bare .o).
        .library(name: "${MODULE_NAME}", type: .dynamic, targets: ["${MODULE_NAME}"])
    ],
    targets: [
        .target(name: "${MODULE_NAME}", path: "Sources/${MODULE_NAME}")
    ]
)
EOF

ARCHIVE_IOS="${BUILD_ROOT}/ios.xcarchive"
ARCHIVE_SIM="${BUILD_ROOT}/ios_sim.xcarchive"
DD="${BUILD_ROOT}/dd"   # pinned DerivedData so swiftmodule paths are deterministic
BPP="${DD}/Build/Intermediates.noindex/ArchiveIntermediates/${MODULE_NAME}/BuildProductsPath"

COMMON_FLAGS="SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES IPHONEOS_DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET}"

# 2. Archive each platform, then immediately inject the Swift module.
#    A bare SwiftPM package is built by running xcodebuild inside its directory.
cd "${BUILD_ROOT}"

# SwiftPM's dynamic-library archive omits the Swift module from the .framework
# bundle. Inject Modules/<name>.swiftmodule (the triple-named
# .swiftmodule/.swiftinterface/.abi.json bundle) from the build products so the
# framework is importable. Pure-Swift module needs no umbrella header. This must
# run right after each archive: a subsequent archive overwrites BuildProductsPath.
archive_and_inject() {
  local dest="$1" archive="$2" sdk="$3"
  xcodebuild archive -scheme "${MODULE_NAME}" -derivedDataPath "${DD}" \
    -destination "${dest}" -archivePath "${archive}" ${COMMON_FLAGS}
  local fw sm
  fw="$(find "${archive}/Products" -name "${MODULE_NAME}.framework" -type d | head -1)"
  sm="${BPP}/Release-${sdk}/${MODULE_NAME}.swiftmodule"
  [ -d "${fw}" ] || { echo "ERROR: framework not found in ${archive}"; exit 1; }
  [ -d "${sm}" ] || { echo "ERROR: swiftmodule not found at ${sm}"; exit 1; }
  mkdir -p "${fw}/Modules"
  cp -R "${sm}" "${fw}/Modules/${MODULE_NAME}.swiftmodule"
  echo "${fw}" >> "${BUILD_ROOT}/.frameworks"
}

rm -f "${BUILD_ROOT}/.frameworks"
archive_and_inject "generic/platform=iOS"           "${ARCHIVE_IOS}" "iphoneos"
archive_and_inject "generic/platform=iOS Simulator" "${ARCHIVE_SIM}" "iphonesimulator"

FW_IOS="$(sed -n '1p' "${BUILD_ROOT}/.frameworks")"
FW_SIM="$(sed -n '2p' "${BUILD_ROOT}/.frameworks")"
echo "device framework: ${FW_IOS}"
echo "sim    framework: ${FW_SIM}"

# 3. Bundle into an xcframework at the committed location.
rm -rf "${OUT_DIR}/${MODULE_NAME}.xcframework"
mkdir -p "${OUT_DIR}"
xcodebuild -create-xcframework \
  -framework "${FW_IOS}" \
  -framework "${FW_SIM}" \
  -output "${OUT_DIR}/${MODULE_NAME}.xcframework"

rm -rf "${BUILD_ROOT}"
echo "Succeeded: ${OUT_DIR}/${MODULE_NAME}.xcframework"
