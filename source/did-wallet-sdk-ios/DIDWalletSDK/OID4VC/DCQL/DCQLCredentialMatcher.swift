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

// MARK: - DCQL Path Element

public enum DCQLPathElement: Codable, Hashable {
    case key(String)
    case index(Int)
    case wildcard   // corresponds to null in Java path list

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .wildcard; return }
        if let i = try? c.decode(Int.self) { self = .index(i); return }
        if let s = try? c.decode(String.self) { self = .key(s); return }
        throw DecodingError.typeMismatch(
            DCQLPathElement.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Path element must be string, int, or null")
        )
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .wildcard: try c.encodeNil()
        case .index(let i): try c.encode(i)
        case .key(let s): try c.encode(s)
        }
    }
}



/// Identifier of a DCQL credential query (`CredentialQuery.id`), used as the key
/// of a presentation submission and the `vp_token` map sent to the verifier.
public typealias ClientID = String

public enum DCQLCredentialMatcher {

    /// Matches stored credentials against a DCQL query by credential schema id.
    ///
    /// For each `CredentialQuery`, the credentials whose `credentialSchema.id` is listed in the
    /// query's `meta["credential_schema_id_values"]` are collected and returned as `ClaimInfo`
    /// entries keyed by the query id. `claimCodes` is left empty (= disclose all claims); per-claim
    /// selective disclosure based on `query.claims` is not yet implemented.
    /// - Parameters:
    ///   - credentials: Stored credentials to match (provided by the caller).
    ///   - queries: The `credentials` array of the DCQL query.
    /// - Returns: Map of query id -> matched `ClaimInfo` list. Queries with no match are omitted.
    public static func getMatchedMetadata(
        credentials: [VerifiableCredential],
        queries: [DCQLQuery.CredentialQuery]
    ) -> [ClientID: [ClaimInfo]] {

        var infos: [ClientID: [ClaimInfo]] = [:]

        for query in queries {
            guard let id = query.id,
                  let meta = query.meta,
                  let schemaIDs = meta["credential_schema_id_values"]?.asArray
            else {
                continue
            }

            let schemas = schemaIDs.compactMap { $0.asString }
            let matched = credentials.filter { schemas.contains($0.credentialSchema.id) }

            if matched.isEmpty {
                continue
            }

            let claimInfos: [ClaimInfo]
            if let claimQueries = query.claims {
                // Per-claim selective disclosure: keep only credentials that satisfy every
                // claim query, and disclose just the matched claim codes.
                claimInfos = matched.compactMap { vc in
                    guard let codes = matchedClaimCodes(credential: vc, claimQueries: claimQueries)
                    else { return nil }
                    return ClaimInfo(credentialId: vc.id, claimCodes: codes)
                }
            } else {
                // No claim constraints: disclose all claims (claimCodes empty).
                claimInfos = matched.map { ClaimInfo(credentialId: $0.id, claimCodes: []) }
            }

            if claimInfos.isEmpty {
                continue
            }
            infos[id] = claimInfos
        }

        return infos
    }

    /// Returns the VC claim codes that satisfy every claim query, or `nil` if the credential does
    /// not satisfy all of them (and is therefore ineligible). Reuses the JSON path / condition
    /// matching engine over a flat `[code: value]` map built from the credential.
    static func matchedClaimCodes(
        credential: VerifiableCredential,
        claimQueries: [DCQLQuery.ClaimQuery]
    ) -> [String]? {
        let allClaims = buildClaimsMap(credential)
        var collected: Set<String> = []

        for claimQuery in claimQueries {
            guard claimQuery.path?.isEmpty == false else { continue }
            // Single shared path/condition engine (ClaimMatchingHelper); a query that matches
            // nothing means a required claim is unsatisfied, so the credential is ineligible.
            let perQuery = ClaimMatchingHelper.extractMatchingClaimsByPath(
                allClaims: allClaims, claimQueries: [claimQuery])
            if perQuery.isEmpty {
                return nil
            }
            collected.formUnion(perQuery)
        }

        return collected.sorted()
    }

    /// Flattens a credential's claims into a `[code: value]` map. Because OmniOne credentials store
    /// claims as a flat `code`/`value` list, a matched claim name equals its claim code, so the
    /// matcher's output can be used directly as `ClaimInfo.claimCodes`.
    private static func buildClaimsMap(_ credential: VerifiableCredential) -> [String: Any] {
        var map: [String: Any] = [:]
        for claim in credential.credentialSubject.claims {
            map[claim.code] = claim.value
        }
        return map
    }

    // MARK: - Format-agnostic matching (adapter-based)

