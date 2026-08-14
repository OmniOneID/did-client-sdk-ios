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
import OrderedCollections
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

    // MARK: - Consent items

    /// The wallet screen is drawn from this list, so it has to name every element the document can
    /// disclose — one row per element, no more and no less.
    func testConsentItemsNameEveryElement() throws {
        let mdoc = try parsed()

        let items = mdoc.consentItems

        XCTAssertEqual(items.count, 26)
        XCTAssertEqual(Set(items.map { $0.code }), try XCTUnwrap(mdoc.namespaces[namespace]).keys.reduce(into: Set<String>()) {
            $0.insert(MdocClaimIndex.code(namespace: namespace, elementIdentifier: $1))
        })
        XCTAssertTrue(items.allSatisfy { $0.namespace == namespace })
        XCTAssertFalse(items.contains { $0.isAmbiguous })
    }

    /// `namespaces` is a `Dictionary`, so a screen built from it reshuffles between runs. The
    /// consent list is the issuer's own order, which is stable.
    func testConsentItemOrderIsStableAndFollowsTheIssuer() throws {
        let mdoc = try parsed()

        let first = mdoc.consentItems.map { $0.elementIdentifier }
        let second = mdoc.consentItems.map { $0.elementIdentifier }

        XCTAssertEqual(first, second)
        // The issuer signed issuance_date, birth_date, … in this order.
        XCTAssertEqual(Array(first.prefix(3)),
                       ["issuance_date", "birth_date", "personal_administrative_number"])
    }

    /// The codes on screen and the codes the presenter resolves are one set, which is the whole
    /// point of publishing them rather than letting an app assemble `"namespace.element"`.
    func testConsentItemCodesArePresentable() throws {
        let mdoc = try parsed()
        let portrait = try XCTUnwrap(mdoc.consentItems.first { $0.elementIdentifier == "portrait" })

        XCTAssertEqual(portrait.value, mdoc.namespaces[namespace]?["portrait"])

        let selected = try MdocPresenter.resolveElements(mdoc: mdoc, claimCodes: [portrait.code])
        XCTAssertEqual(selected[namespace]?.map { $0.elementIdentifier }, ["portrait"])
    }

    /// Two elements whose namespace and identifier join to the same string. No deployed document
    /// type does this, but the wallet must fail closed rather than disclose whichever one it
    /// happened to index first — and the screen has to be able to say so before asking.
    func testCollidingElementsAreMarkedAmbiguousAndCannotBePresented() throws {
        let mdoc = try Mdoc.parse(raw: MdocTests.syntheticDocument(elements: [
            ("a.b", "c"),   // code "a.b.c"
            ("a", "b.c")    // code "a.b.c" as well
        ]))

        let items = mdoc.consentItems
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(Set(items.map { $0.code }), ["a.b.c"])
        XCTAssertTrue(items.allSatisfy { $0.isAmbiguous })

        XCTAssertThrowsError(try MdocPresenter.resolveElements(mdoc: mdoc, claimCodes: ["a.b.c"]))
    }

    /// The reference the issuer publishes status under, as it arrives: `status_list` at the top of
    /// the MSO, an unsigned `idx` and a text `uri`.
    func testStatusListReferenceIsReadFromTheMSO() throws {
        let mdoc = try Mdoc.parse(raw: MdocTests.syntheticDocument(
            elements: [("test.doc", "a")],
            status: .map(["status_list": .map(["idx": .unsignedInt(7),
                                               "uri": .utf8String("https://issuer.example/status-lists/2")])])))

        XCTAssertEqual(mdoc.status, StatusListReference(uri: "https://issuer.example/status-lists/2", idx: 7))
    }

    /// Documents issued before the issuer published status lists carry no `status`, and they have
    /// to keep parsing — the wallet re-reads stored documents on every listing, so rejecting them
    /// would take credentials the holder already owns out of reach.
    func testDocumentWithoutStatusParsesAndReportsNoReference() throws {
        XCTAssertNil(try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned).status)
        XCTAssertNil(try Mdoc.parse(raw: MdocTests.syntheticDocument(elements: [("test.doc", "a")])).status)
    }

    /// A `status` written wrongly is the issuer getting it wrong, not the document declining to
    /// publish one. Returning `nil` there would read as "nothing to check" and quietly let a
    /// revocable document past the check it was supposed to get.
    func testMalformedStatusIsRejectedRatherThanReadAsAbsent() {
        let malformed: [CBOR] = [
            .utf8String("revoked"),                                              // status is not a map
            .map(["status_list": .utf8String("https://issuer.example/2#7")]),    // entry is not a map
            .map(["status_list": .map(["idx": .unsignedInt(7)])]),               // no uri
            .map(["status_list": .map(["uri": .utf8String("https://issuer.example/2")])]),  // no idx
            .map(["status_list": .map(["idx": .negativeInt(0),                   // idx is not unsigned
                                       "uri": .utf8String("https://issuer.example/2")])]),
            .map(["status_list": .map(["idx": .unsignedInt(7),                   // uri names nothing
                                       "uri": .utf8String("")])])
        ]
        for status in malformed {
            XCTAssertThrowsError(try Mdoc.parse(raw: MdocTests.syntheticDocument(
                elements: [("test.doc", "a")], status: status)), "\(status)")
        }
    }

    /// A status mechanism this SDK does not read is not a malformed one. The MSO parses, and the
    /// document simply has no status list to point at.
    func testStatusWithoutAStatusListIsNotAFailure() throws {
        let mdoc = try Mdoc.parse(raw: MdocTests.syntheticDocument(
            elements: [("test.doc", "a")],
            status: .map(["identifier_list": .map(["id": .utf8String("x"),
                                                   "uri": .utf8String("https://issuer.example/ids/1")])])))

        XCTAssertNil(mdoc.status)
    }

    /// Builds an `IssuerSigned` carrying the given (namespace, element) pairs. The MSO is
    /// structurally complete but not signed — `parse` decodes, it does not verify.
    ///
    /// - Parameters:
    ///   - elements: The (namespace, identifier) pairs to write into `nameSpaces`.
    ///   - status: The MSO's `status` member, written only when given.
    private static func syntheticDocument(elements: [(namespace: String, identifier: String)],
                                          status: CBOR? = nil) -> String {
        var nameSpaces = OrderedDictionary<CBOR, CBOR>()
        for (index, element) in elements.enumerated() {
            let item = CBOR.map([
                "digestID": .unsignedInt(UInt64(index)),
                "random": .byteString([UInt8](repeating: 0, count: 16)),
                "elementIdentifier": .utf8String(element.identifier),
                "elementValue": .utf8String("value-\(index)")
            ])
            let tagged = CBOR.tagged(CBOR.Tag(rawValue: 24), .byteString(item.encode()))
            var list = nameSpaces[.utf8String(element.namespace)].flatMap { entry -> [CBOR] in
                if case let .array(existing) = entry { return existing }
                return []
            } ?? []
            list.append(tagged)
            nameSpaces[.utf8String(element.namespace)] = .array(list)
        }

        let timestamp = CBOR.tagged(CBOR.Tag(rawValue: 0), .utf8String("2026-08-11T00:00:00Z"))
        var msoFields: OrderedDictionary<CBOR, CBOR> = [
            "version": .utf8String("1.0"),
            "digestAlgorithm": .utf8String("SHA-256"),
            "docType": .utf8String("test.doc"),
            "valueDigests": .map(["test.doc": .map([:])]),
            "deviceKeyInfo": .map(["deviceKey": .map([:])]),
            "validityInfo": .map([
                "signed": timestamp,
                "validFrom": timestamp,
                "validUntil": timestamp
            ])
        ]
        if let status {
            msoFields["status"] = status
        }
        let mso = CBOR.map(msoFields)
        let issuerAuth = CBOR.array([
            .byteString(CBOR.map([.unsignedInt(1): .negativeInt(6)]).encode()),
            .map([:]),
            .byteString(CBOR.tagged(CBOR.Tag(rawValue: 24), .byteString(mso.encode())).encode()),
            .byteString([UInt8](repeating: 0, count: 64))
        ])

        let issuerSigned = CBOR.map([
            "issuerAuth": issuerAuth,
            "nameSpaces": .map(nameSpaces)
        ])
        return Data(issuerSigned.encode()).base64URLEncoded
    }

    func testStoredItemAnswersTheSameAsItsDocument() throws {
        let mdoc = try parsed()
        let item = MdocCredentialItem(id: "id",
                                      format: .msoMdoc,
                                      configurationId: "config",
                                      kid: "pin",
                                      credentialIdentifier: nil,
                                      mdoc: mdoc)

        XCTAssertEqual(item.consentItems, mdoc.consentItems)
    }

    func testRejectsInputThatIsNotAnIssuerSigned() {
        XCTAssertThrowsError(try Mdoc.parse(raw: "not base64url ~~"))
        XCTAssertThrowsError(try Mdoc.parse(raw: Data([0x01, 0x02]).base64URLEncoded))
    }
}
