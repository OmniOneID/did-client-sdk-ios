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

// Controller
public class WalletAPI {
    
    public static let shared: WalletAPI = WalletAPI()
    
    // When using the actual SDK, please change the public variables below to private and use them. They are changed to public for the testcase mirror function.
    var walletService: WalletServiceImpl
    var lockMnr: WalletLockManagerImpl
    var walletCore: WalletCoreImpl
    var walletToken: WalletTokenImpl
    
    private init() {
        lockMnr = WalletLockManager()
        walletCore = WalletCore()
        walletToken = WalletToken(walletCore)
        walletService = WalletService(walletCore)
    }
    
    /// Checks if a wallet exists by verifying if any device keys and device DID document are saved.
    ///
    /// - Returns: A boolean indicating whether a wallet exists.
    ///            Returns false if no keys are saved and the device DID is not saved, otherwise true.
    public func isExistWallet() -> Bool {
        return walletCore.isExistWallet()
    }
    
    /// Creates a wallet by fetching certified app information, generating a device key,
    /// and registering the wallet with the given parameters.
    ///
    /// - Parameters:
    ///   - tasURL: The URL of the Trusted Application Service.
    ///   - walletURL: The URL where the wallet will be registered.
    /// - Returns: A boolean indicating the success of the wallet creation.
    /// - Throws: An error if the process fails at any stage.
    @discardableResult
    public func createWallet(tasURL: String, walletURL: String) async throws -> Bool {
        return try await walletService.createWallet(tasURL: tasURL, walletURL: walletURL)
    }
    
