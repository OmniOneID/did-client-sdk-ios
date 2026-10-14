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

- Subject: ZKP-Based Data Model
- Author: JooHyun Park
- Date: 2025-04-25
- Version: v1.0.0

| Version | Date       | Change Description |
|---------|------------|--------------------|
| v1.0.0  | 2025-04-25 | Initial version    |

<div style="page-break-after: always;"></div>

# Table of Contents

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

`An object containing a Credential Request along with its metadata`

### Declaration

```swift
public struct ZKPCredentialRequestContainer {
    public let credentialRequest     : ZKPCredentialRequest
    public let credentialRequestMeta : ZKPCredentialRequestMeta
}
```

### Property

| Name                    | Type                         | Description                                     | **M/O** | **Note** |
|-------------------------|------------------------------|-------------------------------------------------|---------|----------|
| credentialRequest       | ZKPCredentialRequest         | The ZKP credential request                      | M       |          |
| credentialRequestMeta   | ZKPCredentialRequestMeta     | Metadata associated with the credential request | M       |          |


<br>

## 1.1. ZKPCredentialRequest

### Description

`Credential issuance request object based on ZKP`

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

| Name                          | Type                                      | Description                                 | **M/O** | **Note** |
|-------------------------------|-------------------------------------------|---------------------------------------------|---------|----------|
| proverDID                     | String                                    | Prover's DID                                | M       |          |
| credDefId                     | String                                    | Credential Definition ID                    | M       |          |
| nonce                         | BigIntString                              | Nonce used for authentication               | M       |          |
| blindedMs                     | BlindedCredentialSecrets                  | Blinded Master Secret                       | M       |          |
| blindedMsCorrectnessProof     | BlindedCredentialSecretsCorrectnessProof  | Proof of correctness of blinding            | M       |          |



<br>

## 1.1.1. BlindedCredentialSecrets

### Description

`A value that hides specific attributes from the issuer when signing credentials using blind signatures`

### Declaration

```swift
public struct BlindedCredentialSecrets: Jsonable {
    public let u : BigIntString
    public let hiddenAttributes : [String]
}
```

### Property

| Name             | Type         | Description                       | **M/O** | **Note** |
|------------------|--------------|-----------------------------------|---------|----------|
| u                | BigIntString | Blinded Master Secret             | M       |          |
| hiddenAttributes | [String]     | Array of hidden attribute names   | M       |          |


<br>

## 1.1.2. BlindedCredentialSecretsCorrectnessProof

### Description

`Represents the correctness proof for blinded credential secrets, ensuring that the committed secrets were formed correctly during the credential issuance protocol.`

### Declaration

```swift
public struct BlindedCredentialSecretsCorrectnessProof : Jsonable {
    public let c : BigIntString
    public let vDashCap : BigIntString
    public var mCaps : BigIntStringDictionary
}
```

### Property

| Name     | Type                   | Description                     | **M/O** | **Note** |
|----------|------------------------|---------------------------------|---------|----------|
| c        | BigIntString           | Challenge value                 | M       |          |
| vDashCap | BigIntString           | Blinding verification value     | M       |          |
| mCaps    | BigIntStringDictionary | Response values for m           | M       |          |



<br>

## 1.2. ZKPCredentialRequestMeta

### Description

`Metadata used during the ZKP-based credential request process.`

### Declaration

```swift
public struct ZKPCredentialRequestMeta {
    let masterSecretBlidingData : MasterSecretBlindingData
    let nonce : BigIntString
    let masterSecretName : String
}
```

### Property

| Name                    | Type                      | Description                                          | **M/O** | **Note** |
|-------------------------|---------------------------|------------------------------------------------------|---------|----------|
| masterSecretBlidingData | MasterSecretBlindingData  | Blinding factor applied to the master secret         | M       |          |
| nonce                   | BigIntString              | Random challenge used to prevent replay attacks      | M       |          |
| masterSecretName        | String                    | Identifier for the master secret                     | M       |          |


<br>

## 1.2.1. MasterSecretBlindingData

### Description

`Contains the blinding factor used when committing the master secret during the credential issuance process in a zero-knowledge proof protocol.`

### Declaration

```swift
public struct MasterSecretBlindingData {
    let vPrime : BigIntString
}
```

### Property

| Name   | Type         | Description                                  | **M/O** | **Note** |
|--------|--------------|----------------------------------------------|---------|----------|
| vPrime | BigIntString | Blinding value applied to the master secret  | M       |          |



