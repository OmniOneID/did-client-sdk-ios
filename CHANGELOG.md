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

- `CredentialPrimaryPublicKey.r` is an `OrderedStringMap<BigIntString>` instead of an
  `OrderedCollections.OrderedDictionary<String, BigIntString>`. Subscripting, iteration and `keys`
  read the same, and the JSON encoding is unchanged; only code that spells the type out or calls
  swift-collections' own API (`elements`, `index(forKey:)`) has to change.

  Why: that property was the sole place a swift-collections type reached the public interface, and
  it obliged every consuming app to declare and pin the package to compile against the SDK. The
  library is an implementation detail — with an SDK-owned type in the signature it is now linked
  statically and never named, so an app using the XCFramework can drop the declaration entirely and
  an app using SPM no longer has to agree with the SDK on a version.

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
- The logger's configuration (`WalletLogger.setEnable`/`setLogLevel`) and the wallet's lock state are
  read and written through a lock instead of unsynchronized mutable statics. Method signatures are
  unchanged.

### Added

**OpenID4VC.** An OpenID4VCI / OpenID4VP layer, new in this release: the wallet can be issued
credentials by an OpenID4VCI issuer, keep them alongside the OmniOne W3C credentials it already
held, and answer an OpenID4VP request from a verifier. Two credential formats are supported,
IETF SD-JWT VC and ISO/IEC 18013-5 mdoc.

- **Issuance and storage.** `WalletAPI.requestIssueOID4VC(...)` obtains a credential from an issuer
  and stores it only after verifying it — the issuer signature against the key its `kid` resolves
  to in the issuer's DID document, and, for an mdoc, the element digests, the validity window and
  the binding to the wallet's own key. `getAllOID4VCs`, `getOID4VCs(ids:)`, `deleteOID4VCs(ids:)`
  and `isAnyOID4VCSaved` manage what is stored.

  The listing APIs return `[any CredentialItem]`, not a concrete type: one wallet holds both
  formats, so a list mixes `SdJwtCredentialItem` and `MdocCredentialItem` and the caller narrows to
  what it can act on.

- **Presentation.** `matchCredentials(hWalletToken:authRequest:)` answers a DCQL query with the
  stored credentials that satisfy it, and `createVpToken(...)` builds the authorization response for
  the holder's selection — a KB-JWT presentation for SD-JWT, a `DeviceResponse` for mdoc — returning
  a body that is ready to send, JWE-sealed when the request asks for `direct_post.jwt`.

  What a presentation carries is what the issuer signed, byte for byte: an SD-JWT disclosure travels
  as the issuer wrote it rather than re-serialized, and its digest is taken over that base64url
  string, because a verifier checks the bytes and not the JSON they decode to. The mdoc path holds
  the same line, moving issuer-signed items across unchanged.

  Matching follows DCQL where the spec is easy to read past: `meta` is optional, so a query without
  it is matched on its claim constraints; a claim value of `0` or `1` is a number and not a boolean,
  so `values` / `value` / `min` / `max` see it; a path into a nested or plaintext claim
  (`address.street_address`) resolves to every disclosure that reveals it, the parent object's
  included; and a stored credential that will not parse is skipped rather than abandoning the match
  for every other credential in the wallet.

  A match names its claims as opaque codes (`MatchedCredential.claimCodes`). The SDK both produces a
  code and resolves it back to the claim, so a code is a label to show and an identity to compare
  and nothing else: splitting one on `.` or `[]`, or assembling one from parts, picks out a
  different claim than the holder agreed to.

- **Consent listing.** `Mdoc.consentItems` and `SDJWT.consentItems()` — mirrored on the two
  `CredentialItem` types — enumerate everything a credential can be asked to disclose, each row
  carrying the code the presentation will be expressed in. Both list in the order the issuer wrote
  the credential — the order its elements were signed in for an mdoc, the order its disclosures
  arrived in for an SD-JWT — so a screen drawn from either does not reorder itself between runs.
  `SdJwtConsentItem.isSelectivelyDisclosable`
  reports whether withholding a claim actually hides it, since an issuer may leave a claim in the
  clear; `isAmbiguous` marks a code that names more than one claim, which cannot be presented.

- **Issuer identity.** `Mdoc.issuerDid` and `SDJWT.issuerDid`, likewise mirrored, name the issuer
  whose key the credential's signature was checked against. Read from the signature's key
  identifier rather than from a self-asserted claim, and reported the same way for both formats.

- **Format tokens.** `CredentialFormat.token` and `CredentialFormat.init?(token:)` convert between
  the enum and the DCQL `format` string, the initializer also accepting the aliases a verifier may
  send. An app that has to branch on a request's format need not carry the literals itself.

- **JWS.** `JWS` is public — `protectedHeader`, `payloadData`, `verify()` and
  `verify(publicKey:)` — because fetching an authorization request and posting its response stay
  with the app. `verify()` checks the signature against a `jwk` carried in the header, which
  authenticates nothing on its own; when the header names a `kid`, resolve the signer's key and use
  `verify(publicKey:)`, leaving the trust decision where it belongs.

- **Errors.** `OID4VCManagerError` raises coded errors across the flow: `051xx` for malformed input,
  `052xx` for JWE, `053xx` for the credential response, `054xx` for verification (including the mdoc
  checks `05403`–`05405`) and `055xx` for presentation.

- `authenticateLock(passcode:isChanging:)` takes an `isChanging` flag, default `false`, so a
  passcode-change flow can verify the current passcode without disturbing the wallet's lock state.
  Existing call sites keep compiling.

- `OrderedStringMap`, an insertion-ordered string-keyed map the SDK owns. See the note on
  `CredentialPrimaryPublicKey.r` under Breaking Changes.

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
