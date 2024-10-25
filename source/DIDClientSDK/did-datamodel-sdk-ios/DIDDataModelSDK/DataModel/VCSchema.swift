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

/// VC schema
public struct VCSchema : Jsonable
{
    /// VC Metadata
    public struct VCMetadata : Jsonable
    {
        /// VC default language
        public var language      : String
        /// VC format version
        public var formatVersion : String
    }
    
    /// Credential Subject
    public struct CredentialSubject : Jsonable
    {
        /// Claim
        public struct Claim : Jsonable
        {
            /// Claim namespace
            public struct Namespace : Jsonable
            {
                /// Claim namespace
                public var id   : String
                /// Namespace name
                public var name : String
                /// URL for namespace information
                public var ref  : String?
            }
            
            /// Claim Definition
            public struct ClaimDef : Jsonable
            {
                /// Claim identifier
                public var id          : String
                /// Claim name
                public var caption     : String
                /// Claim type
                public var type        : ClaimType
                /// Claim format
                public var format      : ClaimFormat
                /// Hide value
                public var hideValue   : Bool? // default(false)
                /// Value Location
                public var location    : Location? // default(inline)
                /// Requirement
                public var required    : Bool? // default(true)
                /// Claim description
                public var description : String? //default("")
                /// Internationalization
                public var i18n        : [String : String]?
            }
            
            /// Claim namespace
            public var namespace : Namespace
            /// List of Claim definition
            public var items     : [ClaimDef]
        }
        
        /// Claim per namespace
        public var claims : [Claim]
    }
    
    /// URL for VC schema
    public var id                : String
    /// URL for VC schema format
    public var schema            : String
    /// VC schema name
    public var title             : String
    /// VC schema decription
    public var description       : String
    /// VC metadata
    public var metadata          : VCMetadata
    /// Credential subject
    public var credentialSubject : CredentialSubject
}

extension VCSchema : Codable
{
    enum CodingKeys: String, CodingKey
    {
        case id     = "@id"
        case schema = "@schema"
        case title,
             description,
             metadata,
             credentialSubject
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id,
                             forKey: .id)
        try container.encode(schema,
                             forKey: .schema)
        try container.encode(title,
                             forKey: .title)
        try container.encode(description,
                             forKey: .description)
        try container.encode(metadata,
                             forKey: .metadata)
        try container.encode(credentialSubject,
                             forKey: .credentialSubject)
    }

    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id                = try container.decode(String.self,
                                                 forKey: .id)
        schema            = try container.decode(String.self,
                                                 forKey: .schema)
        title             = try container.decode(String.self,
                                                 forKey: .title)
        description       = try container.decode(String.self,
                                                 forKey: .description)
        metadata          = try container.decode(VCMetadata.self,
                                                 forKey: .metadata)
        credentialSubject = try container.decode(CredentialSubject.self,
                                                 forKey: .credentialSubject)
        
    }
}