<br>

## 2. ZKPCredential

### Description

`A Credential for Zero-Knowledge Proof`

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

| Name                      | Type                                | Description                                 | **M/O** | **Note** |
|---------------------------|-------------------------------------|---------------------------------------------|---------|----------|
| credentialId              | String                              | Unique identifier for the credential        | M       |          |
| schemaId                  | String                              | Identifier of the schema                    | M       |          |
| credDefId                 | String                              | Credential Definition ID                    | M       |          |
| values                    | [String : AttributeValue]           | Attribute name-value pairs                  | M       |          |
| signature                 | CredentialSignature                 | Signature information                       | M       |          |
| signatureCorrectnessProof | SignatureCorrectnessProof           | Proof of correctness of the signature       | M       |          |


<br>

## 2.1. AttributeValue

### Description

`Represents a credential attribute's value in both human-readable and encoded forms`

### Declaration

```swift
public struct AttributeValue : Jsonable {
    public let encoded : BigIntString
    public private(set) var raw : String
}
```

### Property

| Name    | Type         | Description                                                  | **M/O** | **Note** |
|---------|--------------|--------------------------------------------------------------|---------|----------|
| encoded | BigIntString | Cryptographically encoded representation of the attribute    | M       |          |
| raw     | String       | Original human-readable value of the attribute              | M       |          |



<br>

## 2.2. CredentialSignature

### Description

`Contains the signature information of the credential`

In code, this type is nested in `ZKPCredential` (`ZKPCredential.CredentialSignature`).

### Declaration

```swift
public struct CredentialSignature : Jsonable {
    public var pCredential : PrimaryCredentialSignature
}
```

### Property

| Name        | Type                       | Description                                          | **M/O** | **Note** |
|-------------|----------------------------|------------------------------------------------------|---------|----------|
| pCredential | PrimaryCredentialSignature | Each primary signature value and its associated data | M       |          |



<br>

## 2.2.1. PrimaryCredentialSignature

### Description

`Represents the primary signature values for a ZKP-based credential, typically used in CL signature schemes.`

In code, this type is nested in `ZKPCredential.CredentialSignature` (`ZKPCredential.CredentialSignature.PrimaryCredentialSignature`).

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

| Name | Type         | Description                                        | **M/O** | **Note** |
|------|--------------|----------------------------------------------------|---------|----------|
| a    | BigIntString | Main signature component                           | M       |          |
| e    | BigIntString | Public exponent used in the signature              | M       |          |
| m2   | BigIntString | Committed value for hidden attributes              | M       |          |
| q    | BigIntString | A large prime used for cryptographic construction  | M       |          |
| v    | BigIntString | Blinding factor for zero-knowledge proof           | M       |          |


<br>

## 2.3. SignatureCorrectnessProof

### Description

`The SignatureCorrectnessProof data used to verify the integrity of the signature.`

In code, this type is nested in `ZKPCredential` (`ZKPCredential.SignatureCorrectnessProof`).

### Declaration

```swift
public struct SignatureCorrectnessProof : Jsonable {
    public let se : BigIntString
    public let c  : BigIntString
}
```

### Property

| Name | Type         | Description                                                         | **M/O** | **Note** |
|------|--------------|---------------------------------------------------------------------|---------|----------|
| se   | BigIntString | The hash value that proves the signature has not been tampered with | M       |          |
| c    | BigIntString | An auxiliary hash value used to verify consistency                  | M       |          |


<br>

## 3. AvailableReferent

### Description

`Information on attributes in the holder's credentials that can be used for generating a proof`

### Declaration

```swift
public struct AvailableReferent {
    public let selfAttrReferent  : [AttrReferent]
    public let attrReferent      : [AttrReferent]
    public let predicateReferent : [AttrReferent]
}
```

### Property

| Name              | Type           | Description                       | **M/O** | **Note** |
|-------------------|----------------|-----------------------------------|---------|----------|
| selfAttrReferent  | [AttrReferent] | Self-attested attributes          | M       |          |
| attrReferent      | [AttrReferent] | General attributes to submit      | M       |          |
| predicateReferent | [AttrReferent] | Predicate-based attributes        | M       |          |



<br>

## 3.1. AttrReferent

### Description

`An object representing attribute-related information used in the proof generation process.`

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

