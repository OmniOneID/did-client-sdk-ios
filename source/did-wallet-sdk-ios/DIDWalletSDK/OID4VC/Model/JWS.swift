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

/// A JWS protected header.
///
/// `alg` and `typ` are required on decode; a header that omits either is rejected. Callers read
/// this type through `JWS.protectedHeader` but do not construct it — the memberwise initializer
/// stays internal to the SDK.
public struct JWSHeader : Jsonable
{
    public var alg : JWK.Algorithm = .es256
    public var typ : String
    public var kid : String?
    public var jwk : JWK?
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

    /// The decoded protected header.
    ///
    /// Read `kid` from here when the header carries no `jwk`, resolve the signer's key yourself and
    /// hand it to `verify(publicKey:)`.
    /// - Throws: `OID4VCManagerError.invalidJWS` when the header is not base64url; a decoding error
    ///   when it is not a JWS header — `alg` and `typ` are both required.
    public var protectedHeader: JWSHeader
    {
        get throws
        {
            guard let decoded = header.base64URLDecoded
            else
            {
                throw OID4VCManagerError.invalidJWS(detail: "header is not base64url").getError()
            }

            return try .init(from: decoded)
        }
    }

    /// Verifies the signature against the public key embedded in the header (`jwk`).
    ///
    /// Only self-contained JWSs can be checked this way; a header that carries a `kid` instead of a
    /// `jwk` needs the signer's DID document, which this type does not resolve — use
    /// `verify(publicKey:)` for those.
    /// - Returns: Whether the signature is valid.
    /// - Throws: `OID4VCManagerError.invalidJWS` when a segment is not base64url,
    ///   `.missingJWSHeaderKey` when the header carries no `jwk`.
    public func verify() throws -> Bool
    {
        return try verify(key: try getPublicKey())
    }

    /// Verifies the signature against a caller-supplied public key.
    ///
    /// Use this when the header carries only a `kid`: resolve the signer's key yourself — from the
    /// issuer's DID document, for instance — and pass its bytes in. Key resolution and trust
    /// decisions stay with the caller, and so does checking `alg`: this method does not read the
    /// header at all.
    /// - Parameter publicKey: A P-256 public key, in compressed (33), X9.63 (65) or raw (64) form.
    /// - Returns: Whether the signature is valid.
    /// - Throws: `OID4VCManagerError.invalidJWS` when the signature is not base64url,
    ///   `SignableError.invalidPublicKey` when the bytes are not a P-256 public key.
    public func verify(publicKey: Data) throws -> Bool
    {
        return try verify(key: try .init(p256Representation: publicKey))
    }

    /// Decodes the payload into a `Jsonable` model.
    func getPayload<T : Jsonable>() throws -> T
    {
        return try T.init(from: try payloadData)
    }

    /// The signature check both public entry points share.
    private func verify(key: P256.Signing.PublicKey) throws -> Bool
    {
        guard let signatureData = signature.base64URLDecoded
        else
        {
            throw OID4VCManagerError.invalidJWS(detail: "signature is not base64url").getError()
        }

        let sig = try P256.Signing.ECDSASignature.init(rawRepresentation: signatureData)

        let digest = SHA256.hash(data: Data((header + "." + payload).utf8))

        return key.isValidSignature(sig, for: digest)
    }

    private func getPublicKey() throws -> P256.Signing.PublicKey
    {
        guard let jwk = try protectedHeader.jwk
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
