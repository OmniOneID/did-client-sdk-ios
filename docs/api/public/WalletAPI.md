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
- Date: 2026-08-06
- Version: v3.0.0

| Version | Date       | History                                               |
| -------- | ---------- | ----------------------------------------------------- |
| v3.0.0   | 2026-08-06 | Add OID4VC section; correct declarations to match the SDK |
| v2.0.1   | 2025-09-11 | Add DID-related function and authenticatePin          |
| v2.0.0   | 2025-05-27 | Add ZKP-related function                              |
| v1.0.0   | 2024-10-18 | Initial                                              |

<div style="page-break-after: always;"></div>

# Table of Contents
- [APIs](#api-list)
    - [1. Constructor](#1-constructor)
        - [1.1. shared](#11-shared)
    - [2. Wallet](#2-wallet)
        - [2.1. isExistWallet](#21-isexistwallet)
        - [2.2. createWallet](#22-createwallet)
        - [2.3. deleteWallet](#23-deletewallet)
        - [2.4. createWalletTokenSeed](#24-createwallettokenseed)
        - [2.5. createNonceForWalletToken](#25-createnonceforwallettoken)
        - [2.6. bindUser](#26-binduser)
        - [2.7. unbindUser](#27-unbinduser)
        - [2.8. requestRegisterUser](#28-requestregisteruser)
        - [2.9. getSignedWalletInfo](#29-getsignedwalletinfo)
    - [3. DIDKey)](#3-didkey)
        - [3.1. createHolderDIDDocument](#31-createholderdiddocument)
        - [3.2. createSignedDIDDoc](#32-createsigneddiddoc)
        - [3.3. getDidDocument](#33-getdiddocument)
        - [3.4. isAnyKeysSaved](#34-isanykeyssaved)
        - [3.5. isSavedKey](#35-issavedkey)
        - [3.6. generateKeyPair](#36-generatekeypair)
        - [3.7. sign](#37-sign)
        - [3.8. verify](#38-verify)
        - [3.9. getSignedDidAuth](#39-getsigneddidauth)
        - [3.10. updateHolderDIDDocument](#310-updateholderdiddocument)
        - [3.11. saveHolderDIDDocument](#311-saveholderdiddocument)
        - [3.12. deleteKeyPair](#312-deletekeypair)
        - [3.13. requestUpdateUser](#313-requestupdateuser)
        - [3.14. requestRestoreUser](#314-requestrestoreuser)
    - [4. Credential)](#4-credential)
        - [4.1. requestIssueVc](#41-requestissuevc)
        - [4.2. requestRevokeVc](#42-requestrevokevc)
        - [4.3. getAllCredentials](#43-getallcredentials)
        - [4.4. getCredentials](#44-getcredentials)
        - [4.5. deleteCredentials](#45-deletecredentials)
        - [4.6. createEncVp](#46-createencvp)
        - [4.7. createVp](#47-createvp)
        - [4.8. isAnyCredentialsSaved](#48-isanycredentialssaved)
    - [5. ZKP](#5-zkp)
        - [5.1. createEncZKProof](#51-createenczkproof)
        - [5.2. searchZKPCredentials](#52-searchzkpcredentials)
        - [5.3. getAllZKPCredentials](#53-getallzkpcredentials)
        - [5.4. isAnyZKPCredentialsSaved](#54-isanyzkpcredentialssaved)
        - [5.5. isZKPCredentialSaved](#55-iszkpcredentialsaved)
        - [5.6. getZKPCredentials](#56-getzkpcredentials)
    - [6. SecurityAuth)](#6-securityauth)
        - [6.1. registerLock](#61-registerlock)
        - [6.2. authenticateLock](#62-authenticatelock)
        - [6.3. isLock](#63-islock)
        - [6.4. changePin](#64-changepin)
        - [6.5. changeLock](#65-changelock)
        - [6.6. authenticatePin](#66-authenticatepin)
    - [7. OID4VC](#7-oid4vc)
        - [7.1. requestIssueOID4VC](#71-requestissueoid4vc)
        - [7.2. getAllOID4VCs](#72-getalloid4vcs)
        - [7.3. getOID4VCs](#73-getoid4vcs)
        - [7.4. deleteOID4VCs](#74-deleteoid4vcs)
        - [7.5. isAnyOID4VCSaved](#75-isanyoid4vcsaved)
        - [7.6. matchCredentials](#76-matchcredentials)
        - [7.7. createVpToken](#77-createvptoken)

- [Enumerators](#enumerators)
    - [1. WalletTokenPurposeEnum](#1-wallet_token_purpose)

- [Value Object](#value-object)
    - [1. WalletTokenSeed](#1-wallettokenseed)
    - [2. WalletTokenData](#2-wallettokendata)
    - [3. Provider](#3-provider)
    - [4. SignedDIDDoc](#4-signeddiddoc)
    - [5. SignedWalletInfo](#5-signedwalletinfo)
    - [6. DIDAuth](#6-didauth)
    - [7. AuthorizationRequest](#7-authorizationrequest)
    - [8. MatchedCredential](#8-matchedcredential)


# API List
## 1. constructor

## 1.1. shared

### Description
 `WalletApi construct`

### Declaration

```swift
public static let shared: WalletAPI
```

### Parameters

| Name | Type | Description | **M/O** | **Note** |
|------|------|-------------|---------|----------|
|      |      |             | M       |          |

### Returns

| Type      | Description         | **M/O** | **Note** |
|-----------|---------------------|---------|----------|
| WalletApi | WalletAPI instance  | M       |          |

### Usage

```swift
WalletAPI.shared
```

<br>

## 2. Wallet

## 2.1. isExistWallet

### Description
 `Check whether DeviceKey Wallet exists.`

### Declaration

```swift
func isExistWallet() -> Bool
```

### Parameters

N/A

### Returns

| Type | Description                          | **M/O** | **Note** |
|------|--------------------------------------|---------|----------|
| Bool | Returns whether the wallet exists.   | M       |          |

### Usage

```swift
let exists = WalletAPI.shared.isExistWallet()
```

<br>

## 2.2. createWallet

### Description
`Create a DeviceKey Wallet.`

### Declaration

```swift
func createWallet(tasURL: String, walletURL: String) async throws -> Bool
```

### Parameters

| Name      | Type   | Description | **M/O** | **Note** |
|-----------|--------|-------------|---------|----------|
| tasURL    | String | TAS URL     | M       |          |
| walletURL | String | Wallet URL  | M       |          |

### Returns

| Type    | Description                                   | **M/O** | **Note** |
|---------|-----------------------------------------------|---------|----------|
| boolean | Returns whether wallet creation was successful | M       |          |

### Usage

```swift
let success = try await WalletAPI.shared.createWallet(tasURL:TAS_URL, walletURL: WALLET_URL)
```

<br>

## 2.3. deleteWallet

### Description
`Delete DeviceKey Wallet.`

### Declaration

```swift
func deleteWallet(deleteAll: Bool) throws
```

### Parameters

| Name      | Type | Description                                                          | **M/O** | **Note** |
|-----------|------|----------------------------------------------------------------------|---------|----------|
| deleteAll | Bool | `true` additionally removes the device DID document and device keys, and clears the stored user, token and CA package | M | The holder DID document, holder keys and all credentials are deleted either way |

### Returns

Void

### Usage

```swift
try WalletAPI.shared.deleteWallet(deleteAll: true)
```

<br>

## 2.4. createWalletTokenSeed

### Description
`Generate a wallet token seed.`

### Declaration

```swift
func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String, userId: String) throws -> WalletTokenSeed
```

### Parameters

| Name    | Type                 | Description  | **M/O** | **Note**                                           |
|---------|----------------------|--------------|---------|----------------------------------------------------|
| purpose | WalletTokenPurposeEnum | use token   | M       | [WalletTokenPurposeEnum](#1-wallet_token_purpose)  |
| pkgName | String               | CA Package Name | M    |                                                    |
| userId  | String               | user ID      | M       |                                                    |

### Returns

| Type            | Description               | **M/O** | **Note**                          |
|-----------------|---------------------------|---------|-----------------------------------|
| WalletTokenSeed | Wallet Token Seed Object  | M       | [WalletTokenSeed](#1-wallettokenseed) |

### Usage

```swift
let tokenSeed = try WalletAPI.shared.createWalletTokenSeed(purpose: purpose, "org.opendid.did.ca", "user_id");
```

<br>

## 2.5. createNonceForWalletToken

### Description
`Generate a nonce for creating wallet tokens.`

### Declaration

```swift
func createNonceForWalletToken(walletTokenData: WalletTokenData, APIGatewayURL: String) async throws -> String
```

### Parameters

| Name           | Type           | Description         | **M/O** | **Note**                          |
|----------------|----------------|---------------------|---------|-----------------------------------|
| walletTokenData | WalletTokenData | Wallet Token Data   | M       | [WalletTokenData](#2-wallettokendata) |
| APIGatewayURL  | String         | API Gateway URL the nonce is requested from | M | |

### Returns

| Type   | Description                       | **M/O** | **Note** |
|--------|-----------------------------------|---------|----------|
| String | Nonce for wallet token generation | M       |          |

### Usage

```swift
let walletTokenData = try WalletTokenData.init(from: responseData)
let nonce = try await WalletAPI.shared.createNonceForWalletToken(walletTokenData: walletTokenData,
                                                                APIGatewayURL: "https://api.example.com");
```

<br>

## 2.6. bindUser

### Description
`Perform user personalization in Wallet.`

### Declaration

```swift
func bindUser(hWalletToken: String) throws -> Bool
```

### Parameters

| Name         | Type   | Description   | **M/O** | **Note** |
|--------------|--------|---------------|---------|----------|
| hWalletToken | String | Wallet Token  | M       |          |

### Returns

| Type | Description                                   | **M/O** | **Note** |
|------|-----------------------------------------------|---------|----------|
| Bool | Returns whether personalization was successful. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.bindUser(hWalletToken: hWalletToken);
```

<br>

## 2.7. unbindUser

### Description
`Perform user depersonalization.`

### Declaration

```swift
func unbindUser(hWalletToken: String) throws -> Bool
```

### Parameters

| Name         | Type   | Description  | **M/O** | **Note** |
|--------------|--------|--------------|---------|----------|
| hWalletToken | String | Wallet Token | M       |          |

### Returns

| Type    | Description                                       | **M/O** | **Note** |
| ------- | ------------------------------------------------- | ------- | -------- |
| boolean | Returns whether depersonalization was successful. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.unbindUser(hWalletToken: hWalletToken);
```

<br>


## 2.8. requestRegisterUser

### Description
`Request user registration.`

### Declaration

```swift
func requestRegisterUser(tasURL: String, txId: String, hWalletToken: String, serverToken: String, signedDIDDoc: SignedDIDDoc) async throws -> _RequestRegisterUser
```

### Parameters

| Name         | Type         | Description                | **M/O** | **Note**                        |
| ------------ | ------------ | -------------------------- | ------- | ------------------------------- |
| tasURL       | String       | TAS URL                    | M       |                                 |
| txId         | String       | Transaction Code           | M       |                                 |
| hWalletToken | String       | Wallet Token               | M       |                                 |
| serverToken  | String       | Server Token               | M       |                                 |
| signedDIDDoc | SignedDIDDoc | Signed DID Document Object | M       | [SignedDIDDoc](#4-signeddiddoc) |

### Returns

| Type                | Description                                                | **M/O** | **Note** |
|---------------------|------------------------------------------------------------|---------|----------|
| _RequestRegisterUser | Returns the result of performing the user registration protocol. | M       |          |

### Usage

```swift
let _RequestRegisterUser = try await WalletAPI.shared.requestRegisterUser(tasURL: TAS_URL, txId: "txId", hWalletToken: hWalletToken, serverToken: hServerToken, signedDIDDoc: signedDidDoc);
```

<br>

## 2.9. getSignedWalletInfo

### Description
`signed wallet information.`

### Declaration

```swift
func getSignedWalletInfo() throws -> SignedWalletInfo
```

### Parameters

None.

### Returns

| Type             | Description                 | **M/O** | **Note**                                |
|------------------|-----------------------------|---------|-----------------------------------------|
| SignedWalletInfo | Signed WalletInfo object    | M       | [SignedWalletInfo](#5-signedwalletinfo) |

### Usage

```swift
let signedInfo = try WalletAPI.shared.getSignedWalletInfo();
```

<br>

## 3. DIDKey

## 3.1. createHolderDIDDocument

### Description
```
Create a user DID Document.

After Finish the registration,
Must call saveHolderDIDDocument
```

### Declaration

```swift
func createHolderDIDDocument(hWalletToken: String) throws -> DIDDocument
```

### Parameters

| Name         | Type   | Description  | **M/O** | **Note** |
|--------------|--------|--------------|---------|----------|
| hWalletToken | String | Wallet Token | O       |          |

### Returns

| Type        | Description   | **M/O** | **Note** |
|-------------|---------------|---------|----------|
| DIDDocument | DID Document  | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.createHolderDIDDocument(hWalletToken: hWalletToken);
```

<br>

## 3.2. createSignedDIDDoc

### Description
`Creates a signed user DID Document object.`

### Declaration

```swift
func createSignedDIDDoc(passcode: String? = nil) throws -> SignedDIDDoc
```

### Parameters

| Name     | Type    | Description                                   | **M/O** | **Note** |
|----------|---------|-----------------------------------------------|---------|----------|
| passcode | String? | PIN when the holder key is PIN-protected; `nil` for biometrics | O | |

### Returns

| Type         | Description                | **M/O** | **Note**                        |
|--------------|----------------------------|---------|---------------------------------|
| SignedDIDDoc | Signed DID Document Object | M       | [SignedDIDDoc](#4-signeddiddoc) |

### Usage

```swift
let signedDidDoc = try WalletAPI.shared.createSignedDIDDoc(passcode: passcode);
```

<br>

## 3.3. getDidDocument

### Description
`Look up the DID Document.`

### Declaration

```swift
func getDidDocument(type: DidDocumentType) throws -> DIDDocument
```

### Parameters

| Name | Type | Description                          | **M/O** | **Note**              |
|------|------|--------------------------------------|---------|-----------------------|
| type | Enum | DeviceDidDocument, HolderDidDocumnet | M       | DIDDataModel reference |

### Returns

| Type         | Description                  | **M/O** | **Note** |
|--------------|-----------------------|---------|----------|
| DIDDocument  | DID Document       | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.getDidDocument(type: .HolderDidDocumnet)
```

<br>

## 3.4. isAnyKeysSaved

### Description
`Returns whether a key is stored.`

### Declaration

```swift
public func isAnyKeysSaved() throws -> Bool
```

### Returns

| Type | Description                                      | **M/O** | **Note** |
|------|--------------------------------------------------|---------|----------|
| Bool | `true` if any keys are saved, otherwise `false`. | M       |          |

### Usage

```swift
let isAnyKey = try! WalletAPI.shared.isAnyKeysSaved()
```

<br>

## 3.5. isSavedKey

### Description
```
Checks whether a key pair with the given identifier is saved.
Throws an error if the wallet is locked.

This method verifies if the specified key ID exists in the wallet.
```

### Declaration

```swift
public func isSavedKey(keyId: String) throws -> Bool
```

### Parameters

| Name  | Type   | Description                        | **M/O** | **Note** |
|-------|--------|------------------------------------|---------|----------|
| keyId | String | The identifier of the key to check | M       |          |


### Returns

| Type | Description                                    | **M/O** | **Note** |
|------|------------------------------------------------|---------|----------|
| Bool | `true` if the key is saved, otherwise `false`. | M       |          |

### Usage

```swift
let hasKey = try WalletAPI.shared.isSavedKey(keyId: "pin"))
if hasKey {
    print("Key named pin is saved.")
} else {
    print("Key named pin is not saved.")
}

```

<br>

## 3.6. generateKeyPair

### Description
`Generate a PIN key pair for signing and store it in your Wallet.`

### Declaration

```swift
func generateKeyPair(hWalletToken: String, passcode: String? = nil, keyId: String, algType:AlgorithmType, promptMsg: String? = nil) throws -> Bool
```

### Parameters

| Name         | Type          | Description                                | **M/O** | **Note**                              |
|--------------|---------------|--------------------------------------------|---------|---------------------------------------|
| hWalletToken | String        | Wallet Token                               | M       |                                       |
| passCode     | String        | PIN for signing                            | M       | When generating a key for PIN signing |
| keyId        | String        | PIN for ID                                 | M       |                                       |
| algType      | AlgorithmType | Key algorithm type for signing             | M       |                                       |
| promptMsg    | String        | Biometric authentication prompt message    | M       |                                       |

### Returns

Bool

### Usage

```swift
let success = try WalletAPI.shared.generateKeyPair(hWalletToken:hWalletToken, passcode:"123456", keyId:"pin", algType: AlgoritheType.secp256r1);


let success = try WalletAPI.shared.generateKeyPair(hWalletToken:hWalletToken, keyId:"bio", algType: AlgoritheType.secp256r1, promptMsg: "message");
```

<br>

## 3.7. sign

### Description
`Signs the specified data using the private key associated with the given key ID.`

### Declaration

```swift
@discardableResult
public func sign(keyId: String,
                 pin: Data? = nil,
                 data: Data,
                 type: DidDocumentType) throws -> Data

```

### Parameters

| Parameter | Type            | Description                                      | **M/O** | **Note** |
| --------- | --------------- | ------------------------------------------------ | ------- | -------- |
| keyId     | String          | The ID of the key to use for signing             | M       |          |
| pin       | Data            | The PIN for key decryption (optional)            | O       |          |
| data      | Data            | The digest to sign                               | M       |          |
| type      | DidDocumentType | The type of DID document associated with the key | M       |          |

### Returns

| Type | Description                                              | **M/O** | **Note** |
| ---- | -------------------------------------------------------- | ------- | -------- |
| Data | The signature generated using the specified key and data | M       |          |


### Usage

```swift
let signature = try WalletAPI.shared.sign(
    keyId: "key_identifier",
    pin: pinData,
    data: messageData,
    type: .authentication
)
```

<br>

## 3.8. verify

### Description
`Verifies a signature using the specified public key, data, and signature.`

### Declaration

```swift
public func verify(publicKey: Data,
                   data: Data,
                   signature: Data) throws -> Bool
```

### Parameters

| Parameter | Type | Description                            | **M/O** | **Note** |
| --------- | ---- | -------------------------------------- | ------- | -------- |
| publicKey | Data | The public key to use for verification | M       |          |
| data      | Data | The digest data to verify              | M       |          |
| signature | Data | The signature to verify                | M       |          |

### Returns

| Type | Description                                               | **M/O** | **Note** |
| ---- | --------------------------------------------------------- | ------- | -------- |
| Bool | A boolean value indicating whether the signature is valid | M       |          |

### Usage

```swift
let isValid = try WalletAPI.shared.verify(
    publicKey: publicKeyData,
    data: messageData,
    signature: signatureData
)
print("Signature valid:", isValid)
```

<br>

## 3.9. getSignedDidAuth

### Description
`Perform DIDAuth signing.`

### Declaration

```swift
func getSignedDidAuth(authNonce: String, passcode: String? = nil) throws -> DIDAuth
```

### Parameters

| Name      | Type    | Description                                   | **M/O** | **Note** |
| --------- | ------- | --------------------------------------------- | ------- | -------- |
| authNonce | String  | profile auth nonce                            | M       |          |
| passcode  | String? | PIN when the holder key is PIN-protected; `nil` for biometrics | O | |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| DIDAuth         | Signed DIDAuth object   | M       |[DIDAuth](#6-didauth)          |

### Usage

```swift
let signedDIDAuth = try WalletAPI.shared.getSignedDidAuth(authNonce: authNonce, passcode: passcode);
```

<br>

## 3.10. updateHolderDIDDocument

### Description
```
Updates a DID document.

After Finish the update,
Must call saveHolderDIDDocument
```

### Declaration

```swift
public func updateHolderDIDDocument(hWalletToken: String) throws -> DIDDocument
```

### Parameters

| Parameter    | Type   | Description                       | **M/O** | **Note** |
| ------------ | ------ | --------------------------------- | ------- | -------- |
| hWalletToken | String | The wallet token for verification | M       |          |


### Returns

| Type        | Description                                            | **M/O** | **Note** |
| ----------- | ------------------------------------------------------ | ------- | -------- |
| DIDDocument | A DIDDocument object representing the updated document | M       |          |


### Usage

```swift
let didDocument = try WalletAPI.shared.updateHolderDIDDocument(
    hWalletToken: "wallet_token_value"
)
```

<br>

## 3.11. saveHolderDIDDocument

### Description
`Saves the holder's DID document changes.`

### Declaration

```swift
public func saveHolderDIDDocument() throws
```

### Usage

```swift
try WalletAPI.shared.saveHolderDIDDocument()
```

<br>

## 3.12. deleteKeyPair

### Description
```
Deletes a key pair associated with the given wallet token and key ID.
This method removes the specified key pair from the wallet.
```

### Declaration

```swift
public func deleteKeyPair(hWalletToken: String, keyId: String) throws
```

### Parameters

| Parameter    | Type   | Description                              | **M/O** | **Note** |
| ------------ | ------ | ---------------------------------------- | ------- | -------- |
| hWalletToken | String | The wallet token used for verification   | M       |          |
| keyId        | String | The identifier of the key pair to delete | M       |          |

### Usage

```swift
try WalletAPI.shared.deleteKeyPair(
    hWalletToken: "wallet_token_value",
    keyId: "key_identifier"
)
```

<br>

## 3.13. requestUpdateUser

### Description
```
Requests for updating a user's DID document.

This function sends a request to the specified URL to update the user's DID document using the provided parameters including transaction ID, server token, DID authentication details, and a signed DID document.
```

### Declaration
```swift
public func requestUpdateUser(tasURL: String,
                              txId: String,
                              hWalletToken: String,
                              serverToken: String,
                              didAuth: DIDAuth?,
                              signedDIDDoc: SignedDIDDoc?) async throws -> _RequestUpdateDidDoc
```

### Parameters

| Parameter    | Type          | Description                                 | **M/O** | **Note** |
| ------------ | ------------- | ------------------------------------------- | ------- | -------- |
| tasURL       | String        | The TAS URL endpoint for the update request | M       |          |
| txId         | String        | The transaction ID for the update request   | M       |          |
| hWalletToken | String        | The token used for wallet authentication    | M       |          |
| serverToken  | String        | The token used for server authentication    | M       |          |
| didAuth      | DIDAuth       | Authentication details for the DID          | O       |          |
| signedDIDDoc | SignedDIDDoc  | A signed DID Document representing the user | O       |          |

### Returns

| Type                 | Description                            | **M/O** | **Note** |
| -------------------- | -------------------------------------- | ------- | -------- |
| _RequestUpdateDidDoc | An object containing the response data | M       |          |

### Usage

```swift
let response = try await WalletAPI.shared.requestUpdateUser(
    tasURL: "https://tas.example.com/update",
    txId: "123456",
    hWalletToken: "wallet_token_value",
    serverToken: "server_token_value",
    didAuth: didAuthObject,
    signedDIDDoc: signedDoc
)
```

<br>

## 3.14. requestRestoreUser

### Description
```
Requests a restore of a user's DID document.

This function sends a request to the specified URL to restore a user's DID document using the provided parameters including transaction ID, server token, and DID authentication details.
```

### Declaration
```swift
public func requestRestoreUser(tasURL: String,
                               txId: String,
                               hWalletToken: String,
                               serverToken: String,
                               didAuth: DIDAuth?) async throws -> _RequestRestoreDidDoc
```

### Parameters

| Parameter    | Type     | Description                                  | **M/O** | **Note** |
| ------------ | -------- | -------------------------------------------- | ------- | -------- |
| tasURL       | String   | The TAS URL endpoint for the restore request | M       |          |
| txId         | String   | The transaction ID for the restore request   | M       |          |
| hWalletToken | String   | The token used for wallet authentication     | M       |          |
| serverToken  | String   | The token used for server authentication     | M       |          |
| didAuth      | DIDAuth? | Authentication details for the DID           | O       |          |


### Returns

| Type                   | Description                            | **M/O** | **Note** |
| ---------------------- | -------------------------------------- | ------- | -------- |
| _RequestRestoreDidDoc  | An object containing the response data | M       |          |

### Usage

```swift
let response = try await WalletAPI.shared.requestRestoreUser(
    tasURL: "https://tas.example.com/restore",
    txId: "654321",
    hWalletToken: "wallet_token_value",
    serverToken: "server_token_value",
    didAuth: didAuthObject
)
```

<br>

## 4. Credential

## 4.1. requestIssueVc

### Description
`Request for issuance of VC.`

### Declaration

```swift
func requestIssueVc(url: String, hWalletToken: String, didAuth: DIDAuth, issuerProfile: _RequestIssueProfile, refId: String, serverToken: String?, APIGatewayURL: String) async throws -> (String, _RequestIssueVc?)
```

### Parameters

| Name          | Type                 | Description                        | **M/O** | **Note**               |
|---------------|----------------------|------------------------------------|---------|------------------------|
| url           | String               | TAS endpoint URL for the issuance request | M |                     |
| hWalletToken  | String               | Wallet Token                       | M       |                        |
| didAuth       | DIDAuth              | DIDAuth                            | M       | [DIDAuth](#6-didauth)  |
| issuerProfile | _RequestIssueProfile | issuer profile information         | M       |                        |
| refId         | String               | reference ID                       | M       |                        |
| serverToken   | String?              | Server token for accessing the TAS server | O | reference DIDDataModel |
| APIGatewayURL | String               | APIGateway URL                     | M       |                        |

### Returns

| Type            | Description | **M/O** | **Note**                                   |
| --------------- | ----------- | ------- | ------------------------------------------ |
| String          | VC ID       | M       | Returns the ID of the VC issued on success |
| _RequestIssueVc | VC          | M       | Returns the VC issued on success           |

### Usage

```swift
(vcId, issueVC) = try await WalletAPI.shared.requestIssueVc(url: TAS_URL, hWalletToken: hWalletToken, didAuth: didAuth, issuerProfile: issuerProfile, refId: refId, serverToken: hServerToken, APIGatewayURL: API_URL);
```

<br>

## 4.2. requestRevokeVc

### Description
`Request for VC revocation.`

### Declaration

```swift
func requestRevokeVc(hWalletToken: String, url: String, authType: VerifyAuthType, vcId: String, issuerNonce: String, txId: String, serverToken: String?, passcode: String? = nil) async throws -> _RequestRevokeVc
```

### Parameters

| Name         | Type           | Description                                   | **M/O** | **Note**               |
| ------------ | -------------- | --------------------------------------------- | ------- | ---------------------- |
| hWalletToken | String         | Wallet Token                                  | M       |                        |
| url          | String         | TAS endpoint URL for the revocation request   | M       |                        |
| authType     | VerifyAuthType | How the holder authenticates the revocation   | M       | DIDDataModel reference |
| vcId         | String         | ID of the VC to revoke                        | M       |                        |
| issuerNonce  | String         | Issuer nonce for the revocation transaction   | M       |                        |
| txId         | String         | Transaction Code                              | M       |                        |
| serverToken  | String?        | Server token for accessing the TAS server     | O       |                        |
| passcode     | String?        | PIN when the holder key is PIN-protected; `nil` for biometrics | O | |

### Returns

| Type            | Description    | **M/O** | **Note** |
|-----------------|----------------|---------|----------|
| _RequestRevokeVc | revoke result | M       |          |

### Usage

```swift
let revokeVc = try await WalletAPI.shared.requestRevokeVc(hWalletToken: self.hWalletToken,
                                                                url: URLs.TAS_URL + "/tas/api/v1/request-revoke-vc",
                                                                authType: authType,
                                                                vcId: super.vcId,
                                                                issuerNonce: super.issuerNonce,
                                                                txId: super.txId,
                                                                serverToken: self.hServerToken,
                                                                passcode: passcode)
```

<br>

## 4.3. getAllCredentials

### Description
`Get all VCs stored in the Wallet.`

### Declaration

```swift
func getAllCredentials(hWalletToken: String) throws -> [VerifiableCredential]?
```

### Parameters

| Name         | Type   | Description  | **M/O** | **Note** |
|--------------|--------|--------------|---------|----------|
| hWalletToken | String | Wallet Token | M       |          |

### Returns

| Type                   | Description     | **M/O** | **Note** |
|------------------------|-----------------|---------|----------|
| [VerifiableCredential] | VC List Object  | M       |          |

### Usage

```swift
let vcList = try WalletAPI.shared.getAllCredentials(hWalletToken: hWalletToken);
```

<br>

## 4.4. getCredentials

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

| Type                   | Description     | **M/O** | **Note** |
|------------------------|-----------------|---------|----------|
| [VerifiableCredential] | VC List Object  | M       |          |

### Usage

```swift
let vcList = try WalletAPI.shared.getCredentials(hWalletToken: hWalletToken, ids: [vc.id]);
```

<br>

## 4.5. deleteCredentials

### Description
`Delete a specific VC.`

### Declaration

```swift
func deleteCredentials(hWalletToken: String, ids: [String]) throws -> Bool
```

### Parameters

| Name        | Type     | Description      | **M/O** | **Note** |
|-------------|----------|------------------|---------|----------|
| hWalletToken| String   | Wallet Token     | M       |          |
| ids         | [String] | VC to be deleted | M       |          |

### Returns
Bool

### Usage

```swift
let result = try WalletAPI.shared.deleteCredentials(hWalletToken: hWalletToken, ids:[vc.id]);
```

<br>

## 4.6. createEncVp

### Description
`Generate encrypted VP and accE2e.`

### Declaration

```swift
func createEncVp(hWalletToken: String, claimInfos: [ClaimInfo], verifierProfile: _RequestProfile, APIGatewayURL: String, passcode: String? = nil) async throws -> (AccE2e, Data)
```

### Parameters

| Name            | Type             | Description                                 | **M/O** | **Note**               |
| --------------- | ---------------- | ------------------------------------------- | ------- | ---------------------- |
| hWalletToken    | String           | Wallet Token                                | M       |                        |
| claimInfos      | [ClaimInfo]      | Credentials and claim codes to present      | M       | DIDDataModel reference |
| verifierProfile | _RequestProfile  | Verifier profile, including the E2E encryption information | M | DIDDataModel reference |
| APIGatewayURL   | String           | APIGateway URL                              | M       |                        |
| passcode        | String?          | PIN when the holder key is PIN-protected; `nil` for biometrics | O | |

### Returns

| Type    | Description              | **M/O** | **Note**          |
|---------|--------------------------|---------|-------------------|
| AccE2e  | Cryptographic Object     | M       |acce2e             |
| Data    | Encrypted VP Object      | M       |encVp              |

### Usage

```swift
(accE2e, encVp) = try await WalletAPI.shared.createEncVp(hWalletToken: hWalletToken,
                                                         claimInfos: claimInfos,
                                                         verifierProfile: verifierProfile,
                                                         APIGatewayURL: API_URL,
                                                         passcode: passcode)
```

<br>

## 4.7. createVp

### Description
`Generate a Verifiable Presentation without encrypting it.`

Same selection input as `createEncVp`, but the VP is returned as an object instead of being sealed
for a verifier. Use it when the transport is not the OmniOne E2E channel — for example when the
caller encodes the VP itself.

### Declaration

```swift
func createVp(hWalletToken: String, claimInfos: [ClaimInfo], passcode: String? = nil, verifierNonce: String, challenge: OIDV4VPChallenge? = nil) throws -> VerifiablePresentation
```

### Parameters

| Name          | Type              | Description                                 | **M/O** | **Note**               |
| ------------- | ----------------- | ------------------------------------------- | ------- | ---------------------- |
| hWalletToken  | String            | Wallet Token                                | M       |                        |
| claimInfos    | [ClaimInfo]       | Credentials and claim codes to present      | M       | DIDDataModel reference |
| passcode      | String?           | PIN when the holder key is PIN-protected; `nil` for biometrics | O | |
| verifierNonce | String            | Nonce bound into the presentation proof     | M       |                        |
| challenge     | OIDV4VPChallenge? | `domain`/`challenge` pair to bind instead of the plain nonce | O | DIDDataModel reference |

### Returns

| Type                   | Description | **M/O** | **Note** |
|------------------------|-------------|---------|----------|
| VerifiablePresentation | VP object   | M       | DIDDataModel reference |

### Usage

```swift
let vp = try WalletAPI.shared.createVp(hWalletToken: hWalletToken,
                                       claimInfos: claimInfos,
                                       passcode: passcode,
                                       verifierNonce: verifierNonce)
```

<br>

## 4.8. isAnyCredentialsSaved

### Description
`Checks whether any credentials are saved in the wallet.`

### Declaration

```swift
public var isAnyCredentialsSaved: Bool

```

### Returns

| Type | Description                                                   | **M/O** | **Note** |
| ---- | ------------------------------------------------------------- | ------- | -------- |
| Bool | `true` if at least one credential is saved, otherwise `false` | M       |          |


### Usage

```swift
if WalletAPI.shared.isAnyCredentialsSaved {
    print("At least one credential is saved.")
} else {
    print("No credentials saved.")
}
```

<br>

## 5. ZKP

## 5.1. createEncZKProof

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

## 5.2. searchZKPCredentials

### Description  
`Searches for ZKP credentials that satisfy the given proof request.`

### Declaration

```swift
func searchZKPCredentials(hWalletToken: String, proofRequest: ProofRequest) throws -> AvailableReferent
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

## 5.3. getAllZKPCredentials

### Description  
`Retrieves all ZKP credentials stored in the wallet using the provided wallet token.`

### Declaration

```swift
func getAllZKPCredentials(hWalletToken: String) throws -> [ZKPCredential]?
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

## 5.4. isAnyZKPCredentialsSaved

### Description
`Checks whether any ZKP credentials are saved in the wallet.`

### Declaration

```swift
public var isAnyZKPCredentialsSaved: Bool

```

### Returns

| Type | Description                                                       | **M/O** | **Note** |
| ---- | ----------------------------------------------------------------- | ------- | -------- |
| Bool | `true` if at least one ZKP credential is saved, otherwise `false` | M       |          |


### Usage

```swift
if WalletAPI.shared.isAnyZKPCredentialsSaved {
    print("At least one ZKP credential is saved.")
} else {
    print("No ZKP credentials saved.")
}
```

<br>

## 5.5. isZKPCredentialSaved

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

## 5.6. getZKPCredentials

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

## 6. SecurityAuth

## 6.1. registerLock

### Description
`Sets the lock status of the wallet.`

### Declaration

```swift
func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool
```

### Parameters

| Name         | Type   | Description                  | **M/O** | **Note** |
|--------------|--------|------------------------------|---------|----------|
| hWalletToken | String | Wallet Token                 | M       |          |
| passcode     | String | Unlock PIN                   | M       |          |
| isLock       | Bool   | Whether the lock is activated | M      |          |

### Returns

| Type | Description                                    | **M/O** | **Note** |
| ---- | ---------------------------------------------- | ------- | -------- |
| Bool | Returns whether the lock setup was successful. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.registerLock(hWalletToken: hWalletToken, passcode:"123456", isLock: true);
```

<br>

## 6.2. authenticateLock

### Description
`Perform authentication to unlock the wallet.`

Pass `isChanging: true` when the passcode is being verified as a step of changing it. The passcode is
checked exactly the same way, but the wallet's locked/unlocked state is left untouched — a locked
wallet does not become unlocked as a side effect of the holder proving the old PIN.

### Declaration

```swift
@discardableResult
func authenticateLock(passcode: String, isChanging: Bool = false) throws -> Data?
```

### Parameters

| Name       | Type   | Description  | **M/O** | **Note**                  |
| ---------- | ------ | ------------ | ------- | ------------------------- |
| passcode   | String | Unlock PIN   | M       | PIN set when registerLock |
| isChanging | Bool   | `true` verifies the passcode without changing the lock state | O | Defaults to `false` |

### Returns

| Type  | Description                                                | **M/O** | **Note** |
|-------|------------------------------------------------------------|---------|----------|
| Data? | The authenticated data if the passcode is correct, otherwise `nil` | O | |

### Usage

```swift
try WalletAPI.shared.authenticateLock(passcode: "123456");

// Verifying the old PIN before changing it — the wallet stays locked
try WalletAPI.shared.authenticateLock(passcode: oldPasscode, isChanging: true);
```

<br>

## 6.3. isLock

### Description
`Whether the wallet has an Unlock PIN registered.`

This reports whether the lock is **set up** — a persistent value backed by the stored lock key, not
the wallet's current locked/unlocked state. It stays `true` after a successful `authenticateLock`,
and it survives app restarts. Use it to decide whether an unlock step applies at all (for example,
whether to present an unlock screen, or whether "change Unlock PIN" is available); the SDK does not
expose the per-session unlock state.

### Declaration

```swift
func isLock() throws -> Bool
```

### Parameters

None.

### Returns

| Type | Description                                          | **M/O** | **Note** |
|------|------------------------------------------------------|---------|----------|
| Bool | `true` if an Unlock PIN is registered for the wallet. | M       | Not the current locked state |

### Usage

```swift
let isLockRegistered = try WalletAPI.shared.isLock();
```

<br>

## 6.4. changePin

### Description
`Change PIN for signing`

### Declaration

```swift
public func changePin(id: String, oldPIN: String, newPIN: String) throws
```

### Parameters

| Name   | Type   | Description   | **M/O** | **Note** |
| ------ | ------ | ------------- | ------- | -------- |
| id     | String | key ID for signing | M       |          |
| oldPIN | String | old PIN      | M       |          |
| newPIN | String | new PIN    | M       |          |

### Returns

N/A

### Usage

```swift
try WalletAPI.shared.changePin(id: "pin", oldPIN: oldPIN, newPIN: passcode)
```

<br>

## 6.5. changeLock

### Description
`Changes the lock for the wallet`

### Declaration

```swift
public func changeLock(oldPasscode: String, newPasscode: String) throws
```

### Parameters

| Name          | Type   | Description              | **M/O** | **Note**                  |
| ------------- | ------ | ------------------------ | ------- | ------------------------- |
| oldPasscode   | String | Current set passcode     | M       |                           |
| newPasscode   | String | passcode to be changed   | M       |                           |

### Returns

Void

### Usage

```swift
try WalletAPI.shared.changeLock(oldPasscode: "123456", newPasscode: "987654");
```

<br>

## 6.6. authenticatePin

### Description
`Authenticates pin of the key which is walletPin`

### Declaration

```swift
// Declaration in swift
public func authenticatePin(id: String, pin: String) throws
```

### Parameters

| Name | Type   | Description      | **M/O** | **Note** |
|------|--------|------------------|---------|----------|
| id   | String | Key name         | M       |          |
| pin  | String | Pin of key       | M       |          |

### Returns

Void

### Usage
```swift
let pinID = "pin"
let pin = "password"
try WalletAPI.shared.authenticatePin(id: pinID, pin: pin)
```

<br>

## 7. OID4VC

OpenID4VCI (issuance) and OpenID4VP (presentation). Credentials issued through this section are
stored separately from the W3C credentials of section 4 and are listed with `getAllOID4VCs`, not
`getAllCredentials`.

## 7.1. requestIssueOID4VC

### Description
`Request issuance of a credential over OpenID4VCI and store it in the wallet.`

### Declaration

```swift
func requestIssueOID4VC(hWalletToken: String, metadata: IssuerMetadataResponse, token: TokenResponse, passcode: String?, configurationId: String, credentialIdentifier: String?, APIGatewayURL: String) async throws -> String
```

### Parameters

| Name                 | Type                   | Description                                        | **M/O** | **Note** |
|----------------------|------------------------|----------------------------------------------------|---------|----------|
| hWalletToken         | String                 | Wallet Token                                       | M       | Must allow `ISSUE_VC` |
| metadata             | IssuerMetadataResponse | Issuer metadata describing the offered credentials | M       |          |
| token                | TokenResponse          | Access token obtained from the issuer's token endpoint | M   |          |
| passcode             | String?                | PIN when the holder key is PIN-protected; `nil` for biometrics | O | |
| configurationId      | String                 | `credential_configuration_id` to issue             | M       | Must be one the issuer metadata offers |
| credentialIdentifier | String?                | `credential_identifier` when the token response lists them | O | |
| APIGatewayURL        | String                 | APIGateway URL                                     | M       |          |

### Returns

| Type   | Description                             | **M/O** | **Note** |
|--------|-----------------------------------------|---------|----------|
| String | ID of the credential stored in the wallet | M     |          |

### Usage

```swift
let credentialId = try await WalletAPI.shared.requestIssueOID4VC(hWalletToken: hWalletToken,
                                                                 metadata: issuerMetadata,
                                                                 token: tokenResponse,
                                                                 passcode: passcode,
                                                                 configurationId: configurationId,
                                                                 credentialIdentifier: nil,
                                                                 APIGatewayURL: API_URL)
```

<br>

## 7.2. getAllOID4VCs

### Description
`Look up all OID4VC credentials stored in the wallet.`

### Declaration

```swift
func getAllOID4VCs(hWalletToken: String) throws -> [SdJwtCredentialItem]
```

### Parameters

| Name         | Type   | Description  | **M/O** | **Note** |
|--------------|--------|--------------|---------|----------|
| hWalletToken | String | Wallet Token | M       | Must allow `LIST_VC`, `DETAIL_VC` or `LIST_VC_AND_PRESENT_VP` |

### Returns

| Type                  | Description                  | **M/O** | **Note** |
|-----------------------|------------------------------|---------|----------|
| [SdJwtCredentialItem] | All stored SD-JWT credentials | M      | Empty when none are saved |

### Usage

```swift
let credentials = try WalletAPI.shared.getAllOID4VCs(hWalletToken: hWalletToken)
```

<br>

## 7.3. getOID4VCs

### Description
`Look up OID4VC credentials by id.`

### Declaration

```swift
func getOID4VCs(hWalletToken: String, ids: [String]) throws -> [SdJwtCredentialItem]
```

### Parameters

| Name         | Type     | Description               | **M/O** | **Note** |
|--------------|----------|---------------------------|---------|----------|
| hWalletToken | String   | Wallet Token              | M       | Must allow `LIST_VC`, `DETAIL_VC` or `LIST_VC_AND_PRESENT_VP` |
| ids          | [String] | Credential IDs to look up | M       |          |

### Returns

| Type                  | Description             | **M/O** | **Note** |
|-----------------------|-------------------------|---------|----------|
| [SdJwtCredentialItem] | The matching credentials | M      |          |

### Usage

```swift
let credentials = try WalletAPI.shared.getOID4VCs(hWalletToken: hWalletToken, ids: [credentialId])
```

<br>

## 7.4. deleteOID4VCs

### Description
`Delete OID4VC credentials by id.`

### Declaration

```swift
func deleteOID4VCs(hWalletToken: String, ids: [String]) throws
```

### Parameters

| Name         | Type     | Description              | **M/O** | **Note** |
|--------------|----------|--------------------------|---------|----------|
| hWalletToken | String   | Wallet Token             | M       | Must allow `REMOVE_VC` |
| ids          | [String] | Credential IDs to delete | M       |          |

### Returns

Void

### Usage

```swift
try WalletAPI.shared.deleteOID4VCs(hWalletToken: hWalletToken, ids: [credentialId])
```

<br>

## 7.5. isAnyOID4VCSaved

### Description
`Checks whether any OID4VC credential is saved in the wallet.`

### Declaration

```swift
public var isAnyOID4VCSaved: Bool
```

### Returns

| Type | Description                                                              | **M/O** | **Note** |
| ---- | ------------------------------------------------------------------------ | ------- | -------- |
| Bool | `true` if at least one OID4VC credential is saved, otherwise `false`      | M       |          |

### Usage

```swift
if WalletAPI.shared.isAnyOID4VCSaved {
    // show the credential list
}
```

<br>

## 7.6. matchCredentials

### Description
`Finds the stored credentials that satisfy the verifier's DCQL query.`

The result is what the consent screen shows: one entry per matched credential, each already naming
the claims that would leave the wallet. Before calling `createVpToken` the app may drop the entries
the holder refuses, but it must pass the remaining entries back unchanged.

### Declaration

```swift
func matchCredentials(hWalletToken: String, authRequest: AuthorizationRequest) throws -> [MatchedCredential]
```

### Parameters

| Name         | Type                 | Description                                  | **M/O** | **Note** |
|--------------|----------------------|----------------------------------------------|---------|----------|
| hWalletToken | String               | Wallet Token                                 | M       | Must allow `PRESENT_VP` or `LIST_VC_AND_PRESENT_VP` |
| authRequest  | AuthorizationRequest | Verifier authorization request carrying the DCQL query | M | [AuthorizationRequest](#7-authorizationrequest) |

### Returns

| Type                 | Description                                                | **M/O** | **Note** |
|----------------------|------------------------------------------------------------|---------|----------|
| [MatchedCredential]  | One entry per matched credential, in DCQL declaration order | M      | [MatchedCredential](#8-matchedcredential) |

### Usage

```swift
let matched = try WalletAPI.shared.matchCredentials(hWalletToken: hWalletToken,
                                                    authRequest: authRequest)
```

<br>

## 7.7. createVpToken

### Description
`Builds the authorization response body carrying the vp_token for the selected credentials.`

The returned data is transfer-ready: POST it to the request's `response_uri` as
`application/x-www-form-urlencoded`. For `direct_post.jwt` the body is JWE-sealed with the
verifier's key from `client_metadata`.

Consent is given per credential, not per claim: to withhold a claim the app drops the whole
`MatchedCredential`, and each remaining entry must keep the `claimCodes` that `matchCredentials`
produced.

### Declaration

```swift
func createVpToken(hWalletToken: String, authRequest: AuthorizationRequest, matchedCredentials: [MatchedCredential], passcode: String?) throws -> Data
```

### Parameters

| Name               | Type                 | Description                                          | **M/O** | **Note** |
|--------------------|----------------------|------------------------------------------------------|---------|----------|
| hWalletToken       | String               | Wallet Token                                         | M       | Must allow `PRESENT_VP` or `LIST_VC_AND_PRESENT_VP` |
| authRequest        | AuthorizationRequest | The request the selection was matched against        | M       | [AuthorizationRequest](#7-authorizationrequest) |
| matchedCredentials | [MatchedCredential]  | The credentials to present, as returned by `matchCredentials` minus the refused entries | M | [MatchedCredential](#8-matchedcredential) |
| passcode           | String?              | PIN when the holder key is PIN-protected; `nil` for biometrics | O | |

### Returns

| Type | Description                     | **M/O** | **Note** |
|------|---------------------------------|---------|----------|
| Data | Transfer-ready response body    | M       | POST to `authRequest.responseUri` |

### Usage

```swift
let body = try WalletAPI.shared.createVpToken(hWalletToken: hWalletToken,
                                              authRequest: authRequest,
                                              matchedCredentials: selected,
                                              passcode: passcode)
```

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

## 7. AuthorizationRequest

### Description

`OpenID4VP authorization request received from the verifier.`

### Declaration

```swift
public struct AuthorizationRequest: Jsonable, FromSnake {
    public let responseUri: String
    public let nonce: String
    public let state: String
    public let clientId: String
    public let responseType: String
    public let responseMode: String
    public let dcqlQuery: DCQLQuery
    public let clientMetadata: [String: AnyJSON]
    public let iat: Int
}
```

### Property

| Name           | Type                 | Description                                              | **M/O** | **Note** |
| -------------- | -------------------- | -------------------------------------------------------- | ------- | -------- |
| responseUri    | String               | Endpoint the response body is POSTed to                  | M       |          |
| nonce          | String               | Verifier nonce, bound into the presentation              | M       |          |
| state          | String               | Verifier state, echoed back in the response              | M       |          |
| clientId       | String               | Verifier identifier; used as the presentation audience   | M       |          |
| responseType   | String               | OAuth response type                                      | M       |          |
| responseMode   | String               | `direct_post` or `direct_post.jwt`                       | M       | Other modes are rejected (`MSDKWLT05509`) |
| dcqlQuery      | DCQLQuery            | The credential query to match against                    | M       |          |
| clientMetadata | [String: AnyJSON]    | Verifier metadata; carries the response-encryption key for `direct_post.jwt` | M | |
| iat            | Int                  | Issued-at timestamp of the request                       | M       |          |
<br>

## 8. MatchedCredential

### Description

`One matched credential for a single DCQL credential query.`

Returned by `matchCredentials` and passed back to `createVpToken`. The app may drop entries the
holder refuses, or rebuild the list through the public initializer, but must not narrow an entry's
`claimCodes`.

### Declaration

```swift
public struct MatchedCredential {
    public let queryId: String
    public let credentialId: String
    public let claimCodes: [String]
}
```

### Property

| Name         | Type     | Description                                                   | **M/O** | **Note** |
| ------------ | -------- | ------------------------------------------------------------- | ------- | -------- |
| queryId      | String   | The DCQL credential query id this match answers (`dcql_query.credentials[].id`) | M | |
| credentialId | String   | The matched stored credential id                              | M       |          |
| claimCodes   | [String] | The claims to disclose — the ones the query asked for, or every claim the credential can disclose when it asked for the whole credential | M | Opaque values: display and compare them, never split or assemble them |
<br>
