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

final class OID4VPTests: XCTestCase {

    // credentialSchema.id of the shared `vcJson` fixture (defined in VCManagerTests.swift).
    private let matchingSchemaID = "http://192.168.3.130:8090/tas/api/v1/download/schema?name=mdl"

    private func makeCredential() throws -> VerifiableCredential {
        try VerifiableCredential(from: vcJson)
    }

    private func dcqlQuery(schemaID: String, queryID: String = "student_id") throws -> DCQLQuery {
        let json = """
        {
          "credentials": [
            {
              "id": "\(queryID)",
              "format": "dc+sd-jwt-did",
              "meta": { "credential_schema_id_values": ["\(schemaID)"] }
            }
          ]
        }
        """
        return try DCQLQuery(from: json)
    }

    private func authRequest(schemaID: String) throws -> AuthorizationRequest {
        let json = """
        {
          "response_uri": "https://verifier.example/response",
          "nonce": "test-nonce",
          "state": "test-state",
          "client_id": "verifier",
          "response_type": "vp_token",
          "response_mode": "direct_post",
          "client_metadata": {},
          "iat": 1700000000,
          "dcql_query": {
            "credentials": [
              {
                "id": "student_id",
                "format": "dc+sd-jwt-did",
                "meta": { "credential_schema_id_values": ["\(schemaID)"] }
              }
            ]
          }
        }
        """
        return try AuthorizationRequest(from: json)
    }

    // MARK: - DCQLCredentialMatcher.getMatchedMetadata

    func testGetMatchedMetadata_schemaMatch() throws {
        let vc = try makeCredential()
        let query = try dcqlQuery(schemaID: matchingSchemaID)

        let infos = DCQLCredentialMatcher.getMatchedMetadata(
            credentials: [vc],
            queries: query.credentials!
        )

        XCTAssertEqual(infos.count, 1)
        let claimInfos = try XCTUnwrap(infos["student_id"])
        XCTAssertEqual(claimInfos.count, 1)
        XCTAssertEqual(claimInfos.first?.credentialId, vc.id)
        XCTAssertEqual(claimInfos.first?.claimCodes,
                       vc.credentialSubject.claims.map { $0.code }.sorted(),
                       "a query constraining no claim names them all, never an empty list")
    }

    func testGetMatchedMetadata_emptyClaimsArrayNamesEveryClaim() throws {
        let vc = try makeCredential()
        let query = try DCQLQuery(from: """
        {
          "credentials": [
            {
              "id": "student_id",
              "format": "dc+sd-jwt-did",
              "meta": { "credential_schema_id_values": ["\(matchingSchemaID)"] },
              "claims": []
            }
          ]
        }
        """)

        let infos = DCQLCredentialMatcher.getMatchedMetadata(
            credentials: [vc],
            queries: query.credentials!
        )

        XCTAssertEqual(infos["student_id"]?.first?.claimCodes,
                       vc.credentialSubject.claims.map { $0.code }.sorted(),
                       "an empty claims array constrains nothing, same as an absent one")
    }

    func testGetMatchedMetadata_noMatch() throws {
        let vc = try makeCredential()
        let query = try dcqlQuery(schemaID: "http://other.example/schema?name=none")

        let infos = DCQLCredentialMatcher.getMatchedMetadata(
            credentials: [vc],
            queries: query.credentials!
        )

        XCTAssertTrue(infos.isEmpty)
    }

    // MARK: - DCQLCredentialMatcher.matchCredentials

    func testFindEligibleSubmittables_success() throws {
        let vc = try makeCredential()
        let request = try authRequest(schemaID: matchingSchemaID)

        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: request,
            credentials: [vc]
        )

