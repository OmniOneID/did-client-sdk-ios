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
@testable import DIDWalletSDK

/// The issuer a stored credential names, which a detail screen labels "Issued by".
///
/// Both formats answer from the key identifier their signature was checked against, not from
/// anything the issuer wrote about itself, and both answer in the same shape — a screen that names
/// the issuer should not have to know which format it is looking at.
final class IssuerDidTests: XCTestCase {

    // MARK: - mdoc

    func testMdocNamesTheDidItsSignatureWasCheckedAgainst() throws {
        let mdoc = try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)

        XCTAssertEqual(mdoc.issuerAuth.keyIdentifier, "did:omn:issuer?versionId=1#assert")
        XCTAssertEqual(mdoc.issuerDid, "did:omn:issuer")
    }

    /// A document whose `issuerAuth` names no key has no issuer to show. Parsing does not verify,
    /// so this is reachable by parsing alone -- never by a credential this SDK stored.
    func testMdocWithoutAKeyIdentifierHasNoIssuerDid() throws {
        let mdoc = try Mdoc.parse(raw: IssuerDidTests.unsignedDocument())

        XCTAssertNil(mdoc.issuerAuth.keyIdentifier)
        XCTAssertNil(mdoc.issuerDid)
    }

    func testMdocStoredItemAnswersTheSameAsItsDocument() throws {
        let mdoc = try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)
        let item = MdocCredentialItem(id: "id",
                                      format: .msoMdoc,
                                      configurationId: "config",
                                      kid: "pin",
                                      credentialIdentifier: nil,
                                      mdoc: mdoc)

        XCTAssertEqual(item.issuerDid, mdoc.issuerDid)
    }

    // MARK: - SD-JWT

    /// `kid` rather than `iss`: the payload states an issuer, the header names the key the
    /// signature was verified with. This pins that the property follows the second.
    func testSdJwtNamesTheDidFromTheHeaderNotThePayload() throws {
        let sdjwt = SDJWT.parse(raw: IssuerDidTests.credential(
            header: #"{"alg":"ES256","typ":"dc+sd-jwt-did","kid":"did:omn:issuer?versionId=1#assert"}"#,
            payload: #"{"vct":"https://credentials.example/identity","iss":"https://issuer.example"}"#))

        XCTAssertEqual(sdjwt.issuerDid, "did:omn:issuer")
    }

    func testSdJwtWithoutAKeyIdentifierHasNoIssuerDid() throws {
        let sdjwt = SDJWT.parse(raw: IssuerDidTests.credential(
            header: #"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#,
            payload: #"{"iss":"https://issuer.example"}"#))

        XCTAssertNil(sdjwt.issuerDid)
    }

    /// A `kid` that is not a DID URL names no DID. Reporting the raw string would put a value on
    /// screen that no verification stands behind.
    func testSdJwtWithANonDidKeyIdentifierHasNoIssuerDid() throws {
        let sdjwt = SDJWT.parse(raw: IssuerDidTests.credential(
            header: #"{"alg":"ES256","typ":"dc+sd-jwt-did","kid":"key-1"}"#,
            payload: #"{"iss":"https://issuer.example"}"#))

        XCTAssertNil(sdjwt.issuerDid)
    }

    func testSdJwtStoredItemAnswersTheSameAsItsCredential() throws {
        let sdjwt = SDJWT.parse(raw: IssuerDidTests.credential(
            header: #"{"alg":"ES256","typ":"dc+sd-jwt-did","kid":"did:omn:issuer?versionId=1#assert"}"#,
            payload: #"{"iss":"https://issuer.example"}"#))
        let item = SdJwtCredentialItem(id: "id",
                                       format: .sdJwtVc,
                                       configurationId: "config",
                                       kid: "pin",
                                       credentialIdentifier: nil,
                                       sdjwt: sdjwt)

        XCTAssertEqual(item.issuerDid, sdjwt.issuerDid)
    }

    // MARK: - Both formats

    /// The point of the pair: one screen, one expression, whichever format it was handed.
    func testBothFormatsReportTheSameIssuerInTheSameShape() throws {
        let mdoc = try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)
        let sdjwt = SDJWT.parse(raw: IssuerDidTests.credential(
            header: #"{"alg":"ES256","typ":"dc+sd-jwt-did","kid":"did:omn:issuer?versionId=1#assert"}"#,
            payload: #"{"iss":"https://issuer.example"}"#))

        XCTAssertEqual(mdoc.issuerDid, sdjwt.issuerDid)
    }

    // MARK: - Helpers

    private static func credential(header: String, payload: String) -> String {
        return "\(Data(header.utf8).base64URLEncoded).\(Data(payload.utf8).base64URLEncoded).sig~"
    }

    /// An `IssuerSigned` that is structurally complete but names no signing key.
    private static func unsignedDocument() -> String {
        let timestamp = CBOR.tagged(CBOR.Tag(rawValue: 0), .utf8String("2026-08-11T00:00:00Z"))
        let mso = CBOR.map([
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
        ])
        let issuerAuth = CBOR.array([
            .byteString(CBOR.map([.unsignedInt(1): .negativeInt(6)]).encode()),
            .map([:]),  // neither header carries a kid
            .byteString(CBOR.tagged(CBOR.Tag(rawValue: 24), .byteString(mso.encode())).encode()),
            .byteString([UInt8](repeating: 0, count: 64))
        ])
        let issuerSigned = CBOR.map([
            "issuerAuth": issuerAuth,
            "nameSpaces": .map([:])
        ])
        return Data(issuerSigned.encode()).base64URLEncoded
    }
}
