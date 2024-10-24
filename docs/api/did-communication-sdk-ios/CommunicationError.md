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

Android CommunicationError
==

- Topic: CommunicationError
- Author: Dongjun Park
- Date: 2024-09-04
- Version: v1.0.0

| Version          | Date       | Changes                  |
| ---------------- | ---------- | ------------------------ |
| v1.0.0  | 2024-09-04 | Initial version          |

<div style="page-break-after: always;"></div>

# Table of Contents

- [CommunicationError](#Communicationerror)
  - [Error Code](#error-code)


## CommunicationError

### Description
Error struct for Communication operations. It has code and message pair.
Code starts with MSDKCMM.

### Declaration
```swift
public struct CommunicationSDKError: Error {
    public var code: String
    public var message: String
}
```

### Property

| Name    | Type   | Description             | **M/O** | **Note** |
|---------|--------|-------------------------|---------|----------|
| code    | String | Error code              | M       |          |
| message | String | Error description       | M       |          |

<br>

# Error Code

| Error Code      | Error Message            | Description      | Action Required  |
|-----------------|--------------------------|------------------|------------------|
| MSDKCMM00000    | unknown                   |                  |                  |
| MSDKCMM00001    | incorrect url connection |                  |                  |
| MSDKCMM00002    | invaild parameter        |                  |                  |
| MSDKCMM00003    | server error/ message    |                  |                  |


<br>