        XCTAssertEqual(infos["student_id"]?.first?.credentialId, vc.id)
    }

    func testFindEligibleSubmittables_noEligibleThrows() throws {
        let vc = try makeCredential()
        let request = try authRequest(schemaID: "http://other.example/schema?name=none")

        XCTAssertThrowsError(
            try DCQLCredentialMatcher.matchCredentials(authRequest: request, credentials: [vc])
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05502" else {
                return XCTFail("expected noEligibleCredentials, got \(error)")
            }
        }
    }

    // MARK: - Claim-level matching

    private func dcqlQueryWithClaims(claimsJSON: String, schemaID: String) throws -> DCQLQuery {
        let json = """
        {
          "credentials": [
            {
              "id": "student_id",
              "format": "dc+sd-jwt-did",
              "meta": { "credential_schema_id_values": ["\(schemaID)"] },
              "claims": \(claimsJSON)
            }
          ]
        }
        """
        return try DCQLQuery(from: json)
    }

    func testGetMatchedMetadata_claimLevelSelectsCodes() throws {
        let vc = try makeCredential()
        let query = try dcqlQueryWithClaims(
            claimsJSON: #"[ { "path": ["org.iso.18013.5.family_name"] } ]"#,
            schemaID: matchingSchemaID
        )

        let infos = DCQLCredentialMatcher.getMatchedMetadata(
            credentials: [vc],
            queries: query.credentials!
        )

        let claimInfos = try XCTUnwrap(infos["student_id"])
        XCTAssertEqual(claimInfos.first?.claimCodes, ["org.iso.18013.5.family_name"],
                       "only the requested claim code should be disclosed")
    }

    func testGetMatchedMetadata_claimValueConditionExcludes() throws {
        // The fixture's family_name is "김"; require "박" so the condition fails.
        let vc = try makeCredential()
        let query = try dcqlQueryWithClaims(
            claimsJSON: #"[ { "path": ["org.iso.18013.5.family_name"], "value": "박" } ]"#,
            schemaID: matchingSchemaID
        )

        let infos = DCQLCredentialMatcher.getMatchedMetadata(
            credentials: [vc],
            queries: query.credentials!
        )

        XCTAssertTrue(infos.isEmpty,
                      "a credential whose claim value fails the condition must be excluded")
    }

    func testGetMatchedMetadata_minConditionTypeMismatchExcludes() throws {
        // family_name is a string ("김"); a numeric `min` bound is incomparable. An unsatisfiable
        // constraint must exclude the credential, not silently match (regression: default was true).
        let vc = try makeCredential()
        let query = try dcqlQueryWithClaims(
            claimsJSON: #"[ { "path": ["org.iso.18013.5.family_name"], "min": 18 } ]"#,
            schemaID: matchingSchemaID
        )

        let infos = DCQLCredentialMatcher.getMatchedMetadata(
            credentials: [vc],
            queries: query.credentials!
        )

        XCTAssertTrue(infos.isEmpty,
                      "a numeric min against a string claim must exclude the credential")
    }

    // MARK: - Multi-format (SD-JWT adapter + DCQL advanced) matching

    private func b64url(_ s: String) -> String {
        Data(s.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// SD-JWT digests the US-ASCII bytes of the base64url disclosure, not the JSON it decodes to.
    private func sdDigest(_ disclosure: String) -> String {
        Data(SHA256.hash(data: Data(disclosure.utf8))).base64URLEncoded
    }

    /// Builds a parseable (unsigned) SD-JWT compact string for matching tests.
    ///
    /// The payload lists every disclosure's digest in `_sd`, the way an issuer does — that is what
    /// lets a claim be located from the payload rather than by disclosure name alone.
    private func makeSDJWT(vct: String, iss: String,
                           disclosures: [(salt: String, name: String, value: String)]) -> String {
        let header = b64url(#"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#)
        let discs = disclosures.map { b64url("[\"\($0.salt)\",\"\($0.name)\",\"\($0.value)\"]") }
        let sdList = discs.map { "\"\(sdDigest($0))\"" }.joined(separator: ",")
        let payload = b64url("{\"vct\":\"\(vct)\",\"iss\":\"\(iss)\",\"_sd_alg\":\"sha-256\",\"_sd\":[\(sdList)]}")
        let jwt = "\(header).\(payload).sig"
        return ([jwt] + discs).joined(separator: "~")
    }

    /// Wraps a raw SD-JWT compact string into the wallet item type the SD-JWT matching overload takes.
    private func makeSdJwtItem(id: String, rawSdJwt: String) -> SdJwtCredentialItem {
        SdJwtCredentialItem(id: id, format: .sdJwtVc, configurationId: "", kid: "bio",
                            credentialIdentifier: nil, sdjwt: SDJWT.parse(raw: rawSdJwt))
    }

    private func authRequest(dcqlCredentialsJSON: String, clientId: String = "verifier") throws -> AuthorizationRequest {
        let json = """
        {
          "response_uri": "https://verifier.example/response",
          "nonce": "test-nonce", "state": "test-state",
          "client_id": "\(clientId)",
          "response_type": "vp_token", "response_mode": "direct_post",
          "client_metadata": {}, "iat": 1700000000,
          "dcql_query": { "credentials": \(dcqlCredentialsJSON) }
        }
        """
        return try AuthorizationRequest(from: json)
    }

    func testSDJWT_rawCredentialMatch() throws {
        let vct = "https://credentials.example/identity"
        let sdjwt = makeSDJWT(vct: vct, iss: "https://issuer.example",
                              disclosures: [("s1", "family_name", "Kim"), ("s2", "given_name", "Raon")])
        let creds = """
        [ { "id": "id_card", "format": "dc+sd-jwt-did",
            "meta": { "vct_values": ["\(vct)"] },
            "claims": [ { "path": ["family_name"] } ] } ]
        """
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            sdJwtCredentials: [makeSdJwtItem(id: "cred-1", rawSdJwt: sdjwt)]
        )
        let cis = try XCTUnwrap(infos["id_card"])
        XCTAssertEqual(cis.first?.credentialId, "cred-1")
        XCTAssertEqual(cis.first?.claimCodes, ["family_name"])
    }

    func testSDJWT_vctMismatchExcluded() throws {
        let sdjwt = makeSDJWT(vct: "https://credentials.example/identity", iss: "https://issuer.example",
                              disclosures: [("s1", "family_name", "Kim")])
        let creds = #"[ { "id": "id_card", "format": "dc+sd-jwt-did", "meta": { "vct_values": ["https://other/vct"] } } ]"#
        XCTAssertThrowsError(try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: sdjwt)]
        )) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05502" else { return XCTFail("got \(error)") }
        }
    }

    // One stored credential the adapter cannot parse must not make the rest of the wallet
    // unpresentable: the good credential still matches.
    func testSDJWT_unparseableStoredCredentialIsSkipped() throws {
        let vct = "https://credentials.example/identity"
        let good = makeSDJWT(vct: vct, iss: "https://issuer.example",
                             disclosures: [("s1", "family_name", "Kim")])
        // No `typ` in the header — SDJWTCredentialAdapter.parse rejects it.
        let broken = "\(b64url(#"{"alg":"ES256"}"#)).\(b64url(#"{"vct":"x"}"#)).sig~"

        let creds = """
        [ { "id": "id_card", "format": "dc+sd-jwt-did",
            "meta": { "vct_values": ["\(vct)"] },
            "claims": [ { "path": ["family_name"] } ] } ]
        """
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            sdJwtCredentials: [makeSdJwtItem(id: "broken", rawSdJwt: broken),
                               makeSdJwtItem(id: "cred-1", rawSdJwt: good)]
        )

        let cis = try XCTUnwrap(infos["id_card"])
        XCTAssertEqual(cis.map(\.credentialId), ["cred-1"])
    }

    // `meta` is optional in DCQL: a query that states no schema constraint still has to match, with
    // `claims` alone deciding.
    func testOpendidVc_queryWithoutMetaMatchesOnClaims() throws {
        let vc = try makeCredential()
        let claimCode = try XCTUnwrap(vc.credentialSubject.claims.first?.code)

        let matching = """
        [ { "id": "student_id", "format": "opendid_vc",
            "claims": [ { "path": ["\(claimCode)"] } ] } ]
        """
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: matching),
            credentials: [vc]
        )
        XCTAssertEqual(infos["student_id"]?.first?.credentialId, vc.id)
        XCTAssertEqual(infos["student_id"]?.first?.claimCodes, [claimCode])

        // A claim the credential does not carry still excludes it.
        let notMatching = """
        [ { "id": "student_id", "format": "opendid_vc",
            "claims": [ { "path": ["claim_that_does_not_exist"] } ] } ]
        """
        XCTAssertThrowsError(try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: notMatching),
            credentials: [vc]
        )) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05502" else {
                return XCTFail("expected noMatchedCredentials, got \(error)")
            }
        }
    }

    func testOpendidVc_credentialsOverload() throws {
        let vc = try makeCredential()
        let creds = """
        [ { "id": "student_id", "format": "opendid_vc",
            "meta": { "credential_schema_id_values": ["\(matchingSchemaID)"] } } ]
        """
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            credentials: [vc]
        )
        XCTAssertEqual(infos["student_id"]?.first?.credentialId, vc.id)
    }

    func testSDJWT_trustedAuthorities() throws {
        let iss = "https://issuer.example"
        let sdjwt = makeSDJWT(vct: "v", iss: iss, disclosures: [("s", "family_name", "Kim")])

        let okCreds = """
        [ { "id": "q", "format": "dc+sd-jwt-did",
            "trusted_authorities": [ { "type": "x509_san_dns", "values": ["\(iss)"] } ] } ]
        """
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: okCreds),
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: sdjwt)]
        )
        XCTAssertNotNil(infos["q"], "matching trusted authority should be eligible")

        let badCreds = """
        [ { "id": "q", "format": "dc+sd-jwt-did",
            "trusted_authorities": [ { "type": "x509_san_dns", "values": ["https://evil.example"] } ] } ]
        """
        XCTAssertThrowsError(try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: badCreds),
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: sdjwt)]
        )) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05502" else { return XCTFail("got \(error)") }
        }
    }

    func testSDJWT_claimSets_firstSatisfiableWins() throws {
        // Spec form (OID4VP 1.0 §6.4): claim_sets is an array of arrays of claim ids.
        // First option ["ph"] requires 'phone' (absent) → second ["fn"] requires 'family_name' (present).
        let vct = "https://credentials.example/identity"
        let sdjwt = makeSDJWT(vct: vct, iss: "https://issuer.example",
                              disclosures: [("s1", "family_name", "Kim"), ("s2", "email", "a@b.c")])
        let creds = """
        [ { "id": "q", "format": "dc+sd-jwt-did", "meta": { "vct_values": ["\(vct)"] },
            "claims": [ { "id": "fn", "path": ["family_name"] }, { "id": "ph", "path": ["phone"] } ],
            "claim_sets": [ ["ph"], ["fn"] ] } ]
        """
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: sdjwt)]
        )
        XCTAssertEqual(infos["q"]?.first?.claimCodes, ["family_name"])
    }

    // A query that constrains no claim asks for the whole credential. Reporting that as an empty
    // list left the app unable to tell it from a claim-level selection, so matching names every
    // disclosable claim — nested ones included, by their DCQL path.
    func testSDJWT_unconstrainedQueryNamesEveryDisclosableClaim() throws {
        let creds = #"[ { "id": "q", "format": "dc+sd-jwt-did" } ]"#
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: makeNestedSDJWT().raw)]
        )

        XCTAssertEqual(infos["q"]?.first?.claimCodes,
                       ["address", "address.street_address", "nationality"],
                       "every claim the credential can disclose must be named")
    }

    // ...and those names must present the whole credential: every disclosure it holds.
    func testSDJWT_unconstrainedClaimCodesPresentEveryDisclosure() throws {
        let fixture = makeNestedSDJWT()
        let sdjwt = SDJWT.parse(raw: fixture.raw)
        let creds = #"[ { "id": "q", "format": "dc+sd-jwt-did" } ]"#
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: fixture.raw)]
        )
        let claimCodes = try XCTUnwrap(infos["q"]?.first?.claimCodes)

        let segments = try vpToken(sdjwt: sdjwt, claimCodes: claimCodes)
            .split(separator: "~").map(String.init)
        XCTAssertTrue(segments.contains(fixture.address), "parent disclosure missing")
        XCTAssertTrue(segments.contains(fixture.street), "nested disclosure missing")
        // Issuer JWT + every disclosure the credential holds + KB-JWT: neither more nor less.
        XCTAssertEqual(segments.count, sdjwt.disclosures.count + 2,
                       "the named set must disclose every disclosure and no other segment")
    }

    // A disclosure the issuer never referenced from `_sd` cannot be reached by walking the payload,
    // but it is still presentable by name — so "all claims" has to include it.
    func testSDJWT_unreferencedDisclosureIsNamed() throws {
        let header = b64url(#"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#)
        let payload = b64url(#"{"vct":"https://vct.a","iss":"https://issuer.example","_sd_alg":"sha-256"}"#)
        let orphan = b64url(#"["s1","family_name","Kim"]"#)

        let creds = #"[ { "id": "q", "format": "dc+sd-jwt-did" } ]"#
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: try authRequest(dcqlCredentialsJSON: creds),
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: "\(header).\(payload).sig~\(orphan)")]
        )

        XCTAssertEqual(infos["q"]?.first?.claimCodes, ["family_name"])
    }

    // MARK: - credential_sets satisfaction gate

    /// Builds an SD-JWT matching-request whose `dcql_query` carries both `credentials` and the given
    /// raw `credential_sets` JSON.
    private func authRequest(credentialsJSON: String, credentialSetsJSON: String) throws -> AuthorizationRequest {
        let json = """
        {
          "response_uri": "https://verifier.example/response",
          "nonce": "test-nonce", "state": "test-state",
          "client_id": "verifier",
          "response_type": "vp_token", "response_mode": "direct_post",
          "client_metadata": {}, "iat": 1700000000,
          "dcql_query": { "credentials": \(credentialsJSON), "credential_sets": \(credentialSetsJSON) }
        }
        """
        return try AuthorizationRequest(from: json)
    }

    func testCredentialSets_requiredOptionSatisfied_passes() throws {
        let sdjwt = makeSDJWT(vct: "https://vct.a", iss: "https://issuer.example",
                              disclosures: [("s", "family_name", "Kim")])
        let request = try authRequest(
            credentialsJSON: #"[ { "id": "q1", "format": "dc+sd-jwt-did" } ]"#,
            credentialSetsJSON: #"[ { "options": [["q1"]] } ]"#
        )
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: request,
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: sdjwt)]
        )
        XCTAssertNotNil(infos["q1"], "a required credential_set whose option matches must pass")
    }

    func testCredentialSets_requiredUnsatisfied_throws() throws {
        // q1 matches (no constraints); q2 requires a mismatching vct, so it cannot match. A required
        // set that needs q2 has no satisfiable option → throw.
        let sdjwt = makeSDJWT(vct: "https://vct.a", iss: "https://issuer.example",
                              disclosures: [("s", "family_name", "Kim")])
        let request = try authRequest(
            credentialsJSON: """
            [ { "id": "q1", "format": "dc+sd-jwt-did" },
              { "id": "q2", "format": "dc+sd-jwt-did", "meta": { "vct_values": ["https://vct.b"] } } ]
            """,
            credentialSetsJSON: #"[ { "options": [["q2"]] } ]"#
        )
        XCTAssertThrowsError(try DCQLCredentialMatcher.matchCredentials(
            authRequest: request,
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: sdjwt)]
        )) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05503" else {
                return XCTFail("expected credentialSetsNotSatisfied, got \(error)")
            }
        }
    }

    func testCredentialSets_optionalUnsatisfied_doesNotThrow() throws {
        // An optional (required:false) set that cannot be satisfied must not gate matching.
        let sdjwt = makeSDJWT(vct: "https://vct.a", iss: "https://issuer.example",
                              disclosures: [("s", "family_name", "Kim")])
        let request = try authRequest(
            credentialsJSON: """
            [ { "id": "q1", "format": "dc+sd-jwt-did" },
              { "id": "q2", "format": "dc+sd-jwt-did", "meta": { "vct_values": ["https://vct.b"] } } ]
            """,
            credentialSetsJSON: #"[ { "options": [["q2"]], "required": false } ]"#
        )
        let infos = try DCQLCredentialMatcher.matchCredentials(
            authRequest: request,
            sdJwtCredentials: [makeSdJwtItem(id: "c1", rawSdJwt: sdjwt)]
        )
        XCTAssertNotNil(infos["q1"], "an unsatisfiable optional set must not block eligible matches")
    }

    // MARK: - direct_post.jwt response encryption

    /// Builds an authorization request whose `client_metadata` advertises the given verifier
    /// encryption key (as an EC/P-256 `use:enc` JWK) and `enc` values, in `direct_post.jwt` mode.
    private func encryptedAuthRequest(
        keyJWK: JWK,
        encValues: String = #""A256GCM""#,
        alg: String = "ECDH-ES"
    ) throws -> AuthorizationRequest {
        let json = """
        {
          "response_uri": "https://verifier.example/response",
          "nonce": "test-nonce",
          "state": "test-state",
          "client_id": "verifier",
          "response_type": "vp_token",
          "response_mode": "direct_post.jwt",
          "iat": 1700000000,
          "client_metadata": {
            "encrypted_response_enc_values_supported": [\(encValues)],
            "jwks": { "keys": [
              { "kty": "EC", "crv": "P-256", "use": "enc", "alg": "\(alg)",
                "x": "\(keyJWK.x)", "y": "\(keyJWK.y)" }
            ] }
          },
          "dcql_query": { "credentials": [] }
        }
        """
        return try AuthorizationRequest(from: json)
    }

    // parseResponseEncryption picks the EC/P-256 enc key and the preferred A256GCM enc; encrypting a
    // VPTokenSubmission with them and decrypting with the verifier key must round-trip the JSON.
    func testDirectPostJWT_parseAndEncryptRoundTrips() throws {
        let verifierPrivateKey = P256.KeyAgreement.PrivateKey()
        let verifierJWK = verifierPrivateKey.publicKey.getPublicKeyJwk()

        let request = try encryptedAuthRequest(keyJWK: verifierJWK)

        let (jwk, enc) = try OID4VPResponseUtil.parseResponseEncryption(from: request.clientMetadata)
        XCTAssertEqual(enc, .a256GCM)
        XCTAssertEqual(jwk.x, verifierJWK.x)
        XCTAssertEqual(jwk.y, verifierJWK.y)

        // Reproduce submitVpToken's assembly and verify the verifier can recover {vp_token, state}.
        let vpToken: [String: [AnyJSON]] = ["student_id": [.string("ey.presentation.token")]]
        let payload = try VPTokenSubmission(vpToken: vpToken, state: request.state).toJsonData()
        let compactJWE = try JWE.encrypt(plaintext: payload, to: jwk, enc: enc)

        let decrypted = try JWE(compact: compactJWE).decrypt(using: verifierPrivateKey)
        let recovered = try JSONSerialization.jsonObject(with: decrypted) as? [String: Any]
        XCTAssertEqual(recovered?["state"] as? String, "test-state")
        XCTAssertEqual((recovered?["vp_token"] as? [String: Any])?["student_id"] as? [String],
                       ["ey.presentation.token"])
    }

    // A128GCM is selected when it is the only supported enc value.
    func testDirectPostJWT_selectsA128GCM() throws {
        let verifierJWK = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()
        let request = try encryptedAuthRequest(keyJWK: verifierJWK, encValues: #""A128GCM""#)

        let (_, enc) = try OID4VPResponseUtil.parseResponseEncryption(from: request.clientMetadata)
        XCTAssertEqual(enc, .a128GCM)
    }

    // An enc value we cannot produce (e.g. A192GCM) is rejected.
    func testDirectPostJWT_unsupportedEncThrows() throws {
        let verifierJWK = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()
        let request = try encryptedAuthRequest(keyJWK: verifierJWK, encValues: #""A192GCM""#)

        XCTAssertThrowsError(
            try OID4VPResponseUtil.parseResponseEncryption(from: request.clientMetadata)
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05507" else {
                return XCTFail("expected unsupportedResponseEncryption, got \(error)")
            }
        }
    }

    // A W3C (ldp_vp) presentation must reach the wire as a JSON *object*. Serializing the VP to a
    // string before it enters vp_token makes toFormData() escape it a second time, which the
    // verifier rejects. Asserting on the encoded form body covers the exact place that broke.
    func testVpToken_w3cElementEncodesAsObject() throws {
        let vp: AnyJSON = .object([
            "@context": .array([.string("https://www.w3.org/ns/credentials/v2")]),
            "type": .array([.string("VerifiablePresentation")]),
            "holder": .string("did:omn:holder")
        ])

        let body = try VPTokenSubmission(vpToken: ["student_id": [vp]], state: "s").toFormData()
        let decoded = String(data: body, encoding: .utf8)!.removingPercentEncoding!

        XCTAssertTrue(decoded.contains(#""@context""#), "vp_token lost the VP object: \(decoded)")
        XCTAssertFalse(decoded.contains(#"\""#), "VP was double-encoded as a string: \(decoded)")
    }

    // The SD-JWT element stays a compact string on the wire — the regression guard for the fix above.
    func testVpToken_sdJwtElementEncodesAsString() throws {
        let body = try VPTokenSubmission(
            vpToken: ["student_id": [.string("ey.presentation.token")]],
            state: "s"
        ).toFormData()
        let decoded = String(data: body, encoding: .utf8)!.removingPercentEncoding!

        XCTAssertTrue(decoded.contains(#""ey.presentation.token""#), "unexpected form body: \(decoded)")
    }

    // A key-wrapping alg (ECDH-ES+A256KW) is rejected — only ECDH-ES Direct is supported.
    func testDirectPostJWT_keyWrappingAlgThrows() throws {
        let verifierJWK = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()
        let request = try encryptedAuthRequest(keyJWK: verifierJWK, alg: "ECDH-ES+A256KW")

        XCTAssertThrowsError(
            try OID4VPResponseUtil.parseResponseEncryption(from: request.clientMetadata)
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05507" else {
                return XCTFail("expected unsupportedResponseEncryption, got \(error)")
            }
        }
    }

    // direct_post.jwt with no verifier key in client_metadata is a hard error.
    func testDirectPostJWT_missingKeyThrows() throws {
        let json = """
        {
          "response_uri": "https://verifier.example/response",
          "nonce": "n", "state": "s", "client_id": "verifier",
          "response_type": "vp_token", "response_mode": "direct_post.jwt",
          "iat": 1700000000, "client_metadata": {},
          "dcql_query": { "credentials": [] }
        }
        """
        let request = try AuthorizationRequest(from: json)
        XCTAssertThrowsError(
            try OID4VPResponseUtil.parseResponseEncryption(from: request.clientMetadata)
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05506" else {
                return XCTFail("expected missingVerifierEncryptionKey, got \(error)")
            }
        }
    }

    // MARK: - Selection validation (app-narrowed matchedCredentials)

    /// Two required queries (no credential_sets), each matched by one credential requiring one claim.
    private func selectionRequest() throws -> AuthorizationRequest {
        try authRequest(dcqlCredentialsJSON: """
        [ { "id": "id_card", "format": "dc+sd-jwt-did", "claims": [ { "path": ["family_name"] } ] },
          { "id": "license", "format": "dc+sd-jwt-did", "claims": [ { "path": ["number"] } ] } ]
        """)
    }

    private var selectionMatched: [MatchedCredential] {
        [MatchedCredential(queryId: "id_card", credentialId: "cred-1", claimCodes: ["family_name"]),
         MatchedCredential(queryId: "license", credentialId: "cred-2", claimCodes: ["number"])]
    }

    private func assertSelectionThrows(_ selection: [MatchedCredential],
                                       code: String = "MSDKWLT05508",
                                       _ message: String,
                                       file: StaticString = #filePath, line: UInt = #line) throws {
        let request = try selectionRequest()
        XCTAssertThrowsError(
            try DCQLCredentialMatcher.validateSelection(selection,
                                                        against: selectionMatched,
                                                        dcqlQuery: request.dcqlQuery),
            message, file: file, line: line
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == code else {
                return XCTFail("expected \(code), got \(error)", file: file, line: line)
            }
        }
    }

    // The unmodified match result is always presentable.
    func testSelection_unmodifiedPasses() throws {
        let request = try selectionRequest()
        XCTAssertNoThrow(try DCQLCredentialMatcher.validateSelection(selectionMatched,
                                                                    against: selectionMatched,
                                                                    dcqlQuery: request.dcqlQuery))
    }

    // A credential the query never matched must not be presentable by handing it to createVpToken.
    func testSelection_unmatchedCredentialThrows() throws {
        try assertSelectionThrows(
            [MatchedCredential(queryId: "id_card", credentialId: "not-matched", claimCodes: ["family_name"]),
             MatchedCredential(queryId: "license", credentialId: "cred-2", claimCodes: ["number"])],
            "a credential outside the match result was accepted")
    }

    // Same for a query id the request does not declare.
    func testSelection_unknownQueryIdThrows() throws {
        try assertSelectionThrows(
            [MatchedCredential(queryId: "passport", credentialId: "cred-1", claimCodes: ["family_name"])],
            "an undeclared query id was accepted")
    }

    // Presenting one credential twice for a query would reach Core as a duplicate-identifier error.
    func testSelection_duplicateSelectionThrows() throws {
        try assertSelectionThrows(
            [MatchedCredential(queryId: "id_card", credentialId: "cred-1", claimCodes: ["family_name"]),
             MatchedCredential(queryId: "id_card", credentialId: "cred-1", claimCodes: ["family_name"]),
             MatchedCredential(queryId: "license", credentialId: "cred-2", claimCodes: ["number"])],
            "a duplicated credential was accepted")
    }

    // Narrowing claims below what the query requires is rejected locally, not by the verifier.
    func testSelection_claimNarrowedBelowRequiredThrows() throws {
        try assertSelectionThrows(
            [MatchedCredential(queryId: "id_card", credentialId: "cred-1", claimCodes: ["given_name"]),
             MatchedCredential(queryId: "license", credentialId: "cred-2", claimCodes: ["number"])],
            "a selection missing a required claim was accepted")
    }

    // A query naming no claim asks for the credential as a whole, so the claims matching filled in
    // are as required as the ones an explicit `claims` would have named — narrowing them is refused.
    func testSelection_narrowingAnUnconstrainedQueryThrows() throws {
        let request = try authRequest(dcqlCredentialsJSON: """
        [ { "id": "id_card", "format": "dc+sd-jwt-did" } ]
        """)
        let matched = [MatchedCredential(queryId: "id_card", credentialId: "cred-1",
                                         claimCodes: ["family_name", "given_name"])]
        let selection = [MatchedCredential(queryId: "id_card", credentialId: "cred-1",
                                           claimCodes: ["family_name"])]

        XCTAssertThrowsError(
            try DCQLCredentialMatcher.validateSelection(selection,
                                                        against: matched,
                                                        dcqlQuery: request.dcqlQuery),
            "a selection dropping a claim of an unconstrained query was accepted"
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05508" else {
                return XCTFail("expected invalidSelectedCredentials, got \(error)")
            }
        }
    }

    // Matching never returns an empty claim list, so one coming back in cannot be read as full
    // disclosure — presenting everything is expressed by keeping every code matching named.
    func testSelection_emptyClaimCodesThrows() throws {
        try assertSelectionThrows(
            [MatchedCredential(queryId: "id_card", credentialId: "cred-1", claimCodes: []),
             MatchedCredential(queryId: "license", credentialId: "cred-2", claimCodes: ["number"])],
            "an empty claim list was accepted")
    }

    // Codes beyond the matched set are the app's business: the presenter rejects the ones the
    // credential cannot disclose, so the gate only enforces that nothing required went missing.
    func testSelection_extraClaimCodesPass() throws {
        let request = try selectionRequest()
        let selection = [MatchedCredential(queryId: "id_card", credentialId: "cred-1",
                                           claimCodes: ["family_name", "given_name"]),
                         MatchedCredential(queryId: "license", credentialId: "cred-2",
                                           claimCodes: ["number"])]
        XCTAssertNoThrow(try DCQLCredentialMatcher.validateSelection(selection,
                                                                    against: selectionMatched,
                                                                    dcqlQuery: request.dcqlQuery))
    }

    // With no credential_sets every credential query is required, so dropping one is an error.
    func testSelection_droppedRequiredQueryThrows() throws {
        try assertSelectionThrows(
            [MatchedCredential(queryId: "id_card", credentialId: "cred-1", claimCodes: ["family_name"])],
            "a dropped required query was accepted")
    }

    // With credential_sets, dropping a query is fine as long as an option stays satisfied.
    func testSelection_credentialSetsOptionSatisfiedPasses() throws {
        let request = try authRequest(
            credentialsJSON: """
            [ { "id": "id_card", "format": "dc+sd-jwt-did" },
              { "id": "license", "format": "dc+sd-jwt-did" } ]
            """,
            credentialSetsJSON: """
            [ { "id": "identity", "required": true, "options": [ ["id_card"], ["license"] ] } ]
            """)

        let selection = [MatchedCredential(queryId: "id_card", credentialId: "cred-1",
                                           claimCodes: ["family_name"])]
        XCTAssertNoThrow(try DCQLCredentialMatcher.validateSelection(selection,
                                                                    against: selectionMatched,
                                                                    dcqlQuery: request.dcqlQuery))
    }

    // ...and dropping everything a required set needs still fails, with the credential_sets code.
    func testSelection_credentialSetsUnsatisfiedThrows() throws {
        let request = try authRequest(
            credentialsJSON: """
            [ { "id": "id_card", "format": "dc+sd-jwt-did" },
              { "id": "license", "format": "dc+sd-jwt-did" } ]
            """,
            credentialSetsJSON: """
            [ { "id": "both", "required": true, "options": [ ["id_card", "license"] ] } ]
            """)

        let selection = [MatchedCredential(queryId: "id_card", credentialId: "cred-1",
                                           claimCodes: ["family_name"])]
        XCTAssertThrowsError(
            try DCQLCredentialMatcher.validateSelection(selection,
                                                        against: selectionMatched,
                                                        dcqlQuery: request.dcqlQuery)
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05503" else {
                return XCTFail("expected credentialSetsNotSatisfied, got \(error)")
            }
        }
    }

    // MARK: - Presenter and response-mode guards

    // A claim code with no matching disclosure would silently vanish from the presentation.
    func testPresenter_undisclosableClaimThrows() throws {
        let sdjwt = SDJWT.parse(raw: makeSDJWT(vct: "https://credentials.example/identity",
                                               iss: "https://issuer.example",
                                               disclosures: [("s1", "family_name", "Kim")]))
        let holderJwk = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()

        XCTAssertThrowsError(
            try SDJWTPresenter.createVpToken(sdjwt: sdjwt,
                                             claimCodes: ["family_name", "given_name"],
                                             aud: "verifier",
                                             nonce: "n",
                                             holderJwk: holderJwk,
                                             signDigest: { _ in Data(repeating: 0, count: 65) })
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05508" else {
                return XCTFail("expected invalidSelectedCredentials, got \(error)")
            }
        }
    }

    // An empty list once meant "disclose everything". Matching now names every claim instead, so an
    // empty one can only be a caller mistake — presenting it silently would leak the whole
    // credential on what the caller may have meant as "nothing".
    func testPresenter_emptyClaimCodesThrows() throws {
        let sdjwt = SDJWT.parse(raw: makeSDJWT(vct: "https://credentials.example/identity",
                                               iss: "https://issuer.example",
                                               disclosures: [("s1", "family_name", "Kim")]))
        XCTAssertThrowsError(try vpToken(sdjwt: sdjwt, claimCodes: [])) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05508" else {
                return XCTFail("expected invalidSelectedCredentials, got \(error)")
            }
        }
    }

    // The claims that do exist are still presentable.
    func testPresenter_disclosableClaimsSucceed() throws {
        let sdjwt = SDJWT.parse(raw: makeSDJWT(vct: "https://credentials.example/identity",
                                               iss: "https://issuer.example",
                                               disclosures: [("s1", "family_name", "Kim"),
                                                             ("s2", "given_name", "Raon")]))
        let holderJwk = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()

        let token = try SDJWTPresenter.createVpToken(sdjwt: sdjwt,
                                                     claimCodes: ["family_name"],
                                                     aud: "verifier",
                                                     nonce: "n",
                                                     holderJwk: holderJwk,
                                                     signDigest: { _ in Data(repeating: 0, count: 65) })
        XCTAssertEqual(token.split(separator: "~").count, 3, "expected issuer JWT + 1 disclosure + KB-JWT")
    }

    // MARK: - Claim paths, disclosure bytes and JSON scalars

    /// Builds an SD-JWT whose `address` claim is itself selectively disclosable and hides
    /// `street_address` behind a nested `_sd` digest — the shape a DCQL path query targets.
    private func makeNestedSDJWT() -> (raw: String, address: String, street: String) {
        let street = b64url(#"["s2","street_address","Sesame 1"]"#)
        let address = b64url("[\"s1\",\"address\",{\"_sd\":[\"\(sdDigest(street))\"]}]")
        let header = b64url(#"{"alg":"ES256","typ":"dc+sd-jwt-did"}"#)
        let payload = b64url("""
        {"vct":"https://credentials.example/identity","iss":"https://issuer.example",\
        "nationality":"KR","_sd_alg":"sha-256","_sd":["\(sdDigest(address))"]}
        """)
        return (raw: "\(header).\(payload).sig~\(address)~\(street)", address: address, street: street)
    }

    private func vpToken(sdjwt: SDJWT, claimCodes: [String]) throws -> String {
        try SDJWTPresenter.createVpToken(sdjwt: sdjwt,
                                         claimCodes: claimCodes,
                                         aud: "verifier",
                                         nonce: "n",
                                         holderJwk: P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk(),
                                         signDigest: { _ in Data(repeating: 0, count: 65) })
    }

    // A nested path is what matching reports; presenting it needs the parent disclosure as well as
    // the child, or the verifier cannot reach the claim.
    func testPresenter_nestedPathDisclosesParentAndChild() throws {
        let fixture = makeNestedSDJWT()
        let token = try vpToken(sdjwt: SDJWT.parse(raw: fixture.raw),
                                claimCodes: ["address.street_address"])

        let segments = token.split(separator: "~").map(String.init)
        XCTAssertEqual(segments.count, 4, "expected issuer JWT + 2 disclosures + KB-JWT: \(token)")
        XCTAssertTrue(segments.contains(fixture.address), "parent disclosure missing")
        XCTAssertTrue(segments.contains(fixture.street), "child disclosure missing")
    }

    // A claim the issuer left in the clear has no disclosure at all. That is not an error — the
    // verifier already receives it — so the presentation carries no disclosure for it.
    func testPresenter_plaintextClaimNeedsNoDisclosure() throws {
        let token = try vpToken(sdjwt: SDJWT.parse(raw: makeNestedSDJWT().raw),
                                claimCodes: ["nationality"])

        XCTAssertEqual(token.split(separator: "~").count, 2,
                       "expected issuer JWT + KB-JWT and no disclosure: \(token)")
    }

    // A path into a claim the credential does not hold is still rejected.
    func testPresenter_unknownNestedPathThrows() throws {
        let sdjwt = SDJWT.parse(raw: makeNestedSDJWT().raw)

        XCTAssertThrowsError(try vpToken(sdjwt: sdjwt, claimCodes: ["address.country"])) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05508" else {
                return XCTFail("expected invalidSelectedCredentials, got \(error)")
            }
        }
    }

    // The issuer's `_sd` digests are taken over the disclosure bytes as sent. Re-serializing the
    // decoded value would change them, so a parsed disclosure must survive byte-for-byte.
    func testDisclosure_keepsIssuerBytesAndDigest() throws {
        // Spec-style spacing: a re-encode by this SDK's writer would drop the spaces.
        let raw = b64url(#"["s1", "family_name", "Kim"]"#)
        let disclosure = try XCTUnwrap(Disclosure.parse(raw: raw))

        XCTAssertEqual(disclosure.getDisclosure(), raw, "issuer disclosure bytes were not preserved")
        XCTAssertEqual(disclosure.digest(), sdDigest(raw), "digest must hash the base64url disclosure")

        // A disclosure built in code has no issuer form and is serialized on demand.
        let built = Disclosure(salt: "s1", claimName: "family_name", claimValue: .string("Kim"))
        XCTAssertEqual(built.digest(), sdDigest(built.getDisclosure()))
    }

    // JSONSerialization hands back every scalar as NSNumber, and `as? Bool` also succeeds for 0 and
    // 1 — a numeric claim of 0/1 must not turn into a boolean, or no value condition can match it.
    func testAnyJSON_numericZeroAndOneStayNumbers() throws {
        XCTAssertEqual(AnyJSON.fromFoundation(NSNumber(value: 1)), .number(1))
        XCTAssertEqual(AnyJSON.fromFoundation(NSNumber(value: 0)), .number(0))
        XCTAssertEqual(AnyJSON.fromFoundation(NSNumber(value: true)), .bool(true))
        XCTAssertEqual(AnyJSON.fromFoundation(NSNumber(value: false)), .bool(false))

        // The same via the parser the SD-JWT payload actually goes through.
        let parsed = try JSONSerialization.jsonObject(with: Data(#"{"level":1,"active":true}"#.utf8))
        let object = try XCTUnwrap(AnyJSON.fromFoundation(parsed)?.asObject)
        XCTAssertEqual(object["level"], .number(1))
        XCTAssertEqual(object["active"], .bool(true))
    }

    // A claim query on a numeric 0/1 value must match the credential holding it.
    func testClaimMatching_numericOneMeetsValueCondition() throws {
        let payload = try JSONSerialization.jsonObject(with: Data(#"{"level":1}"#.utf8)) as! [String: Any]
        let query = try DCQLQuery(from: #"{"credentials":[{"id":"q","claims":[{"path":["level"],"values":[1]}]}]}"#)
        let claimQuery = try XCTUnwrap(query.credentials?.first?.claims?.first)

        XCTAssertTrue(ClaimMatchingHelper.meetsConditions(claimQuery: claimQuery,
                                                          actualValue: payload["level"]!))
    }

    // Only the POST-based response modes are supported; anything else must not be sent in the clear.
    func testEncodeResponseBody_unsupportedResponseModeThrows() throws {
        let json = """
        {
          "response_uri": "https://verifier.example/response",
          "nonce": "n", "state": "s", "client_id": "verifier",
          "response_type": "vp_token", "response_mode": "fragment",
          "iat": 1700000000, "client_metadata": {},
          "dcql_query": { "credentials": [] }
        }
        """
        let request = try AuthorizationRequest(from: json)
        XCTAssertThrowsError(
            try OID4VPResponseUtil.encodeResponseBody(authRequest: request,
                                                      vpToken: ["id_card": [.string("ey.token")]])
        ) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05509" else {
                return XCTFail("expected unsupportedResponseMode, got \(error)")
            }
        }
    }

    // direct_post still encodes a clear form body.
    func testEncodeResponseBody_directPostEncodesClearForm() throws {
        let request = try authRequest(dcqlCredentialsJSON: #"[ { "id": "id_card", "format": "dc+sd-jwt-did" } ]"#)
        let body = try OID4VPResponseUtil.encodeResponseBody(authRequest: request,
                                                             vpToken: ["id_card": [.string("ey.token")]])
        let decoded = String(data: body, encoding: .utf8)!.removingPercentEncoding!

        XCTAssertTrue(decoded.contains("vp_token="), "unexpected form body: \(decoded)")
        XCTAssertTrue(decoded.contains(#""ey.token""#), "unexpected form body: \(decoded)")
    }
}

/// DCQL grammar validation (OID4VP 1.0 §6). Feeds invalid queries and asserts they are rejected.
final class DCQLQueryValidatorTests: XCTestCase {

    private func validate(_ json: String) throws -> DCQLQueryValidator.ValidationResult {
        DCQLQueryValidator.validate(try DCQLQuery(from: json))
    }

    func testValidQueryPasses() throws {
        let r = try validate(#"{ "credentials": [ { "id": "q1", "format": "dc+sd-jwt-did", "meta": { "vct_values": ["v"] } } ] }"#)
        XCTAssertTrue(r.isValid(), "unexpected errors: \(r.errors)")
    }

    func testEmptyCredentialsRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [] }"#).isValid())
    }

    func testDuplicateCredentialIdRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did" }, { "id": "q", "format": "dc+sd-jwt-did" } ] }"#).isValid())
    }

    func testMissingFormatRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q" } ] }"#).isValid())
    }

    func testNegativePathIndexRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did", "claims": [ { "path": [-1] } ] } ] }"#).isValid())
    }

    func testEmptyValuesRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did", "claims": [ { "path": ["x"], "values": [] } ] } ] }"#).isValid())
    }

    func testClaimSetsWithoutClaimsRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did", "claim_sets": [["a"]] } ] }"#).isValid())
    }

    func testClaimSetsUndefinedIdRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did", "claims": [ { "id": "a", "path": ["x"] } ], "claim_sets": [["b"]] } ] }"#).isValid())
    }

    func testClaimSetsRequireClaimIds() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did", "claims": [ { "path": ["x"] } ], "claim_sets": [["a"]] } ] }"#).isValid())
    }

    func testTrustedAuthorityMissingValuesRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did", "trusted_authorities": [ { "type": "aki" } ] } ] }"#).isValid())
    }

    func testCredentialSetUndefinedReferenceRejected() throws {
        XCTAssertFalse(try validate(#"{ "credentials": [ { "id": "q1", "format": "dc+sd-jwt-did" } ], "credential_sets": [ { "options": [["q2"]] } ] }"#).isValid())
    }

    func testValidClaimSetsPasses() throws {
        let r = try validate(#"{ "credentials": [ { "id": "q", "format": "dc+sd-jwt-did", "claims": [ { "id": "a", "path": ["x"] } ], "claim_sets": [["a"]] } ] }"#)
        XCTAssertTrue(r.isValid(), "unexpected errors: \(r.errors)")
    }
}
