# iOS Data Model SDK Guide
본 문서는 DataModel SDK 사용을 위한 가이드로,
앱과 월렛 SDK에서 사용된 데이터 모델을 정의합니다.


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
2. 아카이브가 완료되면, `output/` 폴더에 `DIDDataModelSDK.xcframework` 파일이 생성됩니다.
<br>


## SDK 적용 방법
1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDDataModelSDK.xcframework`파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

<br>

## 구조체 규격서
| 구분           | 구조체 문서 Link                                                |
|---------------|--------------------------------------------------------------|
| DataModel     | [DataModel SDK](../../../docs/api/did-datamodel-sdk-ios/DataModel.md) |

<br>

### DIDDocument
- 탈중앙화된 식별자를 위한 문서
### VerifiableCredential
- 탈중앙화된 전자 증명서(이하 VC) 
### VerifiablePresentation
- 주체 서명값으로 서명된 VC의 목록(이하 VP)



## License
Copyright 2024 Raonsecure

