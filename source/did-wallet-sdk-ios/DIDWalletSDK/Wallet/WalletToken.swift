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

class WalletToken: WalletTokenImpl {
    
    private let walletCore: WalletCoreImpl
    
    public init(_ walletCore: WalletCoreImpl) {
        self.walletCore = walletCore
    }
    
    public func verifyWalletToken(hWalletToken: String, purposes: [WalletTokenPurposeEnum]) throws {
        
        guard !hWalletToken.isEmpty else {
            throw WalletAPIError.verifyParameterFail("hWalletToken").getError()
        }
        
        // purposes verify
        guard !purposes.isEmpty else {
            throw WalletAPIError.verifyParameterFail("purposes").getError()
        }
        
        var isPurpose = false
        
        guard let token = try CoreDataManager.shared.selectToken() else {
            WalletLogger.debug("db verify fail")
            throw WalletAPIError.selectQueryFail.getError()
        }
        
        if hWalletToken != token.hWalletToken {
            WalletLogger.debug("hWalletToken fail")
            WalletLogger.debug("input hWalletToken: \(hWalletToken)")
            WalletLogger.debug("saved hWalletToken: \(token.hWalletToken)")
            throw WalletAPIError.verifyTokenFail.getError()
        }
        
        try Date.checkValidation(dateString: token.validUntil)
        
        for purpose in purposes {
            if purpose.value == token.purpose {
                WalletLogger.debug("verify success")
                isPurpose = true
            } else {
                //                WalletLogger.debug("input purpose: \(purpose.value)")
                //                WalletLogger.debug("saved purpose: \(token.purpose)")
            }
        }
        
        if !isPurpose {
            WalletLogger.debug("verify fail")
            throw WalletAPIError.verifyTokenFail.getError()
        }
    }
    
