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

/// A List of VCs signed with subject signatures, hereafter VP
public struct VerifiablePresentation : Jsonable, ProofsContainer, Identifiable
{
    /// JSON-LD context
    public var context              : [String]
    /// VP ID
    public var id                   : String
    /// List of VP type
    public var type                 : [String]
    /// Holder DID
    public var holder               : String
    /// This VP valid from the datetime
    @UTCDatetime public var validFrom  : String
    /// This VP valid until the datetime
    @UTCDatetime public var validUntil : String
    /// Verifier nonce
    public var verifierNonce        : String
    /// List of VC
    public var verifiableCredential : [VerifiableCredential]
    /// Owner proof
    public var proof                : Proof?
    /// List of owner proof 
    public var proofs               : [Proof]?
}

//MARK: - Extension

extension VerifiablePresentation
{
    public init(holder : String,
                @UTCDatetime validFrom : String,
                @UTCDatetime validUntil : String,
                verifierNonce: String,
                verifiableCredential : [VerifiableCredential])
    {
        context = ["https://www.w3.org/ns/credentials/v2"]
        id = UUID().uuidString.lowercased()
        type = ["VerifiablePresentation"]
        
        self.holder = holder
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.verifierNonce = verifierNonce
        self.verifiableCredential = verifiableCredential
    }
}

extension VerifiablePresentation : Codable
{
    enum CodingKeys: String, CodingKey
    {
        case context = "@context"
        case id,
             type,
             holder,
             validFrom,
             validUntil,
             verifierNonce,
             verifiableCredential,
             proof,
             proofs
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(context,
                             forKey: .context)
        try container.encode(id,
                             forKey: .id)
        try container.encode(type,
                             forKey: .type)
        try container.encode(holder,
                             forKey: .holder)
        try container.encode(validFrom,
                             forKey: .validFrom)
        try container.encode(validUntil,
                             forKey: .validUntil)
        try container.encode(verifierNonce,
                             forKey: .verifierNonce)
        try container.encode(verifiableCredential,
                             forKey: .verifiableCredential)
        if proof != nil
        {
            try container.encode(proof,
                                 forKey: .proof)
        }
        else
        {
            if let innerProofs = proofs, !innerProofs.isEmpty
            {
                if innerProofs.count == 1
                {
                    try container.encode(innerProofs[0],
                                         forKey: .proof)
                }
                else
                {
                    try container.encode(innerProofs,
                                         forKey: .proofs)
                }
            }
        }
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        context              = try container.decode([String].self,
                                                    forKey: .context)
        id                   = try container.decode(String.self,
                                                    forKey: .id)
        type                 = try container.decode([String].self,
                                                    forKey: .type)
        holder               = try container.decode(String.self,
                                                    forKey: .holder)
        validFrom            = try container.decode(String.self,
                                                    forKey: .validFrom)
        validUntil           = try container.decode(String.self,
                                                    forKey: .validUntil)
        verifierNonce        = try container.decode(String.self,
                                                    forKey: .verifierNonce)
        verifiableCredential = try container.decode([VerifiableCredential].self,
                                                    forKey: .verifiableCredential)
        proof                = try container.decodeIfPresent(Proof.self,
                                                             forKey: .proof)
        proofs               = try container.decodeIfPresent([Proof].self,
                                                             forKey: .proofs)
    }
}