    /// Deletes the wallet by removing datas and all associated documents and keys.
    ///
    ///
    /// - Throws: An error of type `WalletAPIError` if the wallet is locked or if any deletion operation fails.
    /// - Returns: A boolean indicating whether the wallet deletion was successful.
    @discardableResult
    public func deleteWallet() throws -> Bool {
        return try walletService.deleteWallet()
    }
    
    
    @discardableResult
    /// Creates a wallet token seed based on the provided purpose, package name, and user ID.
    /// The function calls an internal method to generate the token seed.
    /// If successful, it returns an instance of WalletTokenSeed. If the token seed creation fails,
    /// the function throws an error.
    /// - Parameters:
    ///   - purpose: An enum value specifying the purpose of the wallet token.
    ///   - pkgName: The package name associated with the wallet token.
    ///   - userId: The user ID for whom the wallet token is being created.
    /// - Returns: An optional WalletTokenSeed instance if the creation is successful, otherwise nil.
    /// - Throws: An error if the wallet token seed creation fails.
    public func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String, userId: String) throws -> WalletTokenSeed {
        return try walletToken.createWalletTokenSeed(purpose: purpose, pkgName: pkgName, userId: userId)
    }
    
    
    /// createNonceForWalletToken
    /// - Parameter walletTokenData: walletTokenData
    /// - Returns: String
    public func createNonceForWalletToken(walletTokenData: WalletTokenData, APIGatewayURL: String) async throws -> String {
        return try await walletToken.createNonceForWalletToken(walletTokenData: walletTokenData, APIGatewayURL: APIGatewayURL)
    }
    
    
    /// Attempts to bind a user using the provided wallet token (hWalletToken).
    ///
    /// The function first logs the wallet token for debugging purposes. Then, it verifies the token
    /// to ensure it is valid for the specified purposes (PERSONALIZED and PERSONALIZE_AND_CONFIGLOCK).
    ///
    /// If the token is successfully verified, the function proceeds to bind the user by calling an internal method
    /// and returns `true` if successful.
    ///
    /// If the token verification fails, the function throws a WalletApiError with a VERIFY_TOKEN_FAIL error code.
    ///
    /// - Parameter hWalletToken: A string representing the wallet token to be verified and used for binding the user.
    /// Returns:  boolean value that is `true` if the user binding is successful.
    /// Throws:  WalletApiError if the wallet token verification fails or if any other error occurs during the process.
    @discardableResult
    public func bindUser(hWalletToken: String) throws -> Bool {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.PERSONALIZED, .PERSONALIZE_AND_CONFIGLOCK])
        return try walletService.bindUser()
        
    }
    
    /// Attempts to unbind a user using the provided wallet token (hWalletToken).
    /// The function first verifies the wallet token to ensure it is valid for the purpose of depersonalization.
    /// If the token is successfully verified, it logs a success message.
    /// It then tries to delete the user data using the `CoreDataManager`.
    /// If the deletion is successful, the function returns `true`.
    /// If the deletion fails, it throws a `WalletApiError` with a general failure error code.
    /// If the token verification fails, the function throws a `WalletApiError` with a VERIFY_TOKEN_FAIL error code.
    /// - Parameter hWalletToken: A string representing the wallet token to be verified and used for unbinding the user.
    /// - Returns: boolean value that is `true` if the user unbinding is successful.
    /// - Throws: WalletApiError If the wallet token verification fails or if any other error occurs during the process.
    @discardableResult
    public func unbindUser(hWalletToken: String) throws -> Bool {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.DEPERSONALIZED])
        return try walletService.unbindUser()
    }
    
    /// Registers or updates the lock status of the wallet using the provided wallet token, passcode, and lock status.
    /// The function first verifies the wallet token to ensure it is valid for the purposes of personalization
    /// and configuration of the lock. If the token is successfully verified, it registers or updates the lock
    /// by calling an internal method in `lockMnr` with the provided token, passcode, and lock status.
    /// If the registration or update is successful, it logs a success message and returns `true`.
    /// If the token verification fails, the function throws a `WalletApiError` with a VERIFY_TOKEN_FAIL error code.
    ///
    /// - Parameters:
    ///   - hWalletToken: A string representing the wallet token to be verified and used for registering the lock.
    ///   - passcode: A string representing the passcode associated with the lock.
    ///   - isLock: A boolean value indicating whether to lock (`true`) or unlock (`false`) the wallet.
    /// - Returns: boolean value that is `true` if the lock registration or update is successful.
    /// - throws WalletApiError If the wallet token verification fails or if any other error occurs during the process.
    public func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.PERSONALIZED, .PERSONALIZE_AND_CONFIGLOCK])
        _ = try lockMnr.registerLock(hWalletToken: hWalletToken, passcode: passcode, isLock: isLock)
        return true
        
    }
    
    /// Authenticates the lock using the provided passcode.
    /// - Parameter passcode: The passcode to authenticate the lock.
    /// - Returns: The authenticated data if the passcode is correct, otherwise nil.
    /// - Throws: An error if there is an issue with the authentication process.
    public func authenticateLock(passcode: String) throws -> Data? {
        return try lockMnr.authenticateLock(passcode: passcode)
    }
    
    /// This function generates a Verifiable Presentation (VP) by creating a cryptographic proof,
    /// encrypting the presentation, and returning it along with end-to-end encryption (E2E) parameters. The VP
    /// is used to authenticate a holder's identity and claims to a verifier.
    ///
    /// Parameters:
    /// - hWalletToken: String - The wallet token representing the holder's wallet.
    /// - claimInfos: [ClaimInfo]? - Optional. A list of claims that will be included in the presentation.
    /// - verifierProfile: _RequestProfile - The profile of the verifier, including information such as DID and certificate.
    /// - APIGatewayURL: String - The URL of the API gateway for communication and verification.
    /// - passcode: String? (Optional) - An optional passcode for PIN-based authentication.
    ///
    /// Returns: (AccE2e, Data) - Returns a tuple containing the AccE2e object with encryption data and the encrypted VP.
    ///
    /// Throws: Errors can be thrown for cryptographic failures, data encoding issues, or network communication problems.
    public func createEncVp(hWalletToken:String, claimInfos: [ClaimInfo]? = nil, verifierProfile: _RequestProfile, APIGatewayURL: String, passcode: String? = nil) async throws -> (AccE2e, Data) {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.PRESENT_VP, .LIST_VC_AND_PRESENT_VP])
        return try await walletService.requestVp(hWalletToken: hWalletToken, claimInfos: claimInfos, verifierProfile: verifierProfile, APIGatewayURL: APIGatewayURL, passcode: passcode)
    }
    
    /// Checks if the lock is enabled.
    /// - Returns: A boolean value indicating whether the lock is enabled.
    /// - Throws: An error if there is an issue checking the lock status.
    public func isLock() throws -> Bool {
        return try lockMnr.isRegLock()
    }
    
    
    /// Creates a signed DID Document using the provided passcode.
    /// - Parameter passcode: An optional passcode used for creating the signed DID Document.
    /// - Returns: A SignedDidDoc object representing the signed DID Document.
    /// - Throws: An error if there is an issue creating the signed DID Document.
    public func createSignedDIDDoc(passcode: String? = nil) throws -> SignedDIDDoc {
        return try walletService.createSignedDIDDoc(passcode: passcode)
    }
    
    /// Requests to register a user with the given parameters and returns a `_M132_RequestRegisterUser` object.
    /// - Parameters:
    ///   - tasURL: The URL to which the registration request will be sent.
    ///   - txId: The transaction ID associated with the registration request.
    ///   - hWalletToken: The token used to authenticate the wallet.
    ///   - serverToken: The token used to authenticate the server.
    ///   - signedDidDoc: A signed DID Document representing the user's identity.
    /// - Returns: A `_M132_RequestRegisterUser` object representing the registration request.
    /// - Throws: A `WalletApiError` if there is an issue verifying the wallet token.
    public func requestRegisterUser(tasURL: String, txId: String, hWalletToken: String, serverToken: String, signedDIDDoc: SignedDIDDoc) async throws -> _RequestRegisterUser {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.CREATE_DID])
        return try await walletService.requestRegisterUser(tasURL: tasURL, txId: txId, serverToken: serverToken, signedDIDDoc: signedDIDDoc)
    }
    
    /// Requests a restore of a user's DID document.
    ///
    /// This function sends a request to the specified URL to restore a user's DID document
    /// using the provided parameters including user ID, transaction ID, server token, and DID authentication details.
    ///
    /// - Parameters:
    ///   - tasURL: The tasURL endpoint to send the restore request to.
    ///   - txId: The transaction ID associated with the restore request.
    ///   - hWalletToken: The token used to authenticate the wallet.
    ///   - serverToken: The token for server authentication.
    ///   - didAuth: The authentication details for the DID.
    /// - Throws: An error if the request fails or if the response cannot be parsed.
    /// - Returns: A `_RequestRestoreDidDoc` object containing the response data.
    public func requestRestoreUser(tasURL: String, txId: String, hWalletToken: String, serverToken: String, didAuth: DIDAuth?) async throws -> _RequestRestoreDidDoc {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.RESTORE_DID])
        return try await walletService.requestRestoreUser(tasURL: tasURL, txId: txId, serverToken: serverToken, didAuth: didAuth)
    }
    
    public func requestUpdateUser(tasURL: String, txId: String, hWalletToken: String, serverToken: String, didAuth: DIDAuth?, signedDIDDoc: SignedDIDDoc?) async throws -> _RequestUpdateDidDoc {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.UPDATE_DID])
        return try await walletService.requestUpdateUser(tasURL: tasURL, txId: txId, serverToken: serverToken, didAuth: didAuth, signedDIDDoc: signedDIDDoc)
    }
    
    
    /// Get signed DID authentication object.
    /// This function verifies the wallet token and returns a signed DID authentication object.
    /// - Parameters:
    ///   - authNonce: The authentication nonce.
    ///   - pin: The optional PIN to unlock the wallet.
    /// - Throws:
    ///   - `WalletApiError` when the wallet token verification fails.
    ///   - Any error thrown by `_getSignedDidAuth`.
    /// - Returns: The signed DID authentication object.
    public func getSignedDidAuth(authNonce: String, passcode: String? = nil) throws -> DIDAuth? {
        return try walletService.getSignedDidAuth(authNonce: authNonce, passcode: passcode)
    }
    
    /// Request issue Credential with the given parameters.
    ///- Parameters:
    ///  - tasURL: The TAS URL for the request.
    ///  - hWalletToken: The wallet token for authentication.
    ///  - didAuth: The DID authentication object.
    ///  - issuerProfile: The issuer profile for the request.
    ///  - refId: The reference ID for the request.
    ///  - serverToken: The server token for authentication.
    ///  - APIGatewayURL: The API Gateway URL for the request.
    /// - Returns:
    ///  A tuple containing a string and an optional request issue view controller.
    /// - Throws:
    ///  An error if verification of the wallet token fails.
    public func requestIssueVc(tasURL: String, hWalletToken: String, didAuth: DIDAuth, issuerProfile: _RequestIssueProfile, refId: String, serverToken: String, APIGatewayURL: String) async throws -> (String, _RequestIssueVc?) {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.ISSUE_VC])
        return try await walletService.requestIssueVc(tasURL: tasURL, didAuth: didAuth, issuerProfile: issuerProfile, refId: refId, serverToken: serverToken, APIGatewayURL: APIGatewayURL)
    }
    
    /// This function handles the process of revoking a verifiable credential (VC) by generating and signing a
    /// request to revoke the VC. It performs the necessary cryptographic operations and communicates with a server to process
    /// the revocation. The proof of revocation is generated and appended to the request before sending it to the specified server URL.
    ///
    /// - Parameters:
    ///   - hWalletToken: The wallet token for authentication.
    ///   - tasURL: String - The URL of the server where the revocation request is sent.
    ///   - authType: VerifyAuthType - The type of authentication used (e.g., biometrics, passcode).
    ///   - vcId: String - The ID of the verifiable credential to be revoked.
    ///   - issuerNonce: String - A nonce value provided by the issuer to ensure the request is valid.
    ///   - msgId: String - A unique message ID to track the request.
    ///   - txId: String - The transaction ID to identify the request within a broader operation.
    ///   - serverToken: String - A server token that authenticates the request.
    ///   - passcode: String? (Optional) - A passcode used for authentication, if applicable (e.g., PIN-based verification).
    ///
    /// - Returns: _RequestRevokeVc - A structured object containing the server's response to the revocation request.
    ///
    /// Throws: Various errors related to cryptographic operations, server communication, or data encoding failures.
    public func requestRevokeVc(hWalletToken:String, tasURL: String, authType: VerifyAuthType, vcId: String, issuerNonce: String, txId: String, serverToken: String, passcode: String? = nil) async throws -> _RequestRevokeVc {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes: [.REMOVE_VC])
        return try await walletService.requestRevokeVc(tasURL: tasURL, authType: authType, vcId: vcId, issuerNonce: issuerNonce, txId: txId, serverToken: serverToken, passcode: passcode)
    }
    
    /// Retrieves signed wallet information with the given wallet token.
    /// - Returns:
    ///  The signed wallet information.
    /// - Throws:
    ///  An error if verification of the wallet token fails.
    public func getSignedWalletInfo() throws -> SignedWalletInfo {
        return try walletService.getSignedWalletInfo()
    }
}

