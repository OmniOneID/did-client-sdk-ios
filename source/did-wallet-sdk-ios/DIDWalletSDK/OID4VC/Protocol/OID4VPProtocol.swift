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

public struct OID4VPProtocol
{
    static let schemaIdValues : String = "credential_schema_id_values"
    static let vctValus       : String = "vct_values"
    
    public static func getAuthorizationRequest(uri : String) async throws -> AuthorizationRequest
    {
        guard
            let components = URLComponents(string: uri),
            let requestURI = components.queryItems?
                .first(where: { $0.name == "request_uri" })?
                .value
        else
        {
            throw OID4VPError.invalidRequestURI
        }
        
        let (encodedData, statusCode) = try await CommunicationClient.sendRequest(
            urlString: requestURI,
            httpMethod: .GET
        )
        
        if statusCode != 200
        {
            throw OID4VPError.failedToFetchJWS
        }
        let jws = JWS(from: String(data: encodedData, encoding: .utf8)!)
        if try jws.verify() == false
        {
            throw OID4VPError.failedToVerifyJWS
        }
        
        return try jws.getPayload()
        
    }
}

extension OID4VPProtocol
{
    /// Finds which stored credentials satisfy the presentation request's DCQL query.
    ///
    /// The credentials are supplied by the caller (e.g. `WalletAPI.getAllCredentials`); this layer
    /// is stateless and holds no wallet token. The returned map keys are DCQL query ids and the
    /// values are `ClaimInfo` lists ready to pass to `WalletAPI.createVp`. VP creation and
    /// submission to the verifier are the caller's responsibility.
    /// - Parameters:
    ///   - authRequest: The parsed authorization request (from `getAuthorizationRequest`).
    ///   - credentials: The holder's stored credentials.
    /// - Returns: Map of DCQL query id -> matched `ClaimInfo` list.
    /// - Throws: `OID4VPError.invalidDCQLQuery` if the query is invalid,
    ///           `OID4VPError.noEligibleCredentials` if nothing matches.
    public static func findEligibleSubmittables(
        authRequest: AuthorizationRequest,
        credentials: [VerifiableCredential]
    ) throws -> [ClientID: [ClaimInfo]]
    {
        let validation = DCQLQueryValidator.validate(authRequest.dcqlQuery)
        if !validation.isValid()
        {
            throw OID4VPError.invalidDCQLQuery(validation.errors.joined(separator: "; "))
        }

        guard let queries = authRequest.dcqlQuery.credentials
        else
        {
            throw OID4VPError.invalidDCQLQuery("missing 'credentials' in DCQL query")
        }

        let infos = DCQLCredentialMatcher.getMatchedMetadata(credentials: credentials, queries: queries)

        if infos.isEmpty
        {
            throw OID4VPError.noEligibleCredentials
        }

        return infos
    }

    /// Multi-format variant: matches caller-supplied credentials (already parsed to
    /// `ParsedCredential` via `DCQLCredentialMatcher.parseCredential` or adapter `from`) against the
    /// request's DCQL query (format + meta + trusted_authorities + claims/claim_sets). Each entry's
    /// `id` is echoed back as `ClaimInfo.credentialId`. `claimCodes` empty = disclose all claims.
    public static func findEligibleSubmittables(
        authRequest: AuthorizationRequest,
        parsedCredentials: [(id: String, credential: ParsedCredential)]
    ) throws -> [ClientID: [ClaimInfo]]
    {
        let validation = DCQLQueryValidator.validate(authRequest.dcqlQuery)
        if !validation.isValid()
        {
            throw OID4VPError.invalidDCQLQuery(validation.errors.joined(separator: "; "))
        }

        guard let queries = authRequest.dcqlQuery.credentials
        else
        {
            throw OID4VPError.invalidDCQLQuery("missing 'credentials' in DCQL query")
        }

        let infos = DCQLCredentialMatcher.getMatchedSubmittables(parsedCredentials: parsedCredentials,
                                                                 queries: queries)
        if infos.isEmpty
        {
            throw OID4VPError.noEligibleCredentials
        }
        return infos
    }

    /// Convenience over the `ParsedCredential` variant: parses raw multi-format credentials
    /// (SD-JWT compact, opendid_vc JSON, …) via the adapter registry, then matches.
    public static func findEligibleSubmittables(
        authRequest: AuthorizationRequest,
        rawCredentials: [(id: String, raw: String, format: String?)]
    ) throws -> [ClientID: [ClaimInfo]]
    {
        let parsed: [(id: String, credential: ParsedCredential)] = try rawCredentials.map {
            (id: $0.id,
             credential: try DCQLCredentialMatcher.parseCredential(rawCredential: $0.raw, format: $0.format))
        }
        return try findEligibleSubmittables(authRequest: authRequest, parsedCredentials: parsed)
    }

}

