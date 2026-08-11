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

import Foundation

/// JWK thumbprint (RFC 7638).
///
/// The thumbprint identifies a key by its value rather than by how it was written down, which is
/// what lets a wallet and a verifier arrive at the same identifier for the same key. That only
/// holds if both sides serialize identically, so the canonical form is built by hand here rather
/// than by encoding a `JWK`: only the required members, in lexicographic order, with no whitespace
/// and no other fields — an `alg`, `kid` or `use` that happened to travel with the key must not
/// change its thumbprint.
enum JWKThumbprint
{
    /// The SHA-256 thumbprint of an EC key, base64url-encoded.
    ///
    /// Only EC keys are computed here because that is the only key type this SDK exchanges; another
    /// key type has a different required-member set and would need its own canonical form.
    /// - Parameter jwk: The key to identify.
    /// - Returns: The base64url thumbprint.
    /// - Throws: `OID4VCManagerError.unsupportedJWEKey` when the key is not an EC key this SDK
    ///   can canonicalize.
    static func sha256(of jwk: JWK) throws -> String
    {
        guard jwk.kty == .ec, jwk.crv == .p256
        else
        {
            throw OID4VCManagerError.unsupportedJWEKey.getError()
        }

        // RFC 7638 §3.2: for an EC key the required members are crv, kty, x, y — in this order,
        // which is also their lexicographic order.
        let canonical = "{\"crv\":\"P-256\",\"kty\":\"EC\",\"x\":\"\(jwk.x)\",\"y\":\"\(jwk.y)\"}"
        return Data(canonical.utf8).sha256().base64URLEncoded
    }
}
