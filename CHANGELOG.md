# Changelog

## v3.0.0 (2026-11-13)

### Breaking Changes
- Minimum supported platform raised to iOS 17.0.
- `Jsonable` now inherits `Sendable`.
- `walletId` moved to a dedicated `UserDefaults` suite without migration; existing wallets from
  v2.0.2 must be migrated by the app or re-created.
- `CredentialPrimaryPublicKey.r` is now `OrderedStringMap<BigIntString>`.

### Removed
- Deprecated `CommunicationClient.doGet` / `doPost` and their protocols.
- `WalletLogger.shared`; `WalletLogger` now uses static methods.

### Fixed
- ZKP proofs drop requested items on a shared attribute.
- Holder DID Document `versionId` not persisted on update.
- Key material written to logs.

### Added
- OpenID4VCI / OpenID4VP support for SD-JWT VC and mdoc (issuance, presentation, ISO/IEC 18013-5
  proximity presentation, revocation).
- `createLocalWalletToken(purpose:pkgName:)` for offline wallet tokens.
- `isChanging` parameter on `authenticateLock(passcode:isChanging:)`.


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
