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

/// The mdoc presentation path, checked at the level that decides whether a verifier accepts it:
/// which bytes are moved across unchanged, and what the device signature commits to.
///
/// The verifier side is not available yet, so these tests pin our own output rather than an
/// interop result — a real `DeviceResponse` round trip is still owed.
final class MdocPresenterTests: XCTestCase {

    private let namespace = "eu.europa.ec.eudi.pid.1"
    private let clientId = "verifier.example"
    private let nonce = "n-0S6_WzA2Mj"
    private let responseUri = "https://verifier.example/response"

    private func mdoc() throws -> Mdoc {
        return try Mdoc.parse(raw: MdocFixtures.pidIssuerSigned)
    }

    private func code(_ element: String) -> String {
        return MdocClaimIndex.code(namespace: namespace, elementIdentifier: element)
    }

    /// A signer shaped like the wallet's: returns the 65-byte compact signature (`v‖r‖s`) the
    /// KeyManager produces, and records the digest it was asked to sign.
    private final class RecordingSigner {
        let privateKey = P256.Signing.PrivateKey()
        private(set) var digests: [Data] = []

        func sign(_ digest: Data) throws -> Data {
            digests.append(digest)
            let signature = try privateKey.signature(for: digest)
            return Data([0x00]) + signature.rawRepresentation
        }
    }

    private func present(codes: [String],
                         nonce: String? = nil,
                         responseEncryption: MdocPresenter.ResponseEncryption = .none,
                         signer: RecordingSigner = RecordingSigner()) throws -> (token: String, signer: RecordingSigner) {
        let token = try MdocPresenter.createVpToken(
            mdoc: try mdoc(),
            claimCodes: codes,
            clientId: clientId,
            nonce: nonce ?? self.nonce,
            responseUri: responseUri,
            responseEncryption: responseEncryption,
            signDigest: { try signer.sign($0) })
        return (token, signer)
    }

    private func decoded(_ token: String) throws -> OrderedDictionaryView {
        let data = try XCTUnwrap(token.base64URLDecoded)
        let cbor = try XCTUnwrap(try CBOR.decode([UInt8](data)))
        return OrderedDictionaryView(cbor)
    }

    /// Thin reader so the assertions below read as structure, not as pattern matching.
    private struct OrderedDictionaryView {
        let cbor: CBOR
        init(_ cbor: CBOR) { self.cbor = cbor }
        subscript(key: String) -> OrderedDictionaryView? {
            guard case let .map(map) = cbor, let value = map[.utf8String(key)] else { return nil }
            return OrderedDictionaryView(value)
        }
        subscript(index: Int) -> OrderedDictionaryView? {
            guard case let .array(items) = cbor, items.indices.contains(index) else { return nil }
            return OrderedDictionaryView(items[index])
        }
        var text: String? { if case let .utf8String(value) = cbor { return value }; return nil }
        var uint: UInt64? { if case let .unsignedInt(value) = cbor { return value }; return nil }
        var bytes: [UInt8]? { if case let .byteString(value) = cbor { return value }; return nil }
        var array: [CBOR]? { if case let .array(value) = cbor { return value }; return nil }
        var isNull: Bool { if case .null = cbor { return true }; return false }
    }

    // MARK: - Structure

    func testBuildsADeviceResponseAroundTheSelectedDocument() throws {
        let (token, _) = try present(codes: [code("given_name")])
        let response = try decoded(token)

        XCTAssertEqual(response["version"]?.text, "1.0")
        XCTAssertEqual(response["status"]?.uint, 0)
        XCTAssertEqual(response["documents"]?.array?.count, 1)

        let document = try XCTUnwrap(response["documents"]?[0])
        XCTAssertEqual(document["docType"]?.text, "eu.europa.ec.eudi.pid.1")
        XCTAssertNotNil(document["issuerSigned"]?["issuerAuth"])
        XCTAssertNotNil(document["deviceSigned"]?["deviceAuth"]?["deviceSignature"])
    }

    /// The verifier rebuilds `DeviceAuthentication` from the request it sent, so sending the
    /// payload back would assert only what it already knows. It stays detached.
    func testDeviceSignatureIsADetachedES256Signature() throws {
        let (token, signer) = try present(codes: [code("given_name")])
        let signature = try XCTUnwrap(try decoded(token)["documents"]?[0]?["deviceSigned"]?["deviceAuth"]?["deviceSignature"])

        XCTAssertEqual(signature.array?.count, 4)
        // {1: -7} — ES256, in the protected header the signature commits to.
        XCTAssertEqual(signature[0]?.bytes, [0xA1, 0x01, 0x26])
        XCTAssertTrue(try XCTUnwrap(signature[2] as OrderedDictionaryView?).isNull)

        // The wallet returns v‖r‖s; COSE carries the 64-byte r‖s.
        let emitted = try XCTUnwrap(signature[3]?.bytes)
        XCTAssertEqual(emitted.count, 64)
        XCTAssertEqual(signer.digests.count, 1)
        let expected = try signer.privateKey.publicKey.isValidSignature(
            P256.Signing.ECDSASignature(rawRepresentation: Data(emitted)),
            for: try XCTUnwrap(signer.digests.first))
        XCTAssertTrue(expected, "the emitted signature must be the one produced for the signed digest")
    }

