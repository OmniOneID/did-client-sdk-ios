# iOS Utility SDK Guide
본 문서는 Crypto Utility SDK 사용을 위한 가이드로, 다양한 암호화 및 인코딩, 해싱 기능을 제공한다.


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
2. 아카이브가 완료되면, `output/` 폴더에 `DIDUtilitySDK.xcframework` 파일이 생성됩니다.
<br>


## SDK 적용 방법
1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDUtilitySDK.xcframework`파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

<br>

## API 규격서
| 구분 | API 문서 Link |
|------|----------------------------|
| CryptoUtils   | [Utility SDK API](../../../docs/api/did-utility-sdk-ios/Utility_ko.md) |
| MultibaseUtils| 〃 |
| DigestUtils   | 〃 |
| ErrorCode      | [Error Code](../../../docs/api/did-utility-sdk-ios/UtilityError.md)   |

### CryptoUtils
CryptoUtils는 데이터의 AES 암호화 및 복호화, PBKDF, ECDH를 위한 Shared Secret 생성 기능을 제공한다. <br> 주요 기능은 다음과 같다.
- AES 알고리즘을 사용한 데이터 암호화 및 복호화
- PBKDF (Password-Based Key Derivation Function)를 사용한 키 생성
- ECDH (Elliptic-curve Diffie-Hellman)를 위한 Shared Secret 생성

### MultibaseUtils
MultibaseUtils는 base16, base58, base64, base64url 인코딩 및 디코딩을 제공한다. <br>주요 기능은 다음과 같다.
- 다양한 인코딩 형식을 지원하여 데이터의 효율적인 전환 제공
- Base 인코딩의 확장성과 유연성을 통한 다양한 데이터 처리

### DigestUtils
DigestUtils는 SHA-256, SHA-384, SHA-512 등의 해시 함수를 제공한다. <br>주요 기능은 다음과 같다.
- 다양한 해시 알고리즘을 사용하여 데이터의 무결성 검증 및 암호화
- 안전한 데이터 전송 및 저장을 위한 해시 기반 보안 기능 제공
