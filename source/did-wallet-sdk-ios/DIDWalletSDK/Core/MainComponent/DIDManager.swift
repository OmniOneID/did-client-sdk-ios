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



/// It manage the wallet stored DID document
struct DIDManager {
    
    typealias C = WalletCoreCommonError
    typealias E = DIDManagerError
    
    var storageManager: StorageManager<DIDMeta, DIDDocument>
    var didDoc: DIDDocument?
    
    //MARK: - Static Method
    
    /// Returns a random DID string including the `methodName`.
    /// - Parameter methodName: Method-name to use
    /// - Returns: DID string
    public static func genDID(methodName: String) throws -> String {
        if methodName.isEmpty ||
            methodName.count > 20 ||
            !(try! methodName.isMatched(with: "^[0-9a-z:]*$")) {
            throw C.invalidParameter(code: .didManager, name: "methodName").getError()
        }
        
        let count = 20
        var randomData = Data(count: count)
        let result = SecRandomCopyBytes(kSecRandomDefault, count, randomData.withUnsafeMutableBytes({ $0.baseAddress! }))
        
        if result != 0 {
            throw E.failToGenerateRandom.getError()
        }
        
        var id = MultibaseUtils.encode(type: .base58BTC, data: randomData)
        id.removeFirst()
        
        return "did:\(methodName):\(id)"
    }
    
    //MARK: - Instance Property
    
    /// Returns whether a DID document is saved in the wallet.
    public var isSaved: Bool {
        return storageManager.isSaved()
    }
    
    //MARK: - Instance Method
    
    /// Creates an instance of DIDManager that manages the DID document wallet.
    /// - Parameter fileName: The name of the wallet file to store the DID document
    public init(fileName: String) throws {
        if fileName.isEmpty {
            throw C.invalidParameter(code: .didManager, name: "fileName").getError()
        }

        storageManager = try .init(fileName: fileName, fileExtension: .did, isEncrypted: false)
    }
    
    /// Using parameters, create a "temporary DIDDocument object" and manage it as an internal variable.
    /// In this stage, it is not saved in the wallet.
    /// It can only be called when the return value of the isSaved API is false.
    /// - Parameters:
    ///   - did: User DID
    ///   - keyInfos: Array of public key information objects to register in the DID document
    ///   - controller: DID to register as controller in the DID document. If nil, the did field is used.
    ///   - service: Service information of DID document
    public mutating func createDocument(did: String, keyInfos: [DIDKeyInfo], controller: String?, service: [DIDDocument.Service]?) throws {
        if isSaved {
            throw E.documentAlreadyExists.getError()
        }
        
        if did.isEmpty {
            throw C.invalidParameter(code: .didManager, name: "did").getError()
        }
        
        if keyInfos.isEmpty {
            throw C.invalidParameter(code: .didManager, name: "keyInfos").getError()
        }
        
        if Set(keyInfos.map({ $0.keyInfo.id })).count != keyInfos.count {
            throw C.duplicateParameter(code: .didManager, name: "keyInfos.keyInfo.id").getError()
        }
        
        if let controller = controller, controller.isEmpty {
            throw C.invalidParameter(code: .didManager, name: "controller").getError()
        }
        
        if let service = service {
            if service.isEmpty {
                throw C.invalidParameter(code: .didManager, name: "service").getError()
            }
            
            if Set(service.map({ $0.id })).count != service.count {
                throw C.duplicateParameter(code: .didManager, name: "service.id").getError()
            }
        }
        
        let nowTime = Date.getUTC0Date(seconds: 0)
        
        didDoc = .init(id: did, controller: controller, created: nowTime)
        didDoc?.updated = nowTime
        didDoc?.service = service
        
        for keyInfo in keyInfos {
            appendVerificationMethod(didDoc: &didDoc!, didKeyInfo: keyInfo)
        }
    }
    
    /// Returns a "temporary DIDDocument object."
    /// If the "temporary DIDDocument object" is nil, returns the stored DID document.
    /// - Returns: DID document object
    func getDocument() throws -> DIDDocument {
        
        
        if var didDoc = didDoc {
            increaseVersionId(didDoc: &didDoc)
            
            return didDoc
        }
        
        return try loadSavedDocument()
    }
    
    /// Replaces the "temporary DIDDocument object" with the input object.
    /// - Parameters:
    ///   - didDocument: Replacement DID Document object
    ///   - needUpdate: Whether to update the updated attribute of the DID document object to the current time
    public mutating func replaceDocument(didDocument: DIDDocument, needUpdate: Bool) {
        didDoc = didDocument
        
        if needUpdate {
            modifyUpdatedWithNowTime(didDoc: &didDoc!)
        }
    }
    
