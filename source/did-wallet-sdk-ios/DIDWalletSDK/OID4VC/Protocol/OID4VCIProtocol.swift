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
        offerURI : String
    ) async throws -> CredentialOfferResponse
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
        
        return offer
    }
    
    public enum AuthorizationGrantType
    {
        case preAuthorizedCode
        case authorizationCode
    }
    
    public static func checkGrantType(
        offer : CredentialOfferResponse
    ) throws -> AuthorizationGrantType
    {
        if let preAuth = offer.grants.preAuthorizedCode
        {
            if preAuth.preAuthorizedCode.isEmpty
            {
                //TODO: Pre-Authorized Code not in Offer.
                throw NSError(domain: "Pre-Authorized Code not in Offer.", code: 0)
            }
            return .preAuthorizedCode
        }
        else if let _ = offer.grants.authorizationCode
        {
            return .authorizationCode
        }
        else
        {
            //TODO: Unsupported grant type
            throw NSError(domain: "Unsupported grant type", code: 0)
        }
    }
    
    public static func getTokenByPreAuthrizedCode(
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
        
        @ValidURL var endPoint : String
        
        if let authServers = meta.authorizationServers, authServers.isEmpty == false
        {
            endPoint = authServers.first!
        }
        else if let tokenEndpoint = meta.tokenEndpoint, tokenEndpoint.isEmpty == false
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
            //TODO: No issuable Credential ID in Offer.
            throw NSError(domain: "No issuable Credential ID in Offer.", code: 0)
        }
        
        let authDetailsArray = configIds.map {
            return AuthorizationDetails(
                credentialConfigurationId: $0,
                credentialIdentifiers: nil
            )
        }
        
        let tokenRequest = TokenRequest(
//            grantType: "urn:ietf:params:oauth:grant-type:pre-authorized_code",
            preAuthorizedCode: offer.grants.preAuthorizedCode!.preAuthorizedCode,
            txCode: pinCode,
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
    
    public static func processIssuing(
        offer : CredentialOfferResponse,
        tokenResponse : TokenResponse,
        selectedConfigId: String,
        selectedCredentialID: String?
    ) async throws
    {
        let meta = try await getMeta(host: offer.credentialIssuer)
        
        guard let credentialConfig = meta.credentialConfigurationsSupported[selectedConfigId]
        else
        {
            //TODO: Unavailable ConfigId
            throw NSError(domain: "Unavailable ConfigId", code: 0)
        }
        
        if case .unknown(let value) = credentialConfig.format
        {
            //TODO: Unsupported format
            throw NSError(domain: "This format \(value) is not supported", code: 0)
        }
        
        
        //TODO: Signing key
        let pkcs8PrivateKey = "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgmMOV8LmitIOKQCynSbCxsW0xmVMuQjdPtiJdjhwfx0agCgYIKoZIzj0DAQehRANCAAQv+cDbPA9aF/hQ0WIJyVJmfzr533/v+9xvCw+d/ptbZHTOhfDrj38GrJGQqxu4d1NswrAj+JlqA7Fhen34bWoT"
        
        let privateKey = try P256.Signing.PrivateKey(derRepresentation: Data(base64Encoded: pkcs8PrivateKey)!)
        let jwk = privateKey.publicKey.getPublicKeyJwk()
        
        var nonce : String?
        if let nonceEndpoint = meta.nonceEndpoint
        {
            let cNonce : CNonce = try await CommunicationClient.sendRequest(urlString: nonceEndpoint)
            nonce = cNonce.cNonce
        }
        
        let typ = "openid4vci-proof+jwt"
        
        let header = try JWSHeader.init(
            typ: typ,
            jwk: jwk
        ).toJsonData().base64URLEncoded
        
        let payload = try JWSAudiencePayload.init(
            aud: meta.credentialIssuer,
            nonce: nonce
        ).toJsonData().base64URLEncoded
        
        let signSource = "\(header).\(payload)"
        let signSourceData = signSource.data(using: .utf8)!
        
        let signature = try privateKey.signature(for: signSourceData).rawRepresentation.base64URLEncoded
        let jws = "\(signSource).\(signature)"

        var credentialRequest : CredentialRequest
        
        if let selectedCredentialID = selectedCredentialID
        {
            credentialRequest = CredentialRequest(
                credentialConfigurationId: nil,
                credentialIdentifier: selectedCredentialID,
                proofs: .init(jwt: [jws])
            )
        }
        else
        {
            credentialRequest = CredentialRequest(
                credentialConfigurationId: selectedConfigId,
                credentialIdentifier: nil,
                proofs: .init(jwt: [jws])
            )
        }
        
        
        let token = "\(tokenResponse.tokenType) \(tokenResponse.accessToken)"
        
        var headers: [String: String] = [:]
        headers["Authorization"] = token
        headers.merge(DefaultHttpHeaderFields) { current, _ in current }
        
        let credentialResponse : CredentialResponse = try await CommunicationClient.sendRequest(
            urlString: meta.credentialEndpoint,
            headerFields: headers,
            requestJsonable: credentialRequest
        )
        
        //TODO: Verify
        
        
        @ValidURL var issuerURL = offer.credentialIssuer
        
        let issuerJWK = try await getIssuerJWK(url: issuerURL)
        
        let pubKey = try P256.Signing.PublicKey.init(
            xBase64URL: issuerJWK.x,
            yBase64URL: issuerJWK.y
        )
        
        switch credentialConfig.format
        {
        case .sdjwt:
            try veryfySDJWT(credential: credentialResponse.credentials.first!.credential, pubKey: pubKey)
        case .mdoc:
            ()
        case .unknown(_):
            ()
        }
        
        print("done")
        //TODO: Store Credential
        
        
    }
}

extension OID4VCIProtocol
{
    private static func veryfySDJWT(credential : String, pubKey : P256.Signing.PublicKey) throws
    {
        let sdJWT = SDJWT.parse(raw: credential)
        let (source, signature) = sdJWT.getSignSource()
        
        let sign = try P256.Signing.ECDSASignature(rawRepresentation: signature.base64URLDecoded!)
        
        let isValid = pubKey.isValidSignature(sign, for: source.data(using: .utf8)!)
        
        guard isValid else
        {
            //TODO: Failed to verify signature
            throw NSError(domain: "Failed to verify signature", code: 0)
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
            //TODO: Failed to fetch Issuer Metadata
            throw NSError(domain: "Failed to fetch Issuer Metadata", code: 0)
        }
        
        
        let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
        guard let endPoint = json?["token_endpoint"], let tokenEndpoint = endPoint as? String
        else{
            //TODO: Not found token endpoint
            throw NSError(domain: "Not found token endpoint", code: 0)
        }
        
        return tokenEndpoint
    }
    
    private static func getIssuerJWK(url: String) async throws -> JWK
    {
   
        @ValidURL var issuerURL = url
        let subURL = ".well-known/jwt-vc-issuer"
        
        let meta : IssuerJWTMetadata = try await CommunicationClient.sendRequest(
            urlString: _issuerURL.appendingPath(subURL),
            httpMethod: .GET
        )
        
        let filtered = meta.jwks.keys.filter { $0.alg == .es256 && $0.crv == .p256 && $0.kty == .ec }
        
        if filtered.isEmpty
        {
            //TODO: No available jwk
            throw NSError(domain: "No available jwk", code: 0)
        }
        return filtered.first!
    }
}
