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

enum AuthorizationGrantType
{
    case preAuthorizedCode
    case authorizationCode
}

struct OID4VCIProtocol
{
    static func getCredentialOffer(
        offerURI : String
    ) async throws -> (CredentialOfferResponse, AuthorizationGrantType)
    {
        guard
            let components = URLComponents(string: offerURI),
            let offerUriValue = components.queryItems?
                .first(where: { $0.name == "credential_offer_uri" })?
                .value
        else
        {
            //TODO: Invalid Credential Offer URI format.
            throw NSError(domain: "Invalid Credential Offer URI format.", code: 0)
        }
        
        let offer: CredentialOfferResponse = try await CommunicationClient.sendRequest(
            urlString: offerUriValue,
            httpMethod: .GET
        )
        
        guard let configIds = offer.credentialConfigurationIds, configIds.isEmpty == false
        else
        {
            //TODO: No issuable Credential ID in Offer.
            throw NSError(domain: "No issuable Credential ID in Offer.", code: 0)
        }
        
        let grantType = try checkGrantType(offer: offer)
        
        return (offer, grantType)
    }
    
    static func getTokenByPreAuthrizedCode(
        pinCode: String,
        offer: CredentialOfferResponse
    ) async throws -> TokenResponse
    {
        
        if case try checkGrantType(offer: offer) = .authorizationCode
        {
            //TODO: Unsupported grant type
            throw NSError(domain: "Unsupported grant type", code: 0)
        }
        
        let meta = try await getMeta(host: offer.credentialIssuer)
        
        @ValidURL var tokenEndPoint : String
        if let endPoint = meta.tokenEndpoint, endPoint.isEmpty == false
        {
            tokenEndPoint = endPoint
        }
        else
        {
            tokenEndPoint = offer.credentialIssuer
        }
        
        guard let configIds = offer.credentialConfigurationIds, configIds.isEmpty == false
        else
        {
            //TODO: No issuable Credential ID in Offer.
            throw NSError(domain: "", code: 0)
        }
        
        let authDetailsArray = configIds.map {
            return AuthorizationDetails(
                type: "openid_credential",
                credentialConfigurationId: $0,
                credentialIdentifiers: nil
            )
        }
        
        let tokenRequest = TokenRequest(
            grantType: "urn:ietf:params:oauth:grant-type:pre-authorized_code",
            preAuthorizedCode: offer.grants.preAuthorizedCode!.preAuthorizedCode,
            txCode: pinCode,
            authorizationDetails: authDetailsArray
        )
        
        let authHeaderValue = "Basic b2lkNHZjaS1jbGllbnQ6c2VjcmV0"
        var headers: [String: String] = [:]
        headers["Authorization"] = authHeaderValue
        headers.merge(XWWWFormHttpHeaderFields) { current, _ in current }
        
        let response : TokenResponse = try await CommunicationClient.sendPostUrlencoded(
            urlString: _tokenEndPoint.appendingPath("oauth2/token"),
            headerFields: headers,
            requestJsonable: tokenRequest
        )

        return response
    }
    
    static func processIssuing(
        offer : CredentialOfferResponse,
        tokenResponse : TokenResponse,
        selectedConfigId: String,
        selectedCredentialID: String
    ) async throws
    {
        @ValidURL var issuerURL = offer.credentialIssuer
        
        let token = "\(tokenResponse.tokenType) \(tokenResponse.accessToken)"
        
        //TODO: Create JWS
        //TODO: Proofs
        let credentialRequest = CredentialRequest(
            credentialConfigurationId: nil,
            credentialIdentifier: selectedCredentialID,
            proofs: .init()
        )
        
        let endPoint = _issuerURL.appendingPath("credential")
        
        var headers: [String: String] = [:]
        headers["Authorization"] = token
        headers.merge(DefaultHttpHeaderFields) { current, _ in current }
        
        let credentialResponse : CredentialResponse = try await CommunicationClient.sendRequest(
            urlString: endPoint,
            headerFields: headers,
            requestJsonable: credentialRequest
        )
        
        //TODO: Store Credential
    }
}


extension OID4VCIProtocol
{
    
    
    static func checkGrantType(offer : CredentialOfferResponse) throws -> AuthorizationGrantType
    {
        if let preAuth = offer.grants.preAuthorizedCode
        {
            if preAuth.preAuthorizedCode.isEmpty
            {
                //TODO: Pre-Authorized Code not in Offer.
                throw NSError(domain: "", code: 0)
            }
            return .preAuthorizedCode
        }
        else if let authCode = offer.grants.authorizationCode
        {
            return .authorizationCode
        }
        else
        {
            //TODO: Unsupported grant type
            throw NSError(domain: "", code: 0)
        }
    }

}

extension OID4VCIProtocol
{
    private static func getMeta(host: String) async throws -> IssuerMetadataResponse
    {
        let endpoint = host + "/.well-known/openid-credential-issuer"
        let meta : IssuerMetadataResponse = try await CommunicationClient.sendRequest(
            urlString: endpoint,
            httpMethod: .GET
        )
        
        return meta
    }
}
