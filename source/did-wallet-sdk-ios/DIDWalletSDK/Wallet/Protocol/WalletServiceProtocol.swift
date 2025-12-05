//
/*
 * Copyright 2025 OmniOne.
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

protocol IWalletAPI : IWalletService, IDIDKeyService, ICredentialService, IZKPService, ISecurityAuthService
{}

protocol IWalletService
{
    func isExistWallet() -> Bool
    func createWallet(tasURL: String,
                      walletURL: String) async throws -> Bool
    func deleteWallet(deleteAll: Bool) throws
    func createWalletTokenSeed(purpose: WalletTokenPurposeEnum,
                               pkgName: String,
                               userId: String) throws -> WalletTokenSeed
    func createNonceForWalletToken(walletTokenData: WalletTokenData,
                                   APIGatewayURL: String) async throws -> String
    func bindUser(hWalletToken: String) throws -> Bool
    func unbindUser(hWalletToken: String) throws -> Bool
    func requestRegisterUser(tasURL: String,
                             txId: String,
                             hWalletToken: String,
                             serverToken: String,
                             signedDIDDoc: SignedDIDDoc) async throws -> _RequestRegisterUser
    func getSignedWalletInfo() throws -> SignedWalletInfo
}

protocol IDIDKeyService
{
    func createHolderDIDDocument(hWalletToken: String) throws -> DIDDocument
    func createSignedDIDDoc(passcode: String?) throws -> SignedDIDDoc
    func getDidDocument(type: DidDocumentType) throws -> DIDDocument
    func isAnyKeysSaved() throws -> Bool
    func isSavedKey(keyId: String) throws -> Bool
    func generateKeyPair(hWalletToken: String,
                         passcode: String?,
                         keyId: String,
                         algType: AlgorithmType,
                         promptMsg: String?) throws -> Bool
    func sign(keyId: String,
              pin: Data?,
              data: Data,
              type: DidDocumentType) throws -> Data
    func verify(publicKey: Data,
                data: Data,
                signature: Data) throws -> Bool
    func getSignedDidAuth(authNonce: String,
                          passcode: String?) throws -> DIDAuth
    func updateHolderDIDDocument(hWalletToken: String) throws -> DIDDocument
    func saveHolderDIDDocument() throws
    func deleteKeyPair(hWalletToken: String, keyId: String) throws
    func requestUpdateUser(tasURL: String,
                           txId: String,
                           hWalletToken: String,
                           serverToken: String,
                           didAuth: DIDAuth?,
                           signedDIDDoc: SignedDIDDoc?) async throws -> _RequestUpdateDidDoc
    func requestRestoreUser(tasURL: String,
                            txId: String,
                            hWalletToken: String,
                            serverToken: String,
                            didAuth: DIDAuth?) async throws -> _RequestRestoreDidDoc
}

protocol ICredentialService
{
    func requestIssueVc(tasURL: String,
                        hWalletToken: String,
                        didAuth: DIDAuth,
                        issuerProfile: _RequestIssueProfile,
                        refId: String,
                        serverToken: String,
                        APIGatewayURL: String) async throws -> (String, _RequestIssueVc?)
    func requestRevokeVc(hWalletToken:String,
                         tasURL: String,
                         authType: VerifyAuthType,
                         vcId: String,
                         issuerNonce: String,
                         txId: String,
                         serverToken: String,
                         passcode: String?) async throws -> _RequestRevokeVc
    func getAllCredentials(hWalletToken: String) throws -> [VerifiableCredential]?
    func getCredentials(hWalletToken: String,
                        ids: [String]) throws -> [VerifiableCredential]
    func deleteCredentials(hWalletToken: String,
                           ids: [String]) throws -> Bool
    func createEncVp(hWalletToken:String,
                     claimInfos: [ClaimInfo]?,
                     verifierProfile: _RequestProfile,
                     APIGatewayURL: String,
                     passcode: String?) async throws -> (AccE2e, Data)
    var isAnyCredentialsSaved: Bool { get }
}

protocol IZKPService
{
    func createEncZKProof(hWalletToken:String,
                          selectedReferents : [UserReferent],
                          proofParam : ZKProofParam,
                          proofRequestProfile: _RequestProofRequestProfile,
                          APIGatewayURL: String) async throws -> (AccE2e, Data)
    func searchZKPCredentials(hWalletToken: String,
                              proofRequest : ProofRequest) throws -> AvailableReferent
    func getAllZKPCredentials(hWalletToken: String) throws -> [ZKPCredential]?
    var isAnyZKPCredentialsSaved: Bool { get }
    func isZKPCredentialSaved(id : String) -> Bool
    func getZKPCredentials(hWalletToken: String,
                           ids: [String]) throws -> [ZKPCredential]
}

protocol ISecurityAuthService
{
    func registerLock(hWalletToken: String,
                      passcode: String,
                      isLock: Bool) throws -> Bool
    func authenticateLock(passcode: String) throws -> Data?
    func isLock() throws -> Bool
    func changePin(id: String,
                   oldPIN: String,
                   newPIN: String) throws
    func changeLock(oldPasscode: String,
                    newPasscode: String) throws
    func authenticatePin(id: String,
                         pin: String) throws
}