    /// After saving the "Temporary DIDDocument Object" in the wallet file, it is initialized.
    /// If it is called with the "Temporary DIDDocument Object" being nil, meaning there are no changes to the already saved file, nothing happens. (This is not an error)
    public mutating func saveDocument() throws {
        guard let didDoc = didDoc else {
            return
        }
        
        if storageManager.isSaved() {
            var walletItem = try storageManager.getAllItems().first!
            
            if walletItem.meta.id != didDoc.id {
                try storageManager.removeAllItems()
                try storageManager.addItem(walletItem: .init(meta: .init(id: didDoc.id), item: didDoc))
                self.didDoc = nil
                return
            }
            
            walletItem.item = didDoc
            try storageManager.updateItem(walletItem: walletItem)
            self.didDoc = nil
        } else {
            try storageManager.addItem(walletItem: .init(meta: .init(id: didDoc.id), item: didDoc))
            self.didDoc = nil
        }
    }
    
    /// Deletes the stored wallet file.
    /// After deleting the file, initializes the “temporary DIDDocument object” to nil.
    public mutating func deleteDocument() throws {
        try storageManager.removeAllItems()
        didDoc = nil
    }
    
    /// Adds public key information to the "temporary DIDDocument object."
    /// It is primarily used when adding new public key information to a stored DID document.
    /// - Parameter keyInfo: Public key information object to register in the DID document
    public mutating func addVerificationMethod(keyInfo: DIDKeyInfo) throws {
        try prepareToEditDocument()
        
        if didDoc!.verificationMethod.contains(where: { $0.id == keyInfo.keyInfo.id }) {
            throw E.duplicateKeyIDExistsInVerificationMethod.getError()
        }
        
        appendVerificationMethod(didDoc: &didDoc!, didKeyInfo: keyInfo)
        modifyUpdatedWithNowTime(didDoc: &didDoc!)
    }
    
    /// Deletes the public key information in the "Temporary DIDDocument object."
    /// It is mainly used to delete public key information registered in the stored DID document.
    /// - Parameter keyId: ID of the public key information to be removed from the DID document
    public mutating func removeVerificationMethod(keyId: String) throws {
        if keyId.isEmpty {
            throw C.invalidParameter(code: .didManager, name: "keyId").getError()
        }
        
        try prepareToEditDocument()
        
        guard let index = didDoc!.verificationMethod.firstIndex(where: { $0.id == keyId } ) else {
            throw E.notFoundKeyIDInVerificationMethod.getError()
        }
        
        didDoc!.verificationMethod.remove(at: index)
        
        if let assertionMethod = didDoc!.assertionMethod {
            let keyIds = assertionMethod.filter({ $0 != keyId })
            didDoc!.assertionMethod = keyIds.isEmpty ? nil : keyIds
        }
        
        if let authentication = didDoc!.authentication {
            let keyIds = authentication.filter({ $0 != keyId })
            didDoc!.authentication = keyIds.isEmpty ? nil : keyIds
        }
        
        if let keyAgreement = didDoc!.keyAgreement {
            let keyIds = keyAgreement.filter({ $0 != keyId })
            didDoc!.keyAgreement = keyIds.isEmpty ? nil : keyIds
        }
        
        if let capabilityDelegation = didDoc!.capabilityDelegation {
            let keyIds = capabilityDelegation.filter({ $0 != keyId })
            didDoc!.capabilityDelegation = keyIds.isEmpty ? nil : keyIds
        }
        
        if let capabilityInvocation = didDoc!.capabilityInvocation {
            let keyIds = capabilityInvocation.filter({ $0 != keyId })
            didDoc!.capabilityInvocation = keyIds.isEmpty ? nil : keyIds
        }
        
        modifyUpdatedWithNowTime(didDoc: &didDoc!)
    }
    
    /// Adds service information to a "Temporary DIDDocument object".
    /// This is mainly used to add service information registered in the stored DID document.
    /// - Parameter service: Object of service information to be specified in the DID document
    public mutating func addService(service: DIDDocument.Service) throws {
        try prepareToEditDocument()
        
        if let serviceInDoc = didDoc!.service, serviceInDoc.contains(where: { $0.id == service.id }) {
            throw E.duplicateServiceIDExistsInService.getError()
        }
        
        if didDoc!.service == nil {
            didDoc!.service = .init()
        }
        
        didDoc!.service!.append(service)
        modifyUpdatedWithNowTime(didDoc: &didDoc!)
    }
    
