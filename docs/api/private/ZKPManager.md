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

iOS ZKPManager API
==

- Subject: ZKPManager
- Writer: JooHyun Park
- Date: 2025-05-27
- Version: v2.0.0

| Version          | Date       | History                           |
| ---------------- | ---------- | ----------------------------------|
| v2.0.0           | 2025-05-27 | Add isCredentialSaved function    |
| v1.0.0           | 2025-04-24 | Initial                           |


<div style="page-break-after: always;"></div>


# Table of Contents
- [APIs](#apis)
    - [1. init](#1-init)
    - [2. IsAnyCredentialsSaved](#2-isanycredentialssaved)
    - [3. isCredentialSaved](#3-iscredentialsaved)
    - [4. CreateCredentialRequest](#4-createcredentialrequest)
    - [5. VerifyAndStoreCredential](#5-verifyandstorecredential)
    - [6. GetAllCredentials](#6-getallcredentials)
    - [7. GetCredentials](#7-getcredentials)
    - [8. RemoveAllCredentials](#8-removeallcredentials)
    - [9. RemoveCredentials](#9-removecredentials)
    - [10. SearchCredentials](#10-searchcredentials)
    - [11. CreateProof](#11-createproof)



# APIs
## 1. Initializer

### Description
`Initializer(Constructor)`

### Declaration

```swift
// Declaration in swift
public init(fileName : String) throws
```

### Parameters

| Name     | Type   | Description                       | **M/O** | **Note**              |
|----------|--------|-----------------------------------|---------|-----------------------|
| fileName | String | Name to use when saving the file  | M       | Exclude its extension |


### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| self | Instance                   |M       |         |


### Usage
```swift
let zkpManager = try ZKPManager(fileName: "zkpWallet")
```

<br>

## 2. IsAnyCredentialsSaved

### Description
`Check if there is at least one saved ZKPCredential.`

### Declaration

```swift
public var isAnyCredentialsSaved : Bool
```

### Usage

```swift
if ! zkpManager.isAnyCredentialsSaved {
    print("No ZKP Credential is saved in the wallet.")
}
```

<br>

## 3. isCredentialSaved

### Description
`Check whether a specific ZKPCredential exists by its identifier.`

### Declaration

```swift
public func isCredentialSaved(by identifier : String) -> Bool
```

### Parameters

| Name       | Type   | Description                            | **M/O** | **Note** |
|------------|--------|----------------------------------------|---------|----------|
| identifier | String | Specific identifier for the credential | M       |          |


### Returns

| Type  | Description         | **M/O** | **Note** |
|-------|---------------------|---------|----------|
| Bool  | State of existence  | M       |          |

### Usage
```swift
if !zkpManager.isCredentialSaved(by: "id") {
    print("id for ZKP Credential is not saved.")
}
```

<br>

## 4. CreateCredentialRequest

### Description
`Creates the CredentialRequest and its meta`

### Declaration

```swift
public func createCredentialRequest(proverDid : String,
                                    credentialPublicKey : CredentialPrimaryPublicKey,
                                    credOffer : ZKPCredentialOffer) throws -> ZKPCredentialRequestContainer
```

### Parameters

| Name                | Type                       | Description                                                       | **M/O** | **Note** |
|---------------------|----------------------------|-------------------------------------------------------------------|---------|----------|
| proverDid           | String                     | The prover's DID                                                  | M       |          |
| credentialPublicKey | CredentialPrimaryPublicKey | The `primary` of the credential definition’s `value`              | M       |          |
| credOffer           | ZKPCredentialOffer         | ZKPCredentialOffer                                                | M       |          |

### Returns

| Type                          | Description                                         | **M/O** | **Note** |
|-------------------------------|-----------------------------------------------------|---------|----------|
| ZKPCredentialRequestContainer | The object contains credential request and its meta | M       |          |

### Usage
```swift
let proverDid : String
let credentialDefinition : ZKPCredentialDefinition
let credOffer : ZKPCredentialOffer
let container = try zkpManager.createCredentialRequest(proverDid: proverDid,
                                                       credentialPublicKey: credentialDefinition.value.primary,
                                                       credOffer: credOffer)
```

<br>

## 5. VerifyAndStoreCredential

### Description
`Verifies and stores a ZKP credential.`

### Declaration

```swift
public func verifyAndStoreCredential(credentialMeta : ZKPCredentialRequestMeta,
                                     publicKey : CredentialPrimaryPublicKey,
                                     credential : ZKPCredential) throws
```

### Parameters

| Name           | Type                       | Description                                          | **M/O** | **Note** |
|----------------|----------------------------|------------------------------------------------------|---------|----------|
| credentialMeta | ZKPCredentialRequestMeta   | Metadata from the credential request                 | M       |          |
| publicKey      | CredentialPrimaryPublicKey | The `primary` of the credential definition’s `value` | M       |          |
| credential     | ZKPCredential              | The credential to be verified and stored             | M       |          |

### Returns

Void

### Usage
```swift
let container
let credentialDefinition : ZKPCredentialDefinition
let credential : ZKPCredential
try zkpManager.verifyAndStoreCredential(credentialMeta: container.credentialRequestMeta,
                                        publicKey: credentialDefinition.value.primary,
                                        credential: credential)
```

<br>

## 6. GetAllCredentials

### Description
`Returns all stored ZKP credentials.`

### Declaration

```swift
public func getAllCredentials() throws -> [ZKPCredential]
```

### Returns

| Type            | Description                    | **M/O** | **Note** |
|-----------------|--------------------------------|---------|----------|
| [ZKPCredential] | Array of all saved credentials | M       |          |

### Usage
```swift
let zkpCredentials = try zkpManager.getAllCredentials()
```

<br>

## 7. GetCredentials

### Description
`Returns ZKP credentials for the given identifiers.`

### Declaration

```swift
public func getCredentials(by identifiers : [String]) throws -> [ZKPCredential]
```

### Parameters

| Name        | Type     | Description                      | **M/O** | **Note** |
|-------------|----------|----------------------------------|---------|----------|
| identifiers | [String] | A list of credential identifiers | M       |          |

### Returns

| Type            | Description          | **M/O** | **Note** |
|-----------------|----------------------|---------|----------|
| [ZKPCredential] | Matching credentials | M       |          |

### Usage
```swift
let ids = ["id"]
let zkpCredentials = try zkpManager.getCredentials(by: ids)
```

<br>

## 8. RemoveAllCredentials

### Description
`Removes all stored credentials.`

### Declaration

```swift
public func removeAllCredentials() throws
```

### Returns

Void

### Usage
```swift
let zkpCredentials = try zkpManager.removeAllCredentials()
```

<br>

## 9. RemoveCredentials

### Description
`Removes credentials matching the given identifiers.`

### Declaration

```swift
public func removeCredentials(by identifiers : [String]) throws
```

### Parameters

| Name        | Type     | Description                          | **M/O** | **Note** |
|-------------|----------|--------------------------------------|---------|----------|
| identifiers | [String] | An array of credential identifiers   | M       |          |

### Returns

Void

### Usage
```swift
let ids = ["id"]
let zkpCredentials = try zkpManager.removeCredentials(by: ids)
```

<br>

## 10. SearchCredentials

### Description
`Searches for credentials that satisfy the given proof request.`

### Declaration

```swift
public func searchCredentials(proofRequest : ProofRequest) throws -> AvailableReferent
```

### Parameters

| Name         | Type         | Description                                                   | **M/O** | **Note** |
|--------------|--------------|---------------------------------------------------------------|---------|----------|
| proofRequest | ProofRequest | The proof request specifying required attributes and predicates | M       |          |

### Returns

| Type              | Description                        | **M/O** | **Note** |
|-------------------|------------------------------------|---------|----------|
| AvailableReferent | Referents for matching credentials | M       |          |

### Usage
```swift
let proofRequest : ProofRequest
let availableReferent = try zkpManager.searchCredentials(proofRequest: proofRequest)
```

<br>

## 11. CreateProof

### Description
`Creates a zero-knowledge proof based on the given request and selected referents.`

### Declaration

```swift
public func createProof(proofRequest : ProofRequest,
                        selectedReferents : [UserReferent],
                        proofParam : ZKProofParam) throws -> ZKProof
```

### Parameters

| Name              | Type             | Description                                                    | **M/O** | **Note** |
|-------------------|------------------|----------------------------------------------------------------|---------|----------|
| proofRequest      | ProofRequest     | The proof request specifying required attributes and predicates | M       |          |
| selectedReferents | [UserReferent]   | The referents selected by the user to satisfy the proof request | M       |          |
| proofParam        | ZKProofParam     | Additional parameters used to construct the proof               | M       |          |

### Returns

| Type     | Description | **M/O** | **Note** |
|----------|-------------|---------|----------|
| ZKProof  | A ZKProof   | M       |          |

### Usage
```swift
let proofRequest : ProofRequest
let selectedReferents : [UserReferent]
let proofParam : ZKProofParam
let proof =  try zkpManager.createProof(proofRequest: proofRequest,
                                        selectedReferents: selectedReferents,
                                        proofParam: proofParam)
```

<br>