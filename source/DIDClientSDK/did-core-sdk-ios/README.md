# iOS Core SDK Guide
This document is a guide for using the OpenDID Core SDK, providing functions to generate, store, and manage the keys, DID Document, and Verifiable Credential (VC) information required for Open DID.


## S/W Specifications
| Category      | Details                   |
|---------------|---------------------------|
| OS            | iOS                       |
| Language      | Swift 5.8                 |
| IDE           | Xcode 15.4                |
| Compatibility | iOS 15.0 and higher       |

<br>


## Build Method
: Open the terminal and excute the script `build_xcframework.sh` to generate an XCFramework.
1. Open the terminal app and write down below:
```groovy
$ ./build_xcframework.sh
```
2. Once archiving done, the `DIDCoreSDK.xcframework` file will be generated in the `output/` folder.
<br>

## SDK Application Method
1. Copy the `DIDCoreSDK.xcframework`, `DIDDataModelSDK.xcframework`, and `DIDUtilitySDK.xcframework` files to the framework directory of the app project.
2. Add the frameworks to the app project dependencies.
    ```groovy
    DIDCoreSDK.xcframework
    DIDDataModelSDK.xcframework
    DIDUtilitySDK.xcframework
    ```
3. Set the frameworks to `Embeded & Sign`.

<br>

## API Specification
| Category        | API Document Link                                                                      |
|-----------------|----------------------------------------------------------------------------------------|
| KeyManager      | [Wallet Core SDK - KeyManager API](../../../docs/api/did-core-sdk-ios/KeyManager.md)            |
| DIDManager      | [Wallet Core SDK - DIDManager API](../../../docs/api/did-core-sdk-ios/DIDManager.md)            |
| VCManager       | [Wallet Core SDK - VCManager API](../../../docs/api/did-core-sdk-ios/VCManager.md)              |
| SecureEncryptor | [Wallet Core SDK - SecureEncryptor API](../../../docs/api/did-core-sdk-ios/SecureEncryptor.md)  |
| ErrorCode       | [Error Code](../../../docs/api/did-core-sdk-ios/WalletCoreError.md)                             |

### KeyManager
KeyManager provides the functionality to generate and manage key pairs for signing and store them securely.<br>The main features are as follows:

* <b>Key Generation</b>: Generates a new key pair.
* <b>Key Storage</b>: Securely stores the generated key.
* <b>Key Retrieval</b>: Retrieves the stored key.
* <b>Key Deletion</b>: Deletes the stored key.

### DIDManager
DIDManager provides the functionality to generate and manage DID Documents.<br>The main features are as follows:

* <b>DID Generation</b>: Generates a new DID.
* <b>DID Document Management</b>: Creates, updates, and deletes DID Documents.
* <b>DID Document Retrieval</b>: Retrieves information about DID Documents.

### VCManager
VCManager provides the functionality to manage and store Verifiable Credentials (VC).<br>The main features are as follows:

* <b>VC Storage</b>: Securely stores the generated VC.
* <b>VC Retrieval</b>: Retrieves the stored VC.
* <b>VC Deletion</b>: Deletes the stored VC.

### SecureEncryptor
SecureEncryptor provides the functionality to encrypt and decrypt data using the Keystore.<br>The main features are as follows:

* <b>Data Encryption</b>: Securely encrypts the data.
* <b>Data Decryption</b>: Decrypts the encrypted data.
