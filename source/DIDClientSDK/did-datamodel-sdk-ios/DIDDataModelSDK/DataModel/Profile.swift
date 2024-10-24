//
//  Profile.swift
//
//  Copyright 2024 Raonsecure
//

import Foundation

/// Profile type
public enum ProfileType : String, Codable
{
    case IssueProfile
    case VerifyProfile
}

/// Logo image
public struct LogoImage : Jsonable
{
    /// Logo image type
    public enum LogoImageType : String, Codable
    {
        case jpg
        case png
    }
    
    /// Image format
    public var format : LogoImageType
    /// URL for logo image
    public var link   : String?
    /// Image value
    public var value  : String?
}

/// Provider detail information
public struct ProviderDetail : Jsonable
{
    /// Provider DID
    public var did : String
    /// URL for Certificate of membership
    public var certVcRef : String
    
    /// Provider name
    public var name : String
    /// Provider description
    public var description : String?
    /// Logo Image
    public var logo : LogoImage?
    /// URL for reference
    public var ref : String?
}

/// End to end request data
public struct ReqE2e : Jsonable, ProofContainer
{
    /// Value for symmetric key creation
    public var nonce : String
    /// Elliptic curve type
    public var curve : EllipticCurveType
    /// Server's public key for encryption
    public var publicKey : String
    /// Cipher type
    public var cipher : SymmetricCipherType
    /// Padding type
    public var padding : SymmetricPaddingType
    /// Key aggreement proof
    public var proof : Proof?
}

/// Issuer Profile
public struct IssueProfile : Jsonable, ProofContainer
{
    /// Profile contents
    public struct Profile : Jsonable
    {
        /// VC schema information
        public struct CredentialSchema : Jsonable
        {
            /// URL for VC schema
            public var id : String
            /// VC schema format type
            public var type : CredentialSchemaType
            /// VC schema
            public var value : String?
        }
        
        /// Issuing process
        public struct Process : Jsonable
        {
            /// List of endpoint
            public var endpoints : [String]
            /// Request information
            public var reqE2e :  ReqE2e
            /// Issuer nonce
            public var issuerNonce : String
        }
        
        /// Issuer information
        public var issuer : ProviderDetail
        /// VC schema information
        public var credentialSchema : CredentialSchema
        /// Issuing process
        public var process : Process
    }
    
    /// Profile ID
    public var id : String
    /// Profile type
    public var type : ProfileType
    /// Profile title
    public var title : String
    /// Profile description
    public var description : String?
    /// Logo image
    public var logo : LogoImage?
    /// Profile encoding type
    public var encoding : String
    /// Profile language code
    public var language : String
    /// Profile contents
    public var profile : Profile
    /// Owner proof
    public var proof : Proof?
}

/// Verify Profile
public struct VerifyProfile : Jsonable, ProofContainer
{
    /// Profile contents
    public struct Profile : Jsonable
    {
        /// Filtering for presentation
        public struct ProfileFilter : Jsonable
        {
            /// Presentable claim and issuer  per VC schema
            public struct CredentialSchema : Jsonable
            {
                /// URL for VC schema
                public var id : String
                /// VC schema format type
                public var type : CredentialSchemaType
                /// VC schema
                public var value : String?
                /// Require to present all claims. Default(false)
                public var presentAll : Bool?
                /// Display claims
                public var displayClaims : [String]?
                /// Required claims
                public var requiredClaims : [String]?
                /// List of allowed issuers' DID
                public var allowedIssuers : [String]?
            }
            
            /// Presentable claim and issuer  per VC schema
            public var credentialSchemas : [CredentialSchema]
        }
        
        /// Method for VP presentation
        public struct Process : Jsonable
        {
            /// List of endpoint
            public var endpoints : [String]?
            /// Request information
            public var reqE2e :  ReqE2e
            /// Verifier nonce
            public var verifierNonce : String
            /// Indicate access method for Key
            public var authType : VerifyAuthType?
        }
        
        /// Verifier information
        public var verifier : ProviderDetail
        /// Filtering for presentation
        public var filter : ProfileFilter
        /// Method for VP presentation
        public var process : Process
    }
    
    /// Profile ID
    public var id : String
    /// Profile type
    public var type : ProfileType
    /// Profile title
    public var title : String
    /// Profile description
    public var description : String?
    /// Logo image
    public var logo : LogoImage?
    /// Profile encoding type
    public var encoding : String
    /// Profile language code
    public var language : String
    /// Profile contents
    public var profile : Profile
    /// Owner proof
    public var proof : Proof?
}

