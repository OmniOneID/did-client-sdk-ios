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

    // Note: a wrong-key / tampered-ciphertext decrypt currently hits a fatalError inside
    // JWE.decrypt (its auth-failure path is not yet a thrown error), so it cannot be asserted
    // as a throwing test here without crashing the runner. Covered once that path is error-ified.

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
