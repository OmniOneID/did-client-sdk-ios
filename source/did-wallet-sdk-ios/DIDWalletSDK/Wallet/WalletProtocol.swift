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



public protocol WalletLockManagerImpl {
    func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool
    func isRegLock() throws -> Bool
    func authenticateLock(passcode: String) throws -> Data?
}

public protocol WalletTokenImpl {
    func verifyWalletToken(hWalletToken: String, purposes: [WalletTokenPurposeEnum]) throws
    func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String, userId: String?) throws -> WalletTokenSeed
    func createNonceForWalletToken(walletTokenData: WalletTokenData?, APIGatewayURL: String) async throws  -> String
}

public protocol WalletCoreImpl {
    func isSavedKey(keyId: String) throws -> Bool
    func deleteWallet() throws -> Bool
    func saveDidDocument(type: DidDocumentType) throws -> Void
    func isExistWallet() throws -> Bool
    func generateKey(passcode: String?, keyId: String, algType: AlgorithmType, promptMsg: String?) throws -> Void
    func sign(keyId: String, pin: Data?, data: Data, type: DidDocumentType) throws -> Data
    func createDeviceDidDocument() throws -> DIDDocument
    func createHolderDidDocument() throws -> DIDDocument
    func getDidDocument(type: DidDocumentType) throws -> DIDDocument
    func verify(publicKey:Data, data: Data, signature: Data) throws -> Bool
    func addCredential(credential: VerifiableCredential) throws -> Bool
    func deleteCredential(ids: [String]) throws -> Bool
    func getCredential(ids: [String]) throws -> [VerifiableCredential]
    func getAllCredentials() throws -> [VerifiableCredential]
    func isAnyCredentialsSaved() -> Bool
    func makePresentation(claimInfos: [ClaimInfo], presentationInfo: PresentationInfo) throws -> VerifiablePresentation
    func getKeyInfos(keyType: VerifyAuthType) throws -> [KeyInfo]
    func getKeyInfos(ids: [String]) throws -> [KeyInfo]
    func isAnyKeysSaved() throws -> Bool
    func changePin(id: String, oldPIN: String, newPIN: String) throws
    
    //MARK: Zero-Knowledge Proof
    func isAnyZKPCredentialsSaved() -> Bool
    func isZKPCredentialSaved(id : String) -> Bool
    func createZKPCredentialRequest(proverDid : String,
                                    credentialDefinition : ZKPCredentialDefinition,
                                    credOffer : ZKPCredentialOffer) throws -> ZKPCredentialRequestContainer
    @discardableResult func verifyAndStoreZKPCredential(credentialMeta : ZKPCredentialRequestMeta,
                                                        credentialDefinition : ZKPCredentialDefinition,
                                                        credential : ZKPCredential) throws -> Bool
    @discardableResult func deleteZKPCredential(ids: [String]) throws -> Bool
    func getZKPCredential(ids: [String]) throws -> [ZKPCredential]
    func getAllZKPCredentials() throws -> [ZKPCredential]
    func searchZKPCredentials(proofRequest : ProofRequest) throws -> AvailableReferent
    func createZKProof(proofRequest : ProofRequest,
                       selectedReferents : [UserReferent],
                       proofParam : ZKProofParam) throws -> ZKProof
}

public protocol WalletServiceImpl {
    func deleteWallet() throws -> Bool
    func createWallet(tasURL: String, walletURL: String) async throws -> Bool
    func requestVp(hWalletToken: String, claimInfos: [ClaimInfo]?, verifierProfile: _RequestProfile?, APIGatewayURL: String, passcode: String?) async throws -> (AccE2e, Data)
    func requestZKProof(hWalletToken:String,
                        selectedReferents : [UserReferent],
                        proofParam : ZKProofParam,
                        proofRequestProfile: _RequestProofRequestProfile?,
                        APIGatewayURL: String) async throws -> (AccE2e, Data)
    func createSignedDIDDoc(passcode: String?) throws -> SignedDIDDoc
    func createProofs(ownerDidDoc: DIDDocument?, proofPurpose: String) throws -> Data
    func createDeviceDocument() throws -> DIDDocument
    func requestRegisterWallet(tasURL: String, walletURL: String, ownerDidDoc: DIDDocument?) async throws -> Bool
    
    func bindUser() throws -> Bool
    func unbindUser() throws -> Bool
    func requestRegisterUser(tasURL: String, txId: String, serverToken: String, signedDIDDoc: SignedDIDDoc?) async throws -> _RequestRegisterUser
    
    func requestRestoreUser(tasURL: String, txId: String, serverToken: String, didAuth: DIDAuth?) async throws -> _RequestRestoreDidDoc
    
    func requestUpdateUser(tasURL: String, txId: String, serverToken: String, didAuth: DIDAuth?, signedDIDDoc: SignedDIDDoc?) async throws -> _RequestUpdateDidDoc
    
    func getSignedDidAuth(authNonce: String, passcode: String?) throws -> DIDAuth
    func requestIssueVc(tasURL: String, didAuth: DIDAuth?, issuerProfile: _RequestIssueProfile?, refId: String, serverToken: String, APIGatewayURL: String) async throws -> (String, _RequestIssueVc?)
    func requestRevokeVc(tasURL: String, authType: VerifyAuthType, vcId: String, issuerNonce: String, txId: String, serverToken: String, passcode: String?) async throws -> _RequestRevokeVc
    func getSignedWalletInfo() throws -> SignedWalletInfo
}
