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

/// The token a holder signs to revoke a credential, and the request around it.
///
/// The issuer verifies the signing input as received and reads the claims by their exact names, so
/// what these tests pin is the wire shape: header members, claim names in snake case, the lifetime,
/// and that the signature covers exactly the first two segments.
final class CredentialRevocationTokenTests: XCTestCase
{
    private let holderDid = "did:omn:holder"
    private let kid = "did:omn:holder?versionId=3#pin"
    private let nonce = "8qvJQO7TjZlE5M0wL8OaGA"
    private let status = StatusListReference(uri: "https://issuer.example.com/status-lists/1", idx: 42)
    private let issuedAt = Date(timeIntervalSince1970: 1_791_937_200)

    /// A 65-byte compact signature (`v‖r‖s`) whose `r‖s` is recognisable.
    private let compactSignature = Data([0x1b] + [UInt8](repeating: 0xab, count: 64))

    private func makeToken(onSign: (Data) -> Void = { _ in }) throws -> String
    {
        return try CredentialRevocationToken.create(holderDid: holderDid,
                                                    kid: kid,
                                                    nonce: nonce,
                                                    status: status,
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

    func testHeaderNamesTheAlgorithmTypeAndSigningKey() throws
    {
        let header = try json(segments(try makeToken())[0])

        XCTAssertEqual(header["alg"] as? String, "ES256")
        XCTAssertEqual(header["typ"] as? String, "opendid-credential-revocation+jwt")
        XCTAssertEqual(header["kid"] as? String, kid)
        XCTAssertNil(header["jwk"], "the issuer resolves the key from the DID Document, not the header")
        XCTAssertEqual(header.count, 3)
    }

    func testPayloadCarriesTheRevocationClaimsUnderTheirWireNames() throws
    {
        let payload = try json(segments(try makeToken())[1])

        XCTAssertEqual(payload["iss"] as? String, holderDid)
        XCTAssertEqual(payload["iat"] as? Int, 1_791_937_200)
        XCTAssertEqual(payload["nonce"] as? String, nonce)

        let credentialStatus = try XCTUnwrap(payload["credential_status"] as? [String: Any])
        let statusList = try XCTUnwrap(credentialStatus["status_list"] as? [String: Any])
        XCTAssertEqual(statusList["uri"] as? String, status.uri)
        XCTAssertEqual(statusList["idx"] as? Int, status.idx)

        XCTAssertEqual(Set(payload.keys), ["iss", "iat", "exp", "nonce", "credential_status"])
    }

    /// The issuer rejects a token living longer than 300 seconds.
    func testTokenExpiresThreeHundredSecondsAfterIssue() throws
    {
        let payload = try json(segments(try makeToken())[1])

        XCTAssertEqual(payload["exp"] as? Int, 1_791_937_200 + 300)
    }

    /// The key signs the digest of `header.payload` as emitted, and the token carries the 64-byte
    /// `r‖s` JOSE expects, not the key store's 65-byte compact form.
    func testSignatureCoversTheFirstTwoSegmentsAsRAndS() throws
    {
        var signedDigests: [Data] = []
        let token = try makeToken(onSign: { signedDigests.append($0) })
        let parts = segments(token)

        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(signedDigests, [Data("\(parts[0]).\(parts[1])".utf8).sha256()])
        XCTAssertEqual(parts[2], Data(compactSignature.dropFirst()).base64URLEncoded)
    }

    func testSigningFailureIsRaised() throws
    {
        struct SignFailure: Error {}

        XCTAssertThrowsError(try CredentialRevocationToken.create(holderDid: holderDid,
                                                                  kid: kid,
                                                                  nonce: nonce,
                                                                  status: status,
                                                                  signDigest: { _ in throw SignFailure() }))
        { error in
            XCTAssertTrue(error is SignFailure, "unexpected error: \(error)")
        }
    }

    func testRequestBodyCarriesTheTokenAsRevocationToken() throws
    {
        let body = try CredentialRevocationRequest(revocationToken: "a.b.c").toJsonData()
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])

        XCTAssertEqual(object as? [String: String], ["revocation_token": "a.b.c"])
    }

    // MARK: - Issuer metadata

    private func metadata(extra: String) throws -> IssuerMetadataResponse
    {
        return try IssuerMetadataResponse(from: Data("""
        {"credential_issuer":"https://issuer.example.com",
         "credential_endpoint":"https://issuer.example.com/credential",
         "credential_configurations_supported":{}\(extra)}
        """.utf8))
    }

    func testMetadataReadsTheRevocationEndpoint() throws
    {
        let decoded = try metadata(extra: #","nonce_endpoint":"https://issuer.example.com/nonce","credential_revocation_endpoint":"https://issuer.example.com/opendid/credential-lifecycle/v1/revoke""#)

        XCTAssertEqual(decoded.credentialRevocationEndpoint,
                       "https://issuer.example.com/opendid/credential-lifecycle/v1/revoke")
        XCTAssertEqual(decoded.nonceEndpoint, "https://issuer.example.com/nonce")
    }

    /// Metadata from an issuer without the extension still decodes.
    func testMetadataWithoutTheRevocationEndpointStillDecodes() throws
    {
        XCTAssertNil(try metadata(extra: "").credentialRevocationEndpoint)
    }

    // MARK: - Request parameters

    private func assertParameterFailure(_ metadata: IssuerMetadataResponse,
                                        vcId: String = "vc-1",
                                        file: StaticString = #filePath,
                                        line: UInt = #line) async
    {
        do
        {
            try await WalletService(WalletCoreMock()).requestRevokeOID4VC(metadata: metadata,
                                                                          vcId: vcId,
                                                                          passcode: nil)
            XCTFail("expected a parameter failure", file: file, line: line)
        }
        catch let error as WalletSDKError
        {
            XCTAssertEqual(error.code, "MSDKWLT05002", file: file, line: line)
        }
        catch
        {
            XCTFail("unexpected error: \(error)", file: file, line: line)
        }
    }

    func testMissingNonceEndpointIsAParameterFailure() async throws
    {
        await assertParameterFailure(try metadata(extra: #","credential_revocation_endpoint":"https://issuer.example.com/revoke""#))
    }

    func testMissingRevocationEndpointIsAParameterFailure() async throws
    {
        await assertParameterFailure(try metadata(extra: #","nonce_endpoint":"https://issuer.example.com/nonce""#))
    }

    func testEmptyCredentialIdIsAParameterFailure() async throws
    {
        await assertParameterFailure(try metadata(extra: #","nonce_endpoint":"https://issuer.example.com/nonce","credential_revocation_endpoint":"https://issuer.example.com/revoke""#),
                                     vcId: "")
    }
}
