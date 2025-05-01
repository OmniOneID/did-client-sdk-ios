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

iOS SecureEncryptor API
==

- Subject: SecureEncryptor
- Writer: JooHyun Park
- Date: 2024-08-28
- Version: v1.0.0

| Version | Date       | History                 |
| ------- | ---------- | ------------------------|
| v1.0.0  | 2024-08-28 | Initial                 |


<div style="page-break-after: always;"></div>


# Table of Contents
- [APIs](#apis)
    - [1. encrypt](#1-encrypt)
    - [2. decrypt](#2-decrypt)


# APIs
## 1. encrypt

### Description
`Encrypt the plainData via SecureEnclave`

### Declaration

```swift
// Declaration in swift
public static func encrypt(plainData : Data) throws -> Data
```

### Parameters

| Name      | Type | Description          | **M/O** | **Note**            |
|-----------|------|----------------------|---------|---------------------|
| plainData | Data | Data to encrypt      |    M    |                     |

### Returns

| Type | Description                |**M/O**  | **Note**                                       |
|------|----------------------------|---------|------------------------------------------------|
| Data | Encrypted data             |    M    | This data must be decrypted in the same device |


### Usage
```swift
let plainData = "Test".data(using: .utf8)!
let encrypted = try SecureEncryptor.encrypt(plainData: plainData)
```

<br>

## 2. decrypt

### Description
`Decrypt the cipherData that encrypted via SecureEnclave`

### Declaration

```swift
// Declaration in swift
public static func decrypt(cipherData : Data) throws -> Data
```

### Parameters

| Name       | Type | Description                        | **M/O** | **Note**                                       |
|------------|------|------------------------------------|---------|------------------------------------------------|
| cipherData | Data | Encrypted data via Secure Enclave  |    M    | This data must be encrypted in the same device |

### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| Data | Decrypted data             |M       |         |


### Usage
```swift
let plainData = "Test".data(using: .utf8)!
let encrypted = try SecureEncryptor.encrypt(plainData: plainData)
...
let decrypted = try SecureEncryptor.decrypt(cipherData: encrypted)
```
