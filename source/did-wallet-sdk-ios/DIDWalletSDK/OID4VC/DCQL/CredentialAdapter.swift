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

/// Adapter protocol for handling different credential formats during DCQL matching.
/// Implementations provide format-specific parsing and claim/metadata/issuer matching.
public protocol CredentialAdapter {

    /// Credential formats supported by this adapter (e.g., ["dc+sd-jwt", "vc+sd-jwt"]).
    func getSupportedFormats() -> Set<String>

    /// Whether this adapter supports the given credential format.
    func supports(_ format: String) -> Bool

    /// Parses a raw credential string into a `ParsedCredential`.
    func parse(_ rawCredential: String) throws -> ParsedCredential

    /// Whether the credential matches the given DCQL `meta` requirements (Foundation-typed).
    func matchesMetadata(_ credential: ParsedCredential, metadata: [String: Any]) -> Bool

    /// All claims (including disclosed) from the credential.
    func extractAllClaims(_ credential: ParsedCredential) -> [String: Any]

    /// Reserved claim names for this format (JWT standard claims / format metadata).
    func getReservedClaimNames() -> Set<String>

    /// Matching claim names for the given DCQL claim queries (format-specific).
    func extractMatchingClaims(_ credential: ParsedCredential, claimQueries: [DCQLQuery.ClaimQuery]) -> Set<String>

    /// Whether the credential's issuer matches any of the trusted authorities.
    func matchesTrustedAuthorities(_ credential: ParsedCredential,
                                   trustedAuthorities: [DCQLQuery.TrustedAuthority]) -> Bool
}

/// Errors raised by the DCQL credential adapter layer.
public enum DCQLError: Error, LocalizedError {
    case parseError(String)
    case adapterNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .parseError(let msg): return msg
        case .adapterNotFound(let msg): return msg
        }
    }
}
