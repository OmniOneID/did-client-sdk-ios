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

/// `CredentialAdapter` for SD-JWT credentials (format: dc+sd-jwt-did).
/// Reuses the SDK's `SDJWT` parser, `Disclosure`, and `SimpleJWTDecoder`.
public class SDJWTCredentialAdapter: CredentialAdapter {

    private static let supportedFormats: Set<String> = ["dc+sd-jwt-did"]

    // Defined by the claim index so naming and presenting skip exactly the same claims.
    private static let reservedClaims: Set<String> = SDJWTClaimIndex.reservedClaims

    public init() {}

    public func getSupportedFormats() -> Set<String> { SDJWTCredentialAdapter.supportedFormats }
    public func supports(_ format: String) -> Bool { SDJWTCredentialAdapter.supportedFormats.contains(format) }
    public func getReservedClaimNames() -> Set<String> { SDJWTCredentialAdapter.reservedClaims }

    public func parse(_ rawCredential: String) throws -> ParsedCredential {
        guard !rawCredential.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DCQLError.parseError("Raw credential cannot be empty")
        }

        let sdjwt = SDJWT.parse(raw: rawCredential)
        let decodedJwt: SimpleJWTDecoder.SimpleJWT
        do {
            decodedJwt = try SimpleJWTDecoder.parse(sdjwt.credentialJwt)
        } catch {
            throw DCQLError.parseError("Failed to decode SD-JWT payload: \(error)")
        }
        let payload = decodedJwt.payload

        var baseClaims: [String: Any] = [:]
        for (k, v) in payload where !SDJWTCredentialAdapter.reservedClaims.contains(k) {
            baseClaims[k] = v
        }

        let allClaims = extractAllClaimsInternal(sdjwt: sdjwt, payload: payload)
        let metadata = extractMetadata(payload: payload)
        // The transport format is the SD-JWT VC media type in the issuer JWT `typ` header
        // (e.g. dc+sd-jwt / vc+sd-jwt), not the `vct` type claim (which is always present and
        // only identifies the credential type, e.g. urn:eudi:pid:1).
        guard let format = decodedJwt.header["typ"] as? String, !format.isEmpty else {
            throw DCQLError.parseError("SD-JWT is missing the 'typ' header")
        }

        return ParsedCredential(
            format: format,
            rawCredential: rawCredential,
            baseClaims: baseClaims,
            allClaims: allClaims,
            metadata: metadata,
            nativeCredential: sdjwt
        )
    }

    public func matchesMetadata(_ credential: ParsedCredential, metadata: [String: Any]) -> Bool {
        if metadata.isEmpty { return true }
        if let requiredVcts = metadata["vct_values"] as? [String] {
            guard let vct = credential.getMetadataValue("vct") else { return false }
            return requiredVcts.isEmpty || requiredVcts.contains(String(describing: vct))
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

    /// Every claim the SD-JWT can disclose, as codes shaped after the DCQL paths that name them
    /// (`address`, `address.street_address`, `degrees[0]`).
    ///
    /// The shape is how the code is built, not how it is read: nothing parses a code back into a
    /// path, so a claim whose own name contains a separator names itself.
    ///
    /// Top-level claims are listed whether they are in the clear or selectively disclosable; below
    /// that, only the nodes a disclosure hides are listed, because plaintext members ride along with
    /// the parent that already appears. Every disclosure reachable from the issuer payload therefore
    /// has a code naming it, so presenting the whole list presents the whole credential — the
    /// nesting an empty list used to hide from the app.
    ///
    /// The enumeration lives in `SDJWTClaimIndex`, which the presenter reads back when the holder
    /// submits: naming a claim here and resolving it there are two views of one walk, so a code
    /// cannot mean one thing on the way out and another on the way in.
    public func allClaimNames(_ credential: ParsedCredential) -> Set<String> {
        guard let sdjwt = credential.getNativeCredentialAs(SDJWT.self),
              let payload = try? SimpleJWTDecoder.parse(sdjwt.credentialJwt).payload else {
            return Set(credential.allClaims.keys)
        }
        return SDJWTClaimIndex.build(sdjwt: sdjwt, payload: payload).consentItemCodes
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
            case "aki":
                if let aki = metadata["aki"] as? String, values.contains(aki) { return true }
            default:
                break
            }
        }
        return false
    }

    // MARK: - Private

    private func extractAllClaimsInternal(sdjwt: SDJWT, payload: [String: Any]) -> [String: Any] {
        var allClaims: [String: Any] = [:]
        for (k, v) in payload where !SDJWTCredentialAdapter.reservedClaims.contains(k) {
            allClaims[k] = v
        }

        if !sdjwt.disclosures.isEmpty {
            for disclosure in sdjwt.disclosures {
                if let claimName = disclosure.claimName {
                    allClaims[claimName] = SDJWTCredentialAdapter.jsonToAny(disclosure.claimValue)
                }
            }
            integrateNestedDisclosures(allClaims: &allClaims, sdjwt: sdjwt)
        }
        return allClaims
    }

    private func integrateNestedDisclosures(allClaims: inout [String: Any], sdjwt: SDJWT) {
        var digestToDisclosure: [String: Disclosure] = [:]
        for disclosure in sdjwt.disclosures {
            digestToDisclosure[disclosure.digest()] = disclosure
        }
        let snapshot = allClaims
        for (claimName, claimValue) in snapshot {
            if var obj = claimValue as? [String: Any] {
                integrateDisclosuresIntoObject(parentObject: &obj, digestToDisclosure: digestToDisclosure)
                allClaims[claimName] = obj
            }
        }
    }

    private func integrateDisclosuresIntoObject(parentObject: inout [String: Any],
                                                digestToDisclosure: [String: Disclosure]) {
        guard let sd = parentObject["_sd"] as? [Any] else { return }
        for item in sd {
            guard let digest = item as? String else { continue }
            guard let disclosure = digestToDisclosure[digest], let claimName = disclosure.claimName else { continue }
            let claimValue = SDJWTCredentialAdapter.jsonToAny(disclosure.claimValue)
            parentObject[claimName] = claimValue
            if var nested = claimValue as? [String: Any] {
                integrateDisclosuresIntoObject(parentObject: &nested, digestToDisclosure: digestToDisclosure)
                parentObject[claimName] = nested
            }
        }
    }

    private func extractMetadata(payload: [String: Any]) -> [String: Any] {
        var metadata: [String: Any] = [:]
        if let vct = payload["vct"] { metadata["vct"] = vct }
        if let sdAlg = payload["_sd_alg"] { metadata["_sd_alg"] = sdAlg }
        if let iss = payload["iss"] { metadata["iss"] = iss }
        if let cnf = payload["cnf"] { metadata["cnf"] = cnf }
        return metadata
    }

    /// Converts an RNJSON `JSON` value (used by `Disclosure.claimValue`) to Foundation types so the
    /// path/condition matcher can operate on it.
    static func jsonToAny(_ json: JSON) -> Any {
        switch json {
        case .string(let s): return s
        case .number(let digits): return Double(digits) ?? digits
        case .bool(let b): return b
        case .null: return NSNull()
        case .array(let arr): return arr.map { jsonToAny($0) }
        case .object(let kv):
            var dict: [String: Any] = [:]
            for pair in kv { dict[pair.key] = jsonToAny(pair.value) }
            return dict
        }
    }
}
