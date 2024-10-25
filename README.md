![Platform](https://img.shields.io/cocoapods/p/SquishButton.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift)

# iOS Client SDK

Welcome to the iOS Client SDK Repository. <br>
This repository provides an SDK for developing an iOS mobile wallet.

## Folder Structure
```
did-client-sdk-ios
├── CLA.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── MAINTAINERS.md
├── README.md
├── README_ko.md
├── RELEASE-PROCESS.md
├── docs
│   └── api
│       ├── did-communication-sdk-ios
│       │   ├── Communication.md
│       │   ├── CommunicationError.md
│       │   └── Communication_ko.md
│       ├── did-core-sdk-ios
│       │   ├── DIDManager.md
│       │   ├── DIDManager_ko.md
│       │   ├── KeyManager.md
│       │   ├── KeyManager_ko.md
│       │   ├── SecureEncryptor.md
│       │   ├── SecureEncryptor_ko.md
│       │   ├── VCManager.md
│       │   ├── VCManager_ko.md
│       │   └── WalletCoreError.md
│       ├── did-datamodel-sdk-ios
│       │   └── DataModel.md
│       ├── did-utility-sdk-ios
│       │   ├── Utility.md
│       │   ├── UtilityError.md
│       │   └── Utility_ko.md
│       └── did-wallet-sdk-ios
│           ├── Wallet.md
│           ├── WalletError.md
│           └── Wallet_ko.md
└── source
    └── DIDClientSDK
        ├── DIDClientSDK.xcworkspace    
        ├── did-communication-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDCommunicationSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── LICENSE.txt
        │   ├── README_ko.md
        │   ├── build_xcframework.sh
        │   └── source
        ├── did-core-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDCoreSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README.md
        │   ├── README_ko.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        ├── did-datamodel-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDDataModelSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README.md
        │   ├── README_ko.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        ├── did-utility-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDUtilitySDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README.md
        │   ├── README_ko.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        ├── did-wallet-sdk-ios
        │   ├── CHANGELOG.mdt
        │   ├── DIDWalletSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── LICENSE.md
        │   ├── README.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        └── release
            ├── did-communication-sdk-ios-1.0.0
            │   └── DIDCommunicationSDK.xcframework
            ├── did-core-sdk-ios-1.0.0
            │   └── DIDCoreSDK.xcframework
            ├── did-datamodel-sdk-ios-1.0.0
            │   └── DIDDataModelSDK.xcframework
            ├── did-utility-sdk-ios-1.0.0
            │   └── DIDUtilitySDK.xcframework
            └── did-wallet-sdk-ios-1.0.0
                └── DIDWalletSDK.xcframework
```

| Name                    | Description                                     |
| ----------------------- | ----------------------------------------------- |
| source                  | SDK source code project                         |
| docs                    | Documentation                                   |
| ┖ api                   | API guide documentation                         |
| ┖ design                | Design documentation                            |
| sample                  | Samples and data                                |
| README.md               | Overview and description of the project         |
| CLA.md                  | Contributor License Agreement                   |
| CHANGELOG.md            | Version-specific changes in the project         |
| CODE_OF_CONDUCT.md      | Code of conduct for contributors                |
| CONTRIBUTING.md         | Contribution guidelines and procedures          |
| LICENSE-dependencies.md | Licenses for the project’s dependency libraries |
| MAINTAINERS.md          | General guidelines for maintaining              |
| RELEASE-PROCESS.md      | Release process                                 |
| SECURITY.md             | Security policies and vulnerability reporting   |

## Libraries

Libraries can be found in the [releases folder](source/DIDClientSDK/release).

### Core SDK

1. Copy the `DIDCoreSDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embeded & Sign`.

### DataModel SDK

1. Copy the `DIDDataModelSDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embeded & Sign`.

### Utility SDK

1. Copy the `DIDUtilitySDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embeded & Sign`.

### Communication SDK

1. Copy the `DIDCommunicationSDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embeded & Sign`.

### Wallet SDK

1. Copy the `DIDWalletSDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embeded & Sign`.

## API Reference

API Reference can be found : 
<br>
- [Core SDK](source/DIDClientSDK/did-core-sdk-ios/README.md)  
- [DataModel SDK](source/DIDClientSDK/did-datamodel-sdk-ios/README.md)  
- [Utility SDK](source/DIDClientSDK/did-utility-sdk-ios/README.md)  
- [Communication SDK](source/DIDClientSDK/did-communication-sdk-ios/README.md)  
- [Wallet SDK](source/DIDClientSDK/did-wallet-sdk-ios/README.md)  

## Change Log

ChangeLog can be found : 
<br>
- [Core SDK](source/DIDClientSDK/did-core-sdk-ios/CHANGELOG.md)  
- [DataModel SDK](source/DIDClientSDK/did-datamodel-sdk-ios/CHANGELOG.md)
- [Utility SDK](source/DIDClientSDK/did-utility-sdk-ios/CHANGELOG.md)  
- [Communication SDK](source/DIDClientSDK/did-communication-sdk-ios/CHANGELOG.md)  
- [Wallet SDK](source/DIDClientSDK/did-wallet-sdk-ios/CHANGELOG.md)  

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details on our code of conduct, and the process for submitting pull requests to us.


## License
Copyright 2024 Raonsecure
