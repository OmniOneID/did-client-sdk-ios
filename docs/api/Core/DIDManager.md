---
puppeteer:
    pdf:
        format: A4
        displayHeaderFooter: true
        landscape: false
        scale: 0.8
        margin:
            top: 1.2cm
            right: 1cm
            bottom: 1cm
            left: 1cm
    image:
        quality: 100
        fullPage: false
---

iOS DIDManager Core SDK API
==

- Topic: DIDManager
- Author: Woosang Kim
- Date: 2024-08-28
- Version: v1.0.0

| Version | Date       | Change Details            |
| ------- | ---------- | ------------------------- |
| v1.0.0  | 2024-08-28 | Initial version           |


<div style="page-break-after: always;"></div>

# Table of Contents
- [APIs](#apis)
  - [1. genDID](#1-gendid)
  - [2. init](#2-init)
  - [3. isSaved](#3-issaved)
  - [4. createDocument](#4-createdocument)
  - [5. getDocument](#5-getdocument)
  - [6. replaceDocument](#6-replacedocument)
  - [7. saveDocument](#7-savedocument)
  - [8. deleteDocument](#8-deletedocument)
  - [9. addVerificationMethod](#9-addverificationmethod)
  - [10. removeVerificationMethod](#10-removeverificationmethod)
  - [11. addService](#11-addservice)
  - [12. removeService](#12-removeservice)
  - [13. resetChanges](#13-resetchanges)
- [OptionSet](#optionset)
  - [1. DIDMethodType](#1-didmethodtype)
- [Models](#models)
  - [1. DIDKeyInfo](#1-didkeyinfo)
  - [2. DIDDocument](#2-diddocument)
  - [3. DIDDocument.Service](#3-diddocumentservice)
  - [4. KeyInfo](#4-keyinfo)

# APIs
## 1. genDID

### Description
```
Returns a random DID string including the methodName.
```

### Declaration

```swift
// Declaration in Swift
public static func genDID(methodName: String) throws -> String
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| methodName | String | Method-name to use        | M       |                     |

### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| String | DID string                 | M       | Returns a string in the following format: <br>`did:omn:3kH8HncYkmRTkLxxipTP9PB3jSXB` |

### Usage
```swift
let methodName = "omn"
let did = try DIDManager.genDID(methodName: methodName)
print("DID String : \(did)")
```

<br>

## 2. init

### Description
```
Creates an instance of DIDManager that manages the DID document wallet.
```

### Declaration
```swift
public init(fileName: String) throws
```

### Parameters

| Name      | Type   | Description                                | **M/O** | **Note**                                   |
|-----------|--------|--------------------------------------------|---------|--------------------------------------------|
| fileName  | String | The name of the wallet file to store the DID document | M       | Exclude the extension as it is internally defined. |

### Returns

| Type       | Description                        |**M/O** | **Note**|
|------------|------------------------------------|--------|---------|
| DIDManager | Instance of DIDManager             | M      |         |

### Usage
```swift
let fileName = "DIDDocWallet"
let didManager = try DIDManager(fileName: fileName)
```

<br>

## 3. isSaved

### Description
`Returns whether a DID document is saved in the wallet.`

### Declaration

```swift
// Declaration in Swift
public var isSaved: Bool
```

### Usage
```swift
let fileName = "DIDDocWallet"
let didManager = try DIDManager(fileName: fileName)

if didManager.isSaved {
    // DID document exists in the wallet
} else {
    // DID document does not exist in the wallet
}
```

<br>

## 4. createDocument

### Description
```
Using parameters, create a "temporary DIDDocument object" and manage it as an internal variable.
In this stage, it is not saved in the wallet.
It can only be called when the return value of the isSaved API is false.
```

### Declaration

```swift
// Declaration in Swift
public mutating func createDocument(did: String, keyInfos: [DIDKeyInfo], controller: String?, service: [DIDDocument.Service]?) throws
```

### Parameters

| Name          | Type                  | Description                                                               | **M/O** | **Note**                       |
|---------------|-----------------------|---------------------------------------------------------------------------|---------|--------------------------------|
| did           | String                | User DID                                                                  |    M    | Refer to [genDID](#1-gendid) for DID generation. |
| keyInfos      | [DIDKeyInfo]          | Array of public key information objects to register in the DID document   |    M    | [DIDKeyInfo](#1-didkeyinfo) |
| controller    | String                | DID to register as controller in the DID document. <br>If nil, the `did` field is used. |    O    | |
| service       | [DIDDocument.Service] | Service information of DID document                                       |    O    | [DIDDocument.Service](#3-diddocumentservice) |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // A DID document saved in the wallet exists
    return
}

// No DID document saved in the wallet

let did = try DIDManager.genDID(methodName: "omn")

var keyInfos: [DIDKeyInfo] = .init()

let keyInfo = ...   // An element object of the array returned by KeyManager - getKeyInfos

keyInfos.append(.init(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))

try didManager.createDocument(did: did, keyInfos: keyInfos, controller: nil, service: nil)
```

<br>

## 5. getDocument

### Description
```
Returns a "temporary DIDDocument object."
If the "temporary DIDDocument object" is nil, returns the stored DID document.
```

### Declaration

```swift
// Declaration in Swift
public func getDocument() throws -> DIDDocument
```

### Parameters

N/A

### Returns

| Type         | Description         | **M/O** | **Note**                  |
|--------------|---------------------|---------|---------------------------|
| DIDDocument  | DID document object | M       | [DIDDocument](#2-diddocument) |

### Usage
```swift
let fileName = "DIDDocWallet"
let didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // DID document exists in the wallet
    let didDocument = try didManager.getDocument()
} else {
    // DID document does not exist in the wallet
}
```

<br>

## 6. replaceDocument

### Description
```
Replaces the "temporary DIDDocument object" with the input object.
```

### Declaration

```swift
// Declaration in Swift
public mutating func replaceDocument(didDocument: DIDDocument, needUpdate: Bool)
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| didDocument | DIDDocument | Replacement DID Document object |    M    | [DIDDocument](#2-diddocument) |
| needUpdate | Bool | Whether to update the `updated` attribute of the DID document object to the current time | M | If the DID document object to replace does not have a proof added, `true` can be used as needed. <br>However, if a proof is added, use `false` to preserve the original signed document. |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

let didDocumentToReplace: DIDDocument = ... // The DID Document object to replace

try didManager.replaceDocument(didDocument: didDocumentToReplace, needUpdate: false)
```

<br>

## 7. saveDocument

### Description
```
After saving the "Temporary DIDDocument Object" in the wallet file, it is initialized.
If it is called with the "Temporary DIDDocument Object" being nil, meaning there are no changes to the already saved file, nothing happens. (This is not an error)
```
### Declaration

```swift
// Declaration in Swift
public mutating func saveDocument() throws
```
### Parameters

N/A

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // DID document exists in the wallet
    return
}

// DID document does not exist in the wallet

let did = try DIDManager.genDID(methodName: "omn")

var keyInfos: [DIDKeyInfo] = .init()

let keyInfo = ...    // Element object in the array returned by KeyManager - getKeyInfos

keyInfos.append(.init(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))

try didManager.createDocument(did: did, keyInfos: keyInfos, controller: nil, service: nil)

let didDocument = try didManager.getDocument()  // DID document object with an empty proof

let didDocumentWithProof = ...  // DID document object with completed proof, signed by KeyManager

didManager.replaceDocument(didDocument: didDocumentWithProof, needUpdate: false)

try didManager.saveDocument()
```

<br>

## 8. deleteDocument

### Description
```
Deletes the stored wallet file.
After deleting the file, initializes the “temporary DIDDocument object” to nil.
```
### Declaration

```swift
// Declaration in Swift
public mutating func deleteDocument() throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // DID document exists in the wallet
    try didManager.deleteDocument()
}
```

<br>

## 9. addVerificationMethod

### Description
```
Adds public key information to the "temporary DIDDocument object."
It is primarily used when adding new public key information to a stored DID document.
```

### Declaration

```swift
// Declaration in Swift
public mutating func addVerificationMethod(keyInfo: DIDKeyInfo) throws
```

### Input Parameters

| Name    | Type        | Description                          | **M/O** | **Note**                             |
|---------|-------------|--------------------------------------|---------|---------------------------------------|
| keyInfo | DIDKeyInfo  | Public key information object to register in the DID document | M       | [DIDKeyInfo](#1-didkeyinfo)           |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("No DID document saved in the wallet")
    return
}

let keyInfo = ...    // KeyManager - an element object of the array returned by getKeyInfos
let didKeyInfo = DIDKeyInfo(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication])

try didManager.addVerificationMethod(keyInfo: didKeyInfo)
```

<br>

## 10. removeVerificationMethod

### Description
```
Deletes the public key information in the "Temporary DIDDocument object."
It is mainly used to delete public key information registered in the stored DID document.
```

### Declaration

```swift
// Declaration in Swift
public mutating func removeVerificationMethod(keyId: String) throws
```
### Parameters

| Name      | Type   | Description                             | **M/O** | **Note**  |
|-----------|--------|-----------------------------------------|---------|-----------|
| keyId     | String | ID of the public key information to be removed from the DID document | M       |           |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("No DID document saved in the wallet")
    return
}

let keyIdToRemove = "pin"

try didManager.removeVerificationMethod(keyId: keyIdToRemove)
```

<br>

## 11. addService

### Description
```
Adds service information to a "Temporary DIDDocument object".
This is mainly used to add service information registered in the stored DID document.
```

### Declaration

```swift
// Declaration in Swift
public mutating func addService(service: DIDDocument.Service) throws
```

### Parameters

| Name        | Type                  | Description                               | **M/O** | **Note** |
|-------------|-----------------------|-------------------------------------------|---------|----------|
| service     | DIDDocument.Service   | Object of service information to be specified in the DID document |    M    | [DIDDocument.Service](#3-diddocumentservice) |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("No DID document saved in the wallet")
    return
}

let service: DIDDocument.Service = .init(id: "service id", type: .linkedDomains, serviceEndpoint: ["http://serviceEndpoint"])

try didManager.addService(service: service)
```

## 12. removeService

### Description
```
Deletes service information from the "temporary DIDDocument object".
It is mainly used to delete service information registered in the stored DID document.
```

### Declaration

```swift
//Declaration in Swift
public mutating func removeService(serviceId: String) throws
```
### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| serviceId | String | Service ID to be deleted from the DID document    |    M    |         |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("No DID document saved in wallet")
    return
}

let serviceId = "serviceId"

try didManager.removeService(serviceId: serviceId)
```

## 13. resetChanges

### Description
```
To reset changes, the "Temporary DIDDocument object" is initialized to nil.
An error occurs if there is no saved DID document file. In other words, it can only be used when a saved DID document file exists.
```

### Declaration

```swift
// Declaration in Swift
public mutating func removeService(serviceId: String) throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("No DID document saved in wallet")
    return
}

try didManager.resetChanges()
```

# OptionSet
## 1. DIDMethodType

### Description

```
A type that specifies the purpose of the keys to register in the DID document.
```

### Declaration

```swift
// Declaration in Swift
public struct DIDMethodType : OptionSet
{
    public let rawValue: Int
    
    public static let assertionMethod       = DIDMethodType(rawValue: 1 << 0)
    public static let authentication        = DIDMethodType(rawValue: 1 << 1)
    public static let keyAgreement          = DIDMethodType(rawValue: 1 << 2)
    public static let capabilityInvocation  = DIDMethodType(rawValue: 1 << 3)
    public static let capabilityDelegation  = DIDMethodType(rawValue: 1 << 4)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
```

# Models

## 1. DIDKeyInfo

### Description

```
An object containing public key information to register in the DID document.
```

### Declaration

```swift
// Declaration in Swift
public struct DIDKeyInfo {
    public var keyInfo: KeyInfo
    public var methodType: DIDMethodType
    public var controller: String?
}
```

### Property

| Name          | Type               | Description                      | **M/O** | **Note**                    |
|---------------|--------------------|----------------------------------|---------|-----------------------------|
| keyInfo     | KeyInfo         | Public key information object returned by KeyManager                                                             |    M    |                             |
| methodType  | DIDMethodType   | Type specifying the purpose of the public key registered in the DID document  | M    |                             |
| controller  | String          | DID to be registered as the controller of the public key in the DID document. If nil, the DID document's id will be registered as the controller. |    O    |                             |

## 2. DIDDocument

### Description

`DID document object provided by the Data Model SDK.` <br>
cf. [Original DIDDocument Link](#list) <!-- needs modification -->

## 3. DIDDocument.Service

`Service object of the DID document provided by the Data Model SDK.` <br>
cf. [Original DIDDocument.Service Link](#list) <!-- needs modification -->

## 4. KeyInfo

### Description

`Key information object retrieved from KeyManager.` <br>
cf. [Original KeyInfo Link](#list) <!-- needs modification -->

