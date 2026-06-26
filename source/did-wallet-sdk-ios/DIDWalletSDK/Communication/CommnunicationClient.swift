/*
 * Copyright 2024-2025 OmniOne.
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

public struct CommunicationClient//: CommunicationProtocol
{
    
    public enum HTTPMethod : String
    {
        case GET
        case POST
        case DELETE
    }
    
    public static let defaultTimeoutInterval: TimeInterval = 30
    
    /// Sends an asynchronous HTTP request to the specified URL with the given parameters and returns a decoded response.
    ///
    /// This method supports sending any request that conforms to the `Jsonable` protocol.
    /// You can specify the HTTP method, custom headers, and an optional request body.
    /// The response will be decoded into the expected type `T`, which must also conform to `Jsonable`.
    ///
    /// - Parameters:
    ///   - urlString: The URL string to send the request to.
    ///   - httpMethod: The HTTP method to use (e.g., `.GET`, `.POST`). Defaults to `.POST`.
    ///   - headerFields: A dictionary of HTTP header fields. Defaults to `defaultHttpHeaderField`.
    ///   - requestJsonable: An optional request body conforming to `Jsonable`.
    ///
    /// - Returns: Decoded response of type `T`
    /// - Throws: An error if the request fails, the URL is invalid,  the server returns an error response or if decoding the response fails.
    public static func sendRequest<T : Jsonable>(urlString : String,
                                                 httpMethod : HTTPMethod = .POST,
                                                 headerFields : StringDictionary = DefaultHttpHeaderFields,
                                                 requestJsonable : Jsonable? = nil) async throws -> T
    {
        let jsonData : Data? = (requestJsonable != nil)
        ? try requestJsonable?.toJsonData()
        : nil
        
        let (resultData, statusCode) = try await sendRequest(urlString: urlString,
                                                             httpMethod: httpMethod,
                                                             headerFields: headerFields,
                                                             requestJsonData: jsonData)
        
        if statusCode == 200
        {
            return try .init(from: resultData)
        }
        else
        {
            if let errorString = String(data: resultData, encoding: .utf8)
            {
                throw CommunicationAPIError.serverFail(errorString).getError()
            }
            throw CommunicationAPIError.unknown.getError()
        }
    }
    
    /// Sends an asynchronous HTTP request with the specified parameters and returns the raw response data.
    ///
    /// This method constructs and sends an HTTP request using the provided URL, HTTP method, headers, and optional JSON body.
    /// It returns the response as raw `Data` without attempting to decode it.
    ///
    /// - Parameters:
    ///   - urlString: The URL string of the API endpoint.
    ///   - httpMethod: The HTTP method to use for the request (e.g., `.GET`, `.POST`). Defaults to `.POST`.
    ///   - headerFields: A dictionary containing HTTP header fields. Defaults to `defaultHttpHeaderField`.
    ///   - requestJsonData: The optional request body in JSON format as `Data`. Can be `nil` for methods like GET.
    ///
    /// - Returns: A tuple containing the raw response data and the HTTP status code
    /// - Throws: An error if the request fails, the URL is invalid, or the server returns an error response.
    public static func sendRequest(urlString : String,
                                   httpMethod : HTTPMethod = .POST,
                                   headerFields : StringDictionary = DefaultHttpHeaderFields,
                                   requestJsonData : Data? = nil) async throws -> (Data, Int)
    {
        WalletLogger.debug("\n************** requestUrl: \(urlString) **************")
        
        guard !urlString.isEmpty
        else
        {
            throw CommunicationAPIError.invaildParameter.getError()
        }
        
        guard let url = URL(string: urlString)
        else
        {
            throw CommunicationAPIError.incorrectURLconnection.getError()
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = Self.defaultTimeoutInterval
        for (key, value) in headerFields
        {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpMethod = httpMethod.rawValue
        
        if let requestJsonData = requestJsonData
        {
            if httpMethod == .GET
            {
                throw CommunicationAPIError.invaildParameter.getError()
            }
            else
            {
                if requestJsonData.isEmpty
                {
                    throw CommunicationAPIError.invaildParameter.getError()
                }
                
                request.httpBody = requestJsonData
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse
        else
        {
            throw CommunicationAPIError.unknown.getError()
        }
        
        let statusCode = httpResponse.statusCode
        
        WalletLogger.debug("statusCode: \(String(describing: statusCode))")
        WalletLogger.debug("resultData: \(String(data: data, encoding: .utf8) ?? "")\n")
        
        return (data, statusCode)
    }
    
    public static func sendPostUrlencoded<T : Jsonable>(
        urlString : String,
        headerFields : StringDictionary = XWWWFormHttpHeaderFields,
        requestJsonable : Jsonable
    ) async throws -> T
    {
        let jsonData : Data = try requestJsonable.toFormData()
        
        let (resultData, statusCode) = try await sendPostUrlencoded(
            urlString: urlString,
            headerFields: headerFields,
            requestJsonData: jsonData
        )
        
        if statusCode == 200
        {
            return try .init(from: resultData)
        }
        else
        {
            if let errorString = String(data: resultData, encoding: .utf8)
            {
                throw CommunicationAPIError.serverFail(errorString).getError()
            }
            throw CommunicationAPIError.unknown.getError()
        }
    }
    
    
    public static func sendPostUrlencoded(urlString : String,
                                          headerFields : StringDictionary = XWWWFormHttpHeaderFields,
                                          requestJsonData : Data) async throws -> (Data, Int)
    {
        WalletLogger.debug("\n************** requestUrl: \(urlString) **************")
        
        guard !urlString.isEmpty
        else
        {
            throw CommunicationAPIError.invaildParameter.getError()
        }
        
        guard let url = URL(string: urlString)
        else
        {
            throw CommunicationAPIError.incorrectURLconnection.getError()
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = Self.defaultTimeoutInterval
        for (key, value) in headerFields
        {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpMethod = HTTPMethod.POST.rawValue
        
        request.httpBody = requestJsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse
        else
        {
            throw CommunicationAPIError.unknown.getError()
        }
        
        let statusCode = httpResponse.statusCode
        
        WalletLogger.debug("statusCode: \(String(describing: statusCode))")
        WalletLogger.debug("resultData: \(String(data: data, encoding: .utf8) ?? "")\n")
        
        return (data, statusCode)
    }
}

extension CommunicationClient : CommunicationRetrieving
{
    public static func getDIDDocument(hostUrlString : String,
                                      did: String,
                                      versionId: String? = nil) async throws -> DIDDocument
    {
        guard var url = URL(string: hostUrlString)
        else
        {
            throw CommunicationAPIError.incorrectURLconnection.getError()
        }
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else
        {
            throw CommunicationAPIError.incorrectURLconnection.getError()
        }
        components.path += "/api-gateway/api/v1/did-doc"
        var queryItems = [URLQueryItem(name: "did", value: did)]
        if let versionId = versionId
        {
            queryItems.append(URLQueryItem(name: "versionId", value: versionId))
        }
        components.queryItems = queryItems
        guard let resolvedURL = components.url
        else
        {
            throw CommunicationAPIError.incorrectURLconnection.getError()
        }
        url = resolvedURL
        
        let coveredDIDDoc : DIDDocVO = try await sendRequest(urlString: url.absoluteString,
                                                             httpMethod: .GET)
        
        return try .init(fromMultibase: coveredDIDDoc.didDoc)
        
    }
    
    
    /// Retrieves ZKPCredentialSchema object from the specified URL in an synchronous manner using the GET method.
    /// - Parameters:
    ///   - hostUrlString: The string to retrieve data from.
    ///   - id: The Schema ID
    /// - Returns: ZKPCredentialSchema object
    /// - Throws: CommunicationAPIError with the error code FAIL if the HTTP response status code is not 200.
    public static func getZKPCredentialSchama(
        hostUrlString : String,
        id : String
    ) async throws -> ZKPCredentialSchema
    {
        let path : String = "\(hostUrlString)/api-gateway/api/v1/zkp-cred-schema?id=\(id)"
        
        let credSchemaVO : CredSchemaVO = try await sendRequest(urlString: path,
                                                                httpMethod: .GET)
        
        return try .init(fromMultibase: credSchemaVO.credSchema)
    }
    
    /// Retrieves ZKPCredentialDefinition object from the specified URL in an synchronous manner using the GET method.
    /// - Parameters:
    ///   - hostUrlString: The string to retrieve data from.
    ///   - id: The CredentialDefinition ID
    /// - Returns: ZKPCredentialDefinition object
    /// - Throws: CommunicationAPIError with the error code FAIL if the HTTP response status code is not 200.
    public static func getZKPCredentialDefinition(hostUrlString : String, id : String) async throws -> ZKPCredentialDefinition
    {
        let path : String = "\(hostUrlString)/api-gateway/api/v1/zkp-cred-def?id=\(id)"
        
        let credDefVO : CredDefVO = try await sendRequest(urlString: path,
                                                          httpMethod: .GET)
        
        return try .init(fromMultibase: credDefVO.credDef)
    }
}
