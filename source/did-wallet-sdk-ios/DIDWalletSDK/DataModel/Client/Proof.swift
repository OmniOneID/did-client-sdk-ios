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

/// Owner proof
public struct Proof : ProofProtocol
{
    /// Created datetime
    @UTCDatetime public var created: String
    /// Proof purpose
    public var proofPurpose: ProofPurpose
    /// Key URL used for Proof Signature
    public var verificationMethod: String
    /// Proof type
    public var type: ProofType
    /// Signature value
    public var proofValue: String?
    
    public init(created: String,
                proofPurpose: ProofPurpose,
                verificationMethod: String,
                type: ProofType,
                proofValue: String? = nil)
    {
        self.created = created
        self.proofPurpose = proofPurpose
        self.verificationMethod = verificationMethod
        self.type = type
        self.proofValue = proofValue
    }
}

/// Issuer proof
public struct VCProof : ProofProtocol, Jsonable
{
    /// Created datetime
    @UTCDatetime public var created: String
    /// Proof purpose
    public var proofPurpose: ProofPurpose
    /// Key URL used for Proof Signature
    public var verificationMethod: String
    /// Proof type
    public var type: ProofType
    /// Signature value
    public var proofValue: String?
    /// Signature value List
    public var proofValueList: [String]?
    
    public init(created: String, 
                proofPurpose: ProofPurpose,
                verificationMethod: String,
                type: ProofType,
                proofValue: String? = nil,
                proofValueList: [String]? = nil)
    {
        self.created = created
        self.proofPurpose = proofPurpose
        self.verificationMethod = verificationMethod
        self.type = type
        self.proofValue = proofValue
        self.proofValueList = proofValueList
    }
}

//MARK: - Extension

extension Proof : Codable
{
    enum CodingKeys : String, CodingKey
    {
        case created,
             proofPurpose,
             verificationMethod,
             type,
             proofValue
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(created,
                             forKey: .created)
        try container.encode(proofPurpose,
                             forKey: .proofPurpose)
        try container.encode(verificationMethod,
                             forKey: .verificationMethod)
        try container.encode(type,
                             forKey: .type)
        try container.encodeIfPresent(proofValue,
                                      forKey: .proofValue)
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        created             = try container.decode(String.self,
                                                   forKey: .created)
        proofPurpose        = try container.decode(ProofPurpose.self,
                                                   forKey: .proofPurpose)
        verificationMethod  = try container.decode(String.self,
                                                   forKey: .verificationMethod)
        type                = try container.decode(ProofType.self,
                                                   forKey: .type)
        proofValue          = try container.decodeIfPresent(String.self,
                                                            forKey: .proofValue)
    }
}

extension VCProof : Codable
{
    enum CodingKeys : String, CodingKey
    {
        case created,
             proofPurpose,
             verificationMethod,
             type,
             proofValue,
             proofValueList
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(created,
                             forKey: .created)
        try container.encode(proofPurpose,
                             forKey: .proofPurpose)
        try container.encode(verificationMethod,
                             forKey: .verificationMethod)
        try container.encode(type,
                             forKey: .type)
        try container.encodeIfPresent(proofValue,
                                      forKey: .proofValue)
        try container.encodeIfPresent(proofValueList,
                                      forKey: .proofValueList)
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        created             = try container.decode(String.self,
                                                   forKey: .created)
        proofPurpose        = try container.decode(ProofPurpose.self,
                                                   forKey: .proofPurpose)
        verificationMethod  = try container.decode(String.self,
                                                   forKey: .verificationMethod)
        type                = try container.decode(ProofType.self,
                                                   forKey: .type)
        proofValue          = try container.decodeIfPresent(String.self,
                                                            forKey: .proofValue)
        proofValueList      = try container.decodeIfPresent([String].self,
                                                            forKey: .proofValueList)
    }
}
