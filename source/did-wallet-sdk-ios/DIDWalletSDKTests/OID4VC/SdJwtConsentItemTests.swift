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

/// The SD-JWT consent list, which a wallet screen is drawn from.
///
/// What is pinned here is that the list agrees with the two things it has to agree with: the codes
/// matching produces, and the disclosures presenting resolves. An app that walked the disclosures
/// itself would be a third answer to the same question.
final class SdJwtConsentItemTests: XCTestCase {

    private func b64url(_ text: String) -> String {
        return Data(text.utf8).base64URLEncoded
    }

    private func digest(_ disclosure: String) -> String {
        return Data(disclosure.utf8).sha256().base64URLEncoded
    }

    /// `nationality` in the clear, `address` selectively disclosable, and `street_address` nested
    /// inside it.
    private func nestedSDJWT() -> (raw: String, address: String, street: String) {
        let street = b64url(#"["s2","street_address","Sesame 1"]"#)
        let address = b64url("[\"s1\",\"address\",{\"_sd\":[\"\(digest(street))\"]}]")
        let header = b64url(#"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#)
        let payload = b64url("""
        {"vct":"https://credentials.example/identity","iss":"https://issuer.example",\
        "nationality":"KR","_sd_alg":"sha-256","_sd":["\(digest(address))"]}
        """)
        return (raw: "\(header).\(payload).sig~\(address)~\(street)", address: address, street: street)
    }

    // MARK: - The list

    func testNamesEveryConsentableClaim() throws {
        let sdjwt = SDJWT.parse(raw: nestedSDJWT().raw)

        let items = try sdjwt.consentItems()

        XCTAssertEqual(Set(items.map { $0.code }),
                       ["address", "address.street_address", "nationality"])
        XCTAssertEqual(items.first { $0.code == "address.street_address" }?.claimName,
                       "street_address")
    }

    // MARK: - Order

    /// The list follows the credential, the way `Mdoc.consentItems` follows the order the issuer
    /// signed its elements in. `nestedSDJWT` writes `address` then `street_address`.
    func testOrderFollowsTheIssuersDisclosures() throws {
        let sdjwt = SDJWT.parse(raw: nestedSDJWT().raw)

        let disclosed = try sdjwt.consentItems()
            .filter { $0.isSelectivelyDisclosable }
            .map { $0.code }

        XCTAssertEqual(disclosed, ["address", "address.street_address"])
    }

    /// Reversing the disclosures reverses the list -- code order would not move at all, which is
    /// what tells the two orderings apart.
    func testADifferentDisclosureOrderIsADifferentList() throws {
        let fixture = nestedSDJWT()
        let reversed = SDJWT(credentialJwt: SDJWT.parse(raw: fixture.raw).credentialJwt,
                             disclosures: SDJWT.parse(raw: fixture.raw).disclosures.reversed())

        let disclosed = try reversed.consentItems()
            .filter { $0.isSelectivelyDisclosable }
            .map { $0.code }

        XCTAssertEqual(disclosed, ["address.street_address", "address"])
    }

    /// A nested claim sits at its own disclosure, not at the parent's -- the parent is in its
    /// `disclosures` too, and taking that position would stack the two rows together.
    func testANestedClaimSitsAtItsOwnDisclosure() throws {
        let street = b64url(#"["s2","street_address","Sesame 1"]"#)
        let address = b64url("[\"s1\",\"address\",{\"_sd\":[\"\(digest(street))\"]}]")
        let email = b64url(#"["s3","email","a@b.c"]"#)
        let header = b64url(#"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#)
        let payload = b64url("""
        {"vct":"https://vct.a","iss":"https://issuer.example","_sd_alg":"sha-256",\
        "_sd":["\(digest(address))","\(digest(email))"]}
        """)
        // The issuer put `email` between the parent and the nested child.
        let sdjwt = SDJWT.parse(raw: "\(header).\(payload).sig~\(address)~\(email)~\(street)")

        XCTAssertEqual(try sdjwt.consentItems().map { $0.code },
                       ["address", "email", "address.street_address"])
    }

    /// A claim in the clear has no disclosure and so no position. It goes last rather than being
    /// given one it does not have.
    func testPlaintextClaimsComeAfterTheDisclosedOnes() throws {
        let items = try SDJWT.parse(raw: nestedSDJWT().raw).consentItems()

        XCTAssertEqual(items.map { $0.code },
                       ["address", "address.street_address", "nationality"])
        XCTAssertEqual(items.last?.isSelectivelyDisclosable, false)
    }

    /// The consent list and the matcher's codes are one set — that is the whole reason the walk is
    /// shared rather than reimplemented per caller.
    func testTheListMatchesWhatMatchingNames() throws {
        let sdjwt = SDJWT.parse(raw: nestedSDJWT().raw)
        let credential = try SDJWTCredentialAdapter().parse(sdjwt.toString())

        XCTAssertEqual(Set(try sdjwt.consentItems().map { $0.code }),
                       SDJWTCredentialAdapter().allClaimNames(credential))
    }

    func testCarriesTheClaimValues() throws {
        let items = try SDJWT.parse(raw: nestedSDJWT().raw).consentItems()

        XCTAssertEqual(items.first { $0.code == "nationality" }?.value, .string("KR"))
        XCTAssertEqual(items.first { $0.code == "address.street_address" }?.value, .string("Sesame 1"))
    }

    /// A claim the issuer left in the clear reaches the verifier whether or not the holder selects
    /// it. A screen that offered it as a choice would promise something the format cannot deliver.
    func testMarksClaimsThatCannotBeWithheld() throws {
        let items = try SDJWT.parse(raw: nestedSDJWT().raw).consentItems()

        XCTAssertEqual(items.first { $0.code == "nationality" }?.isSelectivelyDisclosable, false)
        XCTAssertEqual(items.first { $0.code == "address" }?.isSelectivelyDisclosable, true)
        XCTAssertEqual(items.first { $0.code == "address.street_address" }?.isSelectivelyDisclosable, true)
    }

    /// A member whose own name contains the code separator collides with the nested path that
    /// looks the same. Presenting either would disclose a claim the holder did not single out.
    func testMarksCollidingClaimsAmbiguous() throws {
        let flat = b64url(#"["s3","address.street_address","Flat"]"#)
        let street = b64url(#"["s2","street_address","Sesame 1"]"#)
        let address = b64url("[\"s1\",\"address\",{\"_sd\":[\"\(digest(street))\"]}]")
        let header = b64url(#"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#)
        let payload = b64url("""
        {"vct":"https://vct.a","iss":"https://issuer.example","_sd_alg":"sha-256",\
        "_sd":["\(digest(address))","\(digest(flat))"]}
        """)
        let sdjwt = SDJWT.parse(raw: "\(header).\(payload).sig~\(address)~\(street)~\(flat)")

        let colliding = try XCTUnwrap(try sdjwt.consentItems().first { $0.code == "address.street_address" })
        XCTAssertTrue(colliding.isAmbiguous)
        XCTAssertThrowsError(try SDJWTPresenter.resolveDisclosures(sdjwt: sdjwt,
                                                                   claimCodes: ["address.street_address"]))
    }

    /// The codes on screen resolve to disclosures — the same codes, through the same index.
    func testConsentCodesResolveToDisclosures() throws {
        let fixture = nestedSDJWT()
        let sdjwt = SDJWT.parse(raw: fixture.raw)
        let street = try XCTUnwrap(try sdjwt.consentItems().first { $0.code == "address.street_address" })

        let resolved = try SDJWTPresenter.resolveDisclosures(sdjwt: sdjwt, claimCodes: [street.code])

        // Reaching the nested claim carries the parent that hides it.
        XCTAssertEqual(Set(resolved.map { $0.getDisclosure() }), [fixture.address, fixture.street])
    }

    func testStoredItemAnswersTheSameAsItsCredential() throws {
        let sdjwt = SDJWT.parse(raw: nestedSDJWT().raw)
        let item = SdJwtCredentialItem(id: "id",
                                       format: .sdJwtVc,
                                       configurationId: "config",
                                       kid: "pin",
                                       credentialIdentifier: nil,
                                       sdjwt: sdjwt)

        XCTAssertEqual(try item.consentItems, try sdjwt.consentItems())
    }

    func testUnreadableIssuerPayloadThrows() {
        let sdjwt = SDJWT.parse(raw: "not.a.jwt~")

        XCTAssertThrowsError(try sdjwt.consentItems())
    }
}
