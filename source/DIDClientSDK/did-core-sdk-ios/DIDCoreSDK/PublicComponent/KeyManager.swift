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
import DIDDataModelSDK
import DIDUtilitySDK
import LocalAuthentication

public struct KeyManager
{
    typealias C = CommonError
    typealias E = KeyManagerError
    
    let groupName  : String = "KeyManager"
    let iterations : UInt32 = 2048
    let derivedKeyLength : UInt = 48
    var storageManager : StorageManager<KeyInfo, DetailKeyInfo>
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - fileName: File name to be saved
    public init(fileName : String) throws
    {
        if fileName.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "fileName").getError()
        }
        
        storageManager = try .init(fileName: fileName,
                                   fileExtension: .key,
                                   isEncrypted: true)
    }
    
    //MARK: Key Life-cicle
    
    /// Keys presence state
    public var isAnyKeysSaved : Bool { storageManager.isSaved() }
    
    /// Returns presence of key named by id
    ///
    /// - Parameters:
    ///   - id: Key name
    /// - Returns: Presence state
    public func isKeySaved(id : String) throws -> Bool
    {
        if id.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "id").getError()
        }
        
        if !isAnyKeysSaved
        {
            return false
        }
        
        let metas = try storageManager.getAllMetas()
        
        return metas.contains { $0.id == id }
    }
    
    /// Generate the key which has given request
    ///
    /// - Parameters:
    ///   - keyGenRequest: Request which conforms to KeyGenRequestProtocol
    public func generateKey(keyGenRequest : KeyGenRequestProtocol) throws
    {
        let keyId = keyGenRequest.id
        if keyId.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "keyGenRequest.id").getError()
        }
        
        if isAnyKeysSaved
        {
            let metas = try storageManager.getAllMetas()
            
            if metas.contains(where: { $0.id == keyId })
            {
                throw E.existKeyID.getError()
            }
            else if SecureEnclaveManager.isKeySaved(group: groupName, 
                                                    identifier: keyId)
            {
                try SecureEnclaveManager.deleteKey(group: groupName,
                                                   identifier: keyId)
            }
        }
        else
        {
            if SecureEnclaveManager.isKeySaved(group: groupName)
            {
                try SecureEnclaveManager.deleteKey(group: groupName)
            }
        }
        
        var keyInfo : KeyInfo
        var detailKeyInfo : DetailKeyInfo
        
        switch keyGenRequest.storage
        {
        case .wallet:
            guard let request = keyGenRequest as? WalletKeyGenRequest
            else
            {
                throw E.notConformToKeyGenRequest(detail: .wallet).getError()
            }
            
            let keyAlgorithm = try getKeyAlgorithm(algorithmType: keyGenRequest.algorithmType)
            let (privateKey, publicKey) = try keyAlgorithm.generateKey()
            
            var priKey = privateKey
            
            var authType : AuthType = .free
            var accessMethod : KeyAccessMethod = .walletNone
            var saltString : String?
            
            if case let .pin(password) = request.accessMethod
            {
                if password.isEmpty
                {
                    throw C.invalidParameter(code: .keyManager,
                                             name: "keyGenRequest.accessMethod.pin(value:)").getError()
                }
                authType = .pin
                accessMethod = .walletPin
                
                let encryptResult = try encryptAES256ViaPBKDF2(password: password,
                                                               plainData: priKey)
                priKey = encryptResult.encrypted
                saltString = encryptResult.salt
            }
            
            keyInfo = .init(algorithmType: request.algorithmType,
                            id: keyId,
                            accessMethod: accessMethod,
                            authType: authType,
                            publicKey: MultibaseUtils.encode(type: .base58BTC,
                                                             data: publicKey))
            
            detailKeyInfo = .init(id: keyId,
                                  privateKey: MultibaseUtils.encode(type: .base64,
                                                                    data: priKey),
                                  salt: saltString)
            
        case .secureEnclave:
            guard let request = keyGenRequest as? SecureKeyGenRequest
            else
            {
                throw E.notConformToKeyGenRequest(detail: .secureEnclave).getError()
            }
            
            var authType : AuthType = .free
            
            var domainState : String?
            if request.accessMethod != .none
            {
                authType = .bio
                var evalueteError : (any Error)?
                
                let semaphore = DispatchSemaphore(value: 0)
                
                try evaluatePolicy(prompt: request.prompt) { result, error in
                    if !result
                    {
                        evalueteError = error
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                
                if let error = evalueteError
                {
                    throw E.evaluatePolicy(detail: error).getError()
                }
                
                domainState = try getDomainState()
            }
            
            let publicKey = try SecureEnclaveManager.generateKey(group: groupName,
                                                                 identifier: keyId,
                                                                 accessMethod: request.accessMethod)
            
            let accessMethod : KeyAccessMethod = .init(rawValue: request.accessMethod.rawValue
                                                       + KeyAccessMethod.secureEnclaveNone.rawValue)!
            
            
            keyInfo = .init(algorithmType: .secp256r1,
                            id: keyId,
                            accessMethod: accessMethod,
                            authType: authType,
                            publicKey: MultibaseUtils.encode(type: .base58BTC,
                                                             data: publicKey))
            
            detailKeyInfo = .init(id: keyId,
                                  domainState: domainState)
        }
        
        try storageManager.addItem(walletItem: .init(meta: keyInfo,
                                                     item: detailKeyInfo))
    }
    
    /// Change pin of the key which is walletPin
    ///
    /// - Parameters:
    ///   - id: Key name
    ///   - oldPin: Current pin of key
    ///   - newPin: New pin of key
    public func changePin(id : String, oldPin : Data, newPin : Data) throws
    {
        if id.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "id").getError()
        }
        
        if oldPin.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "oldPin").getError()
        }
        
        if newPin.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "newPin").getError()
        }
        
        if oldPin == newPin
        {
            throw E.newPinEqualsOldPin.getError()
        }
        
        let walletItem = try storageManager.getItems(by: [id]).first!
        
        let keyInfo = walletItem.meta
        var detailKeyInfo = walletItem.item
        
        if keyInfo.authType != .pin
        {
            throw E.notPinAuthType.getError()
        }
        
        let priKey : Data
        
        do
        {
            priKey = try MultibaseUtils.decode(encoded: detailKeyInfo.privateKey!)
        }
        catch
        {
            throw C.failToDecode(code: .keyManager,
                                 name: "Data(R)").getError()
        }
        
        
        let decrypted = try decryptAES256ViaPBKDF2(encryptResult: EncryptResult(encrypted: priKey,
                                                                                salt:detailKeyInfo.salt!),
                                                   password: oldPin)
        
        let publicKey : Data
        do
        {
            publicKey = try MultibaseUtils.decode(encoded: keyInfo.publicKey)
        }
        catch
        {
            throw C.failToDecode(code: .keyManager,
                                 name: "Data(U)").getError()
        }
        
        let keyAlgorithm = try getKeyAlgorithm(algorithmType: keyInfo.algorithmType)
        try keyAlgorithm.checkKeyPairMatch(privateKey: decrypted,
                                           publicKey: publicKey)
        
        let encryptResult = try encryptAES256ViaPBKDF2(password: newPin,
                                                       plainData: decrypted)
        
        detailKeyInfo.privateKey = MultibaseUtils.encode(type: .base64,
                                                         data: encryptResult.encrypted)
        detailKeyInfo.salt = encryptResult.salt
        
        try storageManager.updateItem(walletItem: .init(meta: keyInfo,
                                                        item: detailKeyInfo))
    }
    
    /// Returns one or more KeyInfo which match the conditions
    ///
    /// Returns all KeyInfos if keyType is empty
    ///
    /// - Parameters:
    ///   - keyType: Match conditions
    /// - Returns: Array of KeyInfo
    @discardableResult
    public func getKeyInfos(keyType : VerifyAuthType) throws -> [KeyInfo]
    {
        let metas = try storageManager.getAllMetas()
        
        if keyType.isEmpty
        {
            return metas
        }
        
        var checkKeyType = keyType
        var keyInfos : [KeyInfo] = .init()
        
        for value in keyType
        {
            let filtered = metas.filter({ $0.authType.rawValue == value.rawValue })
            
            if !filtered.isEmpty
            {
                checkKeyType.remove(value)
                keyInfos.append(contentsOf: filtered)
            }
        }
        
        if checkKeyType == keyType
        {
            throw E.foundNoKeyByKeyType.getError()
        }
        else
        {
            if checkKeyType.contains(.and)
            {
                if checkKeyType != .and
                {
                    throw E.insufficientResultByKeyType.getError()
                }
            }
        }
        
        return keyInfos
    }
    
    /// Returns one or more KeyInfo which match by its name
    ///
    /// - Parameters:
    ///   -  ids: Key names to be find
    /// - Returns: Array of KeyInfo
    @discardableResult
    public func getKeyInfos(ids : [String]) throws -> [KeyInfo]
    {
        try checkArrayArgument(array: ids, 
                               variableName: "ids")
        
        return try storageManager.getMetas(by: ids)
    }
    
    /// Delete the keys which match its name
    ///
    /// - Parameters:
    ///   - ids: Key names to find
    public func deleteKeys(ids : [String]) throws
    {
        try checkArrayArgument(array: ids,
                               variableName: "ids")
        
        let metas = try storageManager.getMetas(by: ids)
        let filtered = metas.filter { $0.accessMethod.rawValue >= KeyAccessMethod.secureEnclaveNone.rawValue }
        
        if !filtered.isEmpty {
            for secureStored in filtered {
                try SecureEnclaveManager.deleteKey(group: groupName,
                                                   identifier: secureStored.id)
            }
        }
        
        try storageManager.removeItems(by: ids)
        
    }
    
    /// Delete All keys
    public func deleteAllKeys() throws
    {
        try storageManager.removeAllItems()
        
        if SecureEnclaveManager.isKeySaved(group: groupName)
        {
            try SecureEnclaveManager.deleteKey(group: groupName)
        }
    }
    
    //MARK: Sign
    /// Sign the digest
    ///
    /// - Parameters:
    ///   - id: Key name to be find
    ///   - pin: (Optional)Pin of key
    ///   - digest: Data to sign
    /// - Returns: Signature value
    public func sign(id : String, pin : Data? = nil, digest : Data) throws -> Data
    {
        if id.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "id").getError()
        }
        
        if digest.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: "digest").getError()
        }
        
        let walletItem = try storageManager.getItems(by: [id]).first!
        
        let keyInfo = walletItem.meta
        let detailKeyInfo = walletItem.item
        
        switch keyInfo.accessMethod
        {
        case .walletNone, .walletPin:
            let keyAlgorithm = try getKeyAlgorithm(algorithmType: keyInfo.algorithmType)
            
            var priKey : Data
            do
            {
                priKey = try MultibaseUtils.decode(encoded: detailKeyInfo.privateKey!)
            }
            catch
            {
                throw C.failToDecode(code: .keyManager,
                                     name: "Data(R)").getError()
            }
            
            if keyInfo.accessMethod == .walletPin
            {
                guard let password = pin, !password.isEmpty
                else
                {
                    throw C.invalidParameter(code: .keyManager,
                                             name: "pin").getError()
                }
                
                let decrypted = try decryptAES256ViaPBKDF2(encryptResult: EncryptResult(encrypted: priKey,
                                                                                        salt: detailKeyInfo.salt!),
                                                           password: password)
                
                let publicKey : Data
                do
                {
                    publicKey = try MultibaseUtils.decode(encoded: keyInfo.publicKey)
                }
                catch
                {
                    throw C.failToDecode(code: .keyManager,
                                         name: "Data(U)").getError()
                }
                
                try keyAlgorithm.checkKeyPairMatch(privateKey: decrypted,
                                                   publicKey: publicKey)
                priKey = decrypted
            }
            
            return try keyAlgorithm.sign(privateKey: priKey,
                                         digest: digest)
        case .secureEnclaveCurrentSet:
            let domainState = try getDomainState()
            
            if domainState != detailKeyInfo.domainState!
            {
                throw E.userBiometricsChanged.getError()
            }
            fallthrough
        case .secureEnclaveNone, .secureEnclaveAny:
            return try SecureEnclaveManager.sign(group: groupName,
                                                 identifier: id,
                                                 digest: digest)
        }
    }
    
    /// Verify the signature value
    ///
    /// - Parameters:
    ///   - algorithmType: Signature value Algorithm type
    ///   - publicKey: Public key of the private key used in the signature
    ///   - digest: Digest data
    ///   - signature: Signature value
    /// - Returns: Return false when not match with recovered public key, otherway error occurs
    public func verify(algorithmType : AlgorithmType,
                       publicKey : Data,
                       digest : Data,
                       signature : Data) throws -> Bool
    {
        let keyAlgorithm = try getKeyAlgorithm(algorithmType: algorithmType)
        
        return try keyAlgorithm.verify(publicKey: publicKey,
                                       digest: digest,
                                       signature: signature)
    }
}

