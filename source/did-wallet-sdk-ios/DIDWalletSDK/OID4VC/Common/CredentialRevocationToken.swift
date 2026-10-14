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

/// The JWT a holder signs to ask the issuer to revoke one of its credentials.
///
/// An OpenDID extension, not an OID4VCI protocol: the holder fetches a `c_nonce` from the issuer's
/// existing `nonce_endpoint`, binds it to the credential's status list entry, signs the result with
/// the key the credential is bound to, and posts it to `credential_revocation_endpoint`. The issuer
/// identifies the credential by `uri` + `idx` and checks that `iss` is the DID it issued to.
///
/// Kept free of wallet state so the token can be built and verified without a key store; the
/// signing is handed in.
enum CredentialRevocationToken
{
    static let typ = "opendid-credential-revocation+jwt"

    /// How long the token is valid. The issuer accepts at most 300 seconds between `iat` and `exp`.
    static let lifetime: Int = 300

    /// Builds and signs a revocation token.
    ///
    /// - Parameters:
    ///   - holderDid: The holder DID — the token's `iss`.
    ///   - kid: The DID URL of the signing key, carrying the DID Document's current `versionId`.
    ///   - nonce: The `c_nonce` the issuer's nonce endpoint returned, as received.
    ///   - status: The credential's status list entry.
    ///   - issuedAt: The token's `iat`.
    ///   - signDigest: Signs the SHA-256 digest of the signing input with the holder key; returns
    ///     the raw 65-byte compact signature (`v‖r‖s`).
    /// - Returns: The token in JWS compact serialization.
    static func create(holderDid: String,
                       kid: String,
                       nonce: String,
                       status: StatusListReference,
                       issuedAt: Date = Date(),
                       signDigest: (_ digest: Data) throws -> Data) throws -> String
    {
        let iat = Int(issuedAt.timeIntervalSince1970)

        let header = try JWSHeader(typ: typ, kid: kid).toJsonData().base64URLEncoded
        let payload = try CredentialRevocationPayload(
            iss: holderDid,
            iat: iat,
            exp: iat + lifetime,
            nonce: nonce,
            credentialStatus: .init(statusList: .init(uri: status.uri, idx: status.idx))
        ).toJsonData().base64URLEncoded

        let signSource = "\(header).\(payload)"
        let digest = signSource.data(using: .utf8)!.sha256()

        // The signer returns a 65-byte compact signature (v‖r‖s); JOSE ES256 wants 64-byte r‖s.
        let compactSignature = try signDigest(digest)
        let signature = Data(compactSignature.dropFirst()).base64URLEncoded

        return "\(signSource).\(signature)"
    }
}

/// The revocation token's claims.
struct CredentialRevocationPayload: Jsonable, FromSnake
{
    struct CredentialStatus: Jsonable, FromSnake
    {
        let statusList: StatusList
    }

    struct StatusList: Jsonable, FromSnake
    {
        let uri: String
        let idx: Int
    }

    let iss: String
    let iat: Int
    let exp: Int
    let nonce: String
    let credentialStatus: CredentialStatus
}

/// The body posted to `credential_revocation_endpoint`.
struct CredentialRevocationRequest: Jsonable, FromSnake
{
    let revocationToken: String
}