    /// Description
    /// - Parameters:
    ///   - purpose: purpose description
    ///   - pkgName: pkgName description
    ///   - userId: userId description
    /// - Returns: description
    func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String, userId: String? = nil) throws -> WalletTokenSeed {
        
        guard !pkgName.isEmpty else {
            throw WalletAPIError.verifyParameterFail("pkgName").getError()
        }
        
        guard WalletTokenPurposeEnum(rawValue: purpose.rawValue) != nil else {
            throw WalletAPIError.verifyParameterFail("purpose").getError()
        }
        
        let nonce = try CryptoUtils.generateNonce(size: 16)
        
        let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: nonce)
        let seed = WalletTokenSeed(purpose: purpose, pkgName: pkgName, nonce: hexNonce, validUntil: Date.getUTC0Date(seconds: 0), userId: userId)
        
        return seed
    }
    
    /// Description
    /// - Parameter walletTokenData: walletTokenData description
    /// - Returns: description
    func createNonceForWalletToken(walletTokenData: WalletTokenData?, APIGatewayURL: String) async throws  -> String {
        
        guard let walletTokenData = walletTokenData else {
            throw WalletAPIError.verifyParameterFail("walletTokenData").getError()
        }
        
        guard !APIGatewayURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("APIGatewayURL").getError()
        }
        
        var tempWalletTokenData = walletTokenData
        
        let roleType = RoleTypeEnum.CAS_SERVICE
        
        let resultNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: try CryptoUtils.generateNonce(size: 16))
        
        let digest = DigestUtils.getDigest(source: (try! walletTokenData.toJson()+resultNonce).data(using: String.Encoding.utf8)!, digestEnum: DigestEnum.sha256)
        // Hex
        let hWalletToken = String(MultibaseUtils.encode(type: MultibaseType.base16, data: digest).dropFirst())
        
        // checkCertVcRef
        try await self.verifyCertVcRef(roleType: roleType, providerDID: walletTokenData.provider.did, providerURL: walletTokenData.provider.certVcRef, APIGatewayURL: APIGatewayURL)
        
        // get CAS DIDDoc
        let casDidDoc = try await CommunicationClient.getDIDDocument(hostUrlString: APIGatewayURL,
                                                                     did: walletTokenData.provider.did)
        
        WalletLogger.debug("casDidDoc: \(try casDidDoc.toJson(isPretty: true))")
        
        for method in casDidDoc.verificationMethod {
            if method.id == "assert" {
                let pubKey = try MultibaseUtils.decode(encoded: method.publicKeyMultibase)
                let signature = try MultibaseUtils.decode(encoded: (tempWalletTokenData.proof?.proofValue!)!)
                tempWalletTokenData.proof?.proofValue = nil
                //                walletTokenData.proof.proofValueList = nil
                let digest = DigestUtils.getDigest(source: try tempWalletTokenData.toJsonData(), digestEnum: .sha256)
                let result = try self.walletCore.verify(publicKey: pubKey, data: digest, signature: signature)
                WalletLogger.debug("result: \(result)")
                guard result else {
                    throw WalletAPIError.verifyCertVCFail.getError()
                }
            }
        }
        
        WalletLogger.debug("sdk hWalletToken \(hWalletToken)")
        WalletLogger.debug("walletId: \(Properties.getWalletId() ?? "not found wallet id")")
        
        // verify certVcRef
        let purpose = WalletTokenPurpose(purpose: walletTokenData.seed.purpose)
        
        if let walletId = Properties.getWalletId(),
           try CoreDataManager.shared.insertToken(walletId: walletId,
                                                  hWalletToken: hWalletToken,
                                                  purpose: purpose.purposeCode.value,
                                                  pkgName: walletTokenData.seed.pkgName,
                                                  nonce: walletTokenData.seed.nonce,
                                                  pii: walletTokenData.sha256_pii) {
            return resultNonce
        }
        WalletLogger.debug("bindUser selectToken fail")
        throw WalletAPIError.insertQueryFail.getError()
    }
    
    /// Purposes a local wallet token may be issued for.
    ///
    /// A local token skips the CAS signature check, so it must open only a proper subset of
    /// what a CAS-verified token opens: reading credentials and building presentations. The
    /// purposes left out either unlock a local mutation (DID creation, key or credential
    /// deletion, personalization, lock setup) or belong to flows that need the CAS anyway.
    static let localTokenPurposes: [WalletTokenPurposeEnum] = [.LIST_VC, .DETAIL_VC, .PRESENT_VP, .LIST_VC_AND_PRESENT_VP]
    
    /// Issues a wallet token without contacting the CAS.
    ///
    /// The only state it requires is that this wallet has been personalized online at least
    /// once (`UserEntity` row). The token is random rather than derived, since the app holds no
    /// `walletTokenData` to derive it from, so the token itself is returned instead of a nonce.
    /// Inserting it replaces whatever token is stored, exactly as the online path does.
    /// - Parameters:
    ///   - purpose: one of `localTokenPurposes`
    ///   - pkgName: package name of the calling app
    /// - Returns: the hWalletToken (64 hex characters)
    func createLocalWalletToken(purpose: WalletTokenPurposeEnum, pkgName: String) throws -> String {
        
        guard !pkgName.isEmpty else {
            throw WalletAPIError.verifyParameterFail("pkgName").getError()
        }
        
        guard WalletToken.localTokenPurposes.contains(purpose) else {
            throw WalletAPIError.verifyParameterFail("purpose").getError()
        }
        
        guard let user = try CoreDataManager.shared.selectUser() else {
            throw WalletAPIError.notPersonalized.getError()
        }
        
        let random = try CryptoUtils.generateNonce(size: 32)
        // Hex, prefix dropped to match the online token
        let hWalletToken = String(MultibaseUtils.encode(type: MultibaseType.base16, data: random).dropFirst())
        
        WalletLogger.debug("local hWalletToken \(hWalletToken)")
        
        if let walletId = Properties.getWalletId(),
           try CoreDataManager.shared.insertToken(walletId: walletId,
                                                  hWalletToken: hWalletToken,
                                                  purpose: purpose.value,
                                                  pkgName: pkgName,
                                                  nonce: "",
                                                  pii: user.pii) {
            return hWalletToken
        }
        WalletLogger.debug("createLocalWalletToken insertToken fail")
        throw WalletAPIError.insertQueryFail.getError()
    }
    
    public func verifyCertVcRef(roleType: RoleTypeEnum, providerDID: String, providerURL: String, APIGatewayURL: String) async throws {
        
        guard !providerDID.isEmpty else {
            throw WalletAPIError.verifyParameterFail("providerDID").getError()
        }
        
        guard RoleTypeEnum(rawValue: roleType.rawValue) != nil else {
            throw WalletAPIError.verifyParameterFail("roleType").getError()
        }
        
        guard !providerURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("providerURL").getError()
        }
        
        guard !APIGatewayURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("APIGatewayURL").getError()
        }
        
        // _createNonceForWalletToken
        // get certVC
        WalletLogger.debug("verifyCertVc(WalletUtil)")
        
        var certVc : VerifiableCredential = try await CommunicationClient.sendRequest(urlString: providerURL,
                                                                                      httpMethod: .GET)
        
        // compare did
        if providerDID != certVc.credentialSubject.id {
            //            throw WalletAPIError.init(errorCode: WalletErrorCodeEnum.didMatchFail)
            throw WalletAPIError.didMatchFail.getError()
        }
        
        // get CAS DIDDoc
        let didDoc = try await CommunicationClient.getDIDDocument(hostUrlString: APIGatewayURL,
                                                                  did: certVc.issuer.id)
        
        WalletLogger.debug("didDoc: \(try didDoc.toJson(isPretty: true))")
        
        // compare rule
        let schemaUrl = certVc.credentialSchema.id
        
        let vcSchema : VCSchema = try await CommunicationClient.sendRequest(urlString: schemaUrl,
                                                                            httpMethod: .GET)
        let vcSchemaClaims = vcSchema.credentialSubject.claims
        
        let certVcClaims = certVc.credentialSubject.claims
        
        var isExistValue = false
        
        for schemaClaim in vcSchemaClaims {
            for item in schemaClaim.items {
                if "role" == item.caption {
                    for certVcClaim in certVcClaims {
                        if certVcClaim.caption == item.caption {
                            WalletLogger.debug("rawValue: \(roleType.rawValue)")
                            if roleType.rawValue == certVcClaim.value {
                                isExistValue = true
                            }
                        }
                    }
                }
            }
        }
        
        if !isExistValue {
            throw WalletAPIError.roleMatchFail.getError()
        }
        
        // verify vc certification
        for method in didDoc.verificationMethod {
            if method.id == "assert" {
                let pubKey = try MultibaseUtils.decode(encoded: method.publicKeyMultibase)
                let signature = try MultibaseUtils.decode(encoded: certVc.proof.proofValue!)
                certVc.proof.proofValue = nil
                certVc.proof.proofValueList = nil
                let digest = DigestUtils.getDigest(source: try certVc.toJsonData(), digestEnum: .sha256)
                let result = try self.walletCore.verify(publicKey: pubKey, data: digest, signature: signature)
                WalletLogger.debug("verifyCertVcRef result: \(result)")
                guard result else {
                    throw WalletAPIError.verifyCertVCFail.getError()
                }
            }
        }
    }
}
