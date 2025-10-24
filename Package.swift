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
    targets: [

        .binaryTarget(
            name: "OpenSSL",
            path: "source/did-wallet-sdk-ios/DIDWalletSDK/Framework/openssl.xcframework"
        ),

        .target(
            name: "OpenSSLWrapper",
            dependencies: [
                "OpenSSL"
            ],
            path: "source/did-wallet-sdk-ios/DIDWalletSDK/Core/SubComponent/Bridging",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        ),

        .target(
            name: "DIDWalletSDK",
            dependencies: [
                "OpenSSLWrapper"
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
