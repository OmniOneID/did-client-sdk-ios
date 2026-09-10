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
import OrderedCollections
@testable import DIDWalletSDK

/// Decoding a `DeviceRequest` and pairing it with stored documents.
final class MdocProximityRequestTests: XCTestCase
{
    private let namespace = "eu.europa.ec.eudi.pid.1"
    private let docType = "eu.europa.ec.eudi.pid.1"

    private func mdoc() throws -> Mdoc
    {
        return try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)
    }

    private func code(_ element: String) -> String
    {
        return MdocClaimIndex.code(namespace: namespace, elementIdentifier: element)
    }

    /// Builds a `DeviceRequest` the way a reader would.
    private func deviceRequest(version: String = "1.0",
                               requests: [(docType: String, items: [(String, Bool)])],
                               withReaderAuth: Bool = false,
                               withUnknownKeys: Bool = false) -> [UInt8]
    {
        var docRequests: [CBOR] = []
        for request in requests
        {
            var elements: [(CBOR, CBOR)] = []
            for item in request.items
            {
                elements.append((.utf8String(item.0), .boolean(item.1)))
            }
            let dataElements = CBOR.map(.init(uniqueKeysWithValues: elements))

            var itemsRequestFields: [(CBOR, CBOR)] = [
                (.utf8String("docType"), .utf8String(request.docType)),
                (.utf8String("nameSpaces"),
                 .map(.init(uniqueKeysWithValues: [(CBOR.utf8String(namespace), dataElements)])))
            ]
            if withUnknownKeys
            {
                itemsRequestFields.append((.utf8String("requestInfo"), [:]))
            }
            let itemsRequest = CBOR.map(.init(uniqueKeysWithValues: itemsRequestFields))

            var docRequestFields: [(CBOR, CBOR)] = [
                (.utf8String("itemsRequest"),
                 .tagged(CBOR.Tag(rawValue: 24), .byteString(itemsRequest.encode())))
            ]
            if withReaderAuth
            {
                // Present, and deliberately not read.
                docRequestFields.append((.utf8String("readerAuth"),
                                         .array([.byteString([0x01]), [:], .null,
                                                 .byteString([0x02])])))
            }
            docRequests.append(.map(.init(uniqueKeysWithValues: docRequestFields)))
        }

        var top: [(CBOR, CBOR)] = [
            (.utf8String("version"), .utf8String(version)),
            (.utf8String("docRequests"), .array(docRequests))
        ]
        if withUnknownKeys
        {
            top.append((.utf8String("deviceRequestInfo"), [:]))
        }
        return CBOR.map(.init(uniqueKeysWithValues: top)).encode()
    }

    private func assertThrows(_ expression: @autoclosure () throws -> Any,
                              code expected: String,
                              file: StaticString = #filePath,
                              line: UInt = #line)
    {
        XCTAssertThrowsError(try expression(), file: file, line: line)
        { error in
            guard let walletError = error as? WalletCoreError else {
                return XCTFail("not a WalletCoreError: \(error)", file: file, line: line)
            }
            XCTAssertEqual(walletError.code, expected, file: file, line: line)
        }
    }

    // MARK: - Decoding

    func testDecodesDocTypeAndElementsInRequestOrder() throws
    {
        let bytes = deviceRequest(requests: [(docType, [("family_name", false),
                                                        ("portrait", true)])])

        let decoded = try MdocDeviceRequestDecoder.decode(bytes)

        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded[0].index, 0)
        XCTAssertEqual(decoded[0].docType, docType)
        XCTAssertEqual(decoded[0].elements,
                       [MdocRequestedElement(namespace: namespace,
                                             elementIdentifier: "family_name",
                                             intentToRetain: false),
                        MdocRequestedElement(namespace: namespace,
                                             elementIdentifier: "portrait",
                                             intentToRetain: true)])
    }

    /// A DIS reader sends `"1.1"` as soon as it includes `deviceRequestInfo`, and unknown keys are
    /// to be tolerated rather than rejected. Neither may stop the request being read.
    func testAcceptsNewerVersionUnknownKeysAndReaderAuth() throws
    {
        let bytes = deviceRequest(version: "1.1",
                                  requests: [(docType, [("given_name", false)])],
                                  withReaderAuth: true,
                                  withUnknownKeys: true)

        let decoded = try MdocDeviceRequestDecoder.decode(bytes)

        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded[0].elements.map { $0.elementIdentifier }, ["given_name"])
    }

    func testIndexesEveryDocRequestIncludingRepeatedDocTypes() throws
    {
        let bytes = deviceRequest(requests: [(docType, [("given_name", false)]),
                                             (docType, [("family_name", true)])])

        let decoded = try MdocDeviceRequestDecoder.decode(bytes)

        XCTAssertEqual(decoded.map { $0.index }, [0, 1])
        XCTAssertEqual(decoded.map { $0.docType }, [docType, docType])
    }

    func testRejectsMalformedRequest() throws
    {
        assertThrows(try MdocDeviceRequestDecoder.decode(CBOR.utf8String("nope").encode()),
                     code: "MSDKWLT05620")

        // itemsRequest has to be embedded CBOR: the reader hashed those bytes.
        let untagged = CBOR.map(.init(uniqueKeysWithValues: [
            (CBOR.utf8String("docRequests"),
             CBOR.array([.map(.init(uniqueKeysWithValues: [(CBOR.utf8String("itemsRequest"),
                                                            CBOR.byteString([0x01]))]))]))
        ])).encode()
        assertThrows(try MdocDeviceRequestDecoder.decode(untagged), code: "MSDKWLT05620")
    }

    // MARK: - Matching

    func testSplitsHeldAndUnheldElements() throws
    {
        let decoded = try MdocDeviceRequestDecoder.decode(
            deviceRequest(requests: [(docType, [("family_name", false),
                                                ("not_an_element", true),
                                                ("given_name", true)])]))

        let matched = try MdocRequestMatcher.match(
            docRequests: decoded,
            candidates: [.init(credentialId: "cred-1", mdoc: try mdoc())])

        XCTAssertEqual(matched.count, 1)
        XCTAssertEqual(matched[0].credentialId, "cred-1")
        XCTAssertEqual(matched[0].claimCodes, [code("family_name"), code("given_name")])
        XCTAssertEqual(matched[0].missing, [code("not_an_element")])
    }

    /// The map covers what was asked for, held or not — the consent screen shows both lists.
    func testIntentToRetainCoversClaimCodesAndMissing() throws
    {
        let decoded = try MdocDeviceRequestDecoder.decode(
            deviceRequest(requests: [(docType, [("family_name", false),
                                                ("not_an_element", true)])]))

        let matched = try MdocRequestMatcher.match(
            docRequests: decoded,
            candidates: [.init(credentialId: "cred-1", mdoc: try mdoc())])

        XCTAssertEqual(matched[0].intentToRetain[code("family_name")], false)
        XCTAssertEqual(matched[0].intentToRetain[code("not_an_element")], true)
        XCTAssertEqual(Set(matched[0].intentToRetain.keys),
                       Set(matched[0].claimCodes + matched[0].missing))
    }

    func testDocumentThatFillsNothingIsNotACandidate() throws
    {
        let decoded = try MdocDeviceRequestDecoder.decode(
            deviceRequest(requests: [(docType, [("not_an_element", false)])]))

        assertThrows(try MdocRequestMatcher.match(
            docRequests: decoded,
            candidates: [.init(credentialId: "cred-1", mdoc: try mdoc())]),
                     code: "MSDKWLT05600")
    }

    func testDocumentOfAnotherTypeIsNotACandidate() throws
    {
        let decoded = try MdocDeviceRequestDecoder.decode(
            deviceRequest(requests: [("org.iso.18013.5.1.mDL", [("family_name", false)])]))

        assertThrows(try MdocRequestMatcher.match(
            docRequests: decoded,
            candidates: [.init(credentialId: "cred-1", mdoc: try mdoc())]),
                     code: "MSDKWLT05600")
    }

    /// A request nothing can answer drops out; the indices of the ones that survive still point at
    /// the request the app sent.
    func testUnanswerableRequestDropsOutAndIndicesSurvive() throws
    {
        let decoded = try MdocDeviceRequestDecoder.decode(
            deviceRequest(requests: [("org.iso.18013.5.1.mDL", [("family_name", false)]),
                                     (docType, [("given_name", false)])]))

        let matched = try MdocRequestMatcher.match(
            docRequests: decoded,
            candidates: [.init(credentialId: "cred-1", mdoc: try mdoc())])

        XCTAssertEqual(matched.count, 1)
        XCTAssertEqual(matched[0].docRequestIndex, 1)
    }

    func testSortsByRequestIndexThenCredentialId() throws
    {
        let decoded = try MdocDeviceRequestDecoder.decode(
            deviceRequest(requests: [(docType, [("given_name", false)]),
                                     (docType, [("family_name", false)])]))

        let matched = try MdocRequestMatcher.match(
            docRequests: decoded,
            candidates: [.init(credentialId: "cred-b", mdoc: try mdoc()),
                         .init(credentialId: "cred-a", mdoc: try mdoc())])

        XCTAssertEqual(matched.map { "\($0.docRequestIndex)/\($0.credentialId)" },
                       ["0/cred-a", "0/cred-b", "1/cred-a", "1/cred-b"])
    }

    /// The same document can answer two different requests — that is the case `docRequestIndex`
    /// exists for, since `(docType, credentialId)` cannot tell the two apart.
    func testSameDocumentAnswersTwoRequestsWithDifferentElements() throws
    {
        let decoded = try MdocDeviceRequestDecoder.decode(
            deviceRequest(requests: [(docType, [("given_name", false)]),
                                     (docType, [("family_name", true)])]))

        let matched = try MdocRequestMatcher.match(
            docRequests: decoded,
            candidates: [.init(credentialId: "cred-1", mdoc: try mdoc())])

        XCTAssertEqual(matched.count, 2)
        XCTAssertEqual(matched[0].claimCodes, [code("given_name")])
        XCTAssertEqual(matched[1].claimCodes, [code("family_name")])
        XCTAssertEqual(Set(matched.map { $0.credentialId }), ["cred-1"])
    }
}
