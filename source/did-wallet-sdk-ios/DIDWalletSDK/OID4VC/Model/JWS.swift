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
import CryptoKit

struct JWSHeader : Jsonable
{
    var alg : JWK.Algorithm = .es256
    var typ : String
    var kid : String?
    var jwk : JWK?
}

struct JWSAudiencePayload : Jsonable
{
    var aud : String
    var iat : Int       = Int(Date().timeIntervalSince1970)
    var nonce : String?
}

/// A parsed JWS in compact serialization (`<header>.<payload>.<signature>`).
///
/// The three properties hold the raw base64url segments as they appear on the wire; use
/// `payloadData` for the decoded payload.
public struct JWS
{
    /// The base64url-encoded protected header.
    public let header: String
    /// The base64url-encoded payload.
    public let payload: String
    /// The base64url-encoded signature.
    public let signature: String

    /// Parses a compact-serialized JWS.
    /// - Parameter string: The compact JWS, e.g. the credential JWT of an SD-JWT.
    /// - Throws: `OID4VCManagerError.invalidJWS` when the string is not three dot-separated parts.
    public init(from string : String) throws
    {
        let parts = string.split(separator: ".")
        guard parts.count == 3
        else
        {
            throw OID4VCManagerError.invalidJWS(
                detail: "expected 3 dot-separated parts, got \(parts.count)").getError()
        }

        self.header = String(parts[0])
        self.payload = String(parts[1])
        self.signature = String(parts[2])
    }

    /// The base64url-decoded payload.
    /// - Throws: `OID4VCManagerError.invalidJWS` when the payload is not valid base64url.
    public var payloadData: Data
    {
        get throws
        {
            guard let decoded = payload.base64URLDecoded
            else
            {
                throw OID4VCManagerError.invalidJWS(detail: "payload is not base64url").getError()
            }
            return decoded
        }
    }

    /// Verifies the signature against the public key embedded in the header (`jwk`).
    ///
    /// Only self-contained JWSs can be checked this way; a header that carries a `kid` instead of a
    /// `jwk` needs the signer's DID document, which this type does not resolve.
    /// - Returns: Whether the signature is valid.
    /// - Throws: `OID4VCManagerError.invalidJWS` when a segment is not base64url,
    ///   `.missingJWSHeaderKey` when the header carries no `jwk`.
    public func verify() throws -> Bool
    {
        let message = header + "." + payload

        let publicKey = try getPublicKey()

        guard let signatureData = signature.base64URLDecoded
        else
        {
            throw OID4VCManagerError.invalidJWS(detail: "signature is not base64url").getError()
        }

        let sig = try P256.Signing.ECDSASignature.init(rawRepresentation: signatureData)

        let digest = SHA256.hash(data: message.data(using: .utf8)!)

        return publicKey.isValidSignature(sig, for: digest)
    }

    /// Decodes the payload into a `Jsonable` model.
    func getPayload<T : Jsonable>() throws -> T
    {
        return try T.init(from: try payloadData)
    }

    private func getPublicKey() throws -> P256.Signing.PublicKey
    {
        guard let decodedHeader = header.base64URLDecoded
        else
        {
            throw OID4VCManagerError.invalidJWS(detail: "header is not base64url").getError()
        }

        let jwsHeader : JWSHeader = try .init(from: decodedHeader)

        guard let jwk = jwsHeader.jwk
        else
        {
            throw OID4VCManagerError.missingJWSHeaderKey.getError()
        }

        return try .init(
            xBase64URL: jwk.x,
            yBase64URL: jwk.y
        )
    }
}
