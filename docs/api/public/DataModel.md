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
- Date: 2026-08-06
- Version: v2.0.0

| Version          | Date       | History                 |
| ---------------- | ---------- | ------------------------|
| v2.0.0           | 2026-08-06 | Add OID4VC models       |
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

- [OID4VC](#oid4vc)
    - [1. CredentialItem](#1-credentialitem)
        - [1.1. CredentialFormat](#11-credentialformat)
        - [1.2. VCDMCredentialItem](#12-vcdmcredentialitem)
        - [1.3. SdJwtCredentialItem](#13-sdjwtcredentialitem)
    - [2. SDJWT](#2-sdjwt)
        - [2.1. Disclosure](#21-disclosure)
    - [3. JWS](#3-jws)
        - [3.1. JWSHeader](#31-jwsheader)
    - [4. JWK](#4-jwk)
        - [4.1. JWK nested enumerations](#41-jwk-nested-enumerations)
    - [5. AuthorizationRequest](#5-authorizationrequest)
    - [6. DCQLQuery](#6-dcqlquery)
        - [6.1. CredentialQuery](#61-credentialquery)
        - [6.2. ClaimQuery](#62-claimquery)
        - [6.3. TrustedAuthority](#63-trustedauthority)
        - [6.4. CredentialSet](#64-credentialset)
        - [6.5. DCQLPathElement](#65-dcqlpathelement)
    - [7. MatchedCredential](#7-matchedcredential)
    - [8. IssuerMetadataResponse](#8-issuermetadataresponse)
        - [8.1. CredentialConfiguration](#81-credentialconfiguration)
        - [8.2. EncryptionSupport](#82-encryptionsupport)
        - [8.3. CredentialPolicy](#83-credentialpolicy)
        - [8.4. CredentialMetadata](#84-credentialmetadata)
        - [8.5. DisplayInfo](#85-displayinfo)
            - [8.5.1. LogoInfo](#851-logoinfo)
        - [8.6. ProofSupport](#86-proofsupport)
        - [8.7. ClaimDetail](#87-claimdetail)
        - [8.8. SupportedFormat](#88-supportedformat)
        - [8.9. SigningAlg](#89-signingalg)
    - [9. CredentialOfferResponse](#9-credentialofferresponse)
        - [9.1. Grants](#91-grants)
        - [9.2. PreAuthorizedCode](#92-preauthorizedcode)
        - [9.3. TxCode](#93-txcode)
        - [9.4. AuthorizationCode](#94-authorizationcode)
    - [10. TokenRequest](#10-tokenrequest)
    - [11. TokenResponse](#11-tokenresponse)
    - [12. AuthorizationDetails](#12-authorizationdetails)
    - [13. OID4VCIIssuerList](#13-oid4vciissuerlist)
        - [13.1. OID4VCIIssuerItem](#131-oid4vciissueritem)
    - [14. AnyJSON](#14-anyjson)

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

# OID4VC

Models of the OpenID4VCI (issuance) and OpenID4VP (presentation) layer that an app handles directly:
what it reads out of the wallet (1–4), what it exchanges with a verifier (5–7), and what it exchanges
with an issuer (8–13).

The matching engine itself — the credential adapters, `DCQLCredentialMatcher`, `ParsedCredential` and
the path helpers — is `public` for internal composition but is not part of the app-facing surface;
apps go through `WalletAPI.matchCredentials` instead.

## 1. CredentialItem

### Description
`A stored credential, in whatever format the wallet holds it.`

### Declaration
```swift
public protocol CredentialItem: Identifiable {
    var id: String { get }
    var format: CredentialFormat { get }
}
```

### Property
| Name   | Type             | Description                       | **M/O** | **Note**                          |
|--------|------------------|-----------------------------------|---------|-----------------------------------|
| id     | String           | Wallet-local credential id        | M       |                                   |
| format | CredentialFormat | Which concrete item this is       | M       | [CredentialFormat](#11-credentialformat) |

<br>

## 1.1. CredentialFormat

### Description
`The storage format of a credential.`

### Declaration
```swift
public enum CredentialFormat { case vcdm, sdJwtVc, msoMdoc }
```

### Property
| Value    | Description                                       | **Note**                                    |
|----------|---------------------------------------------------|---------------------------------------------|
| vcdm     | W3C Verifiable Credentials Data Model credential  | [VCDMCredentialItem](#12-vcdmcredentialitem) |
| sdJwtVc  | SD-JWT VC                                         | [SdJwtCredentialItem](#13-sdjwtcredentialitem) |
| msoMdoc  | ISO mdoc                                          | Not issued or presented yet                 |

<br>

## 1.2. VCDMCredentialItem

### Description
`A stored W3C credential, with its ZKP counterpart when one was issued alongside.`

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
| Name   | Type                 | Description                    | **M/O** | **Note**                                        |
|--------|----------------------|--------------------------------|---------|-------------------------------------------------|
| id     | String               | Wallet-local credential id     | M       |                                                 |
| format | CredentialFormat     | Always `.vcdm`                 | M       | [CredentialFormat](#11-credentialformat)        |
| vc     | VerifiableCredential | The credential itself          | M       | [VerifiableCredential](#2-verifiablecredential) |
| zkp    | ZKPCredential        | ZKP credential for the same subject | O  |                                                 |

<br>

## 1.3. SdJwtCredentialItem

### Description
`A stored SD-JWT credential, as returned by getAllOID4VCs / getOID4VCs.`

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
}
```

### Property
| Name                 | Type             | Description                                          | **M/O** | **Note** |
|----------------------|------------------|------------------------------------------------------|---------|----------|
| id                   | String           | Wallet-local credential id                           | M       |          |
| format               | CredentialFormat | Always `.sdJwtVc`                                    | M       | [CredentialFormat](#11-credentialformat) |
| configurationId      | String           | `credential_configuration_id` this was issued under  | M       |          |
| kid                  | String           | Key id of the holder key bound to the credential     | M       |          |
| credentialIdentifier | String           | `credential_identifier` when the issuer supplied one | O       |          |
| sdjwt                | SDJWT            | The credential itself                                | M       | [SDJWT](#2-sdjwt) |

<br>

## 2. SDJWT

### Description
`An SD-JWT: the issuer JWT, its disclosures, and the key-binding JWT when one is attached.`

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
}
```

### Property
| Name          | Type          | Description                                            | **M/O** | **Note** |
|---------------|---------------|--------------------------------------------------------|---------|----------|
| credentialJwt | String        | The issuer-signed JWT, compact serialized              | M       |          |
| disclosures   | [Disclosure]  | Every disclosure the credential carries                 | M       | [Disclosure](#21-disclosure) |
| keyBindingJwt | String        | KB-JWT, present only on a presentation                 | O       |          |

### Method
| Name             | Description                                                    | **Note** |
|------------------|----------------------------------------------------------------|----------|
| parse(raw:)      | Splits a `~`-separated SD-JWT string into its parts             | Never throws; an unparseable string yields a credential JWT with no disclosures |
| toString()       | Serializes back to the `~`-separated form                       |          |
| getSignSource()  | Returns the signing input and signature of the credential JWT   |          |

<br>

## 2.1. Disclosure

### Description
`One selectively disclosable claim of an SD-JWT.`

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
| Name       | Type   | Description                                              | **M/O** | **Note** |
|------------|--------|----------------------------------------------------------|---------|----------|
| salt       | String | The issuer's salt for this disclosure                     | M       |          |
| claimName  | String | The claim name; `nil` for an array-element disclosure     | O       |          |
| claimValue | JSON   | The disclosed value                                       | M       |          |
| raw        | String | The issuer's disclosure string, byte-for-byte             | O       | `nil` for a disclosure built in code. Digests are computed over these exact bytes, so a parsed disclosure is presented unchanged |

<br>

## 3. JWS

### Description
`A parsed JWS in compact serialization (<header>.<payload>.<signature>).`

The three properties hold the raw base64url segments as they arrived; the decoded forms are the
`payloadData` and `protectedHeader` accessors.

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
| Name      | Type   | Description                          | **M/O** | **Note** |
|-----------|--------|--------------------------------------|---------|----------|
| header    | String | base64url-encoded protected header   | M       |          |
| payload   | String | base64url-encoded payload            | M       |          |
| signature | String | base64url-encoded signature          | M       |          |

### Method
| Name              | Description                                              | **Note** |
|-------------------|----------------------------------------------------------|----------|
| init(from:)       | Parses a compact JWS                                     | Throws `MSDKWLT05102` when the string is not three dot-separated parts |
| payloadData       | The base64url-decoded payload                            | Throws `MSDKWLT05102` when the payload is not base64url |
| protectedHeader   | The decoded protected header                             | Throws `MSDKWLT05102` when the header is not base64url or is not a JWS header |

<br>

## 3.1. JWSHeader

### Description
`The protected header of a JWS.`

Read this off `JWS.protectedHeader`; the memberwise initializer is internal to the SDK. When the
header carries a `kid` rather than a `jwk`, resolve the signer's key yourself — the SDK does not
resolve DID documents for verification.

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
| Name | Type          | Description                                   | **M/O** | **Note** |
|------|---------------|-----------------------------------------------|---------|----------|
| alg  | JWK.Algorithm | Signing algorithm                             | M       | [JWK](#4-jwk) |
| typ  | String        | Token type, e.g. `openid4vci-proof+jwt`       | M       |          |
| kid  | String        | Key id of the signer                          | O       |          |
| jwk  | JWK           | The signer's public key, embedded             | O       | [JWK](#4-jwk) |

<br>

## 4. JWK

### Description
`A JSON Web Key. Only EC P-256 keys are modelled.`

Callers read this type — for example off a `JWSHeader` — but do not construct it; the memberwise
initializer is internal to the SDK.

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
| Name | Type      | Description                              | **M/O** | **Note** |
|------|-----------|------------------------------------------|---------|----------|
| alg  | Algorithm | Intended algorithm                       | O       | [Nested enumerations](#41-jwk-nested-enumerations) |
| kid  | String    | Key id                                   | O       |          |
| crv  | Curve     | Curve; `.p256` by default                | M       |          |
| kty  | KeyType   | Key type; `.ec` by default               | M       |          |
| x    | String    | base64url x coordinate                   | M       |          |
| y    | String    | base64url y coordinate                   | M       |          |
| use  | JWKUse    | `.sig` or `.enc`                         | O       |          |

<br>

## 4.1. JWK nested enumerations

### Description
`Algorithm, curve, key type and intended use. Each keeps the wire value it did not recognise.`

### Declaration
```swift
public enum Algorithm: Jsonable, Equatable { case es256, ecdhES, unknown(String) }
public enum Curve:     Jsonable, Equatable { case p256, unknown(String) }
public enum KeyType:   Jsonable, Equatable { case ec, unknown(String) }
public enum JWKUse: String, Jsonable, Equatable { case sig, enc }
```

### Property
| Type      | Values                                | **Note**                                                     |
|-----------|---------------------------------------|--------------------------------------------------------------|
| Algorithm | `es256`, `ecdhES`, `unknown(String)`  | `ES256` for signing, `ECDH-ES` for response encryption        |
| Curve     | `p256`, `unknown(String)`             | Encoded as `P-256`                                            |
| KeyType   | `ec`, `unknown(String)`               | Encoded as `EC`                                               |
| JWKUse    | `sig`, `enc`                          |                                                               |

<br>

## 5. AuthorizationRequest

### Description
`OpenID4VP authorization request received from the verifier.`

Passed to `matchCredentials` and `createVpToken`.

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
| Name           | Type              | Description                                              | **M/O** | **Note** |
|----------------|-------------------|----------------------------------------------------------|---------|----------|
| responseUri    | String            | Endpoint the response body is POSTed to                  | M       |          |
| nonce          | String            | Verifier nonce, bound into the presentation              | M       |          |
| state          | String            | Verifier state, echoed back in the response              | M       |          |
| clientId       | String            | Verifier identifier; used as the presentation audience   | M       |          |
| responseType   | String            | OAuth response type                                      | M       |          |
| responseMode   | String            | `direct_post` or `direct_post.jwt`                       | M       | Other modes are rejected (`MSDKWLT05509`) |
| dcqlQuery      | DCQLQuery         | The credential query to match against                    | M       | [DCQLQuery](#6-dcqlquery) |
| clientMetadata | [String: AnyJSON] | Verifier metadata; carries the response-encryption key for `direct_post.jwt` | M | [AnyJSON](#14-anyjson) |
| iat            | Int               | Issued-at timestamp of the request                       | M       |          |

<br>

## 6. DCQLQuery

### Description
`The verifier's Digital Credentials Query Language query (OpenID4VP 1.0 §6).`

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
| Name            | Type                    | Description                                      | **M/O** | **Note** |
|-----------------|-------------------------|--------------------------------------------------|---------|----------|
| credentials     | [CredentialQuery]       | The credential queries to satisfy                 | O       | [CredentialQuery](#61-credentialquery) |
| credentialSets  | [CredentialSet]         | Which combinations of those queries are acceptable | O      | [CredentialSet](#64-credentialset) |
| transactionData | [[String: AnyJSON]]     | Transaction data to be signed alongside            | O       | [AnyJSON](#14-anyjson) |

<br>

## 6.1. CredentialQuery

### Description
`One credential the verifier asks for.`

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
| Name                              | Type                | Description                                        | **M/O** | **Note** |
|-----------------------------------|---------------------|----------------------------------------------------|---------|----------|
| id                                | String              | Query id; echoed back as `MatchedCredential.queryId` | O     |          |
| format                            | String              | Credential format asked for                        | O       |          |
| meta                              | [String: AnyJSON]   | Format-specific constraints, e.g. accepted schema ids | O    | [AnyJSON](#14-anyjson) |
| claims                            | [ClaimQuery]        | The claims asked for; absent means the whole credential | O  | [ClaimQuery](#62-claimquery) |
| claimSets                         | [[String]]          | Arrays of `claims[].id`; each inner array is one acceptable option | O | The wallet uses the first option whose ids all resolve |
| trustedAuthorities                | [TrustedAuthority]  | Issuer constraints                                 | O       | [TrustedAuthority](#63-trustedauthority) |
| purpose                           | String              | Why the verifier wants it                          | O       |          |
| multiple                          | Bool                | Whether more than one credential may answer this query | O   | Defaults to `false` |
| requireCryptographicHolderBinding | Bool                | Whether holder binding is required                 | O       |          |

<br>

## 6.2. ClaimQuery

### Description
`One claim the verifier asks for, optionally with a predicate on its value.`

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
| Name      | Type               | Description                                     | **M/O** | **Note** |
|-----------|--------------------|-------------------------------------------------|---------|----------|
| id        | String             | Claim query id, referenced by `claimSets`       | O       |          |
| path      | [DCQLPathElement]  | Path to the claim in a JSON credential          | O       | [DCQLPathElement](#65-dcqlpathelement). Not used for mdoc |
| namespace | String             | mdoc namespace, e.g. `org.iso.18013.5.1`        | O       |          |
| claimName | String             | mdoc claim name within the namespace            | O       |          |
| purpose   | String             | Why the verifier wants this claim               | O       |          |
| values    | [AnyJSON]          | The value must be one of these                  | O       | [AnyJSON](#14-anyjson) |
| value     | AnyJSON            | The value must equal this                       | O       |          |
| max       | AnyJSON            | Upper bound on the value                        | O       |          |
| min       | AnyJSON            | Lower bound on the value                        | O       |          |

<br>

## 6.3. TrustedAuthority

### Description
`Issuer constraint for a credential query (OpenID4VP 1.0 §6.1.1).`

### Declaration
```swift
public struct TrustedAuthority: Jsonable, FromSnake {
    public var type: String?
    public var values: [String]?
}
```

### Property
| Name   | Type     | Description                              | **M/O** | **Note** |
|--------|----------|------------------------------------------|---------|----------|
| type   | String   | Validation type                          | O       | `aki`, `etsi_tl`, `openid_federation`, `x509_san_dns`, `x509_san_uri` |
| values | [String] | Accepted authority values for that type  | O       |          |

<br>

## 6.4. CredentialSet

### Description
`Which combinations of credential queries the verifier will accept.`

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
| Name     | Type       | Description                                          | **M/O** | **Note** |
|----------|------------|------------------------------------------------------|---------|----------|
| id       | String     | Set id                                               | O       |          |
| options  | [[String]] | Arrays of `credentials[].id`; each inner array is one acceptable combination | O | |
| required | Bool       | Whether at least one option must be satisfied        | O       | Defaults to `true` |
| purpose  | String     | Why the verifier wants this set                      | O       |          |

<br>

## 6.5. DCQLPathElement

### Description
`One step of a DCQL claim path: an object member, an array index, or a wildcard.`

### Declaration
```swift
public enum DCQLPathElement: Codable, Hashable, Sendable {
    case key(String)
    case index(Int)
    case wildcard
}
```

### Property
| Value          | Description                    | **Note**                        |
|----------------|--------------------------------|---------------------------------|
| key(String)    | An object member name          | Encoded as a JSON string        |
| index(Int)     | An array index                 | Encoded as a JSON number        |
| wildcard       | Every element of an array      | Encoded as JSON `null`          |

<br>

## 7. MatchedCredential

### Description
`One matched credential for a single DCQL credential query.`

Returned by `matchCredentials` and passed back to `createVpToken`. The app may drop entries the
holder refuses, or rebuild the list through the public initializer, but must not narrow an entry's
`claimCodes`.

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
| Name         | Type     | Description                                                   | **M/O** | **Note** |
|--------------|----------|---------------------------------------------------------------|---------|----------|
| queryId      | String   | The DCQL credential query id this match answers               | M       | `dcql_query.credentials[].id` |
| credentialId | String   | The matched stored credential id                              | M       |          |
| claimCodes   | [String] | The claims to disclose — the ones the query asked for, or every claim the credential can disclose | M | Opaque values: display and compare them, never split or assemble them |

<br>

## 8. IssuerMetadataResponse

### Description
`An issuer's OpenID4VCI metadata: its endpoints and the credentials it offers.`

Passed to `requestIssueOID4VC`.

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
| Name                              | Type                              | Description                                   | **M/O** | **Note** |
|-----------------------------------|-----------------------------------|-----------------------------------------------|---------|----------|
| credentialIssuer                  | String                            | Issuer identifier                             | M       |          |
| authorizationServers              | [String]                          | Authorization servers the issuer trusts       | O       |          |
| credentialOfferEndpoint           | String                            | Credential offer endpoint                     | O       |          |
| credentialEndpoint                | String                            | Credential endpoint                           | M       |          |
| tokenEndpoint                     | String                            | Token endpoint                                | O       |          |
| nonceEndpoint                     | String                            | Nonce endpoint                                | O       |          |
| deferredCredentialEndpoint        | String                            | Deferred credential endpoint                  | O       |          |
| notificationEndpoint              | String                            | Notification endpoint                         | O       |          |
| credentialRequestEncryption       | EncryptionSupport                 | Request encryption the issuer advertises      | O       | [EncryptionSupport](#82-encryptionsupport) |
| credentialResponseEncryption      | EncryptionSupport                 | Response encryption the issuer advertises     | O       | [EncryptionSupport](#82-encryptionsupport) |
| credentialIdentifiersSupported    | Bool                              | Whether the issuer uses `credential_identifier` | O     |          |
| credentialConfigurationsSupported | [String: CredentialConfiguration] | Offered credentials, keyed by `credential_configuration_id` | M | [CredentialConfiguration](#81-credentialconfiguration) |

<br>

## 8.1. CredentialConfiguration

### Description
`One credential the issuer offers.`

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
| Name                                 | Type                     | Description                              | **M/O** | **Note** |
|--------------------------------------|--------------------------|------------------------------------------|---------|----------|
| format                               | SupportedFormat          | Credential format                        | M       | [SupportedFormat](#88-supportedformat) |
| scope                                | String                   | OAuth scope for this credential          | O       |          |
| cryptographicBindingMethodsSupported | [String]                 | Holder binding methods supported         | O       |          |
| credentialSigningAlgValuesSupported  | [SigningAlg]             | Issuer signing algorithms                | O       | [SigningAlg](#89-signingalg) |
| proofTypesSupported                  | [String: ProofSupport]   | Accepted holder proof types              | O       | [ProofSupport](#86-proofsupport) |
| vct                                  | String                   | SD-JWT VC type                           | O       |          |
| doctype                              | String                   | mdoc doctype                             | O       |          |
| policy                               | CredentialPolicy         | Batch and one-time-use policy            | O       | [CredentialPolicy](#83-credentialpolicy) |
| credentialMetadata                   | CredentialMetadata       | Claims and display information           | O       | [CredentialMetadata](#84-credentialmetadata) |

<br>

## 8.2. EncryptionSupport

### Description
`Encryption the issuer advertises — not what the wallet sends.`

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
| Name               | Type     | Description                          | **M/O** | **Note** |
|--------------------|----------|--------------------------------------|---------|----------|
| algValuesSupported | [String] | Key-agreement algorithms supported   | O       |          |
| encValuesSupported | [String] | Content-encryption algorithms supported | O    |          |
| encryptionRequired | Bool     | Whether encryption is mandatory      | O       |          |

<br>

## 8.3. CredentialPolicy

### Description
`Issuance policy for a credential configuration.`

### Declaration
```swift
public struct CredentialPolicy: Jsonable, FromSnake
{
    public let batchSize: Int?
    public let oneTimeUse: Bool?
}
```

### Property
| Name       | Type | Description                              | **M/O** | **Note** |
|------------|------|------------------------------------------|---------|----------|
| batchSize  | Int  | How many copies are issued at once       | O       |          |
| oneTimeUse | Bool | Whether each copy may be presented once  | O       |          |

<br>

## 8.4. CredentialMetadata

### Description
`Claims and display information for a credential configuration.`

### Declaration
```swift
public struct CredentialMetadata: Codable, Sendable {
    public let claims: [ClaimDetail]?
    public let display: [DisplayInfo]?
}
```

### Property
| Name    | Type          | Description                          | **M/O** | **Note** |
|---------|---------------|--------------------------------------|---------|----------|
| claims  | [ClaimDetail] | The claims this credential carries   | O       | [ClaimDetail](#87-claimdetail) |
| display | [DisplayInfo] | How to present the credential, per locale | O  | [DisplayInfo](#85-displayinfo) |

<br>

## 8.5. DisplayInfo

### Description
`How to present a credential or claim in one locale.`

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
| Name            | Type     | Description                | **M/O** | **Note** |
|-----------------|----------|----------------------------|---------|----------|
| name            | String   | Display name               | O       |          |
| logo            | LogoInfo | Logo image                 | O       | [LogoInfo](#851-logoinfo) |
| locale          | String   | BCP 47 locale tag          | O       |          |
| backgroundColor | String   | Background colour          | O       |          |
| textColor       | String   | Text colour                | O       |          |

<br>

## 8.5.1. LogoInfo

### Description
`A logo image for a display entry.`

### Declaration
```swift
public struct LogoInfo: Jsonable, FromSnake
{
    public let uri: String?
    public let altText: String?
}
```

### Property
| Name    | Type   | Description          | **M/O** | **Note** |
|---------|--------|----------------------|---------|----------|
| uri     | String | Image URI            | O       |          |
| altText | String | Alternative text     | O       |          |

<br>

## 8.6. ProofSupport

### Description
`The holder proof algorithms an issuer accepts for one proof type.`

### Declaration
```swift
public struct ProofSupport: Jsonable, FromSnake
{
    public let proofSigningAlgValuesSupported: [String]?
}
```

### Property
| Name                           | Type     | Description                       | **M/O** | **Note** |
|--------------------------------|----------|-----------------------------------|---------|----------|
| proofSigningAlgValuesSupported | [String] | Accepted proof signing algorithms | O       |          |

<br>

## 8.7. ClaimDetail

### Description
`One claim of an offered credential, as the issuer describes it.`

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
| Name      | Type          | Description                                | **M/O** | **Note** |
|-----------|---------------|--------------------------------------------|---------|----------|
| display   | [DisplayInfo] | Claim labels, per locale                   | O       | [DisplayInfo](#85-displayinfo) |
| mandatory | Bool          | Whether the issuer always includes it      | O       |          |
| path      | [String]      | Path to the claim in the credential        | O       |          |
| valueType | String        | Value type hint                            | O       |          |

<br>

## 8.8. SupportedFormat

### Description
`A credential format token, keeping the issuer's original string so it can be re-sent verbatim.`

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
| Value           | Description                     | **Note**                          |
|-----------------|---------------------------------|-----------------------------------|
| sdjwt(String)   | Decoded from `dc+sd-jwt-did`    | `rawValue` returns the original token |
| mdoc(String)    | Decoded from `mso-mdoc-did`     |                                   |
| unknown(String) | Any other format token          | Kept rather than rejected         |

<br>

## 8.9. SigningAlg

### Description
`A signing algorithm value that an issuer may publish as either a string or a number.`

### Declaration
```swift
public enum SigningAlg: Codable, Sendable {
    case string(String)
    case int(Int)
}
```

### Property
| Value          | Description                          | **Note** |
|----------------|--------------------------------------|----------|
| string(String) | Algorithm published as a JSON string | e.g. `"ES256"` |
| int(Int)       | Algorithm published as a JSON number | e.g. a COSE algorithm id |

<br>

## 9. CredentialOfferResponse

### Description
`An issuer's credential offer — what the wallet receives when issuance is issuer-initiated.`

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
| Name                       | Type     | Description                                  | **M/O** | **Note** |
|----------------------------|----------|----------------------------------------------|---------|----------|
| credentialIssuer           | String   | Issuer identifier                            | M       |          |
| credentialConfigurationIds | [String] | The credentials being offered                | O       |          |
| grants                     | Grants   | How to obtain a token for this offer         | M       | [Grants](#91-grants) |

<br>

## 9.1. Grants

### Description
`The grant types the offer supports.`

### Declaration
```swift
public struct Grants: Jsonable
{
    public let preAuthorizedCode: PreAuthorizedCode?
    public let authorizationCode: AuthorizationCode?
}
```

### Property
| Name              | Type              | Description                      | **M/O** | **Note** |
|-------------------|-------------------|----------------------------------|---------|----------|
| preAuthorizedCode | PreAuthorizedCode | Pre-authorized code grant        | O       | [PreAuthorizedCode](#92-preauthorizedcode). Wire key is `urn:ietf:params:oauth:grant-type:pre-authorized_code` |
| authorizationCode | AuthorizationCode | Authorization code grant         | O       | [AuthorizationCode](#94-authorizationcode) |

<br>

## 9.2. PreAuthorizedCode

### Description
`The pre-authorized code grant of a credential offer.`

### Declaration
```swift
public struct PreAuthorizedCode: Jsonable
{
    public let preAuthorizedCode: String
    public let txCode: TxCode?
}
```

### Property
| Name              | Type   | Description                                | **M/O** | **Note** |
|-------------------|--------|--------------------------------------------|---------|----------|
| preAuthorizedCode | String | The pre-authorized code                    | M       | Wire key is `pre-authorized_code` |
| txCode            | TxCode | Transaction code the holder must enter     | O       | [TxCode](#93-txcode) |

<br>

## 9.3. TxCode

### Description
`How the holder must enter the transaction code, when the issuer requires one.`

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
| Name        | Type   | Description                          | **M/O** | **Note** |
|-------------|--------|--------------------------------------|---------|----------|
| inputMode   | String | Input mode, e.g. `numeric`           | O       |          |
| length      | Int    | Expected length                      | O       |          |
| description | String | Guidance to show the holder          | O       |          |

<br>

## 9.4. AuthorizationCode

### Description
`The authorization code grant of a credential offer.`

### Declaration
```swift
public struct AuthorizationCode: Jsonable
{
    public let issuerState: String?
}
```

### Property
| Name        | Type   | Description                                   | **M/O** | **Note** |
|-------------|--------|-----------------------------------------------|---------|----------|
| issuerState | String | Issuer state to carry through the authorization | O     |          |

<br>

## 10. TokenRequest

### Description
`The token request the wallet sends for a pre-authorized code grant.`

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
| Name                 | Type                   | Description                          | **M/O** | **Note** |
|----------------------|------------------------|--------------------------------------|---------|----------|
| grantType            | String                 | Grant type                           | M       | Fixed to the pre-authorized code grant |
| preAuthorizedCode    | String                 | The code from the credential offer   | M       | Encoded as `pre-authorized_code` |
| txCode               | String                 | Transaction code the holder entered  | O       |          |
| authorizationDetails | [AuthorizationDetails] | Which credentials the token is for   | M       | [AuthorizationDetails](#12-authorizationdetails) |

<br>

## 11. TokenResponse

### Description
`The issuer's token response. Passed to requestIssueOID4VC.`

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
| Name                 | Type                   | Description                                   | **M/O** | **Note** |
|----------------------|------------------------|-----------------------------------------------|---------|----------|
| accessToken          | String                 | Access token for the credential endpoint      | M       |          |
| tokenType            | String                 | Token type, e.g. `Bearer`                     | M       |          |
| cNonce               | String                 | Nonce to bind into the holder proof           | O       |          |
| expiresIn            | Int                    | Token lifetime in seconds                     | O       |          |
| authorizationDetails | [AuthorizationDetails] | Credential identifiers the token covers       | O       | [AuthorizationDetails](#12-authorizationdetails) |

<br>

## 12. AuthorizationDetails

### Description
`Which credential configuration a token request or response applies to.`

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
| Name                      | Type     | Description                                        | **M/O** | **Note** |
|---------------------------|----------|----------------------------------------------------|---------|----------|
| type                      | String   | Detail type                                        | M       | Fixed to `openid_credential` |
| credentialConfigurationId | String   | The credential configuration this applies to       | M       |          |
| credentialIdentifiers     | [String] | Identifiers the issuer assigned within that configuration | O | Pass one back as `requestIssueOID4VC(credentialIdentifier:)` |

<br>

## 13. OID4VCIIssuerList

### Description
`List of OID4VCI issuers the wallet may start an issuance with.`

The wire format is camelCase (an OmniOne server API, not the snake_case OID4VCI spec), so unlike the
OID4VCI DTOs this model is not `FromSnake`.

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
| Name  | Type                | Description                 | **M/O** | **Note** |
|-------|---------------------|-----------------------------|---------|----------|
| count | Int                 | Number of entries in `items` | M      |          |
| items | [OID4VCIIssuerItem] | The issuer entries          | M       | [OID4VCIIssuerItem](#131-oid4vciissueritem) |

<br>

## 13.1. OID4VCIIssuerItem

### Description
`One OID4VCI issuer entry: its identifier and the endpoints needed to begin issuance.`

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
| Name                        | Type   | Description                                          | **M/O** | **Note** |
|-----------------------------|--------|------------------------------------------------------|---------|----------|
| credentialIssuer            | String | Issuer identifier                                    | M       | Matches `credential_issuer` of the issuer metadata |
| credentialIssuerMetadataUri | String | Where to fetch this issuer's `IssuerMetadataResponse` | M      | [IssuerMetadataResponse](#8-issuermetadataresponse) |
| userInitiationUri           | String | Where the wallet starts a wallet-initiated issuance  | O       | Absent for issuers that only support issuer-initiated offers |

<br>

## 14. AnyJSON

### Description
`A lossless JSON value container, used wherever the spec allows arbitrary JSON.`

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
| Value                 | Description                     | **Note**                                  |
|-----------------------|---------------------------------|-------------------------------------------|
| null                  | JSON `null`                     |                                           |
| bool(Bool)            | JSON boolean                    |                                           |
| number(Double)        | JSON number                     | Always kept as `Double`                   |
| string(String)        | JSON string                     |                                           |
| array([AnyJSON])      | JSON array                      |                                           |
| object([String: AnyJSON]) | JSON object                 |                                           |

### Method
| Name             | Description                                                | **Note** |
|------------------|------------------------------------------------------------|----------|
| asBool / asDouble / asString / asArray / asObject | Reads the value when it is of that case, otherwise `nil` | |
| toFoundation()   | Converts to Foundation types for `JSONSerialization`       | `null` becomes `NSNull()` |

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


    


