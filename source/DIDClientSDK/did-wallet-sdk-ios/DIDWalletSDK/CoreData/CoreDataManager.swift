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
import CoreData

class CoreDataManager {
    
    public static let shared = CoreDataManager()
    let identifier: String  = "org.omnione.did.sdk.wallet"
    let model: String       = "WalletModel"
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { (storeDescription, error) in
        
            if let err = error{
                fatalError("Loading of store failed:\(err)")
            }
            WalletLogger.shared.debug("succeed")
        }
        
        return container
    }()
    
    @discardableResult
    public func insertCaPakage(pkgName: String) throws -> Bool {
            
        let context = persistentContainer.viewContext
        let ca = NSEntityDescription.insertNewObject(forEntityName: "CaEntity", into: context) as! CaEntity
        ca.idx = UUID().uuidString
        ca.pkgName = pkgName
        ca.createDate = Date.getUTC0Date(seconds: 0)
        
//        do {
            if context.hasChanges {
                try context.save()
            }
            WalletLogger.shared.debug("Ca saved succesfully")
            WalletLogger.shared.debug("CaAppId \(String(describing: ca.idx)): \(String(describing: ca.pkgName)) \(String(describing: ca.createDate))")
            return true
            
//        } catch let error {
//            print("Failed to insert Ca: \(error.localizedDescription)")
//        }
//        return false
    }
    
    public func selectCaPakage() throws -> Ca? {
            
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CaEntity>(entityName: "CaEntity")
        
//        do {
            let cas = try context.fetch(fetchRequest)
            for (_, ca) in cas.enumerated() {
                WalletLogger.shared.debug("CaAppId \(String(describing: ca.idx)): \(String(describing: ca.pkgName)) \(String(describing: ca.createDate))")
                return Ca(idx: ca.idx!, createDate: ca.createDate!, pkgName: ca.pkgName!)
            }
            
//        } catch let fetchErr {
//            print("Failed to fetch Person:",fetchErr)
//        }
//        
        return nil
    }
    
    @discardableResult
    public func deleteCaPakage() throws -> Bool {
        
        let context = persistentContainer.viewContext
        // 모든 데이터 요청
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CaEntity")

//        do {
            let objects = try context.fetch(fetchRequest)
            for case let object as NSManagedObject in objects {
                context.delete(object) // 데이터 삭제
            }
            try context.performAndWait {
                if context.hasChanges {
                    try context.save() // 변경 사항 저장
                }
            }
            return true
//        } catch {
//            print("Delete failed: \(error.localizedDescription)")
//        }
//        
//        return false
    }
    
    @discardableResult
    public func insertToken(walletId: String, hWalletToken: String, purpose: String, pkgName: String, nonce: String, pii: String) throws -> Bool {
        try deleteToken()
        let context = persistentContainer.viewContext
        let token = NSEntityDescription.insertNewObject(forEntityName: "TokenEntity", into: context) as! TokenEntity
        token.idx = UUID().uuidString
        token.walletId = walletId
        token.hWalletToken = hWalletToken
        token.purpose = purpose
        token.pkgName = pkgName
        token.nonce = nonce
        token.pii = pii
        token.validUntil = Date.getUTC0Date(seconds: 60 * 30)
        token.createDate = Date.getUTC0Date(seconds: 0)
        
//        do {
        try context.performAndWait {
            if context.hasChanges {
                try context.save() // 변경 사항 저장
            }
        }
        WalletLogger.shared.debug("token saved succesfully")
        WalletLogger.shared.debug("save Token idx: \(String(describing: token.idx)) pkgName: \(String(describing: token.pkgName)) walletId: \(String(describing: token.walletId)) hWalletToken: \(String(describing: token.hWalletToken)) nonce: \(String(describing: token.nonce)) pii: \(String(describing: token.pii)) validUntil:  \(String(describing: token.validUntil)) createDate: \(String(describing: token.createDate)) purpose: \(String(describing: token.purpose))")
        return true
//        } catch let error {
//            print("Failed to insert token: \(error.localizedDescription)")
//        }
//        return false
    }
    
    public func selectToken() throws -> Token? {
            
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TokenEntity>(entityName: "TokenEntity")
        
//        do {
            let tokens = try context.fetch(fetchRequest)
            for (_, token) in tokens.enumerated() {
                WalletLogger.shared.debug("select Token idx: \(String(describing: token.idx)) pkgName: \(String(describing: token.pkgName)) walletId: \(String(describing: token.walletId)) hWalletToken: \(String(describing: token.hWalletToken)) nonce: \(String(describing: token.nonce)) pii: \(String(describing: token.pii)) validUntil:  \(String(describing: token.validUntil)) createDate: \(String(describing: token.createDate)) purpose: \(String(describing: token.purpose))")
                
                return Token(idx: token.idx!, walletId: token.walletId!, hWalletToken: token.hWalletToken!, validUntil: token.validUntil!, purpose: token.purpose!, nonce: token.nonce!, pkgName: token.pkgName!, pii: token.pii!, createDate: token.createDate!)
            }
            
//        } catch let fetchErr {
//            print("Failed to fetch Person:",fetchErr)
//        }
//        
        return nil
    }
    
    @discardableResult
    public func deleteToken() throws -> Bool {
        
        let context = persistentContainer.viewContext
        // 모든 데이터 요청
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TokenEntity")
        
//        do {
            let objects = try context.fetch(fetchRequest)
            for case let object as NSManagedObject in objects {
                context.delete(object) // 데이터 삭제
            }
            
            try context.performAndWait {
                if context.hasChanges {
                    try context.save() // 변경 사항 저장
                }
            }
                
            return true
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
        
//        return false
    }
    
    @discardableResult
    public func insertUser(finalEncKey: String, pii: String) throws -> Bool {
            
        try self.deleteUser()
        
        let context = persistentContainer.viewContext
        let user = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: context) as! UserEntity
        user.idx = UUID().uuidString
        user.finalEncKey = finalEncKey
        user.pii = pii
        user.createDate = Date.getUTC0Date(seconds: 0)
        user.updateDate = Date.getUTC0Date(seconds: 0)
        
