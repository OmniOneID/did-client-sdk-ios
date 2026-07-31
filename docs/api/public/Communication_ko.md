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
- 일자: 2026-07-31
- 버전: v2.0.0

| 버전   | 일자       | 변경 내용        |
| ------ | ---------- | ---------------- |
| v2.0.0 | 2026-07-31 | doGet / doPost 제거 — sendRequest 사용 |
| v1.0.2 | 2025-09-09 | 신규 통신 API 추가 |
| v1.0.1 | 2025-05-23 | ZKP API 추가     |
| v1.0.0 | 2024-10-18 | 초기 작성        |


<div style="page-break-after: always;"></div>

# 목차
- [APIs](#api-목록)
  - [1. getZKPCredentialSchama](#1-getzkpcredentialschama)
  - [2. getZKPCredentialDefinition](#2-getzkpcredentialdefinition)
  - [3. sendRequest](#3-sendrequest)
  - [4. sendRequest](#4-sendrequest)


## v2.0.0 에서 제거된 API

`doGet(url:)` 과 `doPost(url:requestJsonData:)` 가 제거되었으며, `CommunicationProtocol` 과
`ZKPCommunicationProtocol` 프로토콜도 함께 제거되었습니다. 대신 `sendRequest` 를 사용합니다.
`doGet(url:)` 은 `sendRequest(urlString:httpMethod: .GET)` 으로, `doPost(url:requestJsonData:)` 는
`sendRequest(urlString:requestJsonData:)` 로 대체됩니다.

단순 치환은 아닙니다. 제거된 API 는 `Data` 를 반환하고 상태 코드가 200 이 아니면 예외를 던졌지만,
raw `sendRequest` 오버로드는 `(Data, Int)` 를 반환하며 상태 코드 판정을 호출부에 맡깁니다.
제네릭 `sendRequest<T: Jsonable>` 오버로드는 기존과 같이 200 이 아닐 때 예외를 던집니다.


## 캐시

`CommunicationClient`가 보내는 모든 요청은 URL 로딩 시스템의 캐시를 우회하며, 응답 또한 캐시에
저장되지 않습니다. SDK는 항상 리소스의 최신 값을 요구합니다. 캐시된 DID Document는 회전 또는
폐기된 키로 서명 검증이 통과되게 하고, 캐시된 CA 목록은 신뢰가 철회된 기관을 계속 허용하게 됩니다.
이 동작은 설정할 수 없으며, 호출부가 캐시된 응답을 사용하도록 선택할 수 없습니다.


## API 목록
### 1. getZKPCredentialSchama

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

### 2. getZKPCredentialDefinition

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

### 3. sendRequest

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

### 4. sendRequest

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