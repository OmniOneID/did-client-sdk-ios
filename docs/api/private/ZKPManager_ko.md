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
- Date: 2025-04-24
- Version: v1.0.0

| Version          | Date       | History                            |
| ---------------- | ---------- | ---------------------------------- |
| v1.0.0           | 2025-04-24 | 초기 작성                            |


<div style="page-break-after: always;"></div>


# 목차
- [APIs](#apis)
    - [1. init](#1-init)
    - [2. IsAnyCredentialsSaved](#2-isanycredentialssaved)
    - [3. CreateCredentialRequest](#3-createcredentialrequest)
    - [4. VerifyAndStoreCredential](#4-verifyandstorecredential)
    - [5. GetAllCredentials](#5-getallcredentials)
    - [6. GetCredentials](#6-getcredentials)
    - [7. RemoveAllCredentials](#7-removeallcredentials)
    - [8. RemoveCredentials](#8-removecredentials)
    - [9. SearchCredentials](#9-searchcredentials)
    - [10. CreateProof](#10-createproof)


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

## 3. CreateCredentialRequest

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

<br>

## 4. VerifyAndStoreCredential

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

<br>

## 5. GetAllCredentials

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

<br>

## 6. GetCredentials

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

<br>

## 7. RemoveAllCredentials

### Description
`저장된 모든 Credential을 삭제합니다.`

### Declaration

```swift
public func removeAllCredentials() throws
```

### Returns

Void

<br>

## 8. RemoveCredentials

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

<br>

## 9. SearchCredentials

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

<br>

## 10. CreateProof

### Description
`주어진 요청과 선택된 참조 항목을 기반으로 영지식 증명을 생성합니다.`

### Declaration

```swift
public func createProof(proofRequest : ProofRequest,
                        selectedReferents : [UserReferent],
                        proofParam : ZKPProofParam) throws -> ZKPProof
```

### Parameters

| Name                | Type               | Description                                                      | **M/O**   | **Note**   |
| ------------------- | ------------------ | ---------------------------------------------------------------- | --------- | ---------- |
| proofRequest        | ProofRequest       | 요구 속성과 조건을 명시한 증명 요청                                       | M         |            |
| selectedReferents   | [UserReferent]     | 증명 요청을 만족시키기 위해 사용자가 선택한 참조 항목                          | M         |            |
| proofParam          | ZKPProofParam      | 증명 생성에 사용되는 추가 파라미터                                        | M         |            |

### Returns

| Type       | Description       | **M/O**   | **Note**   |
| ---------- | ----------------  | --------- | ---------- |
| ZKPProof   | 생성된 ZKP 영지식 증명 | M         |            |