    private static var registry: CredentialAdapterRegistry { CredentialAdapterRegistry.shared }

    /// Whether the required format is supported by some registered adapter.
    public static func isFormatSupported(_ requiredFormat: String?) -> Bool {
        guard let requiredFormat = requiredFormat else { return true }
        return registry.isFormatSupported(requiredFormat)
    }

    /// Parses a raw credential string into a `ParsedCredential` via the appropriate adapter.
    public static func parseCredential(rawCredential: String, format: String?) throws -> ParsedCredential {
        let adapter = format != nil ? registry.findAdapter(format!) : registry.detectAdapter(rawCredential)
        guard let adapter = adapter else {
            throw DCQLError.adapterNotFound("No adapter for format: \(format ?? "unknown")")
        }
        return try adapter.parse(rawCredential)
    }

    /// Whether the credential matches the DCQL `meta` requirements (delegated to its adapter).
    public static func matchesMetadata(credential: ParsedCredential, metadata: [String: AnyJSON]?) -> Bool {
        guard let metadata = metadata, !metadata.isEmpty else { return true }
        guard let adapter = registry.findAdapter(credential.format) else { return false }
        return adapter.matchesMetadata(credential, metadata: metadata.mapValues { $0.toFoundation() })
    }

    /// Whether the credential's issuer matches the trusted authorities (delegated to its adapter).
    public static func matchesTrustedAuthorities(credential: ParsedCredential,
                                                 trustedAuthorities: [DCQLQuery.TrustedAuthority]?) -> Bool {
        guard let ta = trustedAuthorities, !ta.isEmpty else { return true }
        guard let adapter = registry.findAdapter(credential.format) else { return false }
        return adapter.matchesTrustedAuthorities(credential, trustedAuthorities: ta)
    }

    /// Returns the claim names to disclose if `credential` satisfies `query` (format + meta +
    /// trusted authorities + claims/claim_sets), or `nil` if it does not (ineligible).
    /// An empty returned set means "no claim constraint" → disclose all claims.
    static func eligibleClaimNames(query: DCQLQuery.CredentialQuery,
                                   credential: ParsedCredential) -> Set<String>? {
        // Format
        if let f = query.format {
            guard let adapter = registry.findAdapter(f), adapter.supports(credential.format) else {
                return nil
            }
        }
        // Metadata
        if !matchesMetadata(credential: credential, metadata: query.meta) { return nil }
        // Trusted authorities
        if !matchesTrustedAuthorities(credential: credential, trustedAuthorities: query.trustedAuthorities) {
            return nil
        }
        guard let adapter = registry.findAdapter(query.format ?? credential.format) else { return nil }

        // claim_sets (OID4VP 1.0 §6.4): each option is an array of claim ids referencing
        // `claims[].id`. The options are alternatives (OR); the first option whose every referenced
        // claim is satisfiable wins.
        if let claimSets = query.claimSets, !claimSets.isEmpty {
            let claimsById: [String: DCQLQuery.ClaimQuery] = (query.claims ?? []).reduce(into: [:]) { acc, claim in
                if let id = claim.id { acc[id] = claim }
            }
            for option in claimSets {
                // Resolve every id in the option; skip the option if any id is undefined.
                let resolved = option.compactMap { claimsById[$0] }
                guard resolved.count == option.count, !resolved.isEmpty else { continue }
                if let matched = matchAllClaims(resolved, adapter: adapter, credential: credential) {
                    return matched
                }
            }
            return nil
        }
        // claims (AND of all claim queries)
        if let claims = query.claims, !claims.isEmpty {
            return matchAllClaims(claims, adapter: adapter, credential: credential)
        }
        // No claim constraint → all claims
        return []
    }

    /// Union of matched claim names if EVERY claim query matched at least one claim; else nil.
    private static func matchAllClaims(_ claims: [DCQLQuery.ClaimQuery],
                                       adapter: CredentialAdapter,
                                       credential: ParsedCredential) -> Set<String>? {
        var union: Set<String> = []
        for claim in claims {
            let matched = adapter.extractMatchingClaims(credential, claimQueries: [claim])
            if matched.isEmpty { return nil }
            union.formUnion(matched)
        }
        return union
    }

