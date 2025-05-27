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

iOS Wallet API
==

- Subject: WalletAPI
- Writer: JooHyun Park
- Date: 2025-05-27
- Version: v2.0.0

| Version | Date       | History                  |
| ------- | ---------- | -------------------------|
| v2.0.0  | 2025-05-27 | Add ZKP-related function |
| v1.0.0  | 2024-10-18 | Initial                  |

<div style="page-break-after: always;"></div>

# Table of Contents
- [APIs](#api-list)
    - [0. constructor](#0-constructor)
    - [1. isExistWallet](#1-isexistwallet)
    - [2. createWallet](#2-createwallet)
    - [3. deleteWallet](#3-deletewallet)
    - [4. createWalletTokenSeed](#4-createwallettokenseed)
    - [5. createNonceForWalletToken](#5-createnonceforwallettoken)
    - [6. bindUser](#6-binduser)
    - [7. unbindUser](#7-unbinduser)
    - [8. registerLock](#8-registerlock)
    - [9. authenticateLock](#9-authenticatelock)
    - [10. createHolderDIDDoc](#10-createholderdiddoc)
    - [11. createSignedDIDDoc](#11-createsigneddiddoc)
    - [12. getDIDDocument](#12-getdiddocument)
    - [13. generateKeyPair](#13-generatekeypair)
    - [14. isLock](#14-islock)
    - [15. getSignedWalletInfo](#15-getsignedwalletinfo)
    - [16. requestRegisterUser](#16-requestregisteruser)
    - [17. getSignedDIDAuth](#17-getsigneddidauth)
    - [18. requestIssueVc](#18-requestissuevc)
    - [19. requestRevokeVc](#19-requestrevokevc)
    - [20. getAllCredentials](#20-getallcredentials)
    - [21. getCredential](#21-getcredential)
    - [22. deleteCredentials](#22-deletecredentials)
    - [23. createEncVp](#23-createencvp)
    - [24. getKeyInfos](#24-getkeyinfos)
    - [25. getKeyInfos](#25-getkeyinfos)
    - [26. isAnyKeysSaved](#26-isanykeyssaved)
    - [27. changePIN](#27-changepin)
    - [28. isZKPCredentialSaved](#28-iszkpcredentialsaved)  
    - [29. deleteZKPCredentials](#29-deletezkpcredentials)  
    - [30. getZKPCredentials](#30-getzkpcredentials)  
    - [31. getAllZKPCrentials](#31-getallzkpcrentials)  
    - [32. searchCredentials](#32-searchcredentials)  
    - [33. createZKProof](#33-createzkproof)  
    - [34. createEncZKProof](#34-createenczkproof)
    
- [Enumerators](#enumerators)
    - [1. WalletTokenPurposeEnum](#1-wallet_token_purpose)

- [Value Object](#value-object)
    - [1. WalletTokenSeed](#1-wallettokenseed)
    - [2. WalletTokenData](#2-wallettokendata)
    - [3. Provider](#3-provider)
    - [4. SignedDIDDoc](#4-signeddiddoc)
    - [5. SignedWalletInfo](#5-signedwalletinfo)
    - [6. DIDAuth](#6-didauth)


# API List
## 0. constructor

### Description
 `WalletApi construct`

### Declaration

```swift
public static let shared: WalletAPI
```

### Parameters

| Name      | Type   | Description                             | **M/O** | **Note** |
|-----------|--------|----------------------------------|---------|----------|
|           |        |                                  | M       |          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| WalletApi | WalletAPI instance | M       |          |

### Usage

```swift
WalletAPI.shared
```

<br>

## 1. isExistWallet

### Description
 `Check whether DeviceKey Wallet exists.`

### Declaration

```swift
func isExistWallet() -> Bool
```

### Parameters

N/A

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool    | Returns whether the wallet exists.   | M       |          |

### Usage

```swift
let exists = WalletAPI.shared.isExistWallet()
```

<br>

## 2. createWallet

### Description
`Create a DeviceKey Wallet.`

### Declaration

```swift
func createWallet(tasURL: String, walletURL: String) async throws -> Bool
```

### Parameters

| Name      | Type   | Description                      | **M/O** | **Note** |
|-----------|--------|----------------------------------|---------|----------|
| tasURL    | String | TAS URL                          | M       |          |
| walletURL | String | Wallet URL                       | M       |          |


### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| boolean | Returns whether wallet creation was successful. | M       |          |

### Usage

```swift
let success = try await WalletAPI.shared.createWallet(tasURL:TAS_URL, walletURL: WALLET_URL)
```

<br>

## 3. deleteWallet

### Description
`Delete DeviceKey Wallet..`

### Declaration

```swift
func deleteWallet() throws -> Bool
```

### Parameters


### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool | Returns whether the wallet deletion was successful. | M       |          |

### Usage

```swift
let success = try WalletAPI.deleteWallet()
```

<br>

## 4. createWalletTokenSeed

### Description
`Generate a wallet token seed.`

### Declaration

```swift
func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String, userId: String) throws -> WalletTokenSeed
```

### Parameters

| Name      | Type   | Description                      | **M/O** | **Note** |
|-----------|--------|----------------------------------|---------|----------|
| purpose   | WalletTokenPurposeEnum |use token         | M       |[WalletTokenPurposeEnum](#1-wallet_token_purpose)         |
| pkgName   | String | CA Package Name                  | M       |          |
| userId    | String | user ID                          | M       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| WalletTokenSeed | Wallet Token Seed Object   | M       |[WalletTokenSeed](#1-wallettokenseed)          |

### Usage

```swift
let tokenSeed = try WalletAPI.shared.createWalletTokenSeed(purpose: purpose, "org.opendid.did.ca", "user_id");
```

<br>

## 5. createNonceForWalletToken

### Description
`Generate a nonce for creating wallet tokens.`

### Declaration

```swift
func createNonceForWalletToken(walletTokenData: WalletTokenData) throws -> String
```

### Parameters

| Name           | Type           | Description                  | **M/O** | **Note** |
|----------------|----------------|-----------------------|---------|----------|
| walletTokenData | WalletTokenData | Wallet Token Data      | M       |[WalletTokenData](#2-wallettokendata)          |

### Returns

| Type    | Description              | **M/O** | **Note** |
|---------|-------------------|---------|----------|
| String  | Nonce for wallet token generation | M       |          |

### Usage

```swift
let walletTokenData = try WalletTokenData.init(from: responseData)
let nonce = try WalletAPI.shared.createNonceForWalletToken(walletTokenData: walletTokenData);
```

<br>

## 6. bindUser

### Description
`Perform user personalization in Wallet.`

### Declaration

```swift
func bindUser(hWalletToken: String) throws -> Bool
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | Wallet Token                  | M       |          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool    | Returns whether personalization was successful. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.bindUser(hWalletToken: hWalletToken);
```

<br>

## 7. unbindUser

### Description
`Perform user depersonalization.`

### Declaration

```swift
public unbindUser(hWalletToken: String) throws -> Bool
```

### Parametersx

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | Wallet Token                  | M       |          |

### Returns

| Type    | Description                                       | **M/O** | **Note** |
| ------- | ------------------------------------------------- | ------- | -------- |
| boolean | Returns whether depersonalization was successful. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.unbindUser(hWalletToken: hWalletToken);
```

<br>

## 8. registerLock

### Description
`Sets the lock status of the wallet.`

### Declaration

```swift
func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool
```

### Parameters

| Name         | Type   | Description                        | **M/O** | **Note** |
|--------------|--------|-----------------------------|---------|----------|
| hWalletToken | String | Wallet Token                   | M       |          |
| passcode     | String | Unlock PIN               | M       |          |
| isLock       | Bool | Whether the lock is activated           | M       |          |

### Returns

| Type | Description                                    | **M/O** | **Note** |
| ---- | ---------------------------------------------- | ------- | -------- |
| Bool | Returns whether the lock setup was successful. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.registerLock(hWalletToken: hWalletToken, passcode:"123456", isLock: true);
```

<br>

## 9. authenticateLock

### Description
`Perform authentication to unlock the wallet.`

### Declaration

```swift
func authenticateLock(hWalletToken: String, passcode: String) throws -> Data?
```

### Parameters

| Name         | Type   | Description  | **M/O** | **Note**                  |
| ------------ | ------ | ------------ | ------- | ------------------------- |
| hWalletToken | String | Wallet Token | M       |                           |
| passcode     | String | Unlock PIN   | M       | PIN set when registerLock |

### Returns

Void

### Usage

```swift
try WalletAPI.shared.authenticateLock(hWalletToken: hWalletToken, passcode: "123456");
```

<br>

## 10. createHolderDIDDocument

### Description
`Create a user DID Document.`

### Declaration

```swift
func createDIDDocument(hWalletToken: String) throws -> DIDDocument
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | Wallet Token                  | O       |          |


### Returns

| Type         | Description                  | **M/O** | **Note** |
|--------------|-----------------------|---------|----------|
| DIDDocument  | DID Document   | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.createHolderDIDDocument(hWalletToken: hWalletToken);
```

<br>

## 11. createSignedDIDDoc

### Description
`Creates a signed user DID Document object.`

### Declaration

```swift
func createSignedDIDDoc(hWalletToken: String, passcode: String) throws -> SignedDIDDoc
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | Wallet Token                  | M       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| SignedDidDoc | Signed DID Document Object   | M       |[SignedDIDDoc](#4-signeddiddoc)          |

### Usage

```swift
let signedDidDoc = try WalletAPI.shared.createSignedDIDDoc(hWalletToken: hWalletToken);
```

<br>

## 12. getDIDDocument

### Description
`Look up the DID Document.`

### Declaration

```swift
func getDIDDocument(type: Int) throws -> DIDDocument
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| type  | Int | 1 : deviceKey DID Document, 2: holder DID document                  | M       |  DIDDataModel reference     |

### Returns

| Type         | Description                  | **M/O** | **Note** |
|--------------|-----------------------|---------|----------|
| DIDDocument  | DID Document       | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.getDIDDocument(type: DidDocumentType.HolderDidDocumnet);
```

<br>

## 13. generateKeyPair

### Description
`Generate a PIN key pair for signing and store it in your Wallet.`

### Declaration

```swift
func generateKeyPair(hWalletToken: String, passcode: String? = nil, keyId: String, algType:AlgorithmType, promptMsg: String? = nil) throws -> Bool
```

### Parameters

| Name         | Type   | Description                        | **M/O** | **Note** |
|--------------|--------|-----------------------------|---------|----------|
| hWalletToken | String |Wallet Token                   | M       |          |
| passCode     | String |PIN for signing              | M       | When generating a key for PIN signing        | 
| keyId     | String |PIN for ID              | M       |         | 
| algType     | AlgorithmType |Key algorithm type for signing               | M       |         | 
| promptMsg     | String |Biometric authentication prompt message              | M       |         | 

### Returns

Bool

### Usage

```swift
let success = try WalletAPI.shared.generateKeyPair(hWalletToken:hWalletToken, passcode:"123456", keyId:"pin", algType: AlgoritheType.secp256r1);


let success = try WalletAPI.shared.generateKeyPair(hWalletToken:hWalletToken, keyId:"bio", algType: AlgoritheType.secp256r1, promptMsg: "message");
```

<br>

## 14. isLock

### Description
`Check the lock type of the wallet.`

### Declaration

```swift
func isLock(hWalletToken: String) throws -> Bool
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | Wallet Token                  | M       |          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool | Returns the wallet lock type. | M       |          |

### Usage

```swift
let isLocked = try WalletAPI.shared.isLock(hWalletToken: hWalletToken);
```

<br>

## 15. getSignedWalletInfo

### Description
`signed wallet information.`

### Declaration

```swift
func getSignedWalletInfo(String hWalletToken) throws -> SignedWalletInfo
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | Wallet Token                  | M       |          |

### Returns

| Type             | Description                    | **M/O** | **Note** |
|------------------|-------------------------|---------|----------|
| SignedWalletInfo | Signed WalletInfo object      | M       |[SignedWalletInfo](#5-signedwalletinfo)          |

### Usage

```swift
let signedInfo = try WalletAPI.shared.getSignedWalletInfo(hWalletToken: hWalletToken);
```

<br>

## 16. requestRegisterUser

### Description
`Request user registration.`

### Declaration

```swift
func String requestRegisterUser(TasURL: String, id: String, txId: String, hWalletToken: String, serverToken: String, signedDIDDoc: SignedDidDoc) throws -> _RequestRegisterUser
```

### Parameters

| Name         | Type         | Description                | **M/O** | **Note**                        |
| ------------ | ------------ | -------------------------- | ------- | ------------------------------- |
| TasURL       | String       | TAS URL                    | M       |                                 |
| id           | String       | message id                 | M       |                                 |
| txId         | String       | Transaction Code           | M       |                                 |
| hWalletToken | String       | Wallet Token               | M       |                                 |
| serverToken  | String       | Server Token               | M       |                                 |
| signedDIDDoc | SignedDidDoc | Signed DID Document Object | M       | [SignedDIDDoc](#4-signeddiddoc) |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| _RequestRegisterUser | Returns the result of performing the user registration protocol. | M       |          |

### Usage

```swift
let _RequestRegisterUser = try await WalletAPI.shared.requestRegisterUser(tasURL: TAS_URL, id: "messageId", txId: "txId", hWalletToken: hWalletToken, serverToken: hServerToken, signedDIDDoc: signedDidDoc);
```

<br>

## 17. getSignedDIDAuth

### Description
`Perform DIDAuth signing.`

### Declaration

```swift
func getSignedDIDAuth(hWalletToken: String, authNonce: String, didType: DidDocumentType, passcode: String ?= nil) throws -> DIDAuth?
```

### Parameters

| Name         | Type            | Description        | **M/O** | **Note** |
| ------------ | --------------- | ------------------ | ------- | -------- |
| hWalletToken | String          | Wallet Token       | M       |          |
| authNonce    | String          | profile auth nonce | M       |          |
| didType      | DIDDocumentType | did type           | M       |          |
| passcode     | String          | user passcode      | M       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| DIDAuth         | Signed DIDAuth object   | M       |[DIDAuth](#6-didauth)          |

### Usage

```swift
let signedDIDAuth = try WalletAPI.shared.getSignedDIDAuth(hWalletToken: hWalletToken, authNonce: authNunce, didType: DidDocumentType.holderDIDDcument, passcode: passcode);
```

<br>

## 18. requestIssueVc

### Description
`Request for issuance of VC.`

### Declaration

```swift
func requestIssueVc(tasURL: String, hWalletToken: String, didAuth: DIDAuth, issueProfile: _RequestIssueProfile, refId: String, serverToken: String, APIGatewayURL: String) async throws -> (String, _requestIssueVc?)
```

### Parameters

| Name          | Type                 | Description                               | **M/O** | **Note**               |
| ------------- | -------------------- | ----------------------------------------- | ------- | ---------------------- |
| tasURL        | String               | TAS URL                                   | M       |                        |
| hWalletToken  | String               | Wallet Token                              | M       |                        |
| didAuth       | DIDAuth              | DIDAuth                                   | M       | [DIDAuth](#6-didauth)  |
| issueProfile  | _RequestIssueProfile | issuer profile infomation                       | M       |                        |
| refId         | String               | reference ID                              | M       |                        |
| serverToken   | String               | Server token for accessing the TAS server | M       | reference DIDDataModel |
| APIGatewayURL | String               | APIGateWay URL                            | M       |                        |

### Returns

| Type            | Description | **M/O** | **Note**                                   |
| --------------- | ----------- | ------- | ------------------------------------------ |
| String          | VC ID       | M       | Returns the ID of the VC issued on success |
| _requestIssueVc | VC          | M       | Returns the VC issued on success           |

### Usage

```swift
(vcId, issueVC) = try await WalletAPI.shared.requestIssueVc(tasURL: TAS_URL, hWalletToken: hWalletToken, didAuth: didAuth, issuerProfile: issuerProfile, refId: refId, serverToken: hServerToken, APIGatewayURL: API_URL);
```

<br>

## 19. requestRevokeVc

### Description
`Request for VC revocation.`

### Declaration

```swift
func  func requestRevokeVc(hWalletToken:String, tasURL: String, authType: VerifyAuthType, vcId: String, issuerNonce: String, txId: String, serverToken: String, passcode: String? = nil) async throws -> _RequestRevokeVc
```

### Parameters

| Name         | Type                 | Description              | **M/O** | **Note**               |
| ------------ | -------------------- | ------------------------ | ------- | ---------------------- |
| hWalletToken | String               | Wallet Token             | M       |                        |
| tasURL       | String               | TAS URL                  | M       |                        |
| authType     | String               | authType                 | M       |                        |
| didAuth      | DIDAuth              | didAUth                  | M       | DIDDataModel reference |
| vcId         | _RequestIssueProfile | issue profile infomation | M       | DIDDataModel reference |
| issuerNonce  | String               | reference ID             | M       |                        |
| txId         | String               |                          | M       |                        |
| serverToken  | String               |                          | M       |                        |
| passcode     | String               |                          | M       |                        |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| _RequestRevokeVc | revoke result | M       |          |

### Usage

```swift
let revokeVc = try await WalletAPI.shared.requestRevokeVc(hWalletToken: self.hWalletToken,
                                                                tasURL: URLs.TAS_URL + "/tas/api/v1/request-revoke-vc",
                                                                authType: authType,
                                                                vcId: super.vcId,
                                                                issuerNonce: super.issuerNonce,
                                                                txId: super.txId,
                                                                serverToken: self.hServerToken,
                                                                passcode: passcode)
```

<br>


## 20. getAllCredentials

### Description
`Get all VCs stored in the Wallet.`

### Declaration

```swift
func getAllCredentials(hWalletToken: String) throws -> [VerifiableCredential]?
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | Wallet Token                  | M       |          |

### Returns

| Type            | Description                | **M/O** | **Note** |
|-----------------|---------------------|---------|----------|
| [VerifiableCredential] | VC List Object  | M       |          |

### Usage

```swift
let vcList = try WalletAPI.shared.getAllCredentials(hWalletToken: hWalletToken);
```

<br>

## 21. getCredentials

### Description
`Query a specific VC.`

### Declaration

```swift
func getCredentials(hWalletToken: String, ids: [String]) throws -> [VerifiableCredential]
```

### Parameters

| Name         | Type     | Description                   | **M/O** | **Note** |
| ------------ | -------- | ----------------------------- | ------- | -------- |
| hWalletToken | String   | Wallet Token                  | M       |          |
| ids          | [String] | List of VC IDs to be searched | M       |          |

### Returns

| Type        | Description                | **M/O** | **Note** |
|-------------|---------------------|---------|----------|
| [VerifiableCredential]  | VC List Object    | M       |          |

### Usage

```swift
let vcList = try WalletAPI.shared.getCredentials(hWalletToken: hWalletToken, ids: [vc.id]]);
```

<br>

## 22. deleteCredentials

### Description
`Delete a specific VC.`

### Declaration

```swift
func deleteCredentials(hWalletToken: String, ids: [String]) throws -> Bool
```

### Parameters

| Name           | Type   | Description                       | **M/O** | **Note** |
|----------------|--------|----------------------------|---------|----------|
| hWalletToken   | String | Wallet Token                  | M       |          |
| ids   | [String]]   | VC to be deleted               | M       |          |

### Returns
Bool

### Usage

```swift
let result = try WalletAPI.shared.deleteCredentials(hWalletToken: hWalletToken, ids:[vc.id]);
```

<br>

## 23. createEncVp

### Description
`Generate encrypted VP and accE2e.`

### Declaration

```swift
func createEncVp(hWalletToken: String, claimInfos: [ClaimInfo]? = nil, verifierProfile: _RequestProfile, passcode: String? = nil) throws -> (AccE2e, Data)
```

### Parameters

| Name         | Type             | Description                           | **M/O** | **Note**               |
| ------------ | ---------------- | ------------------------------------- | ------- | ---------------------- |
| hWalletToken | String           | Wallet Token                          | M       |                        |
| claimCode    | array[ClaimInfo] | Claim Code to Submit                  | M       |                        |
| reqE2e       | ReqE2e           | E2E encryption/decryption information | M       | DIDDataModel reference |
| passcode     | String           | PIN for signing                       | M       |                        |
| nonce        | String           | nonce                                 | M       |                        |

### Returns

| Type    | Description              | **M/O** | **Note**          |
|---------|--------------------------|---------|-------------------|
| AccE2e  | Cryptographic Object     | M       |acce2e             |
| EncVP   | Encrypted VP Object      | M       |encVp              |

### Usage

```swift
(accE2e, encVp) = try WalletAPI.shared.createEncVp(hWalletToken:hWalletToken, claimInfos:claimInfos, verifierProfile: verifierProfile, passcode: passcode)
```

<br>

## 24. getKeyInfos

### Description
`Retrieves saved key information.`

### Declaration

```swift
func getKeyInfos(keyType: VerifyAuthType) throws -> [KeyInfo]
```

### Parameters

| Name        | Type           | Description           | **M/O** | **Note** |
|-------------|----------------|-----------------------|---------|----------|
| keyType     | VerifyAuthType | Wallet Token          | M       |          |

### Returns

| Type     | Description       | **M/O** | **Note** |
|----------|-------------------|---------|----------|
| KeyInfo  | array[KeyInfo]    | M       |          |

### Usage

```swift
let keyInfos = try holderKey.getKeyInfos(keyType: [.free, .pin])
```

<br>

## 25. getKeyInfos

### Description
`Retrieves saved key information.`

### Declaration

```swift
public func getKeyInfos(ids: [String]) throws -> [KeyInfo]
```

### Parameters

| Name        | Type           | Description                 | **M/O** | **Note** |
|-------------|----------------|-----------------------------|---------|----------|
| ids         | array[String]  | key id array                | M       |          |

### Returns

| Type      | Description       | **M/O** | **Note** |
|-----------|-------------------|---------|----------|
| KeyInfos  | array[String]     | M       |      |

### Usage

```swift
let keyInfos = try holderKey.getKeyInfos(ids: ["free", "pin"])
```

<br>

## 26. isAnyKeysSaved

### Description
`Returns whether a key is stored.`

### Declaration

```swift
public func isAnyKeysSaved() throws -> Bool
```

### Parameters


### Returns
Bool

### Usage

```swift
let isAnyKey = try! WalletAPI.shared.isAnyKeysSaved()
```

<br>

## 27. changePIN

### Description
`Change PIN for signing`

### Declaration

```swift
public func changePIN(id: String, oldPIN: String, newPIN: String) throws
```

### Parameters

| Name   | Type   | Description   | **M/O** | **Note** |
| ------ | ------ | ------------- | ------- | -------- |
| id     | String | key ID for signing | M       |          |
| oldPIN | String | old PIN      | M       |          |
| newPIN | String | new PIN    | M       |          |

### Returns


### Usage

```swift
try WalletAPI.shared.changePIN(id: "pin", oldPIN: oldPIN, newPIN: passcode)
```

<br>

## 28. isZKPCredentialSaved

### Description
`Checks whether a ZKP credential with the given ID is stored.`

### Declaration

```swift
func isZKPCredentialSaved(id: String) -> Bool
```

### Parameters

| Name | Type   | Description         | **M/O** | **Note** |
| ---- | ------ | ------------------- | ------- | -------- |
| id   | String | Credential ID       | M       |          |

### Returns

| Type | Description                     | **M/O** | **Note**                                |
| ---- | ------------------------------- | ------- | ---------------------------------------- |
| Bool | Whether the credential is saved | M       | `true`: saved<br>`false`: not saved     |


<br>

## 29. deleteZKPCredentials

### Description
`Revokes the specified ZKP credentials from the wallet using the provided wallet token.`

### Declaration

```swift
func deleteZKPCredentials(hWalletToken: String, ids: [String]) throws -> Bool
```

### Parameters

| Name         | Type     | Description                             | **M/O** | **Note**                        |
| ------------ | -------- | --------------------------------------- | ------- | ------------------------------- |
| hWalletToken | String   | The token associated with the wallet    | M       | Throws if token is not verified |
| ids          | [String] | Array of credential IDs to be revoked   | M       |                                 |

### Returns

| Type | Description                         | **M/O** | **Note**                       |
| ---- | ----------------------------------- | ------- | ------------------------------ |
| Bool | Whether credentials were revoked    | M       | `true`: success, `false`: fail |

### Throws

- `WalletApiError(VERIFY_TOKEN_FAIL)`: If the wallet token verification fails


<br>

## 30. getZKPCredentials

### Description
`Retrieves the specified ZKP credentials from the wallet using the provided wallet token.`

### Declaration

```swift
func getZKPCredentials(hWalletToken: String, ids: [String]) throws -> [ZKPCredential]
```

### Parameters

| Name         | Type     | Description                             | **M/O** | **Note**                        |
| ------------ | -------- | --------------------------------------- | ------- | ------------------------------- |
| hWalletToken | String   | The token associated with the wallet    | M       | Throws if token is not verified |
| ids          | [String] | Array of credential IDs to retrieve     | M       |                                 |

### Returns

| Type            | Description                                  | **M/O** | **Note**                      |
| --------------- | -------------------------------------------- | ------- | ----------------------------- |
| [ZKPCredential] | List of retrieved ZKP credential objects      | M       | Each object contains VC info  |

### Throws

- `WalletApiError(VERIFY_TOKEN_FAIL)`: If the wallet token verification fails



<br>

## 31. getAllZKPCrentials

### Description  
`Retrieves all ZKP credentials stored in the wallet using the provided wallet token.`

### Declaration

```swift
func getAllZKPCrentials(hWalletToken: String) throws -> [ZKPCredential]?
```

### Parameters

| Name         | Type   | Description                          | **M/O** | **Note**                        |
| ------------ | ------ | ------------------------------------ | ------- | ------------------------------- |
| hWalletToken | String | The token associated with the wallet | M       | Throws if token is not verified |

### Returns

| Type              | Description                                    | **M/O** | **Note**                               |
| ----------------- | ---------------------------------------------- | ------- | -------------------------------------- |
| [ZKPCredential]?  | List of all stored ZKP credentials (optional) | O       | Returns `nil` if no credentials exist  |

### Throws

- `WalletApiError(VERIFY_TOKEN_FAIL)`: If the wallet token verification fails


<br>

## 32. searchCredentials

### Description  
`Searches for credentials that satisfy the given proof request.`

### Declaration

```swift
func searchCredentials(hWalletToken: String, proofRequest: ProofRequest) throws -> AvailableReferent
```

### Parameters

| Name         | Type         | Description                                    | **M/O** | **Note**                        |
| ------------ | ------------ | ---------------------------------------------- | ------- | ------------------------------- |
| hWalletToken | String       | The token associated with the wallet           | M       | Throws if token is not verified |
| proofRequest | ProofRequest | The proof request with required attributes     | M       | Includes attributes/predicates  |

### Returns

| Type              | Description                                              | **M/O** | **Note**                              |
| ----------------- | -------------------------------------------------------- | ------- | ------------------------------------- |
| AvailableReferent | Contains referents matching credentials for the request | M       | Includes matched credential references |

### Throws

(No explicit errors listed, may vary by implementation)


<br>

## 33. createZKProof

### Description  
`Creates a zero-knowledge proof based on the given request and selected referents.`

### Declaration

```swift
func createZKProof(hWalletToken: String, proofRequest: ProofRequest, selectedReferents: [UserReferent], proofParam: ZKProofParam) throws -> ZKProof
```

### Parameters

| Name              | Type             | Description                                               | **M/O** | **Note**                        |
| ----------------- | ---------------- | --------------------------------------------------------- | ------- | ------------------------------- |
| hWalletToken      | String           | The token associated with the wallet                      | M       | Throws if token is not verified |
| proofRequest      | ProofRequest     | The proof request specifying required attributes          | M       |                                 |
| selectedReferents | [UserReferent]   | The referents selected to satisfy the proof request       | M       |                                 |
| proofParam        | ZKProofParam     | Additional parameters for constructing the proof          | M       |                                 |

### Returns

| Type    | Description                        | **M/O** | **Note**                          |
| ------- | ---------------------------------- | ------- | --------------------------------- |
| ZKProof | A zero-knowledge proof instance     | M       | Based on selected credentials     |

### Throws

(No explicit errors listed; may vary depending on implementation)



<br>

## 34. createEncZKProof

### Description  
`Generates a zero-knowledge proof, encrypts it, and returns it along with end-to-end encryption (E2E) parameters.`

### Declaration

```swift
func createEncZKProof(hWalletToken: String, selectedReferents: [UserReferent], proofParam: ZKProofParam, proofRequestProfile: _RequestProofRequestProfile, APIGatewayURL: String) async throws -> (AccE2e, Data)
```

### Parameters

| Name                 | Type                         | Description                                                 | **M/O** | **Note**                             |
| -------------------- | ---------------------------- | ----------------------------------------------------------- | ------- | ------------------------------------ |
| hWalletToken         | String                       | The token representing the holder's wallet                  | M       |                                      |
| selectedReferents    | [UserReferent]               | The referents selected to satisfy the proof request         | M       | Must match proof request criteria    |
| proofParam           | ZKProofParam                 | Additional parameters for proof construction                | M       |                                      |
| proofRequestProfile  | _RequestProofRequestProfile  | Verifier profile including DID and ZKP certificate info     | M       |                                      |
| APIGatewayURL        | String                       | The URL of the API gateway for communication and validation | M       |                                      |

### Returns

| Type         | Description                                  | **M/O** | **Note**                              |
| ------------ | -------------------------------------------- | ------- | ------------------------------------- |
| AccE2e       | Object containing encryption parameters       | M       | Includes cryptographic context        |
| Data (EncZKProof) | Encrypted ZK proof data                      | M       | Used for secure submission            |

### Throws

- Errors may occur due to cryptographic failures, data encoding issues, or network communication problems.


<br>


# Enumerators
## 1. WalletTokenPurposeEnum

### Description

`WalletToken purpose`

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

# Value Object

## 1. WalletTokenSeed

### Description

`Data transmitted by the authorization app when requesting wallet token creation to the wallet`

### Declaration

```swift
public struct WalletTokenSeed {
    var purpose: WalletTokenPurposeEnum
    var pkgName: String
    var nonce: String
    var validUntil: String
    var userId: String?
}
```

### Property

| Name       | Type                   | Description        | **M/O** | **Note**                                          |
| ---------- | ---------------------- | ------------------ | ------- | ------------------------------------------------- |
| purpose    | WalletTokenPurposeEnum | token purpose    | M       | [WalletTokenPurposeEnum](#1-wallet_token_purpose) |
| pkgName    | String                 | ca Package Name    | M       |                                                   |
| nonce      | String                 | wallet nonce       | M       |                                                   |
| validUntil | String                 | token expried date | M       |                                                   |
| userId     | String                 | user ID            | M       |                                                   |
<br>

## 2. WalletTokenData

### Description

`Data generated by the wallet and transmitted to the authorization app when the authorization app requests the wallet to create a wallet token.`

### Declaration

```swift
public struct WalletTokenData: Jsonable {
    var seed: WalletTokenSeed
    var sha256_pii: String
    var provider: Provider
    var nonce: String
    var proof: Proof
}
```

### Property

| Name       | Type            | Description                 | **M/O** | **Note**                              |
| ---------- | --------------- | --------------------------- | ------- | ------------------------------------- |
| seed       | WalletTokenSeed | WalletToken Seed            | M       | [WalletTokenSeed](#1-wallettokenseed) |
| sha256_pii | String          | Hash value of user PII      | M       |                                       |
| provider   | Provider        | Wallet business information | M       | [Provider](#3-provider)               |
| nonce      | String          | provider nonce              | M       |                                       |
| proof      | Proof           | provider proof              | M       |                                       |
<br>

## 3. Provider

### Description

`Provider Information`

### Declaration

```swift
public struct Provider: Jsonable {
    var did: String
    var certVcRef: String
}
```

### Property

| Name      | Type   | Description                | **M/O** | **Note** |
| --------- | ------ | -------------------------- | ------- | -------- |
| did       | String | provider DID               | M       |          |
| certVcRef | String | Membership Certificate VC URL | M       |          |
<br>

## 4. SignedDIDDoc

### Description

`Data of the document for the wallet to sign the holder's DID Document and request the controller to register it.`

### Declaration

```swift
public struct SignedDidDoc: Jsonable {
    var ownerDidDoc: String
    var wallet: Wallet
    var nonce: String
    var proof: Proof
}
```

### Property

| Name        | Type   | Description                                                   | **M/O** | **Note** |
| ----------- | ------ | ------------------------------------------------------------- | ------- | -------- |
| ownerDidDoc | String | Multibase encoded value of ownerDidDoc                        | M       |          |
| wallet      | Wallet | An object consisting of the wallet's ID and the wallet's DID. | M       |          |
| nonce       | String | wallet nonce                                                  | M       |          |
| proof       | Proof  | wallet proof                                                  | M       |          |
<br>

## 5. SignedWalletInfo

### Description

`Signed walletinfo data`

### Declaration

```swift
public struct SignedWalletInfo: Jsonable {
    var wallet: Wallet
    var nonce: String
    var proof: Proof
}
```

### Property

| Name   | Type   | Description                                                   | **M/O** | **Note** |
| ------ | ------ | ------------------------------------------------------------- | ------- | -------- |
| wallet | Wallet | An object consisting of the wallet's ID and the wallet's DID. | M       |          |
| nonce  | String | wallet nonce                                                  | M       |          |
| proof  | Proof  | wallet proof                                                  | M       |          |
<br>

## 6. DIDAuth

### Description

`DID Auth Data`

### Declaration

```swift
public struct DIDAuth: Jsonable {
    var did: String
    var authNonce: String
    var proof: Proof
}
```

### Property

| Name      | Type   | Description                           | **M/O** | **Note** |
| --------- | ------ | ------------------------------------- | ------- | -------- |
| did       | String | DID of the person being authenticated | M       |          |
| authNonce | String | Nonce for DID Auth                    | M       |          |
| proof     | Proof  | authentication proof                  | M       |          |
<br>