    // MARK: - Byte fidelity

    /// The MSO digests were computed over these exact item bytes. Rebuilding an item would produce
    /// equivalent CBOR with a different digest, and the verifier would reject the document.
    func testDisclosedItemsAreTheIssuersOwnBytes() throws {
        let mdoc = try mdoc()
        let (token, _) = try present(codes: [code("given_name"), code("family_name")])

        let nameSpaces = try XCTUnwrap(try decoded(token)["documents"]?[0]?["issuerSigned"]?["nameSpaces"])
        let items = try XCTUnwrap(nameSpaces[namespace]?.array)
        XCTAssertEqual(items.count, 2)

        let issued = try XCTUnwrap(mdoc.items[namespace])
        for item in items {
            let encoded = item.encode()
            XCTAssertTrue(issued.contains { $0.itemBytes == encoded },
                          "a disclosed item was re-encoded instead of moved across")
        }
    }

    func testDisclosesOnlyTheSelectedElements() throws {
        let (token, _) = try present(codes: [code("portrait")])

        let items = try XCTUnwrap(try decoded(token)["documents"]?[0]?["issuerSigned"]?["nameSpaces"]?[namespace]?.array)
        XCTAssertEqual(items.count, 1)

        let inner = try XCTUnwrap(try CBOR.decode(try XCTUnwrap(OrderedDictionaryView(items[0]).cbor.taggedByteString)))
        XCTAssertEqual(OrderedDictionaryView(inner)["elementIdentifier"]?.text, "portrait")
    }

    func testIssuerAuthIsCarriedUnchanged() throws {
        let mdoc = try mdoc()
        let (token, _) = try present(codes: [code("given_name")])

        let issuerAuth = try XCTUnwrap(try decoded(token)["documents"]?[0]?["issuerSigned"]?["issuerAuth"])
        let rebuilt = try COSESign1.decode(issuerAuth.cbor)

        XCTAssertEqual(rebuilt.protectedBytes, mdoc.issuerAuth.protectedBytes)
        XCTAssertEqual(rebuilt.payload, mdoc.issuerAuth.payload)
        XCTAssertEqual(rebuilt.signature, mdoc.issuerAuth.signature)
        XCTAssertEqual(rebuilt.keyIdentifier, mdoc.issuerAuth.keyIdentifier)
    }

    // MARK: - Session binding

    /// Both sides hash these structures independently, and the vendored CBOR encoder never sorts
    /// map keys — so the same inputs have to produce the same bytes every time.
    func testTheSameSelectionSignsTheSameDigest() throws {
        let first = try present(codes: [code("given_name")])
        let second = try present(codes: [code("given_name")])

        XCTAssertEqual(first.signer.digests, second.signer.digests)
    }

    func testTheSignatureIsBoundToTheRequest() throws {
        let base = try present(codes: [code("given_name")])
        let otherNonce = try present(codes: [code("given_name")], nonce: "a-different-nonce")

        XCTAssertNotEqual(base.signer.digests, otherNonce.signer.digests)
    }

    /// For `direct_post.jwt` the handover commits to the key the response is sealed to, which is
    /// what keeps a sealed response from being replayed to another verifier.
    func testResponseEncryptionKeyEntersTheSessionBinding() throws {
        let jwk = JWK(crv: .p256,
                      kty: .ec,
                      x: "f83OJ3D2xF1Bg8vub9tLe1gHMzV76e8Tus9uPHvRVEU",
                      y: "x_FEzRu9m36HLN_tue659LNpXW6pCyStikYjKIWI5a0")

        let clear = try present(codes: [code("given_name")])
        let sealed = try present(codes: [code("given_name")], responseEncryption: .key(jwk))

        XCTAssertNotEqual(clear.signer.digests, sealed.signer.digests)
    }

    // MARK: - Selection

    func testRejectsASelectionTheDocumentCannotDisclose() throws {
        XCTAssertThrowsError(try present(codes: []))
        XCTAssertThrowsError(try present(codes: [code("driving_privileges")]))
        // A code is looked up, never split: the bare element name is not a code.
        XCTAssertThrowsError(try present(codes: ["given_name"]))
    }
}

private extension CBOR {
    /// The payload of a tag 24 wrapper, for tests that need to look inside an item.
    var taggedByteString: [UInt8]? {
        guard case let .tagged(tag, value) = self, tag.rawValue == 24,
              case let .byteString(bytes) = value else { return nil }
        return bytes
    }
}
