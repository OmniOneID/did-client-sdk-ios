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

struct TokenRequest: Jsonable, FromSnake
{
//    var clientId: String    = "oid4vci-ios"/*"oid4vci-ios-opendid"*/
    var grantType: String   = "urn:ietf:params:oauth:grant-type:pre-authorized_code"
    var preAuthorizedCode: String
    var txCode: String?
    var authorizationDetails: [AuthorizationDetails]
}

extension TokenRequest
{
//    private static let clientIdKey   = AnyCodingKey(stringValue: "client_id")!
//    private static let clientIdConvertedKey = AnyCodingKey(stringValue: "clientId")!
    
    private static let grantTypeKey  = AnyCodingKey(stringValue: "grant_type")!
    private static let grantTypeConvertedKey = AnyCodingKey(stringValue: "grantType")!
    
    private static let preAuthKey    = AnyCodingKey(stringValue: "pre-authorized_code")!
    private static let preAuthConvertedKey = AnyCodingKey(stringValue: "pre-authorizedCode")!
    
    private static let txCodeKey     = AnyCodingKey(stringValue: "tx_code")!
    private static let txCodeConvertedKey = AnyCodingKey(stringValue: "txCode")!
    
    private static let authDetailKey = AnyCodingKey(stringValue: "authorization_details")!
    private static let authDetailConvertedKey = AnyCodingKey(stringValue: "authorizationDetails")!
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        
//        self.clientId =
//        try container.decodeIfPresent(String.self, forKey: Self.clientIdKey)
//        ?? container.decode(String.self, forKey: Self.clientIdConvertedKey)
        
        self.grantType =
        try container.decodeIfPresent(String.self, forKey: Self.grantTypeKey)
        ?? container.decode(String.self, forKey: Self.grantTypeConvertedKey)
        
        self.preAuthorizedCode =
        try container.decodeIfPresent(String.self, forKey: Self.preAuthKey)
        ?? container.decode(String.self, forKey: Self.preAuthConvertedKey)
        
        self.txCode =
        try container.decodeIfPresent(String.self, forKey: Self.txCodeKey)
        ?? container.decodeIfPresent(String.self, forKey: Self.txCodeConvertedKey)
        
        self.authorizationDetails =
        try container.decodeIfPresent([AuthorizationDetails].self, forKey: Self.authDetailKey)
        ?? container.decode([AuthorizationDetails].self, forKey: Self.authDetailConvertedKey)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        
//        try container.encode(
//            clientId,
//            forKey: Self.clientIdKey
//        )
//        
        try container.encode(
            grantType,
            forKey: Self.grantTypeKey
        )
        
        try container.encode(
            preAuthorizedCode,
            forKey: Self.preAuthKey
        )
        
        try container.encodeIfPresent(
            txCode,
            forKey: Self.txCodeKey
        )
        
        try container.encode(
            authorizationDetails,
            forKey: Self.authDetailKey
        )
    }
}