| Name          | Type          | Description             | **M/O** | **Note** |
|---------------|---------------|-------------------------|---------|----------|
| key           | String        | Referent key            | M       |          |
| name          | String        | Referent name           | M       |          |
| checkRevealed | Bool          | Whether it is revealed  | M       |          |
| referent      | [SubReferent] | SubReferent             | M       |          |


<br>

## 3.1.1. SubReferent

### Description

`Contains information related to a specific attribute.`

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

| Name      | Type   | Description                                 | **M/O** | **Note** |
|-----------|--------|---------------------------------------------|---------|----------|
| raw       | String | Raw value of the attribute                  | M       |          |
| credId    | String | Credential ID that contains the attribute   | M       |          |
| credDefId | String | Credential Definition ID                    | M       |          |
| schemaId  | String | Identifier of the schema                    | M       |          |


<br>

## 4. ZKProof

### Description

`The proof object generated based on ZKP`

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

| Name            | Type             | Description                                  | **M/O** | **Note** |
|-----------------|------------------|----------------------------------------------|---------|----------|
| proofs          | [SubProof]       | Array of sub-proofs                          | M       |          |
| aggregatedProof | AggregatedProof  | Aggregated ZKProof value                     | M       |          |
| requestedProof  | RequestedProof   | Proof corresponding to requested attributes  | M       |          |
| identifiers     | [Identifier]     | Credential identifiers used                  | M       |          |



<br>

## 4.1. SubProof

### Description

`Contains basic proof information.`

In code, this type is nested in `ZKProof` (`ZKProof.SubProof`).

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

`An object containing basic equality and inequality proofs`

In code, this type is nested in `ZKProof.SubProof` (`ZKProof.SubProof.PrimaryProof`).

### Declaration

```swift
public struct PrimaryProof : Jsonable {
    public let eqProof : PrimaryEqualProof
    public let neProofs : [PrimaryPredicateInequalityProof]
}
```

### Property

| Name     | Type                                  | Description                         | **M/O** | **Note** |
|----------|---------------------------------------|-------------------------------------|---------|----------|
| eqProof  | PrimaryEqualProof                     | Basic equality proof                | M       |          |
| neProofs | [PrimaryPredicateInequalityProof]     | Inequality proofs                   | M       |          |



<br>

## 4.1.1.1. PrimaryEqualProof

### Description

`An object that includes data for equality proof`

In code, this type is nested in `ZKProof.SubProof.PrimaryProof` (`ZKProof.SubProof.PrimaryProof.PrimaryEqualProof`).

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

| Name          | Type                   | Description                                                  | **M/O** | **Note** |
|---------------|------------------------|--------------------------------------------------------------|---------|----------|
| revealedAttrs | BigIntStringDictionary | Dictionary of attributes revealed to the verifier            | M       |          |
| aPrime        | BigIntString           | Transformed signature component used in the proof            | M       |          |
| e             | BigIntString           | Blinded exponent from the original signature                 | M       |          |
| v             | BigIntString           | Blinded blinding factor                                      | M       |          |
| m             | BigIntStringDictionary | Dictionary of hidden attribute values in blinded form        | M       |          |
| m2            | BigIntString           | Blinded commitment for the hidden attributes                 | M       |          |



<br>

## 4.1.1.2. PrimaryPredicateInequalityProof

### Description

`Represents the inequality proof component in a ZKP presentation, used to prove that a hidden attribute satisfies a predicate condition(e.g., age ≥ 18) without revealing its actual value.`

In code, this type is nested in `ZKProof.SubProof.PrimaryProof` (`ZKProof.SubProof.PrimaryProof.PrimaryPredicateInequalityProof`).

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
| u         | BigIntStringDictionary | Commitment values related to the predicate       | M       |          |
| r         | BigIntStringDictionary | Response values used in the ZKP                  | M       |          |
| t         | BigIntStringDictionary | T-values used for verifying the predicate proof  | M       |          |
| mj        | BigIntString           | Commitment to the hidden attribute               | M       |          |
| alpha     | BigIntString           | Blinding factor used in the proof                | M       |          |
| predicate | Predicate              | The predicate condition being proven             | M       |          |



<br>

## 4.1.1.2.1. Predicate

### Description

`Defines a predicate condition used in zero-knowledge proofs, typically to prove that a hidden attribute satisfies a given inequality (e.g., age ≥ 18) without revealing the actual value.`

