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
import OrderedCollections
@testable import DIDWalletSDK

/// How the requested items of a proof request are grouped per credential and turned into one
/// sub proof.
///
/// A request may put several items on one attribute — a range is two predicates on the same
/// attribute — so every item has to survive under its own referent key, while the credential value
/// behind them is committed once.
final class ZKPManagerTests: XCTestCase
{
    private let credId = "cred-1"
    private let birth = "org.test.zkp.birth"
    private let score = "org.test.zkp.score"
    private let masterSecret = "12345678901234567890"

    private lazy var values: [String : AttributeValue] = [
        birth: .init(raw: "19900101"),
        score: .init(raw: "80"),
    ]

    // MARK: - Helpers

    private func proofRequest(attributes: [String : String] = [:],
                              predicates: [String : (name: String, pType: String, pValue: Int)] = [:]) throws -> ProofRequest
    {
        let restrictions: [[String : String]] = [["credDefId": "def-1"]]
        let json: [String : Any] = [
            "name": "test",
            "version": "1.0",
            "nonce": "1234567890",
            "requestedAttributes": attributes.mapValues {
                ["name": $0, "restrictions": restrictions]
            },
            "requestedPredicates": predicates.mapValues {
                ["name": $0.name, "pType": $0.pType, "pValue": $0.pValue, "restrictions": restrictions]
            },
        ]
        return try ProofRequest(from: JSONSerialization.data(withJSONObject: json))
    }

    private func selected(_ referentKey: String, name: String, isRevealed: Bool = false) -> UserReferent
    {
        return .init(selectedAttrSubReferent: .init(raw: "",
                                                    credId: credId,
                                                    credDefId: "def-1",
                                                    schemaId: "schema-1"),
                     referentKey: referentKey,
                     referentName: name,
                     isRevealed: isRevealed)
    }

    private func attribute(_ referentKey: String, name: String, isRevealed: Bool) -> ZKPManager.ProveAttribute
    {
        return .init(isRevealed: isRevealed, referentKey: referentKey, attrName: name)
    }

    private func predicate(_ referentKey: String, name: String, _ pType: PredicateType, _ pValue: Int) -> ZKPManager.ProvePredicate
    {
        return .init(referentKey: referentKey,
                     predicate: .init(pType: pType, pValue: pValue, attrName: name))
    }

    private func makeSubProof(_ proveCredential: ZKPManager.ProveCredential) throws -> ZKPManager.SubProofValues
    {
        return try ZKPManager.makeSubProofValues(proveCredential: proveCredential,
                                                 values: values,
                                                 masterSecret: masterSecret,
                                                 subProofIndex: 0)
    }

    private func assertCode(_ expected: String,
                            file: StaticString = #filePath,
                            line: UInt = #line,
                            _ body: () throws -> Void)
    {
        XCTAssertThrowsError(try body(), file: file, line: line) { error in
            XCTAssertEqual((error as? WalletCoreError)?.code, expected, "\(error)", file: file, line: line)
        }
    }

    // MARK: - Grouping per credential

    /// E5a: a range is two predicates on one attribute; both must reach the credential.
    func testTwoPredicatesOnOneAttributeAreBothKept() throws
    {
        let request = try proofRequest(predicates: [
            "predicateReferent1": (birth, "GE", 19000101),
            "predicateReferent2": (birth, "LE", 20000101),
        ])

        let (_, proveCredentials) = try ZKPManager.getProveCredentials(
            proofRequest: request,
            selectedReferents: [selected("predicateReferent1", name: birth),
                                selected("predicateReferent2", name: birth)])

        let provePredicates = try XCTUnwrap(proveCredentials[credId]).provePredicates
        XCTAssertEqual(Set(provePredicates.keys), ["predicateReferent1", "predicateReferent2"])
        XCTAssertEqual(provePredicates["predicateReferent1"]?.predicate.pType, .GE)
        XCTAssertEqual(provePredicates["predicateReferent2"]?.predicate.pType, .LE)
    }

    func testTwoAttributesOnOneAttributeNameAreBothKept() throws
    {
        let request = try proofRequest(attributes: [
            "attributeReferent1": birth,
            "attributeReferent2": birth,
        ])

        let (_, proveCredentials) = try ZKPManager.getProveCredentials(
            proofRequest: request,
            selectedReferents: [selected("attributeReferent1", name: birth, isRevealed: true),
                                selected("attributeReferent2", name: birth, isRevealed: true)])

        let proveAttributes = try XCTUnwrap(proveCredentials[credId]).proveAttributes
        XCTAssertEqual(Set(proveAttributes.keys), ["attributeReferent1", "attributeReferent2"])
        XCTAssertEqual(proveAttributes["attributeReferent1"]?.attrName, birth)
    }

