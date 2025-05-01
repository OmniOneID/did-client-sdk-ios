/*
 * Copyright 2024 OmniOne.
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

/// VC information object to be used for VP generation.
public struct ClaimInfo {
    /// VC ID
    public var credentialId: String
    /// Array of claim codes to include in VP from VC
    public var claimCodes: [String]
    
    /// Initializer
    /// - Parameters:
    ///   - credentialId: VC ID
    ///   - claimCodes: Array of claim codes to include in VP from VC
    public init(credentialId: String, claimCodes: [String]) {
        self.credentialId = credentialId
        self.claimCodes = claimCodes
    }
}

/// Meta information for creating VP
public struct PresentationInfo {
    /// DID of the VC holder
    public var holder: String
    /// Start date and time of VC validity period
    public var validFrom: String
    /// End date and time of VC validity period
    public var validUntil: String
    /// Nonce received from the verifier
    public var verifierNonce: String
    
    /// Initializer
    /// - Parameters:
    ///   - holder: DID of the VC holder
    ///   - validFrom: Start date and time of VC validity period
    ///   - validUntil: End date and time of VC validity period
    ///   - verifierNonce: Nonce received from the verifier
    public init(holder: String, validFrom: String, validUntil: String, verifierNonce: String) {
        self.holder = holder
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.verifierNonce = verifierNonce
    }
}

struct VCInternalMeta: MetaProtocol {
    var id: String
}
