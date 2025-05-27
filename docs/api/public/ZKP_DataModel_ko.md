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
- [Defines](#defines)
    - [1. BigIntString](#-1bigintstring)
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

### Declaration

```swift
public struct SubProof : Codable {
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


### Declaration

```swift
public struct PrimaryProof : Codable {
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

### Declaration

```swift
public struct PrimaryEqualProof : Codable {
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

### Declaration

```swift
public struct PrimaryPredicateInequalityProof : Codable {
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

### Declaration

```swift
public struct Predicate : Codable {
    public let pType : PredicateType
    public let pValue : Int
    public let attrName : String
}
```

### Property

| Name     | Type          | Description                                 | **M/O** | **Note** |
|----------|---------------|---------------------------------------------|---------|----------|
| pType    | PredicateType | 조건의 유형                                | M       |          |
| pValue   | Int           | 속성과 비교할 값                           | M       |          |
| attrName | String        | 평가되는 속성의 이름                        | M       |          |




<br>

## 4.2. AggregatedProof

### Description

`여러 증명을 하나의 ZKP로 집계하는 구조`

### Declaration

```swift
public struct AggregatedProof : Codable {
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

### Declaration

```swift
public struct RequestedProof : Codable {
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

### Declaration

```swift
public struct RequestedAttribute : Codable {
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

### Declaration

```swift
public struct Identifier : Codable {
    public let credDefId : String
    public let schemaId : String
}
```

### Property

| Name      | Type   | Description                             | **M/O** | **Note** |
|-----------|--------|-----------------------------------------|---------|----------|
| credDefId | String | 참조된 자격 증명 스키마 ID             | M       |          |
| schemaId  | String | 참조된 자격 증명 정의 ID               | M       |          |




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
