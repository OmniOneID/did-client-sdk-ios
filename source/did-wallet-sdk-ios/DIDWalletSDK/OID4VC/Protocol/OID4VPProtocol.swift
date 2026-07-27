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
    public static func getAuthorizationRequest(uri : String) async throws -> AuthorizationRequest
    {
        guard
            let components = URLComponents(string: uri),
            let requestURI = components.queryItems?
                .first(where: { $0.name == "request_uri" })?
                .value
        else
        {
            throw OID4VPError.invalidRequestURI
        }
        
        let (encodedData, statusCode) = try await CommunicationClient.sendRequest(
            urlString: requestURI,
            httpMethod: .GET
        )
        
        if statusCode != 200
        {
            throw OID4VPError.failedToFetchJWS
        }
        let jws = JWS(from: String(data: encodedData, encoding: .utf8)!)
        if try jws.verify() == false
        {
            throw OID4VPError.failedToVerifyJWS
        }
        
        return try jws.getPayload()
        
    }
}

extension OID4VPProtocol
{
    /// Submits the ready-to-send authorization-response body (from `createVpToken`) to the
    /// verifier's `response_uri` as `application/x-www-form-urlencoded`.
    /// - Parameters:
    ///   - authRequest: The parsed authorization request (supplies `response_uri`).
    ///   - vpToken: The form body produced by `createVpToken` (clear or JWE-sealed).
    /// - Returns: The raw verifier response body and HTTP status code.
    /// - Throws: `OID4VPError.failedToSubmit` on a non-2xx response.
    @discardableResult
    public static func submitVpToken(
        authRequest: AuthorizationRequest,
        vpToken: Data
    ) async throws -> (Data, Int)
    {
        let (data, statusCode) = try await CommunicationClient.sendPostUrlencoded(
            urlString: authRequest.responseUri,
            requestJsonData: vpToken
        )

        guard (200...299).contains(statusCode)
        else
        {
            throw OID4VPError.failedToSubmit(statusCode)
        }
        return (data, statusCode)
    }

}

/// Errors thrown by the OID4VP (OpenID for Verifiable Presentations) flow.
public enum OID4VPError: Error, LocalizedError
{
    /// The presentation request URI is missing or malformed.
    case invalidRequestURI
    /// Fetching the signed authorization request (JWS) failed.
    case failedToFetchJWS
    /// The authorization request JWS signature could not be verified.
    case failedToVerifyJWS
    /// Submitting the vp_token to the verifier failed. Carries the HTTP status code.
    case failedToSubmit(Int)

    public var errorDescription: String?
    {
        switch self
        {
        case .invalidRequestURI:
            return "Invalid request URI format."
        case .failedToFetchJWS:
            return "Failed to fetch the authorization request JWS."
        case .failedToVerifyJWS:
            return "Failed to verify the authorization request JWS."
        case .failedToSubmit(let status):
            return "Failed to submit vp_token (HTTP \(status))."
        }
    }
}
