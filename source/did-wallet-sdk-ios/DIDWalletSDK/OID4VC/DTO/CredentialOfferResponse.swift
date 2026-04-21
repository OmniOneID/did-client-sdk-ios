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

struct CredentialOfferResponse: Jsonable, FromSnake
{
    @ValidURL var credentialIssuer: String
    var credentialConfigurationIds: [String]?
    var grants: Grants
}

struct Grants: Jsonable
{
    let preAuthorizedCode: PreAuthorizedCode?
    let authorizationCode: AuthorizationCode?

    enum CodingKeys: String, CodingKey
    {
        case preAuthorizedCode = "urn:ietf:params:oauth:grant-type:pre-authorized_code"
        case authorizationCode = "authorization_code"
    }
}

struct PreAuthorizedCode: Jsonable
{
    let preAuthorizedCode: String
    let txCode: TxCode?

    enum CodingKeys: String, CodingKey
    {
        case preAuthorizedCode = "pre-authorized_code"
        case txCode = "tx_code"
    }
}

struct TxCode: Jsonable, FromSnake
{
    let inputMode: String?
    let length: Int?
    let description: String?
}

struct AuthorizationCode: Jsonable, FromSnake
{
    let issuerState: String?
}

struct TestCredentialOfferResponse: Jsonable, FromSnake
{
    let credentialIssuer: String
    let credentialConfigurationIds: [String]?
    let grants: Grants
    let txCode: String
}