extension WalletAPI {
    
    /// Creates a DID document wallet.
    /// After Finish the registration,
    /// Must call `saveHolderDIDDocument`
    /// - Parameters:
    ///   - hWalletToken: The wallet token used for verification.
    /// - Returns:
    ///    A DIDDocument object representing the created document, or nil if creation fails.
    /// - Throws:
    ///   An error if the wallet token verification fails or if there are issues with creating the document.
    @discardableResult
    public func createHolderDIDDocument(hWalletToken: String) throws -> DIDDocument {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes:[.CREATE_DID])
        return try walletCore.createHolderDidDocument()
    }
    
    //
    public func updateHolderDIDDocument(hWalletToken: String) throws -> DIDDocument {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes:[.UPDATE_DID])
        return try walletCore.createHolderDidDocument()
    }
    
    /// Save holder's DID document changes
    public func saveHolderDIDDocument() throws
    {
        try walletCore.saveHolderDIDDocument()
    }
    //
    
    /// Retrieves the DID document of the specified type.
    /// - Parameters:
    ///   - type: The type of DID document to retrieve.
    /// - Returns:
    ///   A DIDDocument object representing the retrieved document.
    /// - Throws:
    ///   An error if there are issues with retrieving the DID document.
    public func getDidDocument(type: DidDocumentType) throws -> DIDDocument {
        return try walletCore.getDidDocument(type: type)
    }
    
    /// Generates a key pair based on the specified wallet token, key ID, and algorithm type.
    /// - Parameters:
    ///   - hWalletToken: The wallet token used for verification.
    ///   - passcode: The passcode used for encryption.
    ///   - keyId: The ID of the key pair to generate.
    ///   - algType: The type of algorithm to use for key generation.
    ///   - promptMsg: A prompt message to display during key generation (optional).
    /// - Returns:
    ///   A boolean value indicating whether or not key generation was successful.
    /// - Throws:
    ///   An error if the wallet token verification fails or if there are issues with generating the key pair.
    @discardableResult
    public func generateKeyPair(hWalletToken: String, passcode: String? = nil, keyId: String, algType: AlgorithmType, promptMsg: String? = nil) throws -> Bool {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes:[.CREATE_DID])
        try walletCore.generateKey(passcode: passcode, keyId: keyId, algType: algType, promptMsg: promptMsg)
        return true

    }
    
    /// Signs the specified data using the private key associated with the specified key ID.
    /// - Parameters:
    ///   - keyId: The ID of the key to use for signing.
    ///   - pin: The PIN to use for key decryption (optional).
    ///   - data: The data to sign.
    ///   - type: The type of DID document associated with the key.
    /// - Returns:
    ///   The signature generated using the specified key and data.
    /// - Throws:
    ///   An error if there are issues with signing the data.
    @discardableResult
    public func sign(keyId: String, pin: Data? = nil, data: Data, type: DidDocumentType) throws -> Data {
        return try walletCore.sign(keyId: keyId, pin: pin, data: data, type: type)
    }
    
    /// Verifies a signature using the specified wallet token, public key, data, and signature.
    /// - Parameters:
    ///   - publicKey: The public key to use for verification.
    ///   - data: The data to verify.
    ///   - signature: The signature to verify.
    /// - Returns: boolean value indicating whether the signature is valid.
    /// - Throws: WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    public func verify(publicKey: Data, data: Data, signature: Data) throws -> Bool {
        return try walletCore.verify(publicKey: publicKey, data: data, signature: signature)
    }
    
    //MARK: Verifiable Credential
    
    /// Checks whether any credentials are saved in the wallet.
    ///
    /// - Returns: `true` if at least one credential is saved,
    ///            otherwise `false`.
    public var isAnyCredentialsSaved : Bool
    {
        return walletCore.isAnyCredentialsSaved()
    }
    
    /// Revokes the specified verifiable credentials from the wallet using the provided wallet token.
    /// - Parameters:
    ///   - hWalletToken: The token associated with the wallet.
    ///   - ids: An array of identifiers for the credentials to revoke.
    /// - Returns: boolean value indicating whether the credentials were successfully revoked.
    /// - Throws: WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    public func deleteCredentials(hWalletToken: String, ids: [String]) throws -> Bool
    {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes:[.REMOVE_VC])
        
        var existedZkpIds:[String] = []
        
        for id in ids
        {
            if walletCore.isZKPCredentialSaved(id: id)
            {
                existedZkpIds.append(id)
            }
        }
        
        if !existedZkpIds.isEmpty
        {
            try walletCore.deleteZKPCredential(ids: existedZkpIds)
        }
        
        
        return try walletCore.deleteCredential(ids: ids)
    }
    
    /// Retrieves the specified verifiable credentials from the wallet using the provided wallet token.
    /// - Parameters:
    ///   - hWalletToken: The token associated with the wallet.
    ///   - ids: An array of identifiers for the credentials to retrieve.
    /// - Returns:An array of VerifiableCredential objects representing the retrieved credentials.
    /// - Throws:WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    public func getCredentials(hWalletToken: String, ids: [String]) throws -> [VerifiableCredential] {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes:[.LIST_VC, .DETAIL_VC, .LIST_VC_AND_PRESENT_VP])
        return try walletCore.getCredential(ids: ids)
    }
    
    /// Retrieves all verifiable credentials stored in the wallet using the provided wallet token.
    /// - Parameters:
    ///   - hWalletToken: The token associated with the wallet.
    /// - Returns: An array of VerifiableCredential objects representing all stored credentials, or nil if no credentials are saved.
    /// - Throws: WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    public func getAllCrentials(hWalletToken: String) throws -> [VerifiableCredential]? {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken, purposes:[.LIST_VC, .DETAIL_VC, .LIST_VC_AND_PRESENT_VP])
        if walletCore.isAnyCredentialsSaved() {
            return try walletCore.getAllCredentials()
        }
        return nil
    }

    
    //MARK: Zero-Knowledge Proof
    /// Checks if a ZKP credential with the given ID is saved.
    ///
    /// - Parameter id: Credential ID
    /// - Returns: `true` if saved, `false` otherwise
    public func isZKPCredentialSaved(id : String) -> Bool
    {
        return walletCore.isZKPCredentialSaved(id: id)
    }
    
    /// Retrieves the specified ZKP credentials from the wallet using the provided wallet token.
    /// - Parameters:
    ///   - hWalletToken: The token associated with the wallet.
    ///   - ids: An array of identifiers for the credentials to retrieve.
    /// - Returns:An array of ZKP Credential objects representing the retrieved credentials.
    /// - Throws:WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    public func getZKPCredentials(hWalletToken: String,
                                  ids: [String]) throws -> [ZKPCredential]
    {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken,
                                               purposes:[.LIST_VC,
                                                         .DETAIL_VC,
                                                         .LIST_VC_AND_PRESENT_VP])
        return try walletCore.getZKPCredential(ids: ids)
    }
    
    
    
    /// Retrieves all ZKP credentials stored in the wallet using the provided wallet token.
    /// - Parameters:
    ///   - hWalletToken: The token associated with the wallet.
    /// - Returns: An array of ZKP Credential objects representing all stored credentials, or nil if no credentials are saved.
    /// - Throws: WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    public func getAllZKPCrentials(hWalletToken: String) throws -> [ZKPCredential]?
    {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken,
                                               purposes:[.LIST_VC,
                                                         .DETAIL_VC,
                                                         .LIST_VC_AND_PRESENT_VP])
        if walletCore.isAnyZKPCredentialsSaved()
        {
            return try walletCore.getAllZKPCredentials()
        }
        return nil
    }
    
    /// Searches for credentials that satisfy the given proof request.
    ///
    /// - Parameters:
    ///   - hWalletToken: The token associated with the wallet.
    ///   - proofRequest: The proof request specifying required attributes and predicates
    /// - Returns: An `AvailableReferent` containing referents for matching credentials
    public func searchCredentials(hWalletToken: String,
                                  proofRequest : ProofRequest) throws -> AvailableReferent
    {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken,
                                               purposes:[.PRESENT_VP,
                                                         .LIST_VC_AND_PRESENT_VP])
        
        return try walletCore.searchZKPCredentials(proofRequest: proofRequest)
    }
    
    /// This function generates a Zero-knowledge proof by creating a cryptographic proof,
    /// encrypting the proof, and returning it along with end-to-end encryption (E2E) parameters.
    ///
    /// - Parameters:
    ///   - hWalletToken: String - The wallet token representing the holder's wallet.
    ///   - selectedReferents: The referents selected by the user to satisfy the proof request
    ///   - proofParam: Additional parameters used to construct the proof
    ///   - proofRequestProfile: _RequestProofRequestProfile - The profile of the verifier, including information such as DID and zkp certificate.
    ///   - APIGatewayURL: String - The URL of the API gateway for communication and verification.
    ///
    /// Returns: (AccE2e, Data) - Returns a tuple containing the AccE2e object with encryption data and the encrypted proof.
    ///
    /// Throws: Errors can be thrown for cryptographic failures, data encoding issues, or network communication problems.
    public func createEncZKProof(hWalletToken:String,
                                 selectedReferents : [UserReferent],
                                 proofParam : ZKProofParam,
                                 proofRequestProfile: _RequestProofRequestProfile,
                                 APIGatewayURL: String) async throws -> (AccE2e, Data)
    {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken,
                                               purposes: [.PRESENT_VP,
                                                          .LIST_VC_AND_PRESENT_VP])
        
        return try await walletService.requestZKProof(hWalletToken: hWalletToken,
                                                      selectedReferents: selectedReferents,
                                                      proofParam: proofParam,
                                                      proofRequestProfile: proofRequestProfile,
                                                      APIGatewayURL: APIGatewayURL)
    }
    
    //MARK: Key
    
    /// Retrieves information about a specific type of key stored in a wallet.
    /// - Parameters:
    ///   - keyType: The type of keys to retrieve information for.
    /// - Returns: An array of KeyInfo objects representing the information about the keys.
    /// - Throws: WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    public func getKeyInfos(keyType: VerifyAuthType) throws -> [KeyInfo] {
        return try walletCore.getKeyInfos(keyType: keyType)
    }
    
    /// Retrieves key information for the specified identifiers.
    ///
    /// This function checks if the wallet is locked. If it is locked, it throws an error.
    /// Otherwise, it retrieves key information for the provided list of IDs using the holderKeyManager.
    ///
    /// - Parameters:
    ///   - ids: An array of strings representing the identifiers for which to retrieve key information.
    /// - Throws: An error if the wallet is locked or if retrieving key information fails.
    /// - Returns: An array of `KeyInfo` objects corresponding to the provided identifiers.
    public func getKeyInfos(ids: [String]) throws -> [KeyInfo] {
        return try walletCore.getKeyInfos(ids: ids)
    }
    
    /// Checks if any keys are saved in the holder key manager.
    /// Throws an error if the wallet is locked.
    /// - Throws: WalletAPIError if the wallet is locked.
    /// - Returns: A Boolean value indicating whether any keys are saved.
    public func isAnyKeysSaved() throws -> Bool {
        return try walletCore.isAnyKeysSaved()
    }
    
    /// Changes the PIN for a specified wallet.
    /// - Parameters:
    ///   - id: The identifier for the wallet whose PIN is being changed.
    ///   - oldPIN: The current PIN that needs to be replaced.
    ///   - newPIN: The new PIN that will be set.
    /// - Throws: An error if the PIN change fails, such as if the old PIN is incorrect.
    public func changePin(id: String, oldPIN: String, newPIN: String) throws {
        try walletCore.changePin(id: id, oldPIN: oldPIN, newPIN: newPIN)
    }
}

private extension WalletAPI
{
    /// Revokes the specified ZKP credentials from the wallet using the provided wallet token.
    /// - Parameters:
    ///   - hWalletToken: The token associated with the wallet.
    ///   - ids: An array of identifiers for the credentials to revoke.
    /// - Returns: boolean value indicating whether the credentials were successfully revoked.
    /// - Throws: WalletApiError with VERIFY_TOKEN_FAIL error code if verification of the wallet token fails.
    private func deleteZKPCredentials(hWalletToken: String,
                                      ids: [String]) throws -> Bool
    {
        try self.walletToken.verifyWalletToken(hWalletToken: hWalletToken,
                                               purposes:[.REMOVE_VC])
        return try walletCore.deleteZKPCredential(ids: ids)
    }
}
