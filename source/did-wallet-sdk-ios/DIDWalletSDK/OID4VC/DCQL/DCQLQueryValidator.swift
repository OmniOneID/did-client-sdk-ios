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

public enum DCQLQueryValidator {

    public struct ValidationResult {
        private(set) public var errors: [String] = []
        private(set) public var warnings: [String] = []

        public mutating func addError(_ msg: String) { errors.append(msg) }
        public mutating func addWarning(_ msg: String) { warnings.append(msg) }

        public func isValid() -> Bool { errors.isEmpty }
        public func hasWarnings() -> Bool { !warnings.isEmpty }
        public func hasErrors() -> Bool { !errors.isEmpty }
        public func getSummary() -> String { "Validation: \(errors.count) errors, \(warnings.count) warnings" }
    }

    public static func validate(_ dcqlQuery: DCQLQuery?) -> ValidationResult {
        var result = ValidationResult()

        guard let dcqlQuery = dcqlQuery else {
            result.addError("DCQL query is null")
            return result
        }

        validateBasicStructure(dcqlQuery, &result)

        if let creds = dcqlQuery.credentials {
            validateCredentials(creds, &result)
        }

        if let sets = dcqlQuery.credentialSets {
            validateCredentialSets(sets, credentials: dcqlQuery.credentials, &result)
        }

        validateConsistency(dcqlQuery, &result)

        return result
    }

    private static func validateBasicStructure(_ dcqlQuery: DCQLQuery, _ result: inout ValidationResult) {
        let hasCredentials = (dcqlQuery.credentials?.isEmpty == false)
        let hasCredentialSets = (dcqlQuery.credentialSets?.isEmpty == false)

        if !hasCredentials && !hasCredentialSets {
            result.addError("DCQL query must have either 'credentials' or 'credential_sets'")
        }

        if hasCredentials && hasCredentialSets {
            result.addWarning("DCQL query has both 'credentials' and 'credential_sets' - credential_sets takes precedence")
        }
    }

    private static func validateCredentials(_ credentials: [DCQLQuery.CredentialQuery], _ result: inout ValidationResult) {
        if credentials.isEmpty {
            result.addError("'credentials' array cannot be empty")
            return
        }

        var ids: Set<String> = []
        for (i, credential) in credentials.enumerated() {
            let context = "credentials[\(i)]"
            validateCredential(credential, context, &result)

            if let id = credential.id {
                if ids.contains(id) { result.addError("Duplicate credential ID: \(id)") }
                else { ids.insert(id) }
            }
        }
    }

    private static func validateCredential(_ credential: DCQLQuery.CredentialQuery, _ context: String, _ result: inout ValidationResult) {
        validateRequiredField(credential.id, "id", context, &result)
        validateRequiredField(credential.format, "format", context, &result)

        if let id = credential.id { validateCredentialId(id, context, &result) }
        if let format = credential.format { validateFormat(format, context, &result) }

        // Per OID4VP 1.0 §6.4: when claim_sets is present, every claims entry MUST have a unique id.
        let claimSetsPresent = credential.claimSets != nil

        if let claims = credential.claims {
            validateClaims(claims, context, requireIds: claimSetsPresent,
                           format: credential.format, &result)
        }

        if let claimSets = credential.claimSets {
            // claim_sets MUST NOT be present unless claims is present.
            if credential.claims == nil {
                result.addError("\(context).claim_sets requires 'claims' to be present")
            }
            validateCredentialClaimSets(claimSets, claims: credential.claims ?? [], context, &result)
        }

        if let trustedAuthorities = credential.trustedAuthorities {
            validateTrustedAuthorities(trustedAuthorities, context, &result)
        }

        if let meta = credential.meta {
            validateMeta(meta, context, &result)
        }
    }

