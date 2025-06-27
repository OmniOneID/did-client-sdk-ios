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

/// It manage the wallet file
struct StorageManager<M, T> where M: MetaProtocol, T: Codable {
    
    typealias C = WalletCoreCommonError
    typealias E = StorageManagerError
    
    enum FileExtension: String {
        case key
        case did
        case vc
        case zkp
    }
    
    struct ExternalWallet: Codable {
        var isEncrypted: Bool
        var data: String
        var version: UInt
        var signature: String?
    }
    
    struct StorableInnerWalletItem: Codable {
        var meta: M
        var item: String
    }
    
    struct UsableInnerWalletItem: Codable {
        var meta: M
        var item: T
    }
    
    static var version: UInt {
        return 1
    }
    
    //MARK: - Private properties
    
    private static var rootDirName: String {
        return "opendid_omnione"
    }
    
    private static var rootPath: URL {
        var documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if #available(iOS 16.0, *)
        {
            documentPath.append(component: Self.rootDirName)
        }
        else
        {
            documentPath.appendPathComponent(Self.rootDirName)
        }
        
        return documentPath
    }
    
    private static var keyGroup: String {
        return "StorageManager"
    }
    
    private static var keyIdentifier: String {
        return "signatureKey"
    }
    
    private var fileName: String
    private var fileExtension: FileExtension
    private var isEncrypted: Bool
    
    private var fileNameWithExt: String {
        return "\(fileName).\(fileExtension.rawValue)"
    }
    
    private var filePathURL: URL {
        var documentPath = Self.rootPath
        
        if #available(iOS 16.0, *)
        {
            documentPath.append(component: fileNameWithExt)
        }
        else
        {
            documentPath.appendPathComponent(fileNameWithExt)
        }
        return documentPath

    }
    
    private let jsonEncoder: JSONEncoder
    
    //MARK: - Methods
    
    /// Create an instance of StorageManager that manage the wallet file
    /// - Parameters:
    ///   - fileName: The name of wallet file
    ///   - fileExtension: The extension of wallet file
    ///   - isEncrypted: The flag whether wallet file is encrypted
    init(fileName: String, fileExtension: FileExtension, isEncrypted: Bool) throws {
        if fileName.isEmpty {
            throw C.invalidParameter(code: .storageMaanger, name: "fileName").getError()
        }
        
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.isEncrypted = isEncrypted
        
        jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    }
    
    /// Returns whether the saved wallet file exist
    /// - Returns: Whether the saved wallet file exist
    func isSaved() -> Bool {
        return (try? Data(contentsOf: filePathURL)) != nil
    }
    
    /// Add wallet item data at wallet file
    /// - Parameter walletItem: The wallet item to add at wallet file
    func addItem(walletItem: UsableInnerWalletItem) throws {
        var savedItems: [StorableInnerWalletItem]
        
        if isSaved() {
            savedItems = try getAllInnerWalletItems()
            
            for savedItem in savedItems {
                if savedItem.meta.id == walletItem.meta.id {
                    throw E.itemDuplicatedWithItInWallet.getError()
                }
            }
        } else {
            savedItems = .init()
        }
        
        let encoded = try encodeItem(item: walletItem.item)
        savedItems.append(.init(meta: walletItem.meta, item: encoded))
        
        try saveItems(walletItems: savedItems)
    }
    
    /// Update wallet item data at wallet file
    /// - Parameter walletItem: The wallet item to update at wallet file
    func updateItem(walletItem: UsableInnerWalletItem) throws {
        var savedItems = try getAllInnerWalletItems()
        
        guard let matchedIndex = savedItems.firstIndex(where: { $0.meta.id == walletItem.meta.id }) else {
            throw E.noItemToUpdate.getError()
        }
        
        let encoded = try encodeItem(item: walletItem.item)
        let walletItem = StorableInnerWalletItem(meta: walletItem.meta, item: encoded)
        
        savedItems.replaceSubrange(matchedIndex...matchedIndex, with: [walletItem])
        
        try saveItems(walletItems: savedItems)
    }
    
