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
import CryptoKit
@testable import DIDWalletSDK

/// Reads a real issued mdoc (`MdocFixtures.pidIssuerSigned`) rather than a document this SDK
/// encoded itself: the parser's job is to survive what issuers actually send, which includes two
/// places where this issuer departs from ISO/IEC 18013-5.
final class MdocTests: XCTestCase {

    private let namespace = "eu.europa.ec.eudi.pid.1"

    private func parsed() throws -> Mdoc {
        return try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)
    }

    func testParsesDocTypeAndEveryElement() throws {
        let mdoc = try parsed()

        XCTAssertEqual(mdoc.docType, "eu.europa.ec.eudi.pid.1")
        XCTAssertEqual(Array(mdoc.namespaces.keys), [namespace])
        XCTAssertEqual(mdoc.namespaces[namespace]?.count, 26)
        XCTAssertEqual(mdoc.items[namespace]?.count, 26)
    }

    func testKeepsTheIssuersOwnBytes() throws {
        let mdoc = try parsed()

        // The document is presented as it was issued; nothing re-encodes it.
        XCTAssertEqual(mdoc.toString(), MdocFixtures.pidIssuerSigned)
        XCTAssertEqual(mdoc, try parsed())
    }

    /// The digests are the reason the raw bytes are kept. Recomputing them here is what would fail
    /// if `MdocIssuerSignedItem` ever rebuilt an item instead of carrying the bytes across.
    func testEveryElementMatchesItsDigestInTheMSO() throws {
        let mdoc = try parsed()
        let digests = try XCTUnwrap(mdoc.mso.valueDigests[namespace])
        let items = try XCTUnwrap(mdoc.items[namespace])

        XCTAssertEqual(mdoc.mso.digestAlgorithm, "SHA-256")
        XCTAssertEqual(digests.count, items.count)
        for item in items {
            let computed = Data(SHA256.hash(data: Data(item.itemBytes)))
            XCTAssertEqual(computed, digests[item.digestID],
                           "digest mismatch for \(item.elementIdentifier)")
        }
    }

    func testReadsTextAndByteStringElements() throws {
        let claims = try XCTUnwrap(parsed().namespaces[namespace])

        XCTAssertEqual(claims["given_name"], .text("Raon"))
        XCTAssertEqual(claims["family_name"], .text("Kim"))
        XCTAssertEqual(claims["issuing_country"], .text("KR"))
        XCTAssertEqual(claims["document_number"], .text("11-123456-78"))

        // A portrait is a JPEG byte string, which is why element values cannot be modelled as JSON.
        guard case let .bytes(portrait)? = claims["portrait"] else {
            return XCTFail("portrait is not a byte string")
        }
        XCTAssertGreaterThan(portrait.count, 1024)
        XCTAssertEqual(portrait.prefix(2), Data([0xFF, 0xD8]))
    }

    /// `birth_date` is tagged `full-date` (1004) as the standard requires, and is kept as written:
    /// turning it into a `Date` would have to invent a time zone.
    func testFullDateIsKeptAsWritten() throws {
        let claims = try XCTUnwrap(parsed().namespaces[namespace])

        XCTAssertEqual(claims["birth_date"], .fullDate("1990-05-15"))
    }

    /// This issuer tags `expiry_date` `0` -- a full date-time -- while writing only a date. Reading
    /// it as an instant would have to invent a time, so the value is kept as the date it is.
    func testDateOnlyUnderTagZeroIsKeptAsAFullDate() throws {
        let claims = try XCTUnwrap(parsed().namespaces[namespace])

        XCTAssertEqual(claims["expiry_date"], .fullDate("2036-01-10"))
    }

    /// The elements this issuer has no value for arrive as empty strings rather than being left
    /// out, so a wallet that lists "the claims this credential can disclose" will list all 26.
    func testElementsWithoutAValueArrivePresentAndEmpty() throws {
        let claims = try XCTUnwrap(parsed().namespaces[namespace])

        XCTAssertEqual(claims["resident_city"], .text(""))
        XCTAssertEqual(claims["nationality"], .text(""))
    }

    /// The MSO's timestamps carry milliseconds, which ISO/IEC 18013-5 does not allow. Rejecting
    /// them would reject documents that verify, so both forms are read.
    func testValidityInfoWithFractionalSecondsIsRead() throws {
        let validity = try parsed().validityInfo

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        XCTAssertEqual(validity.signed, formatter.date(from: "2026-08-11T02:23:27.311Z"))
        XCTAssertEqual(validity.validFrom, validity.signed)
        XCTAssertEqual(validity.validUntil, formatter.date(from: "2027-08-11T02:23:27.311Z"))
        XCTAssertNil(validity.expectedUpdate)
    }

    func testIssuerAuthCarriesADIDKeyIdentifierAndNoCertificateChain() throws {
        let issuerAuth = try parsed().issuerAuth

        XCTAssertEqual(issuerAuth.algorithm, COSESign1.algES256)
        XCTAssertEqual(issuerAuth.keyIdentifier, "did:omn:issuer?versionId=1#assert")
        XCTAssertFalse(issuerAuth.hasX5Chain)
        // ES256 signs r ‖ s, which is what the SDK's P-256 verifier takes.
        XCTAssertEqual(issuerAuth.signature.count, 64)
    }

    /// `Sig_structure` is a four-element array, so its encoding does not depend on how the CBOR
    /// library orders map keys -- the vendored copy does not sort them at all.
    func testSignatureInputIsTheSignature1Structure() throws {
        let issuerAuth = try parsed().issuerAuth

        let input = try issuerAuth.signatureInput()
        XCTAssertEqual(Array(input.prefix(12)),
                       [0x84, 0x6A] + Array("Signature1".utf8))
        XCTAssertEqual(input, try issuerAuth.signatureInput())
    }

    /// The document is bound to a holder key; presenting it means signing with that key, so a
    /// wallet that cannot match it to a key it holds can never present the credential.
    func testDeviceKeyIsAP256PublicKey() throws {
        let deviceKey = try parsed().mso.deviceKey

        guard case let .map(fields) = deviceKey else {
            return XCTFail("deviceKey is not a COSE_Key map")
        }
        XCTAssertEqual(fields[.unsignedInt(1)]?.int64Value, 2)     // kty: EC2
        XCTAssertEqual(fields[.negativeInt(0)]?.int64Value, 1)     // crv: P-256
        guard case let .byteString(x)? = fields[.negativeInt(1)],  // x
              case let .byteString(y)? = fields[.negativeInt(2)] else {
            return XCTFail("deviceKey has no coordinates")
        }
        XCTAssertEqual(x.count, 32)
        XCTAssertEqual(y.count, 32)
    }

    func testAcceptsTheIssuedDocumentsOwnDigests() throws {
        XCTAssertNoThrow(try parsed().verifyDigests())
    }

    /// The window is judged against a caller-supplied instant rather than "now", so the boundaries
    /// can be stated exactly -- and so this test does not start failing in 2027.
    func testValidityIsJudgedAgainstTheIssuersWindow() throws {
        let mdoc = try parsed()
        let validity = mdoc.validityInfo

        XCTAssertNoThrow(try mdoc.verifyValidity(at: validity.validFrom))
        XCTAssertNoThrow(try mdoc.verifyValidity(at: validity.validUntil))
        XCTAssertThrowsError(try mdoc.verifyValidity(at: validity.validFrom.addingTimeInterval(-1)))
        XCTAssertThrowsError(try mdoc.verifyValidity(at: validity.validUntil.addingTimeInterval(1)))
    }

    func testRejectsInputThatIsNotAnIssuerSigned() {
        XCTAssertThrowsError(try Mdoc.parse(raw: "not base64url ~~"))
        XCTAssertThrowsError(try Mdoc.parse(raw: Data([0x01, 0x02]).base64URLEncoded))
    }
}