    func testPredicateSelectedUnderAnotherAttributeNameIsRejected() throws
    {
        let request = try proofRequest(predicates: ["predicateReferent1": (birth, "GE", 19000101)])

        assertCode("MSDKWLT04603") {
            _ = try ZKPManager.getProveCredentials(proofRequest: request,
                                                   selectedReferents: [selected("predicateReferent1", name: score)])
        }
    }

    // MARK: - One sub proof

    func testRangeYieldsOnePredicateProofPerReferentOverOneHiddenValue() throws
    {
        let subProof = try makeSubProof(.init(provePredicates: [
            "predicateReferent1": predicate("predicateReferent1", name: birth, .GE, 19000101),
            "predicateReferent2": predicate("predicateReferent2", name: birth, .LE, 20000101),
        ]))

        XCTAssertEqual(Set(subProof.predicateAttrs.keys), ["predicateReferent1", "predicateReferent2"])
        XCTAssertEqual(subProof.predicates.map(\.pType), [.GE, .LE])
        XCTAssertEqual(subProof.predicates.map(\.attrName), [birth, birth])
        XCTAssertEqual(subProof.credValues.attrValues.count, 3, "master secret, birth and score once each")
        XCTAssertEqual(subProof.credValues.attrValues[birth]?.type, .hidden)
        XCTAssertEqual(subProof.credValues.attrValues[ZKPConstants.masterSecretKey]?.type, .hidden)
        XCTAssertTrue(subProof.revealedAttrNames.isEmpty)
    }

    func testUnrevealedAttributeAndPredicateShareOneHiddenValue() throws
    {
        let subProof = try makeSubProof(.init(
            proveAttributes: ["attributeReferent1": attribute("attributeReferent1", name: birth, isRevealed: false)],
            provePredicates: ["predicateReferent1": predicate("predicateReferent1", name: birth, .GE, 19000101)]))

        XCTAssertEqual(Array(subProof.unrevealedAttrs.keys), ["attributeReferent1"])
        XCTAssertEqual(Array(subProof.predicateAttrs.keys), ["predicateReferent1"])
        XCTAssertEqual(subProof.credValues.attrValues[birth]?.type, .hidden)
    }

    func testTwoRevealedReferentsOnOneAttributeRevealItOnce() throws
    {
        let subProof = try makeSubProof(.init(proveAttributes: [
            "attributeReferent1": attribute("attributeReferent1", name: birth, isRevealed: true),
            "attributeReferent2": attribute("attributeReferent2", name: birth, isRevealed: true),
        ]))

        XCTAssertEqual(Set(subProof.revealedAttrs.keys), ["attributeReferent1", "attributeReferent2"])
        XCTAssertEqual(subProof.revealedAttrs["attributeReferent2"]?.raw, "19900101")
        XCTAssertEqual(subProof.revealedAttrNames, [birth])
        XCTAssertEqual(subProof.credValues.attrValues[birth]?.type, .known)
        XCTAssertEqual(subProof.credValues.attrValues[score]?.type, .hidden)
    }

    /// A predicate is proven over a hidden value; it cannot sit on an attribute the holder reveals.
    func testPredicateOnRevealedAttributeIsRejected() throws
    {
        assertCode("MSDKWLT04603") {
            _ = try makeSubProof(.init(
                proveAttributes: ["attributeReferent1": attribute("attributeReferent1", name: birth, isRevealed: true)],
                provePredicates: ["predicateReferent1": predicate("predicateReferent1", name: birth, .GE, 19000101)]))
        }
    }

    func testRevealedAndUnrevealedReferentsOnOneAttributeAreRejected() throws
    {
        assertCode("MSDKWLT04602") {
            _ = try makeSubProof(.init(proveAttributes: [
                "attributeReferent1": attribute("attributeReferent1", name: birth, isRevealed: true),
                "attributeReferent2": attribute("attributeReferent2", name: birth, isRevealed: false),
            ]))
        }
    }

    func testPredicateOnAttributeMissingFromCredentialIsRejected() throws
    {
        assertCode("MSDKWLT04603") {
            _ = try makeSubProof(.init(provePredicates: [
                "predicateReferent1": predicate("predicateReferent1", name: "org.test.zkp.missing", .GE, 1),
            ]))
        }
    }
}
