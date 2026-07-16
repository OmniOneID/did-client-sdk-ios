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
    /// Finds which stored credentials satisfy the presentation request's DCQL query — the app-facing
    /// entry point.
    ///
    /// The SDK reads the request's credential `format` (from `dcql_query.credentials[]`) and gathers
    /// the matching wallet store itself — W3C via `WalletAPI.getAllCredentials`, SD-JWT via
    /// `WalletAPI.getAllOID4VCs` — so the caller only supplies a wallet token, not the credentials.
    /// A request is assumed to target a single format (W3C and SD-JWT are not mixed); a missing or
    /// mixed format throws. Internally it dispatches to the format-specific overloads below.
    /// - Parameters:
    ///   - hWalletToken: Wallet access token used to read the stored credentials.
    ///   - authRequest: The parsed authorization request (from `getAuthorizationRequest`).
    /// - Returns: Map of DCQL query id -> matched `ClaimInfo` list, ready to pass to `createVpToken`.
    /// - Throws: `unsupportedPresentationFormat` (missing/mixed/unknown format), `invalidDCQLQuery`,
    ///           `noEligibleCredentials`, `credentialSetsNotSatisfied`.
    public static func findEligibleSubmittables(
        hWalletToken: String,
        authRequest: AuthorizationRequest
    ) throws -> [ClientID: [ClaimInfo]]
    {
        let formats = Set((authRequest.dcqlQuery.credentials ?? []).compactMap { $0.format })
        guard formats.count == 1, let format = formats.first
        else
        {
            throw OID4VPError.unsupportedPresentationFormat(
                formats.isEmpty
                    ? "no credential format in DCQL query"
                    : "mixed credential formats are not supported: \(formats.sorted().joined(separator: ", "))"
            )
        }

        if format == VerifiableCredentialAdapter.format
        {
            let vcs = try WalletAPI.shared.getAllCredentials(hWalletToken: hWalletToken) ?? []
            return try findEligibleSubmittables(authRequest: authRequest, credentials: vcs)
        }
        else if SDJWTPresenter.supportedFormats.contains(format)
        {
            let items = try WalletAPI.shared.getAllOID4VCs(hWalletToken: hWalletToken)
            return try findEligibleSubmittables(authRequest: authRequest, sdJwtCredentials: items)
        }
        else
        {
            throw OID4VPError.unsupportedPresentationFormat(format)
        }
    }

    /// Format-specific overload for W3C (`opendid_vc`) credentials, matched by DCQL `meta`
    /// (credential schema id) + claim queries. The unified `hWalletToken` entry point dispatches here
    /// after reading the W3C wallet; a caller holding its own credentials may use it directly.
    public static func findEligibleSubmittables(
        authRequest: AuthorizationRequest,
        credentials: [VerifiableCredential]
    ) throws -> [ClientID: [ClaimInfo]]
    {
        let queries = try validatedQueries(authRequest)
        let infos = DCQLCredentialMatcher.getMatchedMetadata(credentials: credentials, queries: queries)
        return try finalize(infos, authRequest: authRequest)
    }

    /// Format-specific overload for SD-JWT (`dc+sd-jwt-did`) credentials. Each item's `sdjwt` is
    /// parsed via the SD-JWT adapter and matched against the DCQL query (format + meta +
    /// trusted_authorities + claims/claim_sets). The unified `hWalletToken` entry point dispatches
    /// here after reading the SD-JWT wallet; a caller holding its own credentials may use it directly.
    public static func findEligibleSubmittables(
        authRequest: AuthorizationRequest,
        sdJwtCredentials: [SdJwtCredentialItem]
    ) throws -> [ClientID: [ClaimInfo]]
    {
        let queries = try validatedQueries(authRequest)
        let adapter = SDJWTCredentialAdapter()
        let parsed: [(id: String, credential: ParsedCredential)] = try sdJwtCredentials.map {
            (id: $0.id, credential: try adapter.parse($0.sdjwt.toString()))
        }
        let infos = DCQLCredentialMatcher.getMatchedSubmittables(parsedCredentials: parsed, queries: queries)
        return try finalize(infos, authRequest: authRequest)
    }

    // MARK: - Shared matching scaffolding

    /// Validates the request's DCQL query and returns its credential queries.
    private static func validatedQueries(
        _ authRequest: AuthorizationRequest
    ) throws -> [DCQLQuery.CredentialQuery]
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
        return queries
    }

    /// Common tail for every matching overload: rejects an empty match set and enforces the
    /// request's `credential_sets` before returning.
    private static func finalize(
        _ infos: [ClientID: [ClaimInfo]],
        authRequest: AuthorizationRequest
    ) throws -> [ClientID: [ClaimInfo]]
    {
        if infos.isEmpty
        {
            throw OID4VPError.noEligibleCredentials
        }
        try requireCredentialSetsSatisfied(authRequest.dcqlQuery, satisfiedQueryIds: Set(infos.keys))
        return infos
    }

    /// Gates matching on the request's `credential_sets`: every required set must have at least one
    /// option whose credential query ids are all among `satisfiedQueryIds` (the ids that matched).
    /// This operates purely on DCQL credential query ids, so it is credential-format-agnostic.
    /// No-op when the request has no `credential_sets`.
    /// - Throws: `OID4VPError.credentialSetsNotSatisfied` if a required set has no satisfiable option.
    private static func requireCredentialSetsSatisfied(
        _ dcqlQuery: DCQLQuery,
        satisfiedQueryIds: Set<String>
    ) throws
    {
        let errors = DCQLCredentialMatcher.validateCredentialSetsSatisfied(
            credentialSets: dcqlQuery.credentialSets,
            presentedCredentialIds: satisfiedQueryIds
        )
        if !errors.isEmpty
        {
            throw OID4VPError.credentialSetsNotSatisfied(errors.joined(separator: "; "))
        }
    }

}

