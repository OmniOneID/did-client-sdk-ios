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
- Writer: Dongjun Park
- Date: 2024-10-18
- Version: v1.0.0

| Version | Date       | History                 |
| ------- | ---------- | ------------------------|
| v1.0.0  | 2024-10-18 | 초기 작성                 |


<div style="page-break-after: always;"></div>

# 목차
- [APIs](#api-목록)
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
    - [19. requestRevoke](#19-requestrevoke)
    - [20. getAllCredentials](#20-getallcredentials)
    - [21. getCredential](#21-getcredential)
    - [22. deleteCredentials](#22-deletecredentials)
    - [23. createEncVp](#23-createencvp)
    - [24. getKeyInfos](#24-getkeyinfos)
    - [25. getKeyInfos](#25-getkeyinfos)
    - [26. isAnyKeysSaved](#26-isanykeyssaved)
    - [27. changePIN](#27-changepin)
    
- [Enumerators](#enumerators)
    - [1. WALLET_TOKEN_PURPOSE](#1-wallet_token_purpose)

- [Value Object](#value-object)
    - [1. WalletTokenSeed](#1-wallettokenseed)
    - [2. WalletTokenData](#2-wallettokendata)
    - [3. Provider](#3-provider)
    - [4. SignedDIDDoc](#4-signeddiddoc)
    - [5. SignedWalletInfo](#5-signedwalletinfo)
    - [6. DIDAuth](#6-didauth)
# API 목록
## 0. constructor

### Description
 `WalletApi 생성자`

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

## 2. createWallet

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

## 3. deleteWallet

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

## 4. createWalletTokenSeed

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

## 5. createNonceForWalletToken

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

## 6. bindUser

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

## 7. unbindUser

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

## 8. registerLock

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

## 9. authenticateLock

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

## 10. createHolderDIDDocument

### Description
`사용자 DID Document를 생성한다.`

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

## 11. createSignedDIDDoc

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

## 12. getDIDDocument

### Description
`DID Document를 조회한다.`

### Declaration

```swift
func getDIDDocument(type: Int) throws -> DIDDocument
```

### Parameters

| Name          | Type   | Description                       | **M/O** | **Note** |
|---------------|--------|----------------------------|---------|----------|
| type  | Int | 1 : deviceKey DID Document, 2: holder DID document                  | M       |          |

### Returns

| Type         | Description                  | **M/O** | **Note** |
|--------------|-----------------------|---------|----------|
| DIDDocument  | DID Document       | M       |          |

### Usage

```swift
let didDoc = try WalletAPI.shared.getDIDDocument(hWalletToken: hWalletToken, type: 1);
```

<br>

## 13. generateKeyPair

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

## 14. isLock

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

## 15. getSignedWalletInfo

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

## 16. requestRegisterUser

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

## 17. getSignedDIDAuth

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

## 18. requestIssueVc

### Description
`VC 발급을 요청한다.`

### Declaration

```swift
func requestIssueVc(tasURL: String, id: String, hWalletToken: String, didAuth: DIDAuth, issueProfile: _RequestIssueProfile, refId: String, serverToken: String, APIGatewayURL: String) async throws -> (String, _requestIssueVc?)
```

### Parameters

| Name        | Type           | Description                        | **M/O** | **Note** |
|-------------|----------------|-----------------------------|---------|----------|
| tasURL | String         | TAS URL                   | M       |          |
| id | String         | message ID                   | M       |          |
| hWalletToken | String         | 월렛토큰                   | M       |          |
| didAuth     | DIDAuth       | 거래코드               | M       |          |
| issueProfile     | _RequestIssueProfile       | issue profile 정보                | M       |          |
| refId     | String       | 참조번호                | M       |          |
| serverToken |String |    | M       |데이터모델 참조          |
| APIGatewayURL|String |    | M       |[DIDAuth](#6-didauth)         |

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

## 19. requestRevokeVc

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

## 20. getAllCredentials

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

## 21. getCredential

### Description
`특정 VC를 조회한다.`

### Declaration

```swift
func getCredential(hWalletToken: String, ids: [String]) throws -> [VerifiableCredential]
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
let vcList = try WalletAPI.shared.getCredential(hWalletToken: hWalletToken, ids: [vc.id]]);
```

<br>

## 22. deleteCredentials

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
| ids   | [String]]   | 삭제 대상 VC               | M       |          |

### Returns
Bool

### Usage

```swift
let result = try WalletAPI.shared.deleteCredentials(hWalletToken: hWalletToken, ids:[vc.id]);
```

<br>

## 23. createEncVp

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

## 24. getKeyInfos

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

## 25. getKeyInfos

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

## 26. isAnyKeysSaved

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

## 27. changePIN

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


# Enumerators
## 1. WALLET_TOKEN_PURPOSE

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
