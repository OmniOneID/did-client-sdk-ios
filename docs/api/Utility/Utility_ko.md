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

iOS Utility SDK API
==

- 주제: Utility SDK
- 작성: 김우상
- 일자: 2024-08-30
- 버전: v1.0.0

| 버전   | 일자       | 변경 내용                 |
| ------ | ---------- | -------------------------|
| v1.0.0 | 2024-08-30 | 초기 작성                 |


<div style="page-break-after: always;"></div>

# 목차
- [APIs](#apis)
  - [CryptoUitls](#cryptouitls)
    - [1. generateNonce](#1-generatenonce)
    - [2. generateECKeyPair](#2-generateeckeypair)
    - [3. generateSharedSecret](#3-generatesharedsecret)
    - [4. pbkdf2](#4-pbkdf2)
    - [5. encrypt](#5-encrypt)
    - [6. decrypt](#6-decrypt)
  - [MultibaseUtils](#multibaseutils)
    - [1. encode](#1-encode)
    - [2. decode](#2-decode)
  - [DigestUtils](#multibaseutils)
    - [1. getDigest](#1-getdigest)
- [Enumerator](#enumerator)
  - [1. ECType](#1-ectype)
  - [2. EncryptionType](#2-encryptiontype)
  - [3. EncryptionMode](#3-encryptionmode)
  - [4. SymmetricKeySize](#4-symmetrickeysize)
  - [5. SymmetricCipherType](#5-symmetricciphertype)
  - [6. SymmetricPaddingType](#6-symmetricpaddingtype)
  - [7. MultibaseType](#7-multibasetype)
  - [8. DigestEnum](#8-digestenum)
- [Models](#models)
  - [1. ECKeyPair](#1-eckeypair)
  - [2. CipherInfo](#2-cipherinfo)


# APIs

## CryptoUitls

### 1. generateNonce

#### Description
```
랜덤한 nonce를 생성하여 반환한다.
```

#### Declaration

```swift
// Declaration in Swift
public static func generateNonce(size: UInt) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| size      | UInt   | 생성할 nonce의 byte size      | M       |                     |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data | 랜덤 생성한 nonce               | M       |          |


#### Usage
```swift
let size: UInt = 32
let nonce = try CryptoUtils.generateNonce(size: size)
```

<br>

### 2. generateECKeyPair

#### Description
```
ECDH 용도의 키 쌍을 생성한다.
```

#### Declaration

```swift
// Declaration in Swift
static func generateECKeyPair(ecType: ECType) throws -> ECKeyPair
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| ecType      | ECType   | 생성할 키 쌍의 타원 곡선 타입 | M       | [ECType](#1-ectype)             |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| ECKeyPair | 키 쌍 객체               | M       |          |


#### Usage
```swift
let keyPair = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)
```

<br>

### 3. generateSharedSecret

#### Description
```
ECDH 알고리즘으로 비밀 공유키를 생성한다.
```

#### Declaration

```swift
// Declaration in Swift
static func generateSharedSecret(ecType: ECType, privateKey: Data, publicKey: Data) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| ecType      | ECType | ECDH 수행을 위한 키의 타원 곡선 타입 | M   | [ECType](#1-ectype)         |
| privateKey  | Data   | ECDH 수행에 사용할 개인키      | M       | `ecType`와 일치하는 타원 곡선 타입을 가져야 한다. |
| publicKey   | Data   | ECDH 수행에 사용할 공개키      | M       | `ecType`와 일치하는 타원 곡선 타입을 가져야 한다. |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data | ECDH 수행의 결과물인 비밀 공유키    | M       |          |


#### Usage
```swift
let keyPair1 = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)    // 클라이언트 키 쌍
let keyPair2 = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)    // 서버 키 쌍

let sharedSecret1 = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: keyPair1.privateKey, publicKey: keyPair2.publicKey)    // 클라이언트에서 서버의 공개키로 ECDH 수행

let sharedSecret2 = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: keyPair2.privateKey, publicKey: keyPair1.publicKey)    // 서버에서 클라이언트의 공개키로 ECDH 수행

XCTAssertTrue(sharedSecret1 == sharedSecret2)
```

<br>

### 4. pbkdf2

#### Description
```
PBKDF2 알고리즘으로 키를 파생한다.
```

#### Declaration

```swift
// Declaration in Swift
static func pbkdf2(password: Data, salt: Data, iterations: UInt, derivedKeyLength: UInt) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| password  | Data   | 키 파생의 seed가 되는 password | M       |                     |
| salt      | Data   | 키 파생 과정에 사용될 salt      | M       |                     |
| iterations | UInt  | 키 파생 과정에 사용될 해시 반복 횟수 | M      |                     |
| derivedKeyLength | UInt | 키 파생 결과물의 byte 길이 | M       |                     |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data | password 기반으로 파생한 키       | M       |          |


#### Usage
```swift
let password: Data = ...
let salt: Data = ...
let iterations: UInt32 = 4096
let derivedKeyLength: UInt = 32
        
let derivedKey = try CryptoUtils.pbkdf2(password: password, salt: salt, iterations: iterations, derivedKeyLength: derivedKeyLength)
```

<br>

### 5. encrypt

#### Description
```
입력받은 데이터를 암호화한다.
```

#### Declaration

```swift
// Declaration in Swift
static func encrypt(plain: Data, info: CipherInfo, key: Data, iv: Data) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| plain     | Data   | 암호화 할 plain 데이터         | M       |                     |
| info      | CipherInfo   | 암호화 정보.            | M       | [CipherInfo](#2-cipherinfo) |
| key       | Data   | 암호화에 사용할 대칭키           | M       |                     |
| iv        | Data   | 암호화에 사용할 IV             | M       |                     |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data   | 암호화 된 데이터                 | M       |          |


#### Usage
```swift
let info = CipherInfo(cipherType: .aes256CBC, padding: .pkcs5)
let key: Data = ...
let iv: Data = ...
let plain: Data = ...

let encrypted = try CryptoUtils.encrypt(plain: plain, info: info, key: key, iv: iv)
```

<br>

### 6. decrypt

#### Description
```
입력받은 데이터를 복호화한다.
```

#### Declaration

```swift
// Declaration in Swift
static func decrypt(cipher: Data, info: CipherInfo, key: Data, iv: Data) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| cipher    | Data   | 복호화 할 cipher 데이터        | M       |                     |
| info      | CipherInfo | 암호화 정보.            | M       | [CipherInfo](#2-cipherinfo) |
| key       | Data   | 복호화에 사용할 대칭키           | M       |                     |
| iv        | Data   | 복호화에 사용할 IV             | M       |                     |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data   | 복호화 된 데이터               | M       |          |


#### Usage
```swift
let info = CipherInfo(cipherType: .aes256CBC, padding: .pkcs5)
let key: Data = ...
let iv: Data = ...
let cipher: Data = ...

let encrypted = try CryptoUtils.decrypt(cipher: cipher, info: info, key: key, iv: iv)
```

## MultibaseUitls

<br>

### 1. encode

#### Description
```
입력받은 데이터를 Multibase 인코딩한다.
```

#### Declaration

```swift
// Declaration in Swift
static func encode(type: MultibaseType, data: Data) -> String
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| type      | MultibaseType | Multibase 인코딩 타입  | M       | [MultibaseType](#7-multibasetype) |
| data      | Data   | 인코딩 할 데이터                | M       |                     |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| String | 인코딩 한 데이터               | M       |          |


#### Usage
```swift
let source: Data = ...
let encoded = MultibaseUtils.encode(type: .base16, data: source)
```

### 2. decode

#### Description
```
입력받은 Multibase 인코딩 된 문자열을 디코딩한다.
```

#### Declaration

```swift
// Declaration in Swift
static func decode(encoded: String) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| encoded   | String | 디코딩 할 Multibase 인코딩 된 문자열 | M    |                    |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data | 디코딩 한 데이터                 | M       |          |


#### Usage
```swift
let multibaseEncoded: String = ...
let decoded = try MultibaseUtils.decode(encoded: multibaseEncoded)
```

<br>

## DigestUitls

### 1. getDigest

#### Description
```
입력받은 데이터를 해시한다.
```

#### Declaration

```swift
// Declaration in Swift
static func getDigest(source: Data, digestEnum: DigestEnum) -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| source    | Data   | 해시 할 데이터                 | M       |                     |
| digestEnum | DigestEnum | 해시 종류               | M    | [DigestEnum](#8-digestenum)     |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data   | 해시 한 데이터                | M       |          |


#### Usage
```swift
let source: Data = ...
let hashed = DigestUtils.getDigest(source: source, digestEnum: .sha256)
```

<br>

# Enumerator

## 1. ECType

### Description
```
타원곡선 키 알고리즘 타입
```

### Declaration

```swift
// Declaration in Swift
public enum ECType: String {
    case secp256r1 = "Secp256r1"
    case secp256k1 = "Secp256k1"
}
```

## 2. EncryptionType

### Description
```
대칭키 암호화 알고리즘 타입
```

### Declaration

```swift
// Declaration in Swift
public enum EncryptionType: String {
    case aes = "AES"
}
```

## 3. EncryptionMode

### Description
```
대칭키 암호화 알고리즘 운용 모드
```

### Declaration

```swift
// Declaration in Swift
public enum EncryptionMode: String {
    case cbc = "CBC"
    case ecb = "ECB"
}
```

## 4. SymmetricKeySize

### Description
```
대칭키 사이즈.
```

### Declaration

```swift
// Declaration in Swift
public enum SymmetricKeySize: UInt {
    case size128 = 128
    case size256 = 256
}
```

## 5. SymmetricCipherType

### Description
```
대칭키 암호화 알고리즘/사이즈/운용모드 통합 정의 타입.
```

### Declaration

```swift
// Declaration in Swift
public enum SymmetricCipherType: String {
    case aes128CBC = "AES-128-CBC"
    case aes128ECB = "AES-128-ECB"
    case aes256CBC = "AES-256-CBC"
    case aes256ECB = "AES-256-ECB"
}
```

## 6. SymmetricPaddingType

### Description
```
대칭키 암호화 패딩 타입.
```

### Declaration

```swift
// Declaration in Swift
public enum SymmetricPaddingType: String {
    case noPad = "NOPAD"
    case pkcs5 = "PKCS5"
}
```

## 7. MultibaseType

### Description
```
Multibase 인코딩 타입.
```

### Declaration

```swift
// Declaration in Swift
public enum MultibaseType: String {
    case base16 = "f"
    case base16Upper = "F"
    case base58BTC = "z"
    case base64 = "m"
    case base64URL = "u"
}
```

## 8. DigestEnum

### Description
```
해시 알고리즘 타입.
```

### Declaration

```swift
// Declaration in Swift
public enum DigestEnum: String {
    case sha256 = "sha256"
    case sha384 = "sha384"
    case sha512 = "sha512"
}
```

# Models

## 1. ECKeyPair

### Description
```
타원 곡선 키 쌍 정보 객체.
```

### Declaration

```swift
// Declaration in Swift
public struct ECKeyPair {
    public var ecType: ECType
    public var privateKey: Data
    public var publicKey: Data
}
```

### Property

| Name         | Type   | Description         | **M/O** | **Note**            |
|---------------|-----------|-----------------|---------|---------------------|
| ecType       | ECType | 키 쌍의 타원 곡선 타입   | M       | [ECType](#1-ectype) |
| privateKey   | Data   | 개인키 데이터          | M       |                     |
| publicKey    | Data   | 공개키 데이터          | M       |                     |

## 2. CipherInfo

### Description
```
암호화 정보 객체.
```

### Declaration

```swift
// Declaration in Swift
public struct CipherInfo {
    public var type: EncryptionType
    public var mode: EncryptionMode
    public var size: SymmetricKeySize
    public var padding: SymmetricPaddingType
}
```

### Property

| Name          | Type               | Description                      | **M/O** | **Note**                    |
|---------------|--------------------|----------------------------------|---------|-----------------------------|
| type    | EncryptionType      | 대칭키 암호화 알고리즘 타입. | M | [EncryptionType](#2-encryptiontype) |
| mode    | EncryptionMode      | 대칭키 암호화 운용 모드     | M | [EncryptionMode](#3-encryptionmode) |
| size    | SymmetricKeySize     | 대칭키 사이즈            | M | [SymmetricKeySize](#4-symmetrickeysize) |
| padding | SymmetricPaddingType | 대칭키 암호화 패딩 타입    | M | [SymmetricPaddingType](#6-symmetricpaddingtype) |
