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
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4")
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
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "source/did-wallet-sdk-ios/DIDWalletSDK",
            exclude: [
                "Framework",
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
