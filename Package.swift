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
    ],
    targets: [
        .target(
            name: "DIDWalletSDK",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "BigInt", package: "BigInt"),
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
