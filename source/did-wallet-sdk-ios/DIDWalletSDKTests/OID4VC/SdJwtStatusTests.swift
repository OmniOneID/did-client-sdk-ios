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

/// Where an SD-JWT says its revocation status is published.
///
/// The same reference an mdoc carries in its MSO, written as a JSON claim instead of CBOR. Both
/// formats answer with `StatusListReference`, so an app reads one shape whichever it holds; what
/// these tests pin is that the two agree on when the answer is `nil` and when it is a failure.
final class SdJwtStatusTests: XCTestCase {

    private func b64url(_ text: String) -> String {
        return Data(text.utf8).base64URLEncoded
    }

    /// An issuer JWT whose payload carries the given claims verbatim.
    private func credential(claims: String) -> SDJWT {
        let header = b64url(#"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#)
        let payload = b64url("{\"vct\":\"https://credentials.example/identity\"\(claims)}")
        return SDJWT.parse(raw: "\(header).\(payload).sig~")
    }

    /// The reference as the issuer publishes it.
    func testStatusListReferenceIsReadFromThePayload() throws {
        let sdjwt = credential(
            claims: #","status":{"status_list":{"idx":7,"uri":"https://issuer.example/status-lists/2"}}"#)

        XCTAssertEqual(try sdjwt.status(),
                       StatusListReference(uri: "https://issuer.example/status-lists/2", idx: 7))
    }

    /// `status` is optional in SD-JWT VC, and credentials issued before the issuer published status
    /// lists have none. Reading one has to stay an ordinary answer rather than an error.
    func testCredentialWithoutStatusReportsNoReference() throws {
        XCTAssertNil(try credential(claims: "").status())
    }

    /// Written wrongly is not the same as not written. A `nil` here would read as "no status to
    /// check" and let a revocable credential past the check the issuer asked for.
    func testMalformedStatusIsRejectedRatherThanReadAsAbsent() {
        let malformed = [
            #","status":"revoked""#,                                            // status is not an object
            #","status":{"status_list":"https://issuer.example/2#7"}"#,         // entry is not an object
            #","status":{"status_list":{"idx":7}}"#,                            // no uri
            #","status":{"status_list":{"uri":"https://issuer.example/2"}}"#,   // no idx
            #","status":{"status_list":{"idx":-1,"uri":"https://issuer.example/2"}}"#,  // idx is negative
            #","status":{"status_list":{"idx":"7","uri":"https://issuer.example/2"}}"#, // idx is text
            #","status":{"status_list":{"idx":7,"uri":""}}"#                    // uri names nothing
        ]
        for claims in malformed {
            XCTAssertThrowsError(try credential(claims: claims).status(), claims)
        }
    }

    /// A status mechanism this SDK does not read leaves the credential with no status list, which
    /// is not a credential it failed to understand.
    func testStatusWithoutAStatusListIsNotAFailure() throws {
        let sdjwt = credential(
            claims: #","status":{"identifier_list":{"id":"x","uri":"https://issuer.example/ids/1"}}"#)

        XCTAssertNil(try sdjwt.status())
    }

    /// The stored item and the credential inside it answer the same, so a screen drawn from a
    /// wallet listing does not have to reach through to `sdjwt` first.
    func testStoredItemAnswersTheSameAsItsCredential() throws {
        let sdjwt = credential(
            claims: #","status":{"status_list":{"idx":7,"uri":"https://issuer.example/status-lists/2"}}"#)
        let item = SdJwtCredentialItem(id: "id",
                                       format: .sdJwtVc,
                                       configurationId: "config",
                                       kid: "kid",
                                       credentialIdentifier: nil,
                                       sdjwt: sdjwt)

        XCTAssertEqual(try item.status, try sdjwt.status())
    }

    /// A payload that is not readable at all fails, rather than passing for a credential without a
    /// status.
    func testUnreadablePayloadThrows() {
        XCTAssertThrowsError(try SDJWT.parse(raw: "not-a-jwt~").status())
    }
}
