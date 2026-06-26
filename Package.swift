// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DIDWalletSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "DIDWalletSDK", targets: ["DIDWalletSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.1.4"),
    ],
    targets: [
        // Vendored attaswift/BigInt 5.5.1 prebuilt in Release as a binary
        // framework, so SPM consumers building in Debug (-Onone) still get
        // optimized big-integer arithmetic (the P-256 / ZKP hot path).
        // Module is BigIntKit (not BigInt) to dodge the module==type name
        // collision; the exported types are still BigInt / BigUInt.
        // Rebuild with source/did-wallet-sdk-ios/build_bigint_xcframework.sh.
        .binaryTarget(
            name: "BigIntKit",
            path: "source/did-wallet-sdk-ios/Frameworks/BigIntKit.xcframework"
        ),
        .target(
            name: "DIDWalletSDK",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                "BigIntKit",
            ],
            path: "source/did-wallet-sdk-ios/DIDWalletSDK",
            exclude: [
                "OpenSource/BigInt",
                "DIDWalletSDK.h"
            ],
            resources: [
                .process("Wallet/CoreData/WalletModel.xcdatamodeld")
            ]
        ),

        .testTarget(
            name: "DIDWalletSDKTests",
            dependencies: ["DIDWalletSDK"],
            path: "source/did-wallet-sdk-ios/DIDWalletSDKTests"
        )
    ]
)
