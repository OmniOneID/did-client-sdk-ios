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
- Date: 2025-09-09
- Version: v1.0.2

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v1.0.2  | 2025-09-09 | Add new communication API |
| v1.0.1  | 2025-05-23 | Add ZKP API              |
| v1.0.0  | 2024-10-18 | Initial version          |


<div style="page-break-after: always;"></div>

# Table of Contents
- [APIs](#api-list)
  - [1. doGet](#1-doget)
  - [2. doPost](#2-dopost)
  - [3. getZKPCredentialSchama](#3-getzkpcredentialschama)
  - [4. getZKPCredentialDefinition](#4-getzkpcredentialdefinition)
  - [5. sendRequest](#5-sendrequest)
  - [6. sendRequest](#6-sendrequest)  

# API List
### 1. doGet

#### Description
`Provides HTTP GET request and response functionality.`
`This feature is deprecated and may not be provided in the future.`

#### Declaration
```swift
public static func doGet(url: URL) async throws -> Data
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
let responseData = try await CommnunicationClient.doGet(url: URL(string: URLs.TAS_URL + "/list/api/v1/vcplan/list")!)
```

### 2. doPost

#### Description
`Provides HTTP POST request and response functionality.`
`This feature is deprecated and may not be provided in the future.`

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

### 3. getZKPCredentialSchama

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

### 4. getZKPCredentialDefinition

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

### 5. sendRequest

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


### 6. sendRequest

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