    /// Format-agnostic matching entry point. Each supplied credential carries a caller-defined id
    /// (e.g. a wallet credential id) that is echoed back in `ClaimInfo.credentialId`.
    /// `claimCodes` are the matched claim names (== claim codes for opendid_vc); empty = all claims.
    public static func getMatchedSubmittables(
        parsedCredentials: [(id: String, credential: ParsedCredential)],
        queries: [DCQLQuery.CredentialQuery]
    ) -> [ClientID: [ClaimInfo]] {
        var infos: [ClientID: [ClaimInfo]] = [:]
        for query in queries {
            guard let id = query.id else { continue }
            var claimInfos: [ClaimInfo] = []
            for (credId, cred) in parsedCredentials {
                guard let names = eligibleClaimNames(query: query, credential: cred) else { continue }
                claimInfos.append(ClaimInfo(credentialId: credId, claimCodes: names.sorted()))
            }
            if claimInfos.isEmpty { continue }
            infos[id] = claimInfos
        }
        return infos
    }

    /// Validates that presented credential ids satisfy at least one option of each required
    /// `credential_set`. Returns error messages (empty == satisfied).
    public static func validateCredentialSetsSatisfied(credentialSets: [DCQLQuery.CredentialSet]?,
                                                       presentedCredentialIds: Set<String>) -> [String] {
        guard let credentialSets = credentialSets, !credentialSets.isEmpty else { return [] }
        var errors: [String] = []
        for credentialSet in credentialSets {
            if !(credentialSet.required ?? true) { continue }
            var anySatisfied = false
            for option in credentialSet.options ?? [] {
                if Set(option).isSubset(of: presentedCredentialIds) { anySatisfied = true; break }
            }
            if !anySatisfied {
                errors.append("credential_set '\(credentialSet.id ?? "(unnamed)")' not satisfied")
            }
        }
        return errors
    }
}

extension DCQLCredentialMatcher
{
    /// Matches stored W3C credentials against the request's DCQL query: validates the query, runs
    /// the metadata match, then enforces the request's `credential_sets`.
    /// - Returns: Map of DCQL query id -> matched `ClaimInfo` list.
    /// - Throws: `OID4VPError.invalidDCQLQuery`, `.noEligibleCredentials`, `.credentialSetsNotSatisfied`.
    static func matchCredentials(authRequest: AuthorizationRequest,
                                 credentials: [VerifiableCredential]) throws -> [ClientID: [ClaimInfo]]
    {
        let queries = try validatedQueries(authRequest)
        let infos = getMatchedMetadata(credentials: credentials, queries: queries)
        return try finalize(infos, authRequest: authRequest)
    }

    /// Matches stored SD-JWT credentials against the request's DCQL query: parses each SD-JWT via the
    /// adapter, runs the submittable match, then enforces the request's `credential_sets`.
    static func matchCredentials(authRequest: AuthorizationRequest,
                                 sdJwtCredentials: [SdJwtCredentialItem]) throws -> [ClientID: [ClaimInfo]]
    {
        let queries = try validatedQueries(authRequest)
        let adapter = SDJWTCredentialAdapter()
        let parsed: [(id: String, credential: ParsedCredential)] = try sdJwtCredentials.map {
            (id: $0.id, credential: try adapter.parse($0.sdjwt.toString()))
        }
        let infos = getMatchedSubmittables(parsedCredentials: parsed, queries: queries)
        return try finalize(infos, authRequest: authRequest)
    }

    /// Validates the request's DCQL query and returns its credential queries.
    private static func validatedQueries(
        _ authRequest: AuthorizationRequest
    ) throws -> [DCQLQuery.CredentialQuery]
    {
        let validation = DCQLQueryValidator.validate(authRequest.dcqlQuery)
        if !validation.isValid()
        {
            throw OID4VCManagerError.invalidDCQLQuery(detail: validation.errors.joined(separator: "; ")).getError()
        }
        guard let queries = authRequest.dcqlQuery.credentials
        else
        {
            throw OID4VCManagerError.invalidDCQLQuery(detail: "missing 'credentials' in DCQL query").getError()
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
            throw OID4VCManagerError.noMatchedCredentials.getError()
        }
        try requireCredentialSetsSatisfied(authRequest.dcqlQuery, satisfiedQueryIds: Set(infos.keys))
        return infos
    }

    /// Gates matching on the request's `credential_sets`: every required set must have at least one
    /// option whose credential query ids are all among `satisfiedQueryIds` (the ids that matched).
    /// This operates purely on DCQL credential query ids, so it is credential-format-agnostic.
    /// No-op when the request has no `credential_sets`.
    private static func requireCredentialSetsSatisfied(
        _ dcqlQuery: DCQLQuery,
        satisfiedQueryIds: Set<String>
    ) throws
    {
        let errors = validateCredentialSetsSatisfied(
            credentialSets: dcqlQuery.credentialSets,
            presentedCredentialIds: satisfiedQueryIds
        )
        if !errors.isEmpty
        {
            throw OID4VCManagerError.credentialSetsNotSatisfied(detail: errors.joined(separator: "; ")).getError()
        }
    }
}

