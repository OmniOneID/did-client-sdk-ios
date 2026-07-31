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

- Subject: Communication
- Author: JooHyun Park
- Date: 2026-07-31
- Version: v2.0.0

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v2.0.0  | 2026-07-31 | Remove doGet / doPost — use sendRequest |
| v1.0.2  | 2025-09-09 | Add new communication API |
| v1.0.1  | 2025-05-23 | Add ZKP API              |
| v1.0.0  | 2024-10-18 | Initial version          |


<div style="page-break-after: always;"></div>

# Table of Contents
- [APIs](#api-list)
  - [1. getZKPCredentialSchama](#1-getzkpcredentialschama)
  - [2. getZKPCredentialDefinition](#2-getzkpcredentialdefinition)
  - [3. sendRequest](#3-sendrequest)
  - [4. sendRequest](#4-sendrequest)  

# Removed in v2.0.0

`doGet(url:)` and `doPost(url:requestJsonData:)` were removed, along with the
`CommunicationProtocol` and `ZKPCommunicationProtocol` protocols. Use `sendRequest` instead:
`doGet(url:)` becomes `sendRequest(urlString:httpMethod: .GET)`, `doPost(url:requestJsonData:)`
becomes `sendRequest(urlString:requestJsonData:)`.

The replacement is not a drop-in one. The removed APIs returned `Data` and threw on any status
other than 200; the raw `sendRequest` overload returns `(Data, Int)` and leaves the status check to
the caller. The generic `sendRequest<T: Jsonable>` overload still throws on a non-200 status.

# Caching

Every request issued by `CommunicationClient` bypasses the URL loading system's cache, and no
response is stored in it. The SDK always requires the current value of a resource: a cached DID
Document would let signature verification succeed against rotated or revoked keys, and a cached
CA allow list would keep admitting an authority whose trust was withdrawn. This is not
configurable — callers cannot opt into cached responses.

# API List
### 1. getZKPCredentialSchama

#### Description
`Retrieves ZKPCredentialSchema object from the specified URL in an synchronous manner using the GET method.`

#### Declaration
```swift
public static func getZKPCredentialSchama(hostUrlString : String, id : String) async throws -> ZKPCredentialSchema
```


#### Parameters
| Parameter | Type   | Description                  | **M/O** | **Note** |
|-----------|--------|------------------------------|---------|----------|
| urlString | String | Server host URL              |   M     |          |
| id        | String | ZKP Credential Schema ID     |   M     |          |

#### Returns
| Type                | Description      | **M/O** | **Note** |
|---------------------|------------------|---------|----------|
| ZKPCredentialSchema | Response object  |   M     |          |


#### Usage
```swift
let credSchema = try await CommnunicationClient.getZKPCredentialSchama(hostUrlString: APIGatewayURL,
                                                                       id: credSchemaId)
```

<br>

### 2. getZKPCredentialDefinition

#### Description
`Retrieves ZKPCredentialDefinition object from the specified URL in an synchronous manner using the GET method.`

#### Declaration
```swift
public static func getZKPCredentialDefinition(hostUrlString : String, id : String) async throws -> ZKPCredentialDefinition
```


#### Parameters
| Parameter | Type   | Description                  | **M/O** | **Note** |
|-----------|--------|------------------------------|---------|----------|
| urlString | String | Server host URL              |   M     |          |
| id        | String | ZKP Credential Definition ID |   M     |          |

#### Returns
| Type                     | Description      | **M/O** | **Note** |
|--------------------------|------------------|---------|----------|
| ZKPCredentialDefinition  | Response object  |   M     |          |


#### Usage
```swift
let credDef = try await CommnunicationClient.getZKPCredentialDefinition(hostUrlString: APIGatewayURL,
                                                                        id: credDefId)
```

<br>

### 3. sendRequest

#### Description
```
Sends an asynchronous HTTP request to the specified URL and returns a decoded response.

This method supports any request conforming to the Jsonable protocol.
You can specify the HTTP method, custom headers, and an optional request body.
The response will be decoded into the expected generic type T, which must also conform to Jsonable.
```

#### Declaration
```swift
public static func sendRequest<T : Jsonable>(urlString : String,
                                             httpMethod : HTTPMethod = .POST,
                                             headerFields : StringDictionary = defaultHttpHeaderFields,
                                             requestJsonable : Jsonable? = nil) async throws -> T
```

#### Parameters
| Parameter       | Type             | Description                                | **M/O** | **Note**                               |
|-----------------|------------------|--------------------------------------------|---------|----------------------------------------|
| urlString       | String           | The URL string to send the request to      | M       |                                        |
| httpMethod      | HTTPMethod       | The HTTP method to use (default: `POST`)   | O       | Supported values: `GET`, `POST`, `DELETE` |
| headerFields    | StringDictionary | A dictionary of HTTP header fields         | O       | Defaults to `defaultHttpHeaderFields`  |
| requestJsonable | Jsonable?        | Optional request body                      | O       | Must conform to `Jsonable`             |

#### Returns
| Type | Description             | **M/O** | **Note**                   |
| ---- | ----------------------- | ------- | -------------------------- |
| T    | Decoded response object | M       | Must conform to `Jsonable` |

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
Sends an asynchronous HTTP request with the specified parameters and returns the raw response data.

This method constructs and sends an HTTP request using the provided URL, HTTP method, headers, and optional JSON body.
It returns the response as raw Data along with the HTTP status code, without attempting to decode it.
```

#### Declaration
```swift
public static func sendRequest(urlString : String,
                               httpMethod : HTTPMethod = .POST,
                               headerFields : StringDictionary = defaultHttpHeaderFields,
                               requestJsonData : Data? = nil) async throws -> (Data, Int)
```

#### Parameters
| Parameter       | Type             | Description                              | **M/O** | **Note**                               |
|-----------------|------------------|------------------------------------------|---------|----------------------------------------|
| urlString       | String           | The URL string of the API endpoint       | M       |                                        |
| httpMethod      | HTTPMethod       | The HTTP method to use (default: `POST`) | O       | Supported values: `GET`, `POST`, `DELETE` |
| headerFields    | StringDictionary | A dictionary containing HTTP header fields | O     | Defaults to `defaultHttpHeaderFields`  |
| requestJsonData | Data?            | The optional request body in JSON format | O       | Can be `nil` for methods like `GET`    |

#### Returns
| Type        | Description                            | **M/O** | **Note** |
| ----------- | -------------------------------------- | ------- | -------- |
| (Data, Int) | Raw response data and HTTP status code | M       |          |

#### Usage
let (data, statusCode) = try await CommunicationClient.sendRequest(
    urlString: "https://api.example.com/endpoint",
    httpMethod: .GET,
    headerFields: ["Authorization": "Bearer token"],
    requestJsonData: nil
)

<br>