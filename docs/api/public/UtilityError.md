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

iOS UtilityError
==

- Topic: UtilityError
- Author: Woosang Kim
- Date: 2024-08-30
- Version: v1.0.0

| Version          | Date       | Changes                  |
| ---------------- | ---------- | ------------------------ |
| v1.0.0  | 2024-08-30 | Initial version          |

<div style="page-break-after: always;"></div>

# Table of Contents

- [UtilityError](#utilityerror)
- [Error Code](#error-code)
  - [1. Common](#1-common)
  - [2. CryptoUtils](#2-cryptoutils)
  - [3. MultibaseUtils](#3-multibaseutils)


## UtilityError

### Description
Error struct for Utility operations. It has code and message pair.
Code starts with MSDKUTL.

### Declaration
```java
public struct UtilityError: Error {
    public var code: String
    public var message: String
}
```

### Property

| Name    | Type   | Description            | **M/O** | **Note** |
|---------|--------|------------------------|---------|----------|
| code    | String | Error code              | M       |          |
| message | String | Error description       | M       |          |

<br>

# Error Code

## 1. Common

| Error Code   | Error Message                        | Description                       | Action Required                   |
|--------------|--------------------------------------|-----------------------------------|-----------------------------------|
| MSDKUTLxx000 | Invalid parameter : {name}           | Given parameter is invalid        | Check proper data type and length |

<br>

## 2. CryptoUtils

| Error Code      | Error Message                                      | Description                            | Action Required                        |
|-----------------|----------------------------------------------------|----------------------------------------|----------------------------------------|
| MSDKUTL00101    | Fail to create random key. error : {detail error}                 | Failure during random key generation   | Depend on detail error cases     |
| MSDKUTL00102    | Fail to derive public key                          | Failed to derive public key            | Verify key derivation steps            |
| MSDKUTL00103    | Fail to generate shared secret using ECDH. error : {detail error} | ECDH shared secret generation failed   | Depend on detail error cases     |
| MSDKUTL00104    | Fail to derive key using PBKDF2                    | PBKDF2 key derivation failed           | Check PBKDF2 parameters and input      |
| MSDKUTL00200    | Fail to convert public key to external representation. error : {detail error} | Public key conversion failed  | Depend on detail error cases |
| MSDKUTL00201    | Fail to convert private key to external representation. error : {detail error} | Private key conversion failed | Depend on detail error cases     |
| MSDKUTL00202    | Fail to convert private key to object. error : {detail error}     | Private key object conversion failed   | Depend on detail error cases      |
| MSDKUTL00203    | Fail to convert public key to object : {detail error}      | Public key object conversion failed    | Depend on detail error cases       |
| MSDKUTL00300    | Fail to encrypt using AES                          | AES encryption failure                 | Verify AES encryption implementation   |
| MSDKUTL00301    | Fail to decrypt using AES                          | AES decryption failure                 | Verify AES decryption implementation   |
| MSDKUTL00900    | Unsupported ECType : {name}                        | Unsupported elliptic curve type        | Use a supported EC type                |

<br>

## 3. MultibaseUtils

| Error Code      | Error Message                         | Description                         | Action Required                   |
|-----------------|---------------------------------------|-------------------------------------|-----------------------------------|
| MSDKUTL01100    | Fail to decode                        | Decoding process failed             | Verify encoding and input format  |
| MSDKUTL01900    | Unsupported encoding type : {name}    | Unsupported encoding type specified | Use a supported encoding type     |

<br>
