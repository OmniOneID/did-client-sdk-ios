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
import CryptoKit

public struct OID4VCIProtocol
{
    public static func getCredentialOffer(
        rawPayload : String
    ) async throws -> CredentialOfferResponse
    {
        guard
            let components = URLComponents(string: rawPayload),
            let offerUriValue = components.queryItems?
                .first(where: { $0.name == "credential_offer_uri" })?
                .value
        else
        {
            throw OID4VCIError.invalidCredentialOfferURI
        }
        
        let offer: CredentialOfferResponse = try await CommunicationClient.sendRequest(
            urlString: offerUriValue,
            httpMethod: .GET
        )
        
        guard let configIds = offer.credentialConfigurationIds, configIds.isEmpty == false
        else
        {
            throw OID4VCIError.noIssuableCredential
        }
        
        return offer
    }
    
    
    public static func getTokenByPreAuthorizedCode(
        metaData: IssuerMetadataResponse,
        offer: CredentialOfferResponse,
        txCode: String
    ) async throws -> TokenResponse
    {
        
        if case try checkGrantType(offer: offer) = .authorizationCode
        {
            throw OID4VCIError.unsupportedGrantType
        }
        
        //        let meta = try await getMetadata(issuerURL: offer.credentialIssuer)
        
        @ValidURL var endPoint : String
        
        if let authServers = metaData.authorizationServers, authServers.isEmpty == false
        {
            endPoint = authServers.first!
        }
        else if let tokenEndpoint = metaData.tokenEndpoint, tokenEndpoint.isEmpty == false
        {
            endPoint = tokenEndpoint
        }
        else
        {
            endPoint = offer.credentialIssuer
        }
        
        let tokenEndpoint = try await getCredentialRequestURL(url: endPoint)
        
        guard let configIds = offer.credentialConfigurationIds, configIds.isEmpty == false
        else
        {
            throw OID4VCIError.noIssuableCredential
        }
        
        let authDetailsArray = configIds.map {
            return AuthorizationDetails(
                credentialConfigurationId: $0,
                credentialIdentifiers: nil
            )
        }
        
        let tokenRequest = TokenRequest(
            preAuthorizedCode: offer.grants.preAuthorizedCode!.preAuthorizedCode,
            txCode: txCode,
            authorizationDetails: authDetailsArray
        )
        
        //        let authHeaderValue = "Basic b2lkNHZjaS1jbGllbnQ6c2VjcmV0"
        //        var headers: [String: String] = [:]
        //        headers["Authorization"] = authHeaderValue
        //        headers.merge(XWWWFormHttpHeaderFields) { current, _ in current }
        
        let response : TokenResponse = try await CommunicationClient.sendPostUrlencoded(
            urlString: tokenEndpoint,
            //            headerFields: headers,
            requestJsonable: tokenRequest
        )
        
        return response
    }
    
    public static func requestCredential(hWalletToken: String,
                                  metadata: IssuerMetadataResponse,
                                  token: TokenResponse,
                                  passcode: String?,
                                  configurationId: String,
                                  credentialIdentifier: String?,
                                  APIGatewayURL: String) async throws -> String
    {
        return try await WalletAPI.shared.requestIssueOID4VC(
            hWalletToken: hWalletToken,
            metadata: metadata,
            token: token,
            passcode: passcode,
            configurationId:configurationId,
            credentialIdentifier: credentialIdentifier,
            APIGatewayURL: APIGatewayURL
        )
        
    }
}

extension OID4VCIProtocol
{
    private enum AuthorizationGrantType
    {
        case preAuthorizedCode
        case authorizationCode
    }

    private static func checkGrantType(
        offer : CredentialOfferResponse
    ) throws -> AuthorizationGrantType
    {
        if let preAuth = offer.grants.preAuthorizedCode
        {
            if preAuth.preAuthorizedCode.isEmpty
            {
                throw OID4VCIError.preAuthorizedCodeNotFound
            }
            return .preAuthorizedCode
        }
        else if let _ = offer.grants.authorizationCode
        {
            return .authorizationCode
        }
        else
        {
            throw OID4VCIError.unsupportedGrantType
        }
    }
}

