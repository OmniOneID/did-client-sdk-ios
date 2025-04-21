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
- Date: 2024-08-28
- Version: v1.0.0

| Version          | Date       | Changes                  |
| ---------------- | ---------- | ------------------------ |
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
    - [3.4. ETC.(019xx)](#34-etc019xx)
  - [4. VCManager](#4-vcmanager)
  - [5. StorageManager](#5-storagemanager)
    - [5.1. Save(101xx)](#51-save101xx)
    - [5.2. Update(102xx)](#52-update102xx)
    - [5.3. Remove(103xx)](#53-remove103xx)
    - [5.4. Find(104xx)](#54-find104xx)
    - [5.5. Item type(105xx)](#55-item-type105xx)
    - [5.6. ETC.(109xx)](#56-etc109xx)
  - [6. Signable](#5-signable)
    - [6.1. KeyPair(111xx)](#61-keypair111xx)
    - [6.2. Signature(112xx)](#62-signature112xx)
  - [7. SecureEnclave](#7-secureenclave)
    - [7.1. KeyPair(121xx)](#71-keypair121xx)
    - [7.2. Signature(122xx)](#72-signature122xx)
    - [7.3. Encryption(123xx)](#73-encryption123xx)

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

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT01200 | Document is already exists        | -                                 | Do not call this function when already DID document file saved |

<br>

### 3.3. Edit document(013xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT01300 | Duplicate key id exists in verification method   | -                     | Check key id to add in verification method. Do not add duplicate key id |
| MSDKWLT01301 | Not found key id in verification method          | -                     | Check key id to remove in verification method. It must remove key id that exist in verification method |
| MSDKWLT01302 | Duplicate service id exists in service           | -                     | Check service id to add in service. Do not add duplicate service id |
| MSDKWLT01303 | Not found service id in service                  | -                     | Check service id to remove in service. It must remove service id that exist in service |
| MSDKWLT01304 | Don't call 'resetChanges' if no document saved   | -                     | - |

<br>

### 3.4. ETC.(019xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT01900 | Unexpected condition occurred        | -                                 | - |

<br>

## 4. VCManager

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT02100 | No claim code in credential(VC) for presentation. Not found code(s) : {claim code}        | Can't find claim code(s) in wallet to make verifiable presentation   | Check your claim code of credential(VC) in wallet is exist to include at the verifiable presentation |

<br>

## 5. StorageManager

### 5.1. Save(101xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10100 | Fail to save wallet. error : {detail error} | -                          | Depend on detail error cases          |
| MSDKWLT10101 | Item duplicated with it in wallet    | -                                 | Use a different item id that does not duplicate one of the items in your wallet |

<br>

### 5.2. Update(102xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10200 | No item to update in wallet          | -                                 | Check that item id is exist in wallet |

<br>

### 5.3. Remove(103xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10300 | No items to remove in wallet         | -                                 | Check that item id is exist in wallet |
| MSDKWLT10301 | Fail to remove items from wallet. error : {detail error} | -             | Depend on detail error cases          |

<br>

### 5.4. Find(104xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10400 | No items saved in wallet             | -                                 | Check any item is exist in wallet     |
| MSDKWLT10401 | No items to find in wallet           | -                                 | Check that item id is exist in wallet |
| MSDKWLT10402 | Fail to read wallet file. error : {detail error} | -                     | Depend on detail error cases          |

<br>

### 5.5. Item type(105xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10500 | Malformed external wallet format. error : {detail error} | -             | Depend on detail error cases          |
| MSDKWLT10501 | Malformed wallet signature           | Wallet is corrupted.              | -                                     |
| MSDKWLT10502 | Malformed inner wallet format. error : {detail error} | -                | Depend on detail error cases          |
| MSDKWLT10503 | Malformed item object type about item of inner wallet. error : {detail error} | - | Depend on detail error cases |

<br>

### 5.6. ETC.(109xx)

| Error Code   | Error Message                        | Description                       | Action Required                       |
|--------------|--------------------------------------|-----------------------------------|---------------------------------------|
| MSDKWLT10900 | Unexpected error occurred. error : {detail error} | -                    | Depend on detail error cases          |

<br>

## 6. Signable

### 6.1. KeyPair(111xx)

| Error Code   | Error Message                        | Description                       | Action Required                   |
|--------------|--------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT11100 | Not proper public key format         | -                                 | -                                 |
| MSDKWLT11101 | Not proper private key format        | -                                 | -                                 |
| MSDKWLT11102 | Private and public keys are not pair | -                                 | -                                 |

<br>

### 6.2. Signature(112xx)

| Error Code   | Error Message                               | Description                       | Action Required                   |
|--------------|---------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT11200 | Converting failed to compact representation | -                                 | -                                 |
| MSDKWLT11201 | Signing failed : {detail error}             | -                                 | Depend on detail error cases      |
| MSDKWLT11202 | Failed to verify signature : {detail error} | -                                 | Depend on detail error cases      |

<br>

## 7. SecureEnclave

### 7.1. KeyPair(121xx)

| Error Code   | Error Message                                            | Description                                        | Action Required                   |
|--------------|----------------------------------------------------------|----------------------------------------------------|-----------------------------------|
| MSDKWLT12100 | Failed to create secure key : {detail error}             | Error occurs via Secure Enclave                    | Depend on detail error cases      |
| MSDKWLT12101 | Failed to copy public key                                | Cannot copy public key from SecKey                 | -                                 |
| MSDKWLT12102 | Failed to get public key representation : {detail error} | Cannot copy compressed public key data from SecKey | Depend on detail error cases      |
| MSDKWLT12103 | Cannot find secure key by given conditions               | -                                                  | Generate new key                  |
| MSDKWLT12104 | Failed to delete secure key                              | -                                                  | -                                 |

  <br>

### 7.2. Signature(122xx)

| Error Code   | Error Message                   | Description                       | Action Required                   |
|--------------|---------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT12200 | Signing failed : {detail error} | -                                 | Depend on detail error cases      |

  <br>

### 7.3. Encryption(123xx)

| Error Code   | Error Message                                 | Description                       | Action Required                   |
|--------------|-----------------------------------------------|-----------------------------------|-----------------------------------|
| MSDKWLT12300 | Cannot create encrypted data : {detail error} | Error occurs via Secure Enclave   | Depend on detail error cases      |
| MSDKWLT12301 | Cannot create decrypted data : {detail error} | Error occurs via Secure Enclave   | Depend on detail error cases      |

  <br>
