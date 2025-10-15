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
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let identifier: String = "org.omnione.did.sdk.wallet"
    private let modelName: String  = "WalletModel"
    
    // MARK: - Persistent Container
    private(set) lazy var container: NSPersistentContainer = {
        guard
            let bundle = Bundle(identifier: identifier),
            let modelURL = bundle.url(forResource: modelName, withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Failed to load Core Data model \(modelName) from bundle \(identifier)")
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        
        // Stability & concurrency-friendly options
        let desc = container.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
        // WAL improves concurrency; safer under frequent writes
        desc.setOption(["journal_mode": "wal"] as NSDictionary, forKey: NSSQLitePragmasOption)
        // Keep for extensions/multi-process sync safety (optional but helpful)
        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions = [desc]
        
        container.loadPersistentStores { _, error in
            if let error { fatalError("Loading of store failed: \(error)") }
            WalletLogger.shared.debug("persistent store load succeed")
        }
        
        // View (main/UI) context: read/light edits only; auto-merge from writer
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        
        return container
    }()
    
    // MARK: - Contexts
    
    /// All writes MUST go through this writer context (serialized, background queue)
    private lazy var writer: NSManagedObjectContext = {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        ctx.automaticallyMergesChangesFromParent = true
        ctx.undoManager = nil
        return ctx
    }()
    
    // MARK: - Helpers
    
    /// Read on main/view context, synchronously (thread-safe)
    @inline(__always)
    private func read<T>(_ block: (NSManagedObjectContext) throws -> T) rethrows -> T {
        try container.viewContext.performAndWait { try block(container.viewContext) }
    }
    
    /// Write on the writer context and SAVE IMMEDIATELY (no coalescing)
    /// Throws if save fails; also logs detailed Core Data errors.
    @inline(__always)
    private func writeImmediate(_ block: @escaping (NSManagedObjectContext) throws -> Void) throws {
        try writer.performAndWait {
            do {
                try block(writer)
                if writer.hasChanges {
                    do {
                        try writer.save() // immediate commit to disk
                    } catch let e as NSError {
                        logCoreDataError(e, ctx: writer)
                        throw e
                    }
                }
            } catch {
                throw error
            }
        }
    }
    
    /// Rich error logging to help pinpoint root causes when crashes/logs are vague
    private func logCoreDataError(_ e: NSError, ctx: NSManagedObjectContext) {
        WalletLogger.shared.debug("CD SAVE ERROR: domain=\(e.domain) code=\(e.code) info=\(e.userInfo)")
        if e.domain == NSCocoaErrorDomain {
            switch e.code {
            case NSManagedObjectMergeError:
                WalletLogger.shared.debug("Merge error (NSManagedObjectMergeError)")
            case NSManagedObjectConstraintMergeError:
                WalletLogger.shared.debug("Constraint merge error (likely unique constraint conflict)")
                // For standard merge conflicts
                if let mergeConflicts = e.userInfo[NSPersistentStoreSaveConflictsErrorKey] as? [NSMergeConflict] {
                    for c in mergeConflicts {
                        let oid = c.sourceObject.objectID
                        WalletLogger.shared.debug("MergeConflict objectID=\(oid) persisted=\(String(describing: c.persistedSnapshot)) cached=\(String(describing: c.cachedSnapshot))")
                    }
                    // For unique-constraint conflicts (NSConstraintConflict)
                } else if let constraintConflicts = e.userInfo[NSPersistentStoreSaveConflictsErrorKey] as? [NSConstraintConflict] {
                    for c in constraintConflicts {
                        let dbID = c.databaseObject?.objectID
                        let ids = c.conflictingObjects.map { $0.objectID }
                        WalletLogger.shared.debug("ConstraintConflict constraint=\(String(describing: c.constraint)) dbID=\(String(describing: dbID)) conflictingIDs=\(ids)")
                    }
                }
            case NSPersistentStoreSaveError:
                WalletLogger.shared.debug("Persistent store save error (NSPersistentStoreSaveError)")
            case NSPersistentStoreTimeoutError:
                WalletLogger.shared.debug("Persistent store timeout (possible DB lock)")
            default:
                break
            }
        }
    }
    
    // MARK: - Ca APIs
    
    @discardableResult
    public func insertCaPakage(pkgName: String) throws -> Bool {
        try writeImmediate { ctx in
            let ca = CaEntity(context: ctx)
            ca.idx = UUID().uuidString
            ca.pkgName = pkgName
            ca.createDate = Date.getUTC0Date(seconds: 0)
        }
        WalletLogger.shared.debug("Ca saved successfully")
        return true
    }
    
    public func selectCaPakage() throws -> Ca? {
        try read { ctx in
            let req = NSFetchRequest<CaEntity>(entityName: "CaEntity")
            req.fetchLimit = 1
            if let ca = try ctx.fetch(req).first,
               let idx = ca.idx, let pkg = ca.pkgName, let date = ca.createDate {
                WalletLogger.shared.debug("CaAppId \(idx): \(pkg) \(date)")
                return Ca(idx: idx, createDate: date, pkgName: pkg)
            }
            return nil
        }
    }
    
    @discardableResult
    public func deleteCaPakage() throws -> Bool {
        try writeImmediate { ctx in
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: "CaEntity")
            let objs = try ctx.fetch(req) as! [NSManagedObject]
            objs.forEach { ctx.delete($0) }
        }
        return true
    }
    
    // MARK: - Token APIs
    
    @discardableResult
    public func insertToken(walletId: String, hWalletToken: String, purpose: String,
                            pkgName: String, nonce: String, pii: String) throws -> Bool {
        // Delete old token(s), then insert new one atomically on writer
        try writeImmediate { ctx in
            let delReq = NSFetchRequest<NSFetchRequestResult>(entityName: "TokenEntity")
            let olds = try ctx.fetch(delReq) as! [NSManagedObject]
            olds.forEach { ctx.delete($0) }
            
            let token = TokenEntity(context: ctx)
            token.idx = UUID().uuidString
            token.walletId = walletId
            token.hWalletToken = hWalletToken
            token.purpose = purpose
            token.pkgName = pkgName
            token.nonce = nonce
            token.pii = pii
            token.validUntil = Date.getUTC0Date(seconds: 60 * 30)
            token.createDate = Date.getUTC0Date(seconds: 0)
        }
        WalletLogger.shared.debug("token saved successfully")
        return true
    }
    
    public func selectToken() throws -> Token? {
        try read { ctx in
            let req = NSFetchRequest<TokenEntity>(entityName: "TokenEntity")
            req.fetchLimit = 1
            guard let t = try ctx.fetch(req).first,
                  let idx = t.idx, let pkg = t.pkgName, let wid = t.walletId,
                  let h = t.hWalletToken, let n = t.nonce, let p = t.pii,
                  let vu = t.validUntil, let cd = t.createDate, let pur = t.purpose else {
                return nil
            }
            WalletLogger.shared.debug("select Token idx: \(idx) pkgName: \(pkg) walletId: \(wid) hWalletToken: \(h) nonce: \(n) pii: \(p) validUntil: \(vu) createDate: \(cd) purpose: \(pur)")
            return Token(idx: idx, walletId: wid, hWalletToken: h,
                         validUntil: vu, purpose: pur, nonce: n, pkgName: pkg,
                         pii: p, createDate: cd)
        }
    }
    
    @discardableResult
    public func deleteToken() throws -> Bool {
        try writeImmediate { ctx in
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: "TokenEntity")
            let objs = try ctx.fetch(req) as! [NSManagedObject]
            objs.forEach { ctx.delete($0) }
        }
        return true
    }
    
    // MARK: - User APIs
    
    @discardableResult
    public func insertUser(finalEncKey: String, pii: String) throws -> Bool {
        try writeImmediate { ctx in
            // Clear existing
            let delReq = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
            let olds = try ctx.fetch(delReq) as! [NSManagedObject]
            olds.forEach { ctx.delete($0) }
            
            let user = UserEntity(context: ctx)
            user.idx = UUID().uuidString
            user.finalEncKey = finalEncKey
            user.pii = pii
            user.createDate = Date.getUTC0Date(seconds: 0)
            user.updateDate = Date.getUTC0Date(seconds: 0)
        }
        WalletLogger.shared.debug("user saved successfully")
        return true
    }
    
    public func selectUser() throws -> User? {
        try read { ctx in
            let req = NSFetchRequest<UserEntity>(entityName: "UserEntity")
            req.fetchLimit = 1
            guard let u = try ctx.fetch(req).first else { return nil }
            return User(idx: u.idx ?? "",
                        pii: u.pii ?? "",
                        finalEncKey: u.finalEncKey ?? "",
                        createDate: u.createDate ?? "",
                        updateDate: u.updateDate ?? "")
        }
    }
    
    @discardableResult
    public func updateUser(finalEncKey: String) throws -> Bool {
        try writeImmediate { ctx in
            let req = NSFetchRequest<UserEntity>(entityName: "UserEntity")
            // Keep original predicate semantics
//            req.predicate = NSPredicate(format: "finalEncKey == %@", "")
            req.fetchLimit = 1
            if let u = try ctx.fetch(req).first {
                WalletLogger.shared.debug("updateUser finalEncKey: \(finalEncKey)")
                u.finalEncKey = finalEncKey
                u.updateDate = Date.getUTC0Date(seconds: 0)
            }
        }
        return true
    }
    
    @discardableResult
    public func deleteUser() throws -> Bool {
        try writeImmediate { ctx in
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
            let objs = try ctx.fetch(req) as! [NSManagedObject]
            objs.forEach { ctx.delete($0) }
        }
        return true
    }
}
