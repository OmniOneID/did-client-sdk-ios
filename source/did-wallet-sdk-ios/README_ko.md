# iOS DIDWalletSDK Guide
본 문서는 OpenDID Wallet SDK 사용을 위한 가이드로, 
Open DID에 필요한 WalletToken, Lock/Unlock, Key, DID Document(DID 문서), Verifiable Credential(이하 VC) 정보를 생성 및 보관, 관리하는 기능을 제공한다.


## S/W 사양
| 구분              | 내용                          |
|-------------------|-----------------------------|
| OS                | iOS                         |
| Language          | Swift 5.8                   |
| IDE               | Xcode 26.0.1                |
| Compatibility     | iOS 17.0 이상                |
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

> **`2.0.2` 이하에서 올라오는 앱을 위한 안내:** 해당 버전까지는 앱의 `Package Dependencies`에
> `swift-collections`(Exact Version 1.1.4)를 추가하는 단계가 필요했습니다. 이제 이 라이브러리는
> SDK 내부 구현이 되어 그 단계가 필요 없으며, 앱이 직접 사용하지 않는다면 선언을 제거해도 됩니다.

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
- `swift-collections`은 전이 의존성으로 자동 처리됩니다. SDK 공개 API에 노출되지 않으므로 앱이 직접 선언하거나 버전을 고정할 필요가 없습니다.
- Swift Package Manager는 Xcode 12 이상을 권장합니다.
<br>

## 최적화
BigInt 비중이 큰 P-256 / ZKP 연산은 Release로 미리 빌드된 바이너리 프레임워크
(`BigIntKit`)로 제공됩니다.
- SPM으로 소스를 참조해도 Debug에서 큰 정수 연산 지연이 발생하지 않습니다 —
  `Build Configuration`을 변경할 필요가 없습니다.
- `DIDWalletSDK.xcframework`는 그대로 완전히 최적화되어 있습니다.
- 참고: SDK 타깃 자체는 앱의 빌드 구성으로 컴파일되므로, 매우 무거운 ZKP
  흐름에는 약간의 Debug 오버헤드가 남을 수 있습니다.

<br>

## API 규격서
| 구분           | API 문서 Link                                                                              |
|---------------|-------------------------------------------------------------------------------------------|
| Wallet        | [Wallet SDK - Wallet API](../../docs/api/public/Wallet_ko.md)            |
| WalletError   | [Wallet Error](../../docs/api/public/WalletError.md)                                |

