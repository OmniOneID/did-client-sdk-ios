# SwiftCBOR (vendored)

CBOR encoder/decoder used by the OID4VC mdoc (ISO/IEC 18013-5) path.

## Provenance

| | |
|---|---|
| Source | https://github.com/niscy-eudiw/SwiftCBOR |
| Tag | `v0.6.5` |
| Commit | `e8fef8613a4c32b150885fec8f32c2ebfe0501c4` |
| License | The Unlicense (public domain) |
| Upstream lineage | Fork of [valpackett/SwiftCBOR](https://github.com/valpackett/SwiftCBOR), maintained by the EU Digital Identity Wallet reference implementation |

This fork is used rather than upstream because it stores CBOR maps in an
`OrderedDictionary` (upstream uses a plain `Dictionary`, whose iteration order is
seeded per process) and because it already declares `Sendable`.

The sources are vendored rather than declared as a package dependency: the SDK ships
as a prebuilt `DIDWalletSDK.xcframework`, and an external module would have to be
linked by every consumer. Vendoring keeps `CBOR` out of the public interface entirely.

## Local modifications

1. **Codable layer removed.** `Sources/Encoder/`, `Sources/Decoder/`, `AnyCodingKey.swift`
   and `Info.plist` are not vendored. Two call sites that fell back to
   `CodableCBOREncoder` for values that are `Codable` but not `CBOREncodable`
   (in `encodeAny` and `cborFromAny`) now throw `CBOREncoderError.invalidType`, and
   `CBOROptions.toCodableEncoderOptions()` / `.toCodableDecoderOptions()` are dropped.
   The mdoc path builds `CBOR` values directly, so nothing here is reachable from it.
2. **`public` downgraded to `internal`.** `CBOR` is a very general type name; keeping it
   internal avoids polluting the SDK's public surface, keeps `OrderedCollections` out of
   the generated `.swiftinterface`, and prevents confusion for apps that link SwiftCBOR
   themselves.
3. **`Util` renamed to `CBORUtil`** (and `Util.swift` to `CBORUtil.swift`). `Util` is too
   generic to sit in the SDK module namespace.

Deliberately **not** changed: the `CBOROptions.init` parameter is spelled
`shouldShortMapKeys` while the property is `shouldSortMapKeys`. That typo is upstream's;
keeping it makes a future diff against upstream readable.

## Usage notes

- **`CBOR.map` encodes in insertion order and never sorts.** The fork removed the sort from
  `encodeCBORMap`, so `CBOROptions.shouldSortMapKeys` reaches only the Swift-`Dictionary`
  overloads, which the mdoc path does not use. Deterministic encoding is therefore the
  caller's obligation: every structure built here must insert its keys in one fixed order.
  `CBORVendorTests` pins this, and will fail if a re-sync restores sorting.
- The upside of that behaviour is byte fidelity — a decoded issuer document re-encodes to the
  bytes the issuer wrote, which keeps a rejected presentation debuggable.
- When verifying `issuerAuth`, feed the received bytes (the decoded `.byteString` payload
  and protected header) to the signature check. Re-encoding them would break the signature.
- Selective disclosure must move each `IssuerSignedItemBytes` across verbatim: the MSO
  digests are computed over those exact bytes, so the item byte strings can never be
  rebuilt, even though the map that holds them may be re-encoded.

## Re-syncing

Fetch the same file set from the tag you are moving to, then re-apply the three
modifications above. `swift build && swift test` in a clone of the fork is a cheap way to
confirm a candidate tag before vendoring it; it was run against `swift-collections`
1.1.4 (the version this SDK pins) and 1.6.0, passing 77/77 in both.
