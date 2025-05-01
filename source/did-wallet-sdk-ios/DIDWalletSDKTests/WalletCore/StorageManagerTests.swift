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

import XCTest
@testable import DIDWalletSDK

final class StorageManagerTests: XCTestCase {
    enum TestError: Error {
        case error(msg: String)
    }
    
    typealias M = DIDMeta
    typealias T = DIDDocument
    typealias SM = StorageManager<M, T>

    let fileName = "test"
    let fileExt: SM.FileExtension = .did
    let isEncrypted = false
    let version: UInt = 1

    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    override func setUpWithError() throws {
        jsonEncoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddItem() throws {
        let storageManager: SM = try StorageManager(fileName: fileName, fileExtension: fileExt, isEncrypted: isEncrypted)
        
        if storageManager.isSaved() {
            try storageManager.removeAllItems()
        }
        
        let item: DIDDocument = getTestDIDDoc()
        let meta: DIDMeta = .init(id: item.id)
        let usableInnerWalletItem: SM.UsableInnerWalletItem = .init(meta: meta, item: item)
        
        try storageManager.addItem(walletItem: usableInnerWalletItem)
        
        let storableInnerWalletItems: [SM.StorableInnerWalletItem] = try getWalletItemsFromWalletFile()
        
        guard let walletItem = storableInnerWalletItems.first else {
            XCTAssert(false, "Not saved wallet item on wallet file")
            return
        }
        
        XCTAssert(try walletItem.meta.equals(other: usableInnerWalletItem.meta), "Incorrect meta data")
        
        guard let decodedItem = walletItem.item.decodeBase64() else {
            XCTAssert(false, "It failed to decode item data to base64")
            return
        }
        
        guard let item: T = try? .init(from: decodedItem) else {
            XCTAssert(false, "It failed to decode to \(T.self) type")
            return
        }
        
        XCTAssert(try item.equals(other: usableInnerWalletItem.item), "Incorrect item data")
    }
    
    func testUpdateItem() throws {
        let (storageManager, usableInnerWalletItemOrigin) = try getStorageManagerThatHasOneItem()
        
        let updatedVersionId = "\(UInt(usableInnerWalletItemOrigin.item.versionId)! + 1)"
        var usableInnerWalletItemToUpdate = usableInnerWalletItemOrigin
        usableInnerWalletItemToUpdate.item.versionId = updatedVersionId
        
        try storageManager.updateItem(walletItem: usableInnerWalletItemToUpdate)
        
        let storableInnerWalletItems: [SM.StorableInnerWalletItem] = try getWalletItemsFromWalletFile()
        
        guard let walletItem = storableInnerWalletItems.first else {
            XCTAssert(false, "Not saved wallet item on wallet file")
            return
        }
        
        XCTAssert(try walletItem.meta.equals(other: usableInnerWalletItemToUpdate.meta), "Incorrect meta data")
        
        guard let decodedItem = walletItem.item.decodeBase64() else {
            XCTAssert(false, "It failed to decode item data to base64")
            return
        }
        
        guard let item: T = try? .init(from: decodedItem) else {
            XCTAssert(false, "It failed to decode to \(T.self) type")
            return
        }
        
        XCTAssert(try item.equals(other: usableInnerWalletItemToUpdate.item), "Incorrect item data")
    }

    func testRemoveItems() throws {
        let (storageManager, innerWalletItemOrigin) = try getStorageManagerThatHasOneItem()
        
        let itemId = innerWalletItemOrigin.meta.id
        
        try storageManager.removeItems(by: [itemId])
        
        if let _ = getWalletFileData() {
            XCTAssert(false, "It failed to remove wallet file")
        }
    }

    func testRemoveAllItems() throws {
        let (storageManager, _) = try getStorageManagerThatHasOneItem()
                
        try storageManager.removeAllItems()
        
        if let _ = getWalletFileData() {
            XCTAssert(false, "It failed to remove wallet file")
        }
    }

    func testGetMetas() throws {
        let (storageManager, innerWalletItemOrigin) = try getStorageManagerThatHasOneItem()
        
        let itemId = innerWalletItemOrigin.meta.id
        
        let metas = try storageManager.getMetas(by: [itemId])

        XCTAssertEqual(metas.count, 1)
        
        guard let meta = metas.first else {
            XCTAssert(false, "Not found meta data read from wallet file")
            return
        }
        
        XCTAssert(try meta.equals(other: innerWalletItemOrigin.meta))
    }

    func testGetAllMetas() throws {
        let (storageManager, innerWalletItemOrigin) = try getStorageManagerThatHasOneItem()
        
        let metas = try storageManager.getAllMetas()

        XCTAssertEqual(metas.count, 1)
        
        guard let meta = metas.first else {
            XCTAssert(false, "Not found meta data read from wallet file")
            return
        }
        
        XCTAssert(try meta.equals(other: innerWalletItemOrigin.meta))
    }

    func testGetItems() throws {
        let (storageManager, innerWalletItemOrigin) = try getStorageManagerThatHasOneItem()
        
        let itemId = innerWalletItemOrigin.meta.id
        
        let walletItems = try storageManager.getItems(by: [itemId])
        
        XCTAssertEqual(walletItems.count, 1)

        guard let walletItem = walletItems.first else {
            XCTAssert(false, "Not found item data read from wallet file")
            return
        }
        
        XCTAssert(try walletItem.equals(other: innerWalletItemOrigin))
    }

    func testGetAllItems() throws {
        let (storageManager, innerWalletItemOrigin) = try getStorageManagerThatHasOneItem()
        
        let walletItems = try storageManager.getAllItems()
        
        XCTAssertEqual(walletItems.count, 1)

        guard let walletItem = walletItems.first else {
            XCTAssert(false, "Not found item data read from wallet file")
            return
        }
        
        XCTAssert(try walletItem.equals(other: innerWalletItemOrigin))
    }
    
    //MARK: - Utility Method for test
    
    func getTestDIDDoc() -> DIDDocument {
        return try! DIDDocument.init(from: didDocJson)
    }
    
    func getStorageManagerThatHasOneItem() throws -> (StorageManager<DIDMeta, DIDDocument>, StorageManager<DIDMeta, DIDDocument>.UsableInnerWalletItem) {
        typealias SM = StorageManager<DIDMeta, DIDDocument>
        
        let fileName = "test"
        let fileExt: SM.FileExtension = .did
        let isEncrypted = false
        let storageManager: SM = try StorageManager(fileName: fileName, fileExtension: fileExt, isEncrypted: isEncrypted)

        if storageManager.isSaved() {
            try storageManager.removeAllItems()
        }
        
        let item: DIDDocument = getTestDIDDoc()
        let meta: DIDMeta = .init(id: item.id)
        let usableInnerWalletItem: SM.UsableInnerWalletItem = .init(meta: meta, item: item)
        
        try storageManager.addItem(walletItem: usableInnerWalletItem)
        
        return (storageManager, usableInnerWalletItem)
    }
    
    func getWalletItemsFromWalletFile() throws -> [SM.StorableInnerWalletItem] {
        guard let walletDataFromFile = getWalletFileData() else {
            throw TestError.error(msg: "It failed to add item at wallet")
        }
        
        var externalWallet = try jsonDecoder.decode(SM.ExternalWallet.self, from: walletDataFromFile)
        
        if externalWallet.isEncrypted != isEncrypted {
            throw TestError.error(msg: "It's different isEncrypted value with it from wallet file")
        }

        if externalWallet.version != version {
            throw TestError.error(msg: "It's different version value with it from wallet file")
        }

        guard let signature = externalWallet.signature?.decodeBase64() else {
            throw TestError.error(msg: "It failed to decode signature of external wallet")
        }
        
        externalWallet.signature = nil
        
        let publicKey = try SecureEnclaveManager.getPublicKey(group: "StorageManager", identifier: "signatureKey")
        
        let digest = try jsonEncoder.encode(externalWallet).sha256()
        
        let isVerified = try SecureEnclaveManager.verify(publicKey: publicKey, digest: digest, signature: signature)
        
        if !isVerified {
            throw TestError.error(msg: "It failed to verify signature of wallet")
        }
        
        guard let decodedStorableInnerWalletItem = externalWallet.data.decodeBase64() else {
            throw TestError.error(msg: "It failed to decode signature of inner wallet item")
        }
        
        let storableInnerWalletItems = try jsonDecoder.decode([SM.StorableInnerWalletItem].self, from: decodedStorableInnerWalletItem)
        
        return storableInnerWalletItems
    }
    
    func getWalletFileData() -> Data? {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentPath.appending(components: "opendid_omnione", "\(fileName).\(fileExt.rawValue)")

        return try? Data(contentsOf: filePath)
    }
}
