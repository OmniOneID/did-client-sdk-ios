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
- Date: 2025-04-24
- Version: v1.0.0

| Version          | Date       | History                           |
| ---------------- | ---------- | ----------------------------------|
| v1.0.0           | 2025-04-24 | Initial                           |


<div style="page-break-after: always;"></div>


# Table of Contents
- [APIs](#apis)
    - [1. init](#1-init)
    - [2. IsAnyCredentialsSaved](#2-isanycredentialssaved)
    - [3. CreateCredentialRequest](#3-createcredentialrequest)
    - [4. VerifyAndStoreCredential](#4-verifyandstorecredential)
    - [5. GetAllCredentials](#5-getallcredentials)
    - [6. GetCredentials](#6-getcredentials)
    - [7. RemoveAllCredentials](#7-removeallcredentials)
    - [8. RemoveCredentials](#8-removecredentials)
    - [9. SearchCredentials](#9-searchcredentials)
    - [10. CreateProof](#10-createproof)


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

## 3. CreateCredentialRequest

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

<br>

## 4. VerifyAndStoreCredential

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

<br>

## 5. GetAllCredentials

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

<br>

## 6. GetCredentials

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

<br>

## 7. RemoveAllCredentials

### Description
`Removes all stored credentials.`

### Declaration

```swift
public func removeAllCredentials() throws
```

### Returns

Void

<br>

## 8. RemoveCredentials

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

<br>

## 9. SearchCredentials

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

<br>

## 10. CreateProof

### Description
`Creates a zero-knowledge proof based on the given request and selected referents.`

### Declaration

```swift
public func createProof(proofRequest : ProofRequest,
                        selectedReferents : [UserReferent],
                        proofParam : ZKPProofParam) throws -> ZKPProof
```

### Parameters

| Name              | Type             | Description                                                    | **M/O** | **Note** |
|-------------------|------------------|----------------------------------------------------------------|---------|----------|
| proofRequest      | ProofRequest     | The proof request specifying required attributes and predicates | M       |          |
| selectedReferents | [UserReferent]   | The referents selected by the user to satisfy the proof request | M       |          |
| proofParam        | ZKPProofParam    | Additional parameters used to construct the proof               | M       |          |

### Returns

| Type     | Description | **M/O** | **Note** |
|----------|-------------|---------|----------|
| ZKPProof | A ZKP proof | M       |          |
