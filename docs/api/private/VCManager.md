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

iOS VCManager API
==

- Topic: VCManager
- Author: Woosang Kim
- Date: 2024-08-28
- Version: v1.0.0

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v1.0.0  | 2024-08-28 | Initial version          |

<div style="page-break-after: always;"></div>

# Table of Contents
- [APIs](#apis)
  - [1. init](#1-init)
  - [2. isAnyCredentialsSaved](#2-isanycredentialssaved)
  - [3. addCredential](#3-addcredential)
  - [4. getCredentials](#4-getcredentials)
  - [5. getAllCredentials](#5-getallcredentials)
  - [6. deleteCredentials](#6-deletecredentials)
  - [7. deleteAllCredentials](#7-deleteallcredentials)
  - [8. makePresentation](#8-makepresentation)
- [Models](#models)
  - [1. ClaimInfo](#1-claiminfo)
  - [2. PresentationInfo](#2-presentationinfo)
  - [3. VerifiableCredential](#3-verifiablecredential)
  - [4. VerifiablePresentation](#4-verifiablepresentation)

# APIs
## 1. init

### Description
```
Creates an instance of VCManager to manage the VC wallet.
```

### Declaration
```swift
// Declaration in Swift
init(fileName: String) throws
```

### Parameters

| Name      | Type   | Description                           | **M/O** | **Note**                                                |
|-----------|--------|---------------------------------------|---------|---------------------------------------------------------|
| fileName  | String | Name of the wallet file to store the VC | M       | Exclude the extension as it is defined internally.       |

### Returns

| Type       | Description               | **M/O** | **Note** |
|------------|---------------------------|---------|----------|
| VCManager  | Instance of VCManager     | M       |          |

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)
```

<br>

## 2. isAnyCredentialsSaved

### Description
```
Check if there is at least one saved VC. (Verify the existence of the VC wallet)
```

### Declaration

```swift
// Declaration in Swift
var isAnyCredentialsSaved: Bool
```

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

if vcManager.isAnyCredentialsSaved {
    // There are VCs saved in the wallet
} else {
    // There are no VCs saved in the wallet
}
```

<br>

## 3. addCredential

### Description
```
Store VC in the wallet.
```

### Declaration

```swift
// Declaration in Swift
func addCredential(credential: VerifiableCredential) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| credential | VerifiableCredential | VC Object   | M        | [VerifiableCredential](#3-verifiablecredential) |

### Returns

Void

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

let vc: VerifiableCredential = try VerifiableCredential(from: "") // Objectified VC data issued by the issuer.

try vcManager.addCredential(credential: vc)
```

<br>

## 4. getCredentials

### Description
```
Returns all VCs from the wallet that match the identifiers.
```

### Declaration

```swift
// Declaration in Swift
func getCredentials(by identifiers: [String]) throws -> [VerifiableCredential]
```

### Parameters

| Name         | Type     | Description                    | **M/O** | **Note**            |
|--------------|----------|--------------------------------|---------|---------------------|
| identifiers  | [String] | Array of VC IDs                | M       |                     |

### Returns

| Type                   | Description                    | **M/O** | **Note**                             |
|------------------------|--------------------------------|---------|--------------------------------------|
| [VerifiableCredential] | Array of VC objects            | M       | [VerifiableCredential](#3-verifiablecredential) |

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("No VC is saved.")
    return
}

let identifiers = ["eedca648-25b3-4892-babc-2fd567da542b", "f175652b-41b3-4a3b-a471-18dbb9a924fa"]
let vcs = try vcManager.getCredentials(by: identifiers)
```

<br>

## 5. getAllCredentials

### Description
```
Returns all VCs stored in the wallet.
```

### Declaration

```swift
// Declaration in Swift
func getAllCredentials() throws -> [VerifiableCredential]
```

### Parameters

N/A

### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| [VerifiableCredential] | Array of VC objects | M | [VerifiableCredential](#3-verifiablecredential) |

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("No saved VCs.")
    return
}

let allVCs = try vcManager.getAllCredentials()
```

<br>

## 6. deleteCredentials

### Description
```
Deletes all VCs in the wallet that match the identifiers.
```

### Declaration

```swift
// Declaration in Swift
func deleteCredentials(by identifiers: [String]) throws
```

### Parameters

| Name        | Type     | Description                | **M/O** | **Note**            |
|-------------|----------|----------------------------|---------|---------------------|
| identifiers | [String] | Array of VC IDs            | M       |                     |

### Returns

Void

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("No saved VCs.")
    return
}

let identifiers = ["eedca648-25b3-4892-babc-2fd567da542b", "f175652b-41b3-4a3b-a471-18dbb9a924fa"]
try vcManager.deleteCredentials(by: identifiers)
```

<br>

## 7. deleteAllCredentials

### Description
```
Deletes the wallet where the VC is stored.
```

### Declaration

```swift
// Declaration in Swift
func deleteAllCredentials() throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("There are no saved VCs.")
    return
}

try vcManager.deleteAllCredentials()
```

<br>

## 8. makePresentation

### Description
```
Returns a VP (VerifiablePresentation) object without Proof.
```

### Declaration

```swift
// Declaration in Swift
func makePresentation(claimInfos: [ClaimInfo], presentationInfo: PresentationInfo) throws -> VerifiablePresentation
```

### Parameters

| Name              | Type               | Description                              | **M/O** | **Note**                         |
|-------------------|--------------------|------------------------------------------|---------|----------------------------------|
| claimInfos        | [ClaimInfo]        | VC information to use for creating VP    | M       | [ClaimInfo](#1-claiminfo)        |
| presentationInfo  | [PresentationInfo] | Meta information to use for creating VP  | M       | [PresentationInfo](#2-presentationinfo) |

### Returns

| Type                   | Description                               | **M/O** | **Note**                                      |
|------------------------|-------------------------------------------|---------|-----------------------------------------------|
| VerifiablePresentation | VP object                                 | M       | [VerifiablePresentation](#4-verifiablepresentation) without Proof |

### Usage

```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("No saved VC.")
    return
}

let claimInfos: [ClaimInfo] = [
    .init(credentialId: "eedca648-25b3-4892-babc-2fd567da542b", claimCodes: ["department", "name"])
]
let presentationInfo: PresentationInfo = .init(holder: "did:omn:3kH8HncYkmRTkLxxipTP9PB3jSXB", validFrom: "2024-07-12T10:48:00Z", validUntil: "2024-07-12T10:50:00Z", verifierNonce: "fbce87d9cfac255867a8d4488650a4fbd")

let vp = try vcManager.makePresentation(claimInfos: claimInfos, presentationInfo: presentationInfo)
```

<br>


# Models

## 1. ClaimInfo

### Description
```
VC information object to be used for VP generation.
```

### Declaration

```swift
// Declaration in Swift
public struct ClaimInfo {
    public var credentialId: String
    public var claimCodes: [String]
}
```

### Property

| Name         | Type     | Description                        | **M/O** | **Note** |
|--------------|----------|------------------------------------|---------|----------|
| credentialId | String   | VC ID                              | M       |          |
| claimCodes   | [String] | Array of claim codes to include in VP from VC | M |          |

## 2. PresentationInfo

### Description
```
Meta information for creating VP.
```

### Declaration

```swift
// Declaration in Swift
public struct PresentationInfo {
    public var holder: String
    public var validFrom: String
    public var validUntil: String
    public var verifierNonce: String
}
```

### Property

| Name          | Type               | Description                      | **M/O** | **Note**                    |
|---------------|--------------------|----------------------------------|---------|-----------------------------|
| holder        | String             | DID of the VC holder             | M       |                             |
| validFrom     | String             | Start date and time of VC validity period | M |                             |
| validUntil    | String             | End date and time of VC validity period   | M |                             |
| verifierNonce | String             | Nonce received from the verifier | M       |                             |

## 3. VerifiableCredential

### Description

`VC (VerifiableCredential) object. Provided by Data Model SDK.` <br>
cf. [Original Link](#Table-of-Contents) <!-- Needs modification -->

## 4. VerifiablePresentation

### Description

`VP (VerifiablePresentation) object. Provided by Data Model SDK.` <br>
cf. [Original Link](#Table-of-Contents) <!-- Needs modification -->