    /// Remove wallet item data from wallet file
    /// If the wallet file not exist, throw some error
    /// - Parameter identifiers: The wallet item identifiers to update from wallet file
    func removeItems(by identifiers: [String]) throws {
        if identifiers.count == 0 {
            throw C.invalidParameter(code: .storageMaanger, name: "identifiers").getError()
        }
        
        if Set(identifiers).count != identifiers.count {
            throw C.duplicateParameter(code: .storageMaanger, name: "identifiers").getError()
        }
        
        let walletItems = try getAllInnerWalletItems()
        
        let remainedItemsAfterRemove = walletItems.filter({ !identifiers.contains($0.meta.id) })
        
        guard remainedItemsAfterRemove.count == (walletItems.count - identifiers.count) else {
            throw E.noItemsToRemove.getError()
        }
        
        if remainedItemsAfterRemove.count == 0 {
            try removeAllItems()
        } else {
            try saveItems(walletItems: remainedItemsAfterRemove)
        }
    }
    
    /// Removes all of wallet item data from wallet file
    /// If the wallet file not exist, throw some error
    func removeAllItems() throws {
        guard isSaved() else {
            throw E.noItemsSaved.getError()
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePathURL.path)
        } catch {
            throw E.failToRemoveItems(error).getError()
        }
    }
    
    /// Get wallet item meta data from wallet file
    /// - Parameter identifiers: The wallet item identifiers to get metas from wallet file
    /// - Returns: The array of wallet item meta
    func getMetas(by identifiers: [String]) throws -> [M] {
        if identifiers.count == 0 {
            throw C.invalidParameter(code: .storageMaanger, name: "identifiers").getError()
        }
        
        if Set(identifiers).count != identifiers.count {
            throw C.duplicateParameter(code: .storageMaanger, name: "identifiers").getError()
        }
        
        let walletItems = try getAllInnerWalletItems()
        
        let filteredMetas: [M] = walletItems.compactMap {
            if !identifiers.contains($0.meta.id) {
                return nil
            }
            
            return $0.meta
        }
        
        guard filteredMetas.count == identifiers.count else {
            throw E.noItemsToFind.getError()
        }
        
        return filteredMetas
    }
    
    /// Get all of wallet item meta data from wallet file
    /// - Returns: The array of wallet item meta object
    func getAllMetas() throws -> [M] {
        guard isSaved() else {
            throw E.noItemsSaved.getError()
        }
        
        return (try getAllInnerWalletItems()).map { $0.meta }
    }
    
    /// Get wallet item data from wallet file
    /// - Parameter identifiers: The wallet item identifiers to get items from wallet file
    /// - Returns: The array of wallet item
    func getItems(by identifiers: [String]) throws -> [UsableInnerWalletItem] {
        if identifiers.count == 0 {
            throw C.invalidParameter(code: .storageMaanger, name: "identifiers").getError()
        }
        
        if Set(identifiers).count != identifiers.count {
            throw C.duplicateParameter(code: .storageMaanger, name: "identifiers").getError()
        }
        
        let walletItems = try getAllInnerWalletItems()
        
        let filteredWalletItems: [UsableInnerWalletItem] = try walletItems.compactMap {
            if !identifiers.contains($0.meta.id) {
                return nil
            }
            
            return try convertToUsableInnerWalletItem(walletItem: $0)
        }
        
        guard filteredWalletItems.count == identifiers.count else {
            throw E.noItemsToFind.getError()
        }

        return filteredWalletItems
    }
    
    /// Get all of wallet item data from wallet file
    /// - Returns: The array of wallet item
    func getAllItems() throws -> [UsableInnerWalletItem] {
        return try getAllInnerWalletItems()
            .map { try convertToUsableInnerWalletItem(walletItem: $0) }
    }
    
    //MARK: - Private methods
    
    private func readExternalWallet() throws -> ExternalWallet {
        if !isSaved() {
            throw E.noItemsSaved.getError()
        }
        
        let walletData: Data
        
        do {
            walletData = try Data(contentsOf: filePathURL)
        } catch {
            throw E.failToReadWalletFile(error).getError()
        }
        
        let externalWallet: ExternalWallet
        
        do {
            externalWallet = try JSONDecoder().decode(ExternalWallet.self, from: walletData)
        } catch {
            throw E.malformedExternalWallet(error).getError()
        }
        
        guard let signature = externalWallet.signature?.decodeBase64() else {
            throw C.failToDecode(code: .storageMaanger, name: "externalWallet.signature").getError()
        }
        
        let publicKey = try SecureEnclaveManager.getPublicKey(group: Self.keyGroup, identifier: Self.keyIdentifier)
        
        var tempWallet = externalWallet
        tempWallet.signature = nil
        
        let digest: Data
        
        do {
            digest = try jsonEncoder.encode(tempWallet).sha256()
        } catch {
            throw E.unexpectedError(error).getError()
        }
        
        guard try SecureEnclaveManager.verify(publicKey: publicKey, digest: digest, signature: signature) else {
            throw E.malformedWalletSignature.getError()
        }
        
        return externalWallet
    }
    
    private func saveItems(walletItems: [StorableInnerWalletItem]) throws {
        var externalWallet: ExternalWallet
        
        if isSaved() {
            externalWallet = try readExternalWallet()
            externalWallet.signature = nil
        } else {
            externalWallet = .init(isEncrypted: isEncrypted, data: "", version: Self.version, signature: nil)
        }
        
        let data: Data
        
        do {
            data = try jsonEncoder.encode(walletItems)
        } catch {
            throw E.unexpectedError(error).getError()
        }
        
        externalWallet.data = data.base64EncodedString()
        
        let digest = try jsonEncoder.encode(externalWallet).sha256()
        
        if !SecureEnclaveManager.isKeySaved(group: Self.keyGroup, identifier: Self.keyIdentifier) {
            try SecureEnclaveManager.generateKey(group: Self.keyGroup, identifier: Self.keyIdentifier, accessMethod: .none)
        }

        let signature = try SecureEnclaveManager.sign(group: Self.keyGroup, identifier: Self.keyIdentifier, digest: digest)
        externalWallet.signature = signature.base64EncodedString()
        
        var result: Data!
        
        do {
            result = try jsonEncoder.encode(externalWallet)
            
            if !isSaved() {
                try FileManager.default.createDirectory(at: Self.rootPath, withIntermediateDirectories: true)
            }
            
            try result.write(to: filePathURL)
        } catch {
            if result == nil {
                throw E.unexpectedError(error).getError()
            } else {
                throw E.failToSaveWallet(error).getError()
            }
        }
        
    }
    
    private func getAllInnerWalletItems() throws -> [StorableInnerWalletItem] {
        let externalWallet = try readExternalWallet()
        
        guard let decoded = externalWallet.data.decodeBase64() else {
            throw C.failToDecode(code: .storageMaanger, name: "externalWallet.data").getError()
        }
        
        let result: [StorableInnerWalletItem]
        
        do {
            result = try JSONDecoder().decode([StorableInnerWalletItem].self, from: decoded)
        } catch {
            throw E.malformedInnerWallet(error).getError()
        }
        
        return result
    }
    
    private func convertToUsableInnerWalletItem(walletItem: StorableInnerWalletItem) throws -> UsableInnerWalletItem {
        guard var decoded = walletItem.item.decodeBase64() else {
            throw C.failToDecode(code: .storageMaanger, name: "innerWalletItem.item").getError()
        }
        
        if isEncrypted {
            decoded = try SecureEncryptor.decrypt(cipherData: decoded)
        }
        
        let item: T
        
        do {
            item = try JSONDecoder().decode(T.self, from: decoded)
        } catch {
            throw E.malformedItemType(error).getError()
        }
        
        return UsableInnerWalletItem(meta: walletItem.meta, item: item)
    }
    
    private func encodeItem(item: T) throws -> String {
        var data: Data
        
        do {
            data = try jsonEncoder.encode(item)
        } catch {
            throw E.unexpectedError(error).getError()
        }
        
        if isEncrypted {
            data = try SecureEncryptor.encrypt(plainData: data)
        }
        
        return data.base64EncodedString()
    }
    
}
