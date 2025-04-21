# iOS DIDWalletSDK Guide
This document is a guide for using the OpenDID Wallet SDK, and provides functions for creating, storing, and managing the WalletToken, Lock/Unlock, Key, DID Document (DID Document), and Verifiable Credential (hereinafter referred to as VC) information required for Open DID.


## S/W Specification
| Category      | Details                     |
|---------------|-----------------------------|
| OS            | iOS                         |
| Language      | swift 5.8                   | 
| IDE           | Xcode 16.2                  |   
| Compatibility | iOS 15.0 and higher         |


## Build Method
: Open a terminal and run the script `build_xcframework.sh` to build XCFramework.
1. Launch the Terminal app and type the following: 
```groovy
$ ./build_xcframework.sh
```
2. Once the archive is complete, a `DIDWalletSDK.xcframework` file will be created in the `release/` folder.
<br>


## SDK Application Method
1. Copy the `DIDWalletSDK.xcframework` file to the framework directory of the app project. 
2. Add the frameworks to your app project dependencies.
    ```groovy
    DIDWalletSDK.xcframework
    ```
3. Set the frameworks to `Embeded & Sign`.

<br>

## API Specification
| Category           | API Document Link    Link                                                                              |
|---------------|-------------------------------------------------------------------------------------------|
| Wallet        | [Wallet SDK - Wallet API](../../../docs/api/did-wallet-sdk-ios/Wallet.md)            |
| WalletError   | [Wallet Error](../../../docs/api/did-wallet-sdk-ios/WalletError.md)                                |

