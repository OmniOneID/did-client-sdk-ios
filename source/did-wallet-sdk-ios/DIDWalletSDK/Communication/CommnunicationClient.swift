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

public struct CommnunicationClient: CommnunicationProtocol {
    
    static let defaultTimeoutInterval: TimeInterval = 30
    
    /// Retrieves data from the specified URL in an synchronous manner using the GET method.
    /// - Parameters:
    ///   - url: The URL to retrieve data from.
    /// - Returns: Data object containing the retrieved data from the URL.
    /// - Throws: CommunicationAPIError with the error code FAIL if the HTTP response status code is not 200.
    public static func doGet(url: URL) async throws -> Data {
        
        WalletLogger.shared.debug("\n************** requestUrl: \(url.absoluteString) **************")
        
        guard !url.absoluteString.isEmpty else {
            throw CommunicationAPIError.invaildParameter.getError()
        }
        
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = Self.defaultTimeoutInterval
            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            request.httpMethod = "GET"
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                WalletLogger.shared.debug("statusCode: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                WalletLogger.shared.debug("resultData: \(String(describing: String(data: data, encoding: .utf8)))\n")
                throw CommunicationAPIError.serverFail((String(describing: String(data: data, encoding: .utf8)))).getError()
            }
            WalletLogger.shared.debug("errorcode: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            WalletLogger.shared.debug("resultData: \(String(describing: String(data: data, encoding: .utf8)))\n")
            return data
        } catch _ as URLError {
            throw CommunicationAPIError.incorrectURLconnection.getError()
        }
    }
    
    /// Performs a POST request to the specified URL with the provided JSON data in an synchronous manner.
    /// - Parameters:
    ///   - url: The URL to send the POST request to.
    ///   - requestJsonData: The JSON data to include in the POST request.
    /// - Returns: Data object containing the response data from the POST request.
    /// - Throws: CommunicationAPIError with the error code FAIL if the HTTP response status code is not 200.
    public static func doPost(url: URL, requestJsonData: Data) async throws -> Data {
        
        WalletLogger.shared.debug("\n************** requestUrl: \(url.absoluteString) **************")
        WalletLogger.shared.debug("requestData Json: \(String(data: requestJsonData, encoding:.utf8)!)")
        
        guard !url.absoluteString.isEmpty else {
            throw CommunicationAPIError.invaildParameter.getError()
        }
        guard !requestJsonData.isEmpty else {
            throw CommunicationAPIError.invaildParameter.getError()
        }
        
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = Self.defaultTimeoutInterval
            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            request.httpMethod = "POST"
            request.httpBody = requestJsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                WalletLogger.shared.debug("statusCode: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                WalletLogger.shared.debug("resultData: \(String(describing: String(data: data, encoding: .utf8)))\n")
                throw CommunicationAPIError.serverFail(String(data: data, encoding: .utf8)!).getError()
    
            }
            WalletLogger.shared.debug("errorcode: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            WalletLogger.shared.debug("resultData: \(String(describing: String(data: data, encoding: .utf8)))\n")
            return data
        } catch _ as URLError {
            throw CommunicationAPIError.incorrectURLconnection.getError()
        }
    }
}

extension CommnunicationClient : ZKPCommunicationProtocol
{
    /// Retrieves ZKPCredentialSchema object from the specified URL in an synchronous manner using the GET method.
    /// - Parameters:
    ///   - hostUrlString: The string to retrieve data from.
    ///   - id: The Schema ID
    /// - Returns: ZKPCredentialSchema object
    /// - Throws: CommunicationAPIError with the error code FAIL if the HTTP response status code is not 200.
    public static func getZKPCredentialSchama(hostUrlString : String, id : String) async throws -> ZKPCredentialSchema
    {
        let path : String = "\(hostUrlString)/api-gateway/api/v1/zkp-cred-schema?id=\(id)"
        let responseData = try await Self.doGet(url: URL(string:path)!)
        
        let credSchemaVO : CredSchemaVO = try .init(from: responseData)
        
        return try .init(from: try MultibaseUtils.decode(encoded: credSchemaVO.credSchema))
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
        let responseData = try await Self.doGet(url: URL(string:path)!)
        
        let credDefVO : CredDefVO = try .init(from: responseData)
        
        return try .init(from: try MultibaseUtils.decode(encoded: credDefVO.credDef))
    }
}
