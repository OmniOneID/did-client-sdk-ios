# Changelog

## v3.0.0 (Unreleased)

### Breaking Changes
- `Jsonable` now inherits `Sendable`, so a type that conforms to it must itself be `Sendable`.
  A consumer that conforms its own type to `Jsonable` has to make that type a value type whose
  stored properties are all `Sendable` — and, if it is declared inside an isolated context such as a
  `@MainActor` type, mark it `nonisolated`. Types that already are plain value types keep compiling
  unchanged.

  Why the SDK declares it: a public type's `Sendable` status is never inferred outside its own
  module, so consumers building under strict concurrency (or in the Swift 6 language mode) cannot
  treat the SDK's models as safe to pass across concurrency domains unless the SDK says so. The
  SDK itself stays on `swift-tools-version: 5.9` and the Swift 5 language mode; which mode to build
  in remains the consumer's choice.

- The minimum supported platform was raised from **iOS 15.0 to iOS 17.0** (`Package.swift` and both
  Xcode build configurations, `IPHONEOS_DEPLOYMENT_TARGET`). An app whose deployment target is
  iOS 15 or 16 can no longer resolve the Swift package or link the XCFramework and must raise its
  own deployment target to adopt v3.0.0.

- `walletId` is now stored in a dedicated `UserDefaults` suite (`"properties"`) instead of
  `UserDefaults.standard`. Suite-scoped defaults are a separate persistence domain and do **not**
  fall back to the standard domain, so a `walletId` written by v2.0.2 or earlier is not visible to
  v3.0.0 and no migration is performed.

  **Impact when upgrading an app from v2.0.2 (or earlier) to v3.0.0 with a wallet already created
  on the device:** `Properties.getWalletId()` returns `nil`, and the callers that force-unwrap it
  crash — `KeyChainWrapper.matching(passcode:finalEncCek:)` on the first unlock attempt,
  `WalletService.createSignedDIDDoc` and `getSignedWalletInfo`. `walletId` is also the salt used to
  derive the key that protects the stored CEK, so simply tolerating `nil` would still leave the
  existing CEK undecryptable.

  Affected upgrade path: **v2.0.2 → v3.0.0**. Fresh v3.0.0 installs are unaffected. An app that must
  preserve existing wallets has to migrate the value out of `UserDefaults.standard` before the first
  call into the SDK, or re-create the wallet.

### Removed
- `CommunicationClient.doGet(url:)` and `CommunicationClient.doPost(url:requestJsonData:)`, together
  with the `CommunicationProtocol` and `ZKPCommunicationProtocol` protocols. Both methods were
  already marked deprecated in v2.0.2.

  Replace `doGet(url:)` with `sendRequest(urlString:httpMethod: .GET)` and
  `doPost(url:requestJsonData:)` with `sendRequest(urlString:requestJsonData:)`. Error handling
  differs: the removed methods returned `Data` and threw on any status other than 200, while the raw
  `sendRequest` overload returns `(Data, Int)` and leaves the status check to the caller — the
  generic `sendRequest<T: Jsonable>` overload keeps throwing on a non-200 status.

  The ZKP retrieval methods are unchanged; the protocol declaring them is now
  `CommunicationRetrieving`.

- `WalletLogger` is an `enum` with static methods instead of a class with a `shared` singleton.
  Replace `WalletLogger.shared.setEnable(true)` with `WalletLogger.setEnable(true)`, and the same for
  `setLogLevel(_:)` and the log methods.

### Fixed
- SD-JWT disclosures are presented with the issuer's original bytes instead of being re-serialized,
  and a disclosure's digest is now taken over the base64url-encoded disclosure as SD-JWT specifies.
  Presentations of credentials whose disclosures were not byte-identical to this SDK's encoding were
  rejected by the verifier, and nested claims did not resolve.
- A DCQL claim path (`address.street_address`) reported by credential matching now resolves to the
  disclosures that reveal it, including the parent object's. Presenting a nested or plaintext claim
  previously failed after the holder had already consented.
- Numeric claim values of `0` and `1` are no longer read as booleans, so DCQL `values` / `value` /
  `min` / `max` conditions match them.
- A stored credential that cannot be parsed is skipped instead of aborting the match for every other
  credential in the wallet.
- A DCQL credential query without `meta` is matched on its claim constraints instead of being
  dropped; `meta` is optional in DCQL.
- A malformed JWE, credential JWT header or signature from a server raises an error instead of
  trapping: issuance no longer crashes on a malformed response.
- The logger's configuration (`WalletLogger.setEnable`/`setLogLevel`) and the wallet's lock state are
  read and written through a lock instead of unsynchronized mutable statics. Method signatures are
  unchanged.

### Added
- Public data models declare `Sendable`. Beyond `Jsonable` (above), the enums and value types those
  models are built from — `AnyJSON`, `UTCDatetime`, `DIDVersionId`, `DIDMethodType`, `Disclosure`,
  `VerifyAuthType`, `ZKProof`'s nested proof types, the `DIDDocument` / `VerifiableCredential` /
  `Profile` enums and others — now state the conformance too, so consumers can pass them across
  concurrency domains without suppressing diagnostics.


## v2.0.2 (2025-12-19)

### Changed
- Removed the dependency on OpenSSL and replaced it with an internal cryptographic implementation.


## v2.0.1 (2025-10-14)

### Highlights
- Refactored core components including DIDManager, WalletAPI, and CoreDataManager  
- Improved error handling and consistency across the SDK  
- Added new APIs for DID document updates, key management, and authentication  
- Enhanced communication layer with unified request handling and DELETE support  
- Fixed incorrect key placement within DID Document

### Important
- Creating or updating a DID Document no longer triggers automatic save.  
  You must explicitly call the save API to persist changes.

### New Features
- Added Swift Package Manager (SPM) support for seamless integration in Swift and Xcode projects.


## v2.0.0 (2025-05-27)

### Integration
- The Wallet SDK integrates four other SDKs. The list is Below:
    - Core SDK
    - Utility SDK
    - DataModel SDK
    - Communication SDK
    
### New Features
- Zero-Knowledge Proof (ZKP) functionality is now supported


## v1.0.0 (2024-10-18)

### 🚀 New Features
- Core SDK
    - DID Document management(Generation, Retrieval, Deletion)
    - VerifiableCredential management(Storage, Retrieval, Deletion)
    - VerifiablePresentation generation
    - Key management for encryption, decryption and signing
- Utility SDK
    - Data encryption and decryption
    - Key generation using PBKDF
    - Shared Secrets Generation for ECDH
    - Multibase encoding and decoding
    - Hash algorithms
- DataModel SDK
    - Value object for Mobile Wallet (DID, VC, VP, Profile, etc)
- Communication SDK
    - Manages HTTP requests and responses, supporting GET and POST methods with JSON payloads.
- Wallet SDK
    - Token management to access wallet
    - Wallet lock/unlock management
    - Provides core and service functions