extension OID4VPProtocol
{
    /// Builds the `vp_token` map (DCQL query id -> presentation strings) from matched submittables.
    ///
    /// Each DCQL query id is presented by the `CredentialPresenter` for that query's
    /// `dcql_query.credentials[].format` (SD-JWT and W3C `opendid_vc` in Phase 1; mdoc deferred to
    /// Phase 2 and throws `unsupportedPresentationFormat`). Both presenters reach the wallet through
    /// `WalletAPI` (hence `hWalletToken`): SD-JWT fetches via `WalletAPI.getOID4VCs` and signs a
    /// key-binding JWT, while W3C builds the VP via `WalletAPI.createVp`. `claimInfos.claimCodes` are
    /// the claims the holder agreed to disclose (empty = disclose all). The result is ready to pass
    /// to `submitVpToken`.
    /// - Parameters:
    ///   - hWalletToken: Wallet access token; both presenters need it to reach the wallet through
    ///     `WalletAPI` (SD-JWT credential fetch and W3C VP build both verify it).
    ///   - authRequest: The parsed authorization request (from `getAuthorizationRequest`).
    ///   - submittables: The matched credentials/claims (from `findEligibleSubmittables`).
    ///   - pin: The wallet PIN when unlocking with a passcode; `nil` for biometric. The holder
    ///     signing key is resolved by the SDK — SD-JWT uses the key bound to the credential at
    ///     issuance (`SdJwtCredentialItem.kid`), W3C derives it from `pin` presence.
    /// - Returns: Map of DCQL query id -> presentation token strings.
    public static func createVpToken(
        hWalletToken: String,
        authRequest: AuthorizationRequest,
        submittables: [ClientID: [ClaimInfo]],
        pin: String? = nil
    ) throws -> [String: [String]]
    {
        var vpToken: [String: [String]] = [:]
        for (dcqlId, claimInfos) in submittables
        {
            let format = try presentationFormat(for: dcqlId, in: authRequest)

            guard let presenter = CredentialPresenterRegistry.shared.findPresenter(format)
            else
            {
                throw OID4VPError.unsupportedPresentationFormat(format)
            }

            vpToken[dcqlId] = try presenter.createVpTokens(
                hWalletToken: hWalletToken,
                claimInfos: claimInfos,
                authRequest: authRequest,
                pin: pin
            )
        }
        return vpToken
    }

    /// Resolves a DCQL query id to its requested credential `format` from the authorization
    /// request's `dcql_query.credentials`. This is the branch point for per-format presentation:
    /// the matcher keys `submittables` by the same query id.
    private static func presentationFormat(
        for dcqlId: String,
        in authRequest: AuthorizationRequest
    ) throws -> String
    {
        guard let query = authRequest.dcqlQuery.credentials?.first(where: { $0.id == dcqlId }),
              let format = query.format
        else
        {
            throw OID4VPError.unsupportedPresentationFormat("missing format for query '\(dcqlId)'")
        }
        return format
    }

