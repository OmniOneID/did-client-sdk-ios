# iOS DIDWalletSDK Guide
본 문서는 OpenDID Wallet SDK 사용을 위한 가이드로, 
Open DID에 필요한 WalletToken, Lock/Unlock, Key, DID Document(DID 문서), Verifiable Credential(이하 VC) 정보를 생성 및 보관, 관리하는 기능을 제공한다.


## S/W 사양
| 구분              | 내용                          |
|-------------------|-----------------------------|
| OS                | iOS                         |
| Language          | Swift 5.8                   |
| IDE               | Xcode 26.0.1                |
| Compatibility     | iOS 15.0 이상                |
| Test Environment  | iPhone 15 (17.5) 시뮬레이터   |


## 빌드 방법
: 터미널을 열고 XCFramework를 생성하기 위해 스크립트 `build_xcframework.sh`을 실행합니다.
1. 터미널 앱을 실행하고 다음 명령을 입력합니다. 
    ```bash
    $ ./build_xcframework.sh
    ```
2. 아카이브가 완료되면 `release/` 폴더에 `DIDWalletSDK.xcframework` 파일이 생성됩니다.
<br>

## SDK 적용 방법
1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDWalletSDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
    ```text
    DIDWalletSDK.xcframework
    ```
3. 프레임워크를 `Embed & Sign`으로 설정합니다.
4. 앱 프로젝트의 `Package Dependencies`에서 `+`를 눌러 다음 항목을 추가합니다.
    ```text
    https://github.com/apple/swift-collections.git
    Exact Version 1.1.4
    ```
5. **Choose Package Products** 화면에서 **OrderedCollections** 항목을 선택한 후, **Add to Target**을 앱 타겟으로 설정합니다.

<br>

## Swift Package 적용 방법
SDK는 **Swift Package Manager(SPM)**를 통한 배포를 지원합니다.  
**SPM 적용은 SDK 버전 `2.0.1` 이상에서 지원됩니다.**  
XCFramework를 수동으로 복사하지 않아도 Xcode에서 직접 패키지를 불러올 수 있습니다.

### 적용 절차
1. **Xcode → 프로젝트 → Package Dependencies**로 이동합니다.
2. 우측 하단의 **“+”** 버튼을 클릭합니다.
3. 다음 Swift Package URL을 입력합니다.
    ```text
    https://github.com/OmniOneID/did-client-sdk-ios.git
    ```
4. **Version ≥ 2.0.1**을 선택하거나, “Up to Next Major” 규칙을 선택합니다.
5. 패키지를 타겟에 추가합니다.

### 참고사항
- SPM을 사용할 경우 XCFramework를 수동으로 추가할 필요가 없습니다.
- `swift-collections`은 `Package.swift`에 정의되어 있다면 자동으로 의존성 처리됩니다.
- Swift Package Manager는 Xcode 12 이상을 권장합니다.
<br>

## 최적화
ZKP 관련 기능 사용 시 BigInt 관련 최적화 이슈가 있습니다.
- `DIDWalletSDK.xcframework` 사용 시에는 문제가 발생하지 않습니다.
- `DIDWalletSDK` 프로젝트를 직접 참조하여 사용할 경우, ZKP 관련 연산을 수행하는 모든 API에서 지연이 발생할 수 있습니다.
- 해당 문제를 해결하려면 `Build Configuration`을 `Release`로 변경해야 합니다.

<br>

## API 규격서
| 구분           | API 문서 Link                                                                              |
|---------------|-------------------------------------------------------------------------------------------|
| Wallet        | [Wallet SDK - Wallet API](../../docs/api/public/Wallet_ko.md)            |
| WalletError   | [Wallet Error](../../docs/api/public/WalletError.md)                                |

