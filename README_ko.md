![Platform](https://img.shields.io/cocoapods/p/SquishButton.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift)

# iOS Client SDK

iOS Client SDK Repository에 오신 것을 환영합니다. <br> 
이 Repository는 iOS 모바일 월렛을 개발하기 위한 SDK를 제공합니다.

## 폴더 구조
```
did-client-sdk-ios
├── CHANGELOG.md
├── CLA.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── dependencies-license.md
├── LICENSE
├── MAINTAINERS.md
├── Package.resolved
├── Package.swift
├── README.md
├── README_ko.md
├── RELEASE-PROCESS.md
├── SECURITY.md
├── docs
│   └── api
│       ├── README.md
│       ├── public
│       │   ├── Communication.md
│       │   ├── CommunicationError.md
│       │   ├── Communication_ko.md
│       │   ├── DataModel.md
│       │   ├── DataModel_ko.md
│       │   ├── Utility.md
│       │   ├── UtilityError.md
│       │   ├── Utility_ko.md
│       │   ├── Wallet.md
│       │   ├── WalletError.md
│       │   ├── Wallet_ko.md
│       │   ├── WalletCoreError.md
│       │   ├── ZKP_DataModel.md
│       │   └── ZKP_DataModel_ko.md
│       └── private
│           ├── DIDManager.md
│           ├── DIDManager_ko.md
│           ├── KeyManager.md
│           ├── KeyManager_ko.md
│           ├── SecureEncryptor.md
│           ├── SecureEncryptor_ko.md
│           ├── VCManager.md
│           ├── VCManager_ko.md
│           ├── ZKPManager.md
│           └── ZKPManager_ko.md
└── source  
    ├── did-wallet-sdk-ios
    │   ├── DIDWalletSDK.xcodeproj
    │   ├── README.md
    │   ├── README_ko.md
    │   └── build_xcframework.sh
    └── release
        ├── did-wallet-sdk-ios-2.0.0
        │   └── DIDWalletSDK.xcframework
        └── did-wallet-sdk-ios-2.0.1
            └── DIDWalletSDK.xcframework
```

|  이름                    |         역할                          |
| ----------------------- | ------------------------------------ |
| source                  | SDK 소스코드 프로젝트                     |
| docs                    | 문서                                  |
| ┖ api                   | API 가이드 문서                         |
| README.md               | 프로젝트의 전체적인 개요 설명               |
| CLA.md                  | Contributor License Agreement       |
| CHANGELOG.md            | 프로젝트 버전별 변경사항                   |
| CODE_OF_CONDUCT.md      | 기여자의 행동강령                        |
| CONTRIBUTING.md         | 기여 절차 및 방법                       |
| dependencies-license.md | 프로젝트 의존성 라이브러리에 대한 라이선스     |
| MAINTAINERS.md          | 유지관리 가이드                         |
| RELEASE-PROCESS.md      | 릴리즈 절차                            |
| SECURITY.md             | 보안취약점 보고 및 보안정책                | 


## S/W 사양
| 구분              | 내용                          |
|-------------------|-----------------------------|
| OS                | iOS                         |
| Language          | Swift 5.8                   |
| IDE               | Xcode 26.0.1                |
| Compatibility     | iOS 15.0 이상                |
| Test Environment  | iPhone 15 (17.5) 시뮬레이터   |

## 라이브러리

라이브러리는 [release 폴더](source/release)에서 찾을 수 있습니다.

1. 앱 프로젝트의 프레임워크 디렉토리에 `DIDWalletSDK.xcframework` 파일을 복사합니다.
2. 앱 프로젝트 의존성에 프레임워크를 추가합니다.
3. 프레임워크를 `Embed & Sign`으로 설정합니다.

## Swift Package 적용 방법

적용방법은 [여기](source/did-wallet-sdk-ios/README_ko.md)에서 확인할 수 있습니다.

## API 참조

API 참조는 [여기](source/did-wallet-sdk-ios/README_ko.md)에서 확인할 수 있습니다.


## 수정내역

Change Log에는 버전별 변경 사항과 업데이트가 자세히 기록되어 있습니다. 다음에서 확인할 수 있습니다:
- [Change Log](./CHANGELOG.md)    

## 데모 영상
OpenDID 시스템의 실제 동작을 보여주는 데모 영상은 [Demo Repository](https://github.com/OmniOneID/did-demo-server) 에서 확인하실 수 있습니다. <br>
사용자 등록, VC 발급, VP 제출 등 주요 기능들을 영상으로 확인하실 수 있습니다.


## 기여

Contributing 및 pull request 제출 절차에 대한 자세한 내용은 [CONTRIBUTING.md](CONTRIBUTING.md)와 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) 를 참조하세요.

## 라이선스
[Apache 2.0](LICENSE)

