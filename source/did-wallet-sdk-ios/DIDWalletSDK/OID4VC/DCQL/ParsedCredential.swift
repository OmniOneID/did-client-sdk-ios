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

/// A format-agnostic representation of a parsed credential, used as the unified input to
/// DCQL matching regardless of the original credential format (SD-JWT, opendid_vc, mdoc).
public class ParsedCredential {

    /// The credential format identifier (e.g., "dc+sd-jwt", "opendid_vc", "mso_mdoc").
    public let format: String

    /// The raw credential string as originally provided (SD-JWT compact, VC JSON, base64url mdoc).
    public let rawCredential: String

    /// Base claims extracted directly from the credential payload (excluding reserved/metadata).
    public let baseClaims: [String: Any]

    /// All claims including disclosed claims (Foundation-typed values).
    public let allClaims: [String: Any]

    /// Format-specific metadata (e.g., SD-JWT: vct/iss; opendid_vc: credential_schema_id).
    public let metadata: [String: Any]

    /// The original parsed credential object in its native format (e.g., `SDJWT`, `VerifiableCredential`).
    public let nativeCredential: Any?

    public init(format: String,
                rawCredential: String,
                baseClaims: [String: Any] = [:],
                allClaims: [String: Any] = [:],
                metadata: [String: Any] = [:],
                nativeCredential: Any? = nil) {
        self.format = format
        self.rawCredential = rawCredential
        self.baseClaims = baseClaims
        self.allClaims = allClaims
        self.metadata = metadata
        self.nativeCredential = nativeCredential
    }

    public func getClaim(_ claimName: String) -> Any? { allClaims[claimName] }
    public func hasClaim(_ claimName: String) -> Bool { allClaims[claimName] != nil }
    public func getMetadataValue(_ key: String) -> Any? { metadata[key] }
    public func getNativeCredentialAs<T>(_ type: T.Type) -> T? { nativeCredential as? T }
}