    /// Response modes carried in the authorization request's `response_mode`.
    static let responseModeDirectPost    = "direct_post"
    static let responseModeDirectPostJWT = "direct_post.jwt"

    /// Submits the `vp_token` map to the verifier's `response_uri` as
    /// `application/x-www-form-urlencoded`.
    ///
    /// When `response_mode` is `direct_post` the body is the clear `vp_token` (JSON object) plus the
    /// echoed `state`. When it is `direct_post.jwt` the `{vp_token, state}` object is JWE-encrypted
    /// (ECDH-ES + AES-GCM) to the verifier's encryption key from `client_metadata` and sent as a
    /// single `response` field.
    /// - Returns: The raw verifier response body and HTTP status code.
    /// - Throws: `OID4VPError.failedToSubmit` on a non-2xx response, or a response-encryption error
    ///           when `direct_post.jwt` is requested but the verifier's key/parameters are missing
    ///           or unsupported.
    @discardableResult
    public static func submitVpToken(
        authRequest: AuthorizationRequest,
        vpToken: [String: [String]]
    ) async throws -> (Data, Int)
    {
        let body: Data
        if authRequest.responseMode == responseModeDirectPostJWT
        {
            let (jwk, enc) = try parseResponseEncryption(from: authRequest.clientMetadata)
            let payload = try VPTokenSubmission(vpToken: vpToken, state: authRequest.state).toJsonData()
            let compactJWE = try JWE.encrypt(plaintext: payload, to: jwk, enc: enc)
            body = try EncryptedResponseSubmission(response: compactJWE).toFormData()
        }
        else
        {
            body = try VPTokenSubmission(vpToken: vpToken, state: authRequest.state).toFormData()
        }

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
            throw OID4VPError.missingVerifierEncryptionKey
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
            throw OID4VPError.missingVerifierEncryptionKey
        }

        // The key-agreement alg comes from the JWK; nil is treated as the ECDH-ES default for EC
        // encryption keys. Key wrapping (ECDH-ES+A*KW) and other algs are not supported.
        if let alg = jwk.alg, alg != .ecdhES
        {
            throw OID4VPError.unsupportedResponseEncryption("alg: \(alg)")
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
        throw OID4VPError.unsupportedResponseEncryption("enc: \(values.joined(separator: ", "))")
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

/// Form body for an OID4VP `direct_post.jwt`: the JWE-encrypted authorization response.
struct EncryptedResponseSubmission: Jsonable
{
    let response: String
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
    /// The request's `credential_sets` cannot be satisfied by the matched credentials — at least
    /// one required set has no fully-satisfiable option. Carries the per-set detail.
    case credentialSetsNotSatisfied(String)
    /// The holder signing key required for the key-binding JWT was not found. Carries the key id.
    case holderKeyNotFound(String)
    /// A matched credential id was not found in the wallet store. Carries the id.
    case credentialNotFound(String)
    /// The matched credential's format has no presentation builder yet. Carries the format token.
    case unsupportedPresentationFormat(String)
    /// Submitting the vp_token to the verifier failed. Carries the HTTP status code.
    case failedToSubmit(Int)
    /// `direct_post.jwt` was requested but no usable verifier encryption key was found in
    /// `client_metadata.jwks`.
    case missingVerifierEncryptionKey
    /// The verifier's requested response encryption is not supported. Carries the offending
    /// alg/enc detail.
    case unsupportedResponseEncryption(String)

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
        case .credentialSetsNotSatisfied(let detail):
            return "Required credential_sets not satisfied: \(detail)"
        case .holderKeyNotFound(let keyId):
            return "Holder signing key '\(keyId)' not found."
        case .credentialNotFound(let id):
            return "Matched credential '\(id)' not found in the wallet."
        case .unsupportedPresentationFormat(let format):
            return "Presentation for format \(format) is not supported."
        case .failedToSubmit(let status):
            return "Failed to submit vp_token (HTTP \(status))."
        case .missingVerifierEncryptionKey:
            return "No verifier encryption key found in client_metadata for direct_post.jwt."
        case .unsupportedResponseEncryption(let detail):
            return "Unsupported response encryption (\(detail))."
        }
    }
}
