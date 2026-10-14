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

iOS KeyManager API
==

- Subject: KeyManager
- Writer: JooHyun Park
- Date: 2026-08-06
- Version: v1.0.2

| Version  | Date       | History                      |
| -------- | ---------- | ---------------------------- |
| v1.0.2   | 2026-08-06 | Correct isKeySaved declaration |
| v1.0.1   | 2025-10-13 | Add AuthenticatePin function |
| v1.0.0   | 2024-08-28 | Initial                      |


<div style="page-break-after: always;"></div>


# Table of Contents
- [APIs](#apis)
    - [1. Initializer](#1-initializer)
    - [2. IsAnyKeySaved](#2-isanykeysaved)
    - [3. IsKeySaved](#3-iskeysaved)
    - [4. GenerateKey](#4-generatekey)
    - [5. ChangePin](#5-changepin)
    - [6. AuthenticatePin](#6-authenticatepin)
    - [7. GetKeyInfos by Ids](#7-getkeyinfos-by-ids)
    - [8. GetKeyInfos by VerifyAuthType](#8-getkeyinfos-by-verifyauthtype)
    - [9. DeleteKeys](#9-deletekeys)
    - [10. DeleteAllKeys](#10-deleteallkeys)
    - [11. Sign](#11-sign)
    - [12. Verify](#12-verify)
    - [13. CanKeyAgree](#13-cankeyagree)
    - [14. KeyAgreement](#14-keyagreement)
- [OptionSet](#optionset)
    - [1. VerifyAuthType](#1-verifyauthtype)
- [Enumerators](#enumerators)
    - [1. AlgorithmType](#1-algorithmtype)
    - [2. WalletAccessMethod](#2-walletaccessmethod)
    - [3. SecureEnclaveAccessMethod](#3-secureenclaveaccessmethod)
    - [4. StorageOption](#4-storageoption)
    - [5. KeyAccessMethod](#5-keyaccessmethod)
    - [6. AuthType](#6-authtype)
- [Protocols](#protocols)
    - [1. KeyGenRequestProtocol](#1-keygenrequestprotocol)
    - [2. WalletKeyGenRequestProtocol](#2-walletkeygenrequestprotocol)
    - [3. SecureKeyGenRequestProtocol](#3-securekeygenrequestprotocol)
- [Models](#models)
    - [1. WalletKeyGenRequest](#1-walletkeygenrequest)
    - [2. SecureKeyGenRequest](#2-securekeygenrequest)
    - [3. KeyInfo](#3-keyinfo)


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

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| fileName  | String | File name to be saved      |M        |Exclude its extension|

### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| self | Instance                   |M       |         |


### Usage
```swift
let keyManager = try .init(fileName: "MyWallet")
```

<br>

## 2. IsAnyKeySaved

### Description
`Keys presence state`

### Declaration
`public var isAnyKeysSaved : Bool`

### Usage
```swift
let keyManager = try .init(fileName: "MyWallet")
if keyManager.isAnyKeysSaved
{
    try keyManager.deleteAllKeys()
}
```

<br>

## 3. IsKeySaved

### Description
`Returns presence of key named by id`

### Declaration

```swift
// Declaration in swift
func isKeySaved(id : String) throws -> Bool
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| id        | String | Key name                   |    M    |                     |

### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| Bool | Presence state             |   M    |         |

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")
if try !keyManager.isKeySaved(id: "free")
{
    let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, 
                                             id: "free",
                                             methodType: .none)
}
```

<br>

## 4. GenerateKey

### Description
`Generate the key which has given request`

### Declaration

```swift
// Declaration in swift
func generateKey(keyGenRequest : KeyGenRequestProtocol) throws
```

### Parameters

| Name          | Type                  | Description                                     | **M/O** | **Note**                       |
|---------------|-----------------------|-------------------------------------------------|---------|--------------------------------|
| keyGenRequest | KeyGenRequestProtocol | Request which conforms to KeyGenRequestProtocol |    M    |[KeyGenRequestProtocol](#1-keygenrequestprotocol)|

### Returns

Void

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")
//Free
let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, 
                                         id: "free",
                                         methodType: .none)
try keyManager.generateKey(keyGenRequest: freeKeyRequest)
//Pin
let pinData : Data = "password".data(using: .utf8)!
let pinKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1,
                                        id: "pin",
                                        methodType: .pin(value: pinData))
try keyManager.generateKey(keyGenRequest: pinKeyRequest)
//Bio
let bioKeyRequest = SecureKeyGenRequest(id: "bio",
                                        accessMethod: .currentSet,
                                        prompt : "Need to authenticate user")
try keyManager.generateKey(keyGenRequest: bioKeyRequest)
```

<br>

## 5. ChangePin

### Description
`Change pin of the key which is walletPin`

### Declaration

```swift
// Declaration in swift
func changePin(id : String, oldPin : Data, newPin : Data) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| id        | String | Key name                   |    M    |         |
| oldPin    | Data   | Current pin of key         |    M    |         |
| newPin    | Data   | New pin of key             |    M    |         |

### Returns

Void

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

let pinID = "pin"
let oldPinData : Data = "password".data(using: .utf8)!
let newPinData : Data = "newPassword".data(using: .utf8)!
try keyManager.changePin(id: pinID, oldPin: oldPinData, newPin: newPinData)
```

<br>

## 6. AuthenticatePin

### Description
`Authenticates pin of the key which is walletPin`

### Declaration

```swift
// Declaration in swift
func authenticatePin(id: String, pin: Data) throws
```

### Parameters

| Name | Type   | Description      | **M/O** | **Note** |
|------|--------|------------------|---------|----------|
| id   | String | Key name         | M       |          |
| pin  | Data   | Pin of key       | M       |          |

### Returns

Void

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

let pinID = "pin"
let pinData : Data = "password".data(using: .utf8)!
try keyManager.authenticatePin(id: pinID, pin: pinData)
```

<br>

## 7. GetKeyInfos by Ids

### Description
`Returns one or more KeyInfo which match by its name`

### Declaration

```swift
// Declaration in swift
@discardableResult
func getKeyInfos(ids : [String]) throws -> [KeyInfo]
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| ids       |[String]| Key names to be find       |    M    |         |

### Returns

| Type      | Description                |**M/O**  | **Note**         |
|-----------|----------------------------|---------|------------------|
| [KeyInfo] | Array of KeyInfo           |    M    |[KeyInfo](#3-keyinfo)|

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")
let keyInfos = try keyManager.getKeyInfos(ids: ["pin", "bio"])
```

<br>

## 8. GetKeyInfos by VerifyAuthType

### Description
`Returns one or more KeyInfo which match the conditions`

### Declaration

```swift
// Declaration in swift
@discardableResult
func getKeyInfos(keyType : VerifyAuthType) throws -> [KeyInfo]
```

### Parameters

| Name      | Type           | Description                | **M/O** | **Note**                |
|-----------|----------------|----------------------------|---------|-------------------------|
| keyType   | VerifyAuthType | Match conditions           |    M    |[VerifyAuthType](#1-verifyauthtype)|

### Returns

| Type      | Description      |**M/O**  | **Note**         |
|-----------|------------------|---------|------------------|
| [KeyInfo] | Array of KeyInfo |    M    |[KeyInfo](#3-keyinfo)|

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")
//Get All keys in stored
let keyInfos = try keyManager.getKeyInfos(keyType: [])

//Get free keys
let freeKeyInfos = try keyManager.getKeyInfos(keyType: .free)

//Get Pin keys
let pinKeyInfos = try keyManager.getKeyInfos(keyType: .pin)

//Get Bio keys
let bioKeyInfos = try keyManager.getKeyInfos(keyType: .bio)

//Get Free or Pin keys
let orKeyInfos = try keyManager.getKeyInfos(keyType: [.free, .pin])

//Get Pin and Bio keys
let andKeyInfos = try keyManager.getKeyInfos(keyType: [.and, .pin, .bio])
```

<br>

## 9. DeleteKeys

### Description
`Delete the keys which match its name`

### Declaration

```swift
// Declaration in swift
func deleteKeys(ids : [String]) throws
```

### Parameters

| Parameter | Type   | Description          | **M/O** | **Note**|
|-----------|--------|----------------------|---------|---------|
| ids       |[String]| Key names to be find |    M    |         |


### Returns

Void

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")
try keyManager.deleteKeys(ids: ["pin", "bio"])
```

<br>

## 10. DeleteAllKeys

### Description
`Delete All keys`

### Declaration

```swift
// Declaration in swift
func deleteAllKeys() throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")
if keyManager.isAnyKeysSaved
{
    try keyManager.deleteAllKeys()
}
```

<br>

## 11. Sign

### Description
`Sign the digest`

### Declaration

```swift
// Declaration in swift
func sign(id : String, pin : Data? = nil, digest : Data, context : LAContext? = nil) throws -> Data
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| id        | String | Key name to be find        |    M    |         |
| pin       | Data   | Pin of key                 |    O    |         |
| digest    | Data   | Data to sign               |    M    | Data must be digest        |
| context   | LAContext | Authentication context to reuse for a Secure Enclave key, so that a confirmation already given covers this signature too |    O    | Default: nil |

### Returns

| Type | Description     |**M/O** | **Note**|
|------|-----------------|--------|---------|
| Data | Signature value |    M   |         |

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

let plainData = "Test".data(using: .utf8)!
let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)

//Not Pin key
let signature1 = try keyManager.sign(id: "free", digest: digest)
        
//Pin key
let signature2 = try keyManager.sign(id: "pin", pin: pinData, digest: digest)
```

<br>

## 12. Verify

### Description
`Verify the signature value`

### Declaration

```swift
// Declaration in swift
func verify(algorithmType : AlgorithmType, publicKey : Data, digest : Data, signature : Data) throws -> Bool
```

### Parameters

| Name          | Type          | Description                                         | **M/O** | **Note**               |
|---------------|---------------|-----------------------------------------------------|---------|------------------------|
| algorithmType | AlgorithmType | Signature value Algorithm type                      |    M    |[AlgorithmType](#1-algorithmtype)|
| publicKey     | Data          | Public key of the private key used in the signature |    M    |                        |
| digest        | Data          | Digest data                                         |    M    | Data must be digest                       |
| signature     | Data          | Signature value                                     |    M    |                        |

### Returns

| Type | Description                |**M/O** | **Note**                                                                       |
|------|----------------------------|--------|--------------------------------------------------------------------------------|
| Bool | Verification result        |   M    | Return `false` when not match with recovered public key, otherway error occurs |

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

let plainData = "Test".data(using: .utf8)!
let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)
  
let publicKey = try MultibaseUtils.decode(encoded: "zeZDsJJfZxggomwKnwPEdpMKtGvxQANRbJjXMdHsG2SXx")
let signature = try MultibaseUtils.decode(encoded: "z3uF8E6tiEtHqYEFTVE2sL2L1dYDFxgnMyhs9jzu3ZvYxDhPmFRpyM85EAtGmau8ajfEQxqxKpHhVSUSYyRYn2XEV1")
        
let result = try keyManager.verify(algorithmType: .secp256r1, publicKey: publicKey, digest: digest, signature: signature)
```

<br>

## 13. CanKeyAgree

### Description
`Whether the key can perform ECDH key agreement`

A software key (`walletNone`, `walletPin`) always can. A Secure Enclave key is asked about itself: one generated without key exchange support cannot, and nothing on the wallet side changes that. Whether a PIN is needed is a separate matter — a PIN-protected key needs its PIN at `keyAgreement` time, as it does to sign.

### Declaration

```swift
// Declaration in swift
func canKeyAgree(id : String) throws -> Bool
```

### Parameters

| Name | Type   | Description         | **M/O** | **Note** |
|------|--------|---------------------|---------|----------|
| id   | String | Key name to be find |    M    |          |

### Returns

| Type | Description                       | **M/O** | **Note** |
|------|-----------------------------------|---------|----------|
| Bool | Whether the key can do ECDH       |    M    | `false` when no key is stored under `id` |

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

if try keyManager.canKeyAgree(id: "free")
{
    // ECDH is available for this key
}
```

<br>

## 14. KeyAgreement

### Description
`Compute the raw ECDH shared secret between the key and a peer public key`

Returns the raw shared secret (the x-coordinate `Z`, 32 bytes) with no KDF applied; derive keys from it with the KDF the protocol calls for.

### Declaration

```swift
// Declaration in swift
func keyAgreement(id : String, pin : Data? = nil, publicKey : Data, context : LAContext? = nil) throws -> Data
```

### Parameters

| Name      | Type      | Description                                   | **M/O** | **Note** |
|-----------|-----------|-----------------------------------------------|---------|----------|
| id        | String    | Key name to be find                           |    M    |          |
| pin       | Data      | Pin of key                                    |    O    | Used only for a PIN-protected software key, as in `sign` |
| publicKey | Data      | Peer public key                               |    M    | Uncompressed P-256 point (`0x04‖x‖y`, 65 bytes) |
| context   | LAContext | Authentication context to reuse for a Secure Enclave key, so that one confirmation covers several key uses |    O    | Default: nil |

### Returns

| Type | Description          | **M/O** | **Note** |
|------|----------------------|---------|----------|
| Data | Raw shared secret    |    M    | 32 bytes |

### Errors
- Empty `id` or `publicKey`: invalid parameter error
- A `publicKey` that is not a valid P-256 point: invalid parameter error for a software key, `keyAgreement` error for a Secure Enclave key
- A `secureEnclaveCurrentSet` key after the enrolled biometrics changed: `userBiometricsChanged`
- A Secure Enclave key without key exchange support: `keyAgreementUnsupported` (check with `canKeyAgree` first)

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

// peerPublicKey: 65-byte uncompressed point (0x04||x||y)
//Not Pin key
let secret1 = try keyManager.keyAgreement(id: "free", publicKey: peerPublicKey)

//Pin key
let secret2 = try keyManager.keyAgreement(id: "pin", pin: pinData, publicKey: peerPublicKey)
```

<br>

# OptionSet
## 1. VerifyAuthType

### Description

`Declared in External SDK / Indicate access method for Key and presentation option. Similar to AuthType`

### Declaration

```swift
public struct VerifyAuthType : OptionSet, Sequence, Codable, Sendable
{
    public let rawValue: Int
    
    public static let free = VerifyAuthType(rawValue: 1 << 0)
    public static let pin  = VerifyAuthType(rawValue: 1 << 1)
    public static let bio  = VerifyAuthType(rawValue: 1 << 2)
    
    public static let and  = VerifyAuthType(rawValue: 1 << 15)
}
```

<br>

# Enumerators

## 1. AlgorithmType

### Description

`Declared in External SDK / Indicate Algorithm type`

### Declaration

```swift
// Declaration in swift
public enum AlgorithmType : String, Codable
{
    case rsa       = "Rsa"
    case secp256k1 = "Secp256k1"
    case secp256r1 = "Secp256r1"
}
```

<br>

## 2. WalletAccessMethod

### Description

`Access method in Wallet`

### Declaration

```swift
// Declaration in swift
public enum WalletAccessMethod
{
    case none
    case pin(value : Data)
}
```

<br>

## 3. SecureEnclaveAccessMethod

### Description

`Access method in Secure Enclave`

### Declaration

```swift
// Declaration in swift
public enum SecureEnclaveAccessMethod : Int, Codable
{
    case none       = 0
    case currentSet = 1
    case any        = 2
}
```

<br>

## 4. StorageOption

### Description

`Indicate key storage`

### Declaration

```swift
// Declaration in swift
public enum StorageOption : Int, Codable
{
    case wallet         = 0
    case secureEnclave  = 1
}
```

<br>

## 5. KeyAccessMethod

### Description

`Indicate key storage and its access method`

### Declaration

```swift
// Declaration in swift
public enum KeyAccessMethod : Int, Codable
{
    case walletNone = 0
    case walletPin  = 1
    case secureEnclaveNone       = 8
    case secureEnclaveCurrentSet = 9
    case secureEnclaveAny        = 10
}
```

<br>

## 6. AuthType

### Description

`Declared in External SDK / Indicate access method for Key`

### Declaration

```swift
// Declaration in swift
public enum AuthType : Int, Codable, Sendable
{
    case free = 1
    case pin  = 2
    case bio  = 4
}
```

<br>

# Protocols

## 1. KeyGenRequestProtocol

### Description

`General KeyGenRequest Protocol`

### Declaration

```swift
// Declaration in swift
public protocol KeyGenRequestProtocol
{
    var algorithmType : AlgorithmType { get }
    var id : String { get }
    var storage : StorageOption { get }
}
```

### Property

| Name          | Type            | Description                | **M/O** | **Note**               |
|---------------|-----------------|----------------------------|---------|------------------------|
| algorithmType | AlgorithmType   | Algorithm type for Key     |    M    |[AlgorithmType](#1-algorithmtype)|
| id            | String          | Key name                   |    M    |                        |
| storage       | StorageOption   | Key storage                |    M    |[StorageOption](#4-storageoption)|

<br>

## 2. WalletKeyGenRequestProtocol

### Description

`KeyGenRequest Protocol for Wallet Storage`

### Declaration

```swift
// Declaration in swift
public protocol WalletKeyGenRequestProtocol : KeyGenRequestProtocol
{
    var accessMethod : WalletAccessMethod { get }
}
```

### Property

| Name          | Type               | Description              | **M/O** | **Note**                    |
|---------------|--------------------|--------------------------|---------|-----------------------------|
| accessMethod  | WalletAccessMethod | Access method for Wallet |    M    |[WalletAccessMethod](#2-walletaccessmethod)|

<br>

## 3. SecureKeyGenRequestProtocol

### Description

`KeyGenRequest Protocol for Secure Enclave`

### Declaration

```swift
// Declaration in swift
public protocol SecureKeyGenRequestProtocol : KeyGenRequestProtocol
{
    var accessMethod : SecureEnclaveAccessMethod { get }
    var prompt : String { get }
}
```

### Property

| Name          | Type                      | Description                     | **M/O** | **Note**                           |
|---------------|---------------------------|---------------------------------|---------|------------------------------------|
| accessMethod  | SecureEnclaveAccessMethod | Access method for Secure Enclave|    M    |[SecureEnclaveAccessMethod](#3-secureenclaveaccessmethod)|
| prompt        | String                    | Description for Touch ID usage  |    M    |                                    |

<br>

# Models

## 1. WalletKeyGenRequest

### Description

`Data Model for Wallet key creation`

### Declaration

```swift
// Declaration in swift
public struct WalletKeyGenRequest : WalletKeyGenRequestProtocol
{
    public var algorithmType: AlgorithmType
    public var id: String
    public var accessMethod: WalletAccessMethod
    public let storage: StorageOption = .wallet
}
```

### Property

| Name          | Type               | Description                | **M/O** | **Note**                    |
|---------------|--------------------|----------------------------|---------|-----------------------------|
| algorithmType | AlgorithmType      | Algorithm type for Key     |    M    |[AlgorithmType](#1-algorithmtype)     |
| id            | String             | Key name                   |    M    |                             |
| accessMethod  | WalletAccessMethod | Access method for Wallet   |    M    |[WalletAccessMethod](#2-walletaccessmethod)|
| storage       | StorageOption      | Key storage                |    M    |[StorageOption](#4-storageoption)     |

<br>

## 2. SecureKeyGenRequest

### Description

`Data Model for Secure Enclave key creation`

### Declaration

```swift
// Declaration in swift
public struct SecureKeyGenRequest : SecureKeyGenRequestProtocol
{
    public let algorithmType: AlgorithmType = .secp256r1
    public var id: String
    public var accessMethod: SecureEnclaveAccessMethod
    public let storage: StorageOption = .secureEnclave
    public var prompt       : String
}
```

### Property

| Name          | Type                      | Description                     | **M/O** | **Note**                           |
|---------------|---------------------------|---------------------------------|---------|------------------------------------|
| algorithmType | AlgorithmType             | Algorithm type for Key          |    M    |[AlgorithmType](#1-algorithmtype)            |
| id            | String                    | Key name                        |    M    |                                    |
| accessMethod  | SecureEnclaveAccessMethod | Access method for Secure Enclave|    M    |[SecureEnclaveAccessMethod](#3-secureenclaveaccessmethod)|
| storage       | StorageOption             | Key storage                     |    M    |[StorageOption](#4-storageoption)            |
| prompt        | String                    | Description for Touch ID usage  |    M    |                                    |

<br>

## 3. KeyInfo

### Description

`Data Model for Key Information`

### Declaration

```swift
// Declaration in swift
public struct KeyInfo : MetaProtocol
{
    public var algorithmType : AlgorithmType
    public var id            : String
    public var accessMethod  : KeyAccessMethod
    public var authType      : AuthType
    public var publicKey     : String
}
```

### Property

| Name          | Type            | Description                                | **M/O** | **Note**                 |
|---------------|-----------------|--------------------------------------------|---------|--------------------------|
| algorithmType | AlgorithmType   | Algorithm type for Key                     |    M    |[AlgorithmType](#1-algorithmtype)  |
| id            | String          | Key name                                   |    M    |                          |
| accessMethod  | KeyAccessMethod | Indicate key storage and its access method |    M    |[KeyAccessMethod](#5-keyaccessmethod)|
| authType      | AuthType        | Access method                              |    M    |[AuthType](#6-authtype)       |
| publicKey     | String          | Public key                                 |    M    |Encoded by Multibase      |
