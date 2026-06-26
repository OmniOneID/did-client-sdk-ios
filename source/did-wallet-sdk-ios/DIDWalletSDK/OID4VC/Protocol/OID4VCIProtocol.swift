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

    public static func getTokenByPreAuthrizedCode(
        pinCode: String,
        offer: CredentialOfferResponse
    ) async throws -> TokenResponse
    {

        if case try checkGrantType(offer: offer) = .authorizationCode
        {
            throw OID4VCIError.unsupportedGrantType
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
            txCode: pinCode,
            authorizationDetails: authDetailsArray
        )

        let authHeaderValue = "Basic b2lkNHZjaS1jbGllbnQ6c2VjcmV0"
        var headers: [String: String] = [:]
        headers["Authorization"] = authHeaderValue
        headers.merge(XWWWFormHttpHeaderFields) { current, _ in current }

        let response : TokenResponse = try await CommunicationClient.sendPostUrlencoded(
            urlString: tokenEndpoint,
            headerFields: headers,
            requestJsonable: tokenRequest
        )

        return response
    }

    /// Requests, verifies and stores a credential.
    ///
    /// The key-binding proof JWT is signed with the holder wallet key: the PIN key when `password`
    /// is supplied, the biometric key otherwise (mirroring the VP signing path in `WalletService`).
    /// On success the issued credential is persisted via `IssuedCredentialManager` and returned.
    /// - Parameters:
    ///   - offer: The credential offer (from `getCredentialOffer`).
    ///   - tokenResponse: The access token response (from `getTokenByPreAuthrizedCode`).
    ///   - selectedConfigId: The chosen `credential_configuration_id`.
    ///   - selectedCredentialID: The chosen `credential_identifier`, when the issuer uses identifiers.
    ///   - password: The wallet PIN. When `nil`, the biometric key is used.
    /// - Returns: The stored `IssuedCredential`.
    @discardableResult
    public static func processIssuing(
        offer : CredentialOfferResponse,
        tokenResponse : TokenResponse,
        selectedConfigId: String,
        selectedCredentialID: String?,
        password: String? = nil,
        APIGatewayURL : String
    ) async throws -> IssuedCredential
    {
        let meta = try await getMeta(host: offer.credentialIssuer)

        guard let credentialConfig = meta.credentialConfigurationsSupported[selectedConfigId]
        else
        {
            throw OID4VCIError.unavailableConfigId(selectedConfigId)
        }

        if case .unknown(let value) = credentialConfig.format
        {
            throw OID4VCIError.unsupportedFormat(value)
        }

        // Holder key-bound proof. PIN key when a password is supplied, biometric key otherwise.
        let keyManager = try KeyManager(fileName: "holder")
        let keyId = password != nil ? "pin" : "bio"
        let pin = password?.data(using: .utf8)

        guard try keyManager.isKeySaved(id: keyId),
              let keyInfo = try keyManager.getKeyInfos(ids: [keyId]).first
        else
        {
            throw OID4VCIError.holderKeyNotFound(keyId)
        }

        let compressedPublicKey = try MultibaseUtils.decode(encoded: keyInfo.publicKey)
        let jwk = try P256V.decompressPublicKey(compressedPublicKey: compressedPublicKey).getPublicKeyJwk()

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
        let digest = signSource.data(using: .utf8)!.sha256()

        // KeyManager returns a 65-byte compact signature (v‖r‖s); JOSE ES256 wants 64-byte r‖s.
        let compactSignature = try keyManager.sign(id: keyId, pin: pin, digest: digest)
        let signature = Data(compactSignature.dropFirst()).base64URLEncoded
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

        guard let rawCredential = credentialResponse.credentials.first?.credential
        else
        {
            throw OID4VCIError.emptyCredentialResponse
        }

        // Verify
        @ValidURL var issuerURL = offer.credentialIssuer

//        let issuerJWK = try await getIssuerJWK(url: issuerURL)
//
//        let pubKey = try P256.Signing.PublicKey.init(
//            xBase64URL: issuerJWK.x,
//            yBase64URL: issuerJWK.y
//        )
        
        let sdJWT = SDJWT.parse(raw: rawCredential)
        let tempJWS = JWS.init(from: sdJWT.credentialJwt)
        let jwsHeader : JWSHeader = try .init(from: tempJWS.header)
        
        guard let kid = jwsHeader.kid
        else
        {
            //TODO: error
            throw OID4VCIError.emptyCredentialResponse
        }
        let identifier = try DIDUtility.parseDIDKeyIdentifier(kid)
        
        let issuerDIDDoc = try await CommunicationClient.getDIDDocument(hostUrlString: APIGatewayURL,
                                                                        did: identifier.did,
                                                                        versionId: identifier.versionId)

        guard let publicKeyMultibase = issuerDIDDoc.verificationMethod.filter({ $0.id == identifier.kid }).first.map(\.publicKeyMultibase)
        else
        {
            //TODO: no public key
            throw OID4VCIError.emptyCredentialResponse
        }
        
        
        let publicKey : P256.Signing.PublicKey = try .init(compressedRepresentation: MultibaseUtils.decode(encoded: publicKeyMultibase))
        
        switch credentialConfig.format
        {
        case .sdjwt:
            try veryfySDJWT(credential: rawCredential, pubKey: publicKey)
        case .mdoc:
            () //TODO: Phase 2 — mdoc (mso_mdoc) signature verification
        case .unknown(_):
            ()
        }

        // Store
        let format : String
        switch credentialConfig.format
        {
        case .sdjwt:
            format = "dc+sd-jwt-did"
        case .mdoc:
            format = "mso_mdoc"
        case .unknown(let value):
            format = value
        }

        let issuedCredential = IssuedCredential(
            id: UUID().uuidString,
            format: format,
            credentialConfigurationId: selectedConfigId,
            credentialIdentifier: selectedCredentialID,
            credential: rawCredential
        )

        try IssuedCredentialManager().saveCredential(issuedCredential)

        return issuedCredential
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
            throw OID4VCIError.failedToVerifySignature
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
