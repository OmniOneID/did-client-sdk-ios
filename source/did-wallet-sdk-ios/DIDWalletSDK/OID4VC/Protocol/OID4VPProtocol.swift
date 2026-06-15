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

public struct OID4VPProtocol
{
    static let schemaIdValues : String = "credential_schema_id_values"
    static let vctValus       : String = "vct_values"
    
    public static func getAuthorizationRequest(uri : String) async throws -> AuthorizationRequest
    {
        guard
            let components = URLComponents(string: uri),
            let requestURI = components.queryItems?
                .first(where: { $0.name == "request_uri" })?
                .value
        else
        {
            //TODO: Invalid Request URI format.
            throw NSError(domain: "Invalid Request URI format.", code: 0)
        }
        
        let (encodedData, statusCode) = try await CommunicationClient.sendRequest(
            urlString: requestURI,
            httpMethod: .GET
        )
        
        if statusCode != 200
        {
            //TODO: Failed to get JWS
            throw NSError(domain: "Failed to get JWS", code: 0)
        }
        let jws = JWS(from: String(data: encodedData, encoding: .utf8)!)
        if try jws.verify() == false
        {
            //TODO: Failed to get JWS
            throw NSError(domain: "Failed to verify JWS", code: 0)
        }
        
        return try jws.getPayload()
        
    }
    
    
    public static func findEligibleSubmittables(authRequest : AuthorizationRequest)
    {
        
    }
    
}
