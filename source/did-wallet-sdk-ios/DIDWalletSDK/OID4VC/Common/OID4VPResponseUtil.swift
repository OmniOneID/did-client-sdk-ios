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

/// Builds the OID4VP authorization-response body submitted to the verifier: assembles
/// `{vp_token, state}` and, for `response_mode` `direct_post.jwt`, JWE-seals it to the verifier's
/// encryption key. Keeps the response-encoding / `JWE`/`JWK` concerns out of the wallet service.
enum OID4VPResponseUtil
{
    private static let responseModeDirectPostJWT = "direct_post.jwt"

    /// Assembles the OID4VP authorization response (`{vp_token, state}`) as an
    /// `application/x-www-form-urlencoded` body, JWE-sealing it to the verifier's key when
    /// `response_mode` is `direct_post.jwt`. No networking — `JWE`/`JWK` stay internal to the SDK.
    /// - Parameters:
    ///   - authRequest: The parsed authorization request.
    ///   - vpToken: The built `vp_token` map (DCQL query id -> presentation values).
    /// - Returns: The ready-to-send form body (clear for `direct_post`, JWE-wrapped for
    ///   `direct_post.jwt`).
    /// - Throws: a response-encryption error when `direct_post.jwt` is requested but the verifier's
    ///           key/parameters are missing or unsupported.
    static func encodeResponseBody(
        authRequest: AuthorizationRequest,
        vpToken: [String: [AnyJSON]]
    ) throws -> Data
    {
        if authRequest.responseMode == responseModeDirectPostJWT
        {
            let (jwk, enc) = try parseResponseEncryption(from: authRequest.clientMetadata)
            let payload = try VPTokenSubmission(vpToken: vpToken, state: authRequest.state).toJsonData()
            let compactJWE = try JWE.encrypt(plaintext: payload, to: jwk, enc: enc)
            return try EncryptedResponseSubmission(response: compactJWE).toFormData()
        }
        else
        {
            return try VPTokenSubmission(vpToken: vpToken, state: authRequest.state).toFormData()
        }
    }

    /// Extracts the verifier's response-encryption key and content-encryption algorithm from the
    /// authorization request's `client_metadata` (OpenID4VP 1.0).
    ///
    /// The `enc` is chosen from `encrypted_response_enc_values_supported` (preferring `A256GCM`,
    /// then `A128GCM`; defaulting to `A256GCM` when the list is absent). The key is taken from
    /// `jwks.keys`, preferring an `EC` / `P-256` key marked `use: "enc"`. Only key agreement
    /// `ECDH-ES` (Direct) is supported, matching `JWE.encrypt`; anything else throws.
    static func parseResponseEncryption(
        from clientMetadata: [String: AnyJSON]
    ) throws -> (jwk: JWK, enc: JWE.JWEEncryption)
    {
        let enc = try selectResponseEncAlgorithm(from: clientMetadata)

        guard let keys = clientMetadata["jwks"]?.asObject?["keys"]?.asArray
        else
        {
            throw OID4VCManagerError.missingVerifierEncryptionKey.getError()
        }

        let ecKeys: [JWK] = keys.compactMap { entry in
            guard let object = entry.asObject,
                  let data = try? JSONSerialization.data(
                    withJSONObject: AnyJSON.object(object).toFoundation()
                  ),
                  let jwk = try? JWK(from: data),
                  jwk.kty == .ec, jwk.crv == .p256
            else
            {
                return nil
            }
            return jwk
        }

        guard let jwk = ecKeys.first(where: { $0.use == .enc }) ?? ecKeys.first
        else
        {
            throw OID4VCManagerError.missingVerifierEncryptionKey.getError()
        }

        // The key-agreement alg comes from the JWK; nil is treated as the ECDH-ES default for EC
        // encryption keys. Key wrapping (ECDH-ES+A*KW) and other algs are not supported.
        if let alg = jwk.alg, alg != .ecdhES
        {
            throw OID4VCManagerError.unsupportedResponseEncryption(detail: "alg: \(alg)").getError()
        }

        return (jwk, enc)
    }

    private static func selectResponseEncAlgorithm(
        from clientMetadata: [String: AnyJSON]
    ) throws -> JWE.JWEEncryption
    {
        guard let supported = clientMetadata["encrypted_response_enc_values_supported"]?.asArray
        else
        {
            return .a256GCM
        }

        let values = supported.compactMap { $0.asString }
        if values.contains(JWE.JWEEncryption.a256GCM.rawValue) { return .a256GCM }
        if values.contains(JWE.JWEEncryption.a128GCM.rawValue) { return .a128GCM }
        if values.isEmpty { return .a256GCM }
        throw OID4VCManagerError.unsupportedResponseEncryption(detail: "enc: \(values.joined(separator: ", "))").getError()
    }
}

/// Form body for an OID4VP `direct_post`: the `vp_token` JSON object plus the echoed `state`.
struct VPTokenSubmission: Jsonable
{
    let vpToken: [String: [AnyJSON]]
    let state: String

    enum CodingKeys: String, CodingKey
    {
        case vpToken = "vp_token"
        case state
    }
}

/// Form body for an OID4VP `direct_post.jwt`: the JWE-encrypted authorization response.
struct EncryptedResponseSubmission: Jsonable
{
    let response: String
}
