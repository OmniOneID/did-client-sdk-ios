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
              "format": "dc+sd-jwt",
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
                "format": "dc+sd-jwt",
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
        XCTAssertEqual(claimInfos.first?.claimCodes, [], "claimCodes empty = disclose all claims")
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

    // MARK: - OID4VPProtocol.findEligibleSubmittables

    func testFindEligibleSubmittables_success() throws {
        let vc = try makeCredential()
        let request = try authRequest(schemaID: matchingSchemaID)

        let infos = try OID4VPProtocol.findEligibleSubmittables(
            authRequest: request,
            credentials: [vc]
        )

        XCTAssertEqual(infos["student_id"]?.first?.credentialId, vc.id)
    }

    func testFindEligibleSubmittables_noEligibleThrows() throws {
        let vc = try makeCredential()
        let request = try authRequest(schemaID: "http://other.example/schema?name=none")

        XCTAssertThrowsError(
            try OID4VPProtocol.findEligibleSubmittables(authRequest: request, credentials: [vc])
        ) { error in
            guard case OID4VPError.noEligibleCredentials = error else {
                return XCTFail("expected noEligibleCredentials, got \(error)")
            }
        }
    }
}