In code, this type is nested directly in `ZKProof` (`ZKProof.Predicate`), not in `PrimaryPredicateInequalityProof`.

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
| pType    | PredicateType | Type of predicate                           | M       | [PredicateType](#1-predicatetype) |
| pValue   | Int           | The value to compare the attribute against  | M       |          |
| attrName | String        | The name of the attribute being evaluated   | M       |          |



<br>

## 4.2. AggregatedProof

### Description

`A structure that aggregates multiple proofs into a single ZKP`

In code, this type is nested in `ZKProof` (`ZKProof.AggregatedProof`).

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
| cHash | BigIntString | Aggregated challenge value              | M       |          |
| cList | [[UInt8]]    | Challenge values of sub-proofs          | M       |          |



<br>

## 4.3. RequestedProof

### Description

`Classifies the actual attributes submitted in response to the requested attributes.`

In code, this type is nested in `ZKProof` (`ZKProof.RequestedProof`).

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

| Name              | Type                    | Description                         | **M/O** | **Note** |
|-------------------|-------------------------|-------------------------------------|---------|----------|
| selfAttestedAttrs | StringDictionary        | Self-attested attributes            | M       |          |
| predicates        | RequestedAttrDictionary | Predicate-based attribute proof     | M       |          |
| revealedAttrs     | RequestedAttrDictionary | Revealed attributes                 | M       |          |
| unrevealedAttrs   | RequestedAttrDictionary | Hidden attributes                   | M       |          |



<br>

## 4.3.1. RequestedAttribute

### Description

`Represents an attribute included in the ZKP presentation that was requested by the verifier.`

In code, this type is nested in `ZKProof` (`ZKProof.RequestedAttribute`).

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
| subProofIndex | Int    | Index of the sub-proof where the attribute is proven              | M       |          |
| raw           | String | Human-readable value of the attribute (if revealed)               | O       |          |
| encoded       | String | Encoded numeric representation used for cryptographic proof       | O       |          |


<br>

## 4.4. Identifier

### Description

`Contains the identifiers used to build the proof.`

In code, this type is nested in `ZKProof` (`ZKProof.Identifier`).

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
| credDefId | String | Referenced Credential Definition ID     | M       |          |
| schemaId  | String | Referenced Credential Schema ID         | M       |          |



<br>

## 5. ProofRequest

### Description

`Proof request from a verifier: the attributes and predicates the holder is asked to prove`

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
| name | String | Name of the proof request | M |  |
| version | String | Version of the proof request | M |  |
| nonce | BigIntString | Nonce from the verifier | M |  |
| requestedAttributes | [String : AttributeInfo] | Requested attributes, keyed by referent key | O | [AttributeInfo](#51-attributeinfo) |
| requestedPredicates | [String : PredicateInfo] | Requested predicates, keyed by referent key | O | [PredicateInfo](#52-predicateinfo) |

<br>

## 5.1. AttributeInfo

### Description

`A requested attribute`

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
| name | String | Attribute name | M |  |
| restrictions | [[String : String]] | Credential definitions the attribute may come from | M | Every value is read as a credential definition ID, whatever its key. An empty list makes the attribute self-attested |

<br>

## 5.2. PredicateInfo

### Description

`A requested predicate on an attribute`

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
| name | String | Attribute name | M |  |
| pType | PredicateType | Comparison operator | M | [PredicateType](#1-predicatetype) |
| pValue | Int | Value the attribute is compared against | M |  |
| restrictions | [[String : String]] | Credential definitions the attribute may come from | M | Every value is read as a credential definition ID, whatever its key |

<br>

## 6. UserReferent

### Description

`The holder's choice for one referent of the proof request`

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
| credId | String | ID of the credential the value comes from | O | `nil` for a self-attested attribute |
| raw | String | Raw attribute value | M |  |
| referentKey | String | Referent key in the proof request | M |  |
| referentName | String | Referent name | M |  |
| isRevealed | Bool | Whether the value is disclosed to the verifier | M | Always `true` for a self-attested attribute |

### Method

| Name | Description | **Note** |
|------|-------------|----------|
| init(raw:referentKey:referentName:) | Self-attested attribute entered by the holder |  |
| init(selectedAttrSubReferent:referentKey:referentName:isRevealed:) | Takes the credential and value from a selected [SubReferent](#311-subreferent) |  |
| init(attrReferent:selectedIndex:isRevealed:) | Takes the referent at `selectedIndex` of an [AttrReferent](#31-attrreferent) | Throws when `selectedIndex` is out of range |

<br>

## 7. ZKProofParam

### Description

`Schemas and credential definitions needed to build a proof`

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
| schemas | [String : ZKPCredentialSchema] | Credential schemas, keyed by schema ID | M | [ZKPCredentialSchema](#10-zkpcredentialschema) |
| creDefs | [String : ZKPCredentialDefinition] | Credential definitions, keyed by credential definition ID | M | [ZKPCredentialDefinition](#9-zkpcredentialdefinition) |

<br>

## 8. ZKPCredentialOffer

### Description

`Credential offer from an issuer`

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
| credDefId | String | Credential definition ID | M |  |
| schemaId | String | Credential schema ID | M |  |
| keyCorrectnessProof | KeyCorrectnessProof | Proof that the issuer's key is well formed | M | [KeyCorrectnessProof](#81-keycorrectnessproof) |
| nonce | BigIntString | Nonce | M |  |

<br>

## 8.1. KeyCorrectnessProof

### Description

`Proof of correctness of the issuer's public key`

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
| c | BigIntString | Challenge hash | M |  |
| xzCap | BigIntString | Response for `z` | M |  |
| xrCap | BigIntStringDictionary | Responses for each `r`, keyed by attribute name | M |  |

<br>

## 9. ZKPCredentialDefinition

### Description

`Credential definition published by an issuer`

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
| id | String | Credential definition ID | M |  |
| schemaId | String | Credential schema ID | M |  |
| ver | String | Version | M |  |
| type | CredentialType | Signature type | M | [CredentialType](#2-credentialtype) |
| value | CredentialDefinitionValue | Public key material | M | [CredentialDefinitionValue](#91-credentialdefinitionvalue) |
| tag | String | Tag | M |  |

<br>

## 9.1. CredentialDefinitionValue

### Description

`Public key material of a credential definition`

### Declaration

```swift
public struct CredentialDefinitionValue : Jsonable {
    public let primary : CredentialPrimaryPublicKey
}
```

### Property

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
| primary | CredentialPrimaryPublicKey | Primary public key | M | [CredentialPrimaryPublicKey](#911-credentialprimarypublickey) |

<br>

## 9.1.1. CredentialPrimaryPublicKey

### Description

`The issuer's primary (CL) public key`

`r` keeps the order its keys have in the JSON when decoded through `Jsonable`'s `init(from:)`, and is encoded in that order. A plain `JSONDecoder` does not guarantee the order.

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
| n | BigIntString | RSA modulus | M |  |
| z | BigIntString | Public key component `Z` | M |  |
| s | BigIntString | Public key component `S` | M |  |
| r | OrderedStringMap&lt;BigIntString&gt; | Public key component `R` per attribute, keyed by attribute name | M | [OrderedStringMap](DataModel.md#19-orderedstringmap). The order is part of the value |
| rctxt | BigIntString | Public key component for the context attribute | M |  |

<br>

## 10. ZKPCredentialSchema

### Description

`Credential schema published by an issuer`

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
| id | String | Credential schema ID | M |  |
| name | String | Schema name | M |  |
| version | String | Version | M |  |
| attrNames | [String] | Attribute names | M |  |
| attrTypes | [AttributeType] | Attribute definitions, grouped by namespace | M |  |
| tag | String | Tag | M |  |
| AttributeType.namespace | Namespace | Namespace of the attributes (`id`, `name`, optional `ref` URL) | M |  |
| AttributeType.items | [AttributeDef] | Attribute definitions (`label`, `caption`, `type`, optional `i18n`) | M |  |
| AttributeDef.type | AttributeValueType | Value type: `String` or `Number` | M |  |

<br>

# Enumerators

## 1. PredicateType

### Description

`Comparison operator of a predicate`

### Declaration

```swift
@frozen public enum PredicateType : String, Codable {
    case GE
    case LE
    case GT
    case LT
}
```

| Case | Meaning |
|------|---------|
| GE | `>=` |
| LE | `<=` |
| GT | `>` |
| LT | `<` |

<br>

## 2. CredentialType

### Description

`Signature type of a credential definition`

### Declaration

```swift
public enum CredentialType : String, Codable, Sendable {
    case cl = "CL"
}
```

| Case | Raw value | Meaning |
|------|-----------|---------|
| cl | "CL" | Camenisch-Lysyanskaya signature |

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