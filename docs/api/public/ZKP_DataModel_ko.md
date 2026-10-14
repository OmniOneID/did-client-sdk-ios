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

iOS ZKP DataModel SDK
==

- 주제: ZKP 기반 데이터모델
- 작성: 박주현
- 일자: 2025-04-25
- 버전: v1.0.0

| 버전     | 일자         | 변경 내용 |
| ------ | ---------- | ----- |
| v1.0.0 | 2025-04-25 | 최초 작성 |


<div style="page-break-after: always;"></div>

# 목차

- [DataModel](#datamodel)
    - [1. ZKPCredentialRequestContainer](#1-zkpcredentialrequestcontainer)
        - [1.1. ZKPCredentialRequest](#11-zkpcredentialrequest)
            - [1.1.1. BlindedCredentialSecrets](#111-blindedcredentialsecrets)
            - [1.1.2. BlindedCredentialSecretsCorrectnessProof](#112-blindedcredentialsecretscorrectnessproof)
        - [1.2. ZKPCredentialRequestMeta](#12-zkpcredentialrequestmeta)
            - [1.2.1. MasterSecretBlindingData](#121-mastersecretblindingdata)
    - [2. ZKPCredential](#2-zkpcredential)
        - [2.1. AttributeValue](#21-attributevalue)
        - [2.2. CredentialSignature](#22-credentialsignature)
            - [2.2.1. PrimaryCredentialSignature](#221-primarycredentialsignature)
        - [2.3. SignatureCorrectnessProof](#23-signaturecorrectnessproof)
    - [3. AvailableReferent](#3-availablereferent)
        - [3.1. AttrReferent](#31-attrreferent)
            - [3.1.1. SubReferent](#311-subreferent)
    - [4. ZKProof](#4-zkproof)
        - [4.1. SubProof](#41-subproof)
            - [4.1.1. PrimaryProof](#411-primaryproof)
                - [4.1.1.1. PrimaryEqualProof](#4111-primaryequalproof)
                - [4.1.1.2. PrimaryPredicateInequalityProof](#4112-primarypredicateinequalityproof)
                    - [4.1.1.2.1. Predicate](#41121-predicate)
        - [4.2. AggregatedProof](#42-aggregatedproof)
        - [4.3. RequestedProof](#43-requestedproof)
            - [4.3.1. RequestedAttribute](#431-requestedattribute)
        - [4.4. Identifier](#44-identifier)
    - [5. ProofRequest](#5-proofrequest)
        - [5.1. AttributeInfo](#51-attributeinfo)
        - [5.2. PredicateInfo](#52-predicateinfo)
    - [6. UserReferent](#6-userreferent)
    - [7. ZKProofParam](#7-zkproofparam)
    - [8. ZKPCredentialOffer](#8-zkpcredentialoffer)
        - [8.1. KeyCorrectnessProof](#81-keycorrectnessproof)
    - [9. ZKPCredentialDefinition](#9-zkpcredentialdefinition)
        - [9.1. CredentialDefinitionValue](#91-credentialdefinitionvalue)
            - [9.1.1. CredentialPrimaryPublicKey](#911-credentialprimarypublickey)
    - [10. ZKPCredentialSchema](#10-zkpcredentialschema)
- [Enumerators](#enumerators)
    - [1. PredicateType](#1-predicatetype)
    - [2. CredentialType](#2-credentialtype)
- [Defines](#defines)
    - [1. BigIntString](#1-bigintstring)
    - [2. StringDictionary](#2-stringdictionary)
    - [3. BigIntStringDictionary](#3-bigintstringdictionary)
    - [4. RequestedAttrDictionary](#4-requestedattrdictionary)
    - [5. CaptionString](#5-captionstring)
    
---

<br>

# DataModel

## 1. ZKPCredentialRequestContainer

### Description

`메타데이터와 함께 자격 증명 요청(Credential Request)을 포함하는 객체`

### Declaration

```swift
public struct ZKPCredentialRequestContainer {
    public let credentialRequest     : ZKPCredentialRequest
    public let credentialRequestMeta : ZKPCredentialRequestMeta
}
```

### Property

| Name                    | Type                         | Description                | **M/O** | **Note** |
|-------------------------|------------------------------|----------------------------|---------|----------|
| credentialRequest       | ZKPCredentialRequest         | ZKP 자격 증명 요청             | M       |          |
| credentialRequestMeta   | ZKPCredentialRequestMeta     | 자격 증명 요청에 관련된 메타데이터   | M       |          |


<br>

## 1.1. ZKPCredentialRequest

### Description

`ZKP 기반의 자격 증명 발급 요청 객체`

### Declaration

```swift
public struct ZKPCredentialRequest : Jsonable {
    public let proverDID: String
    public let credDefId: String
    public let nonce    : BigIntString
    public let blindedMs : BlindedCredentialSecrets
    public let blindedMsCorrectnessProof : BlindedCredentialSecretsCorrectnessProof
}
```


### Property

| Name                      | Type                                   | Description                              | **M/O** | **Note** |
|----------------------------|----------------------------------------|------------------------------------------|---------|----------|
| proverDID                  | String                                 | Prover의 DID                             | M       |          |
| credDefId                  | String                                 | 자격 증명 정의 ID                        | M       |          |
| nonce                      | BigIntString                           | 인증에 사용된 난수(Nonce)                | M       |          |
| blindedMs                  | BlindedCredentialSecrets              | 블라인드된 마스터 시크릿                 | M       |          |
| blindedMsCorrectnessProof  | BlindedCredentialSecretsCorrectnessProof | 블라인딩의 정확성을 증명하는 증명(Proof) | M       |          |




<br>

## 1.1.1. BlindedCredentialSecrets

### Description

`블라인드 서명을 사용하여 자격 증명을 서명할 때 발급자에게 특정 속성을 숨기는 값`

### Declaration

```swift
public struct BlindedCredentialSecrets: Jsonable {
    public let u : BigIntString
    public let hiddenAttributes : [String]
}
```

### Property

| Name             | Type         | Description                  | **M/O** | **Note** |
|------------------|--------------|------------------------------|---------|----------|
| u                | BigIntString | 블라인드된 마스터 시크릿            | M       |          |
| hiddenAttributes | [String]     | 숨겨진 속성 이름들의 배열           | M       |          |



<br>

## 1.1.2. BlindedCredentialSecretsCorrectnessProof

### Description

`블라인드된 자격 증명 시크릿에 대한 정확성 증명을 나타내며, 자격 증명 발급 프로토콜 동안 커밋된 시크릿이 올바르게 생성되었음을 보장한다.`

### Declaration

```swift
public struct BlindedCredentialSecretsCorrectnessProof : Jsonable {
    public let c : BigIntString
    public let vDashCap : BigIntString
    public var mCaps : BigIntStringDictionary
}
```

### Property

| Name     | Type                   | Description             | **M/O** | **Note** |
|----------|------------------------|-------------------------|---------|----------|
| c        | BigIntString            | 챌린지 값               | M       |          |
| vDashCap | BigIntString            | 블라인딩 검증 값        | M       |          |
| mCaps    | BigIntStringDictionary  | m에 대한 응답 값들       | M       |          |




<br>

## 1.2. ZKPCredentialRequestMeta

### Description

`ZKP 기반 자격 증명 요청 과정에서 사용되는 메타데이터`

### Declaration

```swift
public struct ZKPCredentialRequestMeta {
    let masterSecretBlidingData : MasterSecretBlindingData
    let nonce : BigIntString
    let masterSecretName : String
}
```

### Property

| Name                    | Type                     | Description                                | **M/O** | **Note** |
|--------------------------|---------------------------|--------------------------------------------|---------|----------|
| masterSecretBlidingData  | MasterSecretBlindingData   | 마스터 시크릿에 적용된 블라인딩 팩터       | M       |          |
| nonce                    | BigIntString               | 리플레이 공격을 방지하기 위해 사용된 임의의 챌린지 | M       |          |
| masterSecretName         | String                     | 마스터 시크릿의 식별자                    | M       |          |


<br>

## 1.2.1. MasterSecretBlindingData

### Description

`제로 지식 증명 프로토콜에서 자격 증명 발급 과정 중 마스터 시크릿을 커밋할 때 사용된 블라인딩 팩터를 포함한다.`

### Declaration

```swift
public struct MasterSecretBlindingData {
    let vPrime : BigIntString
}
```

### Property

| Name   | Type         | Description                          | **M/O** | **Note** |
|--------|--------------|--------------------------------------|---------|----------|
| vPrime | BigIntString | 마스터 시크릿에 적용된 블라인딩 값            | M       |          |




<br>

## 2. ZKPCredential

### Description

`제로 지식 증명을 위한 자격 증명`

### Declaration

```swift
public struct ZKPCredential : Jsonable {
    public let credentialId              : String
    public let schemaId                  : String
    public let credDefId                 : String
    public let values                    : [String : AttributeValue]
    public var signature                 : CredentialSignature
    public let signatureCorrectnessProof : SignatureCorrectnessProof
}
```

### Property

| Name                      | Type                              | Description                           | **M/O** | **Note** |
|---------------------------|-----------------------------------|---------------------------------------|---------|----------|
| credentialId              | String                            | 자격 증명의 고유 식별자               | M       |          |
| schemaId                  | String                            | 스키마의 식별자                        | M       |          |
| credDefId                 | String                            | 자격 증명 정의 ID                      | M       |          |
| values                    | [String : AttributeValue]         | 속성 이름-값 쌍                        | M       |          |
| signature                 | CredentialSignature               | 서명 정보                              | M       |          |
| signatureCorrectnessProof | SignatureCorrectnessProof         | 서명의 정확성을 증명하는 증명(Proof)    | M       |          |



<br>

## 2.1. AttributeValue

### Description

`자격 증명 속성의 값을 사람이 읽을 수 있는 형태와 인코딩된 형태로 모두 표현한 것`

### Declaration

```swift
public struct AttributeValue : Jsonable {
    public let encoded : BigIntString
    public private(set) var raw : String
}
```

### Property

| Name    | Type         | Description                             | **M/O** | **Note** |
|---------|--------------|-----------------------------------------|---------|----------|
| encoded | BigIntString | 속성의 암호학적으로 인코딩된 표현       | M       |          |
| raw     | String       | 속성의 원래 사람이 읽을 수 있는 값      | M       |          |





<br>

## 2.2. CredentialSignature

### Description

`자격 증명의 서명 정보를 포함한다`

코드에서 이 타입은 `ZKPCredential`에 중첩되어 있다(`ZKPCredential.CredentialSignature`).

### Declaration

```swift
public struct CredentialSignature : Jsonable {
    public var pCredential : PrimaryCredentialSignature
}
```

### Property

| Name        | Type                       | Description                             | **M/O** | **Note** |
|-------------|----------------------------|-----------------------------------------|---------|----------|
| pCredential | PrimaryCredentialSignature | 각 주요 서명 값과 그에 연관된 데이터      | M       |          |




<br>

## 2.2.1. PrimaryCredentialSignature

### Description

`ZKP 기반 자격 증명의 주요 서명 값을 나타내며, 일반적으로 CL 서명 방식에서 사용된다.`

코드에서 이 타입은 `ZKPCredential.CredentialSignature`에 중첩되어 있다(`ZKPCredential.CredentialSignature.PrimaryCredentialSignature`).

### Declaration

```swift
public struct PrimaryCredentialSignature : Jsonable {
    public let a : BigIntString
    public let e : BigIntString
    public let m2 : BigIntString
    public let q : BigIntString
    public var v : BigIntString
}
```

### Property

| Name | Type         | Description                                  | **M/O** | **Note** |
|------|--------------|----------------------------------------------|---------|----------|
| a    | BigIntString | 주요 서명 구성 요소                          | M       |          |
| e    | BigIntString | 서명에 사용된 공개 지수                      | M       |          |
| m2   | BigIntString | 숨겨진 속성에 대한 커밋 값                   | M       |          |
| q    | BigIntString | 암호학적 구성에 사용되는 큰 소수             | M       |          |
| v    | BigIntString | 제로 지식 증명을 위한 블라인딩 팩터          | M       |          |


<br>

## 2.3. SignatureCorrectnessProof

### Description

`서명의 무결성을 검증하는 데 사용되는 SignatureCorrectnessProof 데이터`

코드에서 이 타입은 `ZKPCredential`에 중첩되어 있다(`ZKPCredential.SignatureCorrectnessProof`).

### Declaration

```swift
public struct SignatureCorrectnessProof : Jsonable {
    public let se : BigIntString
    public let c  : BigIntString
}
```

### Property

| Name | Type         | Description                                           | **M/O** | **Note** |
|------|--------------|-------------------------------------------------------|---------|----------|
| se   | BigIntString | 서명이 변조되지 않았음을 증명하는 해시 값            | M       |          |
| c    | BigIntString | 일관성을 검증하는 데 사용되는 보조 해시 값            | M       |          |



<br>

## 3. AvailableReferent

### Description

`증명 생성을 위해 사용할 수 있는 소유자의 자격 증명 내 속성들에 대한 정보`

### Declaration

```swift
public struct AvailableReferent {
    public let selfAttrReferent  : [AttrReferent]
    public let attrReferent      : [AttrReferent]
    public let predicateReferent : [AttrReferent]
}
```

### Property

| Name              | Type           | Description                              | **M/O** | **Note** |
|-------------------|----------------|------------------------------------------|---------|----------|
| selfAttrReferent  | [AttrReferent] | 자기 증명 속성                           | M       |          |
| attrReferent      | [AttrReferent] | 제출할 일반 속성                         | M       |          |
| predicateReferent | [AttrReferent] | 조건 기반 속성(Predicate 기반 속성)      | M       |          |




<br>

## 3.1. AttrReferent

### Description

`증명 생성 과정에서 사용되는 속성 관련 정보를 나타내는 객체`

### Declaration

```swift
public struct AttrReferent {
    public let key : String
    public let name : String
    public let checkRevealed : Bool
    public let referent : [SubReferent]
}
```

### Property

| Name          | Type          | Description                       | **M/O** | **Note** |
|---------------|---------------|-----------------------------------|---------|----------|
| key           | String        | 참조 키                            | M       |          |
| name          | String        | 참조 이름                          | M       |          |
| checkRevealed | Bool          | 공개 여부                          | M       |          |
| referent      | [SubReferent] | 하위 참조자(SubReferent)          | M       |          |



<br>

## 3.1.1. SubReferent

### Description

`특정 속성과 관련된 정보를 포함한다.`

### Declaration

```swift
public struct SubReferent {
    public let raw : String
    public let credId : String
    public let credDefId : String
    public let schemaId : String
}
```

### Property

| Name      | Type   | Description                           | **M/O** | **Note** |
|-----------|--------|---------------------------------------|---------|----------|
| raw       | String | 속성의 원시 값                        | M       |          |
| credId    | String | 속성을 포함하고 있는 자격 증명 ID     | M       |          |
| credDefId | String | 자격 증명 정의 ID                     | M       |          |
| schemaId  | String | 스키마의 식별자                       | M       |          |



<br>

## 4. ZKProof

### Description

`ZKP 기반으로 생성된 증명 객체`

### Declaration

```swift
public struct ZKProof : Jsonable {
    public let proofs : [SubProof]
    public let aggregatedProof : AggregatedProof
    public let requestedProof : RequestedProof
    public let identifiers : [Identifier]
}
```

### Property

| Name            | Type             | Description                                   | **M/O** | **Note** |
|-----------------|------------------|-----------------------------------------------|---------|----------|
| proofs          | [SubProof]       | 서브 증명들의 배열                            | M       |          |
| aggregatedProof | AggregatedProof  | 집계된 ZKP 증명 값                            | M       |          |
| requestedProof  | RequestedProof   | 요청된 속성에 해당하는 증명                  | M       |          |
| identifiers     | [Identifier]     | 사용된 자격 증명 식별자들                     | M       |          |



<br>

## 4.1. SubProof

### Description

`기본 증명 정보를 포함한다.`

코드에서 이 타입은 `ZKProof`에 중첩되어 있다(`ZKProof.SubProof`).

### Declaration

```swift
public struct SubProof : Jsonable {
    public let primaryProof : PrimaryProof
}
```

### Property

| Name         | Type         | Description     | **M/O** | **Note** |
|--------------|--------------|-----------------|---------|----------|
| primaryProof | PrimaryProof | Primary proof   | M       |          |



<br>

## 4.1.1. PrimaryProof

### Description

`기본적인 동등성과 부등식 증명을 포함하는 객체`


코드에서 이 타입은 `ZKProof.SubProof`에 중첩되어 있다(`ZKProof.SubProof.PrimaryProof`).

### Declaration

```swift
public struct PrimaryProof : Jsonable {
    public let eqProof : PrimaryEqualProof
    public let neProofs : [PrimaryPredicateInequalityProof]
}
```

### Property

| Name     | Type                                  | Description                          | **M/O** | **Note** |
|----------|---------------------------------------|--------------------------------------|---------|----------|
| eqProof  | PrimaryEqualProof                     | 기본적인 동등성 증명                 | M       |          |
| neProofs | [PrimaryPredicateInequalityProof]     | 부등식 증명                          | M       |          |



<br>

## 4.1.1.1. PrimaryEqualProof

### Description

`동등성 증명을 위한 데이터를 포함하는 객체`

코드에서 이 타입은 `ZKProof.SubProof.PrimaryProof`에 중첩되어 있다(`ZKProof.SubProof.PrimaryProof.PrimaryEqualProof`).

### Declaration

```swift
public struct PrimaryEqualProof : Jsonable {
    public let revealedAttrs : BigIntStringDictionary
    public let aPrime : BigIntString
    public let e : BigIntString
    public let v : BigIntString
    public let m : BigIntStringDictionary
    public let m2 : BigIntString
}
```

### Property

| Name          | Type                   | Description                                                   | **M/O** | **Note** |
|---------------|------------------------|---------------------------------------------------------------|---------|----------|
| revealedAttrs | BigIntStringDictionary | 검증자에게 공개된 속성들의 Dictionary                        | M       |          |
| aPrime        | BigIntString           | 증명에 사용된 변형된 서명 구성 요소                         | M       |          |
| e             | BigIntString           | 원본 서명에서의 블라인드된 지수                             | M       |          |
| v             | BigIntString           | 블라인드된 블라인딩 팩터                                     | M       |          |
| m             | BigIntStringDictionary | 블라인드된 형태로 숨겨진 속성 값들의 Dictionary             | M       |          |
| m2            | BigIntString           | 숨겨진 속성에 대한 블라인드된 커밋먼트                       | M       |          |




<br>

## 4.1.1.2. PrimaryPredicateInequalityProof

### Description

`ZKP 프레젠테이션에서 부등식 증명 구성 요소를 나타내며, 숨겨진 속성이 그 실제 값을 공개하지 않고 조건(예: 나이 ≥ 18)을 만족함을 증명하는 데 사용된다.`

코드에서 이 타입은 `ZKProof.SubProof.PrimaryProof`에 중첩되어 있다(`ZKProof.SubProof.PrimaryProof.PrimaryPredicateInequalityProof`).

### Declaration

```swift
public struct PrimaryPredicateInequalityProof : Jsonable {
    public let u : BigIntStringDictionary
    public let r : BigIntStringDictionary
    public let t : BigIntStringDictionary
    public let mj : BigIntString
    public let alpha : BigIntString
    public let predicate : Predicate
}
```

### Property

| Name      | Type                   | Description                                      | **M/O** | **Note** |
|-----------|------------------------|--------------------------------------------------|---------|----------|
| u         | BigIntStringDictionary | 조건과 관련된 커밋먼트 값들                       | M       |          |
| r         | BigIntStringDictionary | ZKP에서 사용되는 응답 값들                       | M       |          |
| t         | BigIntStringDictionary | 조건 증명을 검증하는 데 사용되는 T 값들         | M       |          |
| mj        | BigIntString           | 숨겨진 속성에 대한 커밋먼트                       | M       |          |
| alpha     | BigIntString           | 증명에 사용된 블라인딩 팩터                      | M       |          |
| predicate | Predicate              | 증명되는 조건                                    | M       |          |




<br>

## 4.1.1.2.1. Predicate

### Description

`제로 지식 증명에서 사용되는 조건을 정의하며, 일반적으로 숨겨진 속성이 주어진 부등식(예: 나이 ≥ 18)을 만족함을 실제 값을 공개하지 않고 증명하는 데 사용된다.`

코드에서 이 타입은 `PrimaryPredicateInequalityProof` 가 아니라 `ZKProof` 에 직접 중첩되어 있다(`ZKProof.Predicate`).

### Declaration

```swift
public struct Predicate : Jsonable {
    public let pType : PredicateType
    public let pValue : Int
    public let attrName : String
}
```

### Property

| Name     | Type          | Description                                 | **M/O** | **Note** |
|----------|---------------|---------------------------------------------|---------|----------|
| pType    | PredicateType | 조건의 유형                                | M       | [PredicateType](#1-predicatetype) |
| pValue   | Int           | 속성과 비교할 값                           | M       |          |
| attrName | String        | 평가되는 속성의 이름                        | M       |          |




<br>

## 4.2. AggregatedProof

### Description

`여러 증명을 하나의 ZKP로 집계하는 구조`

코드에서 이 타입은 `ZKProof`에 중첩되어 있다(`ZKProof.AggregatedProof`).

### Declaration

```swift
public struct AggregatedProof : Jsonable {
    public let cHash : BigIntString
    public let cList : [[UInt8]]
}
```

### Property

| Name  | Type         | Description                             | **M/O** | **Note** |
|-------|--------------|-----------------------------------------|---------|----------|
| cHash | BigIntString | 집계된 챌린지 값                        | M       |          |
| cList | [[UInt8]]    | 서브 증명들의 챌린지 값들               | M       |          |




<br>

## 4.3. RequestedProof

### Description

`요청된 속성에 대한 응답으로 제출된 실제 속성들을 분류한다.`

코드에서 이 타입은 `ZKProof`에 중첩되어 있다(`ZKProof.RequestedProof`).

### Declaration

```swift
public struct RequestedProof : Jsonable {
    public let selfAttestedAttrs : StringDictionary
    public let predicates : RequestedAttrDictionary
    public let revealedAttrs : RequestedAttrDictionary
    public let unrevealedAttrs : RequestedAttrDictionary
}
```

### Property

| Name              | Type                    | Description                          | **M/O** | **Note** |
|-------------------|-------------------------|--------------------------------------|---------|----------|
| selfAttestedAttrs | StringDictionary        | 자기 증명 속성                       | M       |          |
| predicates        | RequestedAttrDictionary | 조건 기반 속성 증명                 | M       |          |
| revealedAttrs     | RequestedAttrDictionary | 공개된 속성                          | M       |          |
| unrevealedAttrs   | RequestedAttrDictionary | 숨겨진 속성                          | M       |          |




<br>

## 4.3.1. RequestedAttribute

### Description

`검증자가 요청한 ZKP 프레젠테이션에 포함된 속성을 나타낸다.`

코드에서 이 타입은 `ZKProof`에 중첩되어 있다(`ZKProof.RequestedAttribute`).

### Declaration

```swift
public struct RequestedAttribute : Jsonable {
    public let subProofIndex : Int
    public let raw : String?
    public let encoded : String?
}
```

### Property

| Name          | Type   | Description                                                       | **M/O** | **Note** |
|---------------|--------|-------------------------------------------------------------------|---------|----------|
| subProofIndex | Int    | 속성이 증명된 서브 증명의 인덱스                                 | M       |          |
| raw           | String | 속성의 사람이 읽을 수 있는 값(공개된 경우)                       | O       |          |
| encoded       | String | 암호학적 증명을 위해 사용된 인코딩된 숫자 표현                  | O       |          |



<br>

## 4.4. Identifier

### Description

`증명을 구축하는 데 사용된 식별자들을 포함한다.`

코드에서 이 타입은 `ZKProof`에 중첩되어 있다(`ZKProof.Identifier`).

### Declaration

```swift
public struct Identifier : Jsonable {
    public let credDefId : String
    public let schemaId : String
}
```

### Property

| Name      | Type   | Description                             | **M/O** | **Note** |
|-----------|--------|-----------------------------------------|---------|----------|
| credDefId | String | 참조된 자격 증명 정의 ID               | M       |          |
| schemaId  | String | 참조된 자격 증명 스키마 ID             | M       |          |




<br>

## 5. ProofRequest

### Description

`검증자의 증명 요청. 소유자에게 증명을 요구하는 속성과 조건`

### Declaration

```swift
public struct ProofRequest : Jsonable {
    public let name : String
    public let version : String
    public let nonce : BigIntString
    public let requestedAttributes : [String : AttributeInfo]?
    public let requestedPredicates : [String : PredicateInfo]?
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| name | String | 증명 요청 이름 | M |  |
| version | String | 증명 요청 버전 | M |  |
| nonce | BigIntString | 검증자의 nonce | M |  |
| requestedAttributes | [String : AttributeInfo] | 요청 속성. 키는 referent key | O | [AttributeInfo](#51-attributeinfo) |
| requestedPredicates | [String : PredicateInfo] | 요청 조건. 키는 referent key | O | [PredicateInfo](#52-predicateinfo) |

<br>

## 5.1. AttributeInfo

### Description

`요청 속성`

### Declaration

```swift
public struct AttributeInfo: Jsonable {
    public let name: String
    public let restrictions : [[String : String]]
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| name | String | 속성 이름 | M |  |
| restrictions | [[String : String]] | 속성을 가져올 수 있는 Credential 정의 | M | 키와 상관없이 모든 값을 Credential 정의 ID로 읽는다. 빈 목록이면 자기 증명 속성이다 |

<br>

## 5.2. PredicateInfo

### Description

`속성에 대한 요청 조건`

### Declaration

```swift
public struct PredicateInfo: Jsonable {
    public let name: String
    public let pType : PredicateType
    public let pValue : Int
    public let restrictions : [[String : String]]
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| name | String | 속성 이름 | M |  |
| pType | PredicateType | 비교 연산자 | M | [PredicateType](#1-predicatetype) |
| pValue | Int | 속성과 비교할 값 | M |  |
| restrictions | [[String : String]] | 속성을 가져올 수 있는 Credential 정의 | M | 키와 상관없이 모든 값을 Credential 정의 ID로 읽는다 |

<br>

## 6. UserReferent

### Description

`증명 요청의 referent 하나에 대한 소유자의 선택`

### Declaration

```swift
public struct UserReferent {
    public let credId       : String?
    public let raw          : String
    public let referentKey  : String
    public let referentName : String
    public let isRevealed   : Bool

    public init(raw: String, referentKey: String, referentName: String)
    public init(selectedAttrSubReferent: SubReferent, referentKey: String, referentName: String, isRevealed: Bool)
    public init(attrReferent: AttrReferent, selectedIndex: UInt, isRevealed: Bool) throws
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| credId | String | 값을 가져온 Credential ID | O | 자기 증명 속성이면 `nil` |
| raw | String | 속성 원본 값 | M |  |
| referentKey | String | 증명 요청의 referent key | M |  |
| referentName | String | referent 이름 | M |  |
| isRevealed | Bool | 검증자에게 값을 공개할지 여부 | M | 자기 증명 속성은 항상 `true` |

### Method

| Name | Description | **Note** |
|------|-------------|----------|
| init(raw:referentKey:referentName:) | 소유자가 입력한 자기 증명 속성 |  |
| init(selectedAttrSubReferent:referentKey:referentName:isRevealed:) | 선택한 [SubReferent](#311-subreferent)에서 Credential과 값을 가져온다 |  |
| init(attrReferent:selectedIndex:isRevealed:) | [AttrReferent](#31-attrreferent)의 `selectedIndex` 번째 referent를 가져온다 | `selectedIndex`가 범위를 벗어나면 throw |

<br>

## 7. ZKProofParam

### Description

`증명 생성에 필요한 스키마와 Credential 정의`

### Declaration

```swift
public struct ZKProofParam {
    public let schemas : [String : ZKPCredentialSchema]
    public let creDefs : [String : ZKPCredentialDefinition]

    public init(schemas: [String : ZKPCredentialSchema], creDefs: [String : ZKPCredentialDefinition])
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| schemas | [String : ZKPCredentialSchema] | Credential 스키마. 키는 스키마 ID | M | [ZKPCredentialSchema](#10-zkpcredentialschema) |
| creDefs | [String : ZKPCredentialDefinition] | Credential 정의. 키는 Credential 정의 ID | M | [ZKPCredentialDefinition](#9-zkpcredentialdefinition) |

<br>

## 8. ZKPCredentialOffer

### Description

`발급자의 Credential 제안`

### Declaration

```swift
public struct ZKPCredentialOffer : Jsonable {
    public let credDefId : String
    public let schemaId : String
    public let keyCorrectnessProof : KeyCorrectnessProof
    public let nonce : BigIntString
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| credDefId | String | Credential 정의 ID | M |  |
| schemaId | String | Credential 스키마 ID | M |  |
| keyCorrectnessProof | KeyCorrectnessProof | 발급자 키가 올바른 형식임을 보이는 증명 | M | [KeyCorrectnessProof](#81-keycorrectnessproof) |
| nonce | BigIntString | Nonce | M |  |

<br>

## 8.1. KeyCorrectnessProof

### Description

`발급자 공개키의 정확성 증명`

### Declaration

```swift
public struct KeyCorrectnessProof : Jsonable {
    public let c : BigIntString
    public let xzCap : BigIntString
    public let xrCap : BigIntStringDictionary
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| c | BigIntString | 챌린지 해시 | M |  |
| xzCap | BigIntString | `z`에 대한 응답 값 | M |  |
| xrCap | BigIntStringDictionary | 각 `r`에 대한 응답 값. 키는 속성 이름 | M |  |

<br>

## 9. ZKPCredentialDefinition

### Description

`발급자가 공개한 Credential 정의`

### Declaration

```swift
public struct ZKPCredentialDefinition : Jsonable {
    public let id: String
    public let schemaId: String
    public let ver : String
    public let type : CredentialType
    public let value : CredentialDefinitionValue
    public let tag : String
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| id | String | Credential 정의 ID | M |  |
| schemaId | String | Credential 스키마 ID | M |  |
| ver | String | 버전 | M |  |
| type | CredentialType | 서명 타입 | M | [CredentialType](#2-credentialtype) |
| value | CredentialDefinitionValue | 공개키 정보 | M | [CredentialDefinitionValue](#91-credentialdefinitionvalue) |
| tag | String | 태그 | M |  |

<br>

## 9.1. CredentialDefinitionValue

### Description

`Credential 정의의 공개키 정보`

### Declaration

```swift
public struct CredentialDefinitionValue : Jsonable {
    public let primary : CredentialPrimaryPublicKey
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| primary | CredentialPrimaryPublicKey | 기본 공개키 | M | [CredentialPrimaryPublicKey](#911-credentialprimarypublickey) |

<br>

## 9.1.1. CredentialPrimaryPublicKey

### Description

`발급자의 기본(CL) 공개키`

`Jsonable`의 `init(from:)`으로 디코딩하면 `r`은 JSON에 적힌 키 순서를 그대로 유지하고, 인코딩할 때도 그 순서로 쓴다. 일반 `JSONDecoder`는 순서를 보장하지 않는다.

### Declaration

```swift
public struct CredentialPrimaryPublicKey : Jsonable {
    public let n : BigIntString
    public let z : BigIntString
    public let s : BigIntString
    public var r : OrderedStringMap<BigIntString>
    public let rctxt : BigIntString
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| n | BigIntString | RSA 모듈러스 | M |  |
| z | BigIntString | 공개키 구성 요소 `Z` | M |  |
| s | BigIntString | 공개키 구성 요소 `S` | M |  |
| r | OrderedStringMap&lt;BigIntString&gt; | 속성별 공개키 구성 요소 `R`. 키는 속성 이름 | M | [OrderedStringMap](DataModel_ko.md#19-orderedstringmap). 순서도 값의 일부다 |
| rctxt | BigIntString | 컨텍스트 속성용 공개키 구성 요소 | M |  |

<br>

## 10. ZKPCredentialSchema

### Description

`발급자가 공개한 Credential 스키마`

### Declaration

```swift
public struct ZKPCredentialSchema : Jsonable {
    public let id: String
    public let name: String
    public let version: String
    public let attrNames : [String]
    public let attrTypes : [AttributeType]
    public let tag: String

    public struct AttributeType : Jsonable {
        public struct Namespace : Jsonable {
            public var id   : String
            public var name : String
            public var ref  : String?
        }

        public struct AttributeDef : Jsonable {
            public var label   : String
            public var caption : CaptionString
            public var type    : AttributeValueType
            public var i18n    : [String : CaptionString]?
        }

        public enum AttributeValueType : String, Codable, Sendable {
            case String
            case Number
        }

        public var namespace : Namespace
        public var items     : [AttributeDef]
    }
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| id | String | Credential 스키마 ID | M |  |
| name | String | 스키마 이름 | M |  |
| version | String | 버전 | M |  |
| attrNames | [String] | 속성 이름 목록 | M |  |
| attrTypes | [AttributeType] | 네임스페이스별 속성 정의 | M |  |
| tag | String | 태그 | M |  |
| AttributeType.namespace | Namespace | 속성 네임스페이스(`id`, `name`, 선택 항목인 `ref` URL) | M |  |
| AttributeType.items | [AttributeDef] | 속성 정의(`label`, `caption`, `type`, 선택 항목인 `i18n`) | M |  |
| AttributeDef.type | AttributeValueType | 값 타입: `String` 또는 `Number` | M |  |

<br>

# Enumerators

## 1. PredicateType

### Description

`조건의 비교 연산자`

### Declaration

```swift
@frozen public enum PredicateType : String, Codable {
    case GE
    case LE
    case GT
    case LT
}
```

| Case | 의미 |
|------|------|
| GE | `>=` |
| LE | `<=` |
| GT | `>` |
| LT | `<` |

<br>

## 2. CredentialType

### Description

`Credential 정의의 서명 타입`

### Declaration

```swift
public enum CredentialType : String, Codable, Sendable {
    case cl = "CL"
}
```

| Case | 원시값 | 의미 |
|------|--------|------|
| cl | "CL" | Camenisch-Lysyanskaya 서명 |

<br>

# Defines

## 1. BigIntString

### Declaration

```swift
public typealias BigIntString = String
```

## 2. StringDictionary

### Declaration

```swift
public typealias StringDictionary = [String : String]
```

## 3. BigIntStringDictionary

### Declaration

```swift
public typealias BigIntStringDictionary = [String : BigIntString]
```

## 4. RequestedAttrDictionary

### Declaration

```swift
public typealias RequestedAttrDictionary = [String : ZKProof.RequestedAttribute]
```

## 5. CaptionString

### Declaration

```swift
public typealias CaptionString = String
```
