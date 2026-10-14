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

iOS OID4VCManager API
==

- Topic: OID4VCManager
- Author: JooHyun Park
- Date: 2026-10-07
- Version: v1.0.0

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v1.0.0  | 2026-10-07 | Initial version          |

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
- [Models](#models)
  - [1. OID4VCICredential](#1-oid4vcicredential)
  - [2. IssuedCredentialMeta](#2-issuedcredentialmeta)

`OID4VCManager` stores credentials issued through OpenID4VCI (SD-JWT, mdoc, …) as the issuer returned them. It is the OID4VCI counterpart of `VCManager`, which stores W3C `VerifiableCredential`s. The wallet file is encrypted; each item's `id` and `format` are kept in plaintext meta so items can be told apart without decrypting them. `WalletCore` creates one instance with the file name `"oid4vc"`.

# APIs
## 1. init

### Description
```
Creates an instance of OID4VCManager to manage the issued-credential wallet.
```

### Declaration
```swift
// Declaration in Swift
public init(fileName: String) throws
```

### Parameters

| Name      | Type   | Description                                      | **M/O** | **Note**                                          |
|-----------|--------|--------------------------------------------------|---------|---------------------------------------------------|
| fileName  | String | Name of the wallet file to store the credentials | M       | Exclude the extension as it is defined internally. Throws when empty |

### Returns

| Type          | Description               | **M/O** | **Note** |
|---------------|---------------------------|---------|----------|
| OID4VCManager | Instance of OID4VCManager | M       |          |

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")
```

<br>

## 2. isAnyCredentialsSaved

### Description
```
Check if there is at least one saved credential. (Verify the existence of the wallet file)
```

### Declaration

```swift
// Declaration in Swift
public var isAnyCredentialsSaved: Bool
```

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")

if oid4vcManager.isAnyCredentialsSaved {
    // There are credentials saved in the wallet
}
```

<br>

## 3. addCredential

### Description
```
Store an issued credential in the wallet.
```

### Declaration

```swift
// Declaration in Swift
func addCredential(credential: OID4VCICredential) throws
```

### Parameters

| Name       | Type              | Description             | **M/O** | **Note** |
|------------|-------------------|-------------------------|---------|----------|
| credential | OID4VCICredential | Issued credential       | M       | [OID4VCICredential](#1-oid4vcicredential). Its `id` and `format` become the item's meta |

### Returns

Void

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")

let credential = OID4VCICredential(id: UUID().uuidString,
                                   format: "dc+sd-jwt-did",
                                   credentialConfigurationId: configurationId,
                                   credentialIdentifier: nil,
                                   kid: "pin",
                                   credential: rawCredential) // As returned by the issuer

try oid4vcManager.addCredential(credential: credential)
```

<br>

## 4. getCredentials

### Description
```
Returns all issued credentials from the wallet that match the identifiers.
```

### Declaration

```swift
// Declaration in Swift
func getCredentials(by identifiers: [String]) throws -> [OID4VCICredential]
```

### Parameters

| Name        | Type     | Description                      | **M/O** | **Note** |
|-------------|----------|----------------------------------|---------|----------|
| identifiers | [String] | Array of issued-credential IDs   | M       | Throws when empty or when an ID repeats |

### Returns

| Type                | Description                     | **M/O** | **Note** |
|---------------------|---------------------------------|---------|----------|
| [OID4VCICredential] | Array of issued credentials     | M       | [OID4VCICredential](#1-oid4vcicredential) |

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")

let credentials = try oid4vcManager.getCredentials(by: ["0f8e7c1a-5b2d-4e3f-9a6b-1c2d3e4f5a6b"])
```

<br>

## 5. getAllCredentials

### Description
```
Returns all issued credentials stored in the wallet.
```

### Declaration

```swift
// Declaration in Swift
func getAllCredentials() throws -> [OID4VCICredential]
```

### Parameters
N/A

### Returns

| Type                | Description                     | **M/O** | **Note** |
|---------------------|---------------------------------|---------|----------|
| [OID4VCICredential] | Array of issued credentials     | M       | [OID4VCICredential](#1-oid4vcicredential) |

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")

guard oid4vcManager.isAnyCredentialsSaved else {
    return
}

let credentials = try oid4vcManager.getAllCredentials()
```

<br>

## 6. deleteCredentials

### Description
```
Deletes all issued credentials in the wallet that match the identifiers.
```

### Declaration

```swift
// Declaration in Swift
func deleteCredentials(by identifiers: [String]) throws
```

### Parameters

| Name        | Type     | Description                      | **M/O** | **Note** |
|-------------|----------|----------------------------------|---------|----------|
| identifiers | [String] | Array of issued-credential IDs   | M       | Throws when empty or when an ID repeats |

### Returns

Void

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")

try oid4vcManager.deleteCredentials(by: ["0f8e7c1a-5b2d-4e3f-9a6b-1c2d3e4f5a6b"])
```

<br>

## 7. deleteAllCredentials

### Description
```
Deletes the wallet where the issued credentials are stored.
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
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")

try oid4vcManager.deleteAllCredentials()
```

<br>

# Models

## 1. OID4VCICredential

### Description
```
A credential issued through OpenID4VCI, stored as-is with the metadata needed to identify and re-match it.
```

### Declaration

```swift
// Declaration in Swift
struct OID4VCICredential: Jsonable {
    public let id: String
    public let format: String
    public let credentialConfigurationId: String
    public let credentialIdentifier: String?
    public let kid: String
    public let credential: String

    public init(id: String, format: String, credentialConfigurationId: String,
                credentialIdentifier: String?, kid: String, credential: String)
}
```

### Property

| Name                      | Type   | Description | **M/O** | **Note** |
|---------------------------|--------|-------------|---------|----------|
| id                        | String | Storage primary key | M | Wallet-generated UUID, unique per issuance. The issuer-side identifiers below can be shared across credentials, so they are not used as the key |
| format                    | String | Credential format token | M | e.g. `dc+sd-jwt-did`, `mso_mdoc-did` |
| credentialConfigurationId | String | `credential_configuration_id` the credential was issued under | M | |
| credentialIdentifier      | String | Issuer-assigned `credential_identifier` | O | Only when the issuer used identifiers |
| kid                       | String | Holder key ID the key-binding proof was signed with at issuance | M | `"pin"` or `"bio"`. Reused when presenting the credential |
| credential                | String | Raw credential as returned by the issuer | M | SD-JWT compact, mdoc base64url, … |

<br>

## 2. IssuedCredentialMeta

### Description
```
Plaintext meta of a stored item, so items can be filtered by format without decrypting them.
```

### Declaration

```swift
// Declaration in Swift
struct IssuedCredentialMeta: MetaProtocol {
    public var id: String
    public var format: String
}
```

### Property

| Name   | Type   | Description             | **M/O** | **Note** |
|--------|--------|-------------------------|---------|----------|
| id     | String | Same as `OID4VCICredential.id`     | M | |
| format | String | Same as `OID4VCICredential.format` | M | |