//        do {
            if context.hasChanges {
                try context.save()
            }
            WalletLogger.shared.debug("user saved succesfully")
            WalletLogger.shared.debug("save User idx: \(String(describing: user.idx)) pii: \(String(describing: user.pii)) createDate: \(String(describing: user.createDate)) updateDate: \(String(describing: user.updateDate)) finalEncKey: \(String(describing: user.finalEncKey)) ")
            return true
//        } catch {
//            print("Failed to insert user: \(error.localizedDescription)")
//        }
//        return false
    }
    
    public func selectUser() throws -> User? {
            
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        
//        do {
            let users = try context.fetch(fetchRequest)
            for (_, user) in users.enumerated() {
                WalletLogger.shared.debug("select User idx: \(String(describing: user.idx)) pii: \(String(describing: user.pii)) createDate: \(String(describing: user.createDate)) updateDate: \(String(describing: user.updateDate)) finalEncKey: \(String(describing: user.finalEncKey))")
                
                return User(idx: user.idx ?? "", pii: user.pii ?? "", finalEncKey: user.finalEncKey ?? "", createDate: user.createDate ?? "", updateDate: user.updateDate ?? "")
            }
            
//        } catch let fetchErr {
//            print("Failed to select Person:",fetchErr)
//        }
//        
        return nil
    }
    
    @discardableResult
    public func updateUser(finalEncKey: String) throws -> Bool {

        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        fetchRequest.predicate = NSPredicate(format: "finalEncKey == %@", "")

//        do {
            let users = try context.fetch(fetchRequest)
            
            if let user = users.first {
                WalletLogger.shared.debug("updateUser finalEncKey: \(finalEncKey)")
                user.finalEncKey = finalEncKey
            }
            if context.hasChanges {
                try context.save()
            }
            return true
//        } catch {
//            print("Failed to update finalCek value: \(error.localizedDescription)")
//        }
//        return false
    }
    
    @discardableResult
    public func deleteUser() throws -> Bool {
        
        let context = persistentContainer.viewContext
        // 모든 데이터 요청
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")

//        do {
            let objects = try context.fetch(fetchRequest)
            for case let object as NSManagedObject in objects {
                context.delete(object) // 데이터 삭제
            }
            if context.hasChanges {
                try context.save() // 변경 사항 저장
            }
            return true
//        } catch {
//            print("Delete failed: \(error.localizedDescription)")
//        }
//        
//        return false
    }
}
