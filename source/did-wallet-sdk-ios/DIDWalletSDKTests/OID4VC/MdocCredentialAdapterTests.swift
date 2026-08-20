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

/// DCQL matching for mdoc, against the issued PID fixture.
///
/// The claims the wallet holds are real ones, so "every claim gets named" is checked against the 26
/// elements an issuer actually sent rather than a hand-written pair.
final class MdocCredentialAdapterTests: XCTestCase {

    private let namespace = "eu.europa.ec.eudi.pid.1"
    private let docType = "eu.europa.ec.eudi.pid.1"
    private let adapter = MdocCredentialAdapter()

    private func parsed() throws -> ParsedCredential {
        return try adapter.parse(MdocFixtures.pidIssuerSigned)
    }

    private func claimQuery(_ json: String) throws -> DCQLQuery.ClaimQuery {
        return try DCQLQuery.ClaimQuery(from: json)
    }

    /// One mdoc credential query over this fixture's doctype, carrying the given claim constraints.
    private func query(claims: String, claimSets: String? = nil) throws -> DCQLQuery.CredentialQuery {
        let sets = claimSets.map { ", \"claim_sets\": \($0)" } ?? ""
        let dcql = try DCQLQuery(from: """
        {
          "credentials": [
            {
              "id": "pid",
              "format": "mso_mdoc-did",
              "meta": { "doctype_value": "\(docType)" },
              "claims": \(claims)\(sets)
            }
          ]
        }
        """)
        return try XCTUnwrap(dcql.credentials?.first)
    }

    // MARK: - Parsing

    func testParsesClaimsNestedUnderTheirNamespace() throws {
        let credential = try parsed()

        XCTAssertEqual(credential.format, "mso_mdoc-did")
        XCTAssertEqual(credential.getMetadataValue("doctype") as? String, docType)

        // Nested, not flattened: an element name is only unique within its namespace.
        let elements = try XCTUnwrap(credential.allClaims[namespace] as? [String: Any])
        XCTAssertEqual(elements.count, 26)
        XCTAssertEqual(elements["given_name"] as? String, "Raon")
        XCTAssertEqual(elements["birth_date"] as? String, "1990-05-15")
        XCTAssertTrue(elements["portrait"] is Data)
    }

    // MARK: - Metadata

    func testMatchesTheRequestedDocType() throws {
        let credential = try parsed()

        XCTAssertTrue(adapter.matchesMetadata(credential, metadata: [:]))
        XCTAssertTrue(adapter.matchesMetadata(credential, metadata: ["doctype_value": docType]))
        XCTAssertFalse(adapter.matchesMetadata(credential, metadata: ["doctype_value": "org.iso.18013.5.1.mDL"]))
    }

    // MARK: - Claim addressing

