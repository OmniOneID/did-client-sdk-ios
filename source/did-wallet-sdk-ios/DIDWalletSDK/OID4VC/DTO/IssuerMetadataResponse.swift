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

struct IssuerMetadataResponse: Jsonable, FromSnake
{
    let credentialIssuer: String
    let authorizationServers: [String]?
    let credentialEndpoint: String
    let tokenEndpoint: String?
    let nonceEndpoint: String?
    let deferredCredentialEndpoint: String?
    let notificationEndpoint: String?
    let credentialResponseEncryptionAlgValuesSupported: [String]?
    let credentialResponseEncryptionEncValuesSupported: [String]?
    let requireCredentialResponseEncryption: Bool?
    let credentialIdentifiersSupported: Bool?
    let credentialConfigurationsSupported: [String: CredentialConfiguration]
}

// MARK: - Flexible Type for Signing Algorithms (handles String and Int)
enum SigningAlg: Codable {
    case string(String)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
        } else if let x = try? container.decode(Int.self) {
            self = .int(x)
        } else {
            throw DecodingError.typeMismatch(SigningAlg.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SigningAlg"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x): try container.encode(x)
        case .int(let x): try container.encode(x)
        }
    }
}

// MARK: - Credential Configuration (Main Expanded Model)
struct CredentialConfiguration: Jsonable, FromSnake
{
    let format: SupportedFormat //String
    let scope: String?
    let cryptographicBindingMethodsSupported: [String]?
    let credentialSigningAlgValuesSupported: [SigningAlg]?
    let display: [DisplayInfo]?
    let proofTypesSupported: [String: ProofSupport]?
    let vct: String?
    let claims: [String: ClaimDetail]?
    let doctype: String?
    let credentialMetadata: CredentialMetadata?
}

struct CredentialMetadata: Codable {
    let claims: [ClaimDetail]?
    let display: [DisplayInfo]?
}

struct DisplayInfo: Jsonable, FromSnake
{
    let name: String?
    let logo: LogoInfo?
    let locale: String?
    let backgroundColor: String?
    let textColor: String?
}

struct LogoInfo: Jsonable, FromSnake
{
    let uri: String?
    let altText: String?
}

struct ProofSupport: Jsonable, FromSnake
{
    let proofSigningAlgValuesSupported: [String]?
}

struct ClaimDetail: Jsonable, FromSnake
{
    let display: [DisplayInfo]? // Flexible: use DisplayInfo which covers name/locale
    let mandatory: Bool?
    let path: [String]?
    let valueType: String?
}

enum SupportedFormat: Jsonable, Equatable
{
    case sdjwt
    case mdoc
    case unknown(String)
    
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "dc+sd-jwt":
            self = .sdjwt
        case "mso_mdoc":
            self = .mdoc
        default:
            self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .sdjwt:
            try container.encode("dc+sd-jwt")
        case .mdoc:
            try container.encode("mso_mdoc")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}
