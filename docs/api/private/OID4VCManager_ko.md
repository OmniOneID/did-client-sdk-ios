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

- 주제: OID4VCManager
- 작성: 박주현
- 일자: 2026-10-07
- 버전: v1.0.0

| 버전   | 일자       | 변경 내용                 |
| ------ | ---------- | -------------------------|
| v1.0.0 | 2026-10-07 | 초기 작성                 |


<div style="page-break-after: always;"></div>

# 목차
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

`OID4VCManager`는 OpenID4VCI로 발급받은 크리덴셜(SD-JWT, mdoc 등)을 발급자가 준 형태 그대로 저장한다. W3C `VerifiableCredential`을 저장하는 `VCManager`의 OID4VCI 대응이다. 지갑 파일은 암호화되며, 각 항목의 `id`와 `format`은 복호화 없이 구분할 수 있도록 평문 메타에 둔다. `WalletCore`가 파일 이름 `"oid4vc"`로 인스턴스 하나를 만든다.

# APIs
## 1. init

### Description
```
발급 크리덴셜 지갑을 관리하는 OID4VCManager 인스턴스를 생성한다.
```

### Declaration
```swift
// Declaration in Swift
public init(fileName: String) throws
```

### Parameters

| Name      | Type   | Description                    | **M/O** | **Note**                                     |
|-----------|--------|--------------------------------|---------|----------------------------------------------|
| fileName  | String | 크리덴셜을 저장할 지갑 파일 이름 | M       | 확장자는 내부에서 정하므로 제외한다. 비어 있으면 throw |

### Returns

| Type          | Description              | **M/O** | **Note** |
|---------------|--------------------------|---------|----------|
| OID4VCManager | OID4VCManager 인스턴스   | M       |          |

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")
```

<br>

## 2. isAnyCredentialsSaved

### Description
```
저장된 크리덴셜이 하나 이상 있는지 확인한다. (지갑 파일 존재 여부 확인)
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
    // 지갑에 저장된 크리덴셜이 있음
}
```

<br>

## 3. addCredential

### Description
```
발급받은 크리덴셜을 지갑에 저장한다.
```

### Declaration

```swift
// Declaration in Swift
func addCredential(credential: OID4VCICredential) throws
```

### Parameters

| Name       | Type              | Description       | **M/O** | **Note** |
|------------|-------------------|-------------------|---------|----------|
| credential | OID4VCICredential | 발급 크리덴셜     | M       | [OID4VCICredential](#1-oid4vcicredential). `id`와 `format`이 항목의 메타가 된다 |

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
                                   credential: rawCredential) // 발급자가 준 그대로

try oid4vcManager.addCredential(credential: credential)
```

<br>

## 4. getCredentials

### Description
```
식별자와 일치하는 발급 크리덴셜을 지갑에서 모두 반환한다.
```

### Declaration

```swift
// Declaration in Swift
func getCredentials(by identifiers: [String]) throws -> [OID4VCICredential]
```

### Parameters

| Name        | Type     | Description              | **M/O** | **Note** |
|-------------|----------|--------------------------|---------|----------|
| identifiers | [String] | 발급 크리덴셜 ID 배열    | M       | 비어 있거나 ID가 중복되면 throw |

### Returns

| Type                | Description            | **M/O** | **Note** |
|---------------------|------------------------|---------|----------|
| [OID4VCICredential] | 발급 크리덴셜 배열     | M       | [OID4VCICredential](#1-oid4vcicredential) |

### Usage
```swift
let oid4vcManager = try OID4VCManager(fileName: "oid4vc")

let credentials = try oid4vcManager.getCredentials(by: ["0f8e7c1a-5b2d-4e3f-9a6b-1c2d3e4f5a6b"])
```

<br>

## 5. getAllCredentials

### Description
```
지갑에 저장된 발급 크리덴셜을 모두 반환한다.
```

### Declaration

```swift
// Declaration in Swift
func getAllCredentials() throws -> [OID4VCICredential]
```

### Parameters
N/A

### Returns

| Type                | Description            | **M/O** | **Note** |
|---------------------|------------------------|---------|----------|
| [OID4VCICredential] | 발급 크리덴셜 배열     | M       | [OID4VCICredential](#1-oid4vcicredential) |

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
식별자와 일치하는 발급 크리덴셜을 지갑에서 모두 삭제한다.
```

### Declaration

```swift
// Declaration in Swift
func deleteCredentials(by identifiers: [String]) throws
```

### Parameters

| Name        | Type     | Description              | **M/O** | **Note** |
|-------------|----------|--------------------------|---------|----------|
| identifiers | [String] | 발급 크리덴셜 ID 배열    | M       | 비어 있거나 ID가 중복되면 throw |

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
발급 크리덴셜이 저장된 지갑을 삭제한다.
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
OpenID4VCI로 발급받은 크리덴셜. 식별과 재매칭에 필요한 메타데이터와 함께 원본 그대로 저장한다.
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
| id                        | String | 저장소 기본 키 | M | 지갑이 생성한 UUID로 발급마다 고유하다. 아래 발급자 쪽 식별자는 여러 크리덴셜이 공유할 수 있어 키로 쓰지 않는다 |
| format                    | String | 크리덴셜 포맷 토큰 | M | 예: `dc+sd-jwt-did`, `mso_mdoc-did` |
| credentialConfigurationId | String | 발급에 쓰인 `credential_configuration_id` | M | |
| credentialIdentifier      | String | 발급자가 부여한 `credential_identifier` | O | 발급자가 식별자를 쓴 경우에만 |
| kid                       | String | 발급 시 키 바인딩 증명에 서명한 소유자 키 ID | M | `"pin"` 또는 `"bio"`. 제출할 때 다시 쓴다 |
| credential                | String | 발급자가 준 원본 크리덴셜 | M | SD-JWT compact, mdoc base64url 등 |

<br>

## 2. IssuedCredentialMeta

### Description
```
저장 항목의 평문 메타. 복호화 없이 포맷으로 항목을 거를 수 있게 한다.
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

| Name   | Type   | Description                         | **M/O** | **Note** |
|--------|--------|-------------------------------------|---------|----------|
| id     | String | `OID4VCICredential.id`와 같다       | M | |
| format | String | `OID4VCICredential.format`과 같다   | M | |
