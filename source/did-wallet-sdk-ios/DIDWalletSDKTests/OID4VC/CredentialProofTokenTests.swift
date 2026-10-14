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

/// The key proof a holder attaches to an OID4VCI Credential Request.
///
/// The issuer resolves the signing key from the holder DID Document by `kid`, so what these tests
/// pin is that the header names the key by DID URL and carries no `jwk`, the claims, and that the
/// signature covers exactly the first two segments.
final class CredentialProofTokenTests: XCTestCase
{
    private let kid = "did:omn:holder?versionId=3#pin"
    private let audience = "https://issuer.example.com"
    private let nonce = "8qvJQO7TjZlE5M0wL8OaGA"
    private let issuedAt = Date(timeIntervalSince1970: 1_791_937_200)

    /// A 65-byte compact signature (`v‖r‖s`) whose `r‖s` is recognisable.
    private let compactSignature = Data([0x1b] + [UInt8](repeating: 0xab, count: 64))

    private func makeProof(nonce: String?, onSign: (Data) -> Void = { _ in }) throws -> String
    {
        return try CredentialProofToken.create(kid: kid,
                                               audience: audience,
                                               nonce: nonce,
                                               issuedAt: issuedAt,
                                               signDigest: { digest in
            onSign(digest)
            return self.compactSignature
        })
    }

    private func segments(_ token: String) -> [String]
    {
        return token.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
    }

    private func json(_ segment: String) throws -> [String: Any]
    {
        let data = try XCTUnwrap(segment.base64URLDecoded)
        return try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func testHeaderNamesTheSigningKeyByKidInsteadOfJwk() throws
    {
        let header = try json(segments(try makeProof(nonce: nonce))[0])

        XCTAssertEqual(header["alg"] as? String, "ES256")
        XCTAssertEqual(header["typ"] as? String, "openid4vci-proof+jwt")
        XCTAssertEqual(header["kid"] as? String, kid)
        XCTAssertNil(header["jwk"], "the issuer resolves the key from the DID Document, not the header")
        XCTAssertEqual(header.count, 3)
    }

    func testPayloadCarriesAudienceIssueTimeAndNonce() throws
    {
        let payload = try json(segments(try makeProof(nonce: nonce))[1])

        XCTAssertEqual(payload["aud"] as? String, audience)
        XCTAssertEqual(payload["iat"] as? Int, 1_791_937_200)
        XCTAssertEqual(payload["nonce"] as? String, nonce)
        XCTAssertEqual(Set(payload.keys), ["aud", "iat", "nonce"])
    }

    /// An issuer without a nonce endpoint gets a proof without `nonce`.
    func testPayloadOmitsNonceWhenTheIssuerHasNone() throws
    {
        let payload = try json(segments(try makeProof(nonce: nil))[1])

        XCTAssertNil(payload["nonce"])
        XCTAssertEqual(Set(payload.keys), ["aud", "iat"])
    }

    /// The key signs the digest of `header.payload` as emitted, and the proof carries the 64-byte
    /// `r‖s` JOSE expects, not the key store's 65-byte compact form.
    func testSignatureCoversTheFirstTwoSegmentsAsRAndS() throws
    {
        var signedDigests: [Data] = []
        let proof = try makeProof(nonce: nonce, onSign: { signedDigests.append($0) })
        let parts = segments(proof)

        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(signedDigests, [Data("\(parts[0]).\(parts[1])".utf8).sha256()])
        XCTAssertEqual(parts[2], Data(compactSignature.dropFirst()).base64URLEncoded)
    }

    func testSigningFailureIsRaised() throws
    {
        struct SignFailure: Error {}

        XCTAssertThrowsError(try CredentialProofToken.create(kid: kid,
                                                             audience: audience,
                                                             nonce: nonce,
                                                             signDigest: { _ in throw SignFailure() }))
        { error in
            XCTAssertTrue(error is SignFailure, "unexpected error: \(error)")
        }
    }
}
