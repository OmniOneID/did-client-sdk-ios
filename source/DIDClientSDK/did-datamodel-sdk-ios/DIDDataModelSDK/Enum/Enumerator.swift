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

/// Claim type
public enum ClaimType : String, Codable
{
    case text
    case image
    case document
}

/// Claim format
public enum ClaimFormat : String, Codable
{
    //text
    case plain
    case html
    case xml
    case csv
    //image
    case png
    case jpg
    case gif
    //document
    case txt
    case pdf
    case word
}

/// Value Location
public enum Location : String, Codable
{
    case inline
    case remote
    case attach
}

/// Proof purpose
public enum ProofPurpose : String, Codable
{
    case assertionMethod      = "assertionMethod"
    case authentication       = "authentication"
    case keyAgreement         = "keyAgreement"
    case capabilityInvocation = "capabilityInvocation"
    case capabilityDelegation = "capabilityDelegation"
}

/// Proof type
public enum ProofType : String, Codable, AlgorithmTypeConvertible
{
    public static var commonString: String
    {
        "Signature2018"
    }
    
    case rsaSignature2018       = "RsaSignature2018"
    case secp256k1Signature2018 = "Secp256k1Signature2018"
    case secp256r1Signature2018 = "Secp256r1Signature2018"
}

/// Algorithm type
public enum AlgorithmType : String, Codable
{
    case rsa       = "Rsa"
    case secp256k1 = "Secp256k1"
    case secp256r1 = "Secp256r1"
}

/// Credential schema type
public enum CredentialSchemaType : String, Codable
{
    case osdSchemaCredential = "OsdSchemaCredential"
}

/// Elliptic curve type
public enum EllipticCurveType: String, Codable, ConvertibleToAlgorithmType
{
    public static var commonString: String
    {
        emptyString
    }
    
    case secp256k1 = "Secp256k1"
    case secp256r1 = "Secp256r1"
}

/// Symmetric cipher type
public enum SymmetricCipherType : String, Codable
{
    case aes128CBC = "AES-128-CBC"
    case aes128ECB = "AES-128-ECB"
    case aes256CBC = "AES-256-CBC"
    case aes256ECB = "AES-256-ECB"
}

/// Symmetric padding type
public enum SymmetricPaddingType : String , Codable
{
    case noPad = "NOPAD"
    case pkcs5 = "PKCS5"
}

/// Indicate access method for Key
public enum AuthType : Int, Codable
{
    case free = 1
    case pin  = 2
    case bio  = 4
}

//MARK: - OptionSet
/// Indicate access method for Key and presentation option. Similar to AuthType
public struct VerifyAuthType : OptionSet, Sequence, Codable
{
    public let rawValue: Int
    
    public static let free = VerifyAuthType(rawValue: 1 << 0)
    public static let pin  = VerifyAuthType(rawValue: 1 << 1)
    public static let bio  = VerifyAuthType(rawValue: 1 << 2)
    
    public static let and  = VerifyAuthType(rawValue: 1 << 15)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

//MARK: - Extension
public extension OptionSet where Self.RawValue == Int
{
    func makeIterator() -> OptionSetIterator<Self>
    {
        return OptionSetIterator(element: self)
    }
}

public struct OptionSetIterator<Element: OptionSet>: IteratorProtocol where Element.RawValue == Int
{
    private let value: Element
    
    public init(element: Element)
    {
        self.value = element
    }
    
    private lazy var remainingBits = value.rawValue
    private var bitMask = 1
    
    public mutating func next() -> Element?
    {
        while remainingBits != 0 {
            defer
            { bitMask = bitMask &* 2
                
            }
            if remainingBits & bitMask != 0
            {
                remainingBits = remainingBits & ~bitMask
                return Element(rawValue: bitMask)
            }
        }
        return nil
    }
}
