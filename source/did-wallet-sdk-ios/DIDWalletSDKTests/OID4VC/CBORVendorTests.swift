//
/*
 * Copyright 2026 OmniOne.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import XCTest
import OrderedCollections
@testable import DIDWalletSDK

/// Pins the behaviour of the vendored SwiftCBOR copy that the mdoc (ISO/IEC 18013-5) path
/// depends on. These are not upstream's tests: each one states an invariant the mdoc encoder,
/// decoder or signature check would silently break if a future re-sync changed it.
final class CBORVendorTests: XCTestCase {

    // MARK: - Known vectors (RFC 8949 Appendix A)

    /// The vendored copy still encodes the primitives the mdoc structures are built from.
    func testKnownVectors() {
        XCTAssertEqual(CBOR.unsignedInt(0).encode(), [0x00])
        XCTAssertEqual(CBOR.unsignedInt(100).encode(), [0x18, 0x64])
        XCTAssertEqual(CBOR.unsignedInt(1000).encode(), [0x19, 0x03, 0xe8])
        XCTAssertEqual(CBOR.negativeInt(0).encode(), [0x20])            // -1
        XCTAssertEqual(CBOR.utf8String("").encode(), [0x60])
        XCTAssertEqual(CBOR.utf8String("IETF").encode(), [0x64, 0x49, 0x45, 0x54, 0x46])
        XCTAssertEqual(CBOR.byteString([0x01, 0x02, 0x03, 0x04]).encode(),
                       [0x44, 0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(CBOR.array([]).encode(), [0x80])
        XCTAssertEqual(CBOR.array([1, 2, 3]).encode(), [0x83, 0x01, 0x02, 0x03])
        XCTAssertEqual(CBOR.boolean(false).encode(), [0xf4])
        XCTAssertEqual(CBOR.boolean(true).encode(), [0xf5])
        XCTAssertEqual(CBOR.null.encode(), [0xf6])
    }

    /// COSE protected headers are a map with negative integer values (`{1: -7}` for ES256).
    /// Getting the negative-integer encoding wrong would produce a header the verifier rejects.
    func testCOSEAlgHeaderEncoding() {
        let protectedHeader: CBOR = .map([.unsignedInt(1): .negativeInt(6)])   // alg: ES256 (-7)
        XCTAssertEqual(protectedHeader.encode(), [0xa1, 0x01, 0x26])
    }

    // MARK: - Deterministic encoding

    /// `CBOR.map` encodes in insertion order and never sorts: the fork removed the sort from
    /// `encodeCBORMap`, and `CBOROptions.shouldSortMapKeys` reaches only the Swift-`Dictionary`
    /// overloads the mdoc path does not use.
    ///
    /// So deterministic encoding is *our* obligation, not the library's — every structure the
    /// presenter builds has to insert its keys in one fixed order. This test exists to fail loudly
    /// if a re-sync ever restores sorting, because that would silently rewrite issuer bytes.
    func testMapEncodingFollowsInsertionOrderAndNeverSorts() {
        var ascending = OrderedDictionary<CBOR, CBOR>()
        ascending[.utf8String("a")] = .unsignedInt(1)
        ascending[.utf8String("b")] = .unsignedInt(2)

        var descending = OrderedDictionary<CBOR, CBOR>()
        descending[.utf8String("b")] = .unsignedInt(2)
        descending[.utf8String("a")] = .unsignedInt(1)

        XCTAssertEqual(CBOR.map(ascending).encode(),
                       [0xa2, 0x61, 0x61, 0x01, 0x61, 0x62, 0x02])
        XCTAssertEqual(CBOR.map(descending).encode(),
                       [0xa2, 0x61, 0x62, 0x02, 0x61, 0x61, 0x01])
        XCTAssertNotEqual(CBOR.map(ascending).encode(), CBOR.map(descending).encode())
    }

    /// A map assembled in a fixed order encodes to the same bytes every run, which is what the
    /// SessionTranscript and `Sig_structure` need — the verifier rebuilds them independently and
    /// compares byte for byte.
    func testFixedInsertionOrderEncodesReproducibly() {
        func deviceResponseHead() -> [UInt8] {
            var map = OrderedDictionary<CBOR, CBOR>()
            map[.utf8String("version")] = .utf8String("1.0")
            map[.utf8String("status")] = .unsignedInt(0)
            return CBOR.map(map).encode()
        }

        XCTAssertEqual(deviceResponseHead(), deviceResponseHead())
        XCTAssertEqual(deviceResponseHead(),
                       [0xa2,
                        0x67, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x63, 0x31, 0x2e, 0x30,
                        0x66, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x00])
    }

    // MARK: - Byte preservation

    /// The MSO digests are computed over each `IssuerSignedItemBytes` exactly as the issuer wrote
    /// them. Selective disclosure moves those byte strings across untouched, so decoding must hand
    /// back the inner bytes verbatim — including a key order that deterministic encoding would
    /// have rewritten. If this ever normalises, every presented credential fails digest checks.
    func testTaggedByteStringKeepsIssuerBytesVerbatim() throws {
        // A map whose wire order is {"b": 2, "a": 1} — the opposite of the sorted encoding.
        let issuerItemBytes: [UInt8] = [0xa2, 0x61, 0x62, 0x02, 0x61, 0x61, 0x01]
        let wrapped = CBOR.tagged(CBOR.Tag(rawValue: 24), .byteString(issuerItemBytes))

        guard let decoded = try CBOR.decode(wrapped.encode()),
              case let .tagged(tag, payload) = decoded,
              case let .byteString(recovered) = payload
        else {
            return XCTFail("tag 24 byte string did not survive the round trip")
        }

        XCTAssertEqual(tag.rawValue, 24)
        XCTAssertEqual(recovered, issuerItemBytes)

        // Decoding to a value and re-encoding happens to reproduce the same bytes, because map
        // order survives. The presenter still moves the byte string rather than rebuilding it: a
        // digest check must not rest on the encoder being byte-faithful for every input it meets.
        guard let asValue = try CBOR.decode(issuerItemBytes) else {
            return XCTFail("inner bytes are not decodable")
        }
        XCTAssertEqual(asValue.encode(), issuerItemBytes)
    }

    /// Decoding an issuer credential preserves the order the issuer used, so a re-encoded document
    /// stays comparable to the original when debugging a rejected presentation.
    func testDecodePreservesMapOrder() throws {
        let wire: [UInt8] = [0xa2, 0x61, 0x62, 0x02, 0x61, 0x61, 0x01]   // {"b": 2, "a": 1}
        guard let decoded = try CBOR.decode(wire), case let .map(map) = decoded else {
            return XCTFail("not a map")
        }
        XCTAssertEqual(map.keys.map { $0 }, [.utf8String("b"), .utf8String("a")])
    }

    // MARK: - Robustness

    /// Credential bytes come from the issuer and the verifier, so malformed input has to surface as
    /// a thrown error. A trap here would be an uncatchable crash in the wallet.
    func testTruncatedInputThrows() {
        XCTAssertThrowsError(try CBOR.decode([0x64, 0x49, 0x45]))          // tstr(4) with 2 bytes
        XCTAssertThrowsError(try CBOR.decode([0x44, 0x01]))                // bstr(4) with 1 byte
        XCTAssertThrowsError(try CBOR.decode([0x83, 0x01]))                // array(3) with 1 item
        XCTAssertThrowsError(try CBOR.decode([0xa2, 0x01, 0x02, 0x03]))    // map(2) missing a value
    }

    /// Deeply nested input must not recurse without bound when a depth limit is asked for.
    func testMaximumDepthIsEnforced() {
        // 40 nested single-element arrays.
        let nested = [UInt8](repeating: 0x81, count: 40) + [0x00]
        XCTAssertThrowsError(
            try CBOR.decode(nested, options: CBOROptions(maximumDepth: 8)))
    }
}
