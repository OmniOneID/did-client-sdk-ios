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
        }
    }
}
