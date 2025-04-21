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

iOS SecureEncryptor Core SDK API
==

- Subject: SecureEncryptor
- Writer: JooHyun Park
- Date: 2024-08-28
- Version: v1.0.0

| Version | Date       | History                 |
| ------- | ---------- | ------------------------|
| v1.0.0  | 2024-08-28 | 초기 작성                 |


<div style="page-break-after: always;"></div>


# Contents
- [APIs](#apis)
    - [1. encrypt](#1-encrypt)
    - [2. decrypt](#2-decrypt)


# APIs
## 1. encrypt

### Description
`시큐어 인클레이브를 통하여 평문을 암호화한다.`

### Declaration

```swift
// Declaration in swift
public static func encrypt(plainData : Data) throws -> Data
```

### Parameters

| Name      | Type | Description          | **M/O** | **Note**            |
|-----------|------|----------------------|---------|---------------------|
| plainData | Data | 암호화할 데이터          |    M    |                     |

### Returns

| Type | Description                |**M/O**  | **Note**                             |
|------|----------------------------|---------|--------------------------------------|
| Data | 암호화된 데이터                |    M    | 이 값은 반드시 같은 장치에서 복호화되어야 한다. |


### Usage
```swift
let plainData = "Test".data(using: .utf8)!
let encrypted = try SecureEncryptor.encrypt(plainData: plainData)
```

<br>

## 2. decrypt

### Description
`시큐어 인클레이브를 통해 암호화된 데이터를 복호화한다.`

### Declaration

```swift
// Declaration in swift
public static func decrypt(cipherData : Data) throws -> Data
```

### Parameters

| Name       | Type | Description                        | **M/O** | **Note**                                       |
|------------|------|------------------------------------|---------|------------------------------------------------|
| cipherData | Data | 시큐어 인클레이브를 통해 암호화된 데이터     |    M    | 이 데이터는 반드시 같은 장치에서 암호화된 값이어야 한다.    |

### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| Data | 복호화된 데이터                |M       |         |


### Usage
```swift
let plainData = "Test".data(using: .utf8)!
let encrypted = try SecureEncryptor.encrypt(plainData: plainData)
...
let decrypted = try SecureEncryptor.decrypt(cipherData: encrypted)
```
