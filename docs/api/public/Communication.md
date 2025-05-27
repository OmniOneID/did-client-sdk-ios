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
- Date: 2025-05-23
- Version: v1.0.0

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| v2.0.0  | 2025-05-23 | Adding ZKP API           |
| v1.0.0  | 2024-10-18 | Initial version          |


<div style="page-break-after: always;"></div>

# Table of Contents
- [CommunicationClient](#communicationClient)
- [APIs](#api-list)
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

# API List
### 1. doGet

#### Description
`Provides HTTP GET request and response functionality.`

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