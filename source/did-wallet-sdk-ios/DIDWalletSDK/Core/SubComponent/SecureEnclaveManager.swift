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
import Security

//MARK: Life-cycle
struct SecureEnclaveManager
{
    typealias C = WalletCoreCommonError
    typealias E = SecureEnclaveError
    
    static let compressedPublicKeySize : Int = 33
    static let digestSize : Int = 32
    static let signatureSize : Int = 65
    
    @discardableResult
    static func generateKey(group: String,
                            identifier : String,
                            accessMethod : SecureEnclaveAccessMethod) throws -> Data
    {
        if group.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "group").getError()
        }
        
        if identifier.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "identifier").getError()
        }
        
        var error: Unmanaged<CFError>?
        
        let attributes = makeQueryToCreateSecKey(label: group, 
                                                 identifier: identifier,
                                                 accessMethod: accessMethod)
        
        guard let keyPair = SecKeyCreateRandomKey(attributes, &error)
        else
        {
            throw E.createKey(detail: error!.toError()).getError()
        }
        let publicKey = try keyPair.toPublicKey()
        let compressedPubKeyData = try publicKey.toCompressedPublicKeyData()
        
        return compressedPubKeyData
    }
    
    static func isKeySaved(group: String,
                           identifier: String? = nil) -> Bool
    {
        if group.isEmpty
        {
            return false
        }
        
        let status = SecItemCopyMatching(makeQueryToSearchSecKey(label: group,
                                                                 identifier: identifier),
                                         nil)
        return status == errSecSuccess
    }
    
    static func getPublicKey(group: String,
                             identifier: String) throws -> Data
    {
        if group.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "group").getError()
        }
        
        if identifier.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "identifier").getError()
        }
        
        var keyPairRef: CFTypeRef?
        
        let status = SecItemCopyMatching(makeQueryToSearchSecKey(label: group,
                                                                 identifier: identifier,
                                                                 useRef: true),
                                         &keyPairRef)
        
        if status != errSecSuccess
        {
            throw E.notExistKey.getError()
        }
        
        let keyPair = keyPairRef as! SecKey
        let publicKey = try keyPair.toPublicKey()
        let compressedPubKeyData = try publicKey.toCompressedPublicKeyData()
        
        return compressedPubKeyData
    }
    
    static func deleteKey(group: String,
                          identifier: String? = nil) throws
    {
        if group.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "group").getError()
        }
        
        if !isKeySaved(group: group,
                       identifier: identifier)
        {
            throw E.notExistKey.getError()
        }
        
        let status = SecItemDelete(makeQueryToSearchSecKey(label: group,
                                                           identifier: identifier))
        
        if status != errSecSuccess 
        {
            throw E.failToDeleteKey.getError()
        }
    }
}

//MARK: Signable
extension SecureEnclaveManager
{
    static func sign(group: String,
                     identifier: String,
                     digest : Data) throws -> Data
    {
        if group.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "group").getError()
        }
        
        if identifier.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "identifier").getError()
        }
        
        if digest.count != digestSize
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "digest").getError()
        }
        var keyPairRef: CFTypeRef?
        
        let status = SecItemCopyMatching(makeQueryToSearchSecKey(label: group,
                                                                 identifier: identifier,
                                                                 useRef: true),
                                         &keyPairRef)
        
        if status != errSecSuccess
        {
            throw E.notExistKey.getError()
        }
        
        let keyPair = keyPairRef as! SecKey
        var error: Unmanaged<CFError>?
        
        guard let signed = SecKeyCreateSignature(keyPair,
                                                 .ecdsaSignatureDigestX962SHA256,
                                                 digest as CFData,
                                                 &error) as? Data
        else
        {
            throw E.createSignature(detail: error!.toError()).getError()
        }
        
        let publicKey = try keyPair.toPublicKey()
        let uncompressedPubKeyData = try publicKey.toUncompressedPublicKeyData()
        
        do
        {
            let signature = try P256V.convertToCompactRepresentation(x962Signature: signed,
                                                                     digest: digest,
                                                                     uncompressedPublicKey: uncompressedPubKeyData)
            return signature
        }
        catch
        {
            throw SignableError.failToConvertCompactRepresentation(detail: error).getError()
        }
    }
    
    static func verify(publicKey : Data,
                       digest : Data,
                       signature : Data) throws -> Bool
    {
        if publicKey.count != compressedPublicKeySize
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "publicKey").getError()
        }
        
        if digest.count != digestSize
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "digest").getError()
        }
        
        if signature.count != signatureSize
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "signature").getError()
        }
        
        return try Secp256R1Manager().verify(publicKey: publicKey,
                                      digest: digest,
                                      signature: signature)
    }
}

