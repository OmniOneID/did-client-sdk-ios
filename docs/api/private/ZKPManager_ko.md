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

iOS ZKPManager API
==

- Subject: ZKPManager
- Writer: 박주현
- Date: 2025-05-27
- Version: v2.0.0

| Version          | Date       | History                            |
| ---------------- | ---------- | ---------------------------------- |
| v2.0.0           | 2025-05-27 | isCredentialSaved 추가              |
| v1.0.0           | 2025-04-24 | 초기 작성                            |


<div style="page-break-after: always;"></div>


# 목차
- [APIs](#apis)
    - [1. init](#1-init)
    - [2. IsAnyCredentialsSaved](#2-isanycredentialssaved)
    - [3. isCredentialSaved](#3-iscredentialsaved)
    - [4. CreateCredentialRequest](#4-createcredentialrequest)
    - [5. VerifyAndStoreCredential](#5-verifyandstorecredential)
    - [6. GetAllCredentials](#6-getallcredentials)
    - [7. GetCredentials](#7-getcredentials)
    - [8. RemoveAllCredentials](#8-removeallcredentials)
    - [9. RemoveCredentials](#9-removecredentials)
    - [10. SearchCredentials](#10-searchcredentials)
    - [11. CreateProof](#11-createproof)


# APIs
## 1. Initializer

### Description
`Initializer(Constructor)`

### Declaration

```swift
// Declaration in swift
public init(fileName : String) throws
```

### Parameters

| Name       | Type     | Description         | **M/O**   | **Note**           |
| ---------- | -------- | ------------------- | --------- | ------------------ |
| fileName   | String   | 저장시에 사용될 파일명    | M         | 확장자는 제외된 파일명   |


### Returns

| Type   | Description                  | **M/O**  | **Note**  |
| ------ | ---------------------------- | -------- | --------- |
| self   | Instance                     | M        |           |


### Usage
```swift
let zkpManager = try ZKPManager(fileName: "zkpWallet")
```

<br>

## 2. IsAnyCredentialsSaved

### Description
`저장된 ZKPCredential이 하나라도 존재하는지 확인합니다.`

### Declaration

```swift
public var isAnyCredentialsSaved : Bool
```

### Usage

```swift
if ! zkpManager.isAnyCredentialsSaved {
    print("No ZKP Credential is saved in the wallet.")
}
```

<br>

## 3. isCredentialSaved

### Description
`식별자를 통해 특정 ZKPCredential이 존재하는지 확인합니다.`

### Declaration

```swift
public func isCredentialSaved(by identifier : String) -> Bool
```

### Parameters

| Name       | Type   | Description            | **M/O** | **Note** |
|------------|--------|------------------------|---------|----------|
| identifier | String | 자격증명의 고유 식별자      | M       |          |

### Returns

| Type  | Description | **M/O** | **Note** |
|-------|-------------|---------|----------|
| Bool  | 존재 여부     | M       |          |

### Usage
```swift
if !zkpManager.isCredentialSaved(by: "id") {
    print("id for ZKP Credential is not saved.")
}
```

<br>

## 4. CreateCredentialRequest

### Description
`CredentialRequest와 해당 메타데이터를 생성합니다.`

### Declaration

```swift
public func createCredentialRequest(proverDid : String,
                                    credentialPublicKey : CredentialPrimaryPublicKey,
                                    credOffer : ZKPCredentialOffer) throws -> ZKPCredentialRequestContainer
```

### Parameters

| Name                  | Type                         | Description                                                         | **M/O**   | **Note**   |
| --------------------- | ---------------------------- | ------------------------------------------------------------------- | --------- | ---------- |
| proverDid             | String                       | Prover의 DID                                                        | M         |            |
| credentialPublicKey   | CredentialPrimaryPublicKey   | Credential 정의의 `value`에 포함된 `primary`                            | M         |            |
| credOffer             | ZKPCredential 발급 제안 객체    | ZKPCredentialOffer                                                  | M         |            |

### Returns

| Type                            | Description                      | **M/O**   | **Note**   |
| ------------------------------- | -------------------------------- | --------- | ---------- |
| ZKPCredentialRequestContainer   | CredentialRequest와 메타를 가진 객체  | M         |            |

### Usage
```swift
let proverDid : String
let credentialDefinition : ZKPCredentialDefinition
let credOffer : ZKPCredentialOffer
let container = try zkpManager.createCredentialRequest(proverDid: proverDid,
                                                       credentialPublicKey: credentialDefinition.value.primary,
                                                       credOffer: credOffer)
```

<br>

## 5. VerifyAndStoreCredential

### Description
`ZKP Credential을 검증하고 저장합니다.`

### Declaration

```swift
public func verifyAndStoreCredential(credentialMeta : ZKPCredentialRequestMeta,
                                     publicKey : CredentialPrimaryPublicKey,
                                     credential : ZKPCredential) throws
```

### Parameters

| Name             | Type                         | Description                                            | **M/O**   | **Note**   |
| ---------------- | ---------------------------- | ------------------------------------------------------ | --------- | ---------- |
| credentialMeta   | ZKPCredentialRequestMeta     | Credential 요청에서 생성된 메타데이터                         | M         |            |
| publicKey        | CredentialPrimaryPublicKey   | Credential 정의의 `value`에 포함된 `primary`               | M         |            |
| credential       | ZKPCredential                | 검증하고 저장할 Credential                                 | M         |            |

### Returns

Void

### Usage
```swift
let container
let credentialDefinition : ZKPCredentialDefinition
let credential : ZKPCredential
try zkpManager.verifyAndStoreCredential(credentialMeta: container.credentialRequestMeta,
                                        publicKey: credentialDefinition.value.primary,
                                        credential: credential)
```

<br>

## 6. GetAllCredentials

### Description
`저장된 모든 ZKP Credential을 반환합니다.`

### Declaration

```swift
public func getAllCredentials() throws -> [ZKPCredential]
```

### Returns

| Type              | Description                      | **M/O**   | **Note**   |
| ----------------- | -------------------------------- | --------- | ---------- |
| [ZKPCredential]   | 저장된 모든 Credential 배열          | M         |            |

### Usage
```swift
let zkpCredentials = try zkpManager.getAllCredentials()
```

<br>

## 7. GetCredentials

### Description
`지정된 식별자에 해당하는 ZKP Credential을 반환합니다.`

### Declaration

```swift
public func getCredentials(by identifiers : [String]) throws -> [ZKPCredential]
```

### Parameters

| Name          | Type       | Description                        | **M/O**   | **Note**   |
| ------------- | ---------- | ---------------------------------- | --------- | ---------- |
| identifiers   | [String]   | Credential 식별자 목록                | M         |            |

### Returns

| Type              | Description            | **M/O**   | **Note**   |
| ----------------- | ---------------------- | --------- | ---------- |
| [ZKPCredential]   | 일치하는 Credential 목록  | M         |            |

### Usage
```swift
let ids = ["id"]
let zkpCredentials = try zkpManager.getCredentials(by: ids)
```

<br>

## 8. RemoveAllCredentials

### Description
`저장된 모든 Credential을 삭제합니다.`

### Declaration

```swift
public func removeAllCredentials() throws
```

### Returns

Void

### Usage
```swift
let zkpCredentials = try zkpManager.removeAllCredentials()
```

<br>

## 9. RemoveCredentials

### Description
`지정된 식별자에 해당하는 Credential을 삭제합니다.`

### Declaration

```swift
public func removeCredentials(by identifiers : [String]) throws
```

### Parameters

| Name          | Type       | Description                            | **M/O**   | **Note**   |
| ------------- | ---------- | -------------------------------------- | --------- | ---------- |
| identifiers   | [String]   | Credential 식별자 배열                    | M         |            |

### Returns

Void

### Usage
```swift
let ids = ["id"]
let zkpCredentials = try zkpManager.removeCredentials(by: ids)
```

<br>

## 10. SearchCredentials

### Description
`주어진 증명 요청에 부합하는 Credential을 검색합니다.`

### Declaration

```swift
public func searchCredentials(proofRequest : ProofRequest) throws -> AvailableReferent
```

### Parameters

| Name           | Type           | Description                                                     | **M/O**   | **Note**   |
| -------------- | -------------- | --------------------------------------------------------------- | --------- | ---------- |
| proofRequest   | ProofRequest   | 요구 속성과 조건을 명시한 증명 요청                                      | M         |            |

### Returns

| Type                | Description                          | **M/O**   | **Note**   |
| ------------------- | ------------------------------------ | --------- | ---------- |
| AvailableReferent   | 일치하는 Credential의 참조 목록           | M         |            |

### Usage
```swift
let proofRequest : ProofRequest
let availableReferent = try zkpManager.searchCredentials(proofRequest: proofRequest)
```

<br>

## 11. CreateProof

### Description
`주어진 요청과 선택된 참조 항목을 기반으로 영지식 증명을 생성합니다.`

### Declaration

```swift
public func createProof(proofRequest : ProofRequest,
                        selectedReferents : [UserReferent],
                        proofParam : ZKProofParam) throws -> ZKProof
```

### Parameters

| Name                | Type               | Description                                                      | **M/O**   | **Note**   |
| ------------------- | ------------------ | ---------------------------------------------------------------- | --------- | ---------- |
| proofRequest        | ProofRequest       | 요구 속성과 조건을 명시한 증명 요청                                       | M         |            |
| selectedReferents   | [UserReferent]     | 증명 요청을 만족시키기 위해 사용자가 선택한 참조 항목                          | M         |            |
| proofParam          | ZKProofParam       | 증명 생성에 사용되는 추가 파라미터                                        | M         |            |

### Returns

| Type       | Description       | **M/O**   | **Note**   |
| ---------- | ----------------  | --------- | ---------- |
| ZKProof    | 생성된 ZKP 영지식 증명 | M         |            |

### Usage
```swift
let proofRequest : ProofRequest
let selectedReferents : [UserReferent]
let proofParam : ZKProofParam
let proof =  try zkpManager.createProof(proofRequest: proofRequest,
                                        selectedReferents: selectedReferents,
                                        proofParam: proofParam)
```

<br>