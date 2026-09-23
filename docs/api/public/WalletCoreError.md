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

iOS WalletCoreError
==

- Topic: WalletCoreError
- Author: JooHyun Park
- Date: 2026-09-22
- Version: v2.0.0

| Version          | Date       | Changes                  |
| ---------------- | ---------- | ------------------------ |
| v2.0.0           | 2026-09-22 | Add OID4VCManager error, mdoc / proximity and key agreement errors |
| v1.0.2           | 2025-09-09 | Fixed DID-related error  |
| v1.0.1           | 2025-04-28 | Add ZKP Error            |
| v1.0.0           | 2024-08-28 | Initial version          |

<div style="page-break-after: always;"></div>

# Table of Contents
- [Model](#model)
  - [WalletCoreError](#walletcoreerror)
- [Error Code](#error-code)
  - [1. Common](#1-common)
  - [2. KeyManager](#2-keymanager)
    - [2.1. Generate Key(001xx)](#21-generate-key001xx)
    - [2.2. Pin(002xx)](#22-pin002xx)
    - [2.3. Biometrics(003xx)](#23-biometrics003xx)
    - [2.4. Get KeyInfo(004xx)](#24-get-keyInfo004xx)
    - [2.5. ETC.(009xx)](#25-etc009xx)
  - [3. DIDManager](#3-didmanager)
    - [3.1. Generate random(011xx)](#31-generate-random011xx)
    - [3.2. Create document(012xx)](#32-create-document012xx)
    - [3.3. Edit document(013xx)](#33-edit-document013xx)
    - [3.4. DID Document(014xx)](#34-did-document014xx)
  - [4. VCManager](#4-vcmanager)
  - [5. ZKPManager](#5-zkpmanager)
    - [5.1. ZKPCommon(041xx)](#51-zkpcommon)
    - [5.2. MasterSecret(042xx)](#52-mastersecret)
    - [5.3. IssueCredential(043xx)](#53-issuecredential)
    - [5.4. GetCredential(044xx)](#54-getcredential)
    - [5.5. SearchCredentials(045xx)](#55-searchcredential)
    - [5.6. Proof(046xx)](#56-proof)
  - [6. OID4VCManager](#6-oid4vcmanager)
    - [6.1. Common(051xx)](#61-common051xx)
    - [6.2. JWE(052xx)](#62-jwe052xx)
    - [6.3. OID4VCI(053xx)](#63-oid4vci053xx)
    - [6.4. Verify(054xx)](#64-verify054xx)
    - [6.5. OID4VP(055xx)](#65-oid4vp055xx)
    - [6.6. Proximity(056xx)](#66-proximity056xx)
  - [7. StorageManager](#7-storagemanager)
    - [7.1. Save(101xx)](#71-save101xx)
    - [7.2. Update(102xx)](#72-update102xx)
    - [7.3. Remove(103xx)](#73-remove103xx)
    - [7.4. Find(104xx)](#74-find104xx)
    - [7.5. Item type(105xx)](#75-item-type105xx)
    - [7.6. ETC.(109xx)](#76-etc109xx)
  - [8. Signable](#8-signable)
    - [8.1. KeyPair(111xx)](#81-keypair111xx)
    - [8.2. Signature(112xx)](#82-signature112xx)
  - [9. SecureEnclave](#9-secureenclave)
    - [9.1. KeyPair(121xx)](#91-keypair121xx)
    - [9.2. Signature(122xx)](#92-signature122xx)
    - [9.3. Encryption(123xx)](#93-encryption123xx)
    - [9.4. Key agreement(124xx)](#94-key-agreement124xx)

# Model
## WalletCoreError

### Description
```
Error struct for Wallet Core. It has code and message pair.
Code starts with MSDKWLT.
```

### Declaration
```swift
// Declaration in Swift
public struct WalletCoreError: Error {
    public let code: String
    public let message: String
}
```

### Property

| Name               | Type       | Description                            | **M/O** | **Note**              |
|--------------------|------------|----------------------------------------|---------|-----------------------|
| code               | String     | Error code. It starts with MSDKWLT     |    M    |                       | 
| message            | String     | Error description                      |    M    |                       | 

<br>

# Error Code
## 1. Common

| Error Code   | Error Message                        | Description                       | Action Required                   |
|--------------|--------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLTxx000 | Invalid parameter : {name}           | Given parameter is invalid        | Check proper data type and length |
| MSDKWLTxx001 | Duplicate parameter : {name}         | Given parameters are duplicated   | Check the array value             |
| MSDKWLTxx002 | Fail to decode : {name}              | Given data couldn't be decoded    | Check the data is valid           |

<br>

## 2. KeyManager
### 2.1. Generate Key(001xx)

| Error Code   | Error Message               | Description                       | Action Required                   |
|--------------|-----------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT00100 | Given key id already exists | -                                 | Use not duplicated key id         |
| MSDKWLT00101 | Given keyGenRequest does not<br>conform to {Wallet/Secure}KeyGenRequest | - | Use WalletKeyGenRequest when generate wallet key <br>or SecureKeyGenRequest for secure key |

<br>

### 2.2. Pin(002xx)

| Error Code   | Error Message                     | Description                       | Action Required                   |
|--------------|-----------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT00200 | Given new pin is equal to old pin | -                                 | Use another new pin               |
| MSDKWLT00201 | Given key id is not pin auth type | -                                 | Use pin key id                    |

<br>

### 2.3. Biometrics(003xx)

| Error Code   | Error Message                                       | Description                                   | Action Required                               |
|--------------|-----------------------------------------------------|-----------------------------------------------|-----------------------------------------------|
| MSDKWLT00300 | Error occurs while evaluate policy : {detail error} | -                                             | Depend on detail error cases                  |
| MSDKWLT00301 | Cannot get domain state                             | Cannot get domain state value from the system | Use another new pin                           |
| MSDKWLT00302 | User biometrics changed                             | -                                             | Current Secure key is expired.<br>Use new one |

<br>

### 2.4. Get KeyInfo(004xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT00400 | Found no key by given keyType        | -                                 | Generate proper key or change keyType |
| MSDKWLT00401 | Insufficient result by given keyType | -                                 | Generate proper key or change keyType |

<br>

### 2.5. ETC.(009xx)

| Error Code   | Error Message                     | Description                       | Action Required                   |
|--------------|-----------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT00900 | Given algorithm is unsupported    | -                                 | Use supported algorithm           |

<br>

## 3. DIDManager

### 3.1. Generate random(011xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT01100 | Fail to generate random        | -                                 | - |

<br>

### 3.2. Create document(012xx)

| Error Code   | Error Message                 | Description | Action Required                                                |
|--------------|--------------------------------|-------------|----------------------------------------------------------------|
| MSDKWLT01200 | The document already exists    | -           | Do not call this function when already DID document file saved |

<br>

### 3.3. Edit document(013xx)

| Error Code   | Error Message                                   | Description | Action Required                                                                                   |
|--------------|-------------------------------------------------|-------------|--------------------------------------------------------------------------------------------------|
| MSDKWLT01300 | Duplicate key id exists in verification method  | -           | Check key id to add in verification method. Do not add duplicate key id                          |
| MSDKWLT01301 | Not found key id in verification method         | -           | Check key id to remove in verification method. It must remove key id that exist in verification method |
| MSDKWLT01302 | Duplicate service id exists in service          | -           | Check service id to add in service. Do not add duplicate service id                              |
| MSDKWLT01303 | Not found service id in service                 | -           | Check service id to remove in service. It must remove service id that exist in service           |

<br>

### 3.4. DID Document(014xx)

| Error Code   | Error Message                             | Description | Action Required |
|--------------|-------------------------------------------|-------------|-----------------|
| MSDKWLT01400 | The stored DID document could not be found | -           | -               |


<br>

## 4. VCManager

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT02100 | No claim code in credential(VC) for presentation. Not found code(s) : {claim code}        | Can't find claim code(s) in wallet to make verifiable presentation   | Check your claim code of credential(VC) in wallet is exist to include at the verifiable presentation |

<br>

## 5. ZKPManager
### 5.1. ZKPCommon(041xx)

| Error Code   | Error Message                             | Description                       | Action Required                   |
|--------------|-------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT04100 | Value by key {value} not found in {group} | -                                 | -                                 |
| MSDKWLT04101 | Delta must be positive                    | -                                 | -                                 |
| MSDKWLT04102 | Big Number compare failed {lhs} and {rhs} | -                                 | -                                 |
| MSDKWLT04103 | Failed to inverse {value}                 | -                                 | -                                 |

<br>

### 5.2. MasterSecret(042xx)

| Error Code   | Error Message               | Description                       | Action Required                   |
|--------------|-----------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT04200 | Master secret not found     | -                                 | -                                 |

<br>

### 5.3. IssueCredential(043xx)

| Error Code   | Error Message                            | Description                       | Action Required                   |
|--------------|------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT04300 | Failed to verify signature correctness proof | -                                 | -                                 |


<br>

### 5.4. GetCredential(044xx)

| Error Code   | Error Message                              | Description                       | Action Required                   |
|--------------|--------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT04400 | Credential not found in storage           | -                                 | Issue new credential              |
| MSDKWLT04401 | Credential not found by identifiers in storage | -                                 | Use proper identifier            |



<br>

### 5.5. SearchCredentials(045xx)

| Error Code   | Error Message                                     | Description                       | Action Required                   |
|--------------|---------------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT04500 | Proof request's predicate must have restrictions | -                                 | Get new proof request             |
| MSDKWLT04501 | Not found available request attribute             | -                                 | Issue proper credential           |
| MSDKWLT04502 | Not found available predicate attribute           | -                                 | Issue proper credential           |


<br>

### 5.6. Proof(046xx)

| Error Code   | Error Message                                  | Description                       | Action Required                   |
|--------------|------------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT04600 | Invalid referent name                          | -                                 | Use valid referent name           |
| MSDKWLT04601 | Invalid self attribute referent                | -                                 | Use valid referent name           |
| MSDKWLT04602 | Invalid attribute referent name                | -                                 | Use valid referent name or Use valid cred id |
| MSDKWLT04603 | Invalid predicate referent name                | -                                 | Use valid cred id                 |
| MSDKWLT04604 | Insufficient referents for proof request       | -                                 | All attribute and predicate referents must be required |
| MSDKWLT04605 | {detail} is duplicated                         | -                                 | -                                 |
| MSDKWLT04606 | Not found schema from proof param             | -                                 | Use proper schema                 |
| MSDKWLT04607 | Not found credential definition from proof param | -                                 | Use proper credential definition |

<br>

## 6. OID4VCManager

Errors raised by the OpenID4VCI (issuance), OpenID4VP (presentation) and ISO/IEC 18013-5 proximity
layer. They surface through `requestIssueOID4VC`, `matchCredentials`, `createVpToken`,
`matchMdocRequest` and `createDeviceResponse`.

### 6.1. Common(051xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT05100 | Unsupported in : {id}                | The requested credential configuration id is not offered by the issuer | Use an id listed in the issuer metadata |
| MSDKWLT05101 | Unsupported format : {format}        | The credential format is not one the SDK can issue, store or present   | Use a supported format                  |
| MSDKWLT05102 | Invalid JWS : {detail}               | A JWS could not be decoded, or its payload could not be read           | Depend on detail error cases            |
| MSDKWLT05103 | Invalid mdoc : {detail}              | An `IssuerSigned` could not be decoded, or its MSO uses a digest algorithm the SDK does not implement | Depend on detail error cases |

<br>

### 6.2. JWE(052xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT05210 | Invalid JWE                          | The token is not a well-formed compact JWE | Check the token is complete and not truncated |
| MSDKWLT05211 | Unsupported algorithm for JWE        | `alg` is not `ECDH-ES`, or the token carries an encrypted key (key wrapping) | Use direct ECDH-ES |
| MSDKWLT05212 | Unsupported JWE key                  | The ephemeral or recipient key is not an EC P-256 key | Use a P-256 key                |
| MSDKWLT05213 | invalid SealedBox                    | Ciphertext, IV and tag could not be assembled into a sealed box | Check the token is not truncated |
| MSDKWLT05214 | Authentication failed                | The AEAD tag did not verify — wrong key or tampered ciphertext | Check the recipient key         |
| MSDKWLT05215 | Failed to encrypt                    | Content encryption failed         | -                                     |
| MSDKWLT05216 | Key derivation failed                | ECDH-ES key agreement or the Concat KDF step failed | Check the recipient public key |
| MSDKWLT05217 | Invalid KDF input                    | The key-derivation inputs are malformed | -                                 |

<br>

### 6.3. OID4VCI(053xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT05300 | Invalid credential response          | The issuer's credential response is missing or malformed | Check the issuer response      |

<br>

### 6.4. Verify(054xx)

| Error Code   | Error Message                             | Description                       | Action Required                       |
|--------------|-------------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT05400 | Not found kid for verify                  | The JWS header carries no `kid` to resolve a verification key | -                 |
| MSDKWLT05401 | Failed to verify signature                | The signature did not verify with the resolved key | Check the signer's key           |
| MSDKWLT05402 | No 'jwk' in the JWS header to verify with | Verification was asked to use the embedded key, but the header carries none | Pass the verification key explicitly |
| MSDKWLT05403 | Element {elementIdentifier} does not match its digest in the MSO | An issuer-signed item's bytes do not hash to the digest the MSO carries for it | Check the issuer's document |
| MSDKWLT05404 | The mdoc is outside its validity period   | The issuance moment is before `validFrom` or after `validUntil` of the MSO | Check the issuer's document |
| MSDKWLT05405 | The mdoc is bound to a key this wallet does not hold | The MSO's device key is not the holder key the credential was requested with | Check the issuer's document |

<br>

### 6.5. OID4VP(055xx)

| Error Code   | Error Message                                     | Description                       | Action Required                       |
|--------------|---------------------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT05500 | Presentation for format {format} is not supported  | No presenter is registered for the credential format the query asks for | Use a credential of a supported format |
| MSDKWLT05501 | Invalid DCQL query: {detail}                       | The verifier's `dcql_query` is malformed or self-inconsistent | Check the verifier's request  |
| MSDKWLT05502 | No credentials matched the request                 | No stored credential satisfies the query | Issue a credential that satisfies it |
| MSDKWLT05503 | Required credential_sets not satisfied: {detail}   | A required `credential_sets` option cannot be filled by the matches | Issue the missing credential |
| MSDKWLT05504 | Matched credential not found                       | A selected credential id is no longer in the wallet | Re-run `matchCredentials`     |
| MSDKWLT05505 | Holder signing key not found                       | The holder key needed to sign the presentation is missing | Create the holder key   |
| MSDKWLT05506 | No verifier encryption key found in client_metadata for direct_post.jwt | The request asks for an encrypted response but supplies no key | Check the verifier's `client_metadata` |
| MSDKWLT05507 | Unsupported response encryption ({detail})         | The verifier asks for a key-agreement or content-encryption algorithm the SDK does not implement | Use `ECDH-ES` with `A128GCM`/`A256GCM` |
| MSDKWLT05508 | Invalid selected credentials: {detail}             | The selection does not belong to the request, is empty, drops claims the query asked for, or a claim code names more than one claim | Pass back what `matchCredentials` returned, dropping whole entries only |
| MSDKWLT05509 | Unsupported response_mode : {mode}                 | The request's `response_mode` is neither `direct_post` nor `direct_post.jwt` | Use a POST-based response mode |

<br>

### 6.6. Proximity(056xx)

Raised by `matchMdocRequest` and `createDeviceResponse`.

| Error Code   | Error Message                                               | Description                       | Action Required                       |
|--------------|-------------------------------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT05600 | No stored document can answer any docRequest                | No stored mdoc can fill even one element of any `docRequest` | Issue a document of the requested type |
| MSDKWLT05610 | No document was selected                                    | `createDeviceResponse` was called with an empty `selected` | Do not call it when the holder refuses everything |
| MSDKWLT05611 | Invalid selected mdoc documents: {detail}                   | A selected entry does not belong to the fresh match of the request, or names a code the match did not offer | Prune what `matchMdocRequest` returned; never rebuild entries |
| MSDKWLT05612 | A selected document carries no claim code                   | A selected entry has an empty `claimCodes` | Drop the entry instead of emptying its codes |
| MSDKWLT05613 | The same document is selected twice for the same docRequest | Two selected entries share `docRequestIndex` and `credentialId` | Select each document once per request |
| MSDKWLT05614 | A selected document names the same claim code twice         | A selected entry repeats a code in `claimCodes` | Keep each code once |
| MSDKWLT05620 | Invalid DeviceRequest: {detail}                             | The bytes are not a well-formed `DeviceRequest` | Check what the transport SDK handed over |
| MSDKWLT05621 | Invalid SessionTranscript: {detail}                         | The bytes are neither `SessionTranscriptBytes` nor a `SessionTranscript` array | Pass the transcript as the transport SDK handed it over |

<br>

## 7. StorageManager

### 7.1. Save(101xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10100 | Fail to save wallet. error : {detail error} | -                          | Depend on detail error cases          |
| MSDKWLT10101 | Item duplicated with it in wallet    | -                                 | Use a different item id that does not duplicate one of the items in your wallet |

<br>

### 7.2. Update(102xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10200 | No item to update in wallet          | -                                 | Check that item id is exist in wallet |

<br>

### 7.3. Remove(103xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10300 | No items to remove in wallet         | -                                 | Check that item id is exist in wallet |
| MSDKWLT10301 | Fail to remove items from wallet. error : {detail error} | -             | Depend on detail error cases          |

<br>

### 7.4. Find(104xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10400 | No items saved in wallet             | -                                 | Check any item is exist in wallet     |
| MSDKWLT10401 | No items to find in wallet           | -                                 | Check that item id is exist in wallet |
| MSDKWLT10402 | Fail to read wallet file. error : {detail error} | -                     | Depend on detail error cases          |

<br>

### 7.5. Item type(105xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10500 | Malformed external wallet format. error : {detail error} | -             | Depend on detail error cases          |
| MSDKWLT10501 | Malformed wallet signature           | Wallet is corrupted.              | -                                     |
| MSDKWLT10502 | Malformed inner wallet format. error : {detail error} | -                | Depend on detail error cases          |
| MSDKWLT10503 | Malformed item object type about item of inner wallet. error : {detail error} | - | Depend on detail error cases |

<br>

### 7.6. ETC.(109xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10900 | Unexpected error occurred. error : {detail error} | -                    | Depend on detail error cases          |

<br>

## 8. Signable

### 8.1. KeyPair(111xx)

| Error Code   | Error Message                        | Description                       | Action Required                   |
|--------------|--------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT11100 | Not proper public key format         | -                                 | -                                 |
| MSDKWLT11101 | Not proper private key format        | -                                 | -                                 |
| MSDKWLT11102 | Private and public keys are not pair | -                                 | -                                 |

<br>

### 8.2. Signature(112xx)

| Error Code   | Error Message                               | Description                       | Action Required                   |
|--------------|---------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT11200 | Converting failed to compact representation | -                                 | -                                 |
| MSDKWLT11201 | Signing failed : {detail error}             | -                                 | Depend on detail error cases      |
| MSDKWLT11202 | Failed to verify signature : {detail error} | -                                 | Depend on detail error cases      |

<br>

## 9. SecureEnclave

### 9.1. KeyPair(121xx)

| Error Code   | Error Message                                            | Description                                        | Action Required                   |
|--------------|----------------------------------------------------------|----------------------------------------------------|-----------------------------------|
| MSDKWLT12100 | Failed to create secure key : {detail error}             | Error occurs via Secure Enclave                    | Depend on detail error cases      |
| MSDKWLT12101 | Failed to copy public key                                | Cannot copy public key from SecKey                 | -                                 |
| MSDKWLT12102 | Failed to get public key representation : {detail error} | Cannot copy compressed public key data from SecKey | Depend on detail error cases      |
| MSDKWLT12103 | Cannot find secure key by given conditions               | -                                                  | Generate new key                  |
| MSDKWLT12104 | Failed to delete secure key                              | -                                                  | -                                 |

  <br>

### 9.2. Signature(122xx)

| Error Code   | Error Message                   | Description                       | Action Required                   |
|--------------|---------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT12200 | Signing failed : {detail error} | -                                 | Depend on detail error cases      |

  <br>

### 9.3. Encryption(123xx)

| Error Code   | Error Message                                 | Description                       | Action Required                   |
|--------------|-----------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT12300 | Cannot create encrypted data : {detail error} | Error occurs via Secure Enclave   | Depend on detail error cases      |
| MSDKWLT12301 | Cannot create decrypted data : {detail error} | Error occurs via Secure Enclave   | Depend on detail error cases      |

  <br>

### 9.4. Key agreement(124xx)

| Error Code   | Error Message                                 | Description                       | Action Required                   |
|--------------|-----------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT12400 | The key cannot perform key agreement          | The Secure Enclave key was created without key agreement | Not surfaced through `WalletAPI`: `createDeviceResponse` falls back to `deviceSignature` |
| MSDKWLT12401 | Key agreement failed : {detail error}         | ECDH with the reader's ephemeral key failed | Depend on detail error cases      |

  <br>
