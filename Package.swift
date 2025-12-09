// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DIDWalletSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "DIDWalletSDK", targets: ["DIDWalletSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.1.4"),
        .package(url: "https://github.com/attaswift/BigInt.git", exact: "5.5.1"),
        .package(url: "https://github.com/rnapier/RNJSON.git", branch: "main")
    ],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            path: "source/did-wallet-sdk-ios/DIDWalletSDK/Framework/openssl.xcframework"
        ),

        .target(
            name: "OpenSSLWrapper",
            dependencies: ["OpenSSL"],
            path: "source/did-wallet-sdk-ios/DIDWalletSDK/Core/SubComponent/Bridging",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(
                    "../../../Framework/openssl.xcframework/ios-arm64/openssl.framework/Headers",
                    .when(platforms: [.iOS])
                ),
                .headerSearchPath(
                    "../../../Framework/openssl.xcframework/ios-arm64_x86_64-simulator/openssl.framework/Headers",
                    .when(platforms: [.iOS])
                ),
            ]
        ),

        .target(
            name: "DIDWalletSDK",
            dependencies: [
                "OpenSSLWrapper",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "RNJSON", package: "RNJSON")
            ],
            path: "source/did-wallet-sdk-ios/DIDWalletSDK",
            exclude: [
                "Framework",
                "OpenSource",
                "DIDWalletSDK.h",
                "Core/SubComponent/Bridging"
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
