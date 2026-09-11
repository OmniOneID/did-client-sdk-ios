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

/// Checking the holder's selection, and assembling the `DeviceResponse` from it.
final class MdocProximityResponseTests: XCTestCase
{
    private let namespace = "eu.europa.ec.eudi.pid.1"
    private let docType = "eu.europa.ec.eudi.pid.1"

    /// A transcript whose second element carries a reader ephemeral key, so the MAC path is
    /// reachable. Same bytes as the device-authentication vector.
    private let transcript = hexBytes(
        "83d8185858a20063312e30018201d818584ba401022001215820101112131415161718191a1b1c1d1e1f2021" +
        "22232425262728292a2b2c2d2e2f225820303132333435363738393a3b3c3d3e3f404142434445464748494a" +
        "4b4c4d4e4fd818584ba401022001215820505152535455565758595a5b5c5d5e5f606162636465666768696a" +
        "6b6c6d6e6f225820707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8ff6")

    private func mdoc() throws -> Mdoc
    {
        return try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)
    }

    private func code(_ element: String) -> String
    {
        return MdocClaimIndex.code(namespace: namespace, elementIdentifier: element)
    }

    private func requested(index: Int = 0,
                           credentialId: String = "cred-1",
                           codes: [String]) -> MdocRequestedDocument
    {
        return MdocRequestedDocument(docRequestIndex: index,
                                     docType: docType,
                                     credentialId: credentialId,
                                     claimCodes: codes,
                                     intentToRetain: [:],
                                     missing: [])
    }

    /// Key operations with no Secure Enclave behind them.
    private final class StubKeys: MdocDeviceKeyOperations
    {
        var canAgree = true
        /// Credentials whose key does not do ECDH, so one response can carry both methods.
        var cannotAgree: Set<String> = []
        var agreementError: Error?
        /// The `zab` of the shared session-key vector, so the derivation is exercised on real input.
        var sharedSecret = hexBytes("a95137b042ccb44b378c7c0c9182164fc1b54afc9c6e154ca77958ddd681bd34")
        private(set) var agreementCalls: [String] = []
        private(set) var signCalls: [String] = []

        func canKeyAgree(credentialId: String) throws -> Bool
        {
            return canAgree && !cannotAgree.contains(credentialId)
        }

        func keyAgreement(credentialId: String, readerPublicKey: [UInt8]) throws -> [UInt8]
        {
            agreementCalls.append(credentialId)
            if let agreementError { throw agreementError }
            return sharedSecret
        }

        func sign(credentialId: String, digest: Data) throws -> Data
        {
            signCalls.append(credentialId)
            return Data([0x00] + [UInt8](repeating: 0x11, count: 64))
        }
    }

    private struct OtherFailure: Error {}

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

    // MARK: - validate

    func testAcceptsASubsetOfWhatMatched() throws
    {
        let matched = [requested(codes: [code("given_name"), code("family_name")])]
        let selected = [requested(codes: [code("given_name")])]

        XCTAssertNoThrow(try MdocProximityResponseBuilder.validate(selected: selected,
                                                                   against: matched))
    }

    func testRejectsEmptySelection() throws
    {
        assertThrows(try MdocProximityResponseBuilder.validate(
            selected: [], against: [requested(codes: [code("given_name")])]),
                     code: "MSDKWLT05610")
    }

    func testRejectsDocumentThatDidNotMatchTheRequest() throws
    {
        let matched = [requested(index: 0, codes: [code("given_name")])]
        let selected = [requested(index: 1, codes: [code("given_name")])]

        assertThrows(try MdocProximityResponseBuilder.validate(selected: selected,
                                                               against: matched),
                     code: "MSDKWLT05611")
    }

    /// Moving a `missing` element into `claimCodes` is the reason the check is against the match
    /// result rather than the request.
    func testRejectsCodeThatDidNotMatch() throws
    {
        let matched = [requested(codes: [code("given_name")])]
        let selected = [requested(codes: [code("given_name"), code("not_an_element")])]

        assertThrows(try MdocProximityResponseBuilder.validate(selected: selected,
                                                               against: matched),
                     code: "MSDKWLT05611")
    }

    func testRejectsEmptyClaimCodes() throws
    {
        let matched = [requested(codes: [code("given_name")])]
        let selected = [requested(codes: [])]

        assertThrows(try MdocProximityResponseBuilder.validate(selected: selected,
                                                               against: matched),
                     code: "MSDKWLT05612")
    }

    func testRejectsTheSameDocumentTwiceForOneRequest() throws
    {
        let matched = [requested(codes: [code("given_name")])]
        let selected = [requested(codes: [code("given_name")]),
                        requested(codes: [code("given_name")])]

        assertThrows(try MdocProximityResponseBuilder.validate(selected: selected,
                                                               against: matched),
                     code: "MSDKWLT05613")
    }

    /// The one `shall` the response structure carries is that an element may not appear twice in a
    /// namespace, and a repeated code is how that would happen.
    func testRejectsARepeatedClaimCode() throws
    {
        let matched = [requested(codes: [code("given_name")])]
        let selected = [requested(codes: [code("given_name"), code("given_name")])]

        assertThrows(try MdocProximityResponseBuilder.validate(selected: selected,
                                                               against: matched),
                     code: "MSDKWLT05614")
    }

    func testAcceptsOneDocumentAnsweringTwoRequests() throws
    {
        let matched = [requested(index: 0, codes: [code("given_name")]),
                       requested(index: 1, codes: [code("family_name")])]

        XCTAssertNoThrow(try MdocProximityResponseBuilder.validate(selected: matched,
                                                                    against: matched))
    }

    // MARK: - build

    func testBuildsAMacResponseAndReportsTheMethod() throws
    {
        let keys = StubKeys()
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: keys)

        XCTAssertEqual(built.authMethods, ["cred-1": .deviceMac])

        let response = try XCTUnwrap(try CBOR.decode([UInt8](built.response)))
        guard case let .map(fields) = response,
              case let .array(documents)? = fields["documents"]
        else { return XCTFail("DeviceResponse is not a map with documents") }

        XCTAssertEqual(fields["version"], .utf8String("1.0"))
        XCTAssertEqual(fields["status"], .unsignedInt(0))
        XCTAssertEqual(documents.count, 1)

        let deviceAuth = try deviceAuth(of: documents[0])
        guard case let .map(auth) = deviceAuth else { return XCTFail("deviceAuth is not a map") }
        XCTAssertNotNil(auth["deviceMac"])
        XCTAssertNil(auth["deviceSignature"])
    }

    /// The tag has to be the one our own primitives produce over the transcript **as given** —
    /// which is what proves the builder did not re-encode it on the way in.
    func testMacIsComputedOverTheTranscriptAsReceived() throws
    {
        let keys = StubKeys()
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: keys)

        let wrappedTranscript = CBOR.tagged(CBOR.Tag(rawValue: 24),
                                            .byteString(transcript)).encode()
        let expectedTag = MdocDeviceAuth.mac(
            macStructure: MdocDeviceAuth.macStructure(
                deviceAuthenticationBytes: MdocDeviceAuth.deviceAuthenticationBytes(
                    MdocDeviceAuth.deviceAuthentication(
                        sessionTranscript: transcript,
                        docType: docType,
                        deviceNameSpacesBytes: MdocProximityResponseBuilder
                            .emptyDeviceNameSpacesBytes))),
            emacKey: MdocDeviceAuth.emacKey(sharedSecret: keys.sharedSecret,
                                            sessionTranscriptBytes: wrappedTranscript))

        let response = try XCTUnwrap(try CBOR.decode([UInt8](built.response)))
        guard case let .map(fields) = response,
              case let .array(documents)? = fields["documents"],
              case let .map(auth) = try deviceAuth(of: documents[0]),
              case let .array(mac0)? = auth["deviceMac"],
              case let .byteString(tag) = mac0[3]
        else { return XCTFail("no COSE_Mac0 tag in the response") }

        XCTAssertEqual(tag, expectedTag)
    }

    /// A key that turns out not to do ECDH drops that document to a signature; the response still
    /// goes out.
    func testFallsBackToSignatureWhenKeyAgreementIsUnsupported() throws
    {
        let keys = StubKeys()
        keys.agreementError = MdocDeviceKeyError.keyAgreementUnsupported

        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: keys)

        XCTAssertEqual(built.authMethods, ["cred-1": .deviceSignature])
        XCTAssertEqual(keys.signCalls, ["cred-1"])

        let response = try XCTUnwrap(try CBOR.decode([UInt8](built.response)))
        guard case let .map(fields) = response,
              case let .array(documents)? = fields["documents"],
              case let .map(auth) = try deviceAuth(of: documents[0])
        else { return XCTFail("malformed response") }
        XCTAssertNotNil(auth["deviceSignature"])
    }

    /// Any other failure is not a capability problem, so it is raised rather than hidden by a
    /// fallback.
    func testOtherKeyAgreementFailuresAreNotSwallowed() throws
    {
        let keys = StubKeys()
        keys.agreementError = OtherFailure()

        XCTAssertThrowsError(try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: keys))
        { error in
            XCTAssertTrue(error is OtherFailure, "unexpected error: \(error)")
        }
        XCTAssertTrue(keys.signCalls.isEmpty)
    }

    func testPreCheckAloneCanChooseTheSignature() throws
    {
        let keys = StubKeys()
        keys.canAgree = false

        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: keys)

        XCTAssertEqual(built.authMethods, ["cred-1": .deviceSignature])
        XCTAssertTrue(keys.agreementCalls.isEmpty)
    }

    func testTranscriptWithoutAReaderKeyUsesTheSignature() throws
    {
        let keys = StubKeys()
        let noReaderKey = CBOR.array([.byteString([0x01]), .null, .null]).encode()

        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: noReaderKey,
            keys: keys)

        XCTAssertEqual(built.authMethods, ["cred-1": .deviceSignature])
        XCTAssertTrue(keys.agreementCalls.isEmpty)
    }

    func testRejectsATranscriptThatIsNotThreeElements() throws
    {
        assertThrows(try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: CBOR.array([.null, .null]).encode(),
            keys: StubKeys()),
                     code: "MSDKWLT05621")
    }

    /// The transport SDK hands on `SessionTranscriptBytes` — the tag-24 wrapped form it derived
    /// its session keys over — rather than the bare array. Both forms name the same transcript,
    /// so the response bytes cannot differ between them.
    func testSessionTranscriptBytesInputProducesTheSameResponseAsTheArray() throws
    {
        let wrappedTranscript = CBOR.tagged(CBOR.Tag(rawValue: 24),
                                            .byteString(transcript)).encode()

        let fromArray = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: StubKeys())
        let fromBytes = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: wrappedTranscript,
            keys: StubKeys())

        XCTAssertEqual(fromBytes.authMethods, ["cred-1": .deviceMac])
        XCTAssertEqual(fromBytes.response, fromArray.response)
    }

    /// The reader's `SessionTranscriptBytes` vector, given as is, has to be used as is: the MAC
    /// tag pins both the salt (over the wrapped bytes) and the signature input (over the array
    /// inside them).
    func testSessionTranscriptBytesInputMatchesTheReaderVector() throws
    {
        let transcriptBytes = hexBytes(Self.vectorSessionTranscriptBytes)
        let keys = StubKeys()
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcriptBytes,
            keys: keys)

        let expectedTag = MdocDeviceAuth.mac(
            macStructure: MdocDeviceAuth.macStructure(
                deviceAuthenticationBytes: MdocDeviceAuth.deviceAuthenticationBytes(
                    MdocDeviceAuth.deviceAuthentication(
                        sessionTranscript: hexBytes(Self.vectorSessionTranscript),
                        docType: docType,
                        deviceNameSpacesBytes: MdocProximityResponseBuilder
                            .emptyDeviceNameSpacesBytes))),
            emacKey: MdocDeviceAuth.emacKey(sharedSecret: keys.sharedSecret,
                                            sessionTranscriptBytes: transcriptBytes))

        guard case let .map(fields)? = try CBOR.decode([UInt8](built.response)),
              case let .array(documents)? = fields["documents"],
              case let .map(auth) = try deviceAuth(of: documents[0]),
              case let .array(mac0)? = auth["deviceMac"],
              case let .byteString(tag) = mac0[3]
        else { return XCTFail("no COSE_Mac0 tag in the response") }

        XCTAssertEqual(tag, expectedTag)
    }

    func testRejectsSessionTranscriptBytesThatDoNotWrapAThreeElementArray() throws
    {
        let wrappedPair = CBOR.tagged(CBOR.Tag(rawValue: 24),
                                      .byteString(CBOR.array([.null, .null]).encode())).encode()
        assertThrows(try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: wrappedPair,
            keys: StubKeys()),
                     code: "MSDKWLT05621")
    }

    /// One document answering two requests is authenticated once: the inputs are identical, and
    /// `authMethods` has one entry per credential to describe.
    func testOneDocumentInTwoRequestsIsAuthenticatedOnce() throws
    {
        let keys = StubKeys()
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(index: 0, codes: [code("given_name")]),
                       requested(index: 1, codes: [code("family_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: keys)

        XCTAssertEqual(keys.agreementCalls, ["cred-1"])
        XCTAssertEqual(built.authMethods, ["cred-1": .deviceMac])

        let response = try XCTUnwrap(try CBOR.decode([UInt8](built.response)))
        guard case let .map(fields) = response,
              case let .array(documents)? = fields["documents"]
        else { return XCTFail("malformed response") }

        XCTAssertEqual(documents.count, 2)
        XCTAssertEqual(try deviceAuth(of: documents[0]).encode(),
                       try deviceAuth(of: documents[1]).encode())
    }

    func testDeviceSignedNameSpacesIsTheEmptyMapUsedInTheSignatureInput() throws
    {
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: StubKeys())

        let response = try XCTUnwrap(try CBOR.decode([UInt8](built.response)))
        guard case let .map(fields) = response,
              case let .array(documents)? = fields["documents"],
              case let .map(document) = documents[0],
              case let .map(deviceSigned)? = document["deviceSigned"],
              let nameSpaces = deviceSigned["nameSpaces"]
        else { return XCTFail("malformed response") }

        XCTAssertEqual(nameSpaces.encode(),
                       MdocProximityResponseBuilder.emptyDeviceNameSpacesBytes)
        XCTAssertEqual(nameSpaces.encode(), hexBytes("d81841a0"))
    }

    // MARK: - Reader test vectors

    /// The namespace the reader's `response/issuer-signed-namespaces` vector issues under.
    private static let vectorNamespace = "org.iso.18013.5.1"

    /// The five `IssuerSignedItemBytes` that vector issues, in the issuer's order.
    private static let vectorIssuedItems = [
        // family_name
        "d8185852a46672616e646f6d5001010101010101010101010101010101686469676573744944016c656c" +
        "656d656e7456616c756563446f6571656c656d656e744964656e7469666965726b66616d696c795f6e61" +
        "6d65",
        // given_name
        "d8185852a46672616e646f6d5002020202020202020202020202020202686469676573744944026c656c" +
        "656d656e7456616c7565644a616e6571656c656d656e744964656e7469666965726a676976656e5f6e61" +
        "6d65",
        // birth_date
        "d8185858a46672616e646f6d5003030303030303030303030303030303686469676573744944036c656c" +
        "656d656e7456616c75656a313939302d30312d303171656c656d656e744964656e7469666965726a6269" +
        "7274685f64617465",
        // age_over_18
        "d818584fa46672616e646f6d5004040404040404040404040404040404686469676573744944046c656c" +
        "656d656e7456616c7565f571656c656d656e744964656e7469666965726b6167655f6f7665725f3138",
        // portrait
        "d818588da46672616e646f6d5005050505050505050505050505050505686469676573744944056c656c" +
        "656d656e7456616c75655840000000000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000000000071656c656d656e74" +
        "4964656e74696669657268706f727472616974",
    ]

    /// The `nameSpaces` the reader expects back when only `family_name` and `age_over_18` are
    /// disclosed.
    private static let vectorDisclosedNameSpaces =
        "a1716f72672e69736f2e31383031332e352e3182d8185852a46672616e646f6d50010101010101010101" +
        "01010101010101686469676573744944016c656c656d656e7456616c756563446f6571656c656d656e74" +
        "4964656e7469666965726b66616d696c795f6e616d65d818584fa46672616e646f6d5004040404040404" +
        "040404040404040404686469676573744944046c656c656d656e7456616c7565f571656c656d656e7449" +
        "64656e7469666965726b6167655f6f7665725f3138"

    /// SHA-256 over each disclosed item's bytes -- the digests the MSO commits to.
    private static let vectorDisclosedDigests = [
        "eda73d0987af3d848f50e416db7603385c6a339ab55cd91ed9680cc5ff3b8ccf",
        "05ad9f2ca1c98903706ccbe56c769e4fd48294efcdb316fb7ca10fa9bd1619f3",
    ]

    /// A document carrying the vector's items, under the fixture's own `issuerAuth`.
    ///
    /// `Mdoc.parse` decodes without verifying, so an `issuerAuth` that does not cover these items
    /// is enough: this vector is about which item bytes get moved, not about the signature over
    /// them.
    private func vectorMdoc() throws -> Mdoc
    {
        let fixture = try XCTUnwrap(MdocFixtures.pidIssuerSigned.base64URLDecoded)
        guard case let .map(fixtureFields)? = try CBOR.decode([UInt8](fixture)),
              let issuerAuth = fixtureFields["issuerAuth"]
        else
        {
            throw OtherFailure()
        }

        let items = try Self.vectorIssuedItems.map { item -> CBOR in
            try XCTUnwrap(try CBOR.decode(hexBytes(item)))
        }
        let issuerSigned = CBOR.map([
            "nameSpaces": .map([.utf8String(Self.vectorNamespace): .array(items)]),
            "issuerAuth": issuerAuth
        ])

        return try Mdoc.parse(raw: Data(issuerSigned.encode()).base64URLEncoded)
    }

    private func vectorCode(_ element: String) -> String
    {
        return MdocClaimIndex.code(namespace: Self.vectorNamespace, elementIdentifier: element)
    }

    /// Partial disclosure moves the issuer's own item bytes: the response's `nameSpaces` is the
    /// bytes the reader expects, exactly. Re-encoding an item here would break the MSO digest taken
    /// over it, and the two implementations would disagree about a document neither had touched.
    func testDisclosedNameSpacesMatchesTheReaderVector() throws
    {
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [vectorCode("family_name"), vectorCode("age_over_18")])],
            documents: ["cred-1": try vectorMdoc()],
            sessionTranscript: transcript,
            keys: StubKeys())

        XCTAssertEqual(try issuerSignedNameSpaces(of: built).encode(),
                       hexBytes(Self.vectorDisclosedNameSpaces))
    }

    /// The same bytes, checked the way a verifier checks them: each disclosed item hashes to the
    /// digest the reader recorded for it.
    func testDisclosedItemsHashToTheReaderVectorDigests() throws
    {
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [vectorCode("family_name"), vectorCode("age_over_18")])],
            documents: ["cred-1": try vectorMdoc()],
            sessionTranscript: transcript,
            keys: StubKeys())

        guard case let .map(nameSpaces) = try issuerSignedNameSpaces(of: built),
              case let .array(items)? = nameSpaces[.utf8String(Self.vectorNamespace)]
        else { return XCTFail("no items under the vector's namespace") }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items.map { hexString([UInt8](SHA256.hash(data: Data($0.encode())))) },
                       Self.vectorDisclosedDigests)
    }

    /// The reader's `session/transcript-qr` vector: the `SessionTranscript` this suite is handed,
    /// and the `SessionTranscriptBytes` it wraps into.
    private static let vectorSessionTranscript =
        "83d8185858a20063312e30018201d818584ba401022001215820101112131415161718191a1b1c1d1e1f" +
        "202122232425262728292a2b2c2d2e2f225820303132333435363738393a3b3c3d3e3f40414243444546" +
        "4748494a4b4c4d4e4fd818584ba401022001215820505152535455565758595a5b5c5d5e5f6061626364" +
        "65666768696a6b6c6d6e6f225820707172737475767778797a7b7c7d7e7f808182838485868788898a8b" +
        "8c8d8e8ff6"

    private static let vectorSessionTranscriptBytes =
        "d81858ad83d8185858a20063312e30018201d818584ba401022001215820101112131415161718191a1b" +
        "1c1d1e1f202122232425262728292a2b2c2d2e2f225820303132333435363738393a3b3c3d3e3f404142" +
        "434445464748494a4b4c4d4e4fd818584ba401022001215820505152535455565758595a5b5c5d5e5f60" +
        "6162636465666768696a6b6c6d6e6f225820707172737475767778797a7b7c7d7e7f8081828384858687" +
        "88898a8b8c8d8e8ff6"

    private static let vectorSessionTranscriptBytesDigest =
        "919232350b8073cfb2e0db4417e23e5940d306840f1600173e4d26fa280ff8ab"

    /// The builder wraps the transcript into the reader's exact `SessionTranscriptBytes`.
    ///
    /// The wrapping is private, so the MAC tag pins it: deriving `EMacKey` with a salt taken over
    /// the reader's bytes has to reproduce the tag the builder emitted. One byte's difference in
    /// the wrapping -- a re-encoded transcript, a missing tag 24 -- and the tags diverge.
    func testSessionTranscriptBytesMatchTheReaderVector() throws
    {
        XCTAssertEqual(transcript, hexBytes(Self.vectorSessionTranscript))

        let transcriptBytes = hexBytes(Self.vectorSessionTranscriptBytes)
        XCTAssertEqual(hexString([UInt8](SHA256.hash(data: Data(transcriptBytes)))),
                       Self.vectorSessionTranscriptBytesDigest)

        let keys = StubKeys()
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(codes: [code("given_name")])],
            documents: ["cred-1": try mdoc()],
            sessionTranscript: transcript,
            keys: keys)

        let expectedTag = MdocDeviceAuth.mac(
            macStructure: MdocDeviceAuth.macStructure(
                deviceAuthenticationBytes: MdocDeviceAuth.deviceAuthenticationBytes(
                    MdocDeviceAuth.deviceAuthentication(
                        sessionTranscript: transcript,
                        docType: docType,
                        deviceNameSpacesBytes: MdocProximityResponseBuilder
                            .emptyDeviceNameSpacesBytes))),
            emacKey: MdocDeviceAuth.emacKey(sharedSecret: keys.sharedSecret,
                                            sessionTranscriptBytes: transcriptBytes))

        guard case let .map(fields)? = try CBOR.decode([UInt8](built.response)),
              case let .array(documents)? = fields["documents"],
              case let .map(auth) = try deviceAuth(of: documents[0]),
              case let .array(mac0)? = auth["deviceMac"],
              case let .byteString(tag) = mac0[3]
        else { return XCTFail("no COSE_Mac0 tag in the response") }

        XCTAssertEqual(tag, expectedTag)
    }

    /// `response/mixed-deviceauth`: one response in which the mDL is MAC'd and the photoID is
    /// signed. Our runtime fallback is per document, so this shape is ours to produce -- and the
    /// reader's bytes are what our own primitives have to agree with, document by document.
    ///
    /// The values below are the two `deviceAuth` entries of that vector's `input.bytes`:
    /// `documents[0].deviceSigned.deviceAuth.deviceMac[3]` and
    /// `documents[1].deviceSigned.deviceAuth.deviceSignature[3]`. The shared secret behind the
    /// vector's `eMacKey` is the same `zab` `StubKeys` already carries.
    private static let vectorMacDocType = "org.iso.18013.5.1.mDL"

    private static let vectorSignedDocType = "org.iso.23220.photoID.1"

    private static let vectorMacTag =
        "4f2e17fbfe9e3408a0f96b8e341780420cf37f8d816138014ec58fc8e660e4c1"

    private static let vectorDeviceSignature =
        "d40cf2775285575677c2f93467642ba56acb05e3a60b31dffb48314d75d493a698c05c4e17d327ed1570" +
        "fb5767d60a80580ce735743b37d56b23c441e8e5e105"

    /// The photoID document's `deviceKey`, uncompressed SEC1 -- the public half of what signed it.
    private static let vectorSignedDeviceKey =
        "04d65a93977caa3d1b081852ff57a79e465f1660577304baead505dd3a48589cf350185e895372df6221" +
        "ea3a137557e473fddb6755f05bd507c3c533fce9c91285"

    func testMixedResponseMacTagMatchesTheReaderVector() throws
    {
        let transcriptBytes = hexBytes(Self.vectorSessionTranscriptBytes)
        let tag = MdocDeviceAuth.mac(
            macStructure: MdocDeviceAuth.macStructure(
                deviceAuthenticationBytes: MdocDeviceAuth.deviceAuthenticationBytes(
                    MdocDeviceAuth.deviceAuthentication(
                        sessionTranscript: transcript,
                        docType: Self.vectorMacDocType,
                        deviceNameSpacesBytes: MdocProximityResponseBuilder
                            .emptyDeviceNameSpacesBytes))),
            emacKey: MdocDeviceAuth.emacKey(sharedSecret: StubKeys().sharedSecret,
                                            sessionTranscriptBytes: transcriptBytes))

        XCTAssertEqual(hexString(tag), Self.vectorMacTag)
    }

    /// The signed half of the same response: the reader's signature verifies over the
    /// `Sig_structure` we would have signed, so the two implementations assemble the same input.
    func testMixedResponseSignatureVerifiesOverOurSignatureInput() throws
    {
        let deviceAuthenticationBytes = MdocDeviceAuth.deviceAuthenticationBytes(
            MdocDeviceAuth.deviceAuthentication(
                sessionTranscript: transcript,
                docType: Self.vectorSignedDocType,
                deviceNameSpacesBytes: MdocProximityResponseBuilder.emptyDeviceNameSpacesBytes))
        let signatureInput = CBOR.array([
            .utf8String("Signature1"),
            .byteString(CBOR.map([1: -7]).encode()),
            .byteString([]),
            .byteString(deviceAuthenticationBytes)
        ]).encode()

        let key = try P256.Signing.PublicKey(
            x963Representation: Data(hexBytes(Self.vectorSignedDeviceKey)))
        let signature = try P256.Signing.ECDSASignature(
            rawRepresentation: Data(hexBytes(Self.vectorDeviceSignature)))

        XCTAssertTrue(key.isValidSignature(signature, for: Data(signatureInput)))
    }

    /// Both methods in one response: the decision is per document, so a credential whose key cannot
    /// agree drops to a signature while the other still MACs. A reader that fixed the method for
    /// the whole response would reject one of these documents.
    func testOneResponseCarriesBothAuthMethods() throws
    {
        let keys = StubKeys()
        keys.cannotAgree = ["cred-2"]
        let built = try MdocProximityResponseBuilder.build(
            selected: [requested(index: 0, credentialId: "cred-1", codes: [code("given_name")]),
                       requested(index: 1, credentialId: "cred-2", codes: [code("family_name")])],
            documents: ["cred-1": try mdoc(), "cred-2": try mdoc()],
            sessionTranscript: transcript,
            keys: keys)

        XCTAssertEqual(built.authMethods, ["cred-1": .deviceMac, "cred-2": .deviceSignature])

        guard case let .map(fields)? = try CBOR.decode([UInt8](built.response)),
              case let .array(documents)? = fields["documents"],
              case let .map(first) = try deviceAuth(of: documents[0]),
              case let .map(second) = try deviceAuth(of: documents[1])
        else { return XCTFail("malformed response") }

        XCTAssertNotNil(first["deviceMac"])
        XCTAssertNil(first["deviceSignature"])
        XCTAssertNotNil(second["deviceSignature"])
        XCTAssertNil(second["deviceMac"])
    }

    // MARK: - Helpers

    private func issuerSignedNameSpaces(of built: MdocDeviceResponse) throws -> CBOR
    {
        guard case let .map(fields)? = try CBOR.decode([UInt8](built.response)),
              case let .array(documents)? = fields["documents"],
              documents.count == 1,
              case let .map(document) = documents[0],
              case let .map(issuerSigned)? = document["issuerSigned"],
              let nameSpaces = issuerSigned["nameSpaces"]
        else
        {
            throw OtherFailure()
        }
        return nameSpaces
    }

    private func deviceAuth(of document: CBOR) throws -> CBOR
    {
        guard case let .map(fields) = document,
              case let .map(deviceSigned)? = fields["deviceSigned"],
              let deviceAuth = deviceSigned["deviceAuth"]
        else
        {
            throw OtherFailure()
        }
        return deviceAuth
    }
}

private func hexString(_ bytes: [UInt8]) -> String
{
    return bytes.map { String(format: "%02x", $0) }.joined()
}

private func hexBytes(_ string: String) -> [UInt8]
{
    var out: [UInt8] = []
    out.reserveCapacity(string.count / 2)
    var index = string.startIndex
    while index < string.endIndex {
        let next = string.index(index, offsetBy: 2)
        out.append(UInt8(string[index ..< next], radix: 16)!)
        index = next
    }
    return out
}
