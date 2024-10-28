![Platform](https://img.shields.io/cocoapods/p/SquishButton.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift)

# iOS Client SDK

iOS Client SDK Repository에 오신 것을 환영합니다. <br> 
이 Repository는 iOS 모바일 월렛을 개발하기 위한 SDK를 제공합니다.

## 폴더 구조
```
did-client-sdk-ios
├── CLA.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── MAINTAINERS.md
├── README.md
├── README_ko.md
├── RELEASE-PROCESS.md
├── docs
│   └── api
│       ├── did-communication-sdk-ios
│       │   ├── Communication.md
│       │   ├── CommunicationError.md
│       │   └── Communication_ko.md
│       ├── did-core-sdk-ios
│       │   ├── DIDManager.md
│       │   ├── DIDManager_ko.md
│       │   ├── KeyManager.md
│       │   ├── KeyManager_ko.md
│       │   ├── SecureEncryptor.md
│       │   ├── SecureEncryptor_ko.md
│       │   ├── VCManager.md
│       │   ├── VCManager_ko.md
│       │   └── WalletCoreError.md
│       ├── did-datamodel-sdk-ios
│       │   └── DataModel.md
│       ├── did-utility-sdk-ios
│       │   ├── Utility.md
│       │   ├── UtilityError.md
│       │   └── Utility_ko.md
│       └── did-wallet-sdk-ios
│           ├── Wallet.md
│           ├── WalletError.md
│           └── Wallet_ko.md
└── source
    └── DIDClientSDK
        ├── did-communication-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDCommunicationSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README_ko.md
        │   ├── README.md
        │   └── build_xcframework.sh
        ├── did-core-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDCoreSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README_ko.md
        │   ├── README.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        ├── did-datamodel-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDDataModelSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README_ko.md
        │   ├── README.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        ├── did-utility-sdk-ios
        │   ├── CHANGELOG.md
        │   ├── DIDUtilitySDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README_ko.md
        │   ├── README.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        ├── did-wallet-sdk-ios
        │   ├── CHANGELOG.mdt
        │   ├── DIDWalletSDK.xcodeproj
        │   ├── LICENSE-dependencies.md
        │   ├── README_ko.md
        │   ├── README.md
        │   ├── SECURITY.md
        │   └── build_xcframework.sh
        └── release
            ├── did-communication-sdk-ios-1.0.0
            │   └── DIDCommunicationSDK.xcframework
            ├── did-core-sdk-ios-1.0.0
            │   └── DIDCoreSDK.xcframework
            ├── did-datamodel-sdk-ios-1.0.0
            │   └── DIDDataModelSDK.xcframework
            ├── did-utility-sdk-ios-1.0.0
            │   └── DIDUtilitySDK.xcframework
            └── did-wallet-sdk-ios-1.0.0
                └── DIDWalletSDK.xcframework
```

|  이름                    |         역할                          |
| ----------------------- | ------------------------------------ |
| source                  | SDK 소스코드 프로젝트                     |
| docs                    | 문서                                  |
| ┖ api                   | API 가이드 문서                         |
| ┖ design                | 설계 문서                              |
| sample                  | 샘플 및 데이터                          |
| README.md               | 프로젝트의 전체적인 개요 설명               |
| CLA.md                  | Contributor License Agreement       |
| CHANGELOG.md            | 프로젝트 버전별 변경사항                   |
| CODE_OF_CONDUCT.md      | 기여자의 행동강령                        |
| CONTRIBUTING.md         | 기여 절차 및 방법                       |
| LICENSE-dependencies.md | 프로젝트 의존성 라이브러리에 대한 라이선스     |
| MAINTAINERS.md          | 유지관리 가이드                         |
| RELEASE-PROCESS.md      | 릴리즈 절차                            |
| SECURITY.md             | 보안취약점 보고 및 보안정책                | 

## 라이브러리

라이브러리는 [release 폴더](source/DIDClientSDK/release)에서 찾을 수 있습니다.

### Core SDK

1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDCoreSDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

### DataModel SDK

1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDDataModelSDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

### Utility SDK

1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDUtilitySDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

### Communication SDK

1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDCommunicationSDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

### Wallet SDK

1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDWalletSDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embeded & Sign`으로 설정합니다.

## API 참조

API 참조는 아래에서 확인할 수 있습니다.
<br>
- [Core SDK](source/DIDClientSDK/did-core-sdk-ios/README_ko.md)  
- [DataModel SDK](source/DIDClientSDK/did-datamodel-sdk-ios/README_ko.md)  
- [Utility SDK](source/DIDClientSDK/did-utility-sdk-ios/README_ko.md) 
- [Communication SDK](source/DIDClientSDK/did-communication-sdk-ios/README_ko.md)  
- [Wallet SDK](source/DIDClientSDK/did-wallet-sdk-ios/README_ko.md) 

## 수정내역

수정내역은 아래에서 확인할 수 있습니다. 
<br>
- [Core SDK](source/DIDClientSDK/did-core-sdk-ios/CHANGELOG.md)  
- [DataModel SDK](source/DIDClientSDK/did-datamodel-sdk-ios/CHANGELOG.md)
- [Utility SDK](source/DIDClientSDK/did-utility-sdk-ios/CHANGELOG.md)  
- [Communication SDK](source/DIDClientSDK/did-communication-sdk-ios/CHANGELOG.md)  
- [Wallet SDK](source/DIDClientSDK/did-wallet-sdk-ios/CHANGELOG.md)  

## 기여

Contributing 및 pull request 제출 절차에 대한 자세한 내용은 [CONTRIBUTING.md](CONTRIBUTING.md)와 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) 를 참조하세요.

## 라이선스
[Apache 2.0](LICENSE)

