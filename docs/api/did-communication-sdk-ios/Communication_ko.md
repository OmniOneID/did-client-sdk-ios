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

iOS Communication SDK API
==

- 주제: Communication SDK
- 작성: Dongjun Park
- 일자: 2024-10-18
- 버전: v1.0.0

| 버전   | 일자       | 변경 내용                 |
| ------ | ---------- | -------------------------|
| v1.0.0 | 2024-10-18 | 초기 작성                 |


<div style="page-break-after: always;"></div>

# 목차
- [CommunicationClient](#communicationClient)
- [APIs](#api-목록)
  - [1. doGet](#1-doget)
  - [2. doPost](#2-dopost)


# CommunicationClient
```swift
public class CommnunicationClient: CommnunicationProtocol {
    func doGet(url: URL) async throws -> Data {...}
    func doPost(url: URL, requestJsonData: Data) async throws -> Data {...}
}
```

## API 목록
### 1. doGet

#### Description
`Http 요청 및 응답 기능 제공`

#### Declaration
```swift
func doGet(url: URL) async throws -> Data
```


#### Parameters
| Parameter | Type   | Description                | **M/O** | **Note** |
|-----------|--------|----------------------------|---------|----------|
| urlString | Url    | 서버 URL                    |   M     |          |

#### Returns
| Type | Description                |**M/O**  | **Note**    |
|------|----------------------------|---------|-------------|
| Data | 응답 데이터                   |    M    |             |


#### Usage
```swift
let responseData = try await CommnunicationClient().doGet(url: URL(string: URLs.TAS_URL + "/list/api/v1/vcplan/list")!)
```

<br>

### 2. doPost

#### Description
`Provides HTTP POST request and response functionality.`

#### Declaration
```swift
func doPost(url: URL, requestJsonData: Data) async throws -> Data
```

#### Parameters
| Parameter      | Type   | Description                | **M/O** | **Note** |
|----------------|--------|----------------------------|---------|----------|
| urlString      | URL    | 서버 URL                    |    M    |          |
| requestJsonData| Data   | 요청 데이터                   |    M    |          |

#### Returns
| Type | Description                |**M/O**  |    **Note** |
|------|----------------------------|---------|-------------|
| Data | 응답 데이터                   |      M  |             |

#### Usage
```swift
let reqAttDidDoc = RequestAttestedDIDDoc(id: id, attestedDIDDoc: attDIDDoc)
let responseData = try await CommnunicationClient().doPost(url: URL(string:tasURL + "/tas/api/v1/request-register-wallet")!, requestJsonData: try reqAttDidDoc.toJsonData())
```
<br>
