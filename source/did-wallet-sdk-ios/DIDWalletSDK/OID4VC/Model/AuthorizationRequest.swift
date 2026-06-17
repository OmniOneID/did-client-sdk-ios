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

public struct AuthorizationRequest : Jsonable, FromSnake
{
    public let responseUri: String
    public let nonce: String
    public let state: String
    public let clientId: String
    
    public let responseType: String
    public let responseMode: String
    public let dcqlQuery: DCQLQuery
    
    public let clientMetadata: [String: AnyJSON]
    public let iat : Int
}
