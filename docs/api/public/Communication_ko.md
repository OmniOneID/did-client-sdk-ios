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

iOS Communication API
==

- 주제: Communication
- 작성: 박주현
- 일자: 2025-05-23
- 버전: v1.0.0

| 버전   | 일자       | 변경 내용                 |
| ------ | ---------- | -------------------------|
| v2.0.0 | 2025-05-23 | ZKP API 추가              |
| v1.0.0 | 2024-10-18 | 초기 작성                 |


<div style="page-break-after: always;"></div>

# 목차
- [CommunicationClient](#communicationClient)
- [APIs](#api-목록)
  - [1. doGet](#1-doget)
  - [2. doPost](#2-dopost)
  - [3. getZKPCredentialSchama](#3-getzkpcredentialschama)
  - [4. getZKPCredentialDefinition](#4-getzkpcredentialdefinition)


# CommunicationClient
```swift
public struct CommnunicationClient: CommnunicationProtocol {
    public static func doGet(url: URL) async throws -> Data {...}
    public static func doPost(url: URL, requestJsonData: Data) async throws -> Data {...}
}
extension CommnunicationClient : ZKPCommunicationProtocol
{
    public static func getZKPCredentialSchama(hostUrlString : String, id : String) async throws -> ZKPCredentialSchema
    public static func getZKPCredentialDefinition(hostUrlString : String, id : String) async throws -> ZKPCredentialDefinition
}
```

## API 목록
### 1. doGet

#### Description
`Http 요청 및 응답 기능 제공`

#### Declaration
```swift
public static func doGet(url: URL) async throws -> Data
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
let responseData = try await CommnunicationClient.doGet(url: URL(string: URLs.TAS_URL + "/list/api/v1/vcplan/list")!)
```

<br>

### 2. doPost

#### Description
`HTTP POST 요청 및 응답 기능을 제공합니다.`

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

### 3. getZKPCredentialSchama

#### Description
`지정된 URL에서 GET 메서드를 사용하여 동기 방식으로 ZKPCredentialSchema 객체를 가져옵니다.`

#### Declaration
```swift
public static func getZKPCredentialSchama(hostUrlString : String, id : String) async throws -> ZKPCredentialSchema
```


#### Parameters
| Parameter | Type   | Description                  | **M/O** | **Note** |
|-----------|--------|------------------------------|---------|----------|
| urlString | String | 서버 호스트 URL                 |   M     |          |
| id        | String | ZKP Credential Schema ID     |   M     |          |

#### Returns
| Type               | Description   | **M/O** | **Note** |
|--------------------|---------------|---------|----------|
| ZKPCredentialSchema | 응답 데이터     |   M     |          |


#### Usage
```swift
let credSchema = try await CommnunicationClient.getZKPCredentialSchama(hostUrlString: APIGatewayURL,
                                                                       id: credSchemaId)
```

<br>

### 4. getZKPCredentialDefinition

#### Description
`지정된 URL에서 GET 메서드를 사용하여 동기 방식으로 ZKPCredentialDefinition 객체를 가져옵니다.`

#### Declaration
```swift
public static func getZKPCredentialDefinition(hostUrlString : String, id : String) async throws -> ZKPCredentialDefinition
```


#### Parameters
| Parameter | Type   | Description                  | **M/O** | **Note** |
|-----------|--------|------------------------------|---------|----------|
| urlString | String | 서버 호스트 URL                 |   M     |          |
| id        | String | ZKP Credential Definition ID |   M     |          |

#### Returns
| Type                    | Description   | **M/O** | **Note** |
|-------------------------|---------------|---------|----------|
| ZKPCredentialDefinition | 응답 데이터      |   M     |          |


#### Usage
```swift
let credDef = try await CommnunicationClient.getZKPCredentialDefinition(hostUrlString: APIGatewayURL,
                                                                        id: credDefId)
```

<br>