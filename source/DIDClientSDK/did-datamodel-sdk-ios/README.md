# iOS Data Model SDK Guide
This document is a guide for using the DataModel SDK, defining the data model used in the app and wallet SDK.


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
2. Once archiving done, the `DIDDataModelSDK.xcframework` file will be generated in the `output/` folder.
<br>


## SDK Application Method
1. Copy the `DIDDataModelSDK.xcframework` file to the framework directory of the app project.
2. Add the framework to the app project dependencies.
3. Set the framework to `Embeded & Sign`.

<br>

## Structure Specification
| Category      | Structure Document Link                                      |
|---------------|--------------------------------------------------------------|
| DataModel     | [DataModel SDK](../../../docs/api/did-datamodel-sdk-ios/DataModel.md) |

<br>

### DIDDocument
- Document for Decentralized Identifiers
### VerifiableCredential
- Decentralized digital certificate, hereafter VC
### VerifiablePresentation
- A List of VCs signed with subject signatures, hereafter VP



## License
Copyright 2024 Raonsecure

