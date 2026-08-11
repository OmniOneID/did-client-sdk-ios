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
        // A range rather than an exact version: an exact requirement propagates into every
        // consuming app's dependency graph, where it collides with anything else that needs a
        // different swift-collections. The module is an implementation detail of this SDK — it is
        // not part of the public interface — so any 1.x it resolves to is one this SDK can build
        // against. The version this repository actually builds with is fixed by Package.resolved.
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.4")),
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
                .product(name: "OrderedCollections", package: "swift-collections"),
                "BigIntKit",
            ],
            path: "source/did-wallet-sdk-ios/DIDWalletSDK",
            exclude: [
                "OpenSource/BigInt",
                "OpenSource/SwiftCBOR/README.md",
                "DIDWalletSDK.h"
            ],
            resources: [
                .process("Wallet/CoreData/WalletModel.xcdatamodeld"),
                // Ship the vendored libraries' license texts, as the
                // xcframework build does.
                .copy("OpenSource/RNJSON/LICENSE.txt"),
                .copy("OpenSource/SwiftCBOR/UNLICENSE")
            ]
        ),

        .testTarget(
            name: "DIDWalletSDKTests",
            dependencies: ["DIDWalletSDK"],
            path: "source/did-wallet-sdk-ios/DIDWalletSDKTests"
        )
    ]
)
