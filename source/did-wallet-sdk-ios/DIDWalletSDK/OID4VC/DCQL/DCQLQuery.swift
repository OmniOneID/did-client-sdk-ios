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

public struct DCQLQuery: Jsonable {
    public var credentials: [CredentialQuery]?
    public var credentialSets: [CredentialSet]?
    public var transactionData: [[String: AnyJSON]]?

    enum CodingKeys: String, CodingKey {
        case credentials
        case credentialSets = "credential_sets"
        case transactionData = "transaction_data"
    }

    public init(credentials: [CredentialQuery]? = nil,
                credentialSets: [CredentialSet]? = nil,
                transactionData: [[String: AnyJSON]]? = nil) {
        self.credentials = credentials
        self.credentialSets = credentialSets
        self.transactionData = transactionData
    }

    // MARK: Nested models

    public struct CredentialQuery: Codable {
        public var id: String?
        public var format: String?
        public var meta: [String: AnyJSON]?
        public var claims: [ClaimQuery]?
        public var claimSets: [ClaimSet]?
        public var purpose: String?
        public var requireCryptographicHolderBinding: Bool?

        enum CodingKeys: String, CodingKey {
            case id
            case format
            case meta
            case claims
            case claimSets = "claim_sets"
            case purpose
            case requireCryptographicHolderBinding = "require_cryptographic_holder_binding"
        }

        public init(id: String? = nil,
                    format: String? = nil,
                    meta: [String: AnyJSON]? = nil,
                    claims: [ClaimQuery]? = nil,
                    claimSets: [ClaimSet]? = nil,
                    purpose: String? = nil,
                    requireCryptographicHolderBinding: Bool? = nil) {
            self.id = id
            self.format = format
            self.meta = meta
            self.claims = claims
            self.claimSets = claimSets
            self.purpose = purpose
            self.requireCryptographicHolderBinding = requireCryptographicHolderBinding
        }
    }

    public struct ClaimQuery: Codable {
        public var id: String?
        public var path: [DCQLPathElement]?
        public var purpose: String?
        public var values: [AnyJSON]?
        public var value: AnyJSON?
        public var max: AnyJSON?
        public var min: AnyJSON?

        enum CodingKeys: String, CodingKey {
            case id
            case path
            case purpose
            case values
            case value
            case max
            case min
        }

        public init(id: String? = nil,
                    path: [DCQLPathElement]? = nil,
                    purpose: String? = nil,
                    values: [AnyJSON]? = nil,
                    value: AnyJSON? = nil,
                    max: AnyJSON? = nil,
                    min: AnyJSON? = nil) {
            self.id = id
            self.path = path
            self.purpose = purpose
            self.values = values
            self.value = value
            self.max = max
            self.min = min
        }
    }

    public struct ClaimSet: Codable {
        public var id: String?
        public var claims: [ClaimQuery]?
        public var purpose: String?

        enum CodingKeys: String, CodingKey {
            case id
            case claims
            case purpose
        }

        public init(id: String? = nil, claims: [ClaimQuery]? = nil, purpose: String? = nil) {
            self.id = id
            self.claims = claims
            self.purpose = purpose
        }
    }

    public struct CredentialSet: Codable {
        public var id: String?
        public var options: [[String]]?
        public var purpose: String?

        enum CodingKeys: String, CodingKey {
            case id
            case options
            case purpose
        }

        public init(id: String? = nil, options: [[String]]? = nil, purpose: String? = nil) {
            self.id = id
            self.options = options
            self.purpose = purpose
        }
    }
}
