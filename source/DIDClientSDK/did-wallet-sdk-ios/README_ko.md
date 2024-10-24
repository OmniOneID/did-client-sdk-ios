# iOS DIDWalletSDK Guide
본 문서는 OpenDID Wallet SDK 사용을 위한 가이드로, 
Open DID에 필요한 WalletToken, Lock/Unlock, Key, DID Document(DID 문서), Verifiable Credential(이하 VC) 정보를 생성 및 보관, 관리하는 기능을 제공한다.


## S/W 사양
| 구분           | 내용                         |
|---------------|-----------------------------|
| OS            | iOS 15.x                    |
| Language      | swift 5.x                   | 
| IDE           | xCode 14.x|
| Build System  | Xcode 기본 빌드 시스템          |
| Compatibility | minSDK 15 or iOS 15 higher  |


## 빌드 방법
: 터미널을 열고 XCFramework를 생성하기 위해 스크립트 `build_xcframework.sh`을 실행합니다.
1. 터미널 앱을 실행하고 다음 사항을 작성합니다. 
```groovy
$ ./build_xcframework.sh
```
2. 아카이브가 완료되면, `output/` 폴더에 `DIDWalletSDK.xcframework` 파일이 생성됩니다.
<br>


## SDK 적용 방법
1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDCoreSDK.xcframework`, `DIDDataModelSDK.xcframework`, `DIDUtilitySDK.xcframework`, `DIDCommunicationSDK.xcframework`, `DIDWalletSDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
    ```groovy
    DIDCoreSDK.xcframework
    DIDDataModelSDK.xcframework
    DIDUtilitySDK.xcframework
    DIDCommunicationSDK.xcframework
    DIDWalletSDK.xcframework
    ```
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

<br>

## API 규격서
| 구분           | API 문서 Link                                                                              |
|---------------|-------------------------------------------------------------------------------------------|
| Wallet        | [Wallet SDK - Wallet API](docs/api/did-wallet-sdk-ios/Wallet_ko.md)            |
| WalletError   | [Wallet Error](docs/api/did-wallet-sdk-ios/WalletError.md)                                |

