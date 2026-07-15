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
            guard let path = claimQuery.path, !path.isEmpty else { continue }
            var perQuery: Set<String> = []
            processPathAndCollectClaims(allClaims: allClaims,
                                        path: path,
                                        claimQuery: claimQuery,
                                        matchingClaims: &perQuery)
            if perQuery.isEmpty {
                return nil   // a required claim condition is not satisfied by this credential
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

    public static func matchesFormat(requiredFormat: String?) -> Bool {
        guard let requiredFormat = requiredFormat else { return true }
        let supported: Set<String> = ["dc+sd-jwt-did", "vc+sd-jwt"]
        return supported.contains(requiredFormat)
    }

    public static func matchesMetadata(sdjwt: SDJWT, metadata: [String: AnyJSON]?) -> Bool {
        guard let metadata = metadata, !metadata.isEmpty else { return true }

        if let v = metadata["vct_values"] {
            // vct_values must be array of strings
            guard let required = v.asArray?.compactMap({ $0.asString }) else { return false }
            return checkVctValues(sdjwt: sdjwt, requiredVcts: required)
        }

        return true
    }

    private static func checkVctValues(sdjwt: SDJWT, requiredVcts: [String]?) -> Bool {
        guard let requiredVcts = requiredVcts, !requiredVcts.isEmpty else { return true }
        do {
            let jwt = try SimpleJWTDecoder.parse(sdjwt.credentialJwt)
            guard let vct = jwt.payload["vct"] else { 
                WalletLogger.debug("'vct' claim missing in JWT payload")
                return false 
            }
            let actual = String(describing: vct)
            WalletLogger.debug("--- checkVctValues ---")
            WalletLogger.debug("Required VCTs: \(requiredVcts)")
            WalletLogger.debug("Actual VCT: \(actual)")
            let isContained = requiredVcts.contains(actual)
            WalletLogger.debug("Match result: \(isContained)")
            WalletLogger.debug("-----------------------")
            return isContained
        } catch {
            WalletLogger.debug("SimpleJWTDecoder failed: \(error)")
            return false
        }
    }

    public static func extractMatchingClaimNames(dcqlQuery: DCQLQuery?, sdjwt: SDJWT?) -> Set<String> {
        guard let dcqlQuery = dcqlQuery, let creds = dcqlQuery.credentials, let sdjwt = sdjwt else {
            return []
        }

        var matching: Set<String> = []
        let allClaims = extractAllCredentialClaims(sdjwt: sdjwt)

        for credential in creds {
            if credential.claims == nil {
                matching.formUnion(allClaims.keys)
                continue
            }

            for claimQuery in credential.claims ?? [] {
                guard let path = claimQuery.path, !path.isEmpty else { continue }
                processPathAndCollectClaims(allClaims: allClaims,
                                           path: path,
                                           claimQuery: claimQuery,
                                           matchingClaims: &matching)
            }
        }

        return matching
    }

    private static func extractAllCredentialClaims(sdjwt: SDJWT) -> [String: Any] {
        var allClaims: [String: Any] = [:]

        if let jwt = try? SimpleJWTDecoder.parse(sdjwt.credentialJwt) {
            for (k, v) in jwt.payload where !isReservedJWTClaim(k) {
                allClaims[k] = v
            }
        }

        if !sdjwt.disclosures.isEmpty {
            for d in sdjwt.disclosures {
                if let name = d.claimName {
                    allClaims[name] = d.claimValue as Any
                }
            }
            integrateDisclosuresIntoCredential(allClaims: &allClaims, sdjwt: sdjwt)
        }

        return allClaims
    }

    private static func integrateDisclosuresIntoCredential(allClaims: inout [String: Any], sdjwt: SDJWT) {
        var digestToDisclosure: [String: Disclosure] = [:]
        for d in sdjwt.disclosures {
            digestToDisclosure[d.digest()] = d
        }

        let snapshot = allClaims
        for (claimName, claimValue) in snapshot {
            if var obj = claimValue as? [String: Any] {
                integrateDisclosuresIntoObject(parentName: claimName,
                                              parentObject: &obj,
                                              digestToDisclosure: digestToDisclosure)
                allClaims[claimName] = obj
            }
        }
    }

    private static func integrateDisclosuresIntoObject(parentName: String,
                                                       parentObject: inout [String: Any],
                                                       digestToDisclosure: [String: Disclosure]) {
        guard let sd = parentObject["_sd"] as? [Any] else { return }

        for item in sd {
            guard let digest = item as? String else { continue }
            guard let disclosure = digestToDisclosure[digest], let claimName = disclosure.claimName else { continue }

            let claimValue = disclosure.claimValue as Any
            parentObject[claimName] = claimValue

            if var nested = claimValue as? [String: Any] {
                integrateDisclosuresIntoObject(parentName: parentName + "." + claimName,
                                              parentObject: &nested,
                                              digestToDisclosure: digestToDisclosure)
                parentObject[claimName] = nested
            }
        }
    }

    private static func processPathAndCollectClaims(allClaims: [String: Any],
                                                    path: [DCQLPathElement],
                                                    claimQuery: DCQLQuery.ClaimQuery,
                                                    matchingClaims: inout Set<String>) {

        guard case .key(let topLevel) = path[0] else { return }
        guard let rootValue = allClaims[topLevel] else { return }

        if path.count == 1 {
            if meetsClaimConditions(claimQuery: claimQuery, actualValue: rootValue) {
                matchingClaims.insert(topLevel)
            }
            return
        }

        let remaining = Array(path.dropFirst())
        collectMatchingValuesFromPath(current: rootValue,
                                      remainingPath: remaining,
                                      claimQuery: claimQuery,
                                      claimNamePrefix: topLevel,
                                      matchingClaims: &matchingClaims)
    }

    private static func collectMatchingValuesFromPath(current: Any,
                                                      remainingPath: [DCQLPathElement],
                                                      claimQuery: DCQLQuery.ClaimQuery,
                                                      claimNamePrefix: String,
                                                      matchingClaims: inout Set<String>) {
        if remainingPath.isEmpty {
            if meetsClaimConditions(claimQuery: claimQuery, actualValue: current) {
                matchingClaims.insert(claimNamePrefix)
            }
            return
        }

        let next = remainingPath[0]
        let nextRemaining = Array(remainingPath.dropFirst())

        switch next {
        case .wildcard:
            guard let list = current as? [Any] else { return }
            for i in 0..<list.count {
                let newName = "\(claimNamePrefix)[\(i)]"
                collectMatchingValuesFromPath(current: list[i],
                                              remainingPath: nextRemaining,
                                              claimQuery: claimQuery,
                                              claimNamePrefix: newName,
                                              matchingClaims: &matchingClaims)
            }

        case .index(let idx):
            guard let list = current as? [Any] else { return }
            guard idx >= 0, idx < list.count else { return }
            let newName = "\(claimNamePrefix)[\(idx)]"
            collectMatchingValuesFromPath(current: list[idx],
                                          remainingPath: nextRemaining,
                                          claimQuery: claimQuery,
                                          claimNamePrefix: newName,
                                          matchingClaims: &matchingClaims)

        case .key(let key):
            guard let dict = current as? [String: Any] else { return }
            guard let nextValue = dict[key] else { return }
            let newName = "\(claimNamePrefix).\(key)"
            collectMatchingValuesFromPath(current: nextValue,
                                          remainingPath: nextRemaining,
                                          claimQuery: claimQuery,
                                          claimNamePrefix: newName,
                                          matchingClaims: &matchingClaims)
        }
    }

    private static func meetsClaimConditions(claimQuery: DCQLQuery.ClaimQuery, actualValue: Any) -> Bool {
        // Convert actualValue to AnyJSON for robust comparisons
        let actualJSON = AnyJSON.fromFoundation(actualValue) ?? .null

        if let values = claimQuery.values, !values.isEmpty {
            if !values.contains(actualJSON) { return false }
        }

        if let v = claimQuery.value {
            if actualJSON != v { return false }
        }

        if let min = claimQuery.min, !checkMinCondition(actualValue: actualJSON, minValue: min) {
            return false
        }
        if let max = claimQuery.max, !checkMaxCondition(actualValue: actualJSON, maxValue: max) {
            return false
        }

        return true
    }

    private static func checkMinCondition(actualValue: AnyJSON, minValue: AnyJSON) -> Bool {
        switch (actualValue, minValue) {
        case (.number(let a), .number(let m)):
            return a >= m
        case (.string(let a), .string(let m)):
            return a.compare(m) != .orderedAscending
        default:
            return true
        }
    }

    private static func checkMaxCondition(actualValue: AnyJSON, maxValue: AnyJSON) -> Bool {
        switch (actualValue, maxValue) {
        case (.number(let a), .number(let m)):
            return a <= m
        case (.string(let a), .string(let m)):
            return a.compare(m) != .orderedDescending
        default:
            return true
        }
    }

    private static func isReservedJWTClaim(_ claimName: String) -> Bool {
        let reserved: Set<String> = ["iss","sub","aud","exp","nbf","iat","jti","_sd_alg","_sd","cnf","vct"]
        return reserved.contains(claimName)
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

        // claim_sets (OR of alternative sets; first fully-satisfiable set wins)
        if let claimSets = query.claimSets, !claimSets.isEmpty {
            for set in claimSets {
                guard let setClaims = set.claims, !setClaims.isEmpty else { continue }
                if let matched = matchAllClaims(setClaims, adapter: adapter, credential: credential) {
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

    /// Adapter-based claim-name extraction across all credential queries for one credential.
    public static func extractMatchingClaimNames(dcqlQuery: DCQLQuery?,
                                                 credential: ParsedCredential?) -> Set<String> {
        guard let creds = dcqlQuery?.credentials, let credential = credential else { return [] }
        var matching: Set<String> = []
        for query in creds {
            if let names = eligibleClaimNames(query: query, credential: credential) {
                if names.isEmpty { matching.formUnion(credential.allClaims.keys) }
                else { matching.formUnion(names) }
            }
        }
        return matching
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

