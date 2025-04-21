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

- Topic: Utility SDK
- Author: Woosang Kim
- Date: 2024-08-30
- Version: v1.0.0

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v1.0.0  | 2024-08-30 | Initial version          |

<div style="page-break-after: always;"></div>

# Table of Contents
- [APIs](#apis)
  - [CryptoUtils](#cryptoutils)
    - [1. generateNonce](#1-generatenonce)
    - [2. generateECKeyPair](#2-generateeckeypair)
    - [3. generateSharedSecret](#3-generatesharedsecret)
    - [4. pbkdf2](#4-pbkdf2)
    - [5. encrypt](#5-encrypt)
    - [6. decrypt](#6-decrypt)
  - [MultibaseUtils](#multibaseutils)
    - [1. encode](#1-encode)
    - [2. decode](#2-decode)
  - [DigestUtils](#digestutils)
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

## CryptoUtils

### 1. generateNonce

#### Description
```
Generates and returns a random nonce.
```


#### Declaration

```swift
// Declaration in Swift
public static func generateNonce(size: UInt) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| size      | UInt   | Byte size of the nonce to be generated | M       |                     |

#### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| Data | Randomly generated nonce     | M       |          |


#### Usage
```swift
let size: UInt = 32
let nonce = try CryptoUtils.generateNonce(size: size)
```

### 2. generateECKeyPair

#### Description
```
Generates a key pair for ECDH purposes.
```

#### Declaration

```swift
// Declaration in Swift
static func generateECKeyPair(ecType: ECType) throws -> ECKeyPair
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| ecType    | ECType | Type of elliptic curve for the key pair to be generated | M       | [ECType](#1-ectype)             |

#### Returns

| Type      | Description                | **M/O** | **Note** |
|-----------|----------------------------|---------|----------|
| ECKeyPair | Key pair object            | M       |          |

#### Usage
```swift
let keyPair = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)
```

<br>

### 3. generateSharedSecret

#### Description
```
Generates a shared secret key using the ECDH algorithm.
```

#### Declaration

```swift
// Declaration in Swift
static func generateSharedSecret(ecType: ECType, privateKey: Data, publicKey: Data) throws -> Data
```

#### Parameters

| Name        | Type   | Description                                   | **M/O** | **Note**                                          |
|-------------|--------|-----------------------------------------------|---------|---------------------------------------------------|
| ecType      | ECType | Elliptic curve type for performing ECDH       | M       | [ECType](#1-ectype)                               |
| privateKey  | Data   | Private key to use for ECDH                   | M       |    |
| publicKey   | Data   | Public key to use for ECDH                    | M       |    |

#### Returns

| Type   | Description                              | **M/O** | **Note** |
|--------|------------------------------------------|---------|----------|
| Data   | Secret shared key resulting from ECDH    | M       |          |

#### Usage
```swift
let keyPair1 = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)    // Client key pair
let keyPair2 = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)    // Server key pair

let sharedSecret1 = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: keyPair1.privateKey, publicKey: keyPair2.publicKey)    // Perform ECDH on client with server's public key

let sharedSecret2 = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: keyPair2.privateKey, publicKey: keyPair1.publicKey)    // Perform ECDH on server with client's public key

XCTAssertTrue(sharedSecret1 == sharedSecret2)
```

<br>

### 4. pbkdf2

#### Description
```
Derives a key using the PBKDF2 algorithm.
```

#### Declaration

```swift
// Declaration in Swift
static func pbkdf2(password: Data, salt: Data, iterations: UInt, derivedKeyLength: UInt) throws -> Data
```

#### Parameters

| Name              | Type | Description                                  | **M/O** | **Note** |
|-------------------|------|----------------------------------------------|---------|----------|
| password          | Data | Password used as the seed for key derivation  | M       |          |
| salt              | Data | Salt used in the key derivation process       | M       |          |
| iterations        | UInt | Number of hash iterations for key derivation  | M       |          |
| derivedKeyLength  | UInt | Byte length of the derived key                | M       |          |

#### Returns

| Type | Description                        | **M/O** | **Note** |
|------|------------------------------------|---------|----------|
| Data | Key derived from the password      | M       |          |

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
Encrypt the input data.
```


#### Declaration

```swift
// Declaration in Swift
static func encrypt(plain: Data, info: CipherInfo, key: Data, iv: Data) throws -> Data
```
#### Parameters

| Name   | Type        | Description          | **M/O** | **Note**                |
|--------|-------------|----------------------|---------|-------------------------|
| plain  | Data        | Plain data to encrypt| M       |                         |
| info   | CipherInfo  | Encryption information| M       | [CipherInfo](#2-cipherinfo) |
| key    | Data        | Symmetric key for encryption | M  |                         |
| iv     | Data        | IV for encryption    | M       |                         |

#### Returns

| Type   | Description          | **M/O** | **Note** |
|--------|----------------------|---------|----------|
| Data   | Encrypted data       | M       |          |

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
Decrypts the input data.
```

#### Declaration

```swift
// Declaration in Swift
static func decrypt(cipher: Data, info: CipherInfo, key: Data, iv: Data) throws -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| cipher    | Data   | Cipher data to be decrypted        | M       |                     |
| info      | CipherInfo | Encryption information            | M       | [CipherInfo](#2-cipherinfo) |
| key       | Data   | Symmetric key for decryption           | M       |                     |
| iv        | Data   | IV for decryption            | M       |                     |


#### Returns

| Type   | Description                        | **M/O** | **Note** |
|--------|------------------------------------|---------|----------|
| Data   | Decrypted data                     | M       |          |

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
Encodes the input data using Multibase encoding.
```
#### Declaration

```swift
// Declaration in Swift
static func encode(type: MultibaseType, data: Data) -> String
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| type      | MultibaseType | Multibase encoding type  | M       | [MultibaseType](#7-multibasetype) |
| data      | Data   | Data to be encoded                 | M       |                     |

#### Returns

| Type   | Description               | **M/O** | **Note** |
|--------|---------------------------|---------|----------|
| String | Encoded data              | M       |          |


#### Usage
```swift
let source: Data = ...
let encoded = MultibaseUtils.encode(type: .base16, data: source)
```


### 2. decode

#### Description
```
Decodes the given Multibase encoded string.
```
#### Declaration

```swift
// Declaration in Swift
static func decode(encoded: String) throws -> Data
```
#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| encoded   | String | Multibase encoded string to be decoded | M    |                    |

#### Returns

| Type | Description                | **M/O** | **Note** |
|------|----------------------------|---------|----------|
| Data | Decoded data               | M       |          |


#### Usage
```swift
let multibaseEncoded: String = ...
let decoded = try MultibaseUtils.decode(encoded: multibaseEncoded)
```

<br>

## DigestUtils

### 1. getDigest

#### Description
```
Hashes the input data.
```
#### Declaration

```swift
// Declaration in Swift
static func getDigest(source: Data, digestEnum: DigestEnum) -> Data
```

#### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| source    | Data   | Data to be hashed                 | M       |                     |
| digestEnum | DigestEnum | Type of hash               | M    | [DigestEnum](#8-digestenum)     |

#### Returns

| Type   | Description         | **M/O** | **Note** |
|--------|---------------------|---------|----------|
| Data   | Hashed data         | M       |          |

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
Elliptic Curve Key Algorithm Type
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
Symmetric key encryption algorithm type
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
Symmetric key encryption algorithm operation mode
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
Symmetric key size.
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
Integrated definition type for symmetric key encryption algorithm/size/mode of operation.
This type is composed of three types. Those types are EncryptionType/SymmetricKeySize/EncryptionMode.
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
Symmetric key encryption padding type.
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
Multibase encoding type.
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
Hash algorithm type.
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
Elliptic Curve Key Pair information object.
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

| Name         | Type   | Description                | **M/O** | **Note**            |
|--------------|--------|----------------------------|---------|---------------------|
| ecType       | ECType | Elliptic curve type of key pair | M       | [ECType](#1-ectype) |
| privateKey   | Data   | Private key data           | M       |                     |
| publicKey    | Data   | Public key data            | M       |                     |


## 2. CipherInfo

### Description
```
Encryption information object.
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

| Name    | Type               | Description                                    | **M/O** | **Note**                          |
|---------|--------------------|------------------------------------------------|---------|-----------------------------------|
| type    | EncryptionType     | Symmetric key encryption algorithm type.       | M       | [EncryptionType](#2-encryptiontype) |
| mode    | EncryptionMode     | Symmetric key encryption operation mode        | M       | [EncryptionMode](#3-encryptionmode) |
| size    | SymmetricKeySize   | Symmetric key size                             | M       | [SymmetricKeySize](#4-symmetrickeysize) |
| padding | SymmetricPaddingType | Symmetric key encryption padding type         | M       | [SymmetricPaddingType](#6-symmetricpaddingtype) |
