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

final class OID4VCITests: XCTestCase {
    
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOffer() throws
    {
        let offerString = """
        {
          "credential_configuration_ids": [
            "UniversityDegree",
            "VerifiableIdSD",
            "VerifiableIdLDP",
            "mDoc",
            "StudentID"
          ],
          "credential_issuer": "http://10.48.17.124:8082",
          "grants": {
            "urn:ietf:params:oauth:grant-type:pre-authorized_code": {
              "pre-authorized_code": "1499bc66-f28c-4c99-972e-2443bc900a92",
              "tx_code": {
                "description": "Please enter the PIN.",
                "input_mode": "numeric",
                "length": 6
              }
            }
          }
        }
        """
        
        let offer : CredentialOfferResponse = try .init(from: offerString)

        XCTAssertEqual(offer.credentialIssuer, "http://10.48.17.124:8082")
        XCTAssertEqual(offer.credentialConfigurationIds,
                       ["UniversityDegree", "VerifiableIdSD", "VerifiableIdLDP", "mDoc", "StudentID"])
        let preAuthorizedCode = try XCTUnwrap(offer.grants.preAuthorizedCode)
        XCTAssertEqual(preAuthorizedCode.preAuthorizedCode, "1499bc66-f28c-4c99-972e-2443bc900a92")
        XCTAssertEqual(preAuthorizedCode.txCode?.inputMode, "numeric")
        XCTAssertEqual(preAuthorizedCode.txCode?.length, 6)
        XCTAssertEqual(preAuthorizedCode.txCode?.description, "Please enter the PIN.")
        XCTAssertNil(offer.grants.authorizationCode)

        // Re-encoding must preserve the offer, so compare the parsed JSON structures — comparing the
        // serialized strings would only assert Foundation's pretty-print formatting ("key" : value).
        let reencoded = try JSONSerialization.jsonObject(
            with: Data(offer.toJson(isPretty: true).utf8)) as? NSDictionary
        let original = try JSONSerialization.jsonObject(
            with: Data(offerString.utf8)) as? NSDictionary
        XCTAssertEqual(reencoded, original)
    }

    // MARK: - JWS (public surface)

    /// Builds a real ES256 JWS with the signer's public key embedded in the header.
    private func makeSignedJWS(privateKey: P256.Signing.PrivateKey,
                               payloadJSON: String) throws -> String
    {
        let header = try JWSHeader(typ: "JWT", jwk: privateKey.publicKey.getPublicKeyJwk())
            .toJsonData().base64URLEncoded
        let payload = Data(payloadJSON.utf8).base64URLEncoded
        let signSource = "\(header).\(payload)"
        let signature = try privateKey.signature(for: Data(signSource.utf8))
        return "\(signSource).\(signature.rawRepresentation.base64URLEncoded)"
    }

    func testJWS_parsesAndVerifies() throws
    {
        let privateKey = P256.Signing.PrivateKey()
        let raw = try makeSignedJWS(privateKey: privateKey,
                                    payloadJSON: #"{"aud":"verifier","nonce":"n"}"#)

        let jws = try JWS(from: raw)

        XCTAssertTrue(try jws.verify())
        let payload = try JSONSerialization.jsonObject(with: try jws.payloadData) as? [String: Any]
        XCTAssertEqual(payload?["aud"] as? String, "verifier")
        XCTAssertEqual(payload?["nonce"] as? String, "n")
    }

    func testJWS_tamperedPayloadFailsVerification() throws
    {
        let privateKey = P256.Signing.PrivateKey()
        let raw = try makeSignedJWS(privateKey: privateKey, payloadJSON: #"{"aud":"verifier"}"#)

        let parts = raw.split(separator: ".").map(String.init)
        let tampered = "\(parts[0]).\(Data(#"{"aud":"attacker"}"#.utf8).base64URLEncoded).\(parts[2])"

        XCTAssertFalse(try JWS(from: tampered).verify())
    }

    func testJWS_malformedThrows() throws
    {
        XCTAssertThrowsError(try JWS(from: "header.payload")) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05102" else {
                return XCTFail("expected invalidJWS, got \(error)")
            }
        }
    }

    // A header carrying only a kid cannot be verified without resolving the signer's DID document.
    func testJWS_missingHeaderKeyThrows() throws
    {
        let header = try JWSHeader(typ: "JWT", kid: "did:omn:issuer#key-1")
            .toJsonData().base64URLEncoded
        let payload = Data(#"{"aud":"verifier"}"#.utf8).base64URLEncoded
        let raw = "\(header).\(payload).\(Data(repeating: 0, count: 64).base64URLEncoded)"

        XCTAssertThrowsError(try JWS(from: raw).verify()) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05402" else {
                return XCTFail("expected missingJWSHeaderKey, got \(error)")
            }
        }
    }

    // MARK: - Issuer list

    // The issuer list is served in camelCase, so it decodes with the default key strategy (no
    // FromSnake). userInitiationUri is optional — issuer-initiated-only issuers omit it.
    func testIssuerList() throws
    {
        let listString = """
        {
          "count": 2,
          "items": [
            {
              "credentialIssuer": "http://issuer.example",
              "credentialIssuerMetadataUri": "http://issuer.example/.well-known/openid-credential-issuer",
              "userInitiationUri": "http://issuer.example/initiate"
            },
            {
              "credentialIssuer": "http://issuer2.example",
              "credentialIssuerMetadataUri": "http://issuer2.example/.well-known/openid-credential-issuer"
            }
          ]
        }
        """

        let list: OID4VCIIssuerList = try .init(from: listString)

        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list.items.count, 2)
        XCTAssertEqual(list.items[0].credentialIssuer, "http://issuer.example")
        XCTAssertEqual(list.items[0].credentialIssuerMetadataUri,
                       "http://issuer.example/.well-known/openid-credential-issuer")
        XCTAssertEqual(list.items[0].userInitiationUri, "http://issuer.example/initiate")
        XCTAssertNil(list.items[1].userInitiationUri)

        // Round-trips through the wire format the server uses.
        let reencoded = try JSONSerialization.jsonObject(
            with: try list.toJsonData()) as? [String: Any]
        let items = try XCTUnwrap(reencoded?["items"] as? [[String: Any]])
        XCTAssertEqual(reencoded?["count"] as? Int, 2)
        XCTAssertEqual(items[0]["credentialIssuerMetadataUri"] as? String,
                       "http://issuer.example/.well-known/openid-credential-issuer")
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
