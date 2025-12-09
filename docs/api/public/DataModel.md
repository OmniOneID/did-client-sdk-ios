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
- Writer: JooHyun Park
- Date: 2025-05-27
- Version: v1.0.1

| Version          | Date       | History                 |
| ---------------- | ---------- | ------------------------|
| v1.0.1           | 2025-05-27 | Add ZKP-related models  |
| v1.0.0           | 2024-08-28 | Initial                 |


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
            - [1.2.5. CredInfo](#125-credinfo)
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

`Document for Decentralized Identifiers`

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
| id                   | String               | DID owner's did                        |    M    |   | 
| controller           | String               | DID controller's did                   |    M    |   | 
| verificationMethod   | [VerificationMethod] | List of DID key with public key value  |    M    | [VerificationMethod](#11-verificationmethod) | 
| assertionMethod      | [String]             | List of Assertion key name             |    O    |   | 
| authentication       | [String]             | List of Authentication key name        |    O    |   | 
| keyAgreement         | [String]             | List of Key Agreement key name         |    O    |   | 
| capabilityInvocation | [String]             | List of Capability Invocation key name |    O    |   | 
| capabilityDelegation | [String]             | List of Capability Delegation key name |    O    |   | 
| service              | [Service]            | List of service                        |    O    |[Service](#12-service)  | 
| created              |  String              | Created datetime                       |    M    |[@UTCDatetime](#1-utcdatetime)| 
| updated              |  String              | Updated datetime                       |    M    | [@UTCDatetime](#1-utcdatetime)| 
| versionId            |  String              | DID version id                         |    M    | [@DIDVersionId](#2-didversionid) | 
| deactivated          |  Bool                | True: deactivated, False: activated    |    M    |   | 
| proof                |  Proof               | Owner proof                            |    O    |[Proof](#4-proof)| 
| proofs               |  [Proof]             | List of owner proof                    |    O    |[Proof](#4-proof)| 

<br>

## 1.1. VerificationMethod

### Description

`Sub Model / List of DID key with public key value`

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
| id                 | String     | Key name                               |    M    |                       | 
| type               | DIDKeyType | Key type                               |    M    | [DIDKeyType](#1-didkeytype) | 
| controller         | String     | Key controller's did                   |    M    |                       | 
| publicKeyMultibase | String     | Public key value                       |    M    | Encoded by Multibase  | 
| authType           | AuthType   | Required authentication to use the key |    M    | [AuthType](#5-authtype) | 

<br>

## 1.2. Service

### Description

`Sub Model / List of service`

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
| id              | String         | Service id                 |    M    |                           | 
| type            | DIDServiceType | Service type               |    M    | [DIDServiceType](#2-didservicetype)| 
| serviceEndpoint | [String]       | List of URL to the service |    M    |                           | 

<br>

## 2. VerifiableCredential

### Description

`Decentralized digital certificate, hereafter VC`

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
| type              | [String]          | List of VC type                  |    M    |                             |
| issuer            | Issuer            | Issuer Information               |    M    | [Issuer](#21-issuer)         |
| issuanceDate      | String            | Issuance datetime                |    M    |                             |
| validFrom         | String            | This VC valid from the datetime  |    M    |                             |
| validUntil        | String            | This VC valid until the datetime |    M    |                             |
| encoding          | String            | VC encoding type                 |    M    | Default(UTF-8)              |
| formatVersion     | String            | VC format version                |    M    |                             |
| language          | String            | VC language code                 |    M    |                             |
| evidence          | [Evidence]        | Evidence                         |    M    | [Evidence](#6-evidence) <br> [DocumentVerificationEvidence](#22-documentverificationevidence) |
| credentialSchema  | CredentialSchema  | Credential schema                |    M    | [CredentialSchema](#23-credentialschema)                            |
| credentialSubject | CredentialSubject | Credential subject               |    M    | [CredentialSubject](#24-credentialsubject)                            |
| proof             | VCProof           | Issuer proof                     |    M    | [VCProof](#41-vcproof)                            |

<br>

## 2.1 Issuer

## Description

`Issuer information`

## Declaration

```swift
// Declaration in Swift
public struct Issuer : Jsonable
{
    public var id        : String
    public var name      : String?
}
```

## Property

| Name      | Type   | Description                       | **M/O** | **Note**                 |
|-----------|--------|-----------------------------------|---------|--------------------------|
| id        | String | Issuer's DID                      |    M    |                          |
| name      | String | Issuer's name                     |    O    |                          |

<br>

## 2.2 DocumentVerificationEvidence

## Description

`Document verification for Evidence`

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
| id               | String          | URL for the evidence information |    O    |                                |
| type             | EvidenceType    | Evidence type                    |    M    | [EvidenceType](#8-evidencetype)|
| verifier         | String          | Evidence verifier                |    M    |                                |
| evidenceDocument | String          | Name of Evidence document        |    M    |                                |
| subjectPresence  | Presence        | Subject presence type            |    M    | [Presence](#7-presence)        |
| documentPresence | Presence        | Document presence type           |    M    | [Presence](#7-presence)        |
| attribute        | [String:String] | Document attribute               |    O    |                                |

<br>

## 2.3 CredentialSchema

## Description

`Credential schema`

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

`Credential subject`

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
| id        | String  | Subject DID   |    M    |                          |
| claims    | [Claim] | List of claim |    M    | [Claim](#25-claim)           |

<br>

## 2.5 Claim

## Description

`Information for Subject`

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
| code      | String                       | Claim code                   |    M    |                          |
| caption   | String                       | Claim name                   |    M    |                          |
| value     | String                       | Claim value                  |    M    |                          |
| type      | ClaimType                    | Claim type                   |    M    | [ClaimType](#11-claimtype)         |
| format    | ClaimFormat                  | Claim format                 |    M    | [ClaimFormat](#12-claimformat)           |
| hideValue | Bool                         | Hide value                   |    O    | Default(false)           |
| location  | Location                     | Value Location               |    O    | Default(inline) <br> [Location](#13-location) |
| digestSRI | String                       | Digest Subresource Integrity |    O    |                          |
| i18n      |[String:Internationalization] | Internationalization         |    O    | [Internationalization](#26-internationalization) |

<br>

## 2.6 Internationalization

## Description

`Internationalization`

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
| caption   | String | Claim name                   |    M    |                          |
| value     | String | Claim value                  |    O    |                          |
| digestSRI | String | Digest Subresource Integrity |    O    | Hash value of the value  |

<br>

## 3. VerifiablePresentation

### Description

`A List of VCs signed with subject signatures, hereafter VP`

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
| type                 | [String]               | List of VP type                  |    M    |                          |
| holder               | String                 | Holder DID                       |    M    |                          |
| validFrom            | String                 | This VP valid from the datetime  |    M    |                          |
| validUntil           | String                 | This VP valid until the datetime |    M    |                          |
| verifierNonce        | String                 | Verifier nonce                   |    M    |                          |
| verifiableCredential | [VerifiableCredential] | List of VC                       |    M    | [VerifiableCredential](#2-verifiablecredential)   |
| proof                | Proof                  | Owner proof                      |    O    | [Proof](#4-proof) | 
| proofs               | [Proof]                | List of owner proof              |    O    | [Proof](#4-proof)    | 

<br>

## 4. Proof

### Description

`Owner proof`

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
| created            | String       | Created datetime                 |    M    | [@UTCDatetime](#1-utcdatetime)   | 
| proofPurpose       | ProofPurpose | Proof purpose                    |    M    | [ProofPurpose](#3-proofpurpose) | 
| verificationMethod | String       | Key URL used for Proof Signature |    M    |                          | 
| type               | ProofType    | Proof type                       |    M    | [ProofType](#4-prooftype)   |
| proofValue         | String       | Signature value                  |    O    |                          |

<br>

## 4.1 VCProof

### Description

`Issuer proof`

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
| created            | String       | Created datetime                 |    M    | [@UTCDatetime](#1-utcdatetime)             | 
| proofPurpose       | ProofPurpose | Proof purpose                    |    M    | [ProofPurpose](#3-proofpurpose)  | 
| verificationMethod | String       | Key URL used for Proof Signature |    M    |                          | 
| type               | ProofType    | Proof type                       |    M    | [ProofType](#4-prooftype)   |
| proofValue         | String       | Signature value                  |    O    |                          |
| proofValueList     | [String]     | Signature value List             |    O    |                          |

<br>

## 5. Profile

## 5.1 IssuerProfile

### Description

`Issuer Profile`

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
| id          | String      | Profile ID            |    M    |                          |
| type        | ProfileType | Profile type          |    M    | [ProfileType](#9-profiletype)    |
| title       | String      | Profile title         |    M    |                          |
| description | String      | Profile description   |    O    |                          |
| logo        | LogoImage   | Logo image            |    O    | [LogoImage](#53-logoimage)         |
| encoding    | String      | Profile encoding type |    M    |                          |
| language    | String      | Profile language code |    M    |                          |
| profile     | Profile     | Profile contents      |    M    | [Profle](#511-profile)           |
| proof       | Proof       | Owner proof           |    O    | [Proof](#4-proof)      |

<br>

## 5.1.1 Profile

### Description

`Profile contents`

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

| Name             | Type               | Description                 | **M/O** | **Note**                                    |
|------------------|--------------------|-----------------------------|---------|---------------------------------------------|
| issuer           | ProviderDetail     | Issuer information          |    M    | [ProviderDetail](#54-providerdetail)        |
| credentialSchema | CredentialSchema   | VC schema information       |    M    | [CredentialSchema](#5111-credentialschema)  |
| process          | Process            | Issuing process             |    M    | [Process](#5112-process)                    |
| credentialOffer  | ZKPCredentialOffer | ZKP Credential offer information |    O    | Refer to the ZKP_DataModel.md  |

<br>

## 5.1.1.1 CredentialSchema

### Description

`VC schema information`

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
| id    | String               | URL for VC schema     |    M    |                          |
| type  | CredentialSchemaType | VC schema format type |    M    | [CredentialSchemaType](#17-credentialschematype)      |
| value | String               | VC schema             |    O    | Encoded by Multibase     |

<br>

## 5.1.1.2 Process

### Description

`Issuing process`

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
| endpoints   | [String] | List of endpoint    |    M    |                          |
| reqE2e      | ReqE2e   | Request information |    M    | Proof not included <br> [ReqE2e](#55-reqe2e)     |
| issuerNonce | String   | Issuer nonce        |    M    |                          |

<br>

## 5.2 VerifyProfile

### Description

`Verify Profile`

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
| id          | String      | Profile ID            |    M    |                          |
| type        | ProfileType | Profile type          |    M    | [ProfileType](#9-profiletype)         |
| title       | String      | Profile title         |    M    |                          |
| description | String      | Profile description   |    O    |                          |
| logo        | LogoImage   | Logo image            |    O    |  [LogoImage](#53-logoimage)        |
| encoding    | String      | Profile encoding type |    M    |                          |
| language    | String      | Profile language code |    M    |                          |
| profile     | Profile     | Profile contents      |    M    | [Profile](#521-profile)      |
| proof       | Proof       | Owner proof           |    O    | [Proof](#4-proof)       |

<br>

## 5.2.1 Profile

### Description

`Profile contents`

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
| verifier | ProviderDetail | Verifier information       |    M    |  [ProviderDetail](#54-providerdetail)       |
| filter   | ProfileFilter  | Filtering for presentation |    M    | [ProfileFilter](#5211-profilefilter)          |
| process  | Process        | Method for VP presentation |    M    |[Process](#5212-process)       |

<br>

## 5.2.1.1 ProfileFilter

### Description

`Filtering for presentation`

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
| credentialSchemas | [CredentialSchema] | Presentable claim and issuer  per VC schema|    M    | [CredentialSchema](#52111-credentialschema)      |

<br>

## 5.2.1.1.1 CredentialSchema

### Description

`Presentable claim and issuer  per VC schema`

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

| Name           | Type                 | Description                                   | **M/O** | **Note**                                              |
|----------------|----------------------|-----------------------------------------------|---------|-------------------------------------------------------|
| id             | String               | URL for VC schema                             |    M    |                                                       |
| type           | CredentialSchemaType | VC schema format type                         |    M    | [CredentialSchemaType](#17-credentialschematype)      |
| value          | String               | VC schema                                     |    O    | Encoded by Multibase                                  |
| presentAll     | Bool                 | Require to present all claims. Default(false) |    O    | Ignore display and required claims when if it is true |
| displayClaims  | [String]             | Display claims                                |    O    | Literally display values on device screen             |
| requiredClaims | [String]             | Required claims                               |    O    | Required values to present VP                         |
| allowedIssuers | [String]             | List of allowed issuers' DID                  |    O    |                                                       |

<br>

## 5.2.1.2 Process

### Description

`Method for VP presentation`

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
| endpoints     | [String]       | List of endpoint               |    O    |                          |
| reqE2e        | ReqE2e         | Request information            |    M    | Proof not included <br> [ReqE2e](#55-reqe2e)     |
| verifierNonce | String         | Verifier nonce                   |    M    |                          |
| authType      | VerifyAuthType | Indicate access method for Key |    O    | [VerifyAuthType](#1-verifyauthtype)   |

<br>

## 5.3. LogoImage

### Description

`Logo image`

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
| format | LogoImageType | Image format        |    M    | [LogoImageType](#10-logoimagetype)     |
| link   | String        | URL for logo image  |    O    | Encoded by Multibase     |
| value  | String        | Image value         |    O    | Encoded by Multibase     |

<br>

## 5.4. ProviderDetail

### Description

`Provider detail information`

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
| did         | String    | Provider DID                      |    M    |                          |
| certVcRef   | String    | URL for Certificate of membership |    M    |                          |
| name        | String    | Provider name                     |    M    |                          |
| description | String    | Provider description              |    O    |                          |
| logo        | LogoImage | Logo Image                        |    O    | [LogoImage](#53-logoimage)          |
| ref         | String    | URL for reference                 |    O    |                          |

<br>

## 5.5. ReqE2e

### Description

`End to end request data`

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

| Name      | Type      | Description                                   | **M/O** | **Note**                 |
|-----------|-----------|-----------------------------------------------|---------|--------------------------|
| nonce     | String               | Value for symmetric key creation   |    M    | Encoded by Multibase     |
| curve     | ECType    | Elliptic curve type                |    M    |                          |
| publicKey | String               | Server's public key for encryption |    M    | Encoded by Multibase     |
| cipher    | SymmetricCipherType  | Cipher type                        |    M    | [SymmetricCipherType](#15-symmetricciphertype)  |
| padding   | SymmetricPaddingType | Padding type                       |    M    | [SymmetricPaddingType](#14-symmetricpaddingtype)   |
| proof     | Proof                | Key aggreement proof               |    O    | [Proof](#4-proof)    |

<br>

## 5.6 ProofRequestProfile

### Description

`ProofRequest Profile`

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
| id          | String      | Profile ID            |    M    |                          |
| type        | ProfileType | Profile type          |    M    | [ProfileType](#9-profiletype)         |
| title       | String      | Profile title         |    M    |                          |
| description | String      | Profile description   |    O    |                          |
| logo        | LogoImage   | Logo image            |    O    |  [LogoImage](#53-logoimage)        |
| encoding    | String      | Profile encoding type |    M    |                          |
| language    | String      | Profile language code |    M    |                          |
| profile     | Profile     | Profile contents      |    M    | [Profile](#561-profile)      |
| proof       | Proof       | Owner proof           |    O    | [Proof](#4-proof)       |

<br>

## 5.6.1 Profile

### Description

`Profile contents`

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

| Name         | Type           | Description                | **M/O** | **Note**                                           |
|--------------|----------------|----------------------------|---------|----------------------------------------------------|
| verifier     | ProviderDetail | Verifier information       |    M    | [ProviderDetail](#54-providerdetail)              |
| proofRequest | ProofRequest   | ProofRequest information   |    M    | Refer to the ZKP_DataModel.md                     |
| reqE2e       | ReqE2e         | Request information        |    M    | Proof not included <br> [ReqE2e](#55-reqe2e)

<br>

## 6. VCSchema

### Description

`VC schema`

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
| id                | String            | URL for VC schema        |    M    |                          |
| schema            | String            | URL for VC schema format |    M    |                          |
| title             | String            | VC schema name           |    M    |                          |
| description       | String            | VC schema decription     |    M    |                          |
| metadata          | VCMetadata        | VC metadata              |    M    |  [VCMetadata](#61-vcmetadata)   |
| credentialSubject | CredentialSubject | Credential subject       |    M    |  [CredentialSubject](#62-credentialsubject)   |

<br>

## 6.1. VCMetadata

### Description

`VC Metadata`

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
| language      | String | VC default language |    M    |                          |
| formatVersion | String | VC format version   |    M    |                          |

<br>

## 6.2. CredentialSubject

### Description

`Credential Subject`

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
| claims | [Claim] | Claim per namespace  |    M    | [Claim](#621-claim)                         |

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
| items     | [ClaimDef] | List of Claim definition |    M    | [ClaimDef](#6212-claimdef)  |

<br>

## 6.2.1.1. Namespace

### Description

`Claim namespace`

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
| name | String | Namespace name                |    M    |                          |
| ref  | String | URL for namespace information |    O    |                          |

<br>

## 6.2.1.2. ClaimDef

### Description

`Claim Definition`

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
| caption     | String          | Claim name           |    M    |                          |
| type        | ClaimType       | Claim type           |    M    | [ClaimType](#11-claimtype)         |
| format      | ClaimFormat     | Claim format         |    M    |  [ClaimFormat](#12-claimformat)       |
| hideValue   | Bool            | Hide value           |    O    | Default(false)           |
| location    | Location        | Value Location       |    O    | Default(inline) <br> [Location](#13-location)        |
| required    | Bool            | Requirement          |    O    | Default(true)            |
| description | String          | Claim description    |    O    | Default("")              |
| i18n        | [String:String] | Internationalization |    O    |                          |

<br>

# WalletService
## 1. Protocol

### 1.1. M132 (reg user)

#### 1.1.1. ProposeRegisterUser/ _ProposeRegisterUser

#### Description
`User Reg`

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
| id      | String | message ID                     |    M    |          |
| txId    | String | transaction ID                 |    M    |          |

<br>

#### 1.1.2. RequestEcdh/ _RequestEcdh

#### Description
`session encryption`

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
| id      | String  | message ID                     |    M    |          |
| txId    | String  | transaction ID                 |    M    |          |
| reqEcdh | ReqEcdh |                                |    M    |          |
| accEcdh | AccEcdh |                                |    M    |          |
<br>

#### 1.1.3. AttestedAppInfo

#### Description
`attested app info`

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
| appId   | String  | application id                 |    M    |          |

<br>

#### 1.1.4. WalletTokenData

#### Description

`wallet token data`

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
| seed       | WalletTokenSeed  | wallet token seed              |    M    |          |
| sha256_pii | String           | hashed(sha256)                 |    M    |          |
| provider   | Provider         | provier                        |    M    |          |
| nonce      | String           | nonce                          |    M    |          |
| proof      | Proof            | proof                          |    M    |          |

<br>

#### 1.1.5. RequestCreateToken/ _RequestCreateToken

#### Description

`request create token`

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
| id      | String           | message ID                     |    M    |          |
| txId    | String           | transaction ID                 |    M    |          |
| seed    | ServerTokenSeed  | server token seed              |    M    |          |
| encStd  | String           | encrypt server token data      |    M    |          |

<br>


#### 1.1.6. RetieveKyc/ _RetieveKyc

#### Description

`retrieve kyc`

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
| id          | String           | message ID                     |    M    |          |
| txId        | String           | transaction ID                 |    M    |          |
| serverToken | ServerTokenSeed  | server token                   |    M    |          |
| kycTxId     | String           | kyc transaction ID             |    M    |          |
<br>


#### 1.1.7. RequestRegisterUser/ _RequestRegisterUser

#### Description

`request register user`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| signedDidDoc | SignedDidDoc     | signed DID doc                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
<br>


#### 1.1.8. ConfirmRegisterUser/ _ConfirmRegisterUser

#### Description

`confirm register user`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
<br>


### 1.2. M210 (issue vc)
#### 1.2.1. ProposeIssueVc/ _ProposeIssueVc

#### Description

`propose issue vc`

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
| id           | String           | message ID                     |    M    |          |
| vcPlanId     | String           | vc plan ID                     |    M    |          |
| issuer       | String           | issuer                         |    M    |          |
| offerId      | String           | offer ID                       |    O    |          |
| txId         | String           | transaction ID                 |    M    |          |
| refId        | String           | reference ID                   |    M    |          |
<br>

#### 1.2.2. RequestIssueProfile/ _RequestIssueProfile

#### Description

`request issue profile`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
| authNonce    | String           | auth nonce                     |    M    |          |
| profile      | IssuerProfile    | issuer profile                 |    M    |          |
<br>

#### 1.2.3. RequestIssueVc/ _RequestIssueVc

#### Description

`request issue vc`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
| didAuth      | DIDAuth          | DID auth                       |    M    |          |
| accE2e       | AccE2e           | access E2e                     |    M    |          |
| encReqVc     | String           | encrypt Request vc             |    M    |          |
| e2e          | E2E              | e2e                            |    M    |          |
<br>

#### 1.2.4. ConfirmIssueVc/ _ConfirmIssueVc

#### Description

`confirm issue vc`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
| vcId         | String           | vc ID                          |    M    |          |
<br>

#### 1.2.5. CredInfo

#### Description

`Issued Verifiable Credential and Zero-knowledge Proof Credential`

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
| Name       | Type                   | Description                          | **M/O** | **Note**                       |
|------------|------------------------|--------------------------------------|---------|--------------------------------|
| vc         | VerifiableCredential   | Verifiable Credential                | M       |                                |
| credential | ZKPCredential          | Zero-knowledge Proof Credential      | O       | Refer to the ZKP_DataModel.md |

<br>

### 1.3. M310 (submit vp)
#### 1.3.1. RequestProfile/ _RequestProfile

#### Description

`request verifiy profile`

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
| Name     | Type          | Description                | **M/O** | **Note** |
|----------|---------------|----------------------------|---------|----------|
| id       | String        | message ID                 | M       |          |
| txId     | String        | transaction ID             | O       |          |
| offerId  | String        | offer ID                   | M       |          |
| profile  | VerifyProfile | Verify profile for VP      | M       |          |

<br>

#### 1.3.2. RequestVerify/ _RequestVerify
#### Description

`request verifiy profile`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| accE2e       | AccE2e           | access E2e                     |    M    |          |
| encVp        | String           | encrypt vp                     |    M    |          |

<br>


### 1.4. M220 (revoke vc)
#### 1.4.1. ProposeRevokeVc/ _ProposeRevokeVc

#### Description
`propose revoke vc`

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
| Name        | Type             | Description                         | **M/O** | **Note**                             |
|-------------|------------------|-------------------------------------|---------|--------------------------------------|
| id          | String           | message ID                          | M       |                                      |
| vcId        | String           | vc ID                               | M       |                                      |
| issuerNonce | String           | Issuer nonce                        | M       |                                      |
| authType    | VerifyAuthType   | Indicate access method for Key      | M       | [VerifyAuthType](#1-verifyauthtype)  |


<br>

#### 1.4.2. RequestRevokeVc/ _RequestRevokeVc

#### Description

`request revoke vc`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
| request      | ReqRevokeVc      |                                |    M    |          |
<br>



#### 1.4.3. ConfirmRevokeVc/ _ConfirmRevokeVc

#### Description

`confirm revoke vc`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transaction ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
<br>

### 1.5. M142 (restore DID)
#### 1.5.1. ProposeRestoreDidDoc/ _ProposeRestoreDidDoc

#### Description

`propose restore diddoc`

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
| id           | String           | message ID                     |    M    |          |
| offerId      | String           | offer ID                       |    M    |          |
| did          | String           | did                            |    M    |          |
<br>

#### 1.5.2. RequestRestoreDIDDoc/ _RequestRestoreDIDDoc

#### Description

`request restore diddoc`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transcation ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |
| didAuth      | DIDAuth          | did auth                       |    M    |          |
<br>

#### 1.5.3. ConfirmRestoreDidDoc/ _ConfirmRestoreDidDoc

#### Description

`confirm restore diddoc`

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
| id           | String           | message ID                     |    M    |          |
| txId         | String           | transcation ID                 |    M    |          |
| serverToken  | String           | server token                   |    M    |          |

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
| Name                 | Type                | Description                      | **M/O** | **Note** |
|----------------------|---------------------|----------------------------------|---------|----------|
| id                   | String              | message ID                       | M       |          |
| txId                 | String              | transaction ID                   | O       |          |
| offerId              | String              | offer ID                         | M       |          |
| proofRequestProfile  | ProofRequestProfile | Verify profile for ZKP           | M       |          |

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
| Name     | Type         | Description                | **M/O** | **Note** |
|----------|--------------|----------------------------|---------|----------|
| id       | String       | message ID                 | M       |          |
| txId     | String       | transaction ID             | M       |          |
| accE2e   | AccE2e       | access E2e                 | M       |          |
| encProof | String       | encrypted zkproof          | M       |          |
| nonce    | BigIntString | proof request's nonce      | M       |          |

<br>


## 2. Token
## 2.1. ServerTokenSeed

### Description

`Server token seed`

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
| purpose     | WalletTokenPurposeEnum     | server token purpose       |    M    | [WalletTokenPurposeEnum](#24-servertokenpurpose) |
| walletInfo  | SignedWalletInfo           | Signed wallet information  |    M    | [SignedWalletInfo](#27-signedwalletinfo) |
| caAppInfo   | AttestedAppInfo            | Attested app information   |    M    | [AttestedAppInfo](#6-attestedappinfo) |

<br>

## 2.1.1. AttestedAppInfo

### Description

`Attested app information`


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
| appId    | String   | Certificated app id           |    M    |                            |
| provider | Provider | Provider information          |    M    | [Provider](#provider)      |
| nonce    | String   | Nonce for attestation         |    M    |                            |
| proof    | Proof    | Assertion proof               |    O    | [Proof](#4-proof)         

<br>

## 2.1.1.1. Provider

### Description

`Provider information`

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
| did        | String | Provider DID            |    M    |          |
| certVcRef  | String | Certificate VC URL      |    M    |          |

<br>

## 2.1.2. SignedWalletInfo

### Description

`Signed wallet information`

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
| wallet     | Wallet          | Wallet information        |    M    | [Wallet](#28-wallet) |
| nonce      | String          | Nonce                     |    M    |          |
| proof      | Proof           | Proof                     |    O    | [Proof](#4-proof) |

<br>

## 2.1.2.1. Wallet

### Description

`Wallet details`

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
| id         | String          | Wallet ID               |    M    |          |
| did        | String          | Wallet provider DID     |    M    |          |

<br>

## 2.2. ServerTokenData

### Description

`server token data`

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
| purpose    | ServerTokenPurposeEnum              | Server token purpose                 |    M    | [ServerTokenPurpose](#24-servertokenpurpose) |
| walletId   | String                              | Wallet ID                            |    M    |          |
| appId      | String                              | Certificate app ID                   |    M    |          |
| validUntil | String                              | Expiration date of the server token  |    M    |          |
| provider   | Provider                            | Provider information                 |    M    | [Provider](#18-provider) |
| nonce      | String                              | Nonce                                |    M    |          |
| proof      | Proof                               | Proof                                |    O    | [Proof](#4-proof) |

<br>

## 2.3. WalletTokenSeed

### Description
`Seed object for wallet token seed`

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
| purpose    | ServerTokenPurposeEnum          | Wallet token purpose              |    M    | [WalletTokenPurpose](#33-wallettokenpurpose) |
| pkgName    | String                          | CA package name                   |    M    |          |
| nonce      | String                          | Nonce                             |    M    |          |
| validUntil | String                          | Expiration date of the token      |    M    |          |
| userId     | String                          | User ID                           |    O    |          |
<br>


## 2.4. WalletTokenData

### Description

`Data associated with a wallet token`

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
| seed       | WalletTokenSeed   | Wallet token seed             |    M    | [WalletTokenSeed](#33-wallettokenseed) |
| sha256_pii | String            | SHA-256 hash of PII           |    M    |          |
| provider   | Provider          | Provider information          |    M    | [Provider](#18-provider) |
| nonce      | String            | Nonce                         |    M    |          |
| proof      | Proof             | Proof                         |    O    | [Proof](#4-proof) |

<br>

## 3. SecurityChannel

## 3.1. ReqEcdh

### Description

`ECDH request data`

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
| client      | String                           | Client DID                     |    M    |          |
| clientNonce | String                           | Client Nonce                   |    M    |          |
| curve       | ECType.ELLIPTIC_CURVE_TYPE       | Curve type for ECDH       |    M    |          |
| publicKey   | String                           | Public key for ECDH            |    M    |          |
| candidate   | ReqEcdh.Ciphers                  | Candidate ciphers              |    O    |          |
| proof       | Proof                            | Proof                          |    O    | [Proof](#4-proof) |

<br>

## 3.2. AccEcdh

### Description
`ECDH acceptance data`

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
| server      | String                         | Server ID                          |    M    |          |
| serverNonce | String                         | Server Nonce                       |    M    |          |
| publicKey   | String                         | Public Key for key agreement       |    M    |          |
| cipher      | String                         | Cipher type for encryption         |    M    |          |
| padding     | String                         | Padding type for encryption        |    M    |          |
| proof       | Proof                          | Key agreement proof                |    O    | [Proof](#4-proof) |

<br>

## 3.3. AccE2e

### Description
`E2E acceptance data`

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
| publicKey  | String              | Public Key for encryption  |    M    |                    |
| iv         | String              | Initialize Vector          |    M    |                    |
| proof      | Proof               | Key agreement proof        |    O    | [Proof](#4-proof)  |

<br>

## 3.4. E2e

### Description

`E2E encryption information`

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
`DID Authentication data `

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
| did        | String     | DID                           |    M    |                            |
| authNonce  | String     | Auth nonce                    |    M    |                            |
| proof      | Proof      | Authentication proof          |    O    | [Proof](#4-proof)          |

<br>

## 4. DidDoc
## 4.1. DIDDocVO

### Description
`Encoded DID document`

### Declaration
```swift
public struct DIDDocVO: Jsonable {
    public var didDoc: String
}
```

### Property
| Name   | Type   | Description            | **M/O** | **Note** |
|--------|--------|------------------------|---------|----------|
| didDoc | String | Encoded DID document   |    M    |          |

<br>

## 4.2. AttestedDIDDoc

### Description
`Attested DID information`

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
| walletId   | String   | Wallet ID                |    M    |                            |
| ownerDidDoc| String   | Owner's DID document     |    M    |                            |
| provider   | Provider | Provider information     |    M    | [Provider](#provider)      |
| nonce      | String   | Nonce                    |    M    |                            |
| proof      | Proof    | Attestation proof        |    O    | [Proof](#4-proof)          |

<br>

## 4.3. SignedDidDoc

### Description
`Signed DID Document`

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
| ownerDidDoc| String          | Owner's DID document      |    M    |          |
| wallet     | Wallet          | Wallet information        |    M    | [Wallet](#28-wallet) |
| nonce      | String          | Nonce                     |    M    |          |
| proof      | Proof           | Proof                     |    O    | [Proof](#4-proof) |

<br>

## 5. Offer
## 5.1. IssueOfferPayload

### Description
`Payload for issuing an offer`

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
| offerId   | String        | Offer ID                               |    O    |          |
| type      | OfferTypeEnum | OfferType (issuerOffer or VerifyOffer) |    M    |          |
| vcPlanId  | String        | Verifiable Credential Plan ID          |    M    |          |
| issuer    | String        | Issuer DID                             |    M    |          |
| validUntil| String        | Expiration date                        |    O    |          |

<br>

## 5.2. VerifyOfferPayload

### Description
`Payload for verifying an offer`

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
| Name       | Type                | Description                                | **M/O** | **Note** |
|------------|---------------------|--------------------------------------------|---------|----------|
| offerId    | String              | Offer ID                                   |    M    |          |
| type       | OfferTypeEnum       | Offer type                                 |    M    |          |
| mode       | PresentModeEnum     | Presentation mode                          |    M    |          |
| device     | String              | Identifier of the response device          |    O    |          |
| service    | String              | Identifier of the service                  |    O    |          |
| endpoints  | String[]            | List of profile request API endpoints      |    O    |          |
| validUntil | String              | End date of the offer                      |    M    |          |
| locked     | Bool                | Whether the offer is locked                |    O    |          |


<br>

## 6. VC
## 6.1. ReqVC

### Description
`Request object for Verifiable Credential (VC)`

### Declaration
```swift
public struct ReqVC: Jsonable {
    public var refId: String
    public var profile: ReqVcProfile
    public var credentialRequest : ZKPCredentialRequest?
}
```

### Property
| Name              | Type                 | Description                    | **M/O** | **Note** |
|-------------------|----------------------|--------------------------------|---------|----------|
| refId             | String               | Reference ID                   | M       |          |
| profile           | ReqVcProfile         | Request issue profile          | M       |          |
| credentialRequest | ZKPCredentialRequest | Request for ZKP Credential     | O       |          |

<br>

## 6.1.1. ReqVcProfile

### Description
`Request issue profile`

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
| id           | String          | Issuer DID                |    M    |          |
| issuerNonce | String           | Issuer nonce              |    M    |          |
<br>


## 6.2. VCPlanList

### Description

`List of Verifiable Credential(VC) plan`

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
| count  | int              | Number of VC plan list           |    M    |          |
| items  | array[VCPlan]    | List of VC plan                  |    M    | [VCPlan](#28-vcplan) |

<br>

## 6.2.1. VCPlan

### Description
`Details of a Verifiable Credential (VC) plan`

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
| Name                 | Type                          | Description                                                   | **M/O** | **Note**                        |
|----------------------|-------------------------------|---------------------------------------------------------------|---------|----------------------------------|
| vcPlanId             | String                        | VC plan ID                                                    | M       |                                  |
| name                 | String                        | VC plan name                                                  | M       |                                  |
| description          | String                        | VC plan description                                           | M       |                                  |
| url                  | String                        | Issuer URL                                                    | O       |                                  |
| logo                 | LogoImage                     | Logo image                                                    | O       | [LogoImage](#29-logoimage)       |
| validFrom            | String                        | Validity start date                                           | O       |                                  |
| validUntil           | String                        | Validity end date                                             | O       |                                  |
| tags                 | array[String]                 | Tags                                                          | O       |                                  |
| credentialSchema     | CredentialSchema              | Credential schema                                             | M       |                                  |
| option               | VCPlan.Option                 | Plan options                                                  | M       |                                  |
| delegate             | String                        | Delegate                                                      | O       |                                  |
| allowedIssuers       | array[String]                 | List of issuer DIDs allowed to use this VC plan               | O       |                                  |
| manager              | String                        | Entity with administrative authority over the VC plan         | M       |                                  |
| credentialDefinition | VCPlan.CredentialDefinition   | ZKP-related information associated with VC issuance           | O       |                                  |

<br>

## 6.2.1.1. Option

### Description
`(VC) plan Option`

### Declaration
```swift
public struct Option: Jsonable {
    public var allowUserInit: Bool
    public var allowIssuerInit: Bool
    public var delegatedIssuance: Bool
}
```

### Property
| Name              | Type | Description                                                      | **M/O** | **Note** |
|-------------------|------|------------------------------------------------------------------|---------|----------|
| allowUserInit     | Bool | Whether issuance can be initiated by the user                    | M       |          |
| allowIssuerInit   | Bool | Whether issuance can be initiated by the issuer                  | M       |          |
| delegatedIssuance | Bool | Whether delegated issuance by a representative issuer is allowed | M       |          |



<br>

## 6.2.1.2. VCPlan.CredentialDefinition

### Description
`ZKP-related information associated with VC issuance`

### Declaration
```swift
public struct CredentialDefinition: Jsonable
{
    public var id: String
    public var schemaId: String
}
```

### Property
| Name     | Type   | Description                               | **M/O** | **Note** |
|----------|--------|-------------------------------------------|---------|----------|
| id       | String | Identifier for ZKP CredentialDefinition   | M       |          |
| schemaId | String | Identifier for ZKP CredentialSchema       | M       |          |

<br>

# OptionSet
## 1. VerifyAuthType

### Description

`Indicate access method for Key and presentation option. Similar to AuthType`

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

`DID key type`

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

`Service type`

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

`Proof purpose`

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

`Proof type`

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

`Indicate access method for Key`

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

`Evidence Enumerator for Multitype array`

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

`Presence type`

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

`Evidence type`

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

`Profile type`

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

`Logo image type`

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

`Claim type`

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

`Claim format`

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

`Value Location`

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

`Symmetric padding type`

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

`Symmetric cipher type`

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

`Algorithm type`

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

`Credential schema type`

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
`Enumeration for Offer type`

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

`Enumeration for various role types`

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
`Enumeration for various server token purposes`

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
`Enumeration for various wallet token purposes`

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

`Model to Json, and vice versa`

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

`General proof protocol`

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

`Protocol contains proof`

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

`Protocol contains multi proofs`

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

`Convertible to AlgorithmType protocol`

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

`Convertible from AlgorithmType protocol`

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

`Convertible from AlgorithmType protocol, and vice versa`

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


    


