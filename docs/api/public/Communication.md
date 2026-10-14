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
- Date: 2026-09-22
- Version: v2.0.1

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v2.0.1  | 2026-09-22 | Add sendPostUrlencoded   |
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
  - [5. sendPostUrlencoded](#5-sendposturlencoded)
  - [6. sendPostUrlencoded](#6-sendposturlencoded)
  - [7. getDIDDocument](#7-getdiddocument)
- [Constants](#constants)
  - [1. defaultTimeoutInterval](#1-defaulttimeoutinterval)
- [Enumerator](#enumerator)
  - [1. HTTPMethod](#1-httpmethod)
- [Protocol](#protocol)
  - [1. CommunicationRetrieving](#1-communicationretrieving)

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
| hostUrlString | String | Server host URL              |   M     |          |
| id        | String | ZKP Credential Schema ID     |   M     |          |

#### Returns
| Type                | Description      | **M/O** | **Note** |
|---------------------|------------------|---------|----------|
| ZKPCredentialSchema | Response object  |   M     |          |


#### Usage
```swift
let credSchema = try await CommunicationClient.getZKPCredentialSchama(hostUrlString: APIGatewayURL,
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
| hostUrlString | String | Server host URL              |   M     |          |
| id        | String | ZKP Credential Definition ID |   M     |          |

#### Returns
| Type                     | Description      | **M/O** | **Note** |
|--------------------------|------------------|---------|----------|
| ZKPCredentialDefinition  | Response object  |   M     |          |


#### Usage
```swift
let credDef = try await CommunicationClient.getZKPCredentialDefinition(hostUrlString: APIGatewayURL,
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
                                             headerFields : StringDictionary = DefaultHttpHeaderFields,
                                             requestJsonable : Jsonable? = nil) async throws -> T
```

#### Parameters
| Parameter       | Type             | Description                                | **M/O** | **Note**                               |
|-----------------|------------------|--------------------------------------------|---------|----------------------------------------|
| urlString       | String           | The URL string to send the request to      | M       |                                        |
| httpMethod      | HTTPMethod       | The HTTP method to use (default: `POST`)   | O       | Supported values: `GET`, `POST`, `DELETE` |
| headerFields    | StringDictionary | A dictionary of HTTP header fields         | O       | Defaults to `DefaultHttpHeaderFields`  |
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
                               headerFields : StringDictionary = DefaultHttpHeaderFields,
                               requestJsonData : Data? = nil) async throws -> (Data, Int)
```

#### Parameters
| Parameter       | Type             | Description                              | **M/O** | **Note**                               |
|-----------------|------------------|------------------------------------------|---------|----------------------------------------|
| urlString       | String           | The URL string of the API endpoint       | M       |                                        |
| httpMethod      | HTTPMethod       | The HTTP method to use (default: `POST`) | O       | Supported values: `GET`, `POST`, `DELETE` |
| headerFields    | StringDictionary | A dictionary containing HTTP header fields | O     | Defaults to `DefaultHttpHeaderFields`  |
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

### 5. sendPostUrlencoded

#### Description
```
Sends an asynchronous POST request with an application/x-www-form-urlencoded body and returns a decoded response.

The request object is form-encoded (each property becomes a key=value pair), the method is always POST,
and the response is decoded into the expected generic type T, which must conform to Jsonable.
Suited to the OpenID4VCI token endpoint and the OpenID4VP direct_post response, both of which take form-encoded bodies.
```

#### Declaration
```swift
public static func sendPostUrlencoded<T : Jsonable>(urlString : String,
                                                    headerFields : StringDictionary = XWWWFormHttpHeaderFields,
                                                    requestJsonable : Jsonable) async throws -> T
```

#### Parameters
| Parameter       | Type             | Description                                | **M/O** | **Note**                               |
|-----------------|------------------|--------------------------------------------|---------|----------------------------------------|
| urlString       | String           | The URL string to send the request to      | M       |                                        |
| headerFields    | StringDictionary | A dictionary of HTTP header fields         | O       | Defaults to `XWWWFormHttpHeaderFields` |
| requestJsonable | Jsonable         | Request body, form-encoded before sending  | M       | Must conform to `Jsonable`             |

#### Returns
| Type | Description             | **M/O** | **Note**                   |
| ---- | ----------------------- | ------- | -------------------------- |
| T    | Decoded response object | M       | Must conform to `Jsonable`. Throws on a non-200 status |

#### Usage
```swift
let tokenResponse: TokenResponse = try await CommunicationClient.sendPostUrlencoded(
    urlString: "https://issuer.example.com/token",
    requestJsonable: tokenRequest
)
```

<br>


### 6. sendPostUrlencoded

#### Description
```
Sends an asynchronous POST request with an application/x-www-form-urlencoded body and returns the raw response data.

The body is sent as given, the method is always POST, and the response is returned as raw Data along with
the HTTP status code, without attempting to decode it. The status check is left to the caller.
```

#### Declaration
```swift
public static func sendPostUrlencoded(urlString : String,
                                      headerFields : StringDictionary = XWWWFormHttpHeaderFields,
                                      requestJsonData : Data) async throws -> (Data, Int)
```

#### Parameters
| Parameter       | Type             | Description                                | **M/O** | **Note**                               |
|-----------------|------------------|--------------------------------------------|---------|----------------------------------------|
| urlString       | String           | The URL string of the API endpoint         | M       |                                        |
| headerFields    | StringDictionary | A dictionary containing HTTP header fields | O       | Defaults to `XWWWFormHttpHeaderFields` |
| requestJsonData | Data             | The request body, already form-encoded     | M       | e.g. the `Data` returned by `createVpToken` |

#### Returns
| Type        | Description                            | **M/O** | **Note** |
| ----------- | -------------------------------------- | ------- | -------- |
| (Data, Int) | Raw response data and HTTP status code | M       |          |

#### Usage
```swift
let (data, statusCode) = try await CommunicationClient.sendPostUrlencoded(
    urlString: authRequest.responseUri,
    requestJsonData: responseBody
)
```

<br>

### 7. getDIDDocument

#### Description
```
Retrieves the DID Document of the given DID from the API gateway using the GET method.

The request URL is built from hostUrlString by appending the path /api-gateway/api/v1/did-doc
and the query items did and, when given, versionId:
  {hostUrlString}/api-gateway/api/v1/did-doc?did={did}[&versionId={versionId}]
The response body is a DIDDocVO whose didDoc field is a multibase-encoded DID Document, which is
decoded and returned.
```

#### Declaration
```swift
public static func getDIDDocument(hostUrlString : String,
                                  did: String,
                                  versionId: String? = nil) async throws -> DIDDocument
```

#### Parameters
| Parameter     | Type    | Description                              | **M/O** | **Note**                                      |
|---------------|---------|------------------------------------------|---------|-----------------------------------------------|
| hostUrlString | String  | Server host URL                          | M       |                                               |
| did           | String  | DID whose DID Document is retrieved      | M       |                                               |
| versionId     | String? | Version of the DID Document              | O       | Defaults to `nil` — the query item is omitted |

#### Returns
| Type        | Description                  | **M/O** | **Note**                                     |
|-------------|------------------------------|---------|----------------------------------------------|
| DIDDocument | Decoded DID Document         | M       | [DIDDocument](DataModel.md#1-diddocument)    |

#### Throws
| Error                                        | Condition                                                         |
|----------------------------------------------|-------------------------------------------------------------------|
| `CommunicationAPIError.incorrectURLconnection` | `hostUrlString` cannot be parsed as a URL, or the request URL cannot be built from it |
| `CommunicationAPIError.serverFail`           | The server responds with a status other than 200                  |
| Other errors                                 | Network failure, or the response or its `didDoc` cannot be decoded |

#### Usage
```swift
let didDoc = try await CommunicationClient.getDIDDocument(hostUrlString: APIGatewayURL,
                                                          did: "did:omn:issuer")
```

<br>

# Constants

### 1. defaultTimeoutInterval

#### Description
```
Timeout interval, in seconds, applied to every request issued by CommunicationClient.

Both sendRequest and sendPostUrlencoded set it as the URLRequest timeoutInterval.
The value is fixed and cannot be changed by the caller.
```

#### Declaration
```swift
public static let defaultTimeoutInterval: TimeInterval = 30
```

#### Property
| Name                   | Type         | Description                      | **M/O** | **Note**   |
|------------------------|--------------|----------------------------------|---------|------------|
| defaultTimeoutInterval | TimeInterval | Request timeout interval (seconds) | M     | `30`       |

<br>

# Enumerator

### 1. HTTPMethod

#### Description
```
HTTP method used by sendRequest. Nested in CommunicationClient (CommunicationClient.HTTPMethod).
The raw value is set as the request's httpMethod.
```

#### Declaration
```swift
public enum HTTPMethod : String
{
    case GET
    case POST
    case DELETE
}
```

#### Property
| Name   | Raw value | Description     |
|--------|-----------|-----------------|
| GET    | "GET"     | HTTP GET. A request body cannot be sent with it |
| POST   | "POST"    | HTTP POST       |
| DELETE | "DELETE"  | HTTP DELETE     |

<br>

# Protocol

### 1. CommunicationRetrieving

#### Description
```
Protocol for retrieving ZKP credential schemas and credential definitions from a server.
CommunicationClient conforms to it.
```

#### Declaration
```swift
public protocol CommunicationRetrieving
{
    static func getZKPCredentialSchama(hostUrlString : String, id : String) async throws -> ZKPCredentialSchema
    static func getZKPCredentialDefinition(hostUrlString : String, id : String) async throws -> ZKPCredentialDefinition
}
```

#### Requirements
| Requirement                | Description                                   | **Note**                                                     |
|----------------------------|-----------------------------------------------|--------------------------------------------------------------|
| getZKPCredentialSchama     | Retrieves a ZKP Credential Schema by ID       | [1. getZKPCredentialSchama](#1-getzkpcredentialschama)       |
| getZKPCredentialDefinition | Retrieves a ZKP Credential Definition by ID   | [2. getZKPCredentialDefinition](#2-getzkpcredentialdefinition) |

`getDIDDocument` is implemented in the same `CommunicationClient` extension but is not a requirement of this protocol.

<br>
