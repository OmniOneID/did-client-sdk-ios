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

/// Decentralized digital certificate, hereafter VC
public struct VerifiableCredential : Jsonable, Identifiable
{
    /// JSON-LD context
    public var context           : [String]
    /// VC id
    public var id                : String
    /// List of VC type
    public var type              : [String]
    /// Issuer Information
    public var issuer            : Issuer
    /// Issuance datetime
    public var issuanceDate      : String
    /// This VC valid from the datetime
    @UTCDatetime public var validFrom         : String
    /// This VC valid until the datetime
    @UTCDatetime public var validUntil        : String
    /// VC encoding type
    public var encoding          : String
    /// VC format version
    public var formatVersion     : String
    /// VC language code
    public var language          : String
    /// Evidence
    public var evidence          : [Evidence]
    /// Credential schema
    public var credentialSchema  : CredentialSchema
    /// Credential subject
    public var credentialSubject : CredentialSubject
    /// Issuer proof
    public var proof             : VCProof
    
    /// Issuer information
    public struct Issuer : Jsonable
    {
        /// Issuer's DID
        public var id        : String
        /// Issuer's name
        public var name      : String?
    }
    
    /// Evidence Enumerator for Multitype array
    public enum Evidence
    {
        case documentVerification(DocumentVerificationEvidence)
    }
    
    /// Presence type
    public enum Presence : String, Codable
    {
        case physical = "Physical"
        case digital  = "Digital"
    }
    
    /// Evidence type
    public enum EvidenceType : String, Codable
    {
        case documentVerification = "DocumentVerification"
    }
    
    /// Document verification for Evidence
    public struct DocumentVerificationEvidence : Jsonable
    {
        /// URL for the evidence information
        public var id       : String?
        /// Evidence type
        public var type     : EvidenceType
        /// Evidence verifier
        public var verifier : String
        
        /// Name of Evidence document
        public var evidenceDocument : String
        /// Subject presence type
        public var subjectPresence  : Presence
        /// Document presence type
        public var documentPresence : Presence
        /// Document attribute
        public var attribute : [String: String]?
    }
    
    /// Credential schema
    public struct CredentialSchema : Jsonable
    {
        /// URL for VC schema
        public var id   : String
        /// VC Schema format type
        public var type : CredentialSchemaType
    }
    
    /// Credential subject
    public struct CredentialSubject : Jsonable
    {
        /// Subject DID
        public var id     : String
        /// List of claim
        public var claims : [Claim]
    }
    
    /// Information for Subject
    public struct Claim : Jsonable
    {
        /// Internationalization
        public struct Internationalization : Jsonable
        {
            public var caption  : String
            public var value    : String?
            public var digestSRI: String?
        }
        
        /// Claim code
        public var code     : String
        /// Claim name
        public var caption  : String
        /// Claim value
        public var value    : String
        /// Claim type
        public var type     : ClaimType
        /// Claim format
        public var format   : ClaimFormat
        /// Hide value
        public var hideValue: Bool? //default(false)
        /// Value Location
        public var location : Location? //default(inline)
        /// Digest Subresource Integrity
        public var digestSRI: String?
        /// Internationalization
        public var i18n     : [String : Internationalization]?
    }
}

//MARK: - Extension

extension VerifiableCredential : Codable
{
    enum CodingKeys: String, CodingKey
    {
        case context = "@context"
        case id,
             type,
             issuer,
             issuanceDate,
             validFrom,
             validUntil,
             encoding,
             formatVersion,
             language,
             evidence,
             credentialSchema,
             credentialSubject,
             proof
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
        try container.encode(issuer,
                             forKey: .issuer)
        try container.encode(issuanceDate,
                             forKey: .issuanceDate)
        try container.encode(validFrom,
                             forKey: .validFrom)
        try container.encode(validUntil,
                             forKey: .validUntil)
        try container.encode(encoding,
                             forKey: .encoding)
        try container.encode(formatVersion,
                             forKey: .formatVersion)
        try container.encode(language,
                             forKey: .language)
        try container.encode(evidence,
                             forKey: .evidence)
        try container.encode(credentialSchema,
                             forKey: .credentialSchema)
        try container.encode(credentialSubject,
                             forKey: .credentialSubject)
        try container.encode(proof,
                             forKey: .proof)
    }

    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        context             = try container.decode([String].self,
                                                   forKey: .context)
        id                  = try container.decode(String.self,
                                                   forKey: .id)
        type                = try container.decode([String].self,
                                                   forKey: .type)
        issuer              = try container.decode(Issuer.self,
                                                   forKey: .issuer)
        issuanceDate        = try container.decode(String.self,
                                                   forKey: .issuanceDate)
        validFrom           = try container.decode(String.self,
                                                   forKey: .validFrom)
        validUntil          = try container.decode(String.self,
                                                   forKey: .validUntil)
        encoding            = try container.decode(String.self,
                                                   forKey: .encoding)
        formatVersion       = try container.decode(String.self,
                                                   forKey: .formatVersion)
        language            = try container.decode(String.self,
                                                   forKey: .language)
        evidence            = try container.decode([Evidence].self,
                                                   forKey: .evidence)
        credentialSchema    = try container.decode(CredentialSchema.self,
                                                   forKey: .credentialSchema)
        credentialSubject   = try container.decode(CredentialSubject.self,
                                                   forKey: .credentialSubject)
        proof               = try container.decode(VCProof.self,
                                                   forKey: .proof)
    }
}

extension VerifiableCredential.Evidence : Codable
{
    enum CodingKeys : String, CodingKey
    {
        case type
    }
    
    public func encode(to encoder: any Encoder) throws
    {
        var singleContainer = encoder.singleValueContainer()
        
        switch self
        {
        case .documentVerification(let evidence):
            try singleContainer.encode(evidence)
        }
    }
    
    public init(from decoder : Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()
        
        let type = try container.decode(VerifiableCredential.EvidenceType.self, forKey: .type)
        
        switch type
        {
        case .documentVerification:
            let documentVerification = try singleContainer.decode(VerifiableCredential.DocumentVerificationEvidence.self)
            self = .documentVerification(documentVerification)
        }
    }
}

