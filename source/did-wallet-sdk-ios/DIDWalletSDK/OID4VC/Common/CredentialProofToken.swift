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

/// The key proof a holder attaches to an OID4VCI Credential Request (`proofs.jwt`).
///
/// The header names the signing key by `kid` — a DID URL into the holder DID Document — rather than
/// carrying it as `jwk`, so the issuer resolves the key the same way it does for a revocation token.
///
/// Kept free of wallet state so the proof can be built and verified without a key store; the
/// signing is handed in.
enum CredentialProofToken
{
    static let typ = "openid4vci-proof+jwt"

    /// Builds and signs a key proof.
    ///
    /// - Parameters:
    ///   - kid: The DID URL of the signing key, carrying the DID Document's current `versionId`.
    ///   - audience: The Credential Issuer Identifier — the proof's `aud`.
    ///   - nonce: The `c_nonce` the issuer's nonce endpoint returned, or `nil` when it has none.
    ///   - issuedAt: The proof's `iat`.
    ///   - signDigest: Signs the SHA-256 digest of the signing input with the holder key; returns
    ///     the raw 65-byte compact signature (`v‖r‖s`).
    /// - Returns: The proof in JWS compact serialization.
    static func create(kid: String,
                       audience: String,
                       nonce: String?,
                       issuedAt: Date = Date(),
                       signDigest: (_ digest: Data) throws -> Data) throws -> String
    {
        let header = try JWSHeader(typ: typ, kid: kid).toJsonData().base64URLEncoded
        let payload = try JWSAudiencePayload(
            aud: audience,
            iat: Int(issuedAt.timeIntervalSince1970),
            nonce: nonce
        ).toJsonData().base64URLEncoded

        let signSource = "\(header).\(payload)"
        let digest = signSource.data(using: .utf8)!.sha256()

        // The signer returns a 65-byte compact signature (v‖r‖s); JOSE ES256 wants 64-byte r‖s.
        let compactSignature = try signDigest(digest)
        let signature = Data(compactSignature.dropFirst()).base64URLEncoded

        return "\(signSource).\(signature)"
    }
}
