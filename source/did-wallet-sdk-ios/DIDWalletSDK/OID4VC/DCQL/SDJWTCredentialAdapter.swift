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

    private static let reservedClaims: Set<String> = [
        "iss", "sub", "aud", "exp", "nbf", "iat", "jti",
        "_sd_alg", "_sd", "cnf", "vct"
    ]

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

    /// Every claim the SD-JWT can disclose, as DCQL path codes (`address`, `address.street_address`,
    /// `degrees[0]`).
    ///
    /// Top-level claims are listed whether they are in the clear or selectively disclosable; below
    /// that, only the nodes a disclosure hides are listed, because plaintext members ride along with
    /// the parent that already appears. Every disclosure reachable from the issuer payload therefore
    /// has a code naming it, so presenting the whole list presents the whole credential — the
    /// nesting an empty list used to hide from the app.
    public func allClaimNames(_ credential: ParsedCredential) -> Set<String> {
        guard let sdjwt = credential.getNativeCredentialAs(SDJWT.self),
              let payload = try? SimpleJWTDecoder.parse(sdjwt.credentialJwt).payload else {
            return Set(credential.allClaims.keys)
        }

        var digestToDisclosure: [String: Disclosure] = [:]
        for disclosure in sdjwt.disclosures {
            digestToDisclosure[disclosure.digest()] = disclosure
        }

        var names: Set<String> = []
        var usedDigests: Set<String> = []
        collectClaimPaths(value: payload,
                          prefix: nil,
                          digestToDisclosure: digestToDisclosure,
                          names: &names,
                          usedDigests: &usedDigests)

        // A disclosure whose digest the payload never references is unreachable by the walk above.
        // It is still presentable by name (`SDJWTPresenter` resolves it the same way), so leaving it
        // out would silently shrink what "all claims" means.
        for disclosure in sdjwt.disclosures where !usedDigests.contains(disclosure.digest()) {
            if let claimName = disclosure.claimName,
               !SDJWTCredentialAdapter.reservedClaims.contains(claimName) {
                names.insert(claimName)
            }
        }
        return names
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

    /// Walks the issuer payload, naming every claim node the way DCQL paths do and following each
    /// `_sd` digest / array `{"...": digest}` placeholder into the disclosure it hides.
    private func collectClaimPaths(value: Any,
                                   prefix: String?,
                                   digestToDisclosure: [String: Disclosure],
                                   names: inout Set<String>,
                                   usedDigests: inout Set<String>) {
        if let object = value as? [String: Any] {
            for (key, child) in object where key != "_sd" && key != "_sd_alg" {
                if let prefix = prefix {
                    // A plaintext member of an already-named claim needs no code of its own: it is
                    // disclosed with its parent. Keep walking for disclosures buried under it.
                    collectClaimPaths(value: child,
                                      prefix: "\(prefix).\(key)",
                                      digestToDisclosure: digestToDisclosure,
                                      names: &names,
                                      usedDigests: &usedDigests)
                } else if !SDJWTCredentialAdapter.reservedClaims.contains(key) {
                    names.insert(key)
                    collectClaimPaths(value: child,
                                      prefix: key,
                                      digestToDisclosure: digestToDisclosure,
                                      names: &names,
                                      usedDigests: &usedDigests)
                }
            }

            for entry in (object["_sd"] as? [Any]) ?? [] {
                guard let digest = entry as? String,
                      let disclosure = digestToDisclosure[digest],
                      let claimName = disclosure.claimName else { continue }
                usedDigests.insert(digest)
                let path = prefix.map { "\($0).\(claimName)" } ?? claimName
                names.insert(path)
                collectClaimPaths(value: SDJWTCredentialAdapter.jsonToAny(disclosure.claimValue),
                                  prefix: path,
                                  digestToDisclosure: digestToDisclosure,
                                  names: &names,
                                  usedDigests: &usedDigests)
            }
            return
        }

        guard let array = value as? [Any], let prefix = prefix else { return }
        for (index, element) in array.enumerated() {
            let path = "\(prefix)[\(index)]"
            if let placeholder = element as? [String: Any], let digest = placeholder["..."] as? String {
                guard let disclosure = digestToDisclosure[digest] else { continue }
                usedDigests.insert(digest)
                names.insert(path)
                collectClaimPaths(value: SDJWTCredentialAdapter.jsonToAny(disclosure.claimValue),
                                  prefix: path,
                                  digestToDisclosure: digestToDisclosure,
                                  names: &names,
                                  usedDigests: &usedDigests)
            } else {
                collectClaimPaths(value: element,
                                  prefix: path,
                                  digestToDisclosure: digestToDisclosure,
                                  names: &names,
                                  usedDigests: &usedDigests)
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