    private static func validateClaims(_ claims: [DCQLQuery.ClaimQuery], _ context: String, requireIds: Bool,
                                       format: String?, _ result: inout ValidationResult) {
        // An mdoc element is addressed by namespace and element identifier. OID4VP 1.0 spells that
        // as a two-element `path`, but earlier drafts — and deployed verifiers — send `namespace`
        // plus `claim_name`. Both are accepted for mdoc, so a request in the older spelling is
        // matched rather than rejected as malformed.
        let mdocFormat = format.map { MdocCredentialAdapter.supportedFormats.contains($0) } ?? false
        var seenIds: Set<String> = []
        for (i, claim) in claims.enumerated() {
            let claimContext = "\(context).claims[\(i)]"

            guard let path = claim.path, !path.isEmpty else {
                if mdocFormat, claim.namespace?.isEmpty == false, claim.claimName?.isEmpty == false {
                    if let values = claim.values {
                        validateValues(values, "\(claimContext).values", &result)
                    }
                    continue
                }
                result.addError("\(claimContext).path is required and cannot be empty")
                continue
            }

            validatePath(path, "\(claimContext).path", &result)

            // An mdoc path addresses exactly [namespace, element]; a deeper one has nothing to
            // address, since element values are not navigated into.
            if mdocFormat, path.count != 2 {
                result.addError("\(claimContext).path for an mdoc must be [namespace, element]")
            }

            if let values = claim.values {
                validateValues(values, "\(claimContext).values", &result)
            }

            // Per OID4VP 1.0 §6.4: with claim_sets, each claims entry needs a unique, well-formed id.
            if requireIds {
                guard let id = claim.id, !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    result.addError("\(claimContext).id is required when 'claim_sets' is present")
                    continue
                }
                if id.range(of: "^[a-zA-Z0-9_-]+$", options: .regularExpression) == nil {
                    result.addError("\(claimContext).id must contain only alphanumeric characters, underscores, and hyphens")
                }
                if !seenIds.insert(id).inserted {
                    result.addError("\(claimContext).id '\(id)' is duplicated within 'claims'")
                }
            }
        }
    }

    private static func validatePath(_ path: [DCQLPathElement], _ context: String, _ result: inout ValidationResult) {
        if !DCQLPathProcessor.isValidPath(path) {
            result.addError("\(context) contains invalid elements")
        }

        for (i, el) in path.enumerated() {
            switch el {
            case .wildcard:
                continue
            case .key(let s):
                if s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    result.addError("\(context)[\(i)] cannot be empty string")
                }
            case .index(let idx):
                // Per OID4VP 1.0 §7.1: an array index path element is a non-negative integer.
                if idx < 0 {
                    result.addError("\(context)[\(i)] array index must be non-negative")
                }
            }
        }
    }

    private static func validateValues(_ values: [AnyJSON], _ context: String, _ result: inout ValidationResult) {
        if values.isEmpty {
            // Per OID4VP 1.0 §6.3: `values`, when present, MUST be a non-empty array.
            result.addError("\(context) must not be empty")
            return
        }

        // Java: mixed types warning
        let typeNames: [String] = values.map {
            switch $0 {
            case .null: return "null"
            case .bool: return "bool"
            case .number: return "number"
            case .string: return "string"
            case .array: return "array"
            case .object: return "object"
            }
        }
        if Set(typeNames).count > 1 {
            result.addWarning("\(context) contains mixed value types - may cause matching issues")
        }
    }

    private static func validateCredentialSets(_ credentialSets: [DCQLQuery.CredentialSet],
                                               credentials: [DCQLQuery.CredentialQuery]?,
                                               _ result: inout ValidationResult) {
        if credentialSets.isEmpty {
            result.addError("'credential_sets' array cannot be empty")
            return
        }

        var available: Set<String> = []
        if let credentials = credentials {
            for c in credentials {
                if let id = c.id { available.insert(id) }
            }
        }

        for (i, set) in credentialSets.enumerated() {
            let context = "credential_sets[\(i)]"
            validateCredentialSet(set, context, available, &result)
        }
    }

    private static func validateCredentialSet(_ credentialSet: DCQLQuery.CredentialSet,
                                              _ context: String,
                                              _ availableCredentialIds: Set<String>,
                                              _ result: inout ValidationResult) {
        guard let options = credentialSet.options, !options.isEmpty else {
            result.addError("\(context).options is required and cannot be empty")
            return
        }

        for (i, option) in options.enumerated() {
            let optionContext = "\(context).options[\(i)]"
            if option.isEmpty {
                result.addError("\(optionContext) cannot be null or empty")
                continue
            }
            for credentialId in option {
                if !availableCredentialIds.contains(credentialId) {
                    result.addError("\(optionContext) references undefined credential ID: \(credentialId)")
                }
            }
        }
    }

    private static func validateConsistency(_ dcqlQuery: DCQLQuery, _ result: inout ValidationResult) {
        // no-op (same as Java)
    }

    private static func validateRequiredField(_ value: String?, _ fieldName: String, _ context: String, _ result: inout ValidationResult) {
        if (value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            result.addError("\(context).\(fieldName) is required")
        }
    }

    private static func validateCredentialId(_ id: String, _ context: String, _ result: inout ValidationResult) {
        let pattern = "^[a-zA-Z0-9_-]+$"
        if id.range(of: pattern, options: .regularExpression) == nil {
            result.addError("\(context).id must contain only alphanumeric characters, underscores, and hyphens")
        }
    }

    private static func validateFormat(_ format: String, _ context: String, _ result: inout ValidationResult) {
        let supported: Set<String> = ["dc+sd-jwt-did","opendid_vc","vc+sd-jwt","sd-jwt","jwt_vc_json","jwt_vc","ldp_vc"]
        if !supported.contains(format) {
            result.addWarning("\(context).format '\(format)' may not be supported")
        }
    }

    private static func validateMeta(_ meta: [String: AnyJSON], _ context: String, _ result: inout ValidationResult) {
        if meta.isEmpty {
            result.addWarning("\(context).meta is empty")
        }

        if let v = meta["vct_values"] {
            // Must be array
            if v.asArray == nil {
                result.addError("\(context).meta.vct_values must be an array")
            }
        }
    }

    /// Per OID4VP 1.0 §6.4: `claim_sets` is a non-empty array of non-empty options, each an array of
    /// claim `id`s that MUST reference an entry in the credential query's `claims`.
    private static func validateCredentialClaimSets(_ claimSets: [[String]],
                                                    claims: [DCQLQuery.ClaimQuery],
                                                    _ context: String,
                                                    _ result: inout ValidationResult) {
        if claimSets.isEmpty {
            result.addError("\(context).claim_sets cannot be empty")
            return
        }
        let definedIds = Set(claims.compactMap { $0.id })
        for (i, option) in claimSets.enumerated() {
            let optionContext = "\(context).claim_sets[\(i)]"
            if option.isEmpty {
                result.addError("\(optionContext) cannot be empty")
                continue
            }
            for id in option where !definedIds.contains(id) {
                result.addError("\(optionContext) references undefined claim id: \(id)")
            }
        }
    }

    /// Per OID4VP 1.0 §6.1.1: each trusted authority needs a `type` and a non-empty `values` array.
    /// The `type` registry is extensible, so an unrecognized value is a warning, not a hard error.
    private static func validateTrustedAuthorities(_ authorities: [DCQLQuery.TrustedAuthority],
                                                   _ context: String,
                                                   _ result: inout ValidationResult) {
        if authorities.isEmpty {
            result.addError("\(context).trusted_authorities cannot be empty")
            return
        }
        for (i, authority) in authorities.enumerated() {
            let taContext = "\(context).trusted_authorities[\(i)]"
            if (authority.type?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
                result.addError("\(taContext).type is required")
            } else if let type = authority.type,
                      !["aki", "etsi_tl", "openid_federation"].contains(type) {
                result.addWarning("\(taContext).type '\(type)' is not a spec-registered value")
            }
            if (authority.values?.isEmpty ?? true) {
                result.addError("\(taContext).values is required and cannot be empty")
            }
        }
    }
}