//extension OID4VCIProtocol
//{
//    private static func veryfySDJWT(credential : String, pubKey : P256.Signing.PublicKey) throws
//    {
//        let sdJWT = SDJWT.parse(raw: credential)
//        let (source, signature) = sdJWT.getSignSource()
//
//        let sign = try P256.Signing.ECDSASignature(rawRepresentation: signature.base64URLDecoded!)
//
//        let isValid = pubKey.isValidSignature(sign, for: source.data(using: .utf8)!)
//
//        guard isValid else
//        {
//            throw OID4VCIError.failedToVerifySignature
//        }
//    }
//}


extension OID4VCIProtocol
{
    public static func getMetadata(issuerURL: String) async throws -> IssuerMetadataResponse
    {
        let endpoint = issuerURL + "/.well-known/openid-credential-issuer"
        let meta : IssuerMetadataResponse = try await CommunicationClient.sendRequest(
            urlString: endpoint,
            httpMethod: .GET
        )
        
        return meta
    }
    
}
    
extension OID4VCIProtocol
{
    private static func getCredentialRequestURL(url: String) async throws -> String
    {
        @ValidURL var issuerURL = url
        let subURL = ".well-known/oauth-authorization-server"

        let (result, status)  = try await CommunicationClient.sendRequest(
            urlString: _issuerURL.appendingPath(subURL),
            httpMethod: .GET
        )

        if status != 200
        {
            throw OID4VCIError.failedToFetchIssuerMetadata
        }


        let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
        guard let endPoint = json?["token_endpoint"], let tokenEndpoint = endPoint as? String
        else{
            throw OID4VCIError.tokenEndpointNotFound
        }

        return tokenEndpoint
    }

//    private static func getIssuerJWK(url: String) async throws -> JWK
//    {
//
//        @ValidURL var issuerURL = url
//        let subURL = ".well-known/jwt-vc-issuer"
//
//        let meta : IssuerJWTMetadata = try await CommunicationClient.sendRequest(
//            urlString: _issuerURL.appendingPath(subURL),
//            httpMethod: .GET
//        )
//
//        let filtered = meta.jwks.keys.filter { $0.alg == .es256 && $0.crv == .p256 && $0.kty == .ec }
//
//        if filtered.isEmpty
//        {
//            throw OID4VCIError.noAvailableJWK
//        }
//        return filtered.first!
//    }
}

/// Errors thrown by the OID4VCI (OpenID for Verifiable Credential Issuance) flow.
public enum OID4VCIError: Error, LocalizedError
{
    /// The credential offer URI is missing or malformed.
    case invalidCredentialOfferURI
    /// The offer contains no issuable credential configuration id.
    case noIssuableCredential
    /// The offer advertises the pre-authorized grant but carries no code.
    case preAuthorizedCodeNotFound
    /// The offer's grant type is not supported by this flow.
    case unsupportedGrantType
    /// The selected `credential_configuration_id` is not in the issuer metadata.
    case unavailableConfigId(String)
    /// The credential format is not supported. Carries the format token.
    case unsupportedFormat(String)
    /// Fetching the issuer (authorization-server) metadata failed.
    case failedToFetchIssuerMetadata
    /// The authorization-server metadata has no `token_endpoint`.
    case tokenEndpointNotFound
    /// The issuer exposes no usable ES256/P-256 JWK.
    case noAvailableJWK
    /// The holder signing key required for the proof was not found. Carries the key id.
    case holderKeyNotFound(String)
    /// The credential response carried no credential.
    case emptyCredentialResponse
    /// The issued credential's signature could not be verified.
    case failedToVerifySignature

    public var errorDescription: String?
    {
        switch self
        {
        case .invalidCredentialOfferURI:
            return "Invalid credential offer URI format."
        case .noIssuableCredential:
            return "No issuable credential id in offer."
        case .preAuthorizedCodeNotFound:
            return "Pre-authorized code not in offer."
        case .unsupportedGrantType:
            return "Unsupported grant type."
        case .unavailableConfigId(let id):
            return "Unavailable credential configuration id: \(id)."
        case .unsupportedFormat(let format):
            return "This format \(format) is not supported."
        case .failedToFetchIssuerMetadata:
            return "Failed to fetch issuer metadata."
        case .tokenEndpointNotFound:
            return "Token endpoint not found."
        case .noAvailableJWK:
            return "No available jwk."
        case .holderKeyNotFound(let keyId):
            return "Holder signing key '\(keyId)' not found."
        case .emptyCredentialResponse:
            return "The credential response contained no credential."
        case .failedToVerifySignature:
            return "Failed to verify signature."
        }
    }
}
