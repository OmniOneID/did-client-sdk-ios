# iOS DIDWalletSDK Guide
This document is a guide for using the OpenDID Wallet SDK, and provides functions for creating, storing, and managing the WalletToken, Lock/Unlock, Key, DID Document (DID Document), and Verifiable Credential (hereinafter referred to as VC) information required for Open DID.


## S/W Specification
| Category         | Details                     |
|------------------|-----------------------------|
| OS               | iOS                         |
| Language         | Swift 5.8                   |
| IDE              | Xcode 16.2                  |
| Compatibility    | iOS 15.0 and higher         |
| Test Environment | iPhone 15 (17.5) Simulator  |



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
4. In the app project’s `Package Dependencies`, click the `+` to add the following items.
    ```groovy
    https://github.com/apple/swift-collections.git
    Exact Version 1.1.4
    ```
<br>

## Optimization
There is an optimization issue related to BigInt when using ZKP-related functions.
- This is not an issue when using `DIDWalletSDK.xcframework`.
- When referencing and using the `DIDWalletSDK` project, there is a delay in all APIs that perform ZKP-related operations.
- To resolve this issue, the `Build Configuration` should be changed to `Release`.

<br>

## API Specification
| Category           | API Document Link    Link                                                                              |
|---------------|-------------------------------------------------------------------------------------------|
| Wallet        | [Wallet SDK - Wallet API](../../docs/api/did-wallet-sdk-ios/Wallet.md)            |
| WalletError   | [Wallet Error](../../docs/api/did-wallet-sdk-ios/WalletError.md)                                |