//MARK: Encrypt
extension SecureEnclaveManager
{
    static func encrypt(group: String,
                        identifier: String,
                        plainData : Data) throws -> Data
    {
        if group.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "group").getError()
        }
        
        if identifier.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "identifier").getError()
        }
        
        if plainData.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "plainData").getError()
        }
        
        var keyPairRef: CFTypeRef?
        
        let status = SecItemCopyMatching(makeQueryToSearchSecKey(label: group,
                                                                 identifier: identifier,
                                                                 useRef: true),
                                         &keyPairRef)
        
        if status != errSecSuccess
        {
            throw E.notExistKey.getError()
        }
        
        let keyPair = keyPairRef as! SecKey
        let publicKey = try keyPair.toPublicKey()
        
        var error: Unmanaged<CFError>?
        guard let encrypted = SecKeyCreateEncryptedData(publicKey,
                                                        .eciesEncryptionStandardX963SHA256AESGCM,
                                                        plainData as CFData,
                                                        &error)
        else
        {
            throw E.createEncryptedData(detail: error!.toError()).getError()
        }
        
        return encrypted as Data
        
    }
    
    static func decrypt(group: String,
                        identifier: String,
                        cipherData : Data) throws -> Data
    {
        if group.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "group").getError()
        }
        
        if identifier.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "identifier").getError()
        }
        
        if cipherData.isEmpty
        {
            throw C.invalidParameter(code: .secureEnclave,
                                     name: "cipherData").getError()
        }
        
        var keyPairRef: CFTypeRef?
        
        let status = SecItemCopyMatching(makeQueryToSearchSecKey(label: group,
                                                                 identifier: identifier,
                                                                 useRef: true),
                                         &keyPairRef)
        
        if status != errSecSuccess 
        {
            throw E.notExistKey.getError()
        }
        
        let keyPair = keyPairRef as! SecKey
        var error: Unmanaged<CFError>?
        guard let decrypted = SecKeyCreateDecryptedData(keyPair,
                                                        .eciesEncryptionStandardX963SHA256AESGCM,
                                                        cipherData as CFData,
                                                        &error)
        else
        {
            throw E.createDecryptedData(detail: error!.toError()).getError()
        }
        
        return decrypted as Data
    }
}

//MARK: Private Function
fileprivate extension SecureEnclaveManager
{
    static func makeQueryToSearchSecKey(label: String,
                                        identifier: String? = nil,
                                        useRef: Bool = false) -> NSDictionary
    {
        let query: NSMutableDictionary =
        [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef: useRef,
            kSecAttrLabel: label
        ]
        
        if let identifier = identifier
        {
            query[kSecAttrApplicationTag] = identifier.data(using: .utf8)!
        }
        
        return query
    }
    
    static func makeQueryToCreateSecKey(label: String,
                                        identifier: String,
                                        accessMethod: SecureEnclaveAccessMethod) -> NSDictionary
    {
        let attributes = NSMutableDictionary(dictionary:
                                                [
                                                    kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                                    kSecAttrKeySizeInBits: 256,
                                                    kSecAttrLabel: label
                                                ])
        
        let keyAttrs: NSMutableDictionary = .init()
        
        var controlFlag: SecAccessControlCreateFlags = .privateKeyUsage
        
        switch accessMethod
        {
        case .currentSet:
            controlFlag.insert(.biometryCurrentSet)
            attributes[kSecUseAuthenticationUI] = true
        case .any:
            controlFlag.insert(.biometryAny)
            attributes[kSecUseAuthenticationUI] = true
        default:
            break;
        }
        
        
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                     kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     controlFlag,
                                                     nil)!
        
        keyAttrs[kSecAttrIsPermanent] = true
        keyAttrs[kSecAttrAccessControl] = access
        keyAttrs[kSecAttrApplicationTag] = identifier.data(using: .utf8)!
        
        attributes[kSecAttrTokenID] = kSecAttrTokenIDSecureEnclave
        attributes[kSecPrivateKeyAttrs] = keyAttrs
        
        return attributes
    }
}



