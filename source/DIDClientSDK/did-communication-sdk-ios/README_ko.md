# iOS Communication SDK Guide
본 문서는 DID Communication SDK 사용을 위한 가이드로, 다양한 암호화 및 인코딩, 해싱 기능을 제공한다.


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
```bash
$ ./build_xcframework.sh
```
2. 아카이브가 완료되면, `output/` 폴더에 `DIDCommunicationSDK.xcframework` 파일이 생성됩니다.
<br>


## SDK 적용 방법
1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDCommunicationSDK.xcframework`파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

<br>

## API 규격서
| 구분                    | API 문서 Link                                                                    |
|------------------------|---------------------------------------------------------------------------------|
| CommnunicationClient   | [Communication SDK API](../../../docs/api/did-communication-sdk-ios/Communication_ko.md) |
| CommunicationAPIError  | [Error Code](../../../docs/api/did-communication-sdk-ios/CommunicationError.md)          |



