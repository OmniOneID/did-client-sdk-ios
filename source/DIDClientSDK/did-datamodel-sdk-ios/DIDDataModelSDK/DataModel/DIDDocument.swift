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

/// Document for Decentralized Identifiers
public struct DIDDocument : Jsonable, ProofsContainer
{
    /// JSON-LD context
    public var context              : [String]
    /// DID owner's did
    public var id                   : String
    /// DID controller's did
    public var controller           : String
    /// List of DID key with public key value
    public var verificationMethod   : [VerificationMethod]
    /// List of Assertion key name
    public var assertionMethod      : [String]?
    /// List of Authentication key name
    public var authentication       : [String]?
    /// List of Key Agreement key name
    public var keyAgreement         : [String]?
    /// List of Capability Invocation key name
    public var capabilityInvocation : [String]?
    /// List of Capability Delegation key name
    public var capabilityDelegation : [String]?
    /// List of service
    public var service              : [Service]?
    /// Created datetime
    @UTCDatetime  public var created   : String
    /// Updated datetime
    @UTCDatetime  public var updated   : String
    /// DID version id
    @DIDVersionId public var versionId : String
    /// True: deactivated, False: activated
    public var deactivated          : Bool
    /// Owner proof
    public var proof                : Proof?
    /// List of owner proof
    public var proofs               : [Proof]?
    
    /// List of DID key with public key value
    public struct VerificationMethod : Jsonable
    {
        /// Key name
        public var id                  : String
        /// Key type
        public var type                : DIDKeyType
        /// Key controller's did
        public var controller          : String
        /// Public key value
        public var publicKeyMultibase  : String
        /// Required authentication to use the key
        public var authType            : AuthType
        
        public init(id: String,
                    type: DIDDocument.DIDKeyType,
                    controller: String,
                    publicKeyMultibase: String,
                    authType: AuthType)
        {
            self.id = id
            self.type = type
            self.controller = controller
            self.publicKeyMultibase = publicKeyMultibase
            self.authType = authType
        }
    }
    
    /// List of service
    public struct Service : Jsonable
    {
        /// Service id
        public var id                  : String
        /// Service type
        public var type                : DIDServiceType
        /// List of URL to the service
        public var serviceEndpoint     : [String]
        
        public init(id: String,
                    type: DIDServiceType,
                    serviceEndpoint: [String])
        {
            self.id = id
            self.type = type
            self.serviceEndpoint = serviceEndpoint
        }
    }
    
    /// DID key type
    public enum DIDKeyType : String, Codable, AlgorithmTypeConvertible
    {
        public static var commonString: String
        {
            "VerificationKey2018"
        }
        
        case rsaVerificationKey2018        = "RsaVerificationKey2018"
        case secp256k1VerificationKey2018  = "Secp256k1VerificationKey2018"
        case secp256r1VerificationKey2018  = "Secp256r1VerificationKey2018"
        
    }
     /// Service type
    public enum DIDServiceType : String, Codable
    {
        case linkedDomains      = "LinkedDomains"
        case credentialRegistry = "CredentialRegistry"
    }
}

//MARK: - Extension

extension DIDDocument
{
    public init(id : String, 
                controller : String? = nil,
                @UTCDatetime created : String)
    {
        self.context = ["https://www.w3.org/ns/did/v1"]
        self.id = id
        self.controller = controller ?? id
        self.verificationMethod = .init()
        self.created = created
        self.updated = created
        self.versionId = "1"
        self.deactivated = false
    }
}

extension DIDDocument : Codable
{
    enum CodingKeys: String, CodingKey
    {
        case context = "@context"
        case id,
             controller,
             verificationMethod,
             assertionMethod,
             authentication,
             keyAgreement,
             capabilityInvocation,
             capabilityDelegation,
             service,
             created,
             updated,
             versionId,
             deactivated,
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
        try container.encode(controller,
                             forKey: .controller)
        try container.encode(verificationMethod,
                             forKey: .verificationMethod)
        try container.encodeIfPresent(assertionMethod,
                                      forKey: .assertionMethod)
        try container.encodeIfPresent(authentication,
                                      forKey: .authentication)
        try container.encodeIfPresent(keyAgreement,
                                      forKey: .keyAgreement)
        try container.encodeIfPresent(capabilityInvocation,
                                      forKey: .capabilityInvocation)
        try container.encodeIfPresent(capabilityDelegation,
                                      forKey: .capabilityDelegation)
        try container.encodeIfPresent(service,
                                      forKey: .service)
        try container.encode(created,
                             forKey: .created)
        try container.encode(updated,
                             forKey: .updated)
        try container.encode(versionId,
                             forKey: .versionId)
        try container.encode(deactivated,
                             forKey: .deactivated)
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
        controller           = try container.decode(String.self,
                                                    forKey: .controller)
        verificationMethod   = try container.decode([VerificationMethod].self,
                                                    forKey: .verificationMethod)
        assertionMethod      = try container.decodeIfPresent([String].self,
                                                             forKey: .assertionMethod)
        authentication       = try container.decodeIfPresent([String].self,
                                                             forKey: .authentication)
        keyAgreement         = try container.decodeIfPresent([String].self,
                                                             forKey: .keyAgreement)
        capabilityInvocation = try container.decodeIfPresent([String].self,
                                                             forKey: .capabilityInvocation)
        capabilityDelegation = try container.decodeIfPresent([String].self,
                                                             forKey: .capabilityDelegation)
        service              = try container.decodeIfPresent([Service].self,
                                                             forKey: .service)
        created              = try container.decode(String.self,
                                                    forKey: .created)
        updated              = try container.decode(String.self,
                                                    forKey: .updated)
        versionId            = try container.decode(String.self,
                                                    forKey: .versionId)
        deactivated          = try container.decode(Bool.self,
                                                    forKey: .deactivated)
        proof                = try container.decodeIfPresent(Proof.self,
                                                            forKey: .proof)
        proofs               = try container.decodeIfPresent([Proof].self,
                                                             forKey: .proofs)
    }
}
