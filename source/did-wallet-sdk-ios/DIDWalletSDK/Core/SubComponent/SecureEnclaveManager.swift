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
import LocalAuthentication
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
    /// Whether the stored key can perform ECDH.
    ///
    /// Asked of the key itself: a Secure Enclave key created before key agreement was requested
    /// cannot do it however new the device is, so an OS-version check would give the wrong answer.
    static func canKeyAgree(group: String, identifier: String) -> Bool
    {
        guard let keyPair = try? secKey(group: group, identifier: identifier) else { return false }
        return SecKeyIsAlgorithmSupported(keyPair, .keyExchange, .ecdhKeyExchangeStandard)
    }

    /// The raw ECDH shared secret with the given public key.
    ///
    /// `ecdhKeyExchangeStandard` and not an X963 variant: the mdoc MAC key is derived with HKDF
    /// over the raw Z, so a KDF applied here would produce the wrong input.
    ///
    /// - Parameter publicKey: The peer's public key as an uncompressed point (`0x04‖x‖y`).
    /// - Throws: `SecureEnclaveError.keyAgreementUnsupported` when the key cannot do ECDH — the one
    ///   condition the mdoc path treats as "fall back to a signature".
    ///   `context` is carried into the key lookup, so a confirmation already given in this call is
    ///   not asked for again.
    static func keyAgreement(group: String,
                             identifier: String,
                             publicKey: Data,
                             context: LAContext? = nil) throws -> Data
    {
        let keyPair = try secKey(group: group, identifier: identifier, context: context)

        guard SecKeyIsAlgorithmSupported(keyPair, .keyExchange, .ecdhKeyExchangeStandard)
        else
        {
            throw E.keyAgreementUnsupported.getError()
        }

        var error: Unmanaged<CFError>?
        guard let peer = SecKeyCreateWithData(publicKey as CFData,
                                              [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                               kSecAttrKeyClass: kSecAttrKeyClassPublic,
                                               kSecAttrKeySizeInBits: 256] as CFDictionary,
                                              &error)
        else
        {
            throw E.keyAgreement(detail: error!.toError()).getError()
        }

        guard let shared = SecKeyCopyKeyExchangeResult(keyPair,
                                                       .ecdhKeyExchangeStandard,
                                                       peer,
                                                       [:] as CFDictionary,
                                                       &error) as? Data
        else
        {
            throw E.keyAgreement(detail: error!.toError()).getError()
        }
        return shared
    }

    /// Looks up a stored key pair.
    private static func secKey(group: String,
                               identifier: String,
                               context: LAContext? = nil) throws -> SecKey
    {
        var keyPairRef: CFTypeRef?
        let status = SecItemCopyMatching(makeQueryToSearchSecKey(label: group,
                                                                 identifier: identifier,
                                                                 useRef: true,
                                                                 context: context),
                                         &keyPairRef)
        guard status == errSecSuccess, let keyPair = keyPairRef
        else
        {
            throw E.notExistKey.getError()
        }
        return keyPair as! SecKey
    }

    /// - Parameter context: Carried into the key lookup so one user confirmation can cover several
    ///   key uses within a single call. `nil` lets the system ask on its own.
    static func sign(group: String,
                     identifier: String,
                     digest : Data,
                     context: LAContext? = nil) throws -> Data
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
                                                                 useRef: true,
                                                                 context: context),
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
    /// - Parameter context: The authentication context to judge the key's access control with.
    ///   A context that has already authenticated once is not asked again, which is how one user
    ///   confirmation covers several key uses. Passing it to a key that requires no authentication
    ///   does nothing.
    static func makeQueryToSearchSecKey(label: String,
                                        identifier: String? = nil,
                                        useRef: Bool = false,
                                        context: LAContext? = nil) -> NSDictionary
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
        
        if let context = context
        {
            query[kSecUseAuthenticationContext] = context
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
        
        // `kSecUseAuthenticationUI` is not set here. It belongs to `SecItem*` queries rather than
        // to key generation, its documented values are strings (`…UIAllow` / `…UIFail` /
        // `…UISkip`) rather than a boolean, and `…UIAllow` -- what a boolean was standing in for --
        // is the default anyway. Generating a key does not use its private half, so nothing here
        // asks the user to confirm; the confirmation for a biometric key is asked by `KeyManager`
        // before it gets this far, and by the system when the key is later used.
        switch accessMethod
        {
        case .currentSet:
            controlFlag.insert(.biometryCurrentSet)
        case .any:
            controlFlag.insert(.biometryAny)
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



