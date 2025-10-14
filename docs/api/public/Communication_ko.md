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
- 일자: 2025-09-09
- 버전: v2.0.1

| 버전   | 일자       | 변경 내용        |
| ------ | ---------- | ---------------- |
| v2.0.1 | 2025-09-09 | 신규 통신 API 추가 |
| v2.0.0 | 2025-05-23 | ZKP API 추가     |
| v1.0.0 | 2024-10-18 | 초기 작성        |


<div style="page-break-after: always;"></div>

# 목차
- [APIs](#api-목록)
  - [1. doGet](#1-doget)
  - [2. doPost](#2-dopost)
  - [3. getZKPCredentialSchama](#3-getzkpcredentialschama)
  - [4. getZKPCredentialDefinition](#4-getzkpcredentialdefinition)
  - [5. sendRequest](#5-sendrequest)
  - [6. sendRequest](#6-sendrequest)


## API 목록
### 1. doGet

#### Description
`Http 요청 및 응답 기능 제공`
`본 기능은 Deprecated되어 향후 기능이 제공되지 않을 수 있습니다`

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
`본 기능은 Deprecated되어 향후 기능이 제공되지 않을 수 있습니다.`

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

### 5. sendRequest

#### Description
```
지정된 URL에 비동기 HTTP 요청을 보내고, 응답을 디코딩하여 반환합니다.

이 메서드는 Jsonable 프로토콜을 따르는 모든 요청을 지원합니다.
HTTP 메서드, 사용자 정의 헤더, 선택적 요청 본문을 지정할 수 있습니다.
응답은 Jsonable을 준수하는 제네릭 타입 T로 디코딩됩니다.
```

#### Declaration
```swift
public static func sendRequest<T : Jsonable>(urlString : String,
                                             httpMethod : HTTPMethod = .POST,
                                             headerFields : StringDictionary = defaultHttpHeaderFields,
                                             requestJsonable : Jsonable? = nil) async throws -> T
```

#### Parameters
| Parameter       | Type             | Description             | **M/O** | **Note**                          |
|-----------------|------------------|-------------------------|---------|-----------------------------------|
| urlString       | String           | 요청을 보낼 URL 문자열  | M       |                                   |
| httpMethod      | HTTPMethod       | 사용할 HTTP 메서드 (기본값: `POST`) | O | 지원 값: `GET`, `POST`, `DELETE` |
| headerFields    | StringDictionary | HTTP 헤더 필드 딕셔너리 (기본 제공) | O | 기본: `defaultHttpHeaderFields`   |
| requestJsonable | Jsonable?        | 요청 본문 (선택적)      | O       | `Jsonable`을 준수해야 함          |

#### Returns
| Type | Description | **M/O** | **Note**           |
| ---- | ----------- | ------- | ------------------ |
| T    | 디코딩된 응답 데이터 | M       | `Jsonable`을 준수해야 함 |

#### Usage
```swift
let response: SomeResponse = try await CommunicationClient.sendRequest(
    urlString: "https://api.example.com/endpoint",
    httpMethod: .POST,
    headerFields: ["Authorization": "Bearer token"],
    requestJsonable: requestBody
)
```

<br>

### 6. sendRequest

#### Description
```
지정된 파라미터를 사용하여 비동기 HTTP 요청을 보내고, 원시 응답 데이터를 반환합니다.  

이 메서드는 제공된 URL, HTTP 메서드, 헤더, 선택적 JSON 본문을 사용해 HTTP 요청을 구성하고 전송합니다.  
응답은 디코딩 없이 원시 `Data`와 HTTP 상태 코드로 반환됩니다.
```

#### Declaration
```swift
public static func sendRequest(urlString : String,
                               httpMethod : HTTPMethod = .POST,
                               headerFields : StringDictionary = defaultHttpHeaderFields,
                               requestJsonData : Data? = nil) async throws -> (Data, Int)
```

#### Parameters
| Parameter       | Type             | Description                          | **M/O** | **Note**                               |
|-----------------|------------------|--------------------------------------|---------|----------------------------------------|
| urlString       | String           | API 엔드포인트의 URL 문자열          | M       |                                        |
| httpMethod      | HTTPMethod       | 사용할 HTTP 메서드 (기본값: `POST`)  | O       | 지원 값: `GET`, `POST`, `DELETE`       |
| headerFields    | StringDictionary | HTTP 헤더 필드 딕셔너리 (기본 제공)  | O       | 기본: `defaultHttpHeaderFields`        |
| requestJsonData | Data?            | JSON 형식의 요청 본문 데이터 (선택적) | O       | `GET`과 같은 경우 `nil` 가능           |

#### Returns
| Type        | Description           | **M/O** | **Note** |
| ----------- | --------------------- | ------- | -------- |
| (Data, Int) | 원시 응답 데이터와 HTTP 상태 코드 | M       |          |

#### Usage
let (data, statusCode) = try await CommunicationClient.sendRequest(
    urlString: "https://api.example.com/endpoint",
    httpMethod: .GET,
    headerFields: ["Authorization": "Bearer token"],
    requestJsonData: nil
)

<br>