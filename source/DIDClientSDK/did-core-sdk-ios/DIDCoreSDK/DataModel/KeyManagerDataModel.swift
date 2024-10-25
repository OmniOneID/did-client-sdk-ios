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
import DIDDataModelSDK

//MARK: KeyGenRequest
/// Data Model for Wallet key creation
public struct WalletKeyGenRequest : WalletKeyGenRequestProtocol
{
    /// Algorithm type for Key
    public var algorithmType: AlgorithmType
    /// Key name
    public var id           : String
    /// Access method for Wallet
    public var accessMethod : WalletAccessMethod
    /// Key storage
    public let storage      : StorageOption = .wallet
    
    public init(algorithmType: AlgorithmType, 
                id: String,
                methodType: WalletAccessMethod)
    {
        self.algorithmType = algorithmType
        self.id = id
        self.accessMethod = methodType
    }
}

/// Data Model for Secure Enclave key creation
public struct SecureKeyGenRequest : SecureKeyGenRequestProtocol
{
    /// Algorithm type for Key
    public let algorithmType: AlgorithmType = .secp256r1
    /// Key name
    public var id           : String
    /// Access method for Secure Enclave
    public var accessMethod : SecureEnclaveAccessMethod
    /// Key storage
    public let storage      : StorageOption = .secureEnclave
    /// Description for Touch ID usage
    public var prompt       : String
    
    public init(id: String, 
                accessMethod: SecureEnclaveAccessMethod,
                prompt : String)
    {
        self.id = id
        self.accessMethod = accessMethod
        self.prompt = prompt
    }
}

//MARK: Storage
/// Data Model for Key Information
public struct KeyInfo : MetaProtocol
{
    /// Algorithm type for Key
    public var algorithmType : AlgorithmType
    /// Key name
    public var id            : String
    /// Indicate key storage and its access method
    public var accessMethod  : KeyAccessMethod
    /// Access method
    public var authType      : AuthType
    /// Public key
    public var publicKey     : String
}

struct DetailKeyInfo
{
    var id          : String
    var privateKey  : String?
    var salt        : String?
    var domainState : String?
}

//MARK: Extension
extension KeyInfo : Codable
{
    enum CodingKeys : String, CodingKey
    {
        case algorithmType,
             id,
             accessMethod,
             authType,
             publicKey
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        algorithmType = try container.decode(AlgorithmType.self,
                                             forKey: .algorithmType)
        id            = try container.decode(String.self,
                                             forKey: .id)
        accessMethod  = try container.decode(KeyAccessMethod.self,
                                             forKey: .accessMethod)
        authType      = try container.decode(AuthType.self,
                                             forKey: .authType)
        publicKey     = try container.decode(String.self,
                                             forKey: .publicKey)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(algorithmType,
                             forKey: .algorithmType)
        try container.encode(id,
                             forKey: .id)
        try container.encode(accessMethod,
                             forKey: .accessMethod)
        try container.encode(authType,
                             forKey: .authType)
        try container.encode(publicKey,
                             forKey: .publicKey)
    }
}

extension DetailKeyInfo : Codable
{
    enum CodingKeys : String, CodingKey
    {
        case id,
             privateKey,
             salt,
             domainState
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id            = try container.decode(String.self,
                                             forKey: .id)
        privateKey    = try container.decodeIfPresent(String.self,
                                                      forKey: .privateKey)
        salt          = try container.decodeIfPresent(String.self,
                                                      forKey: .salt)
        domainState   = try container.decodeIfPresent(String.self,
                                                      forKey: .domainState)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id,
                             forKey: .id)
        try container.encodeIfPresent(privateKey,
                                      forKey: .privateKey)
        try container.encodeIfPresent(salt,
                                      forKey: .salt)
        try container.encodeIfPresent(domainState,
                                      forKey: .domainState)
    }
}
