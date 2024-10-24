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
import DIDCoreSDK
import DIDDataModelSDK

class WalletCore: WalletCoreImpl {
    
    private var deviceKeyManager: KeyManager
    private var deviceDidManager: DIDManager
    private var holderKeyManager: KeyManager
    private var holderDidManager: DIDManager
    
    private var vcManager: VCManager
    
    public init() {
        self.deviceKeyManager = try! KeyManager(fileName: "device")
        self.deviceDidManager = try! DIDManager(fileName: "device")
        self.holderKeyManager = try! KeyManager(fileName: "holder")
        self.holderDidManager = try! DIDManager(fileName: "holder")
        self.vcManager = try! VCManager(fileName: "vc")
        
        WalletLogger.shared.debug("secceed create Wallet")
    }
    
    public func isSavedKey(keyId: String) throws -> Bool {
        if try holderKeyManager.isKeySaved(id: keyId) == false {
            return false
        }
        
        return true
    }
    
    public func deleteWallet() throws -> Bool {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }

        if deviceDidManager.isSaved {
            try deviceDidManager.deleteDocument()
        }
        if deviceKeyManager.isAnyKeysSaved {
            try deviceKeyManager.deleteAllKeys()
        }
        if holderDidManager.isSaved {
            try holderDidManager.deleteDocument()
        }
        if holderKeyManager.isAnyKeysSaved {
            try holderKeyManager.deleteAllKeys()
        }
        if vcManager.isAnyCredentialsSaved {
            try vcManager.deleteAllCredentials()
        }
        return true
    }
    
    public func saveDidDocument(type: DidDocumentType) throws -> Void {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }

        if type == DidDocumentType.DeviceDidDocument {
            try deviceDidManager.saveDocument()
        } else {
            try holderDidManager.saveDocument()
        }
    }
    
    public func isExistWallet() throws -> Bool {
//        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
//            throw WalletAPIError.lockedWallet.getError()
//        }
        
        if !deviceKeyManager.isAnyKeysSaved && !deviceDidManager.isSaved {
            WalletLogger.shared.debug("deviceKey not created")
            return false
        }
        
        return true
    }
    
    public func generateKey(passcode: String? = nil, keyId: String, algType: AlgorithmType) throws -> Void {
        // type,status
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }

        if keyId == "pin" {
            let pinKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: keyId, methodType: .pin(value: (passcode?.data(using: .utf8))!))
            try holderKeyManager.generateKey(keyGenRequest: pinKeyRequest)
        } else if keyId == "bio" {
            let bioKeyRequest = SecureKeyGenRequest(id: keyId, accessMethod: .currentSet, prompt: "please regist your biometrics")
            try holderKeyManager.generateKey(keyGenRequest: bioKeyRequest)
        }
        // 무인증 (keyagree)
        else {
            let keyagreeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: keyId, methodType: .none)
            try holderKeyManager.generateKey(keyGenRequest: keyagreeKeyRequest)
        }
    }
    
    public func sign(keyId: String, pin: Data? = nil, data: Data, type: DidDocumentType) throws -> Data {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }

        if type == DidDocumentType.DeviceDidDocument {
            return try deviceKeyManager.sign(id: keyId, digest: data)
        } else {
            return try holderKeyManager.sign(id: keyId, pin: pin, digest: data)
        }
    }
    
    public func createDeviceDidDocument() throws -> DIDDocument {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }

        let did = try DIDManager.genDID(methodName: "omn")
        WalletLogger.shared.debug("DID String : \(did)")
        
        if try deviceKeyManager.isKeySaved(id: "assert") == false {
            let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "assert", methodType: .none)
            try deviceKeyManager.generateKey(keyGenRequest: freeKeyRequest)
            WalletLogger.shared.debug("device assert Key generate completed")
        }
        
        if try deviceKeyManager.isKeySaved(id: "keyagree") == false {
            let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "keyagree", methodType: .none)
            try deviceKeyManager.generateKey(keyGenRequest: freeKeyRequest)
            WalletLogger.shared.debug("device keyagree Key 생성 완료")
        }
        
        if try deviceKeyManager.isKeySaved(id: "auth") == false {
            let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "auth", methodType: .none)
            try deviceKeyManager.generateKey(keyGenRequest: freeKeyRequest)
            WalletLogger.shared.debug("device auth Key generate completed")
        }
        
        let keyInfo = try deviceKeyManager.getKeyInfos(ids: ["assert", "keyagree", "auth"])
        
        var keyInfos: [DIDKeyInfo] = .init()
        keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[0], methodType: [.assertionMethod]))
        keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[1], methodType: [.keyAgreement]))
        keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[2], methodType: [.authentication]))
        
        WalletLogger.shared.debug("keyInfos: \(keyInfos)")
        
        try deviceDidManager.createDocument(did: did, keyInfos: keyInfos, controller: "did:omn:tas", service: nil)
        
        let deviceDidDoc = try deviceDidManager.getDocument()
        WalletLogger.shared.debug("deviceDidDoc: \(try deviceDidDoc.toJson())")
        //        try deviceDidManager.saveDocument()
        return deviceDidDoc
    }
    
    public func createHolderDidDocument() throws -> DIDDocument {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        
        let did = try DIDManager.genDID(methodName: "omn")
        WalletLogger.shared.debug("DID String : \(did)")
        
        
        var keyInfo: [KeyInfo]
        var keyInfos: [DIDKeyInfo] = .init()
        if try holderKeyManager.isKeySaved(id: "bio") {
            keyInfo = try holderKeyManager.getKeyInfos(ids: ["keyagree", "pin", "bio"])
            keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[0], methodType: [.keyAgreement]))
            keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[1], methodType: [.assertionMethod, .authentication]))
            keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[2], methodType: [.assertionMethod, .authentication]))
        } else {
            keyInfo = try holderKeyManager.getKeyInfos(ids: ["keyagree", "pin"])
            keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[0], methodType: [.keyAgreement]))
            keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[1], methodType: [.assertionMethod, .authentication]))
        }
        
        WalletLogger.shared.debug("keyInfos: \(keyInfos)")
        
        try holderDidManager.createDocument(did: did, keyInfos: keyInfos, controller: "did:omn:tas", service: nil)
        
        let holderDidDoc = try holderDidManager.getDocument()
        WalletLogger.shared.debug("holderDidDoc: \(try holderDidDoc.toJson())")
        
        try holderDidManager.saveDocument()
        
        return holderDidDoc
    }
    
    public func getDidDocument(type: DidDocumentType) throws -> DIDDocument {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }

        if type == DidDocumentType.DeviceDidDocument {
            return try deviceDidManager.getDocument()
        }
        else {
            return try holderDidManager.getDocument()
        }
    }
    
    public func verify(publicKey:Data, data: Data, signature: Data) throws -> Bool {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        return try holderKeyManager.verify(algorithmType: .secp256r1, publicKey: publicKey, digest: data, signature: signature)
    }
    
    public func addCredential(credential: VerifiableCredential) throws -> Bool {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        try vcManager.addCredential(credential: credential)
        return true
    }
    
    public func deleteCredential(ids: [String]) throws -> Bool {
        if try WalletLockManager().isRegLock() &&  WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        try vcManager.deleteCredentials(by: ids)
        return true
    }
    
    public func getCredential(ids: [String]) throws -> [VerifiableCredential] {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        return try vcManager.getCredentials(by: ids)
    }
    
    public func getAllCredentials() throws -> [VerifiableCredential] {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        return try vcManager.getAllCredentials()
    }
    
    public func isAnyCredentialsSaved() -> Bool {
        return vcManager.isAnyCredentialsSaved
    }
    
    public func makePresentation(claimInfos: [ClaimInfo], presentationInfo: PresentationInfo) throws -> VerifiablePresentation {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        return try vcManager.makePresentation(claimInfos: claimInfos, presentationInfo: presentationInfo)
    }
    
    public func getKeyInfos(keyType: VerifyAuthType) throws -> [KeyInfo] {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        return try holderKeyManager.getKeyInfos(keyType: keyType)
    }
    
    public func getKeyInfos(ids: [String]) throws -> [KeyInfo] {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        return try holderKeyManager.getKeyInfos(ids: ids)
    }
    
    public func isAnyKeysSaved() throws -> Bool {
        if try WalletLockManager().isRegLock() && WalletLockManager.isLock {
            throw WalletAPIError.lockedWallet.getError()
        }
        return holderKeyManager.isAnyKeysSaved
    }
}
