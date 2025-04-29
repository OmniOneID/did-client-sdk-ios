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
- Writer: 박주현
- Date: 2024-08-28
- Version: v1.0.0

| Version          | Date       | History                 |
| ---------------- | ---------- | ------------------------|
| v1.0.0           | 2024-08-28 | 초기 작성                 |


<div style="page-break-after: always;"></div>


# 목차
- [APIs](#apis)
    - [1. Initializer](#1-initializer)
    - [2. IsAnyKeySaved](#2-isanykeysaved)
    - [3. IsKeySaved](#3-iskeysaved)
    - [4. GenerateKey](#4-generatekey)
    - [5. ChangePin](#5-changepin)
    - [6. GetKeyInfos by Ids](#6-getkeyinfos-by-ids)
    - [7. GetKeyInfos by VerifyAuthType](#7-getkeyinfos-by-verifyauthtype)
    - [8. DeleteKeys](#8-deletekeys)
    - [9. DeleteAllKeys](#9-deleteallkeys)
    - [10. Sign](#10-sign)
    - [11. Verify](#11-verify)
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
`생성자`

### Declaration

```swift
// Declaration in swift
public init(fileName : String) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| fileName  | String | 저장된 파일명                 |M        |확장자는 제외된 파일명     |

### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| self | 인스턴스                     |M       |         |


### Usage
```swift
let keyManager = try .init(fileName: "MyWallet")
```

<br>

## 2. IsAnyKeySaved

### Description
`(그 어떤)키 존재 상태`

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
`키의 이름과 일치하는 키의 저장상태를 반환한다.`

### Declaration

```swift
// Declaration in swift
public func isKeySaved(id : String) -> Bool
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| id        | String | 키 이름                      |    M    |                     |

### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| Bool | 존재 여부                    |   M    |         |

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")
if !keyManager.isKeySaved(id: "free")
{
    let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, 
                                             id: "free",
                                             accessMethod: .none)
}
```

<br>

## 4. GenerateKey

### Description
`주어진 요청에 따라 키를 생성한다.`

### Declaration

```swift
// Declaration in swift
public func generateKey(keyGenRequest : KeyGenRequestProtocol) throws
```

### Parameters

| Name          | Type                  | Description                                     | **M/O** | **Note**                       |
|---------------|-----------------------|-------------------------------------------------|---------|--------------------------------|
| keyGenRequest | KeyGenRequestProtocol | KeyGenRequestProtocol을 따르는 요청값               |    M    |[KeyGenRequestProtocol](#1-keygenrequestprotocol)|

### Returns

Void

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")
//Free
let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, 
                                         id: "free",
                                         accessMethod: .none)
try keyManager.generateKey(keyGenRequest: freeKeyRequest)
//Pin
let pinData : Data = "password".data(using: .utf8)!
let pinKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1,
                                        id: "pin",
                                        accessMethod: .pin(value: pinData))
try keyManager.generateKey(keyGenRequest: pinKeyRequest)
//Bio
let bioKeyRequest = SecureKeyGenRequest(id: "bio",
                                        accessMethod: .currentSet
                                        prompt : "Need to authenticate user")
try keyManager.generateKey(keyGenRequest: bioKeyRequest)
```

<br>

## 5. ChangePin

### Description
`walletPin인 키의 pin을 변경한다.`

### Declaration

```swift
// Declaration in swift
public func changePin(id : String, oldPin : Data, newPin : Data) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| id        | String | 키 이름                     |    M    |         |
| oldPin    | Data   | 현재 키의 pin                |    M    |         |
| newPin    | Data   | 신규 pin                    |    M    |         |

### Returns

Void

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")

let oldPinData : Data = "password".data(using: .utf8)!
let newPinData : Data = "newPassword".data(using: .utf8)!
try keyManager.changePin(id: pinID, oldPin: oldPinData, newPin: newPinData)
```

<br>

## 6. GetKeyInfos by Ids

### Description
`이름과 일치하는 하나 이상의 KeyInfo를 반환한다.`

### Declaration

```swift
// Declaration in swift
@discardableResult
public func getKeyInfos(ids : [String]) throws -> [KeyInfo]
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| ids       |[String]| 찾을 키의 이름                |    M    |         |

### Returns

| Type      | Description                |**M/O**  | **Note**         |
|-----------|----------------------------|---------|------------------|
| [KeyInfo] | KeyInfo 배열                |    M    |[KeyInfo](#3-keyinfo)|

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")
let keyInfos = try keyManager.getKeyInfos(ids: ["pin", "bio"])
```

<br>

## 7. GetKeyInfos by VerifyAuthType

### Description
`조건과 일치하는 하나 이상의 KeyInfo을 반환한다.`

### Declaration

```swift
// Declaration in swift
@discardableResult
public func getKeyInfos(keyType : VerifyAuthType) throws -> [KeyInfo]
```

### Parameters

| Name      | Type           | Description                | **M/O** | **Note**                |
|-----------|----------------|----------------------------|---------|-------------------------|
| keyType   | VerifyAuthType | 키를 찾을 조건                |    M    |[VerifyAuthType](#1-verifyauthtype)|

### Returns

| Type      | Description      |**M/O**  | **Note**         |
|-----------|------------------|---------|------------------|
| [KeyInfo] | KeyInfo 배열      |    M    |[KeyInfo](#3-keyinfo)|

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")
//저장된 모든 키 찾기
let keyInfos = try keyManager.getKeyInfos(keyType: [])

//무인증 키 찾기
let freeKeyInfos = try keyManager.getKeyInfos(keyType: .free)

//Pin 키 찾기
let pinKeyInfos = try keyManager.getKeyInfos(keyType: .pin)

//Bio 키 찾기
let bioKeyInfos = try keyManager.getKeyInfos(keyType: .bio)

//무인증 또는 Pin 키 찾기
let orKeyInfos = try keyManager.getKeyInfos(keyType: [.free, .pin])

//Pin 키와 Bio 키 찾기
let andKeyInfos = try keyManager.getKeyInfos(keyType: [.and, .pin, .bio])
```

<br>

## 8. DeleteKeys

### Description
`이름과 일치하는 키를 삭제한다.`

### Declaration

```swift
// Declaration in swift
public func deleteKeys(ids : [String]) throws
```

### Parameters

| Parameter | Type   | Description          | **M/O** | **Note**|
|-----------|--------|----------------------|---------|---------|
| ids       |[String]| 찾을 키 이름            |    M    |         |


### Returns

Void

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")
try keyManager.deleteKeys(ids: ["pin", "bio"])
```

<br>

## 9. DeleteAllKeys

### Description
`모든 키를 삭제한다.`

### Declaration

```swift
// Declaration in swift
public func deleteAllKeys() throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")
if keyManager.isAnyKeysSaved
{
    try keyManager.deleteAllKeys()
}
```

<br>

## 10. Sign

### Description
`해시된 값을 서명한다.`

### Declaration

```swift
// Declaration in swift
public func sign(id : String, pin : Data? = nil, digest : Data) throws -> Data
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| id        | String | 찾을 키 이름                  |    M    |         |
| pin       | Data   | 키의 Pin                    |    O    |                  |
| digest    | Data   | 서명할 값                    |    M    | 해시된 값이어야 한다. |

### Returns

| Type | Description     |**M/O** | **Note**|
|------|-----------------|--------|---------|
| Data | 서명값           |    M   |         |

### Usage
```swift
import OpenDIDCryptoSDK

let keyManager = KeyManager(fileName: "MyWallet")

let plainData = "Test".data(using: .utf8)!
let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)

//Pin 키가 아닐 경우
let signature1 = try keyManager.sign(id: "free", digest: digest)
        
//Pin 키의 경우
let signature2 = try keyManager.sign(id: "pin", pin: pinData, digest: digest)
```

<br>

## 11. Verify

### Description
`서명값을 검증한다.`

### Declaration

```swift
// Declaration in swift
public func verify(algorithmType : AlgorithmType, publicKey : Data, digest : Data, signature : Data) throws -> Bool
```

### Parameters

| Name          | Type          | Description                                         | **M/O** | **Note**               |
|---------------|---------------|-----------------------------------------------------|---------|------------------------|
| algorithmType | AlgorithmType | 서명값의 알고리즘 타입                                   |    M    |[AlgorithmType](#1-algorithmtype)|
| publicKey     | Data          | 서명에 사용된 개인키의 공개키                              |    M    |                        |
| digest        | Data          | 해시된 서명 원문                                        |    M    |                        |
| signature     | Data          | 서명값                                                |    M    | 해시된 값이어야 한다.       |

### Returns

| Type | Description                |**M/O** | **Note**                                                     |
|------|----------------------------|--------|--------------------------------------------------------------|
| Bool | 검증 결과                    |   M    | 공개키 비교 검증 실패일 경우 false값이 반환되며, 그 외의 경우 에러가 발생한다.|

### Usage
```swift
let keyManager = KeyManager(fileName: "MyWallet")

let plainData = "Test".data(using: .utf8)!
let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)
  
let publicKey = try MultibaseUtils.decode(encoded: "zeZDsJJfZxggomwKnwPEdpMKtGvxQANRbJjXMdHsG2SXx")
let signature = try MultibaseUtils.decode(encoded: "z3uF8E6tiEtHqYEFTVE2sL2L1dYDFxgnMyhs9jzu3ZvYxDhPmFRpyM85EAtGmau8ajfEQxqxKpHhVSUSYyRYn2XEV1")
        
let result = try keyManager.verify(algorithmType: .secp256r1, publicKey: publicKey, digest: digest, signature: signature)
```

<br>

# OptionSet
## 1. VerifyAuthType

### Description

`외부 SDK에 선언됨 / 키의 접근 방법과 제출 옵션을 가리킨다. AuthType과 유사하다.`

### Declaration

```swift
public struct VerifyAuthType : OptionSet, Sequence, Codable
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

`외부 SDK에 선언됨 / 알고리즘 타입`

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

`월렛에 저장된 키의 접근 방법`

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

`Secure Enclave에 저장된 키의 접근 방법`

### Declaration

```swift
// Declaration in swift
public enum SecureEnclaveAccessMethod
{
    case none
    case currentSet
    case any
}
```

<br>

## 4. StorageOption

### Description

`키의 저장소`

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

`키의 저장소와 접근 방법을 가리킨다.`

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

`외부 SDK에 선언됨 / 키의 접근 방법을 가리킨다.`

### Declaration

```swift
// Declaration in swift
public enum AuthType : Int, Codable
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

`KeyGenRequest 프로토콜 원형`

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
| algorithmType | AlgorithmType   | 키의 알고리즘 타입             |    M    |[AlgorithmType](#1-algorithmtype)|
| id            | String          | 키 이름                   |    M    |                        |
| storage       | StorageOption   | 키 저장소                |    M    |[StorageOption](#4-storageoption)|

<br>

## 2. WalletKeyGenRequestProtocol

### Description

`월렛 저장소를 위한 KeyGenRequest 프로토콜`

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
| accessMethod  | WalletAccessMethod | 월렛에 저장된 키의 접근 방법    |    M    |[WalletAccessMethod](#2-walletaccessmethod)|

<br>

## 3. SecureKeyGenRequestProtocol

### Description

`시큐어 인클레이브 저장소를 위한 KeyGenRequest 프로토콜`

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
| accessMethod  | SecureEnclaveAccessMethod | 시큐어 인클레이브에 저장된 키의 접근 방법|    M    |[SecureEnclaveAccessMethod](#3-secureenclaveaccessmethod)|
| prompt        | String                    | Touch ID 사용에 대한 설명           |    M    |                                    |

<br>

# Models

## 1. WalletKeyGenRequest

### Description

`월렛 키 생성을 위한 데이터모델`

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
| algorithmType | AlgorithmType      | 키의 알고리즘 타입             |    M    |[AlgorithmType](#1-algorithmtype)     |
| id            | String             | 키 이름                   |    M    |                             |
| accessMethod  | WalletAccessMethod | 월렛에 저장된 키의 접근 방법    |    M    |[WalletAccessMethod](#2-walletaccessmethod)|
| storage       | StorageOption      | 키 저장소               |    M    |[StorageOption](#4-storageoption)     |

<br>

## 2. SecureKeyGenRequest

### Description

`시큐어 인클레이브 키 생성을 위한 데이터모델`

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
| algorithmType | AlgorithmType             | 키의 알고리즘 타입                    |    M    |[AlgorithmType](#1-algorithmtype)            |
| id            | String                    | 키 이름                            |    M    |                                    |
| accessMethod  | SecureEnclaveAccessMethod | 시큐어 인클레이브에 저장된 키의 접근 방법  |    M    |[SecureEnclaveAccessMethod](#2-secureenclaveaccessmethod)|
| storage       | StorageOption             | 키 저장소                         |    M    |[StorageOption](#4-storageoption)            |
| prompt        | String                    | Touch ID 사용에 대한 설명           |    M    |                                    |

<br>

## 3. KeyInfo

### Description

`키 정보에 관한 데이터모델`

### Declaration

```swift
// Declaration in swift
public struct KeyInfo : MetaProtocol
{
    var algorithmType : AlgorithmType
    var id            : String
    var accessMethod  : KeyAccessMethod
    var authType      : AuthType
    var publicKey     : String
}
```

### Property

| Name          | Type            | Description                                | **M/O** | **Note**                 |
|---------------|-----------------|--------------------------------------------|---------|--------------------------|
| algorithmType | AlgorithmType   | 키의 알고리즘 타입                             |    M    |[AlgorithmType](#1-algorithmtype)  |
| id            | String          | 키 이름                                       |    M    |                          |
| accessMethod  | KeyAccessMethod | 키의 저장소와 접근 방법을 가리킨다               |    M    |[KeyAccessMethod](#5-keyaccessmethod)|
| authType      | AuthType        | 키의 접근 방법을 가리킨다                        |    M    |[AuthType](#6-authtype)       |
| publicKey     | String          | 공개키                                      |    M    | 멀티베이스로 인코딩됨     |