    /// Deletes service information from the "temporary DIDDocument object".
    /// It is mainly used to delete service information registered in the stored DID document.
    /// - Parameter serviceId: Service ID to be deleted from the DID document
    public mutating func removeService(serviceId: String) throws {
        if serviceId.isEmpty {
            throw C.invalidParameter(code: .didManager, name: "serviceId").getError()
        }
        
        try prepareToEditDocument()
        
        if didDoc!.service == nil {
            throw E.notFoundServiceIDInService.getError()
        }
        
        guard let index = didDoc!.service!.firstIndex(where: { $0.id == serviceId } ) else {
            throw E.notFoundServiceIDInService.getError()
        }
        
        if didDoc!.service!.count > 1 {
            didDoc!.service!.remove(at: index)
        } else {
            didDoc!.service = nil
        }
        
        modifyUpdatedWithNowTime(didDoc: &didDoc!)
    }
    
    /// To reset changes, the "Temporary DIDDocument object" is initialized to nil.
    public mutating func resetChanges() {
        didDoc = nil
    }
}
//MARK: - Private methods
extension DIDManager
{
    /// Adds public key information to the "DIDDocument object" inputted.
    /// - Parameters:
    ///   - didDoc: The pointer of "DIDDocument object" variable to add information of public key
    ///   - didKeyInfo: Public key information object to register in the DID document
    private func appendVerificationMethod(didDoc: inout DIDDocument, didKeyInfo: DIDKeyInfo) {
        let type: DIDDocument.DIDKeyType = .convertFrom(algorithmType: didKeyInfo.keyInfo.algorithmType)
        
        addMethodType(keyId: didKeyInfo.keyInfo.id, methodType: didKeyInfo.methodType)

        let verificationMethod: DIDDocument.VerificationMethod = .init(id: didKeyInfo.keyInfo.id,
                                                                       type: type,
                                                                       controller: didKeyInfo.controller ?? didDoc.id,
                                                                       publicKeyMultibase: didKeyInfo.keyInfo.publicKey,
                                                                       authType: didKeyInfo.keyInfo.authType)
        
        didDoc.verificationMethod.append(verificationMethod)
        
        
        //MARK: Local function

        func addMethodType(keyId: String, methodType: DIDMethodType) {
            if methodType.contains(.assertionMethod) {
                addAssertionMethod(keyId: keyId)
            }
            
            if methodType.contains(.authentication) {
                addAuthentication(keyId: keyId)
            }
            
            if methodType.contains(.keyAgreement) {
                addKeyAgreement(keyId: keyId)
            }
            
            if methodType.contains(.capabilityDelegation) {
                addCapabilityDelegation(keyId: keyId)
            }
            
            if methodType.contains(.capabilityInvocation) {
                addCapabilityInvocation(keyId: keyId)
            }
        }
        
        func addAssertionMethod(keyId: String) {
            if didDoc.assertionMethod == nil {
                didDoc.assertionMethod = .init()
            }
            
            didDoc.assertionMethod?.append(keyId)
        }

        func addAuthentication(keyId: String) {
            if didDoc.authentication == nil {
                didDoc.authentication = .init()
            }
            
            didDoc.authentication?.append(keyId)
        }

        func addKeyAgreement(keyId: String) {
            if didDoc.keyAgreement == nil {
                didDoc.keyAgreement = .init()
            }
            
            didDoc.keyAgreement?.append(keyId)
        }

        func addCapabilityInvocation(keyId: String) {
            if didDoc.capabilityInvocation == nil {
                didDoc.capabilityInvocation = .init()
            }
            
            didDoc.capabilityInvocation?.append(keyId)
        }

        func addCapabilityDelegation(keyId: String) {
            if didDoc.capabilityDelegation == nil {
                didDoc.capabilityDelegation = .init()
            }
            
            didDoc.capabilityDelegation?.append(keyId)
        }

    }
    
    /// Check if "Temporary DIDDocument Object" is editable status.
    private mutating func prepareToEditDocument() throws {
        if didDoc == nil, !isSaved {
            throw E.notFoundDocument.getError()
        }
        
        if didDoc == nil {
            didDoc = try getDocument()
        }
    }
    
    /// Update the updated field of "DIDDocument object" inputted with current date and time.
    /// - Parameter didDoc: The pointer of "DIDDocument object" variable to add information of public key
    private func modifyUpdatedWithNowTime(didDoc: inout DIDDocument) {
        didDoc.updated = Date.getUTC0Date(seconds: 0)
    }
    
    /// Increase the document's version by saved one
    /// If the document didn't saved,
    /// nothing happens
    private func increaseVersionId(didDoc: inout DIDDocument)
    {
        if !isSaved { return }
        
        let savedDoc = try! loadSavedDocument()
        
        var versionId = Int(savedDoc.versionId)!
        versionId += 1
        didDoc.versionId = String(versionId)
    }
    
    /// Load saved document
    private func loadSavedDocument() throws -> DIDDocument {
        if isSaved, let savedDidDoc = try storageManager.getAllItems().first?.item {
            return savedDidDoc
        }
        
        throw E.notFoundDocument.getError()
    }
}
