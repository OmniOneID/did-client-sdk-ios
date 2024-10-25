# iOS Core SDK Guide
본 문서는 OpenDID Core SDK 사용을 위한 가이드로, 
Open DID에 필요한 Key, DID Document(DID 문서), Verifiable Credential(이하 VC) 정보를 생성 및 보관, 관리하는 기능을 제공한다.


## S/W 사양
| 구분           | 내용                       |
|---------------|---------------------------|
| OS            | iOS                       |
| Language      | Swift 5.8                 |
| IDE           | Xcode 15.4                |
| Compatibility | iOS 15.0 and higher       |

<br>

## 빌드 방법
: 터미널을 열고 XCFramework를 생성하기 위해 스크립트 `build_xcframework.sh`을 실행합니다.
1. 터미널 앱을 실행하고 다음 사항을 작성합니다. 
```groovy
$ ./build_xcframework.sh
```
2. 아카이브가 완료되면, `output/` 폴더에 `DIDCoreSDK.xcframework` 파일이 생성됩니다.
<br>


## SDK 적용 방법
1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDCoreSDK.xcframework`, `DIDDataModelSDK.xcframework`, `DIDUtilitySDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
    ```groovy
    DIDCoreSDK.xcframework
    DIDDataModelSDK.xcframework
    DIDUtilitySDK.xcframework
    ```
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.
 
<br>

## API 규격서
| 구분             | API 문서 Link                                                                              |
|-----------------|-------------------------------------------------------------------------------------------|
| KeyManager      | [Wallet Core SDK - KeyManager API](https://github.com/OmniOneID/did-client-sdk-ios/blob/main/docs/api/did-core-sdk-ios/KeyManager_ko.md)            |
| DIDManager      | [Wallet Core SDK - DIDManager API](https://github.com/OmniOneID/did-client-sdk-ios/blob/main/docs/api/did-core-sdk-ios/DIDManager_ko.md)            |
| VCManager       | [Wallet Core SDK - VCManager API](https://github.com/OmniOneID/did-client-sdk-ios/blob/main/docs/api/did-core-sdk-ios/VCManager_ko.md)              |
| SecureEncryptor | [Wallet Core SDK - SecureEncryptor API](https://github.com/OmniOneID/did-client-sdk-ios/blob/main/docs/api/did-core-sdk-ios/SecureEncryptor_ko.md)  |
| ErrorCode       | [Error Code](https://github.com/OmniOneID/did-client-sdk-ios/blob/main/docs/api/did-core-sdk-ios/WalletCoreError.md)                                |

### KeyManager
KeyManager는 서명용 키쌍을 생성하고 관리하며, 이를 안전하게 저장하는 기능을 제공한다.<br>주요 기능은 다음과 같다.

* <b>키 생성</b>: 새로운 키쌍을 생성한다.
* <b>키 저장</b>: 생성된 키를 안전하게 저장한다.
* <b>키 조회</b>: 저장된 키를 조회한다.
* <b>키 삭제</b>: 저장된 키를 삭제한다.

### DIDManager
DIDManager는 DID Document를 생성하고 관리하는 기능을 제공한다.<br>
주요 기능은 다음과 같다.

* <b>DID 생성</b>: 새로운 DID를 생성한다.
* <b>DID Document 관리</b>: DID Document를 생성하고, 업데이트하며, 삭제한다.
* <b>DID Document 조회</b>: DID Document에 대한 정보를 조회한다.
  
### VCManager
VCManager는 Verifiable Credential(VC)을 관리하고 저장하는 기능을 제공한다.<br>
주요 기능은 다음과 같다.

* <b>VC 저장</b>: 생성된 VC를 안전하게 저장한다.
* <b>VC 조회</b>: 저장된 VC를 조회한다.
* <b>VC 삭제</b>: 저장된 VC를 삭제한다.

### SecureEncryptor
SecureEncryptor는 Keystore를 이용하여 데이터를 암호화하고 복호화하는 기능을 제공한다.<br>주요 기능은 다음과 같다.

* <b>데이터 암호화</b>: 데이터를 안전하게 암호화한다.
* <b>데이터 복호화</b>: 암호화된 데이터를 복호화한다.
