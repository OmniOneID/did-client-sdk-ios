# iOS Communication SDK Guide
This document is a guide for using the DID Communication SDK, which provides various encryption, encoding, and hashing functions.


## S/W Specifications
| category      | detail                    |
|---------------|---------------------------|
| OS            | iOS                       |
| Language      | Swift 5.8                 |
| IDE           | Xcode 15.4                |
| Compatibility | iOS 15.0 and higher       |

<br>

## How to build
: Open a terminal and run the script `build_xcframework.sh` to build XCFramework.
1. Launch the Terminal app and type the following:
```bash
$ ./build_xcframework.sh
```
2. Once the archive is complete, a `DIDCommunicationSDK.xcframework` file will be created in the `output/` folder.
<br>


## How to apply SDK
1. Copy the `DIDCommunicationSDK.xcframework` file to the framework directory of your app project.
2. Add the framework to your app project dependencies.
3. Set the framework to `Embeded & Sign`.

<br>

## API Specification
| category               | API Documentation Link                                                                    |
|------------------------|---------------------------------------------------------------------------------|
| CommnunicationClient   | [Communication SDK API](../../../docs/api/did-communication-sdk-ios/Communication.md) |
| CommunicationAPIError  | [Error Code](../../../docs/api/did-communication-sdk-ios/CommunicationError.md)          |



