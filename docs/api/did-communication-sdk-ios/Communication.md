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

Android Communication SDK API
==

- Subject: Communication SDK
- Author: Dongjun Park
- Date: 2024-10-18
- Version: v1.0.0

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v1.0.0  | 2024-10-18 | Initial version          |


<div style="page-break-after: always;"></div>

# Table of Contents
- [CommunicationClient](#communicationClient)
- [APIs](#api-list)
  - [1. doGet](#1-doget)
  - [2. doPost](#2-dopost)


# CommunicationClient
```swift
public class CommnunicationClient: CommnunicationProtocol {
    func doGet(url: URL) async throws -> Data {...}
    func doPost(url: URL, requestJsonData: Data) async throws -> Data {...}
}
```

# API List
### 1. doGet

#### Description
`Provides HTTP GET request and response functionality.`

#### Declaration
```swift
func doGet(url: URL) async throws -> Data
```

#### Parameters
| Parameter | Type   | Description                | **M/O** | **Note** |
|-----------|--------|----------------------------|---------|----------|
| urlString | Url    | Server URL                 |   M     |          |

#### Returns
| Type | Description                |**M/O**  | **Note**    |
|------|----------------------------|---------|-------------|
| Data | Response data              |    M    |             |

#### Usage
```swift
let responseData = try await CommnunicationClient().doGet(url: URL(string: URLs.TAS_URL + "/list/api/v1/vcplan/list")!)
```

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
| urlString      | URL    | Server URL                 |    M    |          |
| requestJsonData| Data   | Request data               |    M    |          |

#### Returns
| Type | Description                |**M/O**  |    **Note** |
|------|----------------------------|---------|-------------|
| Data | Response data              |      M  |             |

#### Usage
```swift
let reqAttDidDoc = RequestAttestedDIDDoc(id: id, attestedDIDDoc: attDIDDoc)
let responseData = try await CommnunicationClient().doPost(url: URL(string:tasURL + "/tas/api/v1/request-register-wallet")!, requestJsonData: try reqAttDidDoc.toJsonData())
```
<br>
