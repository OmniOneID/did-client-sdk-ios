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


/// It manage the wallet stored VC
struct VCManager {
    
    typealias C = WalletCoreCommonError
    typealias E = VCManagerError
    
    var storageManager: StorageManager<VCInternalMeta, VerifiableCredential>
    
    
    /// Check if there is at least one saved VC. (Verify the existence of the VC wallet)
    public var isAnyCredentialsSaved: Bool {
        return storageManager.isSaved()
    }
    
    /// Creates an instance of VCManager to manage the VC wallet.
    /// - Parameter fileName: Name of the wallet file to store the VC
    public init(fileName: String) throws {
        if fileName.isEmpty {
            throw C.invalidParameter(code: .vcManager, name: "fileName").getError()
        }

        storageManager = try .init(fileName: fileName, fileExtension: .vc, isEncrypted: true)
    }
    
    /// Store VC in the wallet.
    /// - Parameter credential: VC Object
    func addCredential(credential: VerifiableCredential) throws {
        try storageManager.addItem(walletItem: .init(meta: .init(id: credential.id), item: credential))
    }
    
    /// Returns all VCs from the wallet that match the `identifiers`.
    /// - Parameter identifiers: Array of VC IDs
    /// - Returns: Array of VC objects
    func getCredentials(by identifiers: [String]) throws -> [VerifiableCredential] {
        if identifiers.isEmpty {
            throw C.invalidParameter(code: .vcManager, name: "identifiers").getError()
        }
        
        if identifiers.count != Set(identifiers).count {
            throw C.duplicateParameter(code: .vcManager, name: "identifiers").getError()
        }
        
        return try storageManager.getItems(by: identifiers).map { $0.item }
    }
    
    /// Returns all VCs stored in the wallet.
    /// - Returns: Array of VC objects
    func getAllCredentials() throws -> [VerifiableCredential] {
        return try storageManager.getAllItems().map { $0.item }
    }
    
    /// Deletes all VCs in the wallet that match the `identifiers`.
    /// - Parameter identifiers: Array of VC IDs
    func deleteCredentials(by identifiers: [String]) throws {
        if identifiers.isEmpty {
            throw C.invalidParameter(code: .vcManager, name: "identifiers").getError()
        }
        
        if identifiers.count != Set(identifiers).count {
            throw C.duplicateParameter(code: .vcManager, name: "identifiers").getError()
        }
        
        try storageManager.removeItems(by: identifiers)
    }
    
    /// Deletes the wallet where the VC is stored.
    func deleteAllCredentials() throws {
        try storageManager.removeAllItems()
    }
    
    /// Returns a VP (VerifiablePresentation) object without Proof.
    /// - Parameters:
    ///   - claimInfos: VC information to use for creating VP
    ///   - presentationInfo: Meta information to use for VP creation
    /// - Returns: VP object
    func makePresentation(claimInfos: [ClaimInfo], presentationInfo: PresentationInfo) throws -> VerifiablePresentation {
        if claimInfos.isEmpty {
            throw C.invalidParameter(code: .vcManager, name: "claimInfos").getError()
        }
        
        let credentialIds = claimInfos.map({ $0.credentialId })
        
        let credentials = try storageManager.getItems(by: credentialIds).map { $0.item }
        
        var credentialsToPresent: [VerifiableCredential] = .init()
        
        for credential in credentials {
            let claimCodes = claimInfos.filter({ $0.credentialId == credential.id }).first!.claimCodes
            
            if Set(claimCodes).count != claimCodes.count {
                throw C.duplicateParameter(code: .vcManager, name: "claimInfos.claimCodes").getError()
            }
            
            var index: Int = -1
            var tempCredential = credential
            var tempProof = credential.proof
            tempProof.proofValue = nil
            tempProof.proofValueList = .init()
            
            let codesInCredential = Set(credential.credentialSubject.claims.map({ $0.code }))
            
            let reaminingCodes = Set(claimCodes).subtracting(codesInCredential)
            
            if !reaminingCodes.isEmpty {
                let code = reaminingCodes.joined(separator: ", ")
                throw VCManagerError.noClaimCodeInCredentialForPresentation(code: code).getError()
            }
            
            let claimsToPresent = credential.credentialSubject.claims.filter({
                
                index += 1
                
                if claimCodes.contains($0.code) {
                    tempProof.proofValueList!.append(credential.proof.proofValueList![index])
                    return true
                } else {
                    return false
                }
                
            })
            
            tempCredential.credentialSubject.claims = claimsToPresent
            tempCredential.proof = tempProof
            
            credentialsToPresent.append(tempCredential)
        }
        
        return VerifiablePresentation(holder: presentationInfo.holder, validFrom: presentationInfo.validFrom, validUntil: presentationInfo.validUntil, verifierNonce: presentationInfo.verifierNonce, verifiableCredential: credentialsToPresent)
    }
    
}
