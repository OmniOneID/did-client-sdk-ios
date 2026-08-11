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

/// A thumbprint is only useful if two implementations that never met agree on it, so what these
/// tests pin is the canonical form (RFC 7638 §3.2) rather than a value this SDK happens to produce.
final class JWKThumbprintTests: XCTestCase {

    /// The EC key from RFC 7515 A.3.
    private let key = JWK(crv: .p256,
                          kty: .ec,
                          x: "f83OJ3D2xF1Bg8vub9tLe1gHMzV76e8Tus9uPHvRVEU",
                          y: "x_FEzRu9m36HLN_tue659LNpXW6pCyStikYjKIWI5a0")

    /// The required members of an EC key, in lexicographic order, with no whitespace. Spelled out
    /// here so that changing how the SDK builds it fails against the standard's shape rather than
    /// against a recorded output.
    func testHashesTheCanonicalFormRFC7638Defines() throws {
        let canonical = "{\"crv\":\"P-256\",\"kty\":\"EC\",\"x\":\"\(key.x)\",\"y\":\"\(key.y)\"}"
        let expected = Data(SHA256.hash(data: Data(canonical.utf8))).base64URLEncoded

        XCTAssertEqual(try JWKThumbprint.sha256(of: key), expected)
    }

    /// `alg`, `kid` and `use` are not required members: a key that travels with them is the same
    /// key, and must not get a second identity.
    func testOptionalMembersDoNotChangeTheThumbprint() throws {
        var decorated = key
        decorated.alg = .es256
        decorated.kid = "key-1"
        decorated.use = .sig

        XCTAssertEqual(try JWKThumbprint.sha256(of: decorated), try JWKThumbprint.sha256(of: key))
    }

    func testDifferentKeysGetDifferentThumbprints() throws {
        var other = key
        other.x = "MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4"

        XCTAssertNotEqual(try JWKThumbprint.sha256(of: other), try JWKThumbprint.sha256(of: key))
    }

    /// Only EC keys have a canonical form here; anything else would need its own required-member
    /// set, and guessing one would produce an identifier no other implementation agrees with.
    func testRefusesAKeyItCannotCanonicalize() throws {
        var unsupported = key
        unsupported.kty = .unknown("RSA")

        XCTAssertThrowsError(try JWKThumbprint.sha256(of: unsupported))
    }
}
