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
- Date: 2025-10-13
- Version: v2.0.0

| Version | Date       | History                               |
| -------- | ---------- | -------------------------------------- |
| v2.0.1   | 2025-10-13 | DID 관련 함수 및 authenticatePin 추가 |
| v2.0.0   | 2025-05-27 | ZKP 관련 함수 추가                    |
| v1.0.0   | 2024-10-18 | 초기 작성                             |


<div style="page-break-after: always;"></div>

# 목차
- [APIs](#api-목록)
    - [1. Constructor](#1-constructor)
        - [1.1. shared](#11-shared)
    - [2. Device Wallet](#2-device-wallet)
        - [2.1. isExistWallet](#21-isexistwallet)
        - [2.2. createWallet](#22-createwallet)
        - [2.3. deleteWallet](#23-deletewallet)
    - [3. Token](#3-token)
        - [3.1. getSignedWalletInfo](#31-getsignedwalletinfo)
        - [3.2. createWalletTokenSeed](#32-createwallettokenseed)
        - [3.3. createNonceForWalletToken](#33-createnonceforwallettoken)
    - [4. User Binding](#4-user-binding)
        - [4.1. bindUser](#41-binduser)
        - [4.2. unbindUser](#42-unbinduser)
    - [5. Wallet Authentication](#5-wallet-authentication)
        - [5.1. isLock](#51-islock)
        - [5.2. registerLock](#52-registerlock)
        - [5.3. authenticateLock](#53-authenticatelock)
        - [5.4. changeLock](#54-changelock)
    - [6. DID Auth](#6-did-auth)
        - [6.1. getSignedDidAuth](#61-getsigneddidauth)
    - [7. API for Protocol](#7-api-for-protocol)
        - [7.1. createSignedDIDDoc](#71-createsigneddiddoc)
        - [7.2. requestRegisterUser](#72-requestregisteruser)
        - [7.3. requestUpdateUser](#73-requestupdateuser)
        - [7.4. requestRestoreUser](#74-requestrestoreuser)
        - [7.5. requestIssueVc](#75-requestissuevc)
        - [7.6. requestRevokeVc](#76-requestrevokevc)
    - [8. Holder Wallet](#8-holder-wallet)
        - [8.1. createHolderDIDDocument](#81-createholderdiddocument)
        - [8.2. updateHolderDIDDocument](#82-updateholderdiddocument)
        - [8.3. saveHolderDIDDocument](#83-saveholderdiddocument)
        - [8.4. getDidDocument](#84-getdiddocument)
    - [9. Key Management](#9-key-management)
        - [9.1. isAnyKeysSaved](#91-isanykeyssaved)
        - [9.2. isSavedKey](#92-issavedkey)
        - [9.3. generateKeyPair](#93-generatekeypair)
        - [9.4. getKeyInfos(by KeyType)](#94-getkeyinfosby-keytype)
        - [9.5. getKeyInfos(with Ids)](#95-getkeyinfoswith-ids)
        - [9.6. changePin](#96-changepin)
        - [9.7. deleteKeyPair](#97-deletekeypair)
        - [9.8. authenticatePin](#98-authenticatepin)
    - [10. Signature](#10-signature)
        - [10.1. sign](#101-sign)
        - [10.2. verify](#102-verify)
    - [11. Verifiable Credential Management](#11-verifiable-credential-management)
        - [11.1. isAnyCredentialsSaved](#111-isanycredentialssaved)
        - [11.2. getCredentials](#112-getcredentials)
        - [11.3. getAllCredentials](#113-getallcredentials)
        - [11.4. deleteCredentials](#114-deletecredentials)
        - [11.5. createEncVp](#115-createencvp)
    - [12. Zero-Knowledge Proof Management](#12-zero-knowledge-proof-management)
        - [12.1. isZKPCredentialSaved](#121-iszkpcredentialsaved)
        - [12.2. getZKPCredentials](#122-getzkpcredentials)
        - [12.3. getAllZKPCrentials](#123-getallzkpcrentials)
        - [12.4. searchCredentials](#124-searchcredentials)
        - [12.5. createEncZKProof](#125-createenczkproof)
        - [12.6. deleteZKPCredentials](#126-deletezkpcredentials)
    
- [Enumerators](#enumerators)
    - [1. WalletTokenPurposeEnum](#1-wallet_token_purpose)

- [Value Object](#value-object)
    - [1. WalletTokenSeed](#1-wallettokenseed)
    - [2. WalletTokenData](#2-wallettokendata)
    - [3. Provider](#3-provider)
    - [4. SignedDIDDoc](#4-signeddiddoc)
    - [5. SignedWalletInfo](#5-signedwalletinfo)
    - [6. DIDAuth](#6-didauth)


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

## 2. Device Wallet

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
func deleteWallet() throws -> Bool
```

### Parameters


### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool | Wallet 삭제 성공 여부를 반환한다. | M       |          |

### Usage

```swift
let success = try WalletAPI.deleteWallet()
```

<br>

## 3. Token

## 3.1. getSignedWalletInfo

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

## 3.2. createWalletTokenSeed

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

## 3.3. createNonceForWalletToken

### Description
`월렛 토큰 생성을 위한 nonce를 생성한다.`

### Declaration

```swift
func createNonceForWalletToken(walletTokenData: WalletTokenData) throws -> String
```

### Parameters

| Name           | Type           | Description                  | **M/O** | **Note** |
|----------------|----------------|-----------------------|---------|----------|
| walletTokenData | WalletTokenData | 월렛 토큰 데이터      | M       |[WalletTokenData](#2-wallettokendata)          |

### Returns

| Type    | Description              | **M/O** | **Note** |
|---------|-------------------|---------|----------|
| String  | wallet token 생성을 위한 nonce | M       |          |

### Usage

```swift
let walletTokenData = try WalletTokenData.init(from: responseData)
let nonce = try WalletAPI.shared.createNonceForWalletToken(walletTokenData: walletTokenData);
```

<br>

## 4. User Binding

## 4.1. bindUser

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

## 4.2. unbindUser

### Description
`사용자 비개인화를 수행한다.`

### Declaration

```swift
public unbindUser(hWalletToken: String) throws -> Bool
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

## 5. Wallet Authentication

## 5.1. isLock

### Description
`Wallet의 잠금 타입을 조회한다.`

### Declaration

```swift
func isLock() throws -> Bool
```

### Parameters


### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| Bool | Wallet 잠금 타입을 반환한다. | M       |          |

### Usage

```swift
let isLocked = try WalletAPI.shared.isLock();
```

<br>

## 5.2. registerLock

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

## 5.3. authenticateLock

### Description
`Wallet의 Unlock을 위한 인증을 수행한다.`

### Declaration

```swift
func authenticateLock(hWalletToken: String, passcode: String) throws -> Data?
```

### Parameters

| Name         | Type   | Description                        | **M/O** | **Note** |
|--------------|--------|-----------------------------|---------|----------|
| passcode     | String |Unlock PIN               | M       | registerLock 시 설정한 PIN          | 

### Returns

Void

### Usage

```swift
try WalletAPI.shared.authenticateLock(hWalletToken: hWalletToken, passcode: "123456");
```

<br>


## 5.4. changeLock

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

## 6. DID Auth

## 6.1. getSignedDidAuth


### Description
`DIDAuth 서명을 수행한다.`

### Declaration

```swift
func getSignedDIDAuth(authNonce: String, didType: DidDocumentType, passcode: String ?= nil) throws -> DIDAuth?
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| authNonce  | String | profile의 auth nonce                  | M       |          |
| didType  | DIDDocumentType | did 타입                  | M       |          |
| passcode  | String | 유저 패스코드                  | M       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| DIDAuth   | 서명된 DIDAuth 객체   | M       |[DIDAuth](#6-didauth)          |

### Usage

```swift
let signedDIDAuth = try WalletAPI.shared.getSignedDIDAuth(authNonce: authNunce, didType: DidDocumentType.holderDIDDcument, passcode: passcode);
```

<br>

## 7. API for Protocol

## 7.1. createSignedDIDDoc


### Description
`서명된 사용자 DID Document 객체를 생성한다.`

### Declaration

```swift
func createSignedDIDDoc(hWalletToken: String, passcode: String) throws -> SignedDIDDoc
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | 월렛토큰                  | M       |          |

### Returns

| Type            | Description                  | **M/O** | **Note** |
|-----------------|-----------------------|---------|----------|
| SignedDidDoc | 서명된 DID Document 객체   | M       |[SignedDIDDoc](#4-signeddiddoc)          |

### Usage

```swift
let signedDidDoc = try WalletAPI.shared.createSignedDIDDoc(hWalletToken: hWalletToken);
```

<br>

## 7.2. requestRegisterUser

### Description
`사용자 등록을 요청한다.`

### Declaration

```swift
func String requestRegisterUser(TasURL: String, id: String, txId: String, hWalletToken: String, serverToken: String, signedDIDDoc: SignedDidDoc) throws -> _RequestRegisterUser
```

### Parameters

| Name         | Type           | Description                        | **M/O** | **Note** |
|--------------|----------------|-----------------------------|---------|----------|
| TasURL | String         | TAS URL                   | M       |          |
| id | String         | message id                   | M       |          |
| txId     | String       | 거래코드               | M       |          |
| hWalletToken | String         | 월렛토큰                   | M       |          |
| serverToken     | String       | 서버토큰                | M       |          |
| signedDIDDoc|SignedDidDoc | 서명된 DID Document 객체   | M       |[SignedDIDDoc](#4-signeddiddoc)          |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| _RequestRegisterUser | 사용자 등록 프로토콜 수행 결과를 반환핟다. | M       |          |

### Usage

```swift
let _RequestRegisterUser = try await WalletAPI.shared.requestRegisterUser(tasURL: TAS_URL, id: "messageId", txId: "txId", hWalletToken: hWalletToken, serverToken: hServerToken, signedDIDDoc: signedDidDoc);
```

<br>

## 7.3. requestUpdateUser


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

## 7.4. requestRestoreUser


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

## 7.5. requestIssueVc


### Description
`VC 발급을 요청한다.`

### Declaration

```swift
func requestIssueVc(tasURL: String, id: String, hWalletToken: String, didAuth: DIDAuth, issueProfile: _RequestIssueProfile, refId: String, serverToken: String, APIGatewayURL: String) async throws -> (String, _requestIssueVc?)
```

### Parameters

| Name           | Type                 | Description            | **M/O** | **Note**                |
|----------------|----------------------|------------------------|---------|-------------------------|
| tasURL         | String               | TAS URL                | M       |                         |
| id             | String               | message ID             | M       |                         |
| hWalletToken   | String               | 월렛토큰               | M       |                         |
| didAuth        | DIDAuth              | 거래코드               | M       |                         |
| issueProfile   | _RequestIssueProfile | issue profile 정보     | M       |                         |
| refId          | String               | 참조번호               | M       |                         |
| serverToken    | String               |                        | M       | 데이터모델 참조          |
| APIGatewayURL  | String               |                        | M       | [DIDAuth](#6-didauth)   |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| String | VC ID | M       |성공 시 발급된 VC의 ID를 반환한다          |
| String | VC | M       |성공 시 발급된 VC를 반환한다          |

### Usage

```swift
(vcId, issueVC) = try await WalletAPI.shared.requestIssueVc(tasURL: TAS_URL, id: 
"messageId", hWalletToken: hWalletToken, didAuth: didAuth, issuerProfile: issuerProfile, refId: refId, serverToken: hServerToken, APIGatewayURL: API_URL);
```

<br>

## 7.6. requestRevokeVc

### Description
`VC 폐기을 요청한다.`

### Declaration

```swift
func  func requestRevokeVc(hWalletToken:String, tasURL: String, authType: VerifyAuthType, vcId: String, issuerNonce: String, txId: String, serverToken: String, passcode: String? = nil) async throws -> _RequestRevokeVc
```

### Parameters

| Name         | Type                 | Description        | **M/O** | **Note**              |
| ------------ | -------------------- | ------------------ | ------- | --------------------- |
| hWalletToken | String               | 월렛토큰           | M       |                       |
| tasURL       | String               | TAS URL            | M       |                       |
| authType     | String               | message ID         | M       |                       |
| didAuth      | DIDAuth              | 거래코드           | M       |                       |
| vcId         | _RequestIssueProfile | issue profile 정보 | M       |                       |
| issuerNonce  | String               | 참조번호           | M       |                       |
| txId         | String               |                    | M       | 데이터모델 참조       |
| serverToken  | String               |                    | M       | [DIDAuth](#6-didauth) |
| passcode     | String               |                    | M       | [DIDAuth](#6-didauth) |

### Returns

| Type    | Description                | **M/O** | **Note** |
|---------|---------------------|---------|----------|
| _RequestRevokeVc | 폐기 결과 | M       |성공 시 발급된 VC의 ID를 반환한다          |

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

## 8. Holder Wallet

## 8.1. createHolderDIDDocument

### Description
```
사용자 DID Document를 생성한다.
등록이 완료된 후에는
반드시 saveHolderDIDDocument를 호출해야 한다.
```

### Declaration

```swift
func createDIDDocument(hWalletToken: String) throws -> DIDDocument
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| hWalletToken  | String | 월렛토큰                  | O       |          |


### Returns

| Type         | Description                  | **M/O** | **Note** |
|--------------|-----------------------|---------|----------|
| DIDDocument  | DID Document   | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.createHolderDIDDocument(hWalletToken: hWalletToken);
```

<br>

## 8.2. updateHolderDIDDocument

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

## 8.3. saveHolderDIDDocument

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

## 8.4. getDidDocument


### Description
`DID Document를 조회한다.`

### Declaration

```swift
func getDIDDocument(type: Int) throws -> DIDDocument
```

### Parameters

| Name | Type | Description                               | **M/O** | **Note** |
|------|------|-------------------------------------------|---------|----------|
| type | Enum | 1 : deviceKey DID 문서, 2 : holder DID 문서 | M       |          |


### Returns

| Type         | Description   | **M/O** | **Note** |
|--------------|---------------|---------|----------|
| DIDDocument  | DID 문서       | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.getDidDocument(type: .HolderDidDocumnet)
```

<br>

## 9. Key Management

## 9.1. isAnyKeysSaved


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

## 9.2. isSavedKey


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

## 9.3. generateKeyPair


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

## 9.4. getKeyInfos(by KeyType)

### Description
`저장된 키정보를 가져온다.`

### Declaration

```swift
func getKeyInfos(keyType: VerifyAuthType) throws -> [KeyInfo]
```

### Parameters

| Name        | Type           | Description                        | **M/O** | **Note** |
|-------------|----------------|-----------------------------|---------|----------|
| keyType | VerifyAuthType      | 월렛토큰                   | M       |          |

### Returns

| Type    | Description    | **M/O** | **Note** |
| ------- | -------------- | ------- | -------- |
| KeyInfo | array[KeyInfo] | M       |          |

### Usage

```swift
let keyInfos = try holderKey.getKeyInfos(keyType: [.free, .pin])
```

<br>

## 9.5. getKeyInfos(with Ids)

### Description
`저장된 키정보를 가져온다.`

### Declaration

```swift
public func getKeyInfos(ids: [String]) throws -> [KeyInfo]
```

### Parameters

| Name        | Type           | Description                        | **M/O** | **Note** |
|-------------|----------------|-----------------------------|---------|----------|
| keyType | VerifyAuthType      | 월렛토큰                   | M       |          |

### Returns

| Type   | Description              | **M/O** | **Note** |
|--------|-------------------|---------|----------|
| ids  | array[String]  | M       |      |

### Usage

```swift
let keyInfos = try holderKey.getKeyInfos(ids: ["free", "pin"])
```

<br>

## 9.6. changePin

### Description
`서명용 PIN을 변경한다.`

### Declaration

```swift
public func changePIN(id: String, oldPIN: String, newPIN: String) throws
```

### Parameters

| Name   | Type   | Description   | **M/O** | **Note** |
| ------ | ------ | ------------- | ------- | -------- |
| id     | String | 서명용 key ID | M       |          |
| oldPIN | String | 기존 PIN      | M       |          |
| newPIN | String | 새로운 PIN    | M       |          |

### Returns


### Usage

```swift
try WalletAPI.shared.changePIN(id: "pin", oldPIN: oldPIN, newPIN: passcode)
```

<br>

## 9.7. deleteKeyPair

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

## 9.8. authenticatePin

### Description
`WalletPIN인 키의 PIN을 인증한다.`

### Declaration

```swift
// Declaration in swift
public func authenticatePin(id: String, pin: Data) throws
```

### Parameters

| Name | Type   | Description | **M/O** | **Note** |
|------|--------|-------------|---------|----------|
| id   | String | 키 이름      | M       |          |
| pin  | Data   | 키의 PIN     | M       |          |

### Returns

Void

### Usage
```swift
let pinID = "pin"
let pin = "password"
try WalletAPI.shared.authenticatePin(id: pinID, pin: pin)
```

<br>

## 10. Signature

## 10.1. sign

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

## 10.2. verify

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


## 11. Verifiable Credential Management

## 11.1. isAnyCredentialsSaved

### Description
`지갑에 VC가 있는지 확인한다.`

### Declaration

```swift
public var isAnyCredentialsSaved: Bool

```

### Returns

| Type | Description                                        | **M/O** | **Note** |
| ---- | -------------------------------------------------- | ------- | -------- |
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

## 11.2. getCredentials

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

## 11.3. getAllCredentials

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

## 11.4. deleteCredentials

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

## 11.5. createEncVp

### Description
`암호화된 VP와 accE2e를 생성한다.`

### Declaration

```swift
func createEncVp(hWalletToken: String, claimInfos: [ClaimInfo]? = nil, verifierProfile: _RequestProfile, passcode: String? = nil) throws -> (AccE2e, Data)
```

### Parameters

| Name         | Type               | Description        | **M/O** | **Note**        |
| ------------ | ------------------ | ------------------ | ------- | --------------- |
| hWalletToken | String             | 월렛토큰           | M       |                 |
| vcId         | String             | VC ID              | M       |                 |
| claimCode    | List&lt;String&gt; | 제출할 클레임 코드 | M       |                 |
| reqE2e       | ReqE2e             | E2E 암복호화 정보  | M       | 데이터모델 참조 |
| passcode     | String             | 서명용 PIN         | M       |                 |
| nonce        | String             | nonce              | M       |                 |

### Returns

| Type   | Description    | **M/O** | **Note**         |
| ------ | -------------- | ------- | ---------------- |
| AccE2e | 암호화 객체    | M       | acce2e, encVp... |
| EncVP  | 암호화 VP 객체 | M       | acce2e, encVp... |

### Usage

```swift
(accE2e, encVp) = try WalletAPI.shared.createEncVp(hWalletToken:hWalletToken, claimInfos:claimInfos, verifierProfile: verifierProfile, passcode: passcode)
```

<br>

## 12. Zero-Knowledge Proof Management
## 12.1. isZKPCredentialSaved

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

## 12.2. getZKPCredentials

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

## 12.3. getAllZKPCrentials

### Description  
`월렛에 저장된 모든 ZKP 자격증명을 조회한다.`

### Declaration

```swift
func getAllZKPCrentials(hWalletToken: String) throws -> [ZKPCredential]?
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

## 12.4. searchCredentials

### Description  
`주어진 증명 요청(proof request)을 만족하는 자격증명을 검색한다.`

### Declaration

```swift
func searchCredentials(hWalletToken: String, proofRequest: ProofRequest) throws -> AvailableReferent
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

## 12.5. createEncZKProof


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

## 12.6. deleteZKPCredentials

### Description
`지정한 ZKP 자격증명들을 월렛에서 제거한다.`

### Declaration

```swift
func deleteZKPCredentials(hWalletToken: String, ids: [String]) throws -> Bool
```

### Parameters

| Name         | Type     | Description            | **M/O** | **Note**                                |
| ------------ | -------- | ---------------------- | ------- | ---------------------------------------- |
| hWalletToken | String   | 월렛 토큰               | M       | 유효하지 않을 경우 예외 발생            |
| ids          | [String] | 삭제할 자격증명 ID 배열 | M       |                                          |

### Returns

| Type | Description                | **M/O** | **Note**                                 |
| ---- | -------------------------- | ------- | ---------------------------------------- |
| Bool | 삭제 성공 여부 (`true`/`false`) | M       | `true`: 성공<br>`false`: 실패           |

### Throws

- `WalletApiError(VERIFY_TOKEN_FAIL)` : 월렛 토큰 검증 실패 시 발생


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
