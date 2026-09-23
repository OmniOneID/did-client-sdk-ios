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

iOS DataModel
==

- Subject: DataModel
- Writer: 박주현
- Date: 2026-09-22
- Version: v2.0.0

| Version          | Date       | History                 |
| ---------------- | ---------- | ------------------------|
| v2.0.0           | 2026-09-22 | OID4VC·mdoc·근접 제출 모델 추가 |
| v1.0.1           | 2025-05-27 | ZKP 관련 모델 추가         |
| v1.0.0           | 2024-08-28 | 초기 작성                 |


<div style="page-break-after: always;"></div>


# Contents
- [WalletCore](#walletcore)
    - [1. DIDDocument](#1-diddocument)
        - [1.1. VerificationMethod](#11-verificationmethod)
        - [1.2. Service](#12-service)
    - [2. VerifiableCredential](#2-verifiablecredential)
        - [2.1. Issuer](#21-issuer)
        - [2.2. DocumentVerificationEvidence](#22-documentverificationevidence)
        - [2.3. CredentialSchema](#23-credentialschema)
        - [2.4. CredentialSubject](#24-credentialsubject)
        - [2.5. Claim](#25-claim)
        - [2.6. Internationalization](#26-internationalization)
    - [3. VerifiablePresentation](#3-verifiablepresentation)
    - [4. Proof](#4-proof)
        - [4.1. VCProof](#41-vcproof)
    - [5. Profile](#5-profile)
        - [5.1. IssuerProfile](#51-issuerprofile)
            - [5.1.1. Profle](#511-profile)
                - [5.1.1.1. CredentialSchema](#5111-credentialschema)
                - [5.1.1.2. Process](#5112-process)
        - [5.2 VerifyProfile](#52-verifyprofile)
            - [5.2.1. Profile](#521-profile)
                - [5.2.1.1. ProfileFilter](#5211-profilefilter)
                    - [5.2.1.1.1. CredentialSchema](#52111-credentialschema)
                - [5.2.1.2. Process](#5212-process)
        - [5.3. LogoImage](#53-logoimage)
        - [5.4. ProviderDetail](#54-providerdetail)
        - [5.5. ReqE2e](#55-reqe2e)
        - [5.6. ProofRequestProfile](#56-proofrequestprofile)
            - [5.6.1. Profile](#561-profile)
    - [6. VCSchema](#6-vcschema)
        - [6.1. VCMetadata](#61-vcmetadata)
        - [6.2. CredentialSubject](#62-credentialsubject)
            - [6.2.1. Claim](#621-claim)
                - [6.2.1.1. Namespace](#6211-namespace)
                - [6.2.1.2. ClaimDef](#6212-claimdef)

- [WalletService](#walletservice)
    - [1. Protocol](#1-protocol)
        - [1.1. M132](#11-m132-reg-user)
            - [1.1.1. ProposeRegisterUser/ _ProposeRegisterUser](#111-proposeregisteruser-_proposeregisteruser)
            - [1.1.2. RequestEcdh/ _RequestEcdh](#112-requestecdh-_requestecdh)
            - [1.1.3. AttestedAppInfo](#113-attestedappinfo)
            - [1.1.4. WalletTokenData](#114-wallettokendata)
            - [1.1.5. RequestCreateToken/ _RequestCreateToken](#115-requestcreatetoken-_requestcreatetoken)
            - [1.1.6. RetieveKyc/ _RetieveKyc](#116-retievekyc-_retievekyc)
            - [1.1.7. RequestRegisterUser/ _RequestRegisterUser](#117-requestregisteruser-_requestregisteruser)
            - [1.1.8. ConfirmRegisterUser/ _ConfirmRegisterUser](#118-confirmregisteruser-_confirmregisteruser)
        - [1.2. M210](#12-m210-issue-vc)
            - [1.2.1. ProposeIssueVc/ _ProposeIssueVc](#121-proposeissuevc-_proposeissuevc)
            - [1.2.2. RequestIssueProfile/ _RequestIssueProfile](#122-requestissueprofile-_requestissueprofile)
            - [1.2.3. RequestIssueVc/ _RequestIssueVc](#123-requestissuevc-_requestissuevc)
            - [1.2.4. ConfirmIssueVc/ _ConfirmIssueVc](#124-confirmissuevc-_confirmissuevc)
        - [1.3. M310 (submit vp)](#13-m310-submit-vp)
            - [1.3.1. RequestProfile/ _RequestProfile](#131-requestprofile-_requestprofile)
            - [1.3.2. RequestVerify/ _RequestVerify](#132-requestverify-_requestverify)
        - [1.4. M220 (revoke vc)](#14-m220-revoke-vc)
            - [1.4.1. ProposeRevokeVc/ _ProposeRevokeVc](#141-proposerevokevc-_proposerevokevc)
            - [1.4.2. RequestRevokeVc/ _RequestRevokeVc](#142-requestrevokevc-_requestrevokevc)
            - [1.4.3. ConfirmRevokeVc/ _ConfirmRevokeVc](#143-confirmrevokevc-_confirmrevokevc)
        - [1.5. M142 (restore DID)](#15-m142-restore-did)
            - [1.5.1. ProposeRestoreDidDoc/ _ProposeRestoreDidDoc](#151-proposerestorediddoc-_proposerestorediddoc)
            - [1.5.2. RequestRestoreDIDDoc/ _RequestRestoreDIDDoc](#152-requestrestorediddoc-_requestrestorediddoc)
            - [1.5.3. ConfirmRestoreDidDoc/ _ConfirmRestoreDidDoc](#153-confirmrestorediddoc-_confirmrestorediddoc)
        - [1.6. M310 (submit zkproof)](#16-m310-submit-zkproof)
            - [1.6.1. RequestProfile/ _RequestProofRequestProfile](#161-requestprofile-_requestproofrequestprofile)
            - [1.6.2. RequestZKPVerify/ _RequestVerify](#162-requestzkpverify-_requestverify)
  
    - [2. Token](#2-token)
        - [2.1. ServerTokenSeed](#21-servertokenseed)
            - [2.1.1. AttestedAppInfo](#211-attestedappinfo)
                - [2.1.1.1. Provider](#2111-provider)
            - [2.1.2. SignedWalletInfo](#212-signedwalletinfo)
                - [2.1.2.1. Wallet](#2121-wallet)
        - [2.2. ServerTokenData](#22-servertokendata)
        - [2.3. WalletTokenSeed](#23-wallettokenseed)
        - [2.4. WalletTokenData](#24-wallettokendata)
  
    - [3. SecurityChannel](#3-securitychannel)
        - [3.1. ReqEcdh](#31-reqecdh)
        - [3.2. AccEcdh](#32-accecdh)
        - [3.3. AccE2e](#33-acce2e)
        - [3.4. E2e](#34-e2e)
        - [3.5. DIDAuth](#35-didauth)

    - [4. DidDoc](#4-diddoc)
        - [4.1. DIDDocVO](#41-diddocvo)
        - [4.2. AttestedDIDDoc](#42-attesteddiddoc)
        - [4.3. SignedDidDoc](#43-signeddiddoc)

    - [5. Offer](#5-offer)
        - [5.1. IssueOfferPayload](#51-issueofferpayload)
        - [5.2. VerifyOfferPayload](#52-verifyofferpayload)

    - [6. VC](#6-vc)
        - [6.1. ReqVC](#61-reqvc)
            - [6.1.1. ReqVcProfile](#611-reqvcprofile)
        - [6.2. VCPlanList](#62-vcplanlist)
            - [6.2.1. VCPlan](#621-vcplan)
                - [6.2.1.1. Option](#6211-option)
                - [6.2.1.2. VCPlan.CredentialDefinition](#6212-vcplancredentialdefinition)

- [OID4VC](#oid4vc)
    - [1. CredentialItem](#1-credentialitem)
        - [1.1. CredentialFormat](#11-credentialformat)
        - [1.2. VCDMCredentialItem](#12-vcdmcredentialitem)
        - [1.3. SdJwtCredentialItem](#13-sdjwtcredentialitem)
        - [1.4. MdocCredentialItem](#14-mdoccredentialitem)
    - [2. SDJWT](#2-sdjwt)
        - [2.1. Disclosure](#21-disclosure)
        - [2.2. SdJwtConsentItem](#22-sdjwtconsentitem)
    - [3. Mdoc](#3-mdoc)
        - [3.1. MdocConsentItem](#31-mdocconsentitem)
        - [3.2. MdocValidityInfo](#32-mdocvalidityinfo)
        - [3.3. MdocElementValue](#33-mdocelementvalue)
    - [4. StatusListReference](#4-statuslistreference)
    - [5. JWS](#5-jws)
        - [5.1. JWSHeader](#51-jwsheader)
    - [6. JWK](#6-jwk)
        - [6.1. JWK nested enumerations](#61-jwk-nested-enumerations)
    - [7. AuthorizationRequest](#7-authorizationrequest)
    - [8. DCQLQuery](#8-dcqlquery)
        - [8.1. CredentialQuery](#81-credentialquery)
        - [8.2. ClaimQuery](#82-claimquery)
        - [8.3. TrustedAuthority](#83-trustedauthority)
        - [8.4. CredentialSet](#84-credentialset)
        - [8.5. DCQLPathElement](#85-dcqlpathelement)
    - [9. MatchedCredential](#9-matchedcredential)
    - [10. MdocRequestedDocument](#10-mdocrequesteddocument)
    - [11. MdocDeviceResponse](#11-mdocdeviceresponse)
        - [11.1. MdocDeviceAuthMethod](#111-mdocdeviceauthmethod)
    - [12. IssuerMetadataResponse](#12-issuermetadataresponse)
        - [12.1. CredentialConfiguration](#121-credentialconfiguration)
        - [12.2. EncryptionSupport](#122-encryptionsupport)
        - [12.3. CredentialPolicy](#123-credentialpolicy)
        - [12.4. CredentialMetadata](#124-credentialmetadata)
        - [12.5. DisplayInfo](#125-displayinfo)
            - [12.5.1. LogoInfo](#1251-logoinfo)
        - [12.6. ProofSupport](#126-proofsupport)
        - [12.7. ClaimDetail](#127-claimdetail)
        - [12.8. SupportedFormat](#128-supportedformat)
        - [12.9. SigningAlg](#129-signingalg)
    - [13. CredentialOfferResponse](#13-credentialofferresponse)
        - [13.1. Grants](#131-grants)
        - [13.2. PreAuthorizedCode](#132-preauthorizedcode)
        - [13.3. TxCode](#133-txcode)
        - [13.4. AuthorizationCode](#134-authorizationcode)
    - [14. TokenRequest](#14-tokenrequest)
    - [15. TokenResponse](#15-tokenresponse)
    - [16. AuthorizationDetails](#16-authorizationdetails)
    - [17. OID4VCIIssuerList](#17-oid4vciissuerlist)
        - [17.1. OID4VCIIssuerItem](#171-oid4vciissueritem)
    - [18. AnyJSON](#18-anyjson)

- [OptionSet](#optionset)
    - [1. VerifyAuthType](#1-verifyauthtype)
- [Enumerators](#enumerators)
    - [1. DIDKeyType](#1-didkeytype)
    - [2. DIDServiceType](#2-didservicetype)
    - [3. ProofPurpose](#3-proofpurpose)
    - [4. ProofType](#4-prooftype)
    - [5. AuthType](#5-authtype)
    - [6. Evidence](#6-evidence)
    - [7. Presence](#7-presence)
    - [8. EvidenceType](#8-evidencetype)
    - [9. ProfileType](#9-profiletype)
    - [10. LogoImageType](#10-logoimagetype)
    - [11. ClaimType](#11-claimtype)
    - [12. ClaimFormat](#12-claimformat)
    - [13. Location](#13-location)
    - [14. SymmetricPaddingType](#14-symmetricpaddingtype)
    - [15. SymmetricCipherType](#15-symmetricciphertype)
    - [16. AlgorithmType](#16-algorithmtype)
    - [17. CredentialSchemaType](#17-credentialschematype)
    - [18. OfferTypeEnum](#18-offertypeenum)
    - [19. RoleTypeEnum](#19-roletypeenum)
    - [20. ServerTokenPurposeEnum](#20-servertokenpurposeenum)
    - [21. WalletTokenPurposeEnum](#21-wallettokenpurposeenum)
- [Protocols](#protocols)
    - [1. Jsonable](#1-jsonable)
    - [2. ProofProtocol](#2-proofprotocol)
        - [2.1. ProofContainer](#21-proofcontainer)
    - [2.2. ProofsContainer](#22-proofscontainer)
    - [3. ConvertibleToAlgorithmType](#3-convertibletoalgorithmtype)
    - [4. ConvertibleFromAlgorithmType](#4-convertiblefromalgorithmtype)
    - [5. AlgorithmTypeConvertible](#5-algorithmtypeconvertible)
- [Property Wrapper](#property-wrapper)
    - [1. @UTCDatetime](#1-utcdatetime)
    - [2. @DIDVersionId](#2-didversionid)

# WalletCore

## 1. DIDDocument

### Description

`분산 식별자에 대한 문서`

### Declaration

```swift
// Declaration in Swift
public struct DIDDocument : Jsonable, ProofsContainer
{
    public var context              : [String]
    public var id                   : String
    public var controller           : String
    public var verificationMethod   : [VerificationMethod]
    public var assertionMethod      : [String]?
    public var authentication       : [String]?
    public var keyAgreement         : [String]?
    public var capabilityInvocation : [String]?
    public var capabilityDelegation : [String]?
    public var service              : [Service]?
    @UTCDatetime  public var created   : String
    @UTCDatetime  public var updated   : String
    @DIDVersionId public var versionId : String
    public var deactivated          : Bool
    public var proof                : Proof?
    public var proofs               : [Proof]?
}
```

### Property

| Name                 | Type                 | Description                            | **M/O** | **Note**                    |
|----------------------|----------------------|----------------------------------------|---------|-----------------------------|
| context              | [String]             | JSON-LD context                        |    M    |   | 
| id                   | String               | DID 소유자의 did                        |    M    |   | 
| controller           | String               | DID controller의 did                   |    M    |   | 
| verificationMethod   | [VerificationMethod] | 공개키가 포함된 DID 키 목록  |    M    | [VerificationMethod](#11-verificationmethod) | 
| assertionMethod      | [String]             | Assertion 키 이름 목록             |    O    |   | 
| authentication       | [String]             | Authentication 키 이름 목록        |    O    |   | 
| keyAgreement         | [String]             | Key Agreement 키 이름 목록         |    O    |   | 
| capabilityInvocation | [String]             | Capability Invocation 키 이름 목록 |    O    |   | 
| capabilityDelegation | [String]             | Capability Delegation 키 이름 목록 |    O    |   | 
| service              | [Service]            | 서비스 목록                        |    O    |[Service](#12-service)  | 
| created              |  String              | 생성 시간                       |    M    |[@UTCDatetime](#1-utcdatetime)| 
| updated              |  String              | 갱신 시간                       |    M    | [@UTCDatetime](#1-utcdatetime)| 
| versionId            |  String              | DID 버전 id                         |    M    | [@DIDVersionId](#2-didversionid) | 
| deactivated          |  Bool                | true: 비활성화, false: 활성화    |    M    |   | 
| proof                |  Proof               | 소유자 proof                            |    O    |[Proof](#4-proof)| 
| proofs               |  [Proof]             | 소유자 proof 목록                    |    O    |[Proof](#4-proof)| 

<br>

## 1.1. VerificationMethod

### Description

`하위 모델/공개 키 값을 포함하는 DID 키 목록`

### Declaration

```swift
// Declaration in Swift
public struct VerificationMethod : Jsonable
{
    public var id                  : String
    public var type                : DIDKeyType
    public var controller          : String
    public var publicKeyMultibase  : String
    public var authType            : AuthType
}
```

### Property

| Name               | Type       | Description                            | **M/O** | **Note**              |
|--------------------|------------|----------------------------------------|---------|-----------------------|
| id                 | String     | 키 이름                               |    M    |                       | 
| type               | DIDKeyType | 키 타입                               |    M    | [DIDKeyType](#1-didkeytype) | 
| controller         | String     | 키 controller의 DID                   |    M    |                       | 
| publicKeyMultibase | String     | 공개키                       |    M    | Encoded by Multibase  | 
| authType           | AuthType   | 키 사용을 위한 인증 방법 |    M    | [AuthType](#5-authtype) | 

<br>

## 1.2. Service

### Description

`하위 모델 / 서비스 목록`

### Declaration

```swift
// Declaration in Swift
public struct Service : Jsonable
{
    public var id                  : String
    public var type                : DIDServiceType
    public var serviceEndpoint     : [String]
}
```

### Property

| Name            | Type           | Description                | **M/O** | **Note**                  |
|-----------------|----------------|----------------------------|---------|---------------------------|
| id              | String         | 서비스 id                 |    M    |                           | 
| type            | DIDServiceType | Service 유형               |    M    | [DIDServiceType](#2-didservicetype)| 
| serviceEndpoint | [String]       | 서비스 URL 목록 |    M    |                           | 

<br>

## 2. VerifiableCredential

### Description

`분산형 디지털 인증서, 이하 VC`

### Declaration

```swift
// Declaration in Swift
public struct VerifiableCredential : Jsonable, Identifiable
{
    public var context           : [String]
    public var id                : String
    public var type              : [String]
    public var issuer            : Issuer
    public var issuanceDate      : String
    @UTCDatetime public var validFrom         : String
    @UTCDatetime public var validUntil        : String
    public var encoding          : String
    public var formatVersion     : String
    public var language          : String
    public var evidence          : [Evidence]
    public var credentialSchema  : CredentialSchema
    public var credentialSubject : CredentialSubject
    public var proof             : VCProof
}
```

### Property

| Name              | Type              | Description                      | **M/O** | **Note**                    |
|-------------------|-------------------|----------------------------------|---------|-----------------------------|
| context           | [String]          | JSON-LD context                  |    M    |                             |
| id                | String            | VC id                            |    M    |                             |
| type              | [String]          | VC 종류 목록                  |    M    |                             |
| issuer            | Issuer            | 발급처 정보               |    M    | [Issuer](#21-issuer)         |
| issuanceDate      | String            | 발급 시간                |    M    |                             |
| validFrom         | String            | VC 유효 시작 시간  |    M    |                             |
| validUntil        | String            | VC 만료 시간 |    M    |                             |
| encoding          | String            | VC 인코딩 종류                 |    M    | Default(UTF-8)              |
| formatVersion     | String            | VC 포맷 버전                |    M    |                             |
| language          | String            | VC 언어 코드                 |    M    |                             |
| evidence          | [Evidence]        | 증거                         |    M    | [Evidence](#6-evidence) <br> [DocumentVerificationEvidence](#22-documentverificationevidence) |
| credentialSchema  | CredentialSchema  | Credential schema                |    M    | [CredentialSchema](#23-credentialschema)                            |
| credentialSubject | CredentialSubject | Credential subject               |    M    | [CredentialSubject](#24-credentialsubject)                            |
| proof             | VCProof           | 발급처 proof                     |    M    | [VCProof](#41-vcproof)                            |

<br>

## 2.1 Issuer

## Description

`발급처 정보`

## Declaration

```swift
// Declaration in Swift
public struct Issuer : Jsonable
{
    public var id        : String
    public var name      : String?
    public var certVCRef : String?
}
```

## Property

| Name      | Type   | Description                       | **M/O** | **Note**                 |
|-----------|--------|-----------------------------------|---------|--------------------------|
| id        | String | 발급자 DID                          |    M    |                          |
| name      | String | 발급자 이름                          |    O    |                          |

<br>

## 2.2 DocumentVerificationEvidence

## Description

`증거에 대한 문서 검증`

## Declaration

```swift
// Declaration in Swift
public struct DocumentVerificationEvidence : Jsonable
{
    public var id       : String?
    public var type     : EvidenceType
    public var verifier : String

    public var evidenceDocument : String
    public var subjectPresence  : Presence
    public var documentPresence : Presence
    public var attribute : [String: String]?
}
```

## Property

| Name             | Type            | Description                      | **M/O** | **Note**                       |
|------------------|-----------------|----------------------------------|---------|--------------------------------|
| id               | String          | 증거 정보의 URL                     |    O    |                                |
| type             | EvidenceType    | 증거 유형                          |    M    | [EvidenceType](#8-evidencetype)|
| verifier         | String          | 증거 검증처                         |    M    |                                |
| evidenceDocument | String          | 증거 문서 이름                      |    M    |                                |
| subjectPresence  | Presence        | 주체 표현 유형                      |    M    | [Presence](#7-presence)        |
| documentPresence | Presence        | 문서 표현 유형                      |    M    | [Presence](#7-presence)        |
| attribute        | [String:String] | Document attribute               |    O    |                                |

<br>

## 2.3 CredentialSchema

## Description

`자격 증명 스키마`

## Declaration

```swift
// Declaration in Swift
public struct CredentialSchema : Jsonable
{
    public var id   : String
    public var type : CredentialSchemaType
}
```

## Property

| Name      | Type                 | Description           | **M/O** | **Note**                 |
|-----------|----------------------|-----------------------|---------|--------------------------|
| id        | String               | URL for VC schema     |    M    |                          |
| type      | CredentialSchemaType | VC Schema format type |    M    |  [CredentialSchemaType](#17-credentialschematype)   |

<br>

## 2.4 CredentialSubject

## Description

`자격 증명 주제`

## Declaration

```swift
// Declaration in Swift
public struct CredentialSubject : Jsonable
{
    public var id     : String
    public var claims : [Claim]
}
```

## Property

| Name      | Type    | Description   | **M/O** | **Note**                 |
|-----------|---------|---------------|---------|--------------------------|
| id        | String  | DID 주체       |    M    |                          |
| claims    | [Claim] | claim 목록     |    M    | [Claim](#25-claim)       |

<br>

## 2.5 Claim

## Description

`주체에 대한 정보`

## Declaration

```swift
// Declaration in Swift
public struct Claim : Jsonable
{   
    public var code     : String
    public var caption  : String
    public var value    : String
    public var type     : ClaimType
    public var format   : ClaimFormat
    public var hideValue: Bool? //default(false)
    public var location : Location? //default(inline)
    public var digestSRI: String?
    public var i18n     : [String : Internationalization]?
}
```

## Property

| Name      | Type                         | Description                  | **M/O** | **Note**                 |
|-----------|------------------------------|------------------------------|---------|--------------------------|
| code      | String                       | Claim 코드                   |    M    |                          |
| caption   | String                       | Claim 이름                   |    M    |                          |
| value     | String                       | Claim 값                   |    M    |                          |
| type      | ClaimType                    | Claim 유형                   |    M    | [ClaimType](#11-claimtype)         |
| format    | ClaimFormat                  | Claim 포맷                 |    M    | [ClaimFormat](#12-claimformat)           |
| hideValue | Bool                         | 값 숨김                   |    O    | Default(false)           |
| location  | Location                     | 값 위치               |    O    | Default(inline) <br> [Location](#13-location) |
| digestSRI | String                       | Digest Subresource Integrity |    O    |                          |
| i18n      |[String:Internationalization] | 국제화         |    O    | [Internationalization](#26-internationalization) |

<br>

## 2.6 Internationalization

## Description

`국제화`

## Declaration

```swift
// Declaration in Swift
public struct Internationalization : Jsonable
{
    public var caption  : String
    public var value    : String?
    public var digestSRI: String?
}
```

## Property

| Name      | Type   | Description                  | **M/O** | **Note**                 |
|-----------|--------|------------------------------|---------|--------------------------|
| caption   | String | Claim 이름                    |    M    |                          |
| value     | String | Claim 값                      |    O    |                          |
| digestSRI | String | Digest Subresource Integrity |    O    | Claim 값의 해시값           |

<br>

## 3. VerifiablePresentation

### Description

`이하 VP라고 하는 주제 서명이 있는 VC 목록`

### Declaration

```swift
// Declaration in Swift
public struct VerifiablePresentation : Jsonable, ProofsContainer, Identifiable
{
    public var context              : [String]
    public var id                   : String
    public var type                 : [String]
    public var holder               : String
    @UTCDatetime public var validFrom  : String
    @UTCDatetime public var validUntil : String
    public var verifierNonce        : String
    public var verifiableCredential : [VerifiableCredential]
    public var proof                : Proof?
    public var proofs               : [Proof]?
}
```

### Property

| Name                 | Type                   | Description                      | **M/O** | **Note**                 |
|----------------------|------------------------|----------------------------------|---------|--------------------------|
| context              | [String]               | JSON-LD context                  |    M    |                          |
| id                   | String                 | VP ID                            |    M    |                          |
| type                 | [String]               | VP 유형 목록                  |    M    |                          |
| holder               | String                 | 소유자 DID                       |    M    |                          |
| validFrom            | String                 | VP의 요효 시작 시간  |    M    |                          |
| validUntil           | String                 | VP의 만료 시간 |    M    |                          |
| verifierNonce        | String                 | 검증자 nonce                   |    M    |                          |
| verifiableCredential | [VerifiableCredential] | VC 목록                       |    M    | [VerifiableCredential](#2-verifiablecredential)   |
| proof                | Proof                  | 소유자 proof                      |    O    | [Proof](#4-proof) | 
| proofs               | [Proof]                | 소유자 proof 목록              |    O    | [Proof](#4-proof)    | 

<br>

## 4. Proof

### Description

`소유자 증명`

### Declaration

```swift
// Declaration in Swift
public struct Proof : ProofProtocol
{
    @UTCDatetime public var created: String
    public var proofPurpose: ProofPurpose
    public var verificationMethod: String
    public var type: ProofType
    public var proofValue: String?
}
```

### Property

| Name               | Type         | Description                      | **M/O** | **Note**                 |
|--------------------|--------------|----------------------------------|---------|--------------------------|
| created            | String       | 생성시간                 |    M    | [@UTCDatetime](#1-utcdatetime)   | 
| proofPurpose       | ProofPurpose | Proof 목적                    |    M    | [ProofPurpose](#3-proofpurpose) | 
| verificationMethod | String       | Proof 서명에 사용된 Key URL |    M    |                          | 
| type               | ProofType    | Proof 유형                       |    M    | [ProofType](#4-prooftype)   |
| proofValue         | String       | 서명값                  |    O    |                          |

<br>

## 4.1 VCProof

### Description

`발급자 증명`

### Declaration

```swift
// Declaration in Swift
public struct Service : Jsonable
{
public struct VCProof : ProofProtocol, Jsonable
{
    @UTCDatetime public var created: String
    public var proofPurpose: ProofPurpose
    public var verificationMethod: String
    public var type: ProofType
    public var proofValue: String?
    public var proofValueList: [String]?
}
```

### Property

| Name               | Type         | Description                      | **M/O** | **Note**                 |
|--------------------|--------------|----------------------------------|---------|--------------------------|
| created            | String       | 생성 시간                 |    M    | [@UTCDatetime](#1-utcdatetime)             | 
| proofPurpose       | ProofPurpose | Proof 목적                    |    M    | [ProofPurpose](#3-proofpurpose)  | 
| verificationMethod | String       | Proof 서명에 사용된 Key URL |    M    |                          | 
| type               | ProofType    | Proof 유형                       |    M    | [ProofType](#4-prooftype)   |
| proofValue         | String       | 서명값                  |    O    |                          |
| proofValueList     | [String]     | 서명값 목록             |    O    |                          |

<br>

## 5. Profile

## 5.1 IssuerProfile

### Description

`발급자 프로파일`

### Declaration

```swift
// Declaration in Swift
public struct IssueProfile : Jsonable, ProofContainer
{
    public var id : String
    public var type : ProfileType
    public var title : String
    public var description : String?
    public var logo : LogoImage?
    public var encoding : String
    public var language : String
    public var profile : Profile
    public var proof : Proof?
}
```

### Property

| Name        | Type        | Description           | **M/O** | **Note**                 |
|-------------|-------------|-----------------------|---------|--------------------------|
| id          | String      | 프로파일 ID            |    M    |                          |
| type        | ProfileType | 프로파일 유형          |    M    | [ProfileType](#9-profiletype)    |
| title       | String      | 프로파일 제목         |    M    |                          |
| description | String      | 프로파일 설명   |    O    |                          |
| logo        | LogoImage   | 로고 이미지            |    O    | [LogoImage](#53-logoimage)         |
| encoding    | String      | 프로파일 인코딩 종류 |    M    |                          |
| language    | String      | 프로파일 언어 코드 |    M    |                          |
| profile     | Profile     | 프로파일 컨텐츠      |    M    | [Profle](#511-profile)           |
| proof       | Proof       | 소유자 Proof           |    O    | [Proof](#4-proof)      |

<br>

## 5.1.1 Profile

### Description

`프로파일 내용`

### Declaration

```swift
// Declaration in Swift
public struct Profile : Jsonable
{
    public var issuer : ProviderDetail
    public var credentialSchema : CredentialSchema
    public var process : Process
    public var credentialOffer  : ZKPCredentialOffer?
}
```

### Property

| Name             | Type               | Description                | **M/O** | **Note**                                     |
|------------------|--------------------|----------------------------|---------|----------------------------------------------|
| issuer           | ProviderDetail     | 발급처 정보                 |    M    | [ProviderDetail](#54-providerdetail)         |
| credentialSchema | CredentialSchema   | VC schema 정보             |    M    | [CredentialSchema](#5111-credentialschema)   |
| process          | Process            | 발급 절차                   |    M    | [Process](#5112-process)                     |
| credentialOffer  | ZKPCredentialOffer | ZKP Credential offer 정보  |    O    | ZKP_DataModel_ko.md 참고                      |

<br>

## 5.1.1.1 CredentialSchema

### Description

`VC 스키마 정보`

### Declaration

```swift
// Declaration in Swift
public struct CredentialSchema : Jsonable
{
    public var id : String
    public var type : CredentialSchemaType
    public var value : String?
}
```

### Property

| Name  | Type                 | Description           | **M/O** | **Note**                 |
|-------|----------------------|-----------------------|---------|--------------------------|
| id    | String               | VC schema URL     |    M    |                          |
| type  | CredentialSchemaType | VC schema 포맷 유형 |    M    | [CredentialSchemaType](#17-credentialschematype)      |
| value | String               | VC schema             |    O    | Encoded by Multibase     |

<br>

## 5.1.1.2 Process

### Description

`발급 프로세스`

### Declaration

```swift
// Declaration in Swift
public struct Process : Jsonable
{
    public var endpoints : [String]
    public var reqE2e :  ReqE2e
    public var issuerNonce : String
}
```

### Property

| Name        | Type     | Description         | **M/O** | **Note**                 |
|-------------|----------|---------------------|---------|--------------------------|
| endpoints   | [String] | Endpoint 목록    |    M    |                          |
| reqE2e      | ReqE2e   | 요청 정보  |    M    | Proof not included <br> [ReqE2e](#55-reqe2e)     |
| issuerNonce | String   | 발급처 nonce        |    M    |                          |

<br>

## 5.2 VerifyProfile

### Description

`제출 프로파일 확인`

### Declaration

```swift
// Declaration in Swift
public struct VerifyProfile : Jsonable, ProofContainer
{
    public var id : String
    public var type : ProfileType
    public var title : String
    public var description : String?
    public var logo : LogoImage?
    public var encoding : String
    public var language : String
    public var profile : Profile
    public var proof : Proof?
}
```

### Property

| Name        | Type        | Description           | **M/O** | **Note**                 |
|-------------|-------------|-----------------------|---------|--------------------------|
| id          | String      | 프로파일 ID             |    M    |                          |
| type        | ProfileType | 프로파일 유형            |    M    | [ProfileType](#9-profiletype)         |
| title       | String      | 프로파일 제목            |    M    |                          |
| description | String      | 프로파일 설명            |    O    |                          |
| logo        | LogoImage   | 로고 이미지              |    O    |  [LogoImage](#53-logoimage)        |
| encoding    | String      | 프로파일 인코딩 유형       |    M    |                          |
| language    | String      | 프로파일 언어 코드        |    M    |                          |
| profile     | Profile     | 프로파일 컨텐츠          |    M    | [Profile](#521-profile)      |
| proof       | Proof       | 소유자 proof           |    O    | [Proof](#4-proof)       |

<br>

## 5.2.1 Profile

### Description

`프로파일 내용`

### Declaration

```swift
// Declaration in Swift
public struct Profile : Jsonable
{    
    public var verifier : ProviderDetail
    public var filter : ProfileFilter
    public var process : Process
}
```

### Property

| Name     | Type           | Description                | **M/O** | **Note**                 |
|----------|----------------|----------------------------|---------|--------------------------|
| verifier | ProviderDetail | 검증자 정보       |    M    |  [ProviderDetail](#54-providerdetail)       |
| filter   | ProfileFilter  | 제출을 위한 필터링 정보 |    M    | [ProfileFilter](#5211-profilefilter)          |
| process  | Process        | VP 제출 방법 |    M    |[Process](#5212-process)       |

<br>

## 5.2.1.1 ProfileFilter

### Description

`VP 제출을 위한 필터링`

### Declaration

```swift
// Declaration in Swift
public struct ProfileFilter : Jsonable
{
    public var credentialSchemas : [CredentialSchema]
}
```

### Property

| Name              | Type               | Description                                | **M/O** | **Note**                 |
|-------------------|--------------------|--------------------------------------------|---------|--------------------------|
| credentialSchemas | [CredentialSchema] | 제출가능한 VC Schema 별 Claim과 발급처           |    M    | [CredentialSchema](#52111-credentialschema)      |

<br>

## 5.2.1.1.1 CredentialSchema

### Description

`VC 스키마별 제시 가능한 클레임 및 발급자`

### Declaration

```swift
// Declaration in Swift
public struct CredentialSchema : Jsonable
{
    public var id : String
    public var type : CredentialSchemaType
    public var value : String?
    public var presentAll : Bool?
    public var displayClaims : [String]?
    public var requiredClaims : [String]?
    public var allowedIssuers : [String]?
}
```

### Property

| Name           | Type                 | Description                                   | **M/O** | **Note**                                                              |
|----------------|----------------------|-----------------------------------------------|---------|------------------------------------------------------------------------|
| id             | String               | URL for VC schema                             |    M    |                                                                        |
| type           | CredentialSchemaType | VC schema format type                         |    M    | [CredentialSchemaType](#17-credentialschematype)                      |
| value          | String               | VC schema                                     |    O    | Multibase로 인코딩됨                                                  |
| presentAll     | Bool                 | Require to present all claims. Default(false) |    O    | 이 값이 true인 경우, display 및 required 클레임은 무시됩니다          |
| displayClaims  | [String]             | 사용자 화면에 노출될 claims 목록              |    O    | 디바이스 화면에 표시될 값                                             |
| requiredClaims | [String]             | 발급시 필수 claims                            |    O    | VP를 제출하기 위해 필요한 값들                                        |
| allowedIssuers | [String]             | 허용된 발급처의 DID 목록                      |    O    |                                                                        |


<br>

## 5.2.1.2 Process

### Description

`VP 제출 방법`

### Declaration

```swift
// Declaration in Swift
public struct Process : Jsonable
{
    public var endpoints : [String]?
    public var reqE2e :  ReqE2e
    public var verifierNonce : String
    public var authType : VerifyAuthType?
}
```

### Property

| Name          | Type           | Description                    | **M/O** | **Note**                 |
|---------------|----------------|--------------------------------|---------|--------------------------|
| endpoints     | [String]       | Endpoint 목록                   |    O    |                          |
| reqE2e        | ReqE2e         | 요청 정보                        |    M    | Proof not included <br> [ReqE2e](#55-reqe2e)     |
| verifierNonce | String         | 검증처 nonce                     |    M    |                          |
| authType      | VerifyAuthType | 제출용 인증수단                    |    O    | [VerifyAuthType](#1-verifyauthtype)   |

<br>

## 5.3. LogoImage

### Description

`로고 이미지`

### Declaration

```swift
// Declaration in Swift
public struct LogoImage : Jsonable
{
    public var format : LogoImageType
    public var link   : String?
    public var value  : String?
}
```

### Property

| Name   | Type          | Description         | **M/O** | **Note**                 |
|--------|---------------|---------------------|---------|--------------------------|
| format | LogoImageType | 이미지 포맷            |    M    | [LogoImageType](#10-logoimagetype)     |
| link   | String        | 로고 이미지 URL        |    O    | Encoded by Multibase     |
| value  | String        | 이미지 값              |    O    | Encoded by Multibase     |

<br>

## 5.4. ProviderDetail

### Description

`제공자 세부 정보`

### Declaration

```swift
// Declaration in Swift
public struct ProviderDetail : Jsonable
{
    public var did : String
    public var certVcRef : String
    
    public var name : String
    public var description : String?
    public var logo : LogoImage?
    public var ref : String?
}
```

### Property

| Name        | Type      | Description                       | **M/O** | **Note**                 |
|-------------|-----------|-----------------------------------|---------|--------------------------|
| did         | String    | 제공자 DID                          |    M    |                          |
| certVcRef   | String    | 가입증명서 URL                       |    M    |                          |
| name        | String    | 제공자 이름                          |    M    |                          |
| description | String    | 제공자 설명                          |    O    |                          |
| logo        | LogoImage | 로고 이미지                          |    O    | [LogoImage](#53-logoimage)          |
| ref         | String    | 참조 URL                            |    O    |                          |

<br>

## 5.5. ReqE2e

### Description

`종단 간 요청 데이터`

### Declaration

```swift
// Declaration in Swift
public struct ReqE2e : Jsonable, ProofContainer
{
    public var nonce : String
    public var curve : ECType
    public var publicKey : String
    public var cipher : SymmetricCipherType
    public var padding : SymmetricPaddingType
    public var proof : Proof?
}
```

### Property

| Name      | Type                 | Description                        | **M/O** | **Note**                                         |
| --------- | -------------------- | ---------------------------------- | ------- | ------------------------------------------------ |
| nonce     | String               | 대칭키 생성용 nonce                   |     M    | 멀티베이스 인코딩                                |
| curve     | ECType               | 타원곡선 유형                         |     M    |                                               |
| publicKey | String               | 암호화용 서버공개키                     |    M    | 멀티베이스 인코딩                             |
| cipher    | SymmetricCipherType  | 암호화 유형                           |    M    | [SymmetricCipherType](#15-symmetricciphertype)   |
| padding   | SymmetricPaddingType | 패딩 유형                            |    M    | [SymmetricPaddingType](#14-symmetricpaddingtype) |
| proof     | Proof                | Key aggreement proof               |    O    | [Proof](#4-proof)                                |

<br>

## 5.6 ProofRequestProfile

### Description

`ProofRequest 프로파일`

### Declaration

```swift
// Declaration in Swift
public struct ProofRequestProfile : Jsonable, ProofContainer
{
    public var id : String
    public var type : ProfileType
    public var title : String
    public var description : String?
    public var logo : LogoImage?
    public var encoding : String
    public var language : String
    public var profile : Profile
    public var proof : Proof?
}
```

### Property

| Name        | Type        | Description           | **M/O** | **Note**                 |
|-------------|-------------|-----------------------|---------|--------------------------|
| id          | String      | 프로파일 ID             |    M    |                          |
| type        | ProfileType | 프로파일 유형            |    M    | [ProfileType](#9-profiletype)         |
| title       | String      | 프로파일 제목            |    M    |                          |
| description | String      | 프로파일 설명            |    O    |                          |
| logo        | LogoImage   | 로고 이미지              |    O    |  [LogoImage](#53-logoimage)        |
| encoding    | String      | 프로파일 인코딩 유형       |    M    |                          |
| language    | String      | 프로파일 언어 코드        |    M    |                          |
| profile     | Profile     | 프로파일 컨텐츠          |    M    | [Profile](#561-profile)      |
| proof       | Proof       | 소유자 proof           |    O    | [Proof](#4-proof)       |

<br>

## 5.6.1 Profile

### Description

`프로파일 내용`

### Declaration

```swift
// Declaration in Swift
public struct Profile : Jsonable
{    
    public var verifier : ProviderDetail
    public var proofRequest : ProofRequest
    public var reqE2e :  ReqE2e
}
```

### Property

| Name         | Type           | Description         | **M/O** | **Note**                                               |
|--------------|----------------|---------------------|---------|--------------------------------------------------------|
| verifier     | ProviderDetail | 검증자 정보          |    M    | [ProviderDetail](#54-providerdetail)                  |
| proofRequest | ProofRequest   | ProofRequest 정보    |    M    | ZKP_DataModel_ko.md 참고                              |
| reqE2e       | ReqE2e         | 요청 정보            |    M    | Proof not included <br> [ReqE2e](#55-reqe2e)           |

## 6. VCSchema

### Description

`VC 스키마`

### Declaration

```swift
// Declaration in Swift
public struct VCSchema : Jsonable
{   
    public var id                : String
    public var schema            : String
    public var title             : String
    public var description       : String
    public var metadata          : VCMetadata
    public var credentialSubject : CredentialSubject
}
```

### Property

| Name              | Type              | Description              | **M/O** | **Note**                 |
|-------------------|-------------------|--------------------------|---------|--------------------------|
| id                | String            | VC schema URL            |    M    |                          |
| schema            | String            | VC schema 포맷 URL        |    M    |                          |
| title             | String            | VC schema 이름            |    M    |                          |
| description       | String            | VC schema 설명            |    M    |                          |
| metadata          | VCMetadata        | VC metadata              |    M    |  [VCMetadata](#61-vcmetadata)   |
| credentialSubject | CredentialSubject | Credential subject       |    M    |  [CredentialSubject](#62-credentialsubject)   |

<br>

## 6.1. VCMetadata

### Description

`VC 메타데이터`

### Declaration

```swift
// Declaration in Swift
public struct VCMetadata : Jsonable
{
    public var language      : String
    public var formatVersion : String
}
```

### Property

| Name          | Type   | Description         | **M/O** | **Note**                 |
|---------------|--------|---------------------|---------|--------------------------|
| language      | String | VC 기본 언어          |    M    |                          |
| formatVersion | String | VC 포맷 버전          |    M    |                          |

<br>

## 6.2. CredentialSubject

### Description

`자격 증명 주제`

### Declaration

```swift
// Declaration in Swift
public struct CredentialSubject : Jsonable
{
    public var claims : [Claim]
}
```

### Property

| Name   | Type    | Description          | **M/O** | **Note**                 |
|--------|---------|----------------------|---------|--------------------------|
| claims | [Claim] | Namespace 별 Claim    |    M    | [Claim](#621-claim)                         |

<br>

## 6.2.1. Claim

### Description

`Claim`

### Declaration

```swift
// Declaration in Swift
public struct Claim : Jsonable
{
   public var namespace : Namespace
   public var items     : [ClaimDef]
}

```

### Property

| Name      | Type       | Description              | **M/O** | **Note**                 |
|-----------|------------|--------------------------|---------|--------------------------|
| namespace | Namespace  | Claim namespace          |    M    |  [Namespace](#6211-namespace)      |
| items     | [ClaimDef] | Claim 정의 목록            |    M    | [ClaimDef](#6212-claimdef)  |

<br>

## 6.2.1.1. Namespace

### Description

`네임스페이스 클레임`

### Declaration

```swift
// Declaration in Swift
public struct Namespace : Jsonable
{
    public var id   : String
    public var name : String
    public var ref  : String?
    
}
```

### Property

| Name | Type   | Description                   | **M/O** | **Note**                 |
|------|--------|-------------------------------|---------|--------------------------|
| id   | String | Claim namespace               |    M    |                          |
| name | String | Namespace 이름                 |    M    |                          |
| ref  | String | Namespace 정보 URL             |    O    |                          |

<br>

## 6.2.1.2. ClaimDef

### Description

`클래임 정의`

### Declaration

```swift
// Declaration in Swift

public struct ClaimDef : Jsonable
{
    public var id          : String
    public var caption     : String
    public var type        : ClaimType
    public var format      : ClaimFormat
    public var hideValue   : Bool? // default(false)
    public var location    : Location? // default(inline)
    public var required    : Bool? // default(true)
    public var description : String? //default("")
    public var i18n        : [String : String]?
}
```

### Property

| Name        | Type            | Description          | **M/O** | **Note**                 |
|-------------|-----------------|----------------------|---------|--------------------------|
| id          | String          | Claim identifier     |    M    |                          |
| caption     | String          | Claim 이름            |    M    |                          |
| type        | ClaimType       | Claim 유형            |    M    | [ClaimType](#11-claimtype)         |
| format      | ClaimFormat     | Claim 포맷            |    M    |  [ClaimFormat](#12-claimformat)       |
| hideValue   | Bool            | 값 숨김                |    O    | Default(false)           |
| location    | Location        | 값 위치                |    O    | Default(inline) <br> [Location](#13-location)        |
| required    | Bool            | 필수 여부              |    O    | Default(true)            |
| description | String          | Claim 설명            |    O    | Default("")              |
| i18n        | [String:String] | 국제화                 |    O    |                          |

<br>

# WalletService
## 1. Protocol

### 1.1. M132 (reg user)

#### 1.1.1 ProposeRegisterUser/ _ProposeRegisterUser

#### Description
`유저등록 제안`

#### Declaration

```swift
// Declaration in Swift
public struct ProposeRegisterUser: Jsonable {
    public var id: String
    public init(id: String) {
        self.id = id
    }
}

public struct _ProposeRegisterUser: Jsonable {
    public var txId: String
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property

| Name    | Type   | Description                    | **M/O** | **Note** |
|---------|--------|--------------------------------|---------|----------|
| id      | String | 메시지 ID                        |    M    |          |
| txId    | String | 거래 ID                          |    O    |          |

<br>

#### 1.1.2. RequestEcdh/ _RequestEcdh

#### Description
`세션 암호화`

#### Declaration
```swift
// Declaration in Swift
public struct RequestEcdh: Jsonable {
    public var id: String
    public var txId: String
    public var reqEcdh: ReqEcdh
    public init(id: String, txId: String, reqEcdh: ReqEcdh) {
        self.id = id
        self.txId = txId
        self.reqEcdh = reqEcdh
    }
}

public struct _RequestEcdh: Jsonable {
    public var txId: String
    public var accEcdh: AccEcdh
    public init(id: String, txId: String, accEcdh: AccEcdh) {
        self.txId = txId
        self.accEcdh = accEcdh
    }
}
```
#### Property
| Name    | Type    | Description                    | **M/O** | **Note** |
|---------|---------|--------------------------------|---------|----------|
| id      | String  | 메시지 ID                        |    M    |          |
| txId    | String  | 거래 ID                         |    M    |          |
| reqEcdh | ReqEcdh |                                |    M    |          |
| accEcdh | AccEcdh |                                |    M    |          |
<br>

#### 1.1.3. AttestedAppInfo

#### Description
`인증된 앱 정보`

#### Declaration
```swift
// Declaration in Swift
public struct RequestAttestedAppInfo: Jsonable {
    public var appId: String
    public init(appId: String) {
        self.appId = appId
    }
}
```
### Property
| Name    | Type    | Description                    | **M/O** | **Note** |
|---------|---------|--------------------------------|---------|----------|
| appId   | String  | 어플리케이션 id                   |    M    |          |

<br>

#### 1.1.4. WalletTokenData

#### Description

`월렛 토큰 데이터`

#### Declaration

```swift
// Declaration in Swift
public struct WalletTokenData: Jsonable, ProofContainer {
    public var seed: WalletTokenSeed
    public var sha256_pii: String
    public var provider: Provider
    public var nonce: String   // multibase
    public var proof: OpenDID_DataModel.Proof?
    public init(seed: WalletTokenSeed, sha256_pii: String, provider: Provider, nonce: String, proof: OpenDID_DataModel.Proof?) {
        self.seed = seed
        self.sha256_pii = sha256_pii
        self.provider = provider
        self.nonce = nonce
        self.proof = proof
    }
}
```
#### Property
| Name       | Type             | Description                    | **M/O** | **Note** |
|------------|------------------|--------------------------------|---------|----------|
| seed       | WalletTokenSeed  | 월렛 토큰 시드                    |    M    |          |
| sha256_pii | String           | PII의 SHA-256 해시              |    M    |          |
| provider   | Provider         | 제공자 정보                       |    M    |          |
| nonce      | String           | nonce                          |    M    |          |
| proof      | Proof            | proof                          |    M    |          |

<br>

#### 1.1.5. RequestCreateToken/ _RequestCreateToken

#### Description

`토큰 생성 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestCreateToken: Jsonable {
    public var id: String
    public var txId: String
    public var seed: ServerTokenSeed
    public init(id: String, txId: String, seed: ServerTokenSeed) {
        self.id = id
        self.txId = txId
        self.seed = seed
    }
}

public struct _RequestCreateToken: Jsonable {
    public var txId: String
    public var iv: String
    public var encStd: String
    public init(txId: String, iv: String, encStd: String) {
        self.txId = txId
        self.iv = iv
        self.encStd = encStd
    }
}
```
#### Property
| Name    | Type             | Description                    | **M/O** | **Note** |
|---------|------------------|--------------------------------|---------|----------|
| id      | String           | 메시지 ID                        |    M    |          |
| txId    | String           | 거래 ID                         |    M    |          |
| seed    | ServerTokenSeed  | 서버토큰시드                      |    M    |          |
| encStd  | String           | 암호화된 서버 토큰 데이터            |    M    |          |

<br>


#### 1.1.6. RetieveKyc/ _RetieveKyc

#### Description

`KYC(Know Your Customer) VO`

#### Declaration

```swift
// Declaration in Swift
public struct RetrieveKyc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public var kycTxId: String
    public init(id: String, txId: String, serverToken: String, kycTxId: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
        self.kycTxId = kycTxId
    }
}

public struct _RetrieveKyc: Jsonable {
    public var txId: String    
    public init(txId: String) {
        self.txId = txId
    }
}

```
#### Property
| Name        | Type             | Description                    | **M/O** | **Note** |
|-------------|------------------|--------------------------------|---------|----------|
| id          | String           | 메시지 ID                     |    M    |          |
| txId        | String           | 거래 ID                 |    M    |          |
| serverToken | ServerTokenSeed  | 서버토큰                   |    M    |          |
| kycTxId     | String           | kyc 거래 ID             |    M    |          |
<br>


#### 1.1.7. RequestRegisterUser/ _RequestRegisterUser

#### Description

`사용자 등록 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestRegisterUser: Jsonable {
    public var id: String
    public var txId: String
    public var signedDidDoc: SignedDidDoc
    public var serverToken: String
    public init(id: String, txId: String, signedDidDoc: SignedDidDoc, serverToken: String) {
        self.id = id
        self.txId = txId
        self.signedDidDoc = signedDidDoc
        self.serverToken = serverToken
    }
}

public struct _RequestRegisterUser: Jsonable {
    public var txId: String
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| signedDidDoc | SignedDidDoc     | 서명된 DID doc                   |    M    |          |
| serverToken  | String           | 서버토큰                          |    M    |          |
<br>


#### 1.1.8. ConfirmRegisterUser/ _ConfirmRegisterUser

#### Description

`사용자 등록 확인`

#### Declaration

```swift
// Declaration in Swift
public struct ConfirmRegisterUser: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public init(id: String, txId: String, serverToken: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
    }
}

public struct _ConfirmRegisterUser: Jsonable {
    public var txId: String
    public init(txId: String) {
        self.txId = txId
    }
}
```

#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| serverToken  | String           | 서버토큰                         |    M    |          |
<br>


### 1.2. M210 (issue vc)
#### 1.2.1. ProposeIssueVc/ _ProposeIssueVc

#### Description

`VC 발급 제안`

#### Declaration

```swift
// Declaration in Swift
public struct ProposeIssueVc: Jsonable {
    public var id: String
    public var vcPlanId: String
    public var issuer: String
    public var offerId: String?
    public init(id: String, vcPlanId: String, issuer: String, offerId: String? = nil) {
        self.id = id
        self.vcPlanId = vcPlanId
        self.issuer = issuer
        self.offerId = offerId
    }
}

public struct _ProposeIssueVc: Jsonable {
    public var txId: String
    public var refId: String
    public init(txId: String, refId: String) {
        self.txId = txId
        self.refId = refId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| vcPlanId     | String           | vc plan ID                     |    M    |          |
| issuer       | String           | 발급자 DID                       |    M    |          |
| offerId      | String           | offer ID                       |    O    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| refId        | String           | 참조 ID                         |    M    |          |

<br>

#### 1.2.2. RequestIssueProfile/ _RequestIssueProfile

#### Description

`VC 발급 프로파일 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestIssueProfile: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public init(id: String, txId: String, serverToken: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
    }
}

public struct _RequestIssueProfile: Jsonable {
    public var txId: String
    public var authNonce: String
    public var profile: IssueProfile
    public init(txId: String, authNonce: String, profile: IssueProfile) {
        self.txId = txId
        self.authNonce = authNonce
        self.profile = profile
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| serverToken  | String           | 서버 토큰                        |    M    |          |
| authNonce    | String           | 인증 nonce                      |    M    |          |
| profile      | IssuerProfile    | 발급자 프로파일                    |    M    |          |
<br>

#### 1.2.3. RequestIssueVc/ _RequestIssueVc

#### Description

`VC 발급 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestIssueVc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public var didAuth: DIDAuth
    public var accE2e: AccE2e
    public var encReqVc: String
    public init(id: String, txId: String, serverToken: String, didAuth: DIDAuth, accE2e: AccE2e, encReqVc: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
        self.didAuth = didAuth
        self.accE2e = accE2e
        self.encReqVc = encReqVc
    }
}

public struct _RequestIssueVc: Jsonable {
    public var txId: String
    public var e2e: E2E
    public init(txId: String, e2e: E2E) {
        self.txId = txId
        self.e2e = e2e
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| serverToken  | String           | 서버토큰                         |    M    |          |
| didAuth      | DIDAuth          | DID auth 데이터                  |    M    |          |
| accE2e       | AccE2e           | E2e 암호화 데이터                  |    M    |          |
| encReqVc     | String           | 암호화 VC 요청 데이터               |    M    |          |
| e2e          | E2E              | e2e                            |    M    |          |
<br>

#### 1.2.4. ConfirmIssueVc/ _ConfirmIssueVc

#### Description

`VC 발급 확인`

#### Declaration

```swift
// Declaration in Swift
public struct ConfirmIssueVc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public var vcId: String
    public init(id: String, txId: String, serverToken: String, vcId: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
        self.vcId = vcId
    }
}

public struct _ConfirmIssueVc: Jsonable {
    public var txId: String
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| serverToken  | String           | 서버 토큰                        |    M    |          |
| vcId         | String           | vc ID                          |    M    |          |
<br>

#### 1.2.5. CredInfo

#### Description

`발급받은 VC 및 영지식 인증서`

#### Declaration

```swift
// Declaration in Swift
public struct CredInfo : Jsonable
{
    public let vc: VerifiableCredential
    public let credential : ZKPCredential?
}
```
#### Property
| Name       | Type                   | Description            | **M/O** | **Note**                     |
|------------|------------------------|------------------------|---------|------------------------------|
| vc         | VerifiableCredential   | 분산형 디지털 인증서        | M       |                              |
| credential | ZKPCredential          | 영지식 인증서             | O       | ZKP_DataModel_ko.md 참고      |

<br>


### 1.3. M310 (submit vp)
#### 1.3.1. RequestProfile/ _RequestProfile

#### Description

`VP 프로파일 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestProfile: Jsonable {
    public var id: String
    public var txId: String?
    public var offerId: String
    public init(id: String, txId: String? = nil, offerId: String) {
        self.id = id
        self.txId = txId
        self.offerId = offerId
    }
}

public struct _RequestProfile: Jsonable {
    public var txId: String
    public var profile: VerifyProfile
    public init(txId: String, profile: VerifyProfile) {
        self.txId = txId
        self.profile = profile
    }
}
```
#### Property
| Name     | Type          | Description           | **M/O** | **Note** |
|----------|---------------|-----------------------|---------|----------|
| id       | String        | 메시지 ID              | M       |          |
| txId     | String        | 거래 ID                | O       |          |
| offerId  | String        | offer ID              | M       |          |
| profile  | VerifyProfile | VP 제출용 프로파일        | M       |          |

<br>

#### 1.3.2. RequestVerify/ _RequestVerify
#### Description

`프로필 검증 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestVerify: Jsonable {
    public var id: String
    public var txId: String
    public var accE2e: AccE2e
    public var encVp: String
    
    public init(id: String, txId: String, accE2e: AccE2e, encVp: String) {
        self.id = id
        self.txId = txId
        self.accE2e = accE2e
        self.encVp = encVp
    }
}

public struct _RequestVerify: Jsonable {
    public var txId: String
    
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                          |    M    |          |
| accE2e       | AccE2e           | E2e 암호화 데이터                  |    M    |          |
| encVp        | String           | 암호화된 VP                       |    M    |          |

<br>


### 1.4. M220 (revoke vc)
#### 1.4.1. ProposeRevokeVc/ _ProposeRevokeVc

#### Description
`VC폐기 제안`

#### Declaration

```swift
// Declaration in Swift
public struct ProposeRevokeVc: Jsonable {
    public var id: String
    public var vcId: String
    
    public init(id: String, vcId: String) {
        self.id = id
        self.vcId = vcId
    }
}

public struct _ProposeRevokeVc: Jsonable {
    public var txId: String
    public var issuerNonce: String
    public var authType: VerifyAuthType
    
    public init(txId: String, issuerNonce: String, authType: VerifyAuthType) {
        self.txId = txId
        self.issuerNonce = issuerNonce
        self.authType = authType
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | message ID                     |    M    |          |
| vcId         | String           | vc ID                          |    M    |          |
| issuerNonce  | String           | 발급처 nonce                     |    M    |          |
| authType     | VerifyAuthType   | 제출용 인증수단                    |    M    |          |
<br>

#### 1.4.2. RequestRevokeVc/ _RequestRevokeVc

#### Description

`VC폐기 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestRevokeVc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public var request: ReqRevokeVc
    
    public init(id: String, txId: String, serverToken: String, request: ReqRevokeVc) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
        self.request = request
    }
}

public struct _RequestRevokeVc: Jsonable {
    public var txId: String
    
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| serverToken  | String           | 서버 토큰                         |    M    |          |
| request      | ReqRevokeVc      |                                |    M    |          |
<br>



#### 1.4.3. ConfirmRevokeVc/ _ConfirmRevokeVc

#### Description

`VC폐기 확인`

#### Declaration

```swift
// Declaration in Swift
public struct ConfirmRevokeVc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String

    public init(id: String, txId: String, serverToken: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
    }
}

public struct _ConfirmRevokeVc: Jsonable {
    public var txId: String
    
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지   ID                      |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| serverToken  | String           | 서버 토큰                        |    M    |          |
<br>

### 1.5. M142 (restore DID)
#### 1.5.1. ProposeRestoreDidDoc/ _ProposeRestoreDidDoc

#### Description

`DIDDoc 복구 제안`

#### Declaration

```swift
// Declaration in Swift
public struct ProposeRestoreDidDoc: Jsonable {
    public var id: String
    public var offerId: String
    public var did: String
    
    public init(id: String, offerId: String, did: String) {
        self.id = id
        self.offerId = offerId
        self.did = did
    }
}

public struct _ProposeRestoreDidDoc: Jsonable {
    public var txId: String
    public var authNonce: String
    
    public init(txId: String, authNonce: String) {
        self.txId = txId
        self.authNonce = authNonce
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지    ID                     |    M    |          |
| offerId      | String           | offer ID                       |    M    |          |
| did          | String           | did                            |    M    |          |

<br>

#### 1.5.2. RequestRestoreDIDDoc/ _RequestRestoreDIDDoc

#### Description

`DIDDoc 복구 요청`

#### Declaration

```swift
// Declaration in Swift
public struct RequestRestoreDidDoc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public var didAuth: DIDAuth
    
    public init(id: String, txId: String, serverToken: String, didAuth: DIDAuth) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
        self.didAuth = didAuth
    }
}

public struct _RequestRestoreDidDoc: Jsonable {
    public var txId: String
    
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                         |    M    |          |
| serverToken  | String           | 서버 토큰                        |    M    |          |
| didAuth      | DIDAuth          | DID auth 데이터                  |    M    |          |
<br>

#### 1.5.3. ConfirmRestoreDidDoc/ _ConfirmRestoreDidDoc

#### Description

`DIDDoc 복구 확인`

#### Declaration

```swift
// Declaration in Swift
public struct ConfirmRestoreDidDoc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    
    public init(id: String, txId: String, serverToken: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
    }
}

public struct _ConfirmRestoreDidDoc: Jsonable {
    public var txId: String
    public init(txId: String) {
        self.txId = txId
    }
}
```
#### Property
| Name         | Type             | Description                    | **M/O** | **Note** |
|--------------|------------------|--------------------------------|---------|----------|
| id           | String           | 메시지 ID                        |    M    |          |
| txId         | String           | 거래 ID                          |    M    |          |
| serverToken  | String           | 서버 토큰                         |    M    |          |
<br>


### 1.6. M310 (submit zkproof)
#### 1.6.1. RequestProfile/ _RequestProofRequestProfile

#### Description

`request ZKP verifiy profile`

#### Declaration

```swift
// Declaration in Swift
public struct RequestProfile: Jsonable {
    public var id: String
    public var txId: String?
    public var offerId: String
}

public struct _RequestProofRequestProfile: Jsonable {
    public var txId: String
    public var proofRequestProfile: ProofRequestProfile
}
```
#### Property
| Name                 | Type                | Description              | **M/O** | **Note** |
|----------------------|---------------------|--------------------------|---------|----------|
| id                   | String              | 메시지 ID                 | M       |          |
| txId                 | String              | 거래 ID                   | O       |          |
| offerId              | String              | offer ID                  | M       |          |
| proofRequestProfile  | ProofRequestProfile | ZKP 제출용 프로파일        | M       |          |

<br>

#### 1.6.2. RequestZKPVerify/ _RequestVerify
#### Description

`request verifiy ZKProof`

#### Declaration

```swift
// Declaration in Swift
public struct RequestZKPVerify: Jsonable
 {
    public var id: String
    public var txId: String
    public var accE2e: AccE2e
    public var encProof: String
    public var nonce : BigIntString
}

public struct _RequestVerify: Jsonable 
{
    public var txId: String
}
```
#### Property
| Name     | Type         | Description              | **M/O** | **Note** |
|----------|--------------|--------------------------|---------|----------|
| id       | String       | 메시지 ID                 | M       |          |
| txId     | String       | 거래 ID                   | M       |          |
| accE2e   | AccE2e       | E2e 암호화 데이터          | M       |          |
| encProof | String       | 암호화된 zkproof          | M       |          |
| nonce    | BigIntString | proof request의 nonce     | M       |          |




<br>

## 2. Token
## 2.1. ServerTokenSeed

### Description

`서버 토큰 시드`

### Declaration

```swift
public struct ServerTokenSeed: Jsonable {
    public var purpose: WalletTokenPurposeEnum
    public var walletInfo: SignedWalletInfo
    public var caAppInfo: AttestedAppInfo
}
```

### Property

| Name        | Type                       | Description                | **M/O** | **Note** |
|-------------|---------------------------------------------------------|-------------------------------|---------|----------|
| purpose     | WalletTokenPurposeEnum     | 월렛토큰목적                  |    M    | [WalletTokenPurposeEnum](#24-servertokenpurpose) |
| walletInfo  | SignedWalletInfo           | 서명된 월렛 정보               |    M    | [SignedWalletInfo](#27-signedwalletinfo) |
| caAppInfo   | AttestedAppInfo            | 인증된 앱 정보                |    M    | [AttestedAppInfo](#6-attestedappinfo) |

<br>

## 2.1.1. AttestedAppInfo

### Description

`검증된 앱 정보`


### Declaration

```swift
public struct AttestedAppInfo: Jsonable, ProofContainer {
    public var appId: String
    public var provider: Provider
    public var nonce: String
    public var proof: Proof?
}
```

### Property

| Name     | Type     | Description                   | **M/O** | **Note**                  |
|----------|----------|-------------------------------|---------|---------------------------|
| appId    | String   | 인가앱 id                       |    M    |                            |
| provider | Provider | 인가앱 정보                      |    M    | [Provider](#provider)      |
| nonce    | String   | Nonce for attestation         |    M    |                            |
| proof    | Proof    | Assertion proof               |    O    | [Proof](#4-proof)         

<br>

## 2.1.1.1. Provider

### Description

`제공자 정보`

### Declaration

```swift
public struct Provider: Jsonable {
    public var did: String
    public var certVcRef: String
}
```

### Property

| Name       | Type   | Description             | **M/O** | **Note** |
|------------|--------|-------------------------|---------|----------|
| did        | String | 제공자 DID                |    M    |          |
| certVcRef  | String | 가입증명서 VC URL          |    M    |          |

<br>

## 2.1.2. SignedWalletInfo

### Description

`서명된 월렛 정보`

### Declaration

```swift
public struct SignedWalletInfo: Jsonable, ProofContainer {
    public var wallet: Wallet
    public var nonce: String
    public var proof: Proof?
}
```

### Property

| Name       | Type           | Description                | **M/O** | **Note** |
|------------|----------------|----------------------------|---------|----------|
| wallet     | Wallet          | 월렛 정보                   |    M    | [Wallet](#28-wallet) |
| nonce      | String          | Nonce                     |    M    |          |
| proof      | Proof           | Proof                     |    O    | [Proof](#4-proof) |

<br>

## 2.1.2.1. Wallet

### Description

`월렛 세부정보`

### Declaration

```swift
public struct Wallet: Jsonable {
    private var id: String
    private var did: String
}
```
### Property

| Name       | Type           | Description              | **M/O** | **Note** |
|------------|----------------|--------------------------|---------|----------|
| id         | String          | 월렛 ID                  |    M    |          |
| did        | String          | 월렛 제공자 DID            |    M    |          |

<br>

## 2.2. ServerTokenData

### Description

`서버토큰 데이터`

### Declaration

```swift
public struct ServerTokenData: Jsonable, ProofContainer {
    public var purpose: ServerTokenPurposeEnum
    public var walletId: String
    public var appId: String
    public var validUntil: String
    public var provider: Provider
    public var nonce: String
    public var Proof?
}
```

### Property

| Name       | Type                                | Description                          | **M/O** | **Note** |
|------------|-------------------------------------|--------------------------------------|---------|----------|
| purpose    | ServerTokenPurposeEnum              | 서버토큰 목적                           |    M    | [ServerTokenPurpose](#24-servertokenpurpose) |
| walletId   | String                              | 월렛 ID                               |    M    |          |
| appId      | String                              | 인가앱 ID                              |    M    |          |
| validUntil | String                              | 서버토큰 유효시간                         |    M    |          |
| provider   | Provider                            | 제공자 정보                             |    M    | [Provider](#18-provider) |
| nonce      | String                              | Nonce                                |    M    |          |
| proof      | Proof                               | Proof                                |    O    | [Proof](#4-proof) |

<br>

## 2.3. WalletTokenSeed

### Description
`월렛토큰 시드 객체`

### Declaration
```swift
public struct WalletTokenSeed: Jsonable {
    public var purpose: WalletTokenPurposeEnum
    public var pkgName: String
    public var nonce: String
    public var validUntil: String
    public var userId: String?
}
```

### Property
| Name       | Type                            | Description                       | **M/O** | **Note** |
|------------|---------------------------------|-----------------------------------|---------|----------|
| purpose    | ServerTokenPurposeEnum          | 월렛 토큰 목적                       |    M    | [WalletTokenPurpose](#33-wallettokenpurpose) |
| pkgName    | String                          | 인가앱 패키지명                       |    M    |          |
| nonce      | String                          | Nonce                             |    M    |          |
| validUntil | String                          | 월렛토큰 유효시간                     |    M    |          |
| userId     | String                          | 사용자 ID                           |    O    |          |
<br>


## 2.4. WalletTokenData

### Description

`월렛토큰과 관련된 데이터`

### Declaration

```swift
public struct WalletTokenData: Jsonable, ProofContainer {
    public var seed: WalletTokenSeed
    public var sha256_pii: String
    public var provider: Provider
    public var nonce: String
    public var proof: Proof?
}
```

### Property

| Name       | Type              | Description                   | **M/O** | **Note** |
|------------|-------------------|-------------------------------|---------|----------|
| seed       | WalletTokenSeed   | 월렛 토큰 시드                    |    M    | [WalletTokenSeed](#33-wallettokenseed) |
| sha256_pii | String            | PII의 SHA-256 해시              |    M    |          |
| provider   | Provider          | 제공자 정보                      |    M    | [Provider](#18-provider) |
| nonce      | String            | Nonce                         |    M    |          |
| proof      | Proof             | Proof                         |    O    | [Proof](#4-proof) |

<br>

## 3. SecurityChannel

## 3.1. ReqEcdh

### Description

`ECDH 요청 데이터`

### Declaration

```swift
public struct ReqEcdh: Jsonable, ProofContainer {
    var client: String
    var clientNonce: String
    var publicKey: String
    var curve: ECType
    var candidate: [SymmetricCipherType]?
    public var proof: Proof?
}
```

### Property
| Name        | Type                             | Description                    | **M/O** | **Note** |
|-------------|----------------------------------|--------------------------------|---------|----------|
| client      | String                           | 클라이언트 DID                     |    M    |          |
| clientNonce | String                           | 클라이언트 Nonce                   |    M    |          |
| curve       | ECType.ELLIPTIC_CURVE_TYPE       | ECDH 커브 유형                    |    M    |          |
| publicKey   | String                           | 공개키 정보                        |    M    |          |
| candidate   | ReqEcdh.Ciphers                  | 대칭키 암호화 정보                   |    O    |          |
| proof       | Proof                            | Proof                           |    O    | [Proof](#4-proof) |

<br>

## 3.2. AccEcdh

### Description
`ECDH 승인 데이터`

### Declaration
```swift
public struct AccEcdh: Jsonable, ProofContainer {
    public var server: String
    public var serverNonce: String
    public var publicKey: String
    public var cipher: String
    public var padding: String
    public var proof: Proof?
}
```

### Property
| Name        | Type                           | Description                        | **M/O** | **Note** |
|-------------|--------------------------------|------------------------------------|---------|----------|
| server      | String                         | 서버 ID                          |    M    |          |
| serverNonce | String                         | 서버 Nonce                       |    M    |          |
| publicKey   | String                         | 공개키       |    M    |          |
| cipher      | String                         | 암호화 유형         |    M    |          |
| padding     | String                         | 패딩 유형        |    M    |          |
| proof       | Proof                          | Key agreement proof                |    O    | [Proof](#4-proof) |

<br>

## 3.3. AccE2e

### Description
`E2E 수용 데이터`

### Declaration
```swift
public struct AccE2e: Jsonable, ProofContainer {
    public var publicKey: String
    public var iv: String
    public var proof: Proof?
```

### Property
| Name       | Type               | Description                 | **M/O** | **Note**           |
|------------|--------------------|-----------------------------|---------|--------------------|
| publicKey  | String              | 공개키  |    M    |                    |
| iv         | String              | 초기화 백터          |    M    |                    |
| proof      | Proof               | Key agreement proof        |    O    | [Proof](#4-proof)  |

<br>

## 3.4. E2e

### Description

`E2E 암호화 정보`

### Declaration

```swift
public struct E2E: Jsonable {
    public var iv: String
    public var encVc: String
}
```

### Property

| Name  | Type   | Description                      | **M/O** | **Note** |
|-------|--------|----------------------------------|---------|----------|
| iv    | String | Initialize vector                |    M    |          |
| encVc | String | Encrypted Verifiable Credential  |    M    |          |

<br>

## 3.5. DIDAuth

### Description
`DID 인증 데이터`

### Declaration
```swift
public struct DIDAuth: Jsonable, ProofContainer {
    public var did: String
    public var authNonce: String
    public var proof: Proof?
}
```

### Property
| Name       | Type       | Description                   | **M/O** | **Note**                  |
|------------|------------|-------------------------------|---------|---------------------------|
| did        | String     | 대상 DID                           |    M    |                            |
| authNonce  | String     | Auth nonce                    |    M    |                            |
| proof      | Proof      | 인증 proof          |    O    | [Proof](#4-proof)          |

<br>

## 4. DidDoc
## 4.1. DIDDocVO

### Description
`인코딩된 DID 문서`

### Declaration
```swift
public struct DIDDocVO: Jsonable {
    public var didDoc: String
}
```

### Property
| Name   | Type   | Description            | **M/O** | **Note** |
|--------|--------|------------------------|---------|----------|
| didDoc | String | 인코딩된 DID 문서   |    M    |          |

<br>

## 4.2. AttestedDIDDoc

### Description
`검증된 DID 정보`

### Declaration
```swift
public struct AttestedDIDDoc: Jsonable, ProofContainer {
    public var walletId: String
    public var ownerDidDoc: String
    public var provider: Provider
    public var nonce: String
    public var proof: Proof?
}
```

### Property
| Name       | Type     | Description              | **M/O** | **Note**                  |
|------------|----------|--------------------------|---------|---------------------------|
| walletId   | String   | 월렛 ID                |    M    |                            |
| ownerDidDoc| String   | 소유자의 DID 문서     |    M    |                            |
| provider   | Provider | 제공자 정보     |    M    | [Provider](#provider)      |
| nonce      | String   | Nonce                    |    M    |                            |
| proof      | Proof    | Attestation proof        |    O    | [Proof](#4-proof)          |

<br>

## 4.3. SignedDidDoc

### Description
`서명된 DIDDoc`

### Declaration
```swift
public struct SignedDIDDoc: Jsonable, ProofContainer {
    public var ownerDIDDoc: String
    public var wallet: Wallet
    public var nonce: String
    public var proof: Proof?
}
```

### Property
| Name       | Type           | Description                | **M/O** | **Note** |
|------------|----------------|----------------------------|---------|----------|
| ownerDidDoc| String          | 소유자의 DID 문서      |    M    |          |
| wallet     | Wallet          | 월렛 정보        |    M    | [Wallet](#28-wallet) |
| nonce      | String          | Nonce                     |    M    |          |
| proof      | Proof           | Proof                     |    O    | [Proof](#4-proof) |

<br>

## 5. Offer
## 5.1. IssueOfferPayload

### Description
`VC 발행 위한 페이로드`

### Declaration
```swift
public struct IssueOfferPayload: Jsonable {
    public var offerId: String?
    public var type: OfferTypeEnum
    public var vcPlanId: String
    public var issuer: String
    public var validUntil: String?
```

### Property
| Name      | Type          | Description                            | **M/O** | **Note** |
|-----------|---------------|----------------------------------------|---------|----------|
| offerId   | String        | Offer ID                               |    M    |          |
| type      | OfferTypeEnum | OfferType (issuerOffer or VerifyOffer) |    M    |          |
| vcPlanId  | String        | Verifiable Credential Plan ID          |    M    |          |
| issuer    | String        | 발급자 DID                               |    M    |          |
| validUntil| String        | 유효시간                                 |    O    |          |

<br>

## 5.2. VerifyOfferPayload

### Description
`VP 제출을 위한 페이로드`

### Declaration
```swift
public struct VerifyOfferPayload: Jsonable {
    public var offerId: String
    public var type: OfferTypeEnum
    public var mode: PresentModeEnum
    public var device: String
    public var service: String
    public var endpoints: [String]
    public var validUntil: String
    public var locked: Bool = false
}
```

### Property
| Name       | Type                | Description                       | **M/O** | **Note** |
|------------|---------------------|-----------------------------------|---------|----------|
| offerId    | String              | Offer ID                          |    M    |          |
| type       | OfferTypeEnum       | Offer type                        |    M    |          |
| mode       | PresentModeEnum     | Presentation mode                 |    M    |          |
| device     | String              | 응대장치 식별자                       |    O    |          |
| service    | String              | 서비스 식별자                        |    O    |          |
| endpoints  | String[]            | profile 요청 API endpoint 목록      |    O    |          |
| validUntil | String              | end date of the offer             |    M    |          |
| locked     | Bool                | offer 잠김 여부                     |    O    |          |

<br>

## 6. VC
## 6.1. ReqVC

### Description
`검증 가능한 자격증명(VC)에 대한 요청 객체`

### Declaration
```swift
public struct ReqVC: Jsonable {
    public var refId: String
    public var profile: ReqVcProfile
    public var credentialRequest : ZKPCredentialRequest?
}
```

### Property
| Name              | Type                 | Description          | **M/O** | **Note** |
|-------------------|----------------------|----------------------|---------|----------|
| refId             | String               | 참조 ID               | M       |          |
| profile           | ReqVcProfile         | 발급 요청 프로파일       | M       |          |
| credentialRequest | ZKPCredentialRequest | ZKP 크레덴셜 요청문      | O       |          |

<br>

## 6.1.1. ReqVcProfile

### Description
`VC 발행을 위한 프로파일`

### Declaration
```swift
public struct ReqVcProfile: Jsonable {
    public var id: String
    public var issuerNonce: String
}
```

### Property
| Name         | Type            | Description               | **M/O** | **Note** |
|--------------|-----------------|---------------------------|---------|----------|
| id           | String          | 발급자 DID                |    M    |          |
| issuerNonce | String           | 발급자 nonce              |    M    |          |
<br>


## 6.2. VCPlanList

### Description

`검증 가능한 자격 증명(VC) 계획 목록`

### Declaration

```swift
public struct VCPlanList: Jsonable {
    public var count: Int
    public var items: [VcPlan]
}
```

### Property

| Name   | Type             | Description                      | **M/O** | **Note** |
|--------|------------------|----------------------------------|---------|----------|
| count  | int              | VC plan의 수                      |    M    |          |
| items  | array[VCPlan]    | VC plan 목록                      |    M    | [VCPlan](#28-vcplan) |

<br>

## 6.2.1. VCPlan

### Description
`검증 가능한 자격 증명(VC) 계획의 세부 사항`

### Declaration
```swift
public struct VCPlan: Jsonable {
    public var vcPlanId: String
    public var name: String
    public var description: String
    public var url: String?
    public var logo: LogoImage?
    public var validFrom: String?
    public var validUntil: String?
    public var tags: [String]?
    public var credentialSchema: IssueProfile.Profile.CredentialSchema
    public var option: Option
    public var delegate: String?
    public var allowedIssuers: [String]?
    public var manager: String
    public var credentialDefinition : VCPlan.CredentialDefinition?
}
```

### Property
| Name                 | Type                            | Description                              | **M/O** | **Note**                        |
|----------------------|----------------------------------|-----------------------------------------|---------|----------------------------------|
| vcPlanId             | String                          | VC plan ID                               | M       |                                  |
| name                 | String                          | VC plan 이름                              | M       |                                  |
| description          | String                          | VC plan 설명                              | M       |                                  |
| url                  | String                          | issuer url                               | O       |                                  |
| logo                 | LogoImage                       | 로고 이미지                                 | O       | [LogoImage](#29-logoimage)       |
| validFrom            | String                          | 유효시작일                                  | O       |                                  |
| validUntil           | String                          | 유효만료일                                  | O       |                                  |
| tags                 | array[String]                   | tags                                     | O       |                                  |
| credentialSchema     | CredentialSchema                | Credential schema                        | M       |                                  |
| option               | VCPlan.Option                   | VC Plan 옵션                              | M       |                                  |
| delegate             | String                          | delegate                                 | O       |                                  |
| allowedIssuers       | array[String]                   | VC plan 사용이 허용된 발급 사업자 DID 목록      | O       |                                  |
| manager              | String                          | VC plan 관리 권한을 가진 엔티티               | M       |                                  |
| credentialDefinition | VCPlan.CredentialDefinition     | VC 발급에 연관된 ZKP 정보                    | O       |                                  |


<br>

## 6.2.1.1. Option

### Description
`(VC) 계획 옵션`

### Declaration
```swift
public struct Option: Jsonable {
    public var allowUserInit: Bool
    public var allowIssuerInit: Bool
    public var delegatedIssuance: Bool
}
```

### Property
| Name              | Type        | Description                         | **M/O** | **Note** |
|-------------------|-------------|-------------------------------------|---------|----------|
| allowUserInit     | Bool        | 사용자에 의한 발급 개시 허용 여부           |    M    |          |
| allowIssuerInit   | Bool        | 이슈어에 의한 발급 개시 허용 여부           |    M    |          |
| delegatedIssuance | Bool        | 대표 발급자에 의한 위임발급 여부            |    M    |          |

<br>

## 6.2.1.2. VCPlan.CredentialDefinition

### Description
`VC 발급에 연관된 ZKP 정보`

### Declaration
```swift
public struct CredentialDefinition: Jsonable
{
    public var id: String
    public var schemaId: String
}
```

### Property
| Name     | Type   | Description                     | **M/O** | **Note** |
|----------|--------|---------------------------------|---------|----------|
| id       | String | ZKP CredentialDefinition ID     | M       |          |
| schemaId | String | ZKP CredentialSchema ID         | M       |          |


<br>

# OID4VC

앱이 직접 다루는 OpenID4VCI(발급)·OpenID4VP(제출)·ISO/IEC 18013-5 근접 제출 계층의 모델이다.
Wallet에서 읽어오는 것(1–6), 검증자·리더와 주고받는 것(7–11), 발급자와 주고받는 것(12–17)으로
나뉜다.

매칭 엔진 자체 — credential adapter, `DCQLCredentialMatcher`, `ParsedCredential`, path 헬퍼 — 는
SDK 내부 조합을 위해 `public`일 뿐 앱이 쓰는 표면이 아니다. 앱은 `WalletAPI.matchCredentials`를
경유한다.

## 1. CredentialItem

### Description
`Wallet이 보관하는 형식이 무엇이든, 저장된 크리덴셜 한 건.`

### Declaration
```swift
public protocol CredentialItem: Identifiable {
    var id: String { get }
    var format: CredentialFormat { get }
}
```

### Property
| Name   | Type             | Description                | **M/O** | **Note**                                 |
|--------|------------------|----------------------------|---------|------------------------------------------|
| id     | String           | Wallet 내부 크리덴셜 id     | M       |                                          |
| format | CredentialFormat | 실제 구현 타입 구분          | M       | [CredentialFormat](#11-credentialformat) |

<br>

## 1.1. CredentialFormat

### Description
`크리덴셜의 저장 형식.`

### Declaration
```swift
public enum CredentialFormat {
    case vcdm, sdJwtVc, msoMdoc

    public var token: String { get }
    public init?(token: String)
}
```

### Property
| Value    | Description                            | **Note**                                       |
|----------|----------------------------------------|------------------------------------------------|
| vcdm     | W3C VCDM 크리덴셜                       | [VCDMCredentialItem](#12-vcdmcredentialitem). 토큰 `opendid_vc` |
| sdJwtVc  | IETF SD-JWT VC                         | [SdJwtCredentialItem](#13-sdjwtcredentialitem). 토큰 `dc+sd-jwt-did` |
| msoMdoc  | ISO/IEC 18013-5 mdoc                   | [MdocCredentialItem](#14-mdoccredentialitem). 토큰 `mso_mdoc-did` |

### Method
| Name         | Description                                              | **Note** |
|--------------|----------------------------------------------------------|----------|
| token        | 이 SDK 가 그 형식에 대해 쓰는 DCQL `format` 토큰            | 앱이 표시하거나 비교할 때 기준으로 삼는 단일 정의 |
| init(token:) | DCQL `format` 토큰이 가리키는 형식. 이 SDK 가 다루지 않는 토큰이면 `nil` | 검증자가 보낼 수 있는 별칭도 받는다. `.vcdm` 에 `jwt_vc_json`, `jwt_vc`, `ldp_vc`, `.sdJwtVc` 에 `vc+sd-jwt`, `sd-jwt` |

<br>

## 1.2. VCDMCredentialItem

### Description
`저장된 W3C 크리덴셜. 함께 발급된 ZKP 크리덴셜이 있으면 같이 담긴다.`

### Declaration
```swift
public struct VCDMCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let vc: VerifiableCredential
    public let zkp: ZKPCredential?
}
```

### Property
| Name   | Type                 | Description             | **M/O** | **Note**                                        |
|--------|----------------------|-------------------------|---------|-------------------------------------------------|
| id     | String               | Wallet 내부 크리덴셜 id  | M       |                                                 |
| format | CredentialFormat     | 항상 `.vcdm`            | M       | [CredentialFormat](#11-credentialformat)        |
| vc     | VerifiableCredential | 크리덴셜 본체            | M       | [VerifiableCredential](#2-verifiablecredential) |
| zkp    | ZKPCredential        | 같은 주체의 ZKP 크리덴셜  | O       |                                                 |

<br>

## 1.3. SdJwtCredentialItem

### Description
`저장된 SD-JWT 크리덴셜. getAllOID4VCs / getOID4VCs 가 반환하는 두 원소 타입 중 하나.`

### Declaration
```swift
public struct SdJwtCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let configurationId: String
    public let kid: String
    public let credentialIdentifier: String?
    public let sdjwt: SDJWT

    public var issuerDid: String? { get }
    public var consentItems: [SdJwtConsentItem] { get throws }
    public var status: StatusListReference? { get throws }
}
```

### Property
| Name                 | Type             | Description                                | **M/O** | **Note** |
|----------------------|------------------|--------------------------------------------|---------|----------|
| id                   | String           | Wallet 내부 크리덴셜 id                     | M       |          |
| format               | CredentialFormat | 항상 `.sdJwtVc`                            | M       | [CredentialFormat](#11-credentialformat) |
| configurationId      | String           | 발급에 사용된 `credential_configuration_id` | M       |          |
| kid                  | String           | 크리덴셜에 바인딩된 홀더 키의 id             | M       |          |
| credentialIdentifier | String           | 발급자가 지정한 `credential_identifier`     | O       |          |
| sdjwt                | SDJWT            | 크리덴셜 본체                               | M       | [SDJWT](#2-sdjwt) |
| issuerDid            | String           | 크리덴셜에 서명한 발급자의 DID               | O       | `SDJWT.issuerDid`. 이 SDK 가 저장한 크리덴셜이면 `nil` 이 아니다 |
| consentItems         | [SdJwtConsentItem] | 홀더에게 동의를 물을 수 있는 모든 클레임, 발급자가 쓴 순서 | M | [SdJwtConsentItem](#22-sdjwtconsentitem). 발급자 JWT payload 를 읽을 수 없으면 `MSDKWLT05102` |
| status               | StatusListReference | 크리덴셜의 폐기 상태가 게시되는 곳          | O       | [StatusListReference](#4-statuslistreference). 발급자가 게시하지 않으면 `nil`. payload 를 읽을 수 없으면 `MSDKWLT05102` |

<br>

## 1.4. MdocCredentialItem

### Description
`저장된 ISO/IEC 18013-5 mdoc. getAllOID4VCs / getOID4VCs 가 반환하는 다른 한 원소 타입.`

### Declaration
```swift
public struct MdocCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let configurationId: String
    public let kid: String
    public let credentialIdentifier: String?
    public let mdoc: Mdoc

    public var issuerDid: String? { get }
    public var consentItems: [MdocConsentItem] { get }
    public var status: StatusListReference? { get }
}
```

### Property
| Name                 | Type              | Description                                | **M/O** | **Note** |
|----------------------|-------------------|--------------------------------------------|---------|----------|
| id                   | String            | Wallet 내부 크리덴셜 id                     | M       | `MdocRequestedDocument.credentialId` 가 가리키는 값 |
| format               | CredentialFormat  | 항상 `.msoMdoc`                            | M       | [CredentialFormat](#11-credentialformat) |
| configurationId      | String            | 발급에 사용된 `credential_configuration_id` | M       |          |
| kid                  | String            | 문서에 바인딩된 기기 키의 id                 | M       |          |
| credentialIdentifier | String            | 발급자가 지정한 `credential_identifier`     | O       |          |
| mdoc                 | Mdoc              | 문서 본체                                   | M       | [Mdoc](#3-mdoc) |
| issuerDid            | String            | 문서에 서명한 발급자의 DID                   | O       | `Mdoc.issuerDid`. 이 SDK 가 저장한 문서면 `nil` 이 아니다 |
| consentItems         | [MdocConsentItem] | 홀더에게 동의를 물을 수 있는 모든 element, 발급자 순서 | M | [MdocConsentItem](#31-mdocconsentitem). 파싱 때 문서 전체가 디코딩되므로 에러를 던지지 않는다 |
| status               | StatusListReference | 문서의 폐기 상태가 게시되는 곳              | O       | [StatusListReference](#4-statuslistreference). 발급자가 게시하지 않으면 `nil` |

<br>

## 2. SDJWT

### Description
`SD-JWT — 발급자 JWT, disclosure 목록, 그리고 있으면 key-binding JWT.`

### Declaration
```swift
public struct SDJWT: Jsonable {
    public let credentialJwt: String
    public let disclosures: [Disclosure]
    public var keyBindingJwt: String?

    public init(credentialJwt: String, disclosures: [Disclosure] = [], keyBindingJwt: String? = nil)
    public static func parse(raw: String) -> SDJWT
    public func toString() -> String
    public func getSignSource() -> (String, String)

    public var issuerDid: String? { get }
    public func consentItems() throws -> [SdJwtConsentItem]
    public func status() throws -> StatusListReference?
}
```

### Property
| Name          | Type          | Description                          | **M/O** | **Note** |
|---------------|---------------|--------------------------------------|---------|----------|
| credentialJwt | String        | 발급자가 서명한 JWT (compact)         | M       |          |
| disclosures   | [Disclosure]  | 크리덴셜이 담고 있는 모든 disclosure   | M       | [Disclosure](#21-disclosure) |
| keyBindingJwt | String        | KB-JWT. 제출본에만 존재               | O       |          |
| issuerDid     | String        | 크리덴셜에 서명한 발급자의 DID. 발급자 JWT 의 `kid` 에서 읽는다 | O | JWT 를 읽을 수 없거나 `kid` 가 DID URL 이 아니면 `nil` — 이 SDK 가 저장한 크리덴셜에서는 일어나지 않는다 |

### Method
| Name             | Description                                        | **Note** |
|------------------|----------------------------------------------------|----------|
| parse(raw:)      | `~`로 구분된 SD-JWT 문자열을 분해한다                | 에러를 던지지 않는다. 해석 불가 문자열은 disclosure 없는 크리덴셜 JWT가 된다 |
| toString()       | `~` 구분 형식으로 다시 직렬화한다                    |          |
| getSignSource()  | 크리덴셜 JWT의 서명 대상과 서명값을 반환한다          |          |
| consentItems()   | 홀더에게 동의를 물을 수 있는 모든 클레임을, 각각을 가리키는 코드와 함께, 발급자가 disclosure 를 쓴 순서로 반환한다. 평문으로 둔 클레임은 맨 뒤 | [SdJwtConsentItem](#22-sdjwtconsentitem). 발급자 JWT payload 를 읽을 수 없으면 `MSDKWLT05102` |
| status()         | 크리덴셜의 폐기 상태가 게시되는 곳. 게시하지 않으면 `nil` | [StatusListReference](#4-statuslistreference). payload 를 읽을 수 없거나 해석할 수 없는 `status` 가 있으면 `MSDKWLT05102` |

<br>

## 2.1. Disclosure

### Description
`SD-JWT의 선택 공개 클레임 한 건.`

### Declaration
```swift
public struct Disclosure: Codable, Equatable, Sendable {
    public let salt: String
    public let claimName: String?
    public let claimValue: JSON
    public let raw: String?
}
```

### Property
| Name       | Type   | Description                                  | **M/O** | **Note** |
|------------|--------|----------------------------------------------|---------|----------|
| salt       | String | 발급자가 부여한 salt                          | M       |          |
| claimName  | String | 클레임 이름. 배열 원소 disclosure면 `nil`      | O       |          |
| claimValue | JSON   | 공개되는 값                                   | M       |          |
| raw        | String | 발급자의 disclosure 문자열 원본(바이트 단위)   | O       | 코드로 만든 disclosure는 `nil`. digest가 이 바이트 위에서 계산되므로 파싱된 disclosure는 그대로 제출한다 |

<br>

## 2.2. SdJwtConsentItem

### Description
`SD-JWT 의 클레임 하나. 홀더에게 동의를 묻는 단위.`

`code` 가 오가는 값이다. 매칭은 이 코드로 클레임을 지목하고, 홀더의 선택도 이 코드로 표현되며,
`createVpToken` 은 이 코드를 필요한 disclosure 로 되돌린다. 불투명 값이다 — 표시하고 비교하되,
`.` 이나 `[]` 로 쪼개거나 조립하지 않는다.

### Declaration
```swift
public struct SdJwtConsentItem: Sendable, Equatable {
    public let code: String
    public let claimName: String
    public let value: AnyJSON
    public let isAmbiguous: Bool
    public let isSelectivelyDisclosable: Bool
}
```

### Property
| Name                     | Type    | Description                                              | **M/O** | **Note** |
|--------------------------|---------|----------------------------------------------------------|---------|----------|
| code                     | String  | claim code                                               | M       | `MatchedCredential.claimCodes` 에 그대로 되돌려준다 |
| claimName                | String  | 코드의 마지막 세그먼트. 경로 대신 라벨을 보여줄 화면용     | M       |          |
| value                    | AnyJSON | 클레임 값                                                 | M       | [AnyJSON](#18-anyjson) |
| isAmbiguous              | Bool    | 이 코드가 크리덴셜의 클레임 둘 이상을 가리키는지            | M       | 모호한 코드의 제출은 추측하지 않고 실패한다 |
| isSelectivelyDisclosable | Bool    | 이 클레임을 빼면 실제로 숨겨지는지                          | M       | `false` 면 발급자가 평문으로 둔 것이다. 선택 여부와 무관하게 검증자가 읽는다 |

<br>

## 3. Mdoc

### Description
`OpenID4VCI 로 발급받은 ISO/IEC 18013-5 IssuerSigned 모바일 문서.`

문서는 디코딩된 클레임으로 노출되지만, 저장·제출은 발급자가 서명한 바이트 그대로 한다.
`issuerSigned` 가 원본 base64url 문자열이고, MSO 의 모든 digest 는 받은 그대로의 item 바이트 위에서
계산된다. 파싱은 디코딩만 하고 검증하지 않는다 — 저장된 문서는 저장 시점에 검증(발급자 서명,
element digest, 유효기간, 기기 키 바인딩)을 거친 것이다.

### Declaration
```swift
public struct Mdoc: Sendable, Equatable {
    public let docType: String
    public let namespaces: [String: [String: MdocElementValue]]
    public let validityInfo: MdocValidityInfo
    public let issuerSigned: String

    public var issuerDid: String? { get }
    public var status: StatusListReference? { get }
    public var consentItems: [MdocConsentItem] { get }

    public static func parse(raw: String) throws -> Mdoc
    public func toString() -> String
}
```

### Property
| Name         | Type                                   | Description                                        | **M/O** | **Note** |
|--------------|----------------------------------------|----------------------------------------------------|---------|----------|
| docType      | String                                 | 문서 타입. 예: `eu.europa.ec.eudi.pid.1`            | M       |          |
| namespaces   | [String: [String: MdocElementValue]]   | 공개된 element. namespace, 그 다음 element 식별자 순 | M       | [MdocElementValue](#33-mdocelementvalue). `Dictionary` 라 순회 순서가 고정되지 않는다 — 화면은 `consentItems` 로 그린다 |
| validityInfo | MdocValidityInfo                       | MSO 에 적힌 문서 유효기간                            | M       | [MdocValidityInfo](#32-mdocvalidityinfo) |
| issuerSigned | String                                 | 받은 그대로의 `IssuerSigned` 구조, base64url         | M       |          |
| issuerDid    | String                                 | 문서에 서명한 발급자의 DID. `issuerAuth` 의 `kid` 에서 읽는다 | O | 저장(검증)된 문서에서 의미가 있다. `kid` 가 없거나 DID URL 이 아니면 `nil` |
| status       | StatusListReference                    | 문서의 폐기 상태가 게시되는 곳. MSO 에서 읽는다       | O       | [StatusListReference](#4-statuslistreference). 발급자가 게시하지 않으면 `nil` |
| consentItems | [MdocConsentItem]                      | 홀더에게 동의를 물을 수 있는 모든 element, 각각을 가리키는 코드와 함께 | M | [MdocConsentItem](#31-mdocconsentitem). element 는 서명된 순서, namespace 는 이름 순 |

### Method
| Name         | Description                                        | **Note** |
|--------------|----------------------------------------------------|----------|
| parse(raw:)  | base64url 형태의 `IssuerSigned` 를 디코딩한다        | 올바른 `IssuerSigned` 가 아니면 `MSDKWLT05103` |
| toString()   | base64url 인코딩된 `IssuerSigned`. 발급자 바이트 그대로 |          |

<br>

## 3.1. MdocConsentItem

### Description
`mdoc 의 element 하나. 홀더에게 동의를 묻는 단위.`

`code` 가 오가는 값이다. 매칭은 이 코드로 element 를 지목하고, 홀더의 선택도 이 코드로 표현되며,
`createVpToken` / `createDeviceResponse` 는 이 코드를 이 element 로 되돌린다. 불투명 값이다 —
표시하고 비교하되, 쪼개거나 `namespace` 와 `elementIdentifier` 로 조립하지 않는다.

### Declaration
```swift
public struct MdocConsentItem: Sendable, Equatable {
    public let code: String
    public let namespace: String
    public let elementIdentifier: String
    public let value: MdocElementValue
    public let isAmbiguous: Bool
}
```

### Property
| Name              | Type             | Description                                       | **M/O** | **Note** |
|-------------------|------------------|---------------------------------------------------|---------|----------|
| code              | String           | claim code                                        | M       | `MatchedCredential.claimCodes` 또는 `MdocRequestedDocument.claimCodes` 에 그대로 되돌려준다 |
| namespace         | String           | element 가 속한 namespace                          | M       | 행을 그리기 위한 것이지 코드를 재구성하기 위한 것이 아니다 |
| elementIdentifier | String           | namespace 안에서의 element 식별자                   | M       | 행을 그리기 위한 것이지 코드를 재구성하기 위한 것이 아니다 |
| value             | MdocElementValue | 발급자가 element 에 넣은 값                         | M       | [MdocElementValue](#33-mdocelementvalue) |
| isAmbiguous       | Bool             | 이 코드가 문서의 element 둘 이상을 가리키는지        | M       | 모호한 코드의 제출은 추측하지 않고 실패한다 |

<br>

## 3.2. MdocValidityInfo

### Description
`발급자가 MSO 에 적은 유효기간.`

### Declaration
```swift
public struct MdocValidityInfo: Sendable, Equatable {
    public let signed: Date
    public let validFrom: Date
    public let validUntil: Date
    public let expectedUpdate: Date?
}
```

### Property
| Name           | Type | Description                          | **M/O** | **Note** |
|----------------|------|--------------------------------------|---------|----------|
| signed         | Date | MSO 가 서명된 시각                    | M       |          |
| validFrom      | Date | 문서 유효기간 시작                    | M       |          |
| validUntil     | Date | 문서 유효기간 끝                      | M       |          |
| expectedUpdate | Date | 발급자가 재발급을 예정한 시각(적었다면) | O       |          |

<br>

## 3.3. MdocElementValue

### Description
`mdoc element 가 가질 수 있는 값.`

mdoc element 는 JSON 이 아니라 CBOR 라 `AnyJSON` 이 담지 못하는 것까지 이른다. `portrait` 는 JPEG
바이트열이고, `birth_date` 는 평문 문자열이 아니라 태그된 날짜다.

### Declaration
```swift
public enum MdocElementValue: Sendable, Equatable {
    case text(String)
    case bytes(Data)
    case integer(Int64)
    case double(Double)
    case bool(Bool)
    case fullDate(String)
    case dateTime(Date)
    case array([MdocElementValue])
    case map([String: MdocElementValue])
    case null
}
```

### Property
| Value            | Description                                                       | **Note** |
|------------------|-------------------------------------------------------------------|----------|
| text(String)     | 문자열                                                             |          |
| bytes(Data)      | 바이트열. 예: portrait JPEG                                        |          |
| integer(Int64)   | 정수                                                               |          |
| double(Double)   | 부동소수                                                           |          |
| bool(Bool)       | 불리언                                                             |          |
| fullDate(String) | `full-date`(tag 1004). 시각·시간대 없는 달력 날짜, 적힌 그대로       | 시점이 아니라 날짜를 뜻하므로 문자열로 둔다 |
| dateTime(Date)   | 시점(tag 0 / tag 1)                                                |          |
| array            | element 값의 배열                                                   |          |
| map              | 문자열 키의 element 값 맵                                           |          |
| null             | CBOR null                                                          |          |

<br>

## 4. StatusListReference

### Description
`크리덴셜의 폐기 상태가 게시되는 곳. IETF Token Status List 항목.`

크리덴셜은 자기 상태를 말하지 않는다. 목록을 가리킬 뿐이고, 답이 필요한 쪽이 그 목록을 받아
`idx` 위치의 항목을 읽는다. 두 크리덴셜 형식 모두 같은 방식(`status.status_list`)으로 참조를
담으므로 타입 하나가 둘을 다 맡는다. SDK 는 참조를 노출하는 데서 멈춘다. 목록을 받아오지도,
bitstring 을 풀지도, 폐기·정지 여부를 판단하지도 않는다 — 그 호출과 판단은 월렛 앱의 몫이다.

### Declaration
```swift
public struct StatusListReference: Sendable, Equatable {
    public let uri: String
    public let idx: Int

    public init(uri: String, idx: Int)
}
```

### Property
| Name | Type   | Description                                   | **M/O** | **Note** |
|------|--------|-----------------------------------------------|---------|----------|
| uri  | String | status list 토큰이 게시된 URL                  | M       |          |
| idx  | Int    | `uri` 가 가리키는 목록 안에서 이 크리덴셜의 위치 | M       |          |

<br>

## 5. JWS

### Description
`compact 직렬화된 JWS(<header>.<payload>.<signature>)를 파싱한 결과.`

세 프로퍼티는 전송된 base64url 조각 그대로이며, 디코딩된 형태는 `payloadData`·`protectedHeader`로
읽는다.

### Declaration
```swift
public struct JWS
{
    public let header: String
    public let payload: String
    public let signature: String

    public init(from string: String) throws
    public var payloadData: Data { get throws }
    public var protectedHeader: JWSHeader { get throws }
}
```

### Property
| Name      | Type   | Description                     | **M/O** | **Note** |
|-----------|--------|---------------------------------|---------|----------|
| header    | String | base64url 인코딩된 protected header | M    |          |
| payload   | String | base64url 인코딩된 payload       | M       |          |
| signature | String | base64url 인코딩된 signature     | M       |          |

### Method
| Name            | Description                          | **Note** |
|-----------------|--------------------------------------|----------|
| init(from:)     | compact JWS를 파싱한다                | 점으로 구분된 세 조각이 아니면 `MSDKWLT05102` |
| payloadData     | base64url 디코딩된 payload            | payload가 base64url이 아니면 `MSDKWLT05102` |
| protectedHeader | 디코딩된 protected header             | header가 base64url이 아니거나 JWS 헤더가 아니면 `MSDKWLT05102` |

<br>

## 5.1. JWSHeader

### Description
`JWS의 protected header.`

`JWS.protectedHeader`로 읽는다. memberwise 이니셜라이저는 SDK 내부용이다. 헤더가 `jwk` 없이 `kid`만
담고 있으면 서명자 키는 호출자가 직접 해석해야 한다 — SDK는 검증을 위해 DID 문서를 조회하지 않는다.

### Declaration
```swift
public struct JWSHeader : Jsonable
{
    public var alg : JWK.Algorithm = .es256
    public var typ : String
    public var kid : String?
    public var jwk : JWK?
}
```

### Property
| Name | Type          | Description                            | **M/O** | **Note** |
|------|---------------|----------------------------------------|---------|----------|
| alg  | JWK.Algorithm | 서명 알고리즘                           | M       | [JWK](#6-jwk) |
| typ  | String        | 토큰 타입. 예: `openid4vci-proof+jwt`   | M       |          |
| kid  | String        | 서명자 키 id                            | O       |          |
| jwk  | JWK           | 헤더에 실린 서명자 공개키                | O       | [JWK](#6-jwk) |

<br>

## 6. JWK

### Description
`JSON Web Key. EC P-256 키만 모델링한다.`

호출자는 — 예를 들어 `JWSHeader`에서 — 읽기만 하고 직접 생성하지 않는다. memberwise 이니셜라이저는
SDK 내부용이다.

### Declaration
```swift
public struct JWK: Jsonable
{
    public var alg : Algorithm?
    public var kid : String?
    public var crv : Curve      = .p256
    public var kty : KeyType    = .ec
    public var x   : String
    public var y   : String
    public var use : JWKUse?
}
```

### Property
| Name | Type      | Description                     | **M/O** | **Note** |
|------|-----------|---------------------------------|---------|----------|
| alg  | Algorithm | 용도 알고리즘                    | O       | [중첩 열거형](#61-jwk-nested-enumerations) |
| kid  | String    | 키 id                           | O       |          |
| crv  | Curve     | 곡선. 기본값 `.p256`             | M       |          |
| kty  | KeyType   | 키 타입. 기본값 `.ec`            | M       |          |
| x    | String    | base64url x 좌표                | M       |          |
| y    | String    | base64url y 좌표                | M       |          |
| use  | JWKUse    | `.sig` 또는 `.enc`              | O       |          |

<br>

## 6.1. JWK nested enumerations

### Description
`알고리즘·곡선·키 타입·용도. 각각 인식하지 못한 전송 값을 그대로 보존한다.`

### Declaration
```swift
public enum Algorithm: Jsonable, Equatable { case es256, ecdhES, unknown(String) }
public enum Curve:     Jsonable, Equatable { case p256, unknown(String) }
public enum KeyType:   Jsonable, Equatable { case ec, unknown(String) }
public enum JWKUse: String, Jsonable, Equatable { case sig, enc }
```

### Property
| Type      | Values                                | **Note**                                       |
|-----------|---------------------------------------|------------------------------------------------|
| Algorithm | `es256`, `ecdhES`, `unknown(String)`  | 서명은 `ES256`, 응답 암호화는 `ECDH-ES`          |
| Curve     | `p256`, `unknown(String)`             | `P-256`으로 인코딩                              |
| KeyType   | `ec`, `unknown(String)`               | `EC`로 인코딩                                   |
| JWKUse    | `sig`, `enc`                          |                                                |

<br>

## 7. AuthorizationRequest

### Description
`검증자로부터 받은 OpenID4VP 인가 요청.`

`matchCredentials`와 `createVpToken`에 전달한다.

### Declaration
```swift
public struct AuthorizationRequest : Jsonable, FromSnake
{
    public let responseUri: String
    public let nonce: String
    public let state: String
    public let clientId: String
    public let responseType: String
    public let responseMode: String
    public let dcqlQuery: DCQLQuery
    public let clientMetadata: [String: AnyJSON]
    public let iat : Int
}
```

### Property
| Name           | Type              | Description                                  | **M/O** | **Note** |
|----------------|-------------------|----------------------------------------------|---------|----------|
| responseUri    | String            | 응답 본문을 POST할 엔드포인트                  | M       |          |
| nonce          | String            | presentation에 바인딩되는 검증자 nonce         | M       |          |
| state          | String            | 응답에 그대로 실어 보내는 검증자 state         | M       |          |
| clientId       | String            | 검증자 식별자. presentation의 audience로 쓰인다 | M      |          |
| responseType   | String            | OAuth response type                          | M       |          |
| responseMode   | String            | `direct_post` 또는 `direct_post.jwt`          | M       | 그 외 값은 거부된다 (`MSDKWLT05509`) |
| dcqlQuery      | DCQLQuery         | 매칭 대상 크리덴셜 쿼리                        | M       | [DCQLQuery](#8-dcqlquery) |
| clientMetadata | [String: AnyJSON] | 검증자 메타데이터. `direct_post.jwt`의 응답 암호화 키를 담는다 | M | [AnyJSON](#18-anyjson) |
| iat            | Int               | 요청 발행 시각                                 | M       |          |

<br>

## 8. DCQLQuery

### Description
`검증자의 DCQL(Digital Credentials Query Language) 쿼리 (OpenID4VP 1.0 §6).`

### Declaration
```swift
public struct DCQLQuery: Jsonable, FromSnake
{
    public var credentials: [CredentialQuery]?
    public var credentialSets: [CredentialSet]?
    public var transactionData: [[String: AnyJSON]]?
}
```

### Property
| Name            | Type                 | Description                        | **M/O** | **Note** |
|-----------------|----------------------|------------------------------------|---------|----------|
| credentials     | [CredentialQuery]    | 만족시켜야 할 크리덴셜 쿼리들        | O       | [CredentialQuery](#81-credentialquery) |
| credentialSets  | [CredentialSet]      | 그 쿼리들의 어떤 조합을 받아들이는지 | O       | [CredentialSet](#84-credentialset) |
| transactionData | [[String: AnyJSON]]  | 함께 서명할 거래 데이터              | O       | [AnyJSON](#18-anyjson) |

<br>

## 8.1. CredentialQuery

### Description
`검증자가 요구하는 크리덴셜 한 건.`

### Declaration
```swift
public struct CredentialQuery: Jsonable, FromSnake
{
    public var id: String?
    public var format: String?
    public var meta: [String: AnyJSON]?
    public var claims: [ClaimQuery]?
    public var claimSets: [[String]]?
    public var trustedAuthorities: [TrustedAuthority]?
    public var purpose: String?
    public var multiple: Bool?
    public var requireCryptographicHolderBinding: Bool?
}
```

### Property
| Name                              | Type                | Description                                | **M/O** | **Note** |
|-----------------------------------|---------------------|--------------------------------------------|---------|----------|
| id                                | String              | 쿼리 id. `MatchedCredential.queryId`로 되돌아온다 | O  |          |
| format                            | String              | 요구하는 크리덴셜 형식                       | O       |          |
| meta                              | [String: AnyJSON]   | 형식별 제약. 예: 허용 스키마 id 목록          | O       | [AnyJSON](#18-anyjson) |
| claims                            | [ClaimQuery]        | 요구하는 클레임. 없으면 크리덴셜 전체         | O       | [ClaimQuery](#82-claimquery) |
| claimSets                         | [[String]]          | `claims[].id` 배열의 배열. 안쪽 배열 하나가 하나의 허용 조합 | O | 모든 id가 해소되는 첫 조합을 Wallet이 선택한다 |
| trustedAuthorities                | [TrustedAuthority]  | 발급자 제약                                 | O       | [TrustedAuthority](#83-trustedauthority) |
| purpose                           | String              | 요구 사유                                   | O       |          |
| multiple                          | Bool                | 이 쿼리에 여러 크리덴셜이 응답할 수 있는지     | O       | 기본값 `false` |
| requireCryptographicHolderBinding | Bool                | 홀더 바인딩 필수 여부                        | O       |          |

<br>

## 8.2. ClaimQuery

### Description
`검증자가 요구하는 클레임 한 건. 값에 대한 술어를 함께 걸 수 있다.`

### Declaration
```swift
public struct ClaimQuery: Jsonable, FromSnake
{
    public var id: String?
    public var path: [DCQLPathElement]?
    public var namespace: String?
    public var claimName: String?
    public var purpose: String?
    public var values: [AnyJSON]?
    public var value: AnyJSON?
    public var max: AnyJSON?
    public var min: AnyJSON?
}
```

### Property
| Name      | Type               | Description                            | **M/O** | **Note** |
|-----------|--------------------|----------------------------------------|---------|----------|
| id        | String             | 클레임 쿼리 id. `claimSets`가 참조한다   | O       |          |
| path      | [DCQLPathElement]  | JSON 크리덴셜 내 클레임 경로             | O       | [DCQLPathElement](#85-dcqlpathelement). mdoc에는 쓰지 않는다 |
| namespace | String             | mdoc 네임스페이스. 예: `org.iso.18013.5.1` | O    |          |
| claimName | String             | 네임스페이스 내 mdoc 클레임 이름          | O       |          |
| purpose   | String             | 이 클레임을 요구하는 사유                 | O       |          |
| values    | [AnyJSON]          | 값이 이 중 하나여야 한다                  | O       | [AnyJSON](#18-anyjson) |
| value     | AnyJSON            | 값이 이것과 같아야 한다                   | O       |          |
| max       | AnyJSON            | 값의 상한                                | O       |          |
| min       | AnyJSON            | 값의 하한                                | O       |          |

<br>

## 8.3. TrustedAuthority

### Description
`크리덴셜 쿼리의 발급자 제약 (OpenID4VP 1.0 §6.1.1).`

### Declaration
```swift
public struct TrustedAuthority: Jsonable, FromSnake {
    public var type: String?
    public var values: [String]?
}
```

### Property
| Name   | Type     | Description             | **M/O** | **Note** |
|--------|----------|-------------------------|---------|----------|
| type   | String   | 검증 방식                | O       | `aki`, `etsi_tl`, `openid_federation`, `x509_san_dns`, `x509_san_uri` |
| values | [String] | 해당 방식에서 허용할 값들 | O       |          |

<br>

## 8.4. CredentialSet

### Description
`검증자가 받아들이는 크리덴셜 쿼리 조합.`

### Declaration
```swift
public struct CredentialSet: Jsonable, FromSnake {
    public var id: String?
    public var options: [[String]]?
    public var required: Bool?
    public var purpose: String?
}
```

### Property
| Name     | Type       | Description                                 | **M/O** | **Note** |
|----------|------------|---------------------------------------------|---------|----------|
| id       | String     | set id                                      | O       |          |
| options  | [[String]] | `credentials[].id` 배열의 배열. 안쪽 배열 하나가 하나의 허용 조합 | O | |
| required | Bool       | 최소 한 조합은 만족해야 하는지                | O       | 기본값 `true` |
| purpose  | String     | 이 set을 요구하는 사유                       | O       |          |

<br>

## 8.5. DCQLPathElement

### Description
`DCQL 클레임 경로의 한 단계 — 객체 멤버, 배열 인덱스, 또는 와일드카드.`

### Declaration
```swift
public enum DCQLPathElement: Codable, Hashable, Sendable {
    case key(String)
    case index(Int)
    case wildcard
}
```

### Property
| Value          | Description         | **Note**                  |
|----------------|---------------------|---------------------------|
| key(String)    | 객체 멤버 이름       | JSON 문자열로 인코딩       |
| index(Int)     | 배열 인덱스          | JSON 숫자로 인코딩         |
| wildcard       | 배열의 모든 원소     | JSON `null`로 인코딩       |

<br>

## 9. MatchedCredential

### Description
`하나의 DCQL 크리덴셜 쿼리에 대해 매칭된 크리덴셜 한 건.`

`matchCredentials`가 반환하고 `createVpToken`에 그대로 전달한다. 앱은 홀더가 거부한 항목을 빼거나
public 이니셜라이저로 목록을 다시 구성할 수 있지만, 항목의 `claimCodes`를 좁혀서는 안 된다.

### Declaration
```swift
public struct MatchedCredential
{
    public let queryId: String
    public let credentialId: String
    public let claimCodes: [String]
}
```

### Property
| Name         | Type     | Description                              | **M/O** | **Note** |
|--------------|----------|------------------------------------------|---------|----------|
| queryId      | String   | 이 매칭이 답하는 DCQL 크리덴셜 쿼리 id     | M       | `dcql_query.credentials[].id` |
| credentialId | String   | 매칭된 저장 크리덴셜 id                    | M       |          |
| claimCodes   | [String] | 공개할 클레임. 쿼리가 요구한 클레임이거나, 크리덴셜 전체를 요구했다면 공개 가능한 모든 클레임 | M | 불투명 값이다. 표시·대조에만 쓰고 쪼개거나 조립하지 않는다 |

<br>

## 10. MdocRequestedDocument

### Description
`ISO/IEC 18013-5 근접 제출 요청의 매칭 한 건: 요청된 문서와, 그 element 중 하나 이상을 채울 수 있는 저장 문서.`

`matchMdocRequest` 가 반환하고, 편집한 뒤 `createDeviceResponse` 에 되돌려준다. 요청된 element 를
전부 채울 필요는 없다 — 채우지 못하는 것은 `missing` 에 담긴다. 앱은 element 를 빼려면
`claimCodes` 에서 코드를, 문서를 빼려면 항목 자체를 덜어낸다. 리더가 요청하지 않은 element 를
더하려면 그 문서의 [MdocCredentialItem](#14-mdoccredentialitem)`.consentItems` 에서 코드를 가져와
덧붙인다. 더할지는 홀더가 정한다.

### Declaration
```swift
public struct MdocRequestedDocument
{
    public let docRequestIndex: Int
    public let docType: String
    public let credentialId: String
    public let claimCodes: [String]
    public let intentToRetain: [String: Bool]
    public let missing: [String]

    public init(docRequestIndex: Int, docType: String, credentialId: String,
                claimCodes: [String], intentToRetain: [String: Bool], missing: [String])
}
```

### Property
| Name            | Type           | Description                                                        | **M/O** | **Note** |
|-----------------|----------------|--------------------------------------------------------------------|---------|----------|
| docRequestIndex | Int            | 이 항목이 답하는 `DeviceRequest.docRequests` 의 0 기반 인덱스        | M       | `docType` 으로는 요청을 식별할 수 없다. 리더가 같은 타입을 다른 element 로 두 번 요청할 수 있다 |
| docType         | String         | 요청된 `ItemsRequest.docType`                                       | M       |          |
| credentialId    | String         | 요청된 element 를 하나 이상 채울 수 있는 저장 문서                    | M       | [MdocCredentialItem](#14-mdoccredentialitem)`.id` 와 같은 값 |
| claimCodes      | [String]       | 공개할 element, 코드 형태                                            | M       | 불투명 값이다. element 를 빼려면 코드를 빼고, 요청 밖 element 를 더하려면 `consentItems` 의 코드를 덧붙인다. 쪼개거나 조립하지 않는다 |
| intentToRetain  | [String: Bool] | 코드별 리더의 보관 의도. `claimCodes` 와 `missing` 을 합친 범위        | M       | 출력 전용. `createDeviceResponse` 는 읽지 않는다 |
| missing         | [String]       | 이 문서가 채울 수 없는 요청 element, 같은 코드 형태                    | M       | 보유하지 않은 element 와, 모호한 코드로 보유한 element 를 포함 |

<br>

## 11. MdocDeviceResponse

### Description
`생성된 DeviceResponse 와, 그 안의 문서 각각이 어떤 방식으로 인증됐는지.`

### Declaration
```swift
public struct MdocDeviceResponse
{
    public let response: Data
    public let authMethods: [String: MdocDeviceAuthMethod]

    public init(response: Data, authMethods: [String: MdocDeviceAuthMethod])
}
```

### Property
| Name        | Type                           | Description                                     | **M/O** | **Note** |
|-------------|--------------------------------|-------------------------------------------------|---------|----------|
| response    | Data                           | `DeviceResponse` CBOR, **평문**                  | M       | 전송 SDK 가 암호화해서 보낸다 |
| authMethods | [String: MdocDeviceAuthMethod] | `credentialId` → 그 문서에 실제 사용한 인증 방식   | M       | [MdocDeviceAuthMethod](#111-mdocdeviceauthmethod). 한 응답에 같은 doctype 이 두 번 실릴 수 있어 크리덴셜 기준 |

<br>

## 11.1. MdocDeviceAuthMethod

### Description
`DeviceResponse 안의 문서 하나가 인증된 방식.`

### Declaration
```swift
public enum MdocDeviceAuthMethod: String, Sendable
{
    case deviceSignature
    case deviceMac
}
```

### Property
| Value           | Description                                                 | **Note** |
|-----------------|-------------------------------------------------------------|----------|
| deviceSignature | 문서의 기기 키로 만든 ECDSA 서명                             | 키가 키 합의를 못 하거나 transcript 에 리더 키가 없을 때 |
| deviceMac       | 리더 임시 키와의 ECDH 로 유도한 `EMacKey` 로 만든 HMAC        | 기기 키가 키 합의를 할 수 있으면 우선 사용 |

<br>

## 12. IssuerMetadataResponse

### Description
`발급자의 OpenID4VCI 메타데이터 — 엔드포인트와 발급 가능한 크리덴셜 목록.`

`requestIssueOID4VC`에 전달한다.

### Declaration
```swift
public struct IssuerMetadataResponse: Jsonable, FromSnake
{
    public let credentialIssuer: String
    public let authorizationServers: [String]?
    public let credentialOfferEndpoint: String?
    public let credentialEndpoint: String
    public let tokenEndpoint: String?
    public let nonceEndpoint: String?
    public let deferredCredentialEndpoint: String?
    public let notificationEndpoint: String?
    public let credentialRequestEncryption: EncryptionSupport?
    public let credentialResponseEncryption: EncryptionSupport?
    public let credentialIdentifiersSupported: Bool?
    public let credentialConfigurationsSupported: [String: CredentialConfiguration]
}
```

### Property
| Name                              | Type                              | Description                          | **M/O** | **Note** |
|-----------------------------------|-----------------------------------|--------------------------------------|---------|----------|
| credentialIssuer                  | String                            | 발급자 식별자                         | M       |          |
| authorizationServers              | [String]                          | 발급자가 신뢰하는 인가 서버            | O       |          |
| credentialOfferEndpoint           | String                            | credential offer 엔드포인트           | O       |          |
| credentialEndpoint                | String                            | credential 엔드포인트                 | M       |          |
| tokenEndpoint                     | String                            | token 엔드포인트                      | O       |          |
| nonceEndpoint                     | String                            | nonce 엔드포인트                      | O       |          |
| deferredCredentialEndpoint        | String                            | deferred credential 엔드포인트        | O       |          |
| notificationEndpoint              | String                            | notification 엔드포인트               | O       |          |
| credentialRequestEncryption       | EncryptionSupport                 | 발급자가 광고하는 요청 암호화          | O       | [EncryptionSupport](#122-encryptionsupport) |
| credentialResponseEncryption      | EncryptionSupport                 | 발급자가 광고하는 응답 암호화          | O       | [EncryptionSupport](#122-encryptionsupport) |
| credentialIdentifiersSupported    | Bool                              | `credential_identifier` 사용 여부     | O       |          |
| credentialConfigurationsSupported | [String: CredentialConfiguration] | 발급 가능한 크리덴셜. 키는 `credential_configuration_id` | M | [CredentialConfiguration](#121-credentialconfiguration) |

<br>

## 12.1. CredentialConfiguration

### Description
`발급자가 제공하는 크리덴셜 한 종류.`

### Declaration
```swift
public struct CredentialConfiguration: Jsonable, FromSnake
{
    public let format: SupportedFormat
    public let scope: String?
    public let cryptographicBindingMethodsSupported: [String]?
    public let credentialSigningAlgValuesSupported: [SigningAlg]?
    public let proofTypesSupported: [String: ProofSupport]?
    public let vct: String?
    public let doctype: String?
    public let policy: CredentialPolicy?
    public let credentialMetadata: CredentialMetadata?
}
```

### Property
| Name                                 | Type                     | Description                | **M/O** | **Note** |
|--------------------------------------|--------------------------|----------------------------|---------|----------|
| format                               | SupportedFormat          | 크리덴셜 형식               | M       | [SupportedFormat](#128-supportedformat) |
| scope                                | String                   | 이 크리덴셜의 OAuth scope   | O       |          |
| cryptographicBindingMethodsSupported | [String]                 | 지원하는 홀더 바인딩 방식    | O       |          |
| credentialSigningAlgValuesSupported  | [SigningAlg]             | 발급자 서명 알고리즘         | O       | [SigningAlg](#129-signingalg) |
| proofTypesSupported                  | [String: ProofSupport]   | 허용하는 홀더 proof 타입     | O       | [ProofSupport](#126-proofsupport) |
| vct                                  | String                   | SD-JWT VC 타입              | O       |          |
| doctype                              | String                   | mdoc doctype                | O       |          |
| policy                               | CredentialPolicy         | 배치·1회용 정책              | O       | [CredentialPolicy](#123-credentialpolicy) |
| credentialMetadata                   | CredentialMetadata       | 클레임·표시 정보             | O       | [CredentialMetadata](#124-credentialmetadata) |

<br>

## 12.2. EncryptionSupport

### Description
`발급자가 광고하는 암호화 — Wallet이 실제로 보내는 것이 아니다.`

### Declaration
```swift
public struct EncryptionSupport: Jsonable, FromSnake
{
    public let algValuesSupported: [String]?
    public let encValuesSupported: [String]?
    public let encryptionRequired: Bool?
}
```

### Property
| Name               | Type     | Description                | **M/O** | **Note** |
|--------------------|----------|----------------------------|---------|----------|
| algValuesSupported | [String] | 지원하는 키 합의 알고리즘    | O       |          |
| encValuesSupported | [String] | 지원하는 콘텐츠 암호화 알고리즘 | O     |          |
| encryptionRequired | Bool     | 암호화 필수 여부             | O       |          |

<br>

## 12.3. CredentialPolicy

### Description
`크리덴셜 구성의 발급 정책.`

### Declaration
```swift
public struct CredentialPolicy: Jsonable, FromSnake
{
    public let batchSize: Int?
    public let oneTimeUse: Bool?
}
```

### Property
| Name       | Type | Description                    | **M/O** | **Note** |
|------------|------|--------------------------------|---------|----------|
| batchSize  | Int  | 한 번에 발급되는 사본 수         | O       |          |
| oneTimeUse | Bool | 사본당 1회만 제출 가능한지       | O       |          |

<br>

## 12.4. CredentialMetadata

### Description
`크리덴셜 구성의 클레임·표시 정보.`

### Declaration
```swift
public struct CredentialMetadata: Codable, Sendable {
    public let claims: [ClaimDetail]?
    public let display: [DisplayInfo]?
}
```

### Property
| Name    | Type          | Description                 | **M/O** | **Note** |
|---------|---------------|-----------------------------|---------|----------|
| claims  | [ClaimDetail] | 이 크리덴셜이 담는 클레임     | O       | [ClaimDetail](#127-claimdetail) |
| display | [DisplayInfo] | 로케일별 표시 방법           | O       | [DisplayInfo](#125-displayinfo) |

<br>

## 12.5. DisplayInfo

### Description
`한 로케일에서 크리덴셜 또는 클레임을 표시하는 방법.`

### Declaration
```swift
public struct DisplayInfo: Jsonable, FromSnake
{
    public let name: String?
    public let logo: LogoInfo?
    public let locale: String?
    public let backgroundColor: String?
    public let textColor: String?
}
```

### Property
| Name            | Type     | Description        | **M/O** | **Note** |
|-----------------|----------|--------------------|---------|----------|
| name            | String   | 표시 이름           | O       |          |
| logo            | LogoInfo | 로고 이미지         | O       | [LogoInfo](#1251-logoinfo) |
| locale          | String   | BCP 47 로케일 태그  | O       |          |
| backgroundColor | String   | 배경색             | O       |          |
| textColor       | String   | 글자색             | O       |          |

<br>

## 12.5.1. LogoInfo

### Description
`표시 항목의 로고 이미지.`

### Declaration
```swift
public struct LogoInfo: Jsonable, FromSnake
{
    public let uri: String?
    public let altText: String?
}
```

### Property
| Name    | Type   | Description   | **M/O** | **Note** |
|---------|--------|---------------|---------|----------|
| uri     | String | 이미지 URI     | O       |          |
| altText | String | 대체 텍스트    | O       |          |

<br>

## 12.6. ProofSupport

### Description
`한 proof 타입에 대해 발급자가 허용하는 홀더 proof 알고리즘.`

### Declaration
```swift
public struct ProofSupport: Jsonable, FromSnake
{
    public let proofSigningAlgValuesSupported: [String]?
}
```

### Property
| Name                           | Type     | Description             | **M/O** | **Note** |
|--------------------------------|----------|-------------------------|---------|----------|
| proofSigningAlgValuesSupported | [String] | 허용하는 proof 서명 알고리즘 | O     |          |

<br>

## 12.7. ClaimDetail

### Description
`발급 가능한 크리덴셜의 클레임 한 건. 발급자가 기술한 내용이다.`

### Declaration
```swift
public struct ClaimDetail: Jsonable, FromSnake
{
    public let display: [DisplayInfo]?
    public let mandatory: Bool?
    public let path: [String]?
    public let valueType: String?
}
```

### Property
| Name      | Type          | Description                | **M/O** | **Note** |
|-----------|---------------|----------------------------|---------|----------|
| display   | [DisplayInfo] | 로케일별 클레임 라벨         | O       | [DisplayInfo](#125-displayinfo) |
| mandatory | Bool          | 발급자가 항상 포함하는지     | O       |          |
| path      | [String]      | 크리덴셜 내 클레임 경로      | O       |          |
| valueType | String        | 값 타입 힌트                | O       |          |

<br>

## 12.8. SupportedFormat

### Description
`크리덴셜 형식 토큰. 발급자의 원본 문자열을 보존해 그대로 재전송할 수 있다.`

### Declaration
```swift
public enum SupportedFormat: Jsonable, Equatable
{
    case sdjwt(String)
    case mdoc(String)
    case unknown(String)

    public var rawValue: String { get }
}
```

### Property
| Value           | Description                  | **Note**                     |
|-----------------|------------------------------|------------------------------|
| sdjwt(String)   | `dc+sd-jwt-did`에서 디코딩    | `rawValue`가 원본 토큰을 반환 |
| mdoc(String)    | `mso-mdoc-did`에서 디코딩     |                              |
| unknown(String) | 그 밖의 형식 토큰             | 거부하지 않고 보존            |

<br>

## 12.9. SigningAlg

### Description
`발급자가 문자열 또는 숫자로 게시할 수 있는 서명 알고리즘 값.`

### Declaration
```swift
public enum SigningAlg: Codable, Sendable {
    case string(String)
    case int(Int)
}
```

### Property
| Value          | Description                  | **Note** |
|----------------|------------------------------|----------|
| string(String) | JSON 문자열로 게시된 알고리즘  | 예: `"ES256"` |
| int(Int)       | JSON 숫자로 게시된 알고리즘    | 예: COSE 알고리즘 id |

<br>

## 13. CredentialOfferResponse

### Description
`발급자의 credential offer — 발급자 주도 발급에서 Wallet이 받는 값.`

### Declaration
```swift
public struct CredentialOfferResponse: Jsonable, FromSnake
{
    public var credentialIssuer: String
    public var credentialConfigurationIds: [String]?
    public var grants: Grants
}
```

### Property
| Name                       | Type     | Description                    | **M/O** | **Note** |
|----------------------------|----------|--------------------------------|---------|----------|
| credentialIssuer           | String   | 발급자 식별자                   | M       |          |
| credentialConfigurationIds | [String] | 제공되는 크리덴셜               | O       |          |
| grants                     | Grants   | 이 offer로 토큰을 얻는 방법     | M       | [Grants](#131-grants) |

<br>

## 13.1. Grants

### Description
`offer가 지원하는 grant 타입.`

### Declaration
```swift
public struct Grants: Jsonable
{
    public let preAuthorizedCode: PreAuthorizedCode?
    public let authorizationCode: AuthorizationCode?
}
```

### Property
| Name              | Type              | Description             | **M/O** | **Note** |
|-------------------|-------------------|-------------------------|---------|----------|
| preAuthorizedCode | PreAuthorizedCode | pre-authorized code grant | O     | [PreAuthorizedCode](#132-preauthorizedcode). 전송 키는 `urn:ietf:params:oauth:grant-type:pre-authorized_code` |
| authorizationCode | AuthorizationCode | authorization code grant  | O     | [AuthorizationCode](#134-authorizationcode) |

<br>

## 13.2. PreAuthorizedCode

### Description
`credential offer의 pre-authorized code grant.`

### Declaration
```swift
public struct PreAuthorizedCode: Jsonable
{
    public let preAuthorizedCode: String
    public let txCode: TxCode?
}
```

### Property
| Name              | Type   | Description                  | **M/O** | **Note** |
|-------------------|--------|------------------------------|---------|----------|
| preAuthorizedCode | String | pre-authorized code          | M       | 전송 키는 `pre-authorized_code` |
| txCode            | TxCode | 홀더가 입력해야 할 거래 코드   | O       | [TxCode](#133-txcode) |

<br>

## 13.3. TxCode

### Description
`발급자가 거래 코드를 요구할 때, 홀더가 어떻게 입력해야 하는지.`

### Declaration
```swift
public struct TxCode: Jsonable
{
    public let inputMode: String?
    public let length: Int?
    public let description: String?
}
```

### Property
| Name        | Type   | Description             | **M/O** | **Note** |
|-------------|--------|-------------------------|---------|----------|
| inputMode   | String | 입력 방식. 예: `numeric` | O       |          |
| length      | Int    | 기대 길이                | O       |          |
| description | String | 홀더에게 보여줄 안내      | O       |          |

<br>

## 13.4. AuthorizationCode

### Description
`credential offer의 authorization code grant.`

### Declaration
```swift
public struct AuthorizationCode: Jsonable
{
    public let issuerState: String?
}
```

### Property
| Name        | Type   | Description                    | **M/O** | **Note** |
|-------------|--------|--------------------------------|---------|----------|
| issuerState | String | 인가 과정에 이어 전달할 발급자 state | O    |          |

<br>

## 14. TokenRequest

### Description
`pre-authorized code grant에서 Wallet이 보내는 토큰 요청.`

### Declaration
```swift
public struct TokenRequest: Jsonable, FromSnake
{
    public var grantType: String = "urn:ietf:params:oauth:grant-type:pre-authorized_code"
    public var preAuthorizedCode: String
    public var txCode: String?
    public var authorizationDetails: [AuthorizationDetails]

    public init(preAuthorizedCode: String, txCode: String?, authorizationDetails: [AuthorizationDetails])
}
```

### Property
| Name                 | Type                   | Description                 | **M/O** | **Note** |
|----------------------|------------------------|-----------------------------|---------|----------|
| grantType            | String                 | grant 타입                   | M       | pre-authorized code grant로 고정 |
| preAuthorizedCode    | String                 | credential offer에서 받은 코드 | M      | `pre-authorized_code`로 인코딩 |
| txCode               | String                 | 홀더가 입력한 거래 코드       | O       |          |
| authorizationDetails | [AuthorizationDetails] | 토큰이 대상으로 하는 크리덴셜  | M       | [AuthorizationDetails](#16-authorizationdetails) |

<br>

## 15. TokenResponse

### Description
`발급자의 토큰 응답. requestIssueOID4VC에 전달한다.`

### Declaration
```swift
public struct TokenResponse: Jsonable, FromSnake
{
    public let accessToken: String
    public let tokenType: String
    public let cNonce: String?
    public let expiresIn: Int?
    public let authorizationDetails: [AuthorizationDetails]?
}
```

### Property
| Name                 | Type                   | Description                       | **M/O** | **Note** |
|----------------------|------------------------|-----------------------------------|---------|----------|
| accessToken          | String                 | credential 엔드포인트용 액세스 토큰 | M      |          |
| tokenType            | String                 | 토큰 타입. 예: `Bearer`            | M       |          |
| cNonce               | String                 | 홀더 proof에 바인딩할 nonce        | O       |          |
| expiresIn            | Int                    | 토큰 수명(초)                      | O       |          |
| authorizationDetails | [AuthorizationDetails] | 토큰이 포함하는 credential identifier | O    | [AuthorizationDetails](#16-authorizationdetails) |

<br>

## 16. AuthorizationDetails

### Description
`토큰 요청·응답이 어떤 크리덴셜 구성에 해당하는지.`

### Declaration
```swift
public struct AuthorizationDetails: Jsonable, FromSnake
{
    public var type: String = "openid_credential"
    public var credentialConfigurationId: String
    public var credentialIdentifiers: [String]?

    public init(credentialConfigurationId: String, credentialIdentifiers: [String]?)
}
```

### Property
| Name                      | Type     | Description                            | **M/O** | **Note** |
|---------------------------|----------|----------------------------------------|---------|----------|
| type                      | String   | detail 타입                             | M       | `openid_credential`로 고정 |
| credentialConfigurationId | String   | 해당하는 크리덴셜 구성                   | M       |          |
| credentialIdentifiers     | [String] | 그 구성 안에서 발급자가 부여한 식별자     | O       | 이 중 하나를 `requestIssueOID4VC(credentialIdentifier:)`로 넘긴다 |

<br>

## 17. OID4VCIIssuerList

### Description
`Wallet이 발급을 시작할 수 있는 OID4VCI 발급자 목록.`

전송 형식이 camelCase다(snake_case인 OID4VCI 규격이 아니라 OmniOne 서버 API). 그래서 다른 OID4VCI
DTO와 달리 이 모델은 `FromSnake`가 아니다.

### Declaration
```swift
public struct OID4VCIIssuerList: Jsonable
{
    public var count: Int
    public var items: [OID4VCIIssuerItem]

    public init(count: Int, items: [OID4VCIIssuerItem])
}
```

### Property
| Name  | Type                | Description       | **M/O** | **Note** |
|-------|---------------------|-------------------|---------|----------|
| count | Int                 | `items`의 항목 수  | M       |          |
| items | [OID4VCIIssuerItem] | 발급자 항목들      | M       | [OID4VCIIssuerItem](#171-oid4vciissueritem) |

<br>

## 17.1. OID4VCIIssuerItem

### Description
`OID4VCI 발급자 항목 하나 — 식별자와 발급 시작에 필요한 엔드포인트.`

### Declaration
```swift
public struct OID4VCIIssuerItem: Jsonable
{
    public var credentialIssuer: String
    public var credentialIssuerMetadataUri: String
    public var userInitiationUri: String?

    public init(credentialIssuer: String, credentialIssuerMetadataUri: String, userInitiationUri: String?)
}
```

### Property
| Name                        | Type   | Description                                 | **M/O** | **Note** |
|-----------------------------|--------|---------------------------------------------|---------|----------|
| credentialIssuer            | String | 발급자 식별자                                | M       | 발급자 메타데이터의 `credential_issuer`와 일치 |
| credentialIssuerMetadataUri | String | 이 발급자의 `IssuerMetadataResponse` 조회 위치 | M      | [IssuerMetadataResponse](#12-issuermetadataresponse) |
| userInitiationUri           | String | Wallet 주도 발급을 시작하는 위치              | O       | 발급자 주도 offer만 지원하는 발급자에는 없다 |

<br>

## 18. AnyJSON

### Description
`규격이 임의의 JSON을 허용하는 자리에 쓰이는 무손실 JSON 값 컨테이너.`

### Declaration
```swift
public enum AnyJSON: Codable, Equatable, Hashable, Sendable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([AnyJSON])
    case object([String: AnyJSON])

    public var asBool: Bool? { get }
    public var asDouble: Double? { get }
    public var asString: String? { get }
    public var asArray: [AnyJSON]? { get }
    public var asObject: [String: AnyJSON]? { get }
    public func toFoundation() -> Any
}
```

### Property
| Value                     | Description   | **Note**                |
|---------------------------|---------------|-------------------------|
| null                      | JSON `null`   |                         |
| bool(Bool)                | JSON 불리언    |                         |
| number(Double)            | JSON 숫자      | 항상 `Double`로 보관     |
| string(String)            | JSON 문자열    |                         |
| array([AnyJSON])          | JSON 배열      |                         |
| object([String: AnyJSON]) | JSON 객체      |                         |

### Method
| Name             | Description                                        | **Note** |
|------------------|----------------------------------------------------|----------|
| asBool / asDouble / asString / asArray / asObject | 해당 case일 때 값을 읽고, 아니면 `nil` | |
| toFoundation()   | `JSONSerialization`용 Foundation 타입으로 변환      | `null`은 `NSNull()`이 된다 |

<br>

# OptionSet
## 1. VerifyAuthType

### Description

`key 및 VP 제출 옵션에 대한 엑세스 방법 (AuthType과 유사)`

### Declaration

```cpp
public struct VerifyAuthType : OptionSet, Sequence, Codable
{
    public let rawValue: Int
    
    public static let free = VerifyAuthType(rawValue: 1 << 0)
    public static let pin  = VerifyAuthType(rawValue: 1 << 1)
    public static let bio  = VerifyAuthType(rawValue: 1 << 2)
    
    public static let and  = VerifyAuthType(rawValue: 1 << 15)
}
```

<br>

# Enumerators

## 1. DIDKeyType

### Description

`DID 키 유형`

### Declaration

```swift
// Declaration in Swift
public enum DIDKeyType : String, Codable, AlgorithmTypeConvertible
{
    public static var commonString: String
    {
        "VerificationKey2018"
    }
   
    case rsaVerificationKey2018        = "RsaVerificationKey2018"
    case secp256k1VerificationKey2018  = "Secp256k1VerificationKey2018"
    case secp256r1VerificationKey2018  = "Secp256r1VerificationKey2018"
}
```

<br>

## 2. DIDServiceType

### Description

`서비스 유형`

### Declaration

```swift
// Declaration in Swift
public enum DIDServiceType : String, Codable
{
    case linkedDomains      = "LinkedDomains"
    case credentialRegistry = "CredentialRegistry"
}
```

<br>

## 3. ProofPurpose

### Description

`증명 목적`

### Declaration

```swift
public enum ProofPurpose : String, Codable
{
    case assertionMethod      = "assertionMethod"
    case authentication       = "authentication"
    case keyAgreement         = "keyAgreement"
    case capabilityInvocation = "capabilityInvocation"
    case capabilityDelegation = "capabilityDelegation"
}
```

<br>

## 4. ProofType

### Description

`증명 타입`

### Declaration

```swift
public enum ProofType : String, Codable, AlgorithmTypeConvertible
{
    public static var commonString: String
    {
        "Signature2018"
    }
    
    case rsaSignature2018       = "RsaSignature2018"
    case secp256k1Signature2018 = "Secp256k1Signature2018"
    case secp256r1Signature2018 = "Secp256r1Signature2018"
}
```

<br>

## 5. AuthType

### Description

`Key에 대한 접근 방법 표시`

### Declaration

```swift
// Declaration in Swift
public enum AuthType : Int, Codable
{
    case free = 1
    case pin  = 2
    case bio  = 4
}
```

<br>

## 6. Evidence

### Description

`다중 유형 배열에 대한 증거 열거자`

### Declaration

```swift
// Declaration in Swift
public enum Evidence
{
    case documentVerification(DocumentVerificationEvidence)
}
```

<br>

## 7. Presence

### Description

`존재 유형`

### Declaration

```swift
// Declaration in Swift
public enum Presence : String, Codable
{
    case physical = "Physical"
    case digital  = "Digital"
}
```

<br>

## 8. EvidenceType

### Description

`증거 유형`

### Declaration

```swift
// Declaration in Swift
public enum EvidenceType : String, Codable
{
    case documentVerification = "DocumentVerification"
}
```

<br>

## 9. ProfileType

### Description

`프로파일 유형`

### Declaration

```swift
// Declaration in Swift
public enum ProfileType : String, Codable
{
    case IssueProfile
    case VerifyProfile
    case ProofRequestProfile
}
```

<br>

## 10. LogoImageType

### Description

`로고 이미지 유형`

### Declaration

```swift
// Declaration in Swift
public enum LogoImageType : String, Codable
{
    case jpg
    case png
}
```

<br>

## 11. ClaimType

### Description

`클래임 유형`

### Declaration

```swift
// Declaration in Swift
public enum ClaimType : String, Codable
{
    case text
    case image
    case document
}
```

<br>

## 12. ClaimFormat

### Description

`클래임 포맷`

### Declaration

```swift
// Declaration in Swift
public enum ClaimFormat : String, Codable
{
    //text
    case plain
    case html
    case xml
    case csv
    //image
    case png
    case jpg
    case gif
    //document
    case txt
    case pdf
    case word
}
```

<br>

## 13. Location

### Description

`값 위치`

### Declaration

```swift
// Declaration in Swift
public enum Location : String, Codable
{
    case inline
    case remote
    case attach
}
```

<br>

## 14. SymmetricPaddingType

### Description

`패딩 옵션`

### Declaration

```swift
// Declaration in Swift
public enum SymmetricPaddingType : String , Codable
{
    case noPad = "NOPAD"
    case pkcs5 = "PKCS5"
}
```

<br>

## 15. SymmetricCipherType

### Description

`암호화 종류`

### Declaration

```swift
// Declaration in Swift
public enum SymmetricCipherType : String, Codable
{
    case aes128CBC = "AES-128-CBC"
    case aes128ECB = "AES-128-ECB"
    case aes256CBC = "AES-256-CBC"
    case aes256ECB = "AES-256-ECB"
}
```

<br>

## 16. AlgorithmType

### Description

`알고리즘 종류`

### Declaration

```swift
// Declaration in Swift
public enum AlgorithmType : String, Codable
{
    case rsa       = "Rsa"
    case secp256k1 = "Secp256k1"
    case secp256r1 = "Secp256r1"
}
```

<br>

## 17. CredentialSchemaType

### Description

`Credential schema 유형`

### Declaration

```swift
// Declaration in Swift
public enum CredentialSchemaType : String, Codable
{
    case osdSchemaCredential = "OsdSchemaCredential"
}
```

<br>

## 18. OfferTypeEnum

### Description
`오퍼 유형의 열거`

### Declaration
```swift
public enum OfferTypeEnum: String, Codable {
    case IssueOffer
    case VerifyOffer
    case RestoreDidOffer
    case ZkpIssueOffer
    case VerifyProofOffer
}
```
<br>


## 19. RoleTypeEnum

### Description

`다양한 역할 유형에 대한 열거`

### Declaration

```swift
public enum RoleTypeEnum: String, Jsonable {
    case Tas = "Tas"
    case Wallet = "Wallet"
    case Issuer = "Issuer"
    case Verifier = "Verifier"
    case WalletProvider = "WalletProvider"
    case CAS_SERVICE = "AppProvider"
    case ListProvider = "ListProvider"
    case OpProvider = "OpProvider"
    case KycProvider = "KycProvider"
    case NotificationProvider = "NotificationProvider"
    case LogProvider = "LogProvider"
    case PortalProvider = "PortalProvider"
    case DelegationProvider = "DelegationProvider"
    case StorageProvider = "StorageProvider"
    case BackupProvider = "BackupProvider"
    case Etc = "Etc"
}
```
<br>

## 20. ServerTokenPurposeEnum

### Description
`다양한 서버 토큰 목적을 위한 열거`

### Declaration
```swift
public enum ServerTokenPurposeEnum: Int, Jsonable {
    case CREATE_DID = 5
    case UPDATE_DID = 6
    case RESTORE_DID = 7
    case ISSUE_VC = 8
    case REMOVE_VC = 9
    case PRESENT_VP = 10
    case LIST_VC
    case DETAIL_VC
    case CREATE_DID_AND_ISSUE_VC
}
```

<br>

## 21. WalletTokenPurposeEnum

### Description
`다양한 월렛 토큰 목적을 위한 열거`

### Declaration
```swift
public enum WalletTokenPurposeEnum: Int, Jsonable {
    case PERSONALIZED               = 1
    case DEPERSONALIZED             = 2
    case PERSONALIZE_AND_CONFIGLOCK = 3
    case CONFIGLOCK                 = 4
    case CREATE_DID                 = 5
    case UPDATE_DID                 = 6
    case RESTORE_DID                = 7
    case ISSUE_VC                   = 8
    case REMOVE_VC                  = 9
    case PRESENT_VP                 = 10
    case LIST_VC                    = 11
    case DETAIL_VC                  = 12
    case CREATE_DID_AND_ISSUE_VC    = 13
    case LIST_VC_AND_PRESENT_VP     = 14
}
```
<br>

# Protocols

## 1. Jsonable

### Description

`모델에서 Json으로(직렬화), 그반대 (역직렬화)`

### Declaration

```swift
// Declaration in Swift
public protocol Jsonable : Codable
{
    init(from jsonData: Data) throws
    init(from jsonString: String) throws
    func toJsonData(isPretty: Bool) throws -> Data
    func toJson(isPretty: Bool) throws -> String
}
```

<br>

## 2. ProofProtocol

### Description

`증명 프로토콜`

### Declaration

```swift
// Declaration in Swift
public protocol ProofProtocol : Jsonable
{
    var created : String { get set }
    var verificationMethod : String { get set }
    var proofPurpose : ProofPurpose { get set }
    var type : ProofType? { get set }
    var proofValue : String? { get set }
}
```

<br>

## 2.1. ProofContainer

### Description

`증명 컨테이너`

### Declaration

```swift
// Declaration in Swift
public protocol ProofContainer : Jsonable
{
    var proof : Proof? { get set }
}
```

<br>

## 2.2. ProofsContainer

### Description

`다중 증명 컨테이너`

### Declaration

```swift
// Declaration in Swift
public protocol ProofsContainer : Jsonable
{
    var proof  : Proof? { get set }
    var proofs : [Proof]? { get set }
}
```

<br>

## 3. ConvertibleToAlgorithmType

### Description

`알고리즘타입 프로토콜 변환 가능`

### Declaration

```swift
// Declaration in Swift
public protocol ConvertibleToAlgorithmType : RawRepresentable where RawValue == String
{
    static var commonString : String { get }
    /// Convert to AlgorithmType
    ///
    /// - Returns: AlgorithmType
    func convertTo() -> AlgorithmType
}
```

<br>

## 4. ConvertibleFromAlgorithmType

### Description

`AlgorithmType 프로토콜에서 변환 가능`

### Declaration

```swift
// Declaration in Swift
public protocol ConvertibleFromAlgorithmType : RawRepresentable where RawValue == String
{
    static var commonString : String { get }
    
    /// Convert from AlgorithmType
    ///
    /// - Parameters:
    ///   - algorithmType: AlgorithmType value
    /// - Returns: Self type value
    static func convertFrom(algorithmType : AlgorithmType) -> Self
}
```

<br>

## 5. AlgorithmTypeConvertible

### Description

`AlgorithmType 프로토콜에서 변환 가능(직렬화), 그 반대(역직렬화)`

### Declaration

```swift
// Declaration in Swift
public typealias AlgorithmTypeConvertible = ConvertibleToAlgorithmType & ConvertibleFromAlgorithmType
```

<br>

# Property Wrapper

## 1. @UTCDatetime

### Description

`TBD`

### Declaration

```swift
// Declaration in Swift
@UTCDatetime
```

<br>

## 2. @DIDVersionId

### Description

`TBD`

### Declaration

```swift
// Declaration in Swift
@DIDVersionId
```


<br>


    


