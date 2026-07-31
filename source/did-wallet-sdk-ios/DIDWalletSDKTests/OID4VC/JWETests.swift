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

final class JWETests: XCTestCase {

    // Encrypt with JWE.encrypt, then decrypt with the matching private key: the plaintext must survive.
    func testEncryptDecryptRoundTripA256GCM() throws {
        let recipientPrivateKey = P256.KeyAgreement.PrivateKey()
        let recipientJWK = recipientPrivateKey.publicKey.getPublicKeyJwk()

        let plaintext = Data(#"{"vp_token":{"q1":["ey..."]},"state":"abc"}"#.utf8)

        let compact = try JWE.encrypt(plaintext: plaintext, to: recipientJWK)

        // Compact JWE has 5 dot-separated segments; ECDH-ES Direct leaves the encrypted key empty.
        let segments = compact.split(separator: ".", omittingEmptySubsequences: false)
        XCTAssertEqual(segments.count, 5)
        XCTAssertTrue(segments[1].isEmpty)

        let decrypted = try JWE(compact: compact).decrypt(using: recipientPrivateKey)
        XCTAssertEqual(decrypted, plaintext)
    }

    // A128GCM derives a 128-bit CEK; the round trip must still hold.
    func testEncryptDecryptRoundTripA128GCM() throws {
        let recipientPrivateKey = P256.KeyAgreement.PrivateKey()
        let recipientJWK = recipientPrivateKey.publicKey.getPublicKeyJwk()

        let plaintext = Data("hello a128gcm".utf8)

        let compact = try JWE.encrypt(plaintext: plaintext, to: recipientJWK, enc: .a128GCM)
        let decrypted = try JWE(compact: compact).decrypt(using: recipientPrivateKey)

        XCTAssertEqual(decrypted, plaintext)
    }

    // apu/apv feed the Concat KDF; encrypt and decrypt read them from the same header, so they must match.
    func testEncryptDecryptRoundTripWithApuApv() throws {
        let recipientPrivateKey = P256.KeyAgreement.PrivateKey()
        let recipientJWK = recipientPrivateKey.publicKey.getPublicKeyJwk()

        let plaintext = Data("party info".utf8)
        let apu = Data("Alice".utf8).base64URLEncoded
        let apv = Data("Bob".utf8).base64URLEncoded

        let compact = try JWE.encrypt(plaintext: plaintext, to: recipientJWK, apu: apu, apv: apv)
        let decrypted = try JWE(compact: compact).decrypt(using: recipientPrivateKey)

        XCTAssertEqual(decrypted, plaintext)
    }

    // A tampered ciphertext fails the GCM tag check. AEAD cannot tell "wrong key" from "modified
    // data" — and must not, or it becomes an oracle — so both surface as authenticationFailed.
    func testTamperedCiphertextFailsAuthentication() throws {
        let recipientPrivateKey = P256.KeyAgreement.PrivateKey()
        let compact = try JWE.encrypt(plaintext: Data("secret payload".utf8),
                                      to: recipientPrivateKey.publicKey.getPublicKeyJwk())

        var segments = compact.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        var ciphertext = try XCTUnwrap(segments[3].base64URLDecoded)
        // Flip one bit; the protected header (AAD), iv and tag stay intact so the SealedBox still
        // builds and the failure lands on the tag check rather than on invalidSealedBox.
        ciphertext[0] ^= 0x01
        segments[3] = ciphertext.base64URLEncoded

        let tampered = try JWE(compact: segments.joined(separator: "."))
        XCTAssertThrowsError(try tampered.decrypt(using: recipientPrivateKey)) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05214" else {
                return XCTFail("expected authenticationFailed, got \(error)")
            }
        }
    }

    // Decrypting with a key the JWE was not encrypted for derives a different CEK, which the tag
    // check rejects the same way.
    func testWrongRecipientKeyFailsAuthentication() throws {
        let compact = try JWE.encrypt(plaintext: Data("secret payload".utf8),
                                      to: P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk())

        let strangerKey = P256.KeyAgreement.PrivateKey()
        XCTAssertThrowsError(try JWE(compact: compact).decrypt(using: strangerKey)) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05214" else {
                return XCTFail("expected authenticationFailed, got \(error)")
            }
        }
    }

    // The recipient JWK's kid is echoed into the top-level protected header; the ephemeral epk
    // carries no kid. A recipient without a kid produces a header with no kid field.
    func testRecipientKidEchoedIntoHeader() throws {
        var recipientJWK = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()
        recipientJWK.kid = "verifier-key-1"

        let compact = try JWE.encrypt(plaintext: Data("x".utf8), to: recipientJWK)
        let jwe = try JWE(compact: compact)

        XCTAssertEqual(jwe.protectedHeader.kid, "verifier-key-1")
        XCTAssertNil(jwe.protectedHeader.epk.kid)

        let noKidJWK = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()
        let compactNoKid = try JWE.encrypt(plaintext: Data("x".utf8), to: noKidJWK)
        XCTAssertNil(try JWE(compact: compactNoKid).protectedHeader.kid)
    }

    // Every segment of a compact JWE is server-supplied. One that is not valid base64url must be
    // reported as invalidJWE, never trap the app mid-issuance.
    func testMalformedSegmentThrowsInsteadOfTrapping() throws {
        let compact = try JWE.encrypt(plaintext: Data("x".utf8),
                                      to: P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk())
        var segments = compact.split(separator: ".", omittingEmptySubsequences: false).map(String.init)

        // A base64url segment whose length is ≡1 mod 4 cannot be decoded.
        for index in [0, 2, 3, 4] {
            var broken = segments
            broken[index] = String(repeating: "A", count: 5)

            XCTAssertThrowsError(try JWE(compact: broken.joined(separator: ".")),
                                 "segment \(index) should be rejected") { error in
                guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05210" else {
                    return XCTFail("expected invalidJWE for segment \(index), got \(error)")
                }
            }
        }

        // The intact string still parses, so the test above is not passing for the wrong reason.
        segments = compact.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        XCTAssertNoThrow(try JWE(compact: segments.joined(separator: ".")))
    }

    // A non-P-256 recipient key is rejected up front.
    func testEncryptRejectsUnsupportedRecipientKey() throws {
        var badJWK = P256.KeyAgreement.PrivateKey().publicKey.getPublicKeyJwk()
        badJWK.crv = .unknown("P-384")

        XCTAssertThrowsError(try JWE.encrypt(plaintext: Data("x".utf8), to: badJWK)) { error in
            guard let walletError = error as? WalletCoreError, walletError.code == "MSDKWLT05212" else {
                return XCTFail("expected unsupportedJWEKey, got \(error)")
            }
        }
    }
}
