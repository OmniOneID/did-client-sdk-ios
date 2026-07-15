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

        if let claims = credential.claims {
            validateClaims(claims, context, &result)
        }

        if let claimSets = credential.claimSets {
            validateCredentialClaimSets(claimSets, context, &result)
            if credential.claims != nil {
                result.addWarning("\(context) has both 'claims' and 'claim_sets' - claim_sets takes precedence")
            }
        }

        if let meta = credential.meta {
            validateMeta(meta, context, &result)
        }
    }

    private static func validateClaims(_ claims: [DCQLQuery.ClaimQuery], _ context: String, _ result: inout ValidationResult) {
        for (i, claim) in claims.enumerated() {
            let claimContext = "\(context).claims[\(i)]"

            guard let path = claim.path, !path.isEmpty else {
                result.addError("\(claimContext).path is required and cannot be empty")
                continue
            }

            validatePath(path, "\(claimContext).path", &result)

            if let values = claim.values {
                validateValues(values, "\(claimContext).values", &result)
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
            case .index:
                continue
            }
        }
    }

    private static func validateValues(_ values: [AnyJSON], _ context: String, _ result: inout ValidationResult) {
        if values.isEmpty {
            result.addWarning("\(context) is empty - no value restrictions will be applied")
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
        let supported: Set<String> = ["dc+sd-jwt-did","vc+sd-jwt","sd-jwt","jwt_vc_json","jwt_vc","ldp_vc"]
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

    private static func validateCredentialClaimSets(_ claimSets: [DCQLQuery.ClaimSet], _ context: String, _ result: inout ValidationResult) {
        if claimSets.isEmpty {
            result.addError("\(context).claim_sets cannot be empty")
        }
        for (i, cs) in claimSets.enumerated() {
            if cs.claims == nil || cs.claims?.isEmpty == true {
                result.addError("\(context).claim_sets[\(i)].claims cannot be null or empty")
            }
        }
    }
}
