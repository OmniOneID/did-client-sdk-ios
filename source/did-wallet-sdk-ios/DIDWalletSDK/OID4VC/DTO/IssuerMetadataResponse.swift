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

public struct IssuerMetadataResponse: Jsonable, FromSnake
{
    public let credentialIssuer: String
    public let authorizationServers: [String]?
    public let credentialOfferEndpoint: String?
    public let credentialEndpoint: String
    public let tokenEndpoint: String?
    public let nonceEndpoint: String?
    public let deferredCredentialEndpoint: String?
    public let notificationEndpoint: String?
    public let credentialRequestEncryption: EncryptionSupport?
    public let credentialResponseEncryption: EncryptionSupport?
    public let credentialIdentifiersSupported: Bool?
    public let credentialConfigurationsSupported: [String: CredentialConfiguration]

    // MARK: - Flexible Type for Signing Algorithms (handles String and Int)
    public enum SigningAlg: Codable, Sendable {
        case string(String)
        case int(Int)
    }

    // MARK: - Encryption Support (what the issuer advertises, not what the wallet sends)
    public struct EncryptionSupport: Jsonable, FromSnake
    {
        public let algValuesSupported: [String]?
        public let encValuesSupported: [String]?
        public let encryptionRequired: Bool?
    }

    // MARK: - Credential Configuration (Main Expanded Model)
    public struct CredentialConfiguration: Jsonable, FromSnake
    {
        public let format: SupportedFormat //String
        public let scope: String?
        public let cryptographicBindingMethodsSupported: [String]?
        public let credentialSigningAlgValuesSupported: [SigningAlg]?
        public let proofTypesSupported: [String: ProofSupport]?
        public let vct: String?
        public let doctype: String?
        public let policy: CredentialPolicy?
        public let credentialMetadata: CredentialMetadata?
    }

    public struct CredentialPolicy: Jsonable, FromSnake
    {
        public let batchSize: Int?
        public let oneTimeUse: Bool?
    }

    public struct CredentialMetadata: Codable, Sendable {
        public let claims: [ClaimDetail]?
        public let display: [DisplayInfo]?
    }

    public struct DisplayInfo: Jsonable, FromSnake
    {
        public let name: String?
        public let logo: LogoInfo?
        public let locale: String?
        public let backgroundColor: String?
        public let textColor: String?
    }

    public struct LogoInfo: Jsonable, FromSnake
    {
        public let uri: String?
        public let altText: String?
    }

    public struct ProofSupport: Jsonable, FromSnake
    {
        public let proofSigningAlgValuesSupported: [String]?
    }

    public struct ClaimDetail: Jsonable, FromSnake
    {
        public let display: [DisplayInfo]? // Flexible: use DisplayInfo which covers name/locale
        public let mandatory: Bool?
        public let path: [String]?
        public let valueType: String?
    }

    /// Carries the issuer's original format token so it can be stored and re-sent verbatim.
    public enum SupportedFormat: Jsonable, Equatable
    {
        case sdjwt(String)
        case mdoc(String)
        case unknown(String)

        public var rawValue: String
        {
            switch self
            {
            case .sdjwt(let value), .mdoc(let value), .unknown(let value):
                return value
            }
        }
    }
}

// MARK: - SigningAlg Codable
extension IssuerMetadataResponse.SigningAlg {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
        } else if let x = try? container.decode(Int.self) {
            self = .int(x)
        } else {
            throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SigningAlg"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x): try container.encode(x)
        case .int(let x): try container.encode(x)
        }
    }
}

// MARK: - SupportedFormat Codable
extension IssuerMetadataResponse.SupportedFormat {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "dc+sd-jwt-did":
            self = .sdjwt(value)
        case "mso_mdoc-did":
            self = .mdoc(value)
        default:
            self = .unknown(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
