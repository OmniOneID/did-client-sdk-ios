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
- Writer: 박주현
- Date: 2026-08-06
- Version: v3.0.0

| Version | Date       | History                               |
| -------- | ---------- | -------------------------------------- |
| v3.0.0   | 2026-08-06 | OID4VC 절 추가, 선언부를 SDK 기준으로 정정 |
| v2.0.1   | 2025-10-13 | DID 관련 함수 및 authenticatePin 추가 |
| v2.0.0   | 2025-05-27 | ZKP 관련 함수 추가                    |
| v1.0.0   | 2024-10-18 | 초기 작성                             |


<div style="page-break-after: always;"></div>

# 목차
- [APIs](#api-목록)
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


# API 목록
## 1. constructor

## 1.1. shared

### Description
 `WalletApi 생성자`

### Declaration

```swift
public static let shared: WalletAPI
```

### Parameters

| Name      | Type   | Description                      | **M/O** | **Note** |
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

## 2. Wallet

## 2.1. isExistWallet

### Description
 `DeviceKey Wallet 존재 유무를 확인한다.`

### Declaration

```swift
func isExistWallet() -> Bool
```

### Parameters

N/A

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool    | Wallet의 존재 여부를 반환한다.   | M       |          |

### Usage

```swift
let exists = WalletAPI.shared.isExistWallet()
```

<br>

## 2.2. createWallet

### Description
`DeviceKey Wallet을 생성한다.`

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
| boolean | Wallet 생성 성공 여부를 반환한다. | M       |          |

### Usage

```swift
let success = try await WalletAPI.shared.createWallet(tasURL:TAS_URL, walletURL: WALLET_URL)
```

<br>

## 2.3. deleteWallet

### Description
`DeviceKey Wallet을 삭제한다.`

### Declaration

```swift
func deleteWallet(deleteAll: Bool) throws
```

### Parameters

| Name      | Type | Description                                                                | **M/O** | **Note** |
|-----------|------|---------------------------------------------------------------------------|---------|----------|
| deleteAll | Bool | `true`이면 디바이스 DID Document와 디바이스 키까지 삭제하고 저장된 사용자·토큰·CA 패키지도 함께 지운다 | M | 홀더 DID Document·홀더 키·크리덴셜은 값과 무관하게 삭제된다 |

### Returns

Void

### Usage

```swift
try WalletAPI.shared.deleteWallet(deleteAll: true)
```

<br>

## 2.4. createWalletTokenSeed

### Description
`월렛 토큰 시드를 생성한다.`

### Declaration

```swift
func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String, userId: String) throws -> WalletTokenSeed
```

### Parameters

| Name      | Type   | Description                             | **M/O** | **Note** |
|-----------|--------|----------------------------------|---------|----------|
| purpose   | WalletTokenPurposeEnum |token 사용 목적                       | M       |[WalletTokenPurposeEnum](#1-wallet_token_purpose)         |
| pkgName   | String | 인가앱 Package Name                       | M       |          |
| userId    | String | 사용자 ID                        | M       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| WalletTokenSeed | 월렛 토큰 시드 객체   | M       |[WalletTokenSeed](#1-wallettokenseed)          |

### Usage

```swift
let tokenSeed = try WalletAPI.shared.createWalletTokenSeed(purpose: purpose, "org.opendid.did.ca", "user_id");
```

<br>

## 2.5. createNonceForWalletToken

### Description
`월렛 토큰 생성을 위한 nonce를 생성한다.`

### Declaration

```swift
func createNonceForWalletToken(walletTokenData: WalletTokenData, APIGatewayURL: String) async throws -> String
```

### Parameters

| Name           | Type           | Description                  | **M/O** | **Note** |
|----------------|----------------|-----------------------|---------|----------|
| walletTokenData | WalletTokenData | 월렛 토큰 데이터      | M       |[WalletTokenData](#2-wallettokendata)          |
| APIGatewayURL  | String         | nonce를 요청할 API Gateway URL | M   |          |

### Returns

| Type    | Description              | **M/O** | **Note** |
|---------|-------------------|---------|----------|
| String  | wallet token 생성을 위한 nonce | M       |          |

### Usage

```swift
let walletTokenData = try WalletTokenData.init(from: responseData)
let nonce = try await WalletAPI.shared.createNonceForWalletToken(walletTokenData: walletTokenData,
                                                                 APIGatewayURL: "https://api.example.com");
```

<br>

## 2.6. bindUser

### Description
`Wallet에 사용자 개인화를 수행한다.`

### Declaration

```swift
func bindUser(hWalletToken: String) throws -> Bool
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | 월렛토큰                  | M       |          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool | 개인화 성공 여부를 반환한다. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.bindUser(hWalletToken: hWalletToken);
```

<br>

## 2.7. unbindUser

### Description
`사용자 비개인화를 수행한다.`

### Declaration

```swift
func unbindUser(hWalletToken: String) throws -> Bool
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | 월렛토큰                  | M       |          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| boolean | 비개인화 성공 여부를 반환한다. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.unbindUser(hWalletToken: hWalletToken);
```

<br>

## 2.8. requestRegisterUser

### Description
`사용자 등록을 요청한다.`

### Declaration

```swift
func requestRegisterUser(tasURL: String, txId: String, hWalletToken: String, serverToken: String, signedDIDDoc: SignedDIDDoc) async throws -> _RequestRegisterUser
```

### Parameters

| Name         | Type           | Description                        | **M/O** | **Note** |
|--------------|----------------|-----------------------------|---------|----------|
| tasURL | String         | TAS URL                   | M       |          |
| txId     | String       | 거래코드               | M       |          |
| hWalletToken | String         | 월렛토큰                   | M       |          |
| serverToken     | String       | 서버토큰                | M       |          |
| signedDIDDoc|SignedDIDDoc | 서명된 DID Document 객체   | M       |[SignedDIDDoc](#4-signeddiddoc)          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| _RequestRegisterUser | 사용자 등록 프로토콜 수행 결과를 반환핟다. | M       |          |

### Usage

```swift
let _RequestRegisterUser = try await WalletAPI.shared.requestRegisterUser(tasURL: TAS_URL, txId: "txId", hWalletToken: hWalletToken, serverToken: hServerToken, signedDIDDoc: signedDidDoc);
```

<br>

## 2.9. getSignedWalletInfo

### Description
`서명된 Wallet 정보를 조회한다.`

### Declaration

```swift
func getSignedWalletInfo() throws -> SignedWalletInfo
```

### Parameters


### Returns

| Type             | Description                    | **M/O** | **Note** |
|------------------|-------------------------|---------|----------|
| SignedWalletInfo | 서명된 WalletInfo 객체       | M       |[SignedWalletInfo](#5-signedwalletinfo)          |

### Usage

```swift
let signedInfo = try WalletAPI.shared.getSignedWalletInfo();
```

<br>

## 3. DIDKey

## 3.1. createHolderDIDDocument

### Description
```
사용자 DID Document를 생성한다.
등록이 완료된 후에는
반드시 saveHolderDIDDocument를 호출해야 한다.
```

### Declaration

```swift
func createHolderDIDDocument(hWalletToken: String) throws -> DIDDocument
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | 월렛토큰                  | M       |          |


### Returns

| Type         | Description                  | **M/O** | **Note** |
|--------------|-----------------------|---------|----------|
| DIDDocument  | DID Document   | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.createHolderDIDDocument(hWalletToken: hWalletToken);
```

<br>

## 3.2. createSignedDIDDoc

### Description
`서명된 사용자 DID Document 객체를 생성한다.`

### Declaration

```swift
func createSignedDIDDoc(passcode: String? = nil) throws -> SignedDIDDoc
```

### Parameters

| Name      | Type    | Description                                            | **M/O** | **Note** |
|-----------|---------|--------------------------------------------------------|---------|----------|
| passcode  | String? | 홀더 키가 PIN 보호일 때의 PIN. 생체인증이면 `nil`        | O       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| SignedDIDDoc | 서명된 DID Document 객체   | M       |[SignedDIDDoc](#4-signeddiddoc)          |

### Usage

```swift
let signedDidDoc = try WalletAPI.shared.createSignedDIDDoc(passcode: passcode);
```

<br>

## 3.3. getDidDocument

### Description
`DID Document를 조회한다.`

### Declaration

```swift
func getDidDocument(type: DidDocumentType) throws -> DIDDocument
```

### Parameters

| Name | Type            | Description                                                            | **M/O** | **Note** |
|------|-----------------|------------------------------------------------------------------------|---------|----------|
| type | DidDocumentType | `.DeviceDidDocument` : deviceKey DID 문서, `.HolderDidDocumnet` : holder DID 문서 | M | |


### Returns

| Type         | Description   | **M/O** | **Note** |
|--------------|---------------|---------|----------|
| DIDDocument  | DID 문서       | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.getDidDocument(type: .HolderDidDocumnet)
```

<br>

## 3.4. isAnyKeysSaved

### Description
`저장된 키 유무를 반환한다.`

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

## 3.5. isSavedKey

### Description
```
지정된 식별자를 가진 키 쌍이 저장되어 있는지 확인한다.
지갑이 잠겨 있는 경우 에러가 발생.
이 함수는 지정된 키 ID가 지갑에 존재하는지 검증한다.
```

### Declaration

```swift
public func isSavedKey(keyId: String) throws -> Bool
```

### Parameters

| Name  | Type   | Description               | **M/O** | **Note** |
|-------|--------|---------------------------|---------|----------|
| keyId | String | 확인할 키의 식별자        | M       |          |


### Returns

| Type | Description                             | **M/O** | **Note** |
|------|-----------------------------------------|---------|----------|
| Bool | 키가 저장되어 있으면 `true`, 그렇지 않으면 `false` | M       |          |

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
`서명을 위한 PIN 키 쌍을 생성하여 Wallet에 저장한다.`

### Declaration

```swift
func generateKeyPair(hWalletToken: String, passcode: String? = nil, keyId: String, algType:AlgorithmType, promptMsg: String? = nil) throws -> Bool
```

### Parameters

| Name         | Type   | Description                        | **M/O** | **Note** |
|--------------|--------|-----------------------------|---------|----------|
| hWalletToken | String |월렛토큰                   | M       |          |
| passCode     | String |서명용 PIN               | M       | PIN 서명용 키 생성 시        | 
| keyId     | String |서명용 ID               | M       |         | 
| algType     | AlgorithmType |서명용 키 알고리즘 타입               | M       |         | 
| promptMsg     | String |생체인증 프롬프트 메시지               | M       |         | 

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
`지정된 키 ID와 연결된 개인 키를 사용하여 지정된 데이터를 서명한다.`

### Declaration

```swift
@discardableResult
public func sign(keyId: String,
                 pin: Data? = nil,
                 data: Data,
                 type: DidDocumentType) throws -> Data

```

### Parameters

| Parameter | Type            | Description                        | **M/O** | **Note** |
| --------- | --------------- | ---------------------------------- | ------- | -------- |
| keyId     | String          | 서명에 사용할 키의 ID               | M       |          |
| pin       | Data            | 키 복호화를 위한 PIN (선택 사항)    | O       |          |
| data      | Data            | 서명할 데이터의 다이제스트          | M       |          |
| type      | DidDocumentType | 키와 연결된 DID 문서의 유형         | M       |          |

### Returns

| Type | Description                        | **M/O** | **Note** |
| ---- | ---------------------------------- | ------- | -------- |
| Data | 지정된 키와 데이터를 사용해 생성된 서명 | M       |          |


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
`지정된 공개 키, 데이터, 그리고 서명을 사용하여 서명의 유효성을 검증한다.`

### Declaration

```swift
public func verify(publicKey: Data,
                   data: Data,
                   signature: Data) throws -> Bool
```

### Parameters

| Parameter | Type | Description             | **M/O** | **Note** |
| --------- | ---- | ----------------------- | ------- | -------- |
| publicKey | Data | 검증에 사용할 공개 키     | M       |          |
| data      | Data | 검증할 데이터의 해시된 값 | M       |          |
| signature | Data | 검증할 서명               | M       |          |

### Returns

| Type | Description                      | **M/O** | **Note** |
| ---- | -------------------------------- | ------- | -------- |
| Bool | 서명이 유효한지 여부를 나타내는 Bool 값  | M       |          |

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
`DIDAuth 서명을 수행한다.`

### Declaration

```swift
func getSignedDidAuth(authNonce: String, passcode: String? = nil) throws -> DIDAuth
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| authNonce  | String | profile의 auth nonce                  | M       |          |
| passcode  | String? | 홀더 키가 PIN 보호일 때의 PIN. 생체인증이면 `nil`  | O       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| DIDAuth   | 서명된 DIDAuth 객체   | M       |[DIDAuth](#6-didauth)          |

### Usage

```swift
let signedDIDAuth = try WalletAPI.shared.getSignedDidAuth(authNonce: authNonce, passcode: passcode);
```

<br>

## 3.10. updateHolderDIDDocument

### Description
```
DID 문서를 업데이트한다.
업데이트가 완료된 후에는
반드시 saveHolderDIDDocument를 호출해야 한다.
```

### Declaration

```swift
public func updateHolderDIDDocument(hWalletToken: String) throws -> DIDDocument
```

### Parameters

| Parameter    | Type   | Description | **M/O** | **Note** |
|--------------|--------|-------------|---------|----------|
| hWalletToken | String | 월렛토큰    | M       |          |


### Returns

| Type        | Description                              | **M/O** | **Note** |
| ----------- | ---------------------------------------- | ------- | -------- |
| DIDDocument | 업데이트된 문서를 나타내는 DIDDocument 객체      | M       |          |


### Usage

```swift
let didDocument = try WalletAPI.shared.updateHolderDIDDocument(
    hWalletToken: "wallet_token_value"
)
```

<br>

## 3.11. saveHolderDIDDocument

### Description
`사용자의 DID 문서 변경사항을 저장한다.`

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
지정된 지갑 토큰과 키 ID에 연결된 키 쌍을 삭제한다.
이 함수는 지갑에서 해당 키 쌍을 제거한다.
```

### Declaration

```swift
public func deleteKeyPair(hWalletToken: String, keyId: String) throws
```

### Parameters

| Parameter    | Type   | Description                    | **M/O** | **Note** |
| ------------ | ------ | ------------------------------ | ------- | -------- |
| hWalletToken | String | 검증에 사용되는 지갑 토큰       | M       |          |
| keyId        | String | 삭제할 키 쌍의 식별자           | M       |          |

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
사용자의 DID 문서를 업데이트하기 위한 요청.
이 함수는 트랜잭션 ID, 서버 토큰, DID 인증 정보, 그리고 서명된 DID 문서를 포함한 매개변수를 사용하여 지정된 URL로 요청을 전송함으로써 사용자의 DID 문서를 업데이트한다.
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

| Parameter    | Type         | Description                          | **M/O** | **Note** |
|--------------|--------------|--------------------------------------|---------|----------|
| tasURL       | String       | 업데이트 요청을 위한 TAS URL 엔드포인트 | M       |          |
| txId         | String       | 업데이트 요청에 사용되는 트랜잭션 ID     | M       |          |
| hWalletToken | String       | 지갑 인증에 사용되는 토큰               | M       |          |
| serverToken  | String       | 서버 인증에 사용되는 토큰               | M       |          |
| didAuth      | DIDAuth      | DID 인증에 대한 세부 정보               | O       |          |
| signedDIDDoc | SignedDIDDoc | 사용자를 나타내는 서명된 DID 문서       | O       |          |

### Returns

| Type                 | Description                 | **M/O** | **Note** |
|----------------------|-----------------------------|---------|----------|
| _RequestUpdateDidDoc | 응답 데이터를 포함하는 객체 | M       |          |

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
사용자의 DID 문서 복원을 요청.
이 함수는 트랜잭션 ID, 서버 토큰, 그리고 DID 인증 정보를 포함한 매개변수를 사용하여 지정된 URL로 요청을 전송함으로써 사용자의 DID 문서를 복원한다.
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

| Parameter    | Type     | Description                      | **M/O** | **Note** |
|--------------|----------|----------------------------------|---------|----------|
| tasURL       | String   | 복원 요청을 위한 TAS URL 엔드포인트 | M       |          |
| txId         | String   | 복원 요청에 사용되는 트랜잭션 ID     | M       |          |
| hWalletToken | String   | 지갑 인증에 사용되는 토큰           | M       |          |
| serverToken  | String   | 서버 인증에 사용되는 토큰           | M       |          |
| didAuth      | DIDAuth? | DID 인증에 대한 세부 정보           | O       |          |

### Returns

| Type                  | Description                 | **M/O** | **Note** |
|------------------------|-----------------------------|---------|----------|
| _RequestRestoreDidDoc  | 응답 데이터를 포함하는 객체 | M       |          |

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
`VC 발급을 요청한다.`

### Declaration

```swift
func requestIssueVc(url: String, hWalletToken: String, didAuth: DIDAuth, issuerProfile: _RequestIssueProfile, refId: String, serverToken: String?, APIGatewayURL: String) async throws -> (String, _RequestIssueVc?)
```

### Parameters

| Name           | Type                 | Description                  | **M/O** | **Note**                |
|----------------|----------------------|------------------------------|---------|-------------------------|
| url            | String               | 발급 요청을 보낼 TAS 엔드포인트 URL | M   |                         |
| hWalletToken   | String               | 월렛토큰                     | M       |                         |
| didAuth        | DIDAuth              | DIDAuth                      | M       | [DIDAuth](#6-didauth)   |
| issuerProfile  | _RequestIssueProfile | issuer profile 정보          | M       |                         |
| refId          | String               | 참조번호                     | M       |                         |
| serverToken    | String?              | TAS 서버 접근용 서버토큰      | O       | 데이터모델 참조          |
| APIGatewayURL  | String               | APIGateway URL               | M       |                         |

### Returns

| Type            | Description | **M/O** | **Note** |
|-----------------|-------------|---------|----------|
| String          | VC ID       | M       |성공 시 발급된 VC의 ID를 반환한다          |
| _RequestIssueVc | VC          | M       |성공 시 발급된 VC를 반환한다          |

### Usage

```swift
(vcId, issueVC) = try await WalletAPI.shared.requestIssueVc(url: TAS_URL, hWalletToken: hWalletToken, didAuth: didAuth, issuerProfile: issuerProfile, refId: refId, serverToken: hServerToken, APIGatewayURL: API_URL);
```

<br>

## 4.2. requestRevokeVc

### Description
`VC 폐기을 요청한다.`

### Declaration

```swift
func requestRevokeVc(hWalletToken: String, url: String, authType: VerifyAuthType, vcId: String, issuerNonce: String, txId: String, serverToken: String?, passcode: String? = nil) async throws -> _RequestRevokeVc
```

### Parameters

| Name         | Type           | Description                       | **M/O** | **Note**              |
| ------------ | -------------- | --------------------------------- | ------- | --------------------- |
| hWalletToken | String         | 월렛토큰                          | M       |                       |
| url          | String         | 폐기 요청을 보낼 TAS 엔드포인트 URL | M      |                       |
| authType     | VerifyAuthType | 폐기 시 홀더 인증 방식             | M       | 데이터모델 참조       |
| vcId         | String         | 폐기할 VC의 ID                    | M       |                       |
| issuerNonce  | String         | 폐기 거래의 issuer nonce          | M       |                       |
| txId         | String         | 거래코드                          | M       |                       |
| serverToken  | String?        | TAS 서버 접근용 서버토큰           | O       |                       |
| passcode     | String?        | 홀더 키가 PIN 보호일 때의 PIN. 생체인증이면 `nil` | O | |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| _RequestRevokeVc | 폐기 결과 | M       |성공 시 발급된 VC의 ID를 반환한다          |

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
`Wallet에 저장된 모든 VC를 조회한다.`

### Declaration

```swift
func getAllCredentials(hWalletToken: String) throws -> [VerifiableCredential]?
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | 월렛토큰                  | M       |          |

### Returns

| Type            | Description                | **M/O** | **Note** |
|-----------------|---------------------|---------|----------|
| [VerifiableCredential] | VC List 객체  | M       |          |

### Usage

```swift
let vcList = try WalletAPI.shared.getAllCredentials(hWalletToken: hWalletToken);
```

<br>

## 4.4. getCredentials

### Description
`특정 VC를 조회한다.`

### Declaration

```swift
func getCredentials(hWalletToken: String, ids: [String]) throws -> [VerifiableCredential]
```

### Parameters

| Name           | Type   | Description                       | **M/O** | **Note** |
|----------------|--------|----------------------------|---------|----------|
| hWalletToken   | String | 월렛토큰                  | M       |          |
| ids   | [String]   | 조회 대상 VC ID List               | M       |          |

### Returns

| Type        | Description                | **M/O** | **Note** |
|-------------|---------------------|---------|----------|
| [VerifiableCredential]  | VC List 객체    | M       |          |

### Usage

```swift
let vcList = try WalletAPI.shared.getCredentials(hWalletToken: hWalletToken, ids: [vc.id]);
```

<br>

## 4.5. deleteCredentials

### Description
`특정 VC를 삭제한다.`

### Declaration

```swift
func deleteCredentials(hWalletToken: String, ids: [String]) throws -> Bool
```

### Parameters

| Name           | Type   | Description                       | **M/O** | **Note** |
|----------------|--------|----------------------------|---------|----------|
| hWalletToken   | String | 월렛토큰                  | M       |          |
| ids   | [String]   | 삭제 대상 VC               | M       |          |

### Returns
Bool

### Usage

```swift
let result = try WalletAPI.shared.deleteCredentials(hWalletToken: hWalletToken, ids:[vc.id]);
```

<br>

## 4.6. createEncVp

### Description
`암호화된 VP와 accE2e를 생성한다.`

### Declaration

```swift
func createEncVp(hWalletToken: String, claimInfos: [ClaimInfo], verifierProfile: _RequestProfile, APIGatewayURL: String, passcode: String? = nil) async throws -> (AccE2e, Data)
```

### Parameters

| Name            | Type            | Description                        | **M/O** | **Note**        |
| --------------- | --------------- | ---------------------------------- | ------- | --------------- |
| hWalletToken    | String          | 월렛토큰                            | M       |                 |
| claimInfos      | [ClaimInfo]     | 제출할 크리덴셜과 클레임 코드        | M       | 데이터모델 참조 |
| verifierProfile | _RequestProfile | E2E 암복호화 정보를 포함한 검증자 프로파일 | M   | 데이터모델 참조 |
| APIGatewayURL   | String          | APIGateway URL                     | M       |                 |
| passcode        | String?         | 홀더 키가 PIN 보호일 때의 PIN. 생체인증이면 `nil` | O | |

### Returns

| Type   | Description    | **M/O** | **Note**         |
| ------ | -------------- | ------- | ---------------- |
| AccE2e | 암호화 객체    | M       | acce2e           |
| Data   | 암호화 VP 객체 | M       | encVp            |

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
`암호화하지 않은 Verifiable Presentation을 생성한다.`

`createEncVp`와 같은 선택 정보를 받지만, 검증자용으로 봉인하는 대신 VP 객체를 그대로 반환한다.
OmniOne E2E 채널이 아닌 경로로 전달할 때 — 예를 들어 호출자가 직접 인코딩할 때 — 사용한다.

### Declaration

```swift
func createVp(hWalletToken: String, claimInfos: [ClaimInfo], passcode: String? = nil, verifierNonce: String, challenge: OIDV4VPChallenge? = nil) throws -> VerifiablePresentation
```

### Parameters

| Name          | Type              | Description                        | **M/O** | **Note**        |
| ------------- | ----------------- | ---------------------------------- | ------- | --------------- |
| hWalletToken  | String            | 월렛토큰                            | M       |                 |
| claimInfos    | [ClaimInfo]       | 제출할 크리덴셜과 클레임 코드        | M       | 데이터모델 참조 |
| passcode      | String?           | 홀더 키가 PIN 보호일 때의 PIN. 생체인증이면 `nil` | O | |
| verifierNonce | String            | presentation proof에 바인딩할 nonce | M       |                 |
| challenge     | OIDV4VPChallenge? | nonce 대신 바인딩할 `domain`/`challenge` 쌍 | O | 데이터모델 참조 |

### Returns

| Type                   | Description | **M/O** | **Note**        |
|------------------------|-------------|---------|-----------------|
| VerifiablePresentation | VP 객체      | M       | 데이터모델 참조 |

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
`지갑에 VC가 있는지 확인한다.`

### Declaration

```swift
public var isAnyCredentialsSaved: Bool

```

### Returns

| Type | Description                                             | **M/O** | **Note** |
| ---- | ------------------------------------------------------- | ------- | -------- |
| Bool | 하나 이상의 자격증명이 저장되어 있으면 `true`, 그렇지 않으면 `false` | M       |          |


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
`영지식 증명(ZK Proof)을 생성하고 암호화하여 E2E 파라미터와 함께 반환한다.`

### Declaration

```swift
func createEncZKProof(hWalletToken: String, selectedReferents: [UserReferent], proofParam: ZKProofParam, proofRequestProfile: _RequestProofRequestProfile, APIGatewayURL: String) async throws -> (AccE2e, Data)
```

### Parameters

| Name                 | Type                         | Description                              | **M/O** | **Note**                          |
| -------------------- | ---------------------------- | ---------------------------------------- | ------- | --------------------------------- |
| hWalletToken         | String                       | 월렛 토큰                                 | M       |                                   |
| selectedReferents    | [UserReferent]               | 선택된 자격증명 참조 목록                  | M       | ProofRequest 조건을 만족해야 함   |
| proofParam           | ZKProofParam                 | 영지식 증명 생성을 위한 추가 파라미터      | M       |                                   |
| proofRequestProfile  | _RequestProofRequestProfile  | 검증자 프로필 (DID, ZKP 인증서 등 포함)    | M       |                                   |
| APIGatewayURL        | String                       | API Gateway URL                           | M       | 통신 및 검증에 사용됨            |

### Returns

| Type         | Description                     | **M/O** | **Note**                                |
| ------------ | ------------------------------- | ------- | --------------------------------------- |
| AccE2e       | 암호화 관련 정보 객체             | M       | 증명 데이터 암호화 포함                 |
| Data (EncZKProof) | 암호화된 영지식 증명 데이터       | M       | 전송 가능한 형식                        |

### Throws

- 암호화 실패, 인코딩 오류, 네트워크 통신 실패 등의 예외 발생 가능


<br>

## 5.2. searchZKPCredentials

### Description  
`주어진 증명 요청(proof request)을 만족하는 자격증명을 검색한다.`

### Declaration

```swift
func searchZKPCredentials(hWalletToken: String, proofRequest: ProofRequest) throws -> AvailableReferent
```

### Parameters

| Name         | Type         | Description             | **M/O** | **Note**                     |
| ------------ | ------------ | ----------------------- | ------- | ---------------------------- |
| hWalletToken | String       | 월렛 토큰                | M       | 유효하지 않을 경우 예외 발생 |
| proofRequest | ProofRequest | 증명 요청 객체            | M       | 필요한 속성과 조건 포함      |

### Returns

| Type              | Description                             | **M/O** | **Note**                                |
| ----------------- | --------------------------------------- | ------- | --------------------------------------- |
| AvailableReferent | 조건에 일치하는 자격증명 참조 정보 객체 | M       | 검색된 참조 정보 목록 포함              |

### Throws

(정의된 예외 없음, 구현에 따라 추가 가능)


<br>

## 5.3. getAllZKPCredentials

### Description  
`월렛에 저장된 모든 ZKP 자격증명을 조회한다.`

### Declaration

```swift
func getAllZKPCredentials(hWalletToken: String) throws -> [ZKPCredential]?
```

### Parameters

| Name         | Type   | Description    | **M/O** | **Note**                     |
| ------------ | ------ | -------------- | ------- | ---------------------------- |
| hWalletToken | String | 월렛 토큰       | M       | 유효하지 않을 경우 예외 발생 |

### Returns

| Type              | Description                    | **M/O** | **Note**                                |
| ----------------- | ------------------------------ | ------- | --------------------------------------- |
| [ZKPCredential]?  | 저장된 ZKP 자격증명 리스트 (옵셔널) | O       | 저장된 항목이 없으면 `nil` 반환         |

### Throws

- `WalletApiError(VERIFY_TOKEN_FAIL)` : 월렛 토큰 검증 실패 시 발생


<br>

## 5.4. isAnyZKPCredentialsSaved

### Description
`지갑에 ZKP VC가 있는지 확인한다.`

### Declaration

```swift
public var isAnyZKPCredentialsSaved: Bool

```

### Returns

| Type | Description                                                 | **M/O** | **Note** |
| ---- | ----------------------------------------------------------- | ------- | -------- |
| Bool | 하나 이상의 ZKP 자격증명이 저장되어 있으면 `true`, 그렇지 않으면 `false` | M       |          |


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
`주어진 ID를 가진 ZKP 자격증명이 저장되어 있는지 확인한다.`

### Declaration

```swift
func isZKPCredentialSaved(id: String) -> Bool
```

### Parameters

| Name | Type   | Description      | **M/O** | **Note** |
| ---- | ------ | ---------------- | ------- | -------- |
| id   | String | 자격증명 ID       | M       |          |

### Returns

| Type | Description                    | **M/O** | **Note**                                |
| ---- | ------------------------------ | ------- | ---------------------------------------- |
| Bool | 저장 여부 (`true`/`false`)      | M       | `true`: 저장되어 있음<br>`false`: 없음 |

<br>

## 5.6. getZKPCredentials

### Description
`지정한 ZKP 자격증명들을 월렛에서 조회한다.`

### Declaration

```swift
func getZKPCredentials(hWalletToken: String, ids: [String]) throws -> [ZKPCredential]
```

### Parameters

| Name         | Type     | Description            | **M/O** | **Note**                                |
| ------------ | -------- | ---------------------- | ------- | ---------------------------------------- |
| hWalletToken | String   | 월렛 토큰               | M       | 유효하지 않을 경우 예외 발생            |
| ids          | [String] | 조회할 자격증명 ID 배열 | M       |                                          |

### Returns

| Type            | Description                     | **M/O** | **Note**                      |
| --------------- | ------------------------------- | ------- | ----------------------------- |
| [ZKPCredential] | 조회된 ZKP 자격증명 객체 목록     | M       | 각 객체는 자격증명 정보를 포함 |

### Throws

- `WalletApiError(VERIFY_TOKEN_FAIL)` : 월렛 토큰 검증 실패 시 발생

<br>

## 6. SecurityAuth

## 6.1. registerLock

### Description
`Wallet의 잠금 상태를 설정한다.`

### Declaration

```swift
func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool
```

### Parameters

| Name         | Type   | Description                        | **M/O** | **Note** |
|--------------|--------|-----------------------------|---------|----------|
| hWalletToken | String | 월렛토큰                   | M       |          |
| passcode     | String | Unlock PIN               | M       |          |
| isLock       | Bool | 잠금 활성화 여부            | M       |          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool | 잠금 설정 성공 여부를 반환한다. | M       |          |

### Usage

```swift
let success = try WalletAPI.shared.registerLock(hWalletToken: hWalletToken, passcode:"123456", isLock: true);
```

<br>

## 6.2. authenticateLock

### Description
`Wallet의 Unlock을 위한 인증을 수행한다.`

패스코드를 변경하는 과정에서 기존 패스코드를 확인할 때는 `isChanging: true`로 호출한다. 패스코드
검증 방식은 동일하지만 Wallet의 잠금/해제 상태는 그대로 유지된다 — 홀더가 기존 PIN을 증명했다는
이유만으로 잠긴 Wallet이 풀리지 않는다.

### Declaration

```swift
@discardableResult
func authenticateLock(passcode: String, isChanging: Bool = false) throws -> Data?
```

### Parameters

| Name       | Type   | Description                        | **M/O** | **Note** |
|------------|--------|------------------------------------|---------|----------|
| passcode   | String | Unlock PIN                         | M       | registerLock 시 설정한 PIN |
| isChanging | Bool   | `true`면 잠금 상태를 바꾸지 않고 패스코드만 검증한다 | O | 기본값 `false` |

### Returns

| Type  | Description                                   | **M/O** | **Note** |
|-------|-----------------------------------------------|---------|----------|
| Data? | 패스코드가 맞으면 인증 데이터, 아니면 `nil`      | O       |          |

### Usage

```swift
try WalletAPI.shared.authenticateLock(passcode: "123456");

// 패스코드 변경 전 기존 PIN 확인 — Wallet은 잠긴 상태를 유지한다
try WalletAPI.shared.authenticateLock(passcode: oldPasscode, isChanging: true);
```

<br>

## 6.3. isLock

### Description
`Wallet에 Unlock PIN이 등록되어 있는지 조회한다.`

잠금이 **설정되어 있는지**를 반환하며, 저장된 잠금 키에 기반한 영속 값이다. 현재 잠금 상태가 아니다 —
`authenticateLock` 으로 해제한 뒤에도 `true` 이며 앱을 다시 실행해도 유지된다. 잠금 단계가 적용되는
상황인지 판단할 때 사용한다(잠금 화면 표시 여부, "Change Unlock PIN" 메뉴 활성 여부 등). 세션 단위의
해제 상태는 SDK가 공개하지 않는다.

### Declaration

```swift
func isLock() throws -> Bool
```

### Parameters

N/A

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool | Unlock PIN이 등록되어 있으면 `true`. | M       | 현재 잠금 상태가 아님 |

### Usage

```swift
let isLockRegistered = try WalletAPI.shared.isLock();
```

<br>

## 6.4. changePin

### Description
`서명용 PIN을 변경한다.`

### Declaration

```swift
public func changePin(id: String, oldPIN: String, newPIN: String) throws
```

### Parameters

| Name   | Type   | Description   | **M/O** | **Note** |
| ------ | ------ | ------------- | ------- | -------- |
| id     | String | 서명용 key ID | M       |          |
| oldPIN | String | 기존 PIN      | M       |          |
| newPIN | String | 새로운 PIN    | M       |          |

### Returns

N/A

### Usage

```swift
try WalletAPI.shared.changePin(id: "pin", oldPIN: oldPIN, newPIN: passcode)
```

<br>

## 6.5. changeLock

### Description
`Wallet의 lock 설정을 변경한다`

### Declaration

```swift
public func changeLock(oldPasscode: String, newPasscode: String) throws
```

### Parameters

| Name        | Type   | Description          | **M/O** | **Note** |
|-------------|--------|----------------------|---------|----------|
| oldPasscode | String | 현재 설정된 passcode | M       |          |
| newPasscode | String | 새로 설정할 passcode | M       |          |

### Returns

Void

### Usage

```swift
try WalletAPI.shared.changeLock(oldPasscode: "123456", newPasscode: "987654");
```

<br>

## 6.6. authenticatePin

### Description
`WalletPIN인 키의 PIN을 인증한다.`

### Declaration

```swift
// Declaration in swift
public func authenticatePin(id: String, pin: String) throws
```

### Parameters

| Name | Type   | Description | **M/O** | **Note** |
|------|--------|-------------|---------|----------|
| id   | String | 키 이름      | M       |          |
| pin  | String | 키의 PIN     | M       |          |

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

OpenID4VCI(발급)와 OpenID4VP(제출). 이 절로 발급받은 크리덴셜은 4절의 W3C 크리덴셜과 별도로
저장되며, `getAllCredentials`가 아니라 `getAllOID4VCs`로 조회한다.

## 7.1. requestIssueOID4VC

### Description
`OpenID4VCI로 크리덴셜 발급을 요청하고 Wallet에 저장한다.`

### Declaration

```swift
func requestIssueOID4VC(hWalletToken: String, metadata: IssuerMetadataResponse, token: TokenResponse, passcode: String?, configurationId: String, credentialIdentifier: String?, APIGatewayURL: String) async throws -> String
```

### Parameters

| Name                 | Type                   | Description                                | **M/O** | **Note** |
|----------------------|------------------------|--------------------------------------------|---------|----------|
| hWalletToken         | String                 | 월렛토큰                                    | M       | `ISSUE_VC` 권한 필요 |
| metadata             | IssuerMetadataResponse | 발급 가능한 크리덴셜을 기술한 issuer 메타데이터 | M    |          |
| token                | TokenResponse          | issuer 토큰 엔드포인트에서 받은 액세스 토큰    | M       |          |
| passcode             | String?                | 홀더 키가 PIN 보호일 때의 PIN. 생체인증이면 `nil` | O | |
| configurationId      | String                 | 발급받을 `credential_configuration_id`       | M       | issuer 메타데이터가 제공하는 값이어야 한다 |
| credentialIdentifier | String?                | 토큰 응답이 `credential_identifier`를 제공할 때의 값 | O | |
| APIGatewayURL        | String                 | APIGateway URL                             | M       |          |

### Returns

| Type   | Description               | **M/O** | **Note** |
|--------|---------------------------|---------|----------|
| String | Wallet에 저장된 크리덴셜의 ID | M      |          |

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
`Wallet에 저장된 모든 OID4VC 크리덴셜을 조회한다.`

### Declaration

```swift
func getAllOID4VCs(hWalletToken: String) throws -> [SdJwtCredentialItem]
```

### Parameters

| Name         | Type   | Description | **M/O** | **Note** |
|--------------|--------|-------------|---------|----------|
| hWalletToken | String | 월렛토큰     | M       | `LIST_VC`, `DETAIL_VC`, `LIST_VC_AND_PRESENT_VP` 중 하나의 권한 필요 |

### Returns

| Type                  | Description                | **M/O** | **Note** |
|-----------------------|----------------------------|---------|----------|
| [SdJwtCredentialItem] | 저장된 모든 SD-JWT 크리덴셜 | M       | 없으면 빈 배열 |

### Usage

```swift
let credentials = try WalletAPI.shared.getAllOID4VCs(hWalletToken: hWalletToken)
```

<br>

## 7.3. getOID4VCs

### Description
`ID로 OID4VC 크리덴셜을 조회한다.`

### Declaration

```swift
func getOID4VCs(hWalletToken: String, ids: [String]) throws -> [SdJwtCredentialItem]
```

### Parameters

| Name         | Type     | Description        | **M/O** | **Note** |
|--------------|----------|--------------------|---------|----------|
| hWalletToken | String   | 월렛토큰            | M       | `LIST_VC`, `DETAIL_VC`, `LIST_VC_AND_PRESENT_VP` 중 하나의 권한 필요 |
| ids          | [String] | 조회할 크리덴셜 ID  | M       |          |

### Returns

| Type                  | Description       | **M/O** | **Note** |
|-----------------------|-------------------|---------|----------|
| [SdJwtCredentialItem] | 조회된 크리덴셜    | M       |          |

### Usage

```swift
let credentials = try WalletAPI.shared.getOID4VCs(hWalletToken: hWalletToken, ids: [credentialId])
```

<br>

## 7.4. deleteOID4VCs

### Description
`ID로 OID4VC 크리덴셜을 삭제한다.`

### Declaration

```swift
func deleteOID4VCs(hWalletToken: String, ids: [String]) throws
```

### Parameters

| Name         | Type     | Description       | **M/O** | **Note** |
|--------------|----------|-------------------|---------|----------|
| hWalletToken | String   | 월렛토큰           | M       | `REMOVE_VC` 권한 필요 |
| ids          | [String] | 삭제할 크리덴셜 ID | M       |          |

### Returns

Void

### Usage

```swift
try WalletAPI.shared.deleteOID4VCs(hWalletToken: hWalletToken, ids: [credentialId])
```

<br>

## 7.5. isAnyOID4VCSaved

### Description
`Wallet에 저장된 OID4VC 크리덴셜이 하나라도 있는지 확인한다.`

### Declaration

```swift
public var isAnyOID4VCSaved: Bool
```

### Returns

| Type | Description                                            | **M/O** | **Note** |
| ---- | ------------------------------------------------------ | ------- | -------- |
| Bool | OID4VC 크리덴셜이 하나 이상 있으면 `true`, 아니면 `false` | M       |          |

### Usage

```swift
if WalletAPI.shared.isAnyOID4VCSaved {
    // 크리덴셜 목록 표시
}
```

<br>

## 7.6. matchCredentials

### Description
`검증자의 DCQL 쿼리를 만족하는 저장된 크리덴셜을 찾는다.`

반환값이 곧 동의 화면에 보여줄 내용이다. 매칭된 크리덴셜마다 한 항목씩, Wallet에서 나갈 클레임의
이름이 이미 채워져 있다. `createVpToken`을 호출하기 전에 앱은 홀더가 거부한 항목을 뺄 수 있지만,
남긴 항목은 그대로 넘겨야 한다.

### Declaration

```swift
func matchCredentials(hWalletToken: String, authRequest: AuthorizationRequest) throws -> [MatchedCredential]
```

### Parameters

| Name         | Type                 | Description                          | **M/O** | **Note** |
|--------------|----------------------|--------------------------------------|---------|----------|
| hWalletToken | String               | 월렛토큰                              | M       | `PRESENT_VP` 또는 `LIST_VC_AND_PRESENT_VP` 권한 필요 |
| authRequest  | AuthorizationRequest | DCQL 쿼리를 담은 검증자 인가 요청       | M       | [AuthorizationRequest](#7-authorizationrequest) |

### Returns

| Type                | Description                              | **M/O** | **Note** |
|---------------------|------------------------------------------|---------|----------|
| [MatchedCredential] | 매칭된 크리덴셜마다 한 항목, DCQL 선언 순서 | M       | [MatchedCredential](#8-matchedcredential) |

### Usage

```swift
let matched = try WalletAPI.shared.matchCredentials(hWalletToken: hWalletToken,
                                                    authRequest: authRequest)
```

<br>

## 7.7. createVpToken

### Description
`선택한 크리덴셜로 vp_token을 담은 인가 응답 본문을 생성한다.`

반환되는 데이터는 그대로 전송 가능하다. 요청의 `response_uri`로
`application/x-www-form-urlencoded`로 POST하면 된다. `direct_post.jwt`인 경우 `client_metadata`의
검증자 키로 JWE 봉인된 본문이 반환된다.

동의는 클레임 단위가 아니라 크리덴셜 단위다. 클레임을 빼고 싶으면 해당 `MatchedCredential`을 통째로
제거해야 하며, 남긴 항목은 `matchCredentials`가 만든 `claimCodes`를 그대로 유지해야 한다.

### Declaration

```swift
func createVpToken(hWalletToken: String, authRequest: AuthorizationRequest, matchedCredentials: [MatchedCredential], passcode: String?) throws -> Data
```

### Parameters

| Name               | Type                 | Description                              | **M/O** | **Note** |
|--------------------|----------------------|------------------------------------------|---------|----------|
| hWalletToken       | String               | 월렛토큰                                  | M       | `PRESENT_VP` 또는 `LIST_VC_AND_PRESENT_VP` 권한 필요 |
| authRequest        | AuthorizationRequest | 선택의 근거가 된 인가 요청                 | M       | [AuthorizationRequest](#7-authorizationrequest) |
| matchedCredentials | [MatchedCredential]  | 제출할 크리덴셜. `matchCredentials` 반환값에서 거부된 항목을 뺀 것 | M | [MatchedCredential](#8-matchedcredential) |
| passcode           | String?              | 홀더 키가 PIN 보호일 때의 PIN. 생체인증이면 `nil` | O | |

### Returns

| Type | Description           | **M/O** | **Note** |
|------|-----------------------|---------|----------|
| Data | 전송 가능한 응답 본문   | M       | `authRequest.responseUri`로 POST |

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

`인가앱이 월렛에 월렛토큰 생성 요청 시 전달하는 데이터`

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

| Name       | Type                   | Description         | **M/O** | **Note**                                          |
| ---------- | ---------------------- | ------------------- | ------- | ------------------------------------------------- |
| purpose    | WalletTokenPurposeEnum | token 사용 목적     | M       | [WalletTokenPurposeEnum](#1-wallet_token_purpose) |
| pkgName    | String                 | 인가앱 Package Name | M       |                                                   |
| nonce      | String                 | wallet nonce        | M       |                                                   |
| validUntil | String                 | token 만료일시      | M       |                                                   |
| userId     | String                 | 사용자 ID           | M       |                                                   |
<br>

## 2. WalletTokenData

### Description

`인가앱이 월렛에 월렛토큰 생성 요청 시 월렛이 생성하여 인가앱으로 전달하는 데이터`

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

| Name       | Type            | Description         | **M/O** | **Note**                              |
| ---------- | --------------- | ------------------- | ------- | ------------------------------------- |
| seed       | WalletTokenSeed | WalletToken Seed    | M       | [WalletTokenSeed](#1-wallettokenseed) |
| sha256_pii | String          | 사용자 PII의 해시값 | M       |                                       |
| provider   | Provider        | wallet 사업자 정보  | M       | [Provider](#3-provider)               |
| nonce      | String          | provider nonce      | M       |                                       |
| proof      | Proof           | provider proof      | M       |                                       |
<br>

## 3. Provider

### Description

`Provider 정보`

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
| certVcRef | String | provider 가입증명서 VC URL | M       |          |
<br>

## 4. SignedDIDDoc

### Description

`월렛이 holder의 DID Document를 서명하여 controller에게 등록을 요청하기 위한 문서의 데이터`

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

| Name        | Type   | Description                              | **M/O** | **Note** |
| ----------- | ------ | ---------------------------------------- | ------- | -------- |
| ownerDidDoc | String | ownerDidDoc의 multibase 인코딩 값        | M       |          |
| wallet      | Wallet | wallet의 id와 wallet의 DID로 구성된 객체 | M       |          |
| nonce       | String | wallet nonce                             | M       |          |
| proof       | Proof  | wallet proof                             | M       |          |
<br>

## 5. SignedWalletInfo

### Description

`서명 된 walletinfo 데이터`

### Declaration

```swift
public struct SignedWalletInfo: Jsonable {
    var wallet: Wallet
    var nonce: String
    var proof: Proof
}
```

### Property

| Name          | Type            | Description                | **M/O** | **Note**               |
|---------------|-----------------|----------------------------|---------|------------------------|
| wallet    | Wallet | wallet의 id와 wallet의 DID로 구성된 객체                        | M       |          |
| nonce    | String | wallet nonce                        | M       |          |
| proof    | Proof | wallet proof                        | M       |          |
<br>

## 6. DIDAuth

### Description

`DID Auth 데이터`

### Declaration

```swift
public struct DIDAuth: Jsonable {
    var did: String
    var authNonce: String
    var proof: Proof
}
```

### Property

| Name      | Type   | Description          | **M/O** | **Note** |
| --------- | ------ | -------------------- | ------- | -------- |
| did       | String | 인증 대상자의 DID    | M       |          |
| authNonce | String | DID Auth 용 nonce    | M       |          |
| proof     | Proof  | authentication proof | M       |          |
<br>

## 7. AuthorizationRequest

### Description

`검증자로부터 받은 OpenID4VP 인가 요청.`

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

| Name           | Type              | Description                                    | **M/O** | **Note** |
| -------------- | ----------------- | ---------------------------------------------- | ------- | -------- |
| responseUri    | String            | 응답 본문을 POST할 엔드포인트                    | M       |          |
| nonce          | String            | presentation에 바인딩되는 검증자 nonce           | M       |          |
| state          | String            | 응답에 그대로 실어 보내는 검증자 state           | M       |          |
| clientId       | String            | 검증자 식별자. presentation의 audience로 쓰인다  | M       |          |
| responseType   | String            | OAuth response type                            | M       |          |
| responseMode   | String            | `direct_post` 또는 `direct_post.jwt`            | M       | 그 외 값은 거부된다 (`MSDKWLT05509`) |
| dcqlQuery      | DCQLQuery         | 매칭 대상 크리덴셜 쿼리                          | M       |          |
| clientMetadata | [String: AnyJSON] | 검증자 메타데이터. `direct_post.jwt`의 응답 암호화 키를 담는다 | M | |
| iat            | Int               | 요청 발행 시각                                   | M       |          |
<br>

## 8. MatchedCredential

### Description

`하나의 DCQL 크리덴셜 쿼리에 대해 매칭된 크리덴셜 한 건.`

`matchCredentials`가 반환하고 `createVpToken`에 그대로 전달한다. 앱은 홀더가 거부한 항목을 빼거나
public 이니셜라이저로 목록을 다시 구성할 수 있지만, 항목의 `claimCodes`를 좁혀서는 안 된다.

### Declaration

```swift
public struct MatchedCredential {
    public let queryId: String
    public let credentialId: String
    public let claimCodes: [String]
}
```

### Property

| Name         | Type     | Description                                              | **M/O** | **Note** |
| ------------ | -------- | -------------------------------------------------------- | ------- | -------- |
| queryId      | String   | 이 매칭이 답하는 DCQL 크리덴셜 쿼리 id (`dcql_query.credentials[].id`) | M | |
| credentialId | String   | 매칭된 저장 크리덴셜 id                                    | M       |          |
| claimCodes   | [String] | 공개할 클레임. 쿼리가 요구한 클레임이거나, 크리덴셜 전체를 요구했다면 공개 가능한 모든 클레임 | M | 불투명 값이다. 표시·대조에만 쓰고 쪼개거나 조립하지 않는다 |
<br>
