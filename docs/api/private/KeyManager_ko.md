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
- Date: 2026-08-06
- Version: v1.0.2

| Version | Date       | History                |
| -------- | ---------- | ---------------------- |
| v1.0.2   | 2026-08-06 | isKeySaved 선언 정정      |
| v1.0.1   | 2025-10-13 | AuthenticatePin 함수 추가 |
| v1.0.0   | 2024-08-28 | 초기 작성               |


<div style="page-break-after: always;"></div>


# 목차
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
func isKeySaved(id : String) throws -> Bool
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
`주어진 요청에 따라 키를 생성한다.`

### Declaration

```swift
// Declaration in swift
func generateKey(keyGenRequest : KeyGenRequestProtocol) throws
```

### Parameters

| Name          | Type                  | Description                                     | **M/O** | **Note**                       |
|---------------|-----------------------|-------------------------------------------------|---------|--------------------------------|
| keyGenRequest | KeyGenRequestProtocol | KeyGenRequestProtocol을 따르는 요청값               |    M    |[KeyGenRequestProtocol](#1-keygenrequestprotocol)|

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
`walletPin인 키의 pin을 변경한다.`

### Declaration

```swift
// Declaration in swift
func changePin(id : String, oldPin : Data, newPin : Data) throws
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
let keyManager = try KeyManager(fileName: "MyWallet")

let oldPinData : Data = "password".data(using: .utf8)!
let newPinData : Data = "newPassword".data(using: .utf8)!
try keyManager.changePin(id: pinID, oldPin: oldPinData, newPin: newPinData)
```

<br>


## 6. AuthenticatePin

### Description
`walletPin인 키의 pin을 인증한다.`

### Declaration

```swift
// Declaration in swift
func authenticatePin(id: String, pin: Data) throws
```

### Parameters

| Name | Type   | Description | **M/O** | **Note** |
|------|--------|--------------|---------|----------|
| id   | String | 키 이름       | M       |          |
| pin  | Data   | 키의 Pin     | M       |          |

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
`이름과 일치하는 하나 이상의 KeyInfo를 반환한다.`

### Declaration

```swift
// Declaration in swift
@discardableResult
func getKeyInfos(ids : [String]) throws -> [KeyInfo]
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
let keyManager = try KeyManager(fileName: "MyWallet")
let keyInfos = try keyManager.getKeyInfos(ids: ["pin", "bio"])
```

<br>

## 8. GetKeyInfos by VerifyAuthType

### Description
`조건과 일치하는 하나 이상의 KeyInfo을 반환한다.`

### Declaration

```swift
// Declaration in swift
@discardableResult
func getKeyInfos(keyType : VerifyAuthType) throws -> [KeyInfo]
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
let keyManager = try KeyManager(fileName: "MyWallet")
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

## 9. DeleteKeys

### Description
`이름과 일치하는 키를 삭제한다.`

### Declaration

```swift
// Declaration in swift
func deleteKeys(ids : [String]) throws
```

### Parameters

| Parameter | Type   | Description          | **M/O** | **Note**|
|-----------|--------|----------------------|---------|---------|
| ids       |[String]| 찾을 키 이름            |    M    |         |


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
`모든 키를 삭제한다.`

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
`해시된 값을 서명한다.`

### Declaration

```swift
// Declaration in swift
func sign(id : String, pin : Data? = nil, digest : Data, context : LAContext? = nil) throws -> Data
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| id        | String | 찾을 키 이름                  |    M    |         |
| pin       | Data   | 키의 Pin                    |    O    |                  |
| digest    | Data   | 서명할 값                    |    M    | 해시된 값이어야 한다. |
| context   | LAContext | 시큐어 인클레이브 키에 재사용할 인증 컨텍스트. 이미 받은 확인으로 이 서명도 처리한다 |    O    | 기본값: nil |

### Returns

| Type | Description     |**M/O** | **Note**|
|------|-----------------|--------|---------|
| Data | 서명값           |    M   |         |

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

let plainData = "Test".data(using: .utf8)!
let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)

//Pin 키가 아닐 경우
let signature1 = try keyManager.sign(id: "free", digest: digest)
        
