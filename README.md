![Platform](https://img.shields.io/cocoapods/p/SquishButton.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift)

# iOS Client SDK

Welcome to the iOS Client SDK Repository. <br>
This repository provides an SDK for developing an iOS mobile wallet.

## Folder Structure
```
did-client-sdk-ios
├── CHANGELOG.md
├── CLA.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── dependencies-license.md
├── LICENSE
├── MAINTAINERS.md
├── Package.resolved
├── Package.swift
├── README.md
├── README_ko.md
├── RELEASE-PROCESS.md
├── SECURITY.md
├── docs
│   └── api
│       ├── README.md
│       ├── public
│       │   ├── Communication.md
│       │   ├── CommunicationError.md
│       │   ├── Communication_ko.md
│       │   ├── DataModel.md
│       │   ├── DataModel_ko.md
│       │   ├── Utility.md
│       │   ├── UtilityError.md
│       │   ├── Utility_ko.md
│       │   ├── Wallet.md
│       │   ├── WalletError.md
│       │   ├── Wallet_ko.md
│       │   ├── WalletCoreError.md
│       │   ├── ZKP_DataModel.md
│       │   └── ZKP_DataModel_ko.md
│       └── private
│           ├── DIDManager.md
│           ├── DIDManager_ko.md
│           ├── KeyManager.md
│           ├── KeyManager_ko.md
│           ├── SecureEncryptor.md
│           ├── SecureEncryptor_ko.md
│           ├── VCManager.md
│           ├── VCManager_ko.md
│           ├── ZKPManager.md
│           └── ZKPManager_ko.md
└── source  
    ├── did-wallet-sdk-ios
    │   ├── DIDWalletSDK.xcodeproj
    │   ├── README.md
    │   ├── README_ko.md
    │   └── build_xcframework.sh
    └── release
        ├── did-wallet-sdk-ios-2.0.0
        │   └── DIDWalletSDK.xcframework
        └── did-wallet-sdk-ios-2.0.1
            └── DIDWalletSDK.xcframework
```

| Name                    | Description                                     |
| ----------------------- | ----------------------------------------------- |
| source                  | SDK source code project                         |
| docs                    | Documentation                                   |
| ┖ api                   | API guide documentation                         |
| README.md               | Overview and description of the project         |
| CLA.md                  | Contributor License Agreement                   |
| CHANGELOG.md            | Version-specific changes in the project         |
| CODE_OF_CONDUCT.md      | Code of conduct for contributors                |
| CONTRIBUTING.md         | Contribution guidelines and procedures          |
| dependencies-license.md | Licenses for the project’s dependency libraries |
| MAINTAINERS.md          | General guidelines for maintaining              |
| RELEASE-PROCESS.md      | Release process                                 |
| SECURITY.md             | Security policies and vulnerability reporting   |


## S/W Specification
| Category         | Details                     |
|------------------|-----------------------------|
| OS               | iOS                         |
| Language         | Swift 5.8                   |
| IDE              | Xcode 26.0.1                |
| Compatibility    | iOS 15.0 and higher         |
| Test Environment | iPhone 15 (17.5) Simulator  |

## Libraries

Libraries can be found in the [releases folder](source/release).

### Wallet SDK

1. Copy the `DIDWalletSDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embed & Sign`.

## Swift Package Integration

Application method can be found [here](source/did-wallet-sdk-ios/README.md)

## API Reference

API Reference can be found [here](source/did-wallet-sdk-ios/README.md)


## Change Log

The Change Log provides a detailed record of version-specific changes and updates. You can find it here:
- [Change Log](./CHANGELOG.md)


## OpenDID Demonstration Videos
To watch our demonstration videos of the OpenDID system in action, please visit our [Demo Repository](https://github.com/OmniOneID/did-demo-server). <br>

These videos showcase key features including user registration, VC issuance, and VP submission processes.


## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details on our code of conduct, and the process for submitting pull requests to us.



## License
[Apache 2.0](LICENSE)

