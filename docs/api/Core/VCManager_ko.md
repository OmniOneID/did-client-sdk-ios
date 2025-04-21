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

iOS VCManager Core SDK API
==

- 주제: VCManager
- 작성: 김우상
- 일자: 2024-08-28
- 버전: v1.0.0

| 버전   | 일자       | 변경 내용                 |
| ------ | ---------- | -------------------------|
| v1.0.0 | 2024-08-28 | 초기 작성                 |


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
  - [8. makePresentation](#8-makepresentation)
- [Models](#models)
  - [1. ClaimInfo](#1-claiminfo)
  - [2. PresentationInfo](#2-presentationinfo)
  - [3. VerifiableCredential](#3-verifiablecredential)
  - [4. VerifiablePresentation](#4-verifiablepresentation)

# APIs
## 1. init

### Description
```
VC 월렛을 관리하는 VCManager 인스턴스를 생성한다.
```

### Declaration

```swift
// Declaration in Swift
init(fileName: String) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| fileName  | String | VC를 저장할 월렛 파일 이름       | M       | 확장자는 내부적으로 정의되므로 제외하고 입력한다. |

### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| VCManager | VCManager 인스턴스           | M      |         |


### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)
```

<br>

## 2. isAnyCredentialsSaved

### Description
```
저장된 VC가 1개 이상 있는지 확인한다. (VC 월렛이 존재하는지 확인)
```

### Declaration

```swift
// Declaration in Swift
var isAnyCredentialsSaved: Bool
```

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

if vcManager.isAnyCredentialsSaved {
    // 월렛에 저장된 VC가 존재함
} else {
    // 월렛에 저장된 VC가 없음
}
```

<br>

## 3. addCredential

### Description
```
VC를 월렛에 저장한다.
```

### Declaration

```swift
// Declaration in Swift
func addCredential(credential: VerifiableCredential) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| credential | VerifiableCredential | VC 객체      | M        | [VerifiableCredential](#3-verifiablecredential) |

### Returns

Void

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

let vc: VerifiableCredential = try VerifiableCredential(from: "") // 이슈어로부터 발급받은 VC 데이터를 객체화 시킨 것.

try vcManager.addCredential(credential: vc)
```

<br>

## 4. getCredentials

### Description
```
월렛에서 identifiers와 일치하는 VC를 모두 반환한다.
```

### Declaration

```swift
// Declaration in Swift
func getCredentials(by identifiers: [String]) throws -> [VerifiableCredential]
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| identifiers | [String] | VC ID의 배열             | M       |                     |

### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| [VerifiableCredential] | VC 객체의 배열 | M | [VerifiableCredential](#3-verifiablecredential) |

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("저장된 VC가 없습니다.")
    return
}

let identifiers = ["eedca648-25b3-4892-babc-2fd567da542b", "f175652b-41b3-4a3b-a471-18dbb9a924fa"]
let vcs = try vcManager.getCredentials(by: identifiers)
```

<br>

## 5. getAllCredentials

### Description
```
월렛에 저장된 VC를 모두 반환한다.
```

### Declaration

```swift
// Declaration in Swift
func getAllCredentials() throws -> [VerifiableCredential]
```

### Parameters

N/A

### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| [VerifiableCredential] | VC 객체의 배열 | M | [VerifiableCredential](#3-verifiablecredential) |

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("저장된 VC가 없습니다.")
    return
}

let allVCs = try vcManager.getAllCredentials()
```

<br>

## 6. deleteCredentials

### Description
```
월렛에서 identifiers와 일치하는 VC를 모두 삭제한다.
```

### Declaration

```swift
// Declaration in Swift
func deleteCredentials(by identifiers: [String]) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| identifiers | [String] | VC ID의 배열             | M       |                     |

### Returns

Void

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("저장된 VC가 없습니다.")
    return
}

let identifiers = ["eedca648-25b3-4892-babc-2fd567da542b", "f175652b-41b3-4a3b-a471-18dbb9a924fa"]
try vcManager.deleteCredentials(by: identifiers)
```

<br>

## 7. deleteAllCredentials

### Description
```
VC가 저장된 월렛을 삭제한다.
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
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("저장된 VC가 없습니다.")
    return
}

try vcManager.deleteAllCredentials()
```

<br>

## 8. makePresentation

### Description
```
Proof가 없는 VP(VerifiablePresentation) 객체를 반환한다.
```

### Declaration

```swift
// Declaration in Swift
func makePresentation(claimInfos: [ClaimInfo], presentationInfo: PresentationInfo) throws -> VerifiablePresentation
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| claimInfos | [ClaimInfo] | VP 생성에 사용할 VC 정보 | M        | [ClaimInfo](#1-claiminfo) |
| presentationInfo | [PresentationInfo] | VP 생성에 사용할 VC 정보 | M        | [PresentationInfo](#2-presentationinfo) |

### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| VerifiablePresentation | VP 객체     | M       | Proof가 없는 [VerifiablePresentation](#4-verifiablepresentation) |

### Usage
```swift
let fileName = "VCWallet"
let vcManager = try VCManager(fileName: fileName)

guard vcManager.isAnyCredentialsSaved else {
    print("저장된 VC가 없습니다.")
    return
}

let claimInfos: [ClaimInfo] = [
    .init(credentialId: "eedca648-25b3-4892-babc-2fd567da542b", claimCodes: ["department", "name"])
]
let presentationInfo: PresentationInfo = .init(holder: "did:omn:3kH8HncYkmRTkLxxipTP9PB3jSXB", validFrom: "2024-07-12T10:48:00Z", validUntil: "2024-07-12T10:50:00Z", verifierNonce: "fbce87d9cfac255867a8d4488650a4fbd")

let vp = try vcManager.makePresentation(claimInfos: claimInfos, presentationInfo: presentationInfo)
```

<br>


# Models

## 1. ClaimInfo

### Description
```
VP 생성에 사용할 VC 정보 객체.
```

### Declaration

```swift
// Declaration in Swift
public struct ClaimInfo {
    public var credentialId: String
    public var claimCodes: [String]
}
```

### Property

| Name          | Type               | Description                      | **M/O** | **Note**                    |
|---------------|--------------------|----------------------------------|---------|-----------------------------|
| credentialId | String | VC ID | M | |
| claimCodes | [String] | VC에서 VP에 포함할 클레임 코드의 배열 | M | |

## 2. PresentationInfo

### Description
```
VP 생성에 사용할 VP 메타 정보.
```

### Declaration

```swift
// Declaration in Swift
public struct PresentationInfo {
    public var holder: String
    public var validFrom: String
    public var validUntil: String
    public var verifierNonce: String
}
```

### Property

| Name          | Type               | Description                      | **M/O** | **Note**                    |
|---------------|--------------------|----------------------------------|---------|-----------------------------|
| holder | String | VC 소유자의 DID | M | |
| validFrom | String | VC 유효기간 시작 일시 | M | |
| validUntil | String | VC 유효기간 종료 일시 | M | |
| verifierNonce | String | 검증자에게 전달받은 nonce | M | |

## 3. VerifiableCredential

### Description

`VC(VerifiableCredential) 객체. Data Model SDK에서 제공.` <br>
cf. [ 원본 링크](#목차) <!-- 수정필요 -->

## 4. VerifiablePresentation

### Description

`VP(VerifiablePresentation) 객체. Data Model SDK에서 제공.` <br>
cf. [ 원본 링크](#목차) <!-- 수정필요 -->
