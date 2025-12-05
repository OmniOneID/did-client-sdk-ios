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

iOS DIDManager API
==

- 주제: DIDManager
- 작성: 박주현
- 일자: 2025-09-09
- 버전: v1.0.1

| 버전             | 일자        | 변경 내용                 |
| --------------- | ---------- | -----------------------|
| v1.0.1          | 2025-09-09 | 문서 버전 증가 기능 추가     |
| v1.0.0          | 2024-08-28 | 초기 작성                |


<div style="page-break-after: always;"></div>

# 목차
- [APIs](#apis)
  - [1. genDID](#1-gendid)
  - [2. init](#2-init)
  - [3. isSaved](#3-issaved)
  - [4. createDocument](#4-createdocument)
  - [5. getDocument](#5-getdocument)
  - [6. replaceDocument](#6-replacedocument)
  - [7. saveDocument](#7-savedocument)
  - [8. deleteDocument](#8-deletedocument)
  - [9. addVerificationMethod](#9-addverificationmethod)
  - [10. removeVerificationMethod](#10-removeverificationmethod)
  - [11. addService](#11-addservice)
  - [12. removeService](#12-removeservice)
  - [13. resetChanges](#13-resetchanges)
- [OptionSet](#optionset)
  - [1. DIDMethodType](#1-didmethodtype)
- [Models](#models)
  - [1. DIDKeyInfo](#1-didkeyinfo)
  - [2. DIDDocument](#2-diddocument)
  - [3. DIDDocument.Service](#3-diddocumentservice)
  - [4. KeyInfo](#4-keyinfo)

# APIs
## 1. genDID

### Description
`methodName을 포함한 랜덤한 DID 문자열을 반환한다.`

### Declaration

```swift
// Declaration in Swift
public static func genDID(methodName: String) throws -> String
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| methodName | String | 사용할 method name          | M       |                     |

### Returns

| Type   | Description                | **M/O** | **Note** |
|--------|----------------------------|---------|----------|
| String | DID 문자열                   | M       | 다음과 같은 형식의 문자열을 반환하다. <br>`did:omn:3kH8HncYkmRTkLxxipTP9PB3jSXB` |

### Usage
```swift
let methodName = "omn"
let did = try DIDManager.genDID(methodName: methodName)
print("DID String : \(did)")
```

<br>

## 2. init

### Description
`DID 문서 월렛을 관리하는 DIDManager 인스턴스를 생성한다.`

### Declaration
```swift
public init(fileName: String) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**            |
|-----------|--------|----------------------------|---------|---------------------|
| fileName  | String | DID 문서를 저장할 월렛 파일 이름  | M       | 확장자는 내부적으로 정의되므로 제외하고 입력한다. |

### Returns

| Type       | Description                |**M/O** | **Note**|
|------------|----------------------------|--------|---------|
| DIDManager | DIDManager 인스턴스           | M      |         |

### Usage
```swift
let fileName = "DIDDocWallet"
let didManager = try DIDManager(fileName: fileName)
```

<br>

## 3. isSaved

### Description
`월렛에 저장된 DID 문서의 존재 여부를 반환한다.`

### Declaration

```swift
// Declaration in Swift
public var isSaved: Bool
```

### Usage
```swift
let fileName = "DIDDocWallet"
let didManager = try DIDManager(fileName: fileName)

if didManager.isSaved {
    // 월렛에 저장된 DID 문서가 존재함
} else {
    // 월렛에 저장된 DID 문서가 없음
}
```

<br>

## 4. createDocument

### Description
```
파라미터를 사용해 "임시 DIDDocument 객체"를 생성하여 내부 변수로 관리한다. 
이 단계에서는 월렛에 저장하지 않는다. 
isSaved API의 리턴값이 false인 경우에만 호출 가능하다.
```

### Declaration

```swift
// Declaration in Swift
public mutating func createDocument(did: String, keyInfos: [DIDKeyInfo], controller: String?, service: [DIDDocument.Service]?) throws
```

### Parameters

| Name          | Type                  | Description                                     | **M/O** | **Note**                       |
|---------------|-----------------------|-------------------------------------------------|---------|--------------------------------|
| did | String | 사용자 DID |    M    | DID 생성은 [genDID](#1-gendid)를 참고. |
| keyInfos | [DIDKeyInfo] | DID 문서에 등록할 공개키 정보 객체의 배열 |    M    | [DIDKeyInfo](#1-didkeyinfo) |
| controller | String | DID 문서에 controller로 등록할 DID. <br>nil이면, `did` 항목을 사용한다. |    O    | |
| service | [DIDDocument.Service] | DID 문서의 서비스 정보 |    O    | [DIDDocument.Service](#3-diddocumentservice) |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // 월렛에 저장된 DID 문서가 존재함
    return
}

// 월렛에 저장된 DID 문서가 없음

let did = try DIDManager.genDID(methodName: "omn")

var keyInfos: [DIDKeyInfo] = .init()

let keyInfo = ...   // KeyManager - getKeyInfos 의 리턴값인 배열의 원소 객체

keyInfos.append(.init(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))

try didManager.createDocument(did: did, keyInfos: keyInfos, controller: nil, service: nil)
```

<br>

## 5. getDocument

### Description
```
"임시 DIDDocument 객체"를 리턴한다.
"임시 DIDDocument 객체"가 nil이면, 저장된 DID 문서를 리턴한다.
```

### Declaration

```swift
// Declaration in Swift
public func getDocument() throws -> DIDDocument
```

### Parameters

N/A

### Returns

| Type | Description                |**M/O** | **Note**|
|------|----------------------------|--------|---------|
| DIDDocument | DID 문서 객체         | M      | [DIDDocument](#2-diddocument) |

### Usage
```swift
let fileName = "DIDDocWallet"
let didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // 월렛에 저장된 DID 문서가 존재함
    let didDocument = try didManager.getDocument()
} else {
    // 월렛에 저장된 DID 문서가 없음
}
```

<br>

## 6. replaceDocument

### Description
`"임시 DIDDocument 객체"를 입력받은 객체로 대치한다.`

### Declaration

```swift
// Declaration in Swift
public mutating func replaceDocument(didDocument: DIDDocument, needUpdate: Bool)
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| didDocument | DIDDocument | 대체할 DID 문서 객체 |    M    | [DIDDocument](#2-diddocument) |
| needUpdate | Bool | DID 문서 객체의 updated 속성을 현재 시간으로 업데이트 할 것인지 여부 | M | 대체할 DID 문서 객체가 proof가 추가되지 않은 상태라면 필요에 따라 true를 사용할 수 있다. <br>단, proof가 추가 된 상태라면, 서명 원문 보존을 위해서 false를 사용해야 한다. |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

let didDocumentToReplace: DIDDocument = ... // 대체할 DID Document 문서 객체

try didManager.replaceDocument(didDocument: didDocumentToReplace, needUpdate: false)
```

<br>

## 7. saveDocument

### Description
```
“임시 DIDDocument 객체”를 월렛 파일에 저장한 후에 초기화 한다.
이미 저장된 파일을 대상으로 변경사항이 없는 상태, 즉, “임시 DIDDocument 객체”가 nil인 상태에서 호출한다면 아무런 동작을 하지 않는다. (에러 아님)
```

### Declaration

```swift
// Declaration in Swift
public mutating func saveDocument() throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // 월렛에 저장된 DID 문서가 존재함
    return
}

// 월렛에 저장된 DID 문서가 없음

let did = try DIDManager.genDID(methodName: "omn")

var keyInfos: [DIDKeyInfo] = .init()

let keyInfo = ...    // KeyManager - getKeyInfos 의 리턴값인 배열의 원소 객체

keyInfos.append(.init(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))

try didManager.createDocument(did: did, keyInfos: keyInfos, controller: nil, service: nil)

let didDocument = try didManager.getDocument()  // proof가 비어 있는 DID 문서 객체

let didDocumentWithProof = ...  // KeyManager로 서명하여 proof를 완성한 DID 문서 객체

didManager.replaceDocument(didDocument: didDocumentWithProof, needUpdate: false)

try didManager.saveDocument()
```

<br>

## 8. deleteDocument

### Description
```
저장된 월렛 파일을 삭제한다.
파일 삭제후, “임시 DIDDocument 객체”를 nil로 초기화 한다.
```

### Declaration

```swift
// Declaration in Swift
public mutating func deleteDocument() throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if didManager.isSaved { // 월렛에 저장된 DID 문서가 존재함
    try didManager.deleteDocument()
}
```

<br>

## 9. addVerificationMethod

### Description
```
“임시 DIDDocument 객체”에 공개키 정보를 추가한다.
주로 저장된 DID 문서에 새로운 공개키 정보를 추가하는 경우에 사용한다.
```

### Declaration

```swift
// Declaration in Swift
public mutating func addVerificationMethod(keyInfo: DIDKeyInfo) throws
```

### Input Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| keyInfo | DIDKeyInfo | DID 문서에 등록할 공개키 정보 객체 |    M    | [DIDKeyInfo](#1-didkeyinfo) |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("월렛에 저장된 DID 문서가 없음")
    return
}

let keyInfo = ...    // KeyManager - getKeyInfos 의 리턴값인 배열의 원소 객체
let didKeyInfo = DIDKeyInfo(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication])

try didManager.addVerificationMethod(keyInfo: didKeyInfo)
```

<br>

## 10. removeVerificationMethod

### Description
```
“임시 DIDDocument 객체”에 공개키 정보를 삭제한다.
주로 저장된 DID 문서에 등록된 공개키 정보를 삭제하는 경우에 사용한다.
```

### Declaration

```swift
// Declaration in Swift
public mutating func removeVerificationMethod(keyId: String) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| keyId     | String | DID 문서에서 삭제할 공개키 정보의 ID       |    M    |         |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("월렛에 저장된 DID 문서가 없음")
    return
}

let keyIdToRemove = "pin"

try didManager.removeVerificationMethod(keyId: keyIdToRemove)
```

<br>

## 11. addService

### Description
```
“임시 DIDDocument 객체”에 서비스 정보를 추가한다.
주로 저장된 DID 문서에 등록된 서비스 정보를 추가하는 경우에 사용한다.
```

### Declaration

```swift
// Declaration in Swift
public mutating func addService(service: DIDDocument.Service) throws
```

### Parameters

| Name        | Type                  | Description                  | **M/O** | **Note** |
|-------------|-----------------------|------------------------------|---------|----------|
| service     | DIDDocument.Service   | DID 문서에 명시할 서비스 정보 객체  |    M    | [DIDDocument.Service](#3-diddocumentservice) |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("월렛에 저장된 DID 문서가 없음")
    return
}

let service: DIDDocument.Service = .init(id: "service id", type: .linkedDomains, serviceEndpoint: ["http://serviceEndpoint"])

try didManager.addService(service: service)
```

## 12. removeService

### Description
```
“임시 DIDDocument 객체”에서 서비스 정보를 삭제한다.
주로 저장된 DID 문서에 등록된 서비스 정보를 삭제하는 경우에 사용한다.
```

### Declaration

```swift
// Declaration in Swift
public mutating func removeService(serviceId: String) throws
```

### Parameters

| Name      | Type   | Description                | **M/O** | **Note**|
|-----------|--------|----------------------------|---------|---------|
| serviceId | String | DID 문서에서 삭제할 서비스 ID    |    M    |         |

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("월렛에 저장된 DID 문서가 없음")
    return
}

let serviceId = "serviceId"

try didManager.removeService(serviceId: serviceId)
```

## 13. resetChanges

### Description
```
변경사항을 초기화하기 위해 “임시 DIDDocument 객체”를 nil로 초기화 한다.
저장된 DID 문서 파일이 없는 경우에는 에러가 발생한다. 즉, 저장된 DID 문서 파일이 있는 경우에만 사용 가능하다.
```

### Declaration

```swift
// Declaration in Swift
public mutating func resetChanges() throws
```

### Parameters

N/A

### Returns

Void

### Usage
```swift
let fileName = "DIDDocWallet"
var didManager = try DIDManager(fileName: fileName)

if !didManager.isSaved {
    print("월렛에 저장된 DID 문서가 없음")
    return
}

try didManager.resetChanges()
```

# OptionSet
## 1. DIDMethodType

### Description

`DID 문서에 등록되는 키가 어떤 용도인지 명시하는 타입.`

### Declaration

```swift
// Declaration in Swift
public struct DIDMethodType : OptionSet
{
    public let rawValue: Int
    
    public static let assertionMethod       = DIDMethodType(rawValue: 1 << 0)
    public static let authentication        = DIDMethodType(rawValue: 1 << 1)
    public static let keyAgreement          = DIDMethodType(rawValue: 1 << 2)
    public static let capabilityInvocation  = DIDMethodType(rawValue: 1 << 3)
    public static let capabilityDelegation  = DIDMethodType(rawValue: 1 << 4)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
```

# Models

## 1. DIDKeyInfo

### Description

`DID Doc에 등록할 공개키 정보 객체.`

### Declaration

```swift
// Declaration in Swift
public struct DIDKeyInfo {
    public var keyInfo: KeyInfo
    public var methodType: DIDMethodType
    public var controller: String?
}
```

### Property

| Name          | Type               | Description                      | **M/O** | **Note**                    |
|---------------|--------------------|----------------------------------|---------|-----------------------------|
| keyInfo       | KeyInfo            | KeyManager가 반환한 공개키 정보 객체   |    M    |                             |
| methodType    | DIDMethodType      | DID 문서에 등록되는 공개키가 어떤 용도인지 명시하는 타입 |  M  |                     |
| controller    | String            | DID 문서에 등록되는 공개키의 controller로 등록할 DID. nil이면, DID 문서의 id를 controller로 등록한다. |    O    |                     |


## 2. DIDDocument

### Description

`DID 문서 객체. Data Model SDK에서 제공.` <br>
cf. [DIDDocument 원본 링크](#목차) <!-- 수정필요 -->

## 3. DIDDocument.Service

`DID 문서의 service 객체. Data Model SDK에서 제공.` <br>
cf. [DIDDocument.Service 원본 링크](#목차) <!-- 수정필요 -->

## 4. KeyInfo

### Description

`KeyManager에서 조회한 키 정보 객체.` <br>
cf. [KeyInfo 원본 링크](#목차) <!-- 수정필요 -->
