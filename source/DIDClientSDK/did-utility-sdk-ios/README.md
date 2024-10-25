# iOS Utility SDK Guide
This document is a guide for using the Crypto Utility SDK, providing various encryption, encoding, and hashing functions.


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
```bash
$ ./build_xcframework.sh
```
2. Once archiving done, the `DIDUtilitySDK.xcframework` file will be generated in the `output/` folder.
<br>

## SDK Application Method
1. Copy the `DIDUtilitySDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embeded & Sign`.

<br>

## API Specification
| Category | API Document Link |
|------|----------------------------|
| CryptoUtils    | [Utility SDK API](../../../docs/api/did-utility-sdk-ios/Utility.md) |
| MultibaseUtils | 〃                             |
| DigestUtils    | 〃                             |
| ErrorCode      | [Error Code](../../../docs/api/did-utility-sdk-ios/UtilityError.md)        |

### CryptoUtils

CryptoUtils provides AES encryption and decryption of data, PBKDF, and generates Shared Secrets for ECDH. 
<br> Key features include:
- Data encryption and decryption using the AES algorithm
- Key generation using PBKDF (Password-Based Key Derivation Function)
- Shared Secrets Generation for ECDH (Elliptic-curve Diffie-Hellman)

### MultibaseUtils

MultibaseUtils offers encoding and decoding for base16, base58, base64, and base64url. <br> Key features include:
- Efficient conversion of data through support for various encoding formats
- Versatile and flexible data handling through Base encoding

### DigestUtils
DigestUtils provides hash functions such as SHA-256, SHA-384, and SHA-512. <br>Key features include:
- Data integrity verification and encryption using various hash algorithms
- Hash-based security features for secure data transmission and storage