fileprivate extension KeyManager
{
    func getKeyAlgorithm(algorithmType : AlgorithmType) throws -> SignableProtocol
    {
        switch algorithmType
        {
        case .secp256r1:
            Secp256R1Manager()
        default:
            throw E.unsupportedAlgorithm.getError()
        }
    }
}

fileprivate extension KeyManager
{
    func canEvaluatePolicy() throws -> LAContext
    {
        var error: NSError?
        let context : LAContext = .init()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                  error: &error)
        
        if let error = error
        {
            throw E.evaluatePolicy(detail: error).getError()
        }
        
        return context
    }
    
    typealias PolicyClosure = (Bool, (any Error)?) -> Void
    func evaluatePolicy(prompt : String, reply : @escaping PolicyClosure) throws
    {
        let context = try canEvaluatePolicy()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: prompt,
                               reply: reply)
    }
    
    func getDomainState() throws -> String
    {
        let context = try canEvaluatePolicy()
        
        if let domainState = context.evaluatedPolicyDomainState
        {
            return MultibaseUtils.encode(type: .base64,
                                         data: domainState)
        }
        else
        {
            throw E.domainStateNil.getError()
        }
    }
}

fileprivate extension KeyManager
{
    typealias EncryptResult = (encrypted : Data, salt : String)
    
    func encryptAES256ViaPBKDF2(password : Data,
                                plainData : Data) throws -> EncryptResult
    {
        let salt = try CryptoUtils.generateNonce(size: 32)
        
        let derived = try CryptoUtils.pbkdf2(password: password,
                                             salt: salt,
                                             iterations: iterations,
                                             derivedKeyLength: derivedKeyLength)
        
        let encrypted = try CryptoUtils.encrypt(plain: plainData,
                                                info: CipherInfo(cipherType: .aes256CBC,
                                                                 padding: .pkcs5),
                                                key: derived[0..<32],
                                                iv: derived[32..<48])
        
        return EncryptResult(encrypted: encrypted,
                             salt: MultibaseUtils.encode(type: .base64,
                                                         data: salt))
    }
    
    func decryptAES256ViaPBKDF2(encryptResult : EncryptResult,
                                password : Data) throws -> Data
    {
        
        let salt : Data
        do
        {
            salt = try MultibaseUtils.decode(encoded: encryptResult.salt)
        }
        catch
        {
            throw C.failToDecode(code: .keyManager,
                                 name: "Data(A)").getError()
        }
        
        let derived =  try CryptoUtils.pbkdf2(password: password,
                                              salt: salt,
                                              iterations: iterations,
                                              derivedKeyLength: derivedKeyLength)
        
        return try CryptoUtils.decrypt(cipher: encryptResult.encrypted,
                                       info: CipherInfo(cipherType: .aes256CBC,
                                                        padding: .pkcs5),
                                       key: derived[0..<32],
                                       iv: derived[32..<48])
    }
}

fileprivate extension KeyManager
{
    func checkArrayArgument<T>(array : Array<T>,
                               variableName : String) throws where T : Hashable
    {
        if array.isEmpty
        {
            throw C.invalidParameter(code: .keyManager,
                                     name: variableName).getError()
        }
        else if array.count != Set(array).count
        {
            throw C.duplicateParameter(code: .keyManager,
                                       name: variableName).getError()
        }
    }
}
