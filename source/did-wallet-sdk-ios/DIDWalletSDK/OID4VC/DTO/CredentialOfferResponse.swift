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

public struct CredentialOfferResponse: Jsonable, FromSnake
{
    var credentialIssuer: String
    var credentialConfigurationIds: [String]?
    var grants: Grants
    
    public struct Grants: Jsonable
    {
        let preAuthorizedCode: PreAuthorizedCode?
        let authorizationCode: AuthorizationCode?
        
        public struct PreAuthorizedCode: Jsonable
        {
            let preAuthorizedCode: String
            let txCode: TxCode?
            
            public struct TxCode: Jsonable
            {
                let inputMode: String?
                let length: Int?
                let description: String?
            }
        }
        
        public struct AuthorizationCode: Jsonable
        {
            let issuerState: String?
        }
    }
}

extension CredentialOfferResponse.Grants
{
    private static let preAuthKey  = AnyCodingKey(stringValue: "urn:ietf:params:oauth:grant-type:pre-authorized_code")!
    private static let preAuthConvertedKey  = AnyCodingKey(stringValue: "urn:ietf:params:oauth:grant-type:pre-authorizedCode")!

    private static let authCodeKey = AnyCodingKey(stringValue: "authorization_code")!
    private static let authCodeConvertedKey = AnyCodingKey(stringValue: "authorizationCode")!
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        
        self.preAuthorizedCode =
        try container.decodeIfPresent(PreAuthorizedCode.self, forKey: Self.preAuthKey)
        ?? container.decodeIfPresent(PreAuthorizedCode.self, forKey: Self.preAuthConvertedKey)
        
        self.authorizationCode =
        try container.decodeIfPresent(AuthorizationCode.self, forKey: Self.authCodeKey)
        ?? container.decodeIfPresent(AuthorizationCode.self, forKey: Self.authCodeConvertedKey)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        
        try container.encodeIfPresent(
            preAuthorizedCode,
            forKey: Self.preAuthKey
        )
        
        try container.encodeIfPresent(
            authorizationCode,
            forKey: Self.authCodeKey
        )
    }
}

extension CredentialOfferResponse.Grants.PreAuthorizedCode
{
    private static let preAuthorizedCodeKey = AnyCodingKey(stringValue: "pre-authorized_code")!
    private static let preAuthorizedCodeConvertedKey = AnyCodingKey(stringValue: "pre-authorizedCode")!

    private static let txCodeKey            = AnyCodingKey(stringValue: "tx_code")!
    private static let txCodeConvertedKey            = AnyCodingKey(stringValue: "txCode")!
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        
        self.preAuthorizedCode =
        try container.decodeIfPresent(String.self, forKey: Self.preAuthorizedCodeKey)
        ?? container.decode(String.self, forKey: Self.preAuthorizedCodeConvertedKey)
        
        self.txCode =
        try container.decodeIfPresent(TxCode.self, forKey: Self.txCodeKey)
        ?? container.decodeIfPresent(TxCode.self, forKey: Self.txCodeConvertedKey)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        
        try container.encode(
            preAuthorizedCode,
            forKey: Self.preAuthorizedCodeKey
        )
        
        try container.encodeIfPresent(
            txCode,
            forKey: Self.txCodeKey
        )
    }
}
