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

/// A credential issued through the OpenID4VCI flow, stored as-is.
///
/// Unlike the W3C `VerifiableCredential` VO (JSON-LD), OID4VCI issues format-specific credentials
/// (SD-JWT compact strings, mdoc, …). This wrapper keeps the raw credential together with the
/// metadata needed to identify and re-match it: its `format`, the `credentialConfigurationId` the
/// issuer offered it under, and the issuer-assigned `credentialIdentifier` (when present).
public struct OID4VCICredential: Jsonable
{
    /// Storage primary key. A wallet-generated UUID, unique per issuance — issuer-side identifiers
    /// (`credentialConfigurationId` / `credentialIdentifier`) are kept as separate fields because they
    /// can be shared across distinct credentials and so are unsafe as a primary key.
    public let id: String
    /// Credential format token, e.g. `"dc+sd-jwt"` or `"mso_mdoc"`.
    public let format: String
    /// The `credential_configuration_id` the credential was issued under.
    public let credentialConfigurationId: String?
    /// The issuer-assigned `credential_identifier`, when the issuer used identifiers.
    public let credentialIdentifier: String?
    /// The raw credential as returned by the issuer (SD-JWT compact, mdoc base64url, …).
    public let credential: String
    
    

    public init(
        id: String,
        format: String,
        credentialConfigurationId: String?,
        credentialIdentifier: String?,
        credential: String
    ) {
        self.id = id
        self.format = format
        self.credentialConfigurationId = credentialConfigurationId
        self.credentialIdentifier = credentialIdentifier
        self.credential = credential
    }
}

/// Wallet-file meta for an `IssuedCredential`. `format` is kept in the (plaintext) meta so callers
/// can filter by format without decrypting every stored item.
public struct IssuedCredentialMeta: MetaProtocol
{
    public var id: String
    public var format: String
}
