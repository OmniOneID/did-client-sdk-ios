/*
 * Copyright 2024 OmniOne.
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

@testable import DIDWalletSDK

class WalletServiceMock : WalletServiceImpl
{
    //TODO: future
    func requestZKProof(hWalletToken: String, selectedReferents: [DIDWalletSDK.UserReferent], proofParam: DIDWalletSDK.ZKProofParam, proofRequestProfile: DIDWalletSDK._RequestProofRequestProfile?, APIGatewayURL: String) async throws -> (DIDWalletSDK.AccE2e, Data) {
        return (DIDWalletSDK.AccE2e.init(publicKey: "", iv: ""), Data())
    }
    
    private let walletCore: WalletCoreImpl
    
    public init(_ walletCore: WalletCoreImpl) {
        self.walletCore = walletCore
    }
    // TODO
    func requestUpdateUser(tasURL: String, txId: String, serverToken: String, didAuth: DIDAuth?, signedDIDDoc: SignedDIDDoc?) async throws -> _RequestUpdateDidDoc {
        return _RequestUpdateDidDoc(txId: "txid")
    }
    // TODO
    func deleteWallet(deleteAll: Bool) throws
    {
        ()
    }
    
    func createWallet(tasURL: String, walletURL: String) async throws -> Bool {
        print("createWallet mock")
        
        _ = try self.createDeviceDocument()
        try self.walletCore.saveDidDocument(type: DidDocumentType.DeviceDidDocument)
        
        return true
    }
    
    func requestVp(hWalletToken: String, claimInfos: [ClaimInfo]?, verifierProfile: _RequestProfile?, APIGatewayURL: String, passcode: String?) async throws -> (AccE2e, Data) {
        
        let holderDidDoc = try WalletAPI.shared.getDidDocument(type: DidDocumentType.HolderDidDocumnet)

        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                          proofPurpose: ProofPurpose.keyAgreement,
                          verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#keyagree",
                          type: ProofType.secp256r1Signature2018)
        
        let keyPair = try CryptoUtils.generateECKeyPair(ecType: ECType.secp256r1)
        let iv = try CryptoUtils.generateNonce(size: 16)
        
        var accE2e = AccE2e(publicKey: MultibaseUtils.encode(type: MultibaseType.base58BTC, data: keyPair.publicKey),
                            iv: MultibaseUtils.encode(type: MultibaseType.base58BTC, data: iv),
                            proof: proof)
        
        let source = try DigestUtils.getDigest(source: accE2e.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature = try WalletAPI.shared.sign(keyId: "keyagree", data: source, type: DidDocumentType.HolderDidDocumnet)
        accE2e.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
                
        let presentationInfo = PresentationInfo(holder: holderDidDoc.id,
                                                validFrom: Date.getUTC0Date(seconds: 0),
                                                validUntil: Date.getUTC0Date(seconds: 5000),
                                                verifierNonce: verifierProfile!.profile.profile.process.verifierNonce)

        var vp = try walletCore.makePresentation(claimInfos:claimInfos!,
                                                 presentationInfo: presentationInfo)
        
        let authType = passcode != nil ? "#pin" : "#bio"
        print("vp: \(try vp.toJson())")
        let vpProof = Proof(created: Date.getUTC0Date(seconds: 0),
                            proofPurpose: ProofPurpose.assertionMethod,
                            verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + authType,
                            type: ProofType.secp256r1Signature2018)
        vp.proof = vpProof
        let vpSource = try DigestUtils.getDigest(source: vp.toJsonData(), digestEnum: DigestEnum.sha256)
        
        let vpSignature: Data?
        if passcode != nil {
            vpSignature = try walletCore.sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: vpSource, type: DidDocumentType.HolderDidDocumnet)
        } else {
            vpSignature = try walletCore.sign(keyId: "bio", pin: nil, data: vpSource, type: DidDocumentType.HolderDidDocumnet)
        }
                    
        vp.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: vpSignature!)
        
        let serverNonce = try MultibaseUtils.decode(encoded: verifierProfile!.profile.profile.process.verifierNonce)
        
        let sessKey = try CryptoUtils.generateSharedSecret(ecType: ECType.secp256r1,
                                                           privateKey: keyPair.privateKey,
                                                           publicKey: MultibaseUtils.decode(encoded: verifierProfile!.profile.profile.process.reqE2e.publicKey))
        
        let clientMergedSharedSecret = WalletUtil.mergeSharedSecretAndNonce(sharedSecret: sessKey, nonce: serverNonce, symmetricCipherType: SymmetricCipherType.aes256CBC)
        
        
        let encVp = try CryptoUtils.encrypt(plain: vp.toJsonData(), info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: clientMergedSharedSecret, iv: iv)
        
//        print("accE2e: \(try accE2e.toJson())")
//        print("encVp: \(encVp)")

        return (accE2e, encVp)
    }
    // TODO
    func fetchCaInfo() async throws {
        
    }
    
    func createSignedDIDDoc(passcode: String?) throws -> SignedDIDDoc {
        
//        let deviceDidDoc = try DIDDocument(from: "{\"@context\":[\"https://www.w3.org/ns/did/v1\"],\"assertionMethod\":[\"assert\"],\"authentication\":[\"auth\"],\"controller\":\"did:omn:tas\",\"created\":\"2024-08-26T08:03:54Z\",\"deactivated\":false,\"id\":\"did:omn:2dmrJGpFpiRACcjg9MQYw2pn4VZZ\",\"keyAgreement\":[\"keyagree\"],\"updated\":\"2024-08-26T08:03:54Z\",\"verificationMethod\":[{\"authType\":1,\"controller\":\"did:omn:2dmrJGpFpiRACcjg9MQYw2pn4VZZ\",\"id\":\"assert\",\"publicKeyMultibase\":\"zgb1nZK5suXBQcLZkp16kBRoxEVDZLbyKKyFnEgcrrjYz\",\"type\":\"Secp256r1VerificationKey2018\"},{\"authType\":1,\"controller\":\"did:omn:2dmrJGpFpiRACcjg9MQYw2pn4VZZ\",\"id\":\"keyagree\",\"publicKeyMultibase\":\"zwsgd3wB68xRbyMMg9feHp4ygtaMfy5BB5s5qCiesCVoy\",\"type\":\"Secp256r1VerificationKey2018\"},{\"authType\":1,\"controller\":\"did:omn:2dmrJGpFpiRACcjg9MQYw2pn4VZZ\",\"id\":\"auth\",\"publicKeyMultibase\":\"z2Am6tznjCHXFeni3XoYgDStY9L7d92GctvE2W3Y1pHHgJ\",\"type\":\"Secp256r1VerificationKey2018\"}],\"versionId\":\"1\"}")
           
        var deviceDidDoc = try walletCore.getDidDocument(type: DidDocumentType.DeviceDidDocument)
        WalletLogger.shared.debug("saved deviceDidDoc: \(try deviceDidDoc.toJson(isPretty: true))")
        
//        var holderDidDoc = try DIDDocument(from: "{\"@context\":[\"https://www.w3.org/ns/did/v1\"],\"assertionMethod\":[\"pin\",\"bio\"],\"authentication\":[\"pin\",\"bio\"],\"controller\":\"did:omn:tas\",\"created\":\"2024-08-26T08:37:04Z\",\"deactivated\":false,\"id\":\"did:omn:2VhHke4Hqzev8jNXaxMRgGWcUXZi\",\"keyAgreement\":[\"keyagree\"],\"updated\":\"2024-08-26T08:37:04Z\",\"verificationMethod\":[{\"authType\":1,\"controller\":\"did:omn:2VhHke4Hqzev8jNXaxMRgGWcUXZi\",\"id\":\"keyagree\",\"publicKeyMultibase\":\"z28MaU2yv21wAFi97rj8LC9wuJJaZJZ5bsxWtDvEjDUn9a\",\"type\":\"Secp256r1VerificationKey2018\"},{\"authType\":2,\"controller\":\"did:omn:2VhHke4Hqzev8jNXaxMRgGWcUXZi\",\"id\":\"pin\",\"publicKeyMultibase\":\"z25yWffgpPpHd9GiZUxaVRhjGj82fnaGWL55xdNdnTduFJ\",\"type\":\"Secp256r1VerificationKey2018\"},{\"authType\":4,\"controller\":\"did:omn:2VhHke4Hqzev8jNXaxMRgGWcUXZi\",\"id\":\"bio\",\"publicKeyMultibase\":\"zv52y8JMgwQYY2vucXbZQqG5eVMGNhndDV6g2jfdjgoNq\",\"type\":\"Secp256r1VerificationKey2018\"}],\"versionId\":\"1\"}")
        
        var holderDidDoc = try walletCore.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        WalletLogger.shared.debug("saved holderDidDoc: \(try holderDidDoc.toJson(isPretty: true))")
        
        let wallet = Wallet(id: "walletId", did: deviceDidDoc.id)
        let nonce =  try CryptoUtils.generateNonce(size: 16)
        let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: nonce)
        
        var proofArry: [Proof] = .init()
        
        if try walletCore.isSavedKey(keyId: "pin") {
            var pinProof = Proof(created: Date.getUTC0Date(seconds: 0),
                                 proofPurpose: ProofPurpose.assertionMethod,
                                 verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#pin",
                                 type: ProofType.secp256r1Signature2018)
            
            holderDidDoc.proof = pinProof
            let firstSource = try DigestUtils.getDigest(source: holderDidDoc.toJsonData(), digestEnum: DigestEnum.sha256)
            WalletLogger.shared.debug("assert holderDidDoc Str: \(try holderDidDoc.toJson(isPretty: true))")
            
            let pinSignature = try walletCore.sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: firstSource, type: DidDocumentType.HolderDidDocumnet)
            holderDidDoc.proof = nil
            pinProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: pinSignature)
            proofArry.append(pinProof)
        }
        
        if try walletCore.isSavedKey(keyId: "bio") {
            var bioProof = Proof(created: Date.getUTC0Date(seconds: 0),
                                 proofPurpose: ProofPurpose.assertionMethod,
                                 verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#bio",
                                 type: ProofType.secp256r1Signature2018)
            
            holderDidDoc.proof = bioProof
            let secondSource = try DigestUtils.getDigest(source: holderDidDoc.toJsonData(), digestEnum: DigestEnum.sha256)
            
            WalletLogger.shared.debug("auth holderDidDoc Str: \(try holderDidDoc.toJson(isPretty: true))")
            let bioSignature = try walletCore.sign(keyId: "bio", pin: nil, data: secondSource, type: DidDocumentType.HolderDidDocumnet)
            // (core func)
            holderDidDoc.proof = nil

            bioProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: bioSignature)
            proofArry.append(bioProof)
                
        }
        
        holderDidDoc.proofs = proofArry
        WalletLogger.shared.debug("final holderDidDoc Str: \(try holderDidDoc.toJson(isPretty: true))")
        
        let ownerDIDDoc = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: try holderDidDoc.toJsonData())
        
        // deviceKey서명
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                        proofPurpose: ProofPurpose.assertionMethod,
                        verificationMethod: deviceDidDoc.id + "?versionId=" + deviceDidDoc.versionId + "#assert",
                        type: ProofType.secp256r1Signature2018)
        
        var signedDIDDoc = SignedDIDDoc(ownerDidDoc: ownerDIDDoc, wallet: wallet, nonce: hexNonce, proof: proof)
        
        let source = try DigestUtils.getDigest(source: signedDIDDoc.toJsonData(), digestEnum: DigestEnum.sha256)
        
        let signature = try walletCore.sign(keyId: "assert", pin: nil, data: source, type: DidDocumentType.DeviceDidDocument)
        
        signedDIDDoc.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
        WalletLogger.shared.debug("signed holderDidDoc Str: \(try signedDIDDoc.toJson(isPretty: true))")
        return signedDIDDoc
        

    }
    // TODO
    func createProofs(ownerDidDoc: DIDDocument?, proofPurpose: String) throws -> Data {
        return Data()
    }
    
    func createDeviceDocument() throws -> DIDDocument {
        // 1. deviceKey 생성 (core func)
        var didDoc = try walletCore.createDeviceDidDocument()
        var proofArry: [Proof] = .init()
        // 2. proofValue를 제외한 proof 생성
        var assertProof = Proof(created: Date.getUTC0Date(seconds: 0), proofPurpose: ProofPurpose.assertionMethod, verificationMethod: didDoc.id+"?versionId="+didDoc.versionId+"#assert", type: ProofType.secp256r1Signature2018)
        didDoc.proof = assertProof
        let assertSource = try DigestUtils.getDigest(source: didDoc.toJsonData(), digestEnum: DigestEnum.sha256)
        WalletLogger.shared.debug("assert didDoc Str: \(try didDoc.toJson())")
        let assertSignature = try walletCore.sign(keyId: "assert", pin: nil, data: assertSource, type: DidDocumentType.DeviceDidDocument)
        didDoc.proof = nil
        assertProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: assertSignature)
        proofArry.append(assertProof)
        
        var authProof = Proof(created: Date.getUTC0Date(seconds: 0), proofPurpose: ProofPurpose.authentication, verificationMethod: didDoc.id+"?versionId="+didDoc.versionId+"#auth", type: ProofType.secp256r1Signature2018)
        
        didDoc.proof = authProof
        let authSource = try DigestUtils.getDigest(source: didDoc.toJsonData(), digestEnum: DigestEnum.sha256)

        WalletLogger.shared.debug("auth didDoc Str: \(try didDoc.toJson())")
        let authSignature = try walletCore.sign(keyId: "auth", pin: nil, data: authSource, type: DidDocumentType.DeviceDidDocument)
        // (core func)
        didDoc.proof = nil
        
        authProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: authSignature)
        proofArry.append(authProof)
        
        didDoc.proofs = proofArry
        
        WalletLogger.shared.debug("fianl didDoc Str: \(try didDoc.toJson())")
        return didDoc
    }
    // TODO
    func requestRegisterWallet(tasURL: String, walletURL: String, ownerDidDoc: DIDDocument?) async throws -> Bool {
        return false
    }
    
    func bindUser() throws -> Bool {
        
        
        if let token = MockData.shared.getTokenMock() {
            WalletLogger.shared.debug("bindUser verifyWalletToken reg success")
            // 최초 유저 등록 시 finalEncKey값 존재하지 않음 (PIN 입력 후 매핑 됨)
            MockData.shared.setUserMock(user: UserMock(idx: "id", pii: token.pii, finalEncKey: "", createDate: "2024-08-23T11:40:03.566877Z", updateDate: "2050-08-23T12:10:02Z"))
            return true
        } else {
            WalletLogger.shared.debug("bindUser selectToken fail")
            throw WalletAPIError.selectQueryFail.getError()
        }
    }
    // TODO
    func unbindUser() throws -> Bool {
        return true
    }
    // TODO
    func requestRegisterUser(tasURL: String, txId: String, serverToken: String, signedDIDDoc: SignedDIDDoc?) async throws -> _RequestRegisterUser {
        return _RequestRegisterUser(txId: "txId")
    }
    
    func getSignedDidAuth(authNonce: String, passcode: String?) throws -> DIDAuth {
        // 1. 홀더 did 조회
        var didDoc = try walletCore.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        // 2. proofValue를 제외한 proof 생성
        
        let authType = passcode != nil ? "#pin" : "#bio"
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                        proofPurpose: ProofPurpose.authentication,
                        verificationMethod: didDoc.id + "?versionId=" + didDoc.versionId + authType,
                        type: ProofType.secp256r1Signature2018)
        didDoc.proof = proof
        
        // 3. 홀더 did, authnonce, proof(proofValue제외) 준비
        var didAuth = DIDAuth(did: didDoc.id, authNonce: authNonce, proof: proof)
        
        // 4. core sdk에 서명 요청
        let source = try DigestUtils.getDigest(source: didAuth.toJsonData(), digestEnum: DigestEnum.sha256)
        
        let signature: Data?
        if passcode != nil {
            signature = try walletCore.sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: source, type: DidDocumentType.HolderDidDocumnet)
        } else {
            signature = try walletCore.sign(keyId: "bio", pin: nil, data: source, type: DidDocumentType.HolderDidDocumnet)
        }
        
//        let signature = try walletCore._sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: source, type: didType)
        // 5. 최종 DidAuth의 proof 준비
        didAuth.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature!)
        // 6. didAuth 리턴
        return didAuth
    }
    
    func requestIssueVc(tasURL: String, didAuth: DIDAuth?, issuerProfile: _RequestIssueProfile?, refId: String, serverToken: String, APIGatewayURL: String) async throws -> (String, _RequestIssueVc?) {
    
        let holderDidDoc = try walletCore.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                        proofPurpose: ProofPurpose.keyAgreement,
                          verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#keyagree",
                        type: ProofType.secp256r1Signature2018)
        
        var accE2e = AccE2e(publicKey: "mAvuqNcA0akRCgC5anv6fTQFstQynq2WZgYg/9Eh0QkAy",
                                                     iv: "u9Mytc_E57cDAaAIIuCqfhw",
                                                     proof: proof)
        
        let accEceDummy = """
                        {"id": "20240829103610767000876724d4",
                          "txId": "1ca4e278-76cd-47e4-978f-139273e0a28a",
                          "accE2e": {
                            "publicKey": "mAvuqNcA0akRCgC5anv6fTQFstQynq2WZgYg/9Eh0QkAy",
                            "iv": "u9Mytc_E57cDAaAIIuCqfhw"
                          },
                          "encReqVc": "mYMh5+wqo+sFh3oMBpuQCVVNslPLH8juMMBQsUcoJ/NTGzqX4VkLwUML5gWecrHlpVeijasMZFbWVl9prwQApuB0ECzJWXvgJD9c4NwWRrMorMl+uU0eTHMMxbQhu4FARDy98pHpoBj6kP1pQ2Ai3iFgY9qQRowj0B6wW9Xu79Ugu+X+Labl3yqxrA9/5H3Z+b5VTmYZ/TZPKZRQuZRBb8qxz32GX1lCAPxki1ni2XDg"}
                        """
        
        let source = try DigestUtils.getDigest(source: accE2e.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature = try walletCore.sign(keyId: "keyagree", pin: nil, data: source, type: DidDocumentType.HolderDidDocumnet)
        
        accE2e.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
        
        let reqVcProfile = ReqVcProfile(id: issuerProfile!.profile.id, issuerNonce: issuerProfile!.profile.profile.process.issuerNonce)
        
        let reqVC = ReqVC(refId: refId, profile: reqVcProfile)
        WalletLogger.shared.debug("reqVc: \(try reqVC.toJson(isPretty: true))")
        
        let serverNonce = try MultibaseUtils.decode(encoded: issuerProfile!.profile.profile.process.issuerNonce)
        
        // 세션키 생성
        let sessKey = try CryptoUtils.generateSharedSecret(ecType: ECType.secp256r1,
                                                           privateKey: try MultibaseUtils.decode(encoded: "mNdy+e2T694f0QbSd/gdLvmdgUjti+RR6wQY4F+kMYfA="),
                                                           publicKey: MultibaseUtils.decode(encoded: issuerProfile!.profile.profile.process.reqE2e.publicKey))
        
        let clientMergedSharedSecret = WalletUtil.mergeSharedSecretAndNonce(sharedSecret: sessKey, nonce: serverNonce, symmetricCipherType: SymmetricCipherType.aes256CBC)

        let encReqVc = try CryptoUtils.encrypt(plain: reqVC.toJsonData(),
                                               info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5),
                                               key: clientMergedSharedSecret,
                                               iv: MultibaseUtils.decode(encoded: "zMMmb3pXD8KjEYUwp4tSzms"))
        
        let multiEncReqVc = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: encReqVc)
                
        let issueVcResponseDummy = """
        {"txId": "1ca4e278-76cd-47e4-978f-139273e0a28a","e2e": {"iv": "mwZPbY3+4RBYwwzuLOM6AFA","encVc": "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"}}
        """
        
        let decodedResponse = try _RequestIssueVc.init(from: issueVcResponseDummy)
        // 복호화, 월렛에 vc 저장
        let envVc = try MultibaseUtils.decode(encoded: decodedResponse.e2e.encVc)
        
        let decVc = try CryptoUtils.decrypt(cipher: envVc,
                                            info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC,padding: SymmetricPaddingType.pkcs5),
                                            key: MultibaseUtils.decode(encoded: "myVtcQ4f4nuqJ/Ac3JnuVXCjb4TrzbRfPo95bSTMfbA8"),
                                            iv: MultibaseUtils.decode(encoded: decodedResponse.e2e.iv))
        
        
        print("decVc.json :\(MultibaseUtils.encode(type: MultibaseType.base64, data: decVc))")
        
        var vc = try VerifiableCredential(from: decVc)
        let tempProofValue = vc.proof.proofValue
        let tempProofValueList = vc.proof.proofValueList

        // vc 체크 후 조회 (is any credential)
        if walletCore.isAnyCredentialsSaved() {
            let vcs = try walletCore.getAllCredentials()
            for v in vcs {
                if v.credentialSchema.id == vc.credentialSchema.id {
                    WalletLogger.shared.debug("v.credentialSchema.id: \(v.credentialSchema.id)")
                    WalletLogger.shared.debug("vc.credentialSchema.id: \(vc.credentialSchema.id)")
                    _ = try walletCore.deleteCredential(ids: [v.id])
                }
            }
        }
        
        vc.proof.proofValue = tempProofValue
        vc.proof.proofValueList = tempProofValueList
        
        print("vc!!!!!: \(try vc.toJson(isPretty: true))")
        _ = try walletCore.addCredential(credential: vc)
        
        // 월렛에 저장
        // 이슈어 서명 검증 통신 (블록체인)
        return (vc.id, decodedResponse)
    }
    // TODO
    func requestRevokeVc(tasURL: String, authType: VerifyAuthType, vcId: String, issuerNonce: String, txId: String, serverToken: String, passcode: String?) async throws -> _RequestRevokeVc {
        return try _RequestRevokeVc(from: Data())
    }
    // TODO
    func requestRestoreUser(tasURL: String, txId: String, serverToken: String, didAuth: DIDAuth?) async throws -> _RequestRestoreDidDoc {
        return try _RequestRestoreDidDoc(txId: "txId")
    }
    // TODO
    func getSignedWalletInfo() throws -> SignedWalletInfo {
        return try SignedWalletInfo(from: Data())
    }
}
