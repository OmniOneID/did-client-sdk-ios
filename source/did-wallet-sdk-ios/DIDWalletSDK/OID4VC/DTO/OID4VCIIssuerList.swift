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

/// List of OID4VCI issuers the wallet may start an issuance with.
///
/// The wire format is camelCase (an OmniOne server API, not the snake_case OID4VCI spec), so the
/// default `Codable` key strategy applies — unlike the OID4VCI DTOs, this model is not `FromSnake`.
public struct OID4VCIIssuerList: Jsonable
{
    /// Number of entries in `items`.
    public var count: Int
    /// The issuer entries.
    public var items: [OID4VCIIssuerItem]

    public init(count: Int, items: [OID4VCIIssuerItem])
    {
        self.count = count
        self.items = items
    }
}

/// One OID4VCI issuer entry: its identifier and the endpoints needed to begin issuance.
public struct OID4VCIIssuerItem: Jsonable
{
    /// The issuer identifier — matches `credential_issuer` of the issuer metadata.
    public var credentialIssuer: String
    /// Where to fetch this issuer's `IssuerMetadataResponse`.
    public var credentialIssuerMetadataUri: String
    /// Where the wallet starts a user-initiated (wallet-initiated) issuance.
    /// Absent for issuers that only support issuer-initiated offers.
    public var userInitiationUri: String?

    public init(credentialIssuer: String,
                credentialIssuerMetadataUri: String,
                userInitiationUri: String?)
    {
        self.credentialIssuer = credentialIssuer
        self.credentialIssuerMetadataUri = credentialIssuerMetadataUri
        self.userInitiationUri = userInitiationUri
    }
}
