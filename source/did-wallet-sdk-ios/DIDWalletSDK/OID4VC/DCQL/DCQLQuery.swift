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

public struct DCQLQuery: Jsonable, FromSnake
{
    public var credentials: [CredentialQuery]?
    public var credentialSets: [CredentialSet]?
    public var transactionData: [[String: AnyJSON]]?

    // MARK: Nested models

    public struct CredentialQuery: Jsonable, FromSnake
    {
        public var id: String?
        public var format: String?
        public var meta: [String: AnyJSON]?
        public var claims: [ClaimQuery]?
        /// Per OID4VP spec: claim_sets is an array of arrays of claim query IDs.
        /// Each inner array references claim IDs defined in the 'claims' array.
        /// Example: [["a", "b"], ["a", "b", "c"]]
        public var claimSets: [ClaimSet]?
        public var trustedAuthorities: [TrustedAuthority]?
        public var purpose: String?
        /// If true, the Wallet MAY return multiple credentials for this query.
        /// Defaults to false (exactly one credential expected).
        public var multiple: Bool?
        public var requireCryptographicHolderBinding: Bool?

    }

    public struct ClaimQuery: Jsonable, FromSnake
    {
        public var id: String?
        /// For JSON-based credentials (SD-JWT, W3C VC): path to the claim.
        /// Not used for mdoc format.
        public var path: [DCQLPathElement]?
        /// For mdoc credentials: the namespace of the claim.
        /// e.g., "org.iso.18013.5.1"
        public var namespace: String?
        /// For mdoc credentials: the name of the claim within the namespace.
        /// e.g., "family_name"
        public var claimName: String?
        public var purpose: String?
        public var values: [AnyJSON]?
        public var value: AnyJSON?
        public var max: AnyJSON?
        public var min: AnyJSON?

    }

    /// Trusted authority for credential issuer validation.
    /// Per OID4VP spec section 6.1.1.
    public struct TrustedAuthority: Jsonable, FromSnake {
        /// Type of authority validation.
        /// Allowed values: "aki", "etsi_tl", "openid_federation", "x509_san_dns", "x509_san_uri"
        public var type: String?
        public var values: [String]?
    }

    public struct ClaimSet: Jsonable, FromSnake {
        public var id: String?
        public var claims: [ClaimQuery]?
        public var purpose: String?

        public init(id: String? = nil, claims: [ClaimQuery]? = nil, purpose: String? = nil) {
            self.id = id
            self.claims = claims
            self.purpose = purpose
        }
    }
    
    public struct CredentialSet: Jsonable, FromSnake {
        public var id: String?
        public var options: [[String]]?
        /// Per OID4VP spec: whether at least one option must be satisfied.
        /// Defaults to true if not specified.
        public var required: Bool?
        public var purpose: String?
    }
}