extension OID4VPProtocol
{
    /// Builds the `vp_token` map (DCQL query id -> presentation strings) from matched submittables.
    ///
    /// Raw credentials are fetched from `IssuedCredentialManager` by `ClaimInfo.credentialId`; each
    /// entry's `claimCodes` are the claims the holder agreed to disclose (empty = disclose all).
    /// SD-JWT is supported now; mdoc (`mso_mdoc`) is deferred (Phase 2) and throws
    /// `unsupportedPresentationFormat`. The result is ready to pass to `submitVpToken`.
    /// - Parameters:
    ///   - authRequest: The parsed authorization request (from `getAuthorizationRequest`).
    ///   - submittables: The matched credentials/claims (from `findEligibleSubmittables`).
    ///   - keyId: The holder key id (`"pin"` / `"bio"`).
    ///   - pin: The wallet PIN as data for the PIN key; `nil` for biometric.
    /// - Returns: Map of DCQL query id -> presentation token strings.
    public static func createVpToken(
        authRequest: AuthorizationRequest,
        submittables: [ClientID: [ClaimInfo]],
        keyId: String,
        pin: Data? = nil
    ) throws -> [String: [String]]
    {
        let store = try IssuedCredentialManager()

        var vpToken: [String: [String]] = [:]
        for (dcqlId, claimInfos) in submittables
        {
            var tokens: [String] = []
            for claimInfo in claimInfos
            {
                guard let credential = try store.getCredentials(by: [claimInfo.credentialId]).first
                else
                {
                    throw OID4VPError.credentialNotFound(claimInfo.credentialId)
                }

                guard SDJWTPresenter.supportedFormats.contains(credential.format)
                else
                {
                    throw OID4VPError.unsupportedPresentationFormat(credential.format)
                }

                let token = try SDJWTPresenter.createVpToken(
                    rawCredential: credential.credential,
                    claimCodes: claimInfo.claimCodes,
                    aud: authRequest.clientId,
                    nonce: authRequest.nonce,
                    keyId: keyId,
                    pin: pin
                )
                tokens.append(token)
            }
            vpToken[dcqlId] = tokens
        }
        return vpToken
    }

    /// Submits the `vp_token` map to the verifier's `response_uri` as
    /// `application/x-www-form-urlencoded` (`vp_token` = JSON object, `state` echoed back).
    /// - Returns: The raw verifier response body and HTTP status code.
    /// - Throws: `OID4VPError.failedToSubmit` on a non-2xx response.
    @discardableResult
    public static func submitVpToken(
        authRequest: AuthorizationRequest,
        vpToken: [String: [String]]
    ) async throws -> (Data, Int)
    {
        let submission = VPTokenSubmission(vpToken: vpToken, state: authRequest.state)
        let body = try submission.toFormData()

        let (data, statusCode) = try await CommunicationClient.sendPostUrlencoded(
            urlString: authRequest.responseUri,
            requestJsonData: body
        )

        guard (200...299).contains(statusCode)
        else
        {
            throw OID4VPError.failedToSubmit(statusCode)
        }
        return (data, statusCode)
    }
}

/// Form body for an OID4VP `direct_post`: the `vp_token` JSON object plus the echoed `state`.
struct VPTokenSubmission: Jsonable
{
    let vpToken: [String: [String]]
    let state: String

    enum CodingKeys: String, CodingKey
    {
        case vpToken = "vp_token"
        case state
    }
}

/// Errors thrown by the OID4VP (OpenID for Verifiable Presentations) flow.
public enum OID4VPError: Error, LocalizedError
{
    /// The presentation request URI is missing or malformed.
    case invalidRequestURI
    /// Fetching the signed authorization request (JWS) failed.
    case failedToFetchJWS
    /// The authorization request JWS signature could not be verified.
    case failedToVerifyJWS
    /// The DCQL query in the authorization request is invalid. Carries the validation summary.
    case invalidDCQLQuery(String)
    /// No stored credential satisfies the authorization request.
    case noEligibleCredentials
    /// The holder signing key required for the key-binding JWT was not found. Carries the key id.
    case holderKeyNotFound(String)
    /// A matched credential id was not found in the wallet store. Carries the id.
    case credentialNotFound(String)
    /// The matched credential's format has no presentation builder yet. Carries the format token.
    case unsupportedPresentationFormat(String)
    /// Submitting the vp_token to the verifier failed. Carries the HTTP status code.
    case failedToSubmit(Int)

    public var errorDescription: String?
    {
        switch self
        {
        case .invalidRequestURI:
            return "Invalid request URI format."
        case .failedToFetchJWS:
            return "Failed to fetch the authorization request JWS."
        case .failedToVerifyJWS:
            return "Failed to verify the authorization request JWS."
        case .invalidDCQLQuery(let detail):
            return "Invalid DCQL query: \(detail)"
        case .noEligibleCredentials:
            return "No credentials available for submission."
        case .holderKeyNotFound(let keyId):
            return "Holder signing key '\(keyId)' not found."
        case .credentialNotFound(let id):
            return "Matched credential '\(id)' not found in the wallet."
        case .unsupportedPresentationFormat(let format):
            return "Presentation for format \(format) is not supported."
        case .failedToSubmit(let status):
            return "Failed to submit vp_token (HTTP \(status))."
        }
    }
}