//Pin 키의 경우
let signature2 = try keyManager.sign(id: "pin", pin: pinData, digest: digest)
```

<br>

## 12. Verify

### Description
`서명값을 검증한다.`

### Declaration

```swift
// Declaration in swift
func verify(algorithmType : AlgorithmType, publicKey : Data, digest : Data, signature : Data) throws -> Bool
```

### Parameters

| Name          | Type          | Description                                         | **M/O** | **Note**               |
|---------------|---------------|-----------------------------------------------------|---------|------------------------|
| algorithmType | AlgorithmType | 서명값의 알고리즘 타입                                   |    M    |[AlgorithmType](#1-algorithmtype)|
| publicKey     | Data          | 서명에 사용된 개인키의 공개키                              |    M    |                        |
| digest        | Data          | 해시된 서명 원문                                        |    M    | 해시된 값이어야 한다.       |
| signature     | Data          | 서명값                                                |    M    |                        |

### Returns

| Type | Description                |**M/O** | **Note**                                                     |
|------|----------------------------|--------|--------------------------------------------------------------|
| Bool | 검증 결과                    |   M    | 공개키 비교 검증 실패일 경우 false값이 반환되며, 그 외의 경우 에러가 발생한다.|

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
`키가 ECDH 키 합의를 수행할 수 있는지 확인한다.`

소프트웨어 키(`walletNone`, `walletPin`)는 항상 가능하다. 시큐어 인클레이브 키는 키 자체에 묻는다. 키 교환을 지원하지 않게 생성된 키는 불가능하며, 지갑 쪽에서 이를 바꿀 방법은 없다. PIN이 필요한지는 별개 문제다. PIN으로 보호된 키는 서명할 때처럼 `keyAgreement` 시점에 PIN이 필요하다.

### Declaration

```swift
// Declaration in swift
func canKeyAgree(id : String) throws -> Bool
```

### Parameters

| Name | Type   | Description  | **M/O** | **Note** |
|------|--------|--------------|---------|----------|
| id   | String | 찾을 키 이름 |    M    |          |

### Returns

| Type | Description              | **M/O** | **Note** |
|------|--------------------------|---------|----------|
| Bool | ECDH 수행 가능 여부      |    M    | `id`로 저장된 키가 없으면 `false` |

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

if try keyManager.canKeyAgree(id: "free")
{
    // 이 키로 ECDH 가능
}
```

<br>

## 14. KeyAgreement

### Description
`키와 상대 공개키 사이의 ECDH 공유 비밀을 계산한다.`

KDF를 적용하지 않은 원본 공유 비밀(x 좌표 `Z`, 32바이트)을 반환한다. 키 유도는 프로토콜이 정한 KDF로 호출하는 쪽에서 한다.

### Declaration

```swift
// Declaration in swift
func keyAgreement(id : String, pin : Data? = nil, publicKey : Data, context : LAContext? = nil) throws -> Data
```

### Parameters

| Name      | Type      | Description                                   | **M/O** | **Note** |
|-----------|-----------|-----------------------------------------------|---------|----------|
| id        | String    | 찾을 키 이름                                  |    M    |          |
| pin       | Data      | 키의 Pin                                      |    O    | `sign`과 같이 PIN으로 보호된 소프트웨어 키에만 쓴다 |
| publicKey | Data      | 상대 공개키                                   |    M    | 비압축 P-256 점(`0x04‖x‖y`, 65바이트) |
| context   | LAContext | 시큐어 인클레이브 키에 재사용할 인증 컨텍스트. 한 번의 확인으로 여러 키 사용을 처리한다 |    O    | 기본값: nil |

### Returns

| Type | Description        | **M/O** | **Note** |
|------|--------------------|---------|----------|
| Data | 원본 공유 비밀     |    M    | 32바이트 |

### Errors
- `id`나 `publicKey`가 비어 있는 경우: 파라미터 오류
- `publicKey`가 올바른 P-256 점이 아닌 경우: 소프트웨어 키는 파라미터 오류, 시큐어 인클레이브 키는 `keyAgreement` 오류
- 등록된 생체 정보가 바뀐 뒤의 `secureEnclaveCurrentSet` 키: `userBiometricsChanged`
- 키 교환을 지원하지 않는 시큐어 인클레이브 키: `keyAgreementUnsupported` (먼저 `canKeyAgree`로 확인)

### Usage
```swift
let keyManager = try KeyManager(fileName: "MyWallet")

// peerPublicKey: 65바이트 비압축 점 (0x04||x||y)
//Pin 키가 아닐 경우
let secret1 = try keyManager.keyAgreement(id: "free", publicKey: peerPublicKey)

//Pin 키의 경우
let secret2 = try keyManager.keyAgreement(id: "pin", pin: pinData, publicKey: peerPublicKey)
```

<br>

# OptionSet
## 1. VerifyAuthType

### Description

`외부 SDK에 선언됨 / 키의 접근 방법과 제출 옵션을 가리킨다. AuthType과 유사하다.`

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
| accessMethod  | SecureEnclaveAccessMethod | 시큐어 인클레이브에 저장된 키의 접근 방법  |    M    |[SecureEnclaveAccessMethod](#3-secureenclaveaccessmethod)|
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
| algorithmType | AlgorithmType   | 키의 알고리즘 타입                             |    M    |[AlgorithmType](#1-algorithmtype)  |
| id            | String          | 키 이름                                       |    M    |                          |
| accessMethod  | KeyAccessMethod | 키의 저장소와 접근 방법을 가리킨다               |    M    |[KeyAccessMethod](#5-keyaccessmethod)|
| authType      | AuthType        | 키의 접근 방법을 가리킨다                        |    M    |[AuthType](#6-authtype)       |
| publicKey     | String          | 공개키                                      |    M    | 멀티베이스로 인코딩됨     |