    /// OID4VP 1.0 addresses an mdoc element as `path: [namespace, element]`; earlier drafts used
    /// `namespace` + `claim_name`. Both name the same element, so both must produce the same code —
    /// the app compares codes, and a wallet that answered with two spellings would be unusable.
    func testBothClaimSpellingsResolveToTheSameCode() throws {
        let credential = try parsed()
        let expected = MdocClaimIndex.code(namespace: namespace, elementIdentifier: "family_name")

        let byPath = adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["\#(namespace)", "family_name"]}"#)
        ])
        let byNamespace = adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"namespace": "\#(namespace)", "claim_name": "family_name"}"#)
        ])

        XCTAssertEqual(byPath, [expected])
        XCTAssertEqual(byNamespace, [expected])
    }

    func testDoesNotMatchAnElementTheDocumentLacks() throws {
        let credential = try parsed()

        XCTAssertTrue(adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["\#(namespace)", "driving_privileges"]}"#)
        ]).isEmpty)
        XCTAssertTrue(adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["org.iso.18013.5.1", "family_name"]}"#)
        ]).isEmpty)
    }

    /// An mdoc path is exactly two elements. A deeper or shorter one addresses nothing an mdoc has,
    /// and must not be quietly reinterpreted.
    func testIgnoresPathsThatCannotAddressAnMdocElement() throws {
        let credential = try parsed()

        XCTAssertTrue(adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["\#(namespace)"]}"#)
        ]).isEmpty)
        XCTAssertTrue(adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["\#(namespace)", "address", "street"]}"#)
        ]).isEmpty)
    }

    func testAppliesValueConditionsToTheElement() throws {
        let credential = try parsed()

        XCTAssertFalse(adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["\#(namespace)", "issuing_country"], "values": ["KR", "JP"]}"#)
        ]).isEmpty)
        XCTAssertTrue(adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["\#(namespace)", "issuing_country"], "values": ["JP"]}"#)
        ]).isEmpty)
    }

    // MARK: - Naming the whole credential

    /// Most mdoc requests constrain only the doctype, so this is the path that decides what the
    /// holder is actually shown before consenting.
    func testNamesEveryElementWhenTheQueryConstrainsNoClaim() throws {
        let credential = try parsed()

        let names = adapter.allClaimNames(credential)

        XCTAssertEqual(names.count, 26)
        XCTAssertTrue(names.contains(MdocClaimIndex.code(namespace: namespace, elementIdentifier: "portrait")))
        XCTAssertTrue(names.allSatisfy { $0.hasPrefix("\(namespace).") })
    }

    /// The codes matching produces and the codes the index resolves are one set, not two that
    /// happen to agree today.
    func testMatchedCodesAreTheIndexesCodes() throws {
        let credential = try parsed()
        let mdoc = try XCTUnwrap(credential.getNativeCredentialAs(Mdoc.self))
        let index = MdocClaimIndex.build(mdoc: mdoc)

        XCTAssertEqual(adapter.allClaimNames(credential), index.consentItemCodes)

        let matched = adapter.extractMatchingClaims(credential, claimQueries: [
            try claimQuery(#"{"path": ["\#(namespace)", "given_name"]}"#)
        ])
        let code = try XCTUnwrap(matched.first)
        let entry = try XCTUnwrap(index.entry(for: code))
        XCTAssertEqual(entry.namespace, namespace)
        XCTAssertEqual(entry.elementIdentifier, "given_name")
        XCTAssertFalse(entry.isAmbiguous)
    }

    func testIndexDoesNotResolveACodeTheDocumentDoesNotHave() throws {
        let mdoc = try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)
        let index = MdocClaimIndex.build(mdoc: mdoc)

        XCTAssertNil(index.entry(for: "given_name"))
        XCTAssertNil(index.entry(for: "\(namespace).driving_privileges"))
    }

    // MARK: - Trusted authorities

    /// These documents are signed under a DID and carry no certificate chain, so no authority type
    /// OID4VP defines can be checked against one. Excluding the credential is the safe answer;
    /// presenting it would claim an authority nobody verified.
    func testACredentialWithNoChainCannotSatisfyATrustedAuthority() throws {
        let credential = try parsed()

        XCTAssertTrue(adapter.matchesTrustedAuthorities(credential, trustedAuthorities: []))
        XCTAssertFalse(adapter.matchesTrustedAuthorities(credential, trustedAuthorities: [
            DCQLQuery.TrustedAuthority(type: "x509_san_dns", values: ["issuer.example"])
        ]))
    }

    // MARK: - Through the matcher

    func testEligibleClaimNamesResolvesAWholeCredentialQuery() throws {
        let credential = try parsed()
        let query = try DCQLQuery(from: """
        {
          "credentials": [
            {
              "id": "pid",
              "format": "mso_mdoc-did",
              "meta": { "doctype_value": "\(docType)" }
            }
          ]
        }
        """)

        let names = DCQLCredentialMatcher.eligibleClaimNames(query: query.credentials![0],
                                                             credential: credential)

        XCTAssertEqual(names?.count, 26)
    }

    func testEligibleClaimNamesRejectsAnotherDocType() throws {
        let credential = try parsed()
        let query = try DCQLQuery(from: """
        {
          "credentials": [
            {
              "id": "mdl",
              "format": "mso_mdoc-did",
              "meta": { "doctype_value": "org.iso.18013.5.1.mDL" }
            }
          ]
        }
        """)

        XCTAssertNil(DCQLCredentialMatcher.eligibleClaimNames(query: query.credentials![0],
                                                              credential: credential))
    }

    /// The spelling a verifier happens to use must not change what leaves the wallet. Matching once
    /// dropped the `namespace` + `claim_name` pair for having no path, which read as "this query
    /// constrains no claim" and named all 26 elements — a request for two.
    func testEligibleClaimNamesHonoursTheOlderMdocClaimSpelling() throws {
        let credential = try parsed()
        let expected: Set<String> = [
            MdocClaimIndex.code(namespace: namespace, elementIdentifier: "family_name"),
            MdocClaimIndex.code(namespace: namespace, elementIdentifier: "given_name")
        ]

        let byNamespace = try query(claims: """
        [ { "namespace": "\(namespace)", "claim_name": "family_name" },
          { "namespace": "\(namespace)", "claim_name": "given_name" } ]
        """)
        let byPath = try query(claims: """
        [ { "path": ["\(namespace)", "family_name"] },
          { "path": ["\(namespace)", "given_name"] } ]
        """)

        XCTAssertEqual(DCQLCredentialMatcher.eligibleClaimNames(query: byNamespace, credential: credential),
                       expected)
        XCTAssertEqual(DCQLCredentialMatcher.eligibleClaimNames(query: byPath, credential: credential),
                       expected)
    }

    /// A claim query the credential cannot satisfy makes it ineligible. Read as "no constraint", the
    /// same query would have made every credential eligible and disclosed all of it.
    func testEligibleClaimNamesRejectsAnElementTheDocumentLacks() throws {
        let credential = try parsed()
        let query = try query(claims: """
        [ { "namespace": "\(namespace)", "claim_name": "driving_privileges" } ]
        """)

        XCTAssertNil(DCQLCredentialMatcher.eligibleClaimNames(query: query, credential: credential))
    }

    func testEligibleClaimNamesAppliesValueConditionsInTheOlderSpelling() throws {
        let credential = try parsed()
        let met = try query(claims: """
        [ { "namespace": "\(namespace)", "claim_name": "given_name", "values": ["Raon"] } ]
        """)
        let unmet = try query(claims: """
        [ { "namespace": "\(namespace)", "claim_name": "given_name", "values": ["NotRaon"] } ]
        """)

        XCTAssertEqual(DCQLCredentialMatcher.eligibleClaimNames(query: met, credential: credential),
                       [MdocClaimIndex.code(namespace: namespace, elementIdentifier: "given_name")])
        XCTAssertNil(DCQLCredentialMatcher.eligibleClaimNames(query: unmet, credential: credential))
    }

    /// `claim_sets` resolves its ids against the same claim queries, so the older spelling has to
    /// hold up there too.
    func testEligibleClaimNamesHonoursTheOlderSpellingInAClaimSet() throws {
        let credential = try parsed()
        let query = try query(claims: """
        [ { "id": "a", "namespace": "\(namespace)", "claim_name": "family_name" },
          { "id": "b", "namespace": "\(namespace)", "claim_name": "given_name" } ]
        """, claimSets: #"[["a", "b"]]"#)

        XCTAssertEqual(DCQLCredentialMatcher.eligibleClaimNames(query: query, credential: credential),
                       [MdocClaimIndex.code(namespace: namespace, elementIdentifier: "family_name"),
                        MdocClaimIndex.code(namespace: namespace, elementIdentifier: "given_name")])
    }

    // MARK: - Query validation

    /// Validation runs before matching, so a query the validator rejects never reaches the adapter.
    /// The older `namespace` + `claim_name` spelling has to survive it for the adapter's support of
    /// that spelling to mean anything.
    func testValidatorAcceptsTheOlderMdocClaimSpelling() throws {
        let query = try DCQLQuery(from: """
        {
          "credentials": [
            {
              "id": "pid",
              "format": "mso_mdoc-did",
              "meta": { "doctype_value": "\(docType)" },
              "claims": [ { "namespace": "\(namespace)", "claim_name": "family_name" } ]
            }
          ]
        }
        """)

        XCTAssertTrue(DCQLQueryValidator.validate(query).isValid())
    }

    func testValidatorRejectsAnMdocPathThatCannotAddressAnElement() throws {
        let query = try DCQLQuery(from: """
        {
          "credentials": [
            {
              "id": "pid",
              "format": "mso_mdoc-did",
              "claims": [ { "path": ["\(namespace)", "address", "street"] } ]
            }
          ]
        }
        """)

        XCTAssertFalse(DCQLQueryValidator.validate(query).isValid())
    }

    /// The same shortcut must not leak into JSON-based formats, where a claim really does need a
    /// path.
    func testValidatorStillRequiresAPathForSDJWT() throws {
        let query = try DCQLQuery(from: """
        {
          "credentials": [
            {
              "id": "pid",
              "format": "dc+sd-jwt-did",
              "claims": [ { "namespace": "\(namespace)", "claim_name": "family_name" } ]
            }
          ]
        }
        """)

        XCTAssertFalse(DCQLQueryValidator.validate(query).isValid())
    }

    func testRegistryFindsTheAdapterByFormatAndByContent() throws {
        let registry = CredentialAdapterRegistry.shared

        XCTAssertTrue(registry.isFormatSupported("mso_mdoc-did"))
        XCTAssertTrue(registry.findAdapter("mso_mdoc-did") is MdocCredentialAdapter)
        XCTAssertTrue(registry.detectAdapter(MdocFixtures.pidIssuerSigned) is MdocCredentialAdapter)
    }
}
