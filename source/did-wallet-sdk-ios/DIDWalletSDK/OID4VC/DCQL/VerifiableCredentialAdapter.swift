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

/// `CredentialAdapter` for OmniOne W3C credentials (`VerifiableCredential`, format "opendid_vc").
/// Claims are a flat `code`/`value` list, so a matched claim name equals its claim code — the
/// matcher output can be used directly as `ClaimInfo.claimCodes`.
public class VerifiableCredentialAdapter: CredentialAdapter {

    public static let format = "opendid_vc"

    public init() {}

    public func getSupportedFormats() -> Set<String> { [VerifiableCredentialAdapter.format] }
    public func supports(_ format: String) -> Bool { format == VerifiableCredentialAdapter.format }
    public func getReservedClaimNames() -> Set<String> { [] }

    public func parse(_ rawCredential: String) throws -> ParsedCredential {
        do {
            let vc = try VerifiableCredential(from: rawCredential)
            return VerifiableCredentialAdapter.makeParsed(from: vc, rawCredential: rawCredential)
        } catch {
            throw DCQLError.parseError("Failed to decode VerifiableCredential JSON: \(error)")
        }
    }

    /// Wraps an already-decoded `VerifiableCredential` into a `ParsedCredential`.
    public static func from(_ vc: VerifiableCredential) -> ParsedCredential {
        let raw = (try? vc.toJson()) ?? ""
        return makeParsed(from: vc, rawCredential: raw)
    }

    private static func makeParsed(from vc: VerifiableCredential, rawCredential: String) -> ParsedCredential {
        var allClaims: [String: Any] = [:]
        for claim in vc.credentialSubject.claims {
            allClaims[claim.code] = claim.value
        }
        let metadata: [String: Any] = [
            "credential_schema_id": vc.credentialSchema.id,
            "iss": vc.issuer.id
        ]
        return ParsedCredential(
            format: VerifiableCredentialAdapter.format,
            rawCredential: rawCredential,
            baseClaims: allClaims,
            allClaims: allClaims,
            metadata: metadata,
            nativeCredential: vc
        )
    }

    public func matchesMetadata(_ credential: ParsedCredential, metadata: [String: Any]) -> Bool {
        if metadata.isEmpty { return true }
        if let requiredSchemas = metadata["credential_schema_id_values"] as? [String] {
            guard let schemaId = credential.getMetadataValue("credential_schema_id") as? String else {
                return false
            }
            return requiredSchemas.isEmpty || requiredSchemas.contains(schemaId)
        }
        return true
    }

    public func extractAllClaims(_ credential: ParsedCredential) -> [String: Any] {
        credential.allClaims
    }

    public func extractMatchingClaims(_ credential: ParsedCredential,
                                      claimQueries: [DCQLQuery.ClaimQuery]) -> Set<String> {
        ClaimMatchingHelper.extractMatchingClaimsByPath(allClaims: credential.allClaims,
                                                        claimQueries: claimQueries)
    }

    public func matchesTrustedAuthorities(_ credential: ParsedCredential,
                                          trustedAuthorities: [DCQLQuery.TrustedAuthority]) -> Bool {
        if trustedAuthorities.isEmpty { return true }
        let metadata = credential.metadata
        for authority in trustedAuthorities {
            guard let type = authority.type, let values = authority.values else { continue }
            switch type {
            case "x509_san_dns", "x509_san_uri":
                if let iss = metadata["iss"] as? String, values.contains(iss) { return true }
            default:
                break
            }
        }
        return false
    }
}
