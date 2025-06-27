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
import CryptoKit
import CommonCrypto

/// Utility class for cryptography function
public class CryptoUtils {
    
    typealias C = UtilityCommonError
    typealias E = CryptoUtilsError
    
    /// Generates and returns a random nonce.
    /// - Parameter size: Byte size of the nonce to be generated
    /// - Returns: Randomly generated nonce
    public static func generateNonce(size: UInt) throws -> Data {
        if size == 0 {
            throw C.invalidParameter(code: .cryptoUtils, name: "size").getError()
        }
        
        let count = Int(size)
        var result: Data = .init(count: count)
        let _ = SecRandomCopyBytes(kSecRandomDefault, count, result.withUnsafeMutableBytes({ $0.baseAddress! }))
        
        return result
    }
    
    /// Generates a key pair for ECDH purposes.
    /// - Parameter ecType: Type of elliptic curve for the key pair to be generated
    /// - Returns: Key pair object
    public static func generateECKeyPair(ecType: ECType) throws -> ECKeyPair {
        
        func makeQueryToCreateSecKey(bits: Int = 256) -> NSDictionary {
            let attributes = NSMutableDictionary(dictionary: [
                kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeySizeInBits: bits
            ])
            
            let keyAttrs: NSMutableDictionary = .init()
                        
            attributes[kSecPrivateKeyAttrs] = keyAttrs
            
            return attributes
        }

        func toPublicKey(privateKey: SecKey) throws -> SecKey {
            guard let pubKey = SecKeyCopyPublicKey(privateKey) else {
                throw E.failToDerivePublicKey.getError()
            }
            
            return pubKey
        }
        
        func toCompressedRepresentationFromRawPublicKey(publicKey: Data) throws -> Data {
            let offsetX = 1
            let offsetY = 33
            
            let x = publicKey[offsetX..<offsetY]
            let y = publicKey[offsetY...]
            
            var tag: Data!
            
            if y.last! & 0x01 == 0x01 {
                tag = Data(repeating: 0x03, count: 1)
            } else {
                tag = Data(repeating: 0x02, count: 1)
            }
            
            return tag + x
        }

        func toCompressedPublicKeyData(publicKey: SecKey) throws -> Data {
            var error: Unmanaged<CFError>?
            
            guard let pubKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as? Data else {
                let err = (error!.takeRetainedValue() as Error)
                throw E.failToConvertPublicKeyToExternalRepresentation(err).getError()
            }
            
            return try toCompressedRepresentationFromRawPublicKey(publicKey: pubKeyData)
        }

        func generateKey() throws -> ECKeyPair {
            var error: Unmanaged<CFError>?
            var keyPair: SecKey!

        
            let attributes = makeQueryToCreateSecKey()
            
            guard let tempKeyPair = SecKeyCreateRandomKey(attributes, &error) else {
                let err = (error!.takeRetainedValue() as Error)
                throw E.failToCreateRandomKey(err).getError()
            }
            
            keyPair = tempKeyPair
            
            let publicKey = try toPublicKey(privateKey: keyPair)
            let publicKeyData = try toCompressedPublicKeyData(publicKey: publicKey)
            
            guard let keyPairData = SecKeyCopyExternalRepresentation(keyPair, &error) as? Data else {
                let err = (error!.takeRetainedValue() as Error)
                throw E.failToConvertPrivateKeyToExternalRepresentation(err).getError()
            }
            
            let offset = keyPairData.count - 32
            let privateKeyData = Data(keyPairData[offset...])
            
            return ECKeyPair(ecType: ecType, privateKey: privateKeyData, publicKey: publicKeyData)
        }
        
        if ecType != .secp256r1 {
            throw CryptoUtilsError.unsupprotedECType(typeName: ecType.rawValue).getError()
        }
        
        return try generateKey()
        
        
    }
    
    /// Generates a shared secret key using the ECDH algorithm.
    /// - Parameters:
    ///   - ecType: Elliptic curve type for performing ECDH
    ///   - privateKey: Private key to use for ECDH
    ///   - publicKey: Public key to use for ECDH
    /// - Returns: Secret shared key resulting from ECDH
    public static func generateSharedSecret(ecType: ECType, privateKey: Data, publicKey: Data) throws -> Data {
        if privateKey.count != 32 {
            throw C.invalidParameter(code: .cryptoUtils, name: "privateKey").getError()
        }
        
        if publicKey.count != 33 {
            throw C.invalidParameter(code: .cryptoUtils, name: "publicKey").getError()
        }
        
        let privKeyObj: P256.KeyAgreement.PrivateKey
        
        do {
            privKeyObj = try P256.KeyAgreement.PrivateKey(rawRepresentation: privateKey)
        } catch {
            throw E.failToConvertPrivateKeyToObject(error).getError()
        }
        
        let pubKeyObj: P256.KeyAgreement.PublicKey
        
        do {
            pubKeyObj = try P256.KeyAgreement.PublicKey(compactRepresentation: publicKey[1...]) // Must use compact representation because compressed representation api needs above iOS 16
        } catch {
            throw E.failToConvertPublicKeyToObject(error).getError()
        }
        
        let sharedSecret: SharedSecret
        
        do {
            sharedSecret = try privKeyObj.sharedSecretFromKeyAgreement(with: pubKeyObj)
        } catch {
            throw E.failToGenerateSharedSecretUsingECDH(error).getError()
        }
        
        let result = sharedSecret.withUnsafeBytes({ Data(bytes: $0.baseAddress!, count: $0.count) })
        
        return result
        
    }
    
    /// Derives a key using the PBKDF2 algorithm.
    /// - Parameters:
    ///   - password: Password used as the seed for key derivation
    ///   - salt: Salt used in the key derivation process
    ///   - iterations: Number of hash iterations for key derivation
    ///   - derivedKeyLength: Byte length of the derived key
    /// - Returns: Key derived from the password
    public static func pbkdf2(password: Data, salt: Data, iterations: UInt32, derivedKeyLength: UInt) throws -> Data {
        if password.count == 0 {
            throw C.invalidParameter(code: .cryptoUtils, name: "password").getError()
        }
        
        if salt.count == 0 {
            throw C.invalidParameter(code: .cryptoUtils, name: "salt").getError()
        }

        if iterations == 0 {
            throw C.invalidParameter(code: .cryptoUtils, name: "iterations").getError()
        }
        
        if derivedKeyLength == 0 {
            throw C.invalidParameter(code: .cryptoUtils, name: "derivedKeyLength").getError()
        }
        
        var derivedKey = Array<UInt8>(repeating: 0, count: Int(derivedKeyLength))
        
        let status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), (password as NSData).bytes, password.count, (salt as NSData).bytes, salt.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), iterations, &derivedKey, derivedKey.count)
        
        if status != kCCSuccess {
            throw E.failToDeriveKeyUsingPBKDF2.getError()
        }
        
        return Data(bytes: derivedKey, count: derivedKey.count)
    }
    
    /// Encrypt the input data.
    /// - Parameters:
    ///   - plain: Plain data to encrypt
    ///   - info: Encryption information
    ///   - key: Symmetric key for encryption
    ///   - iv: IV for encryption
    /// - Returns: Encrypted data
    public static func encrypt(plain: Data, info: CipherInfo, key: Data, iv: Data) throws -> Data {
        if plain.count == 0 {
            throw C.invalidParameter(code: .cryptoUtils, name: "plain").getError()
        }
        
        try isValid(cipherInfo: info, key: key, iv: iv)
        
        switch info.type {
        case .aes:
            return try aesCrypt(dataIn: plain, info: info, key: key, iv: iv, operation: CCOperation(kCCEncrypt))
        }
    }
    
    /// Decrypts the input data.
    /// - Parameters:
    ///   - cipher: Cipher data to be decrypted
    ///   - info: Encryption information
    ///   - key: Symmetric key for decryption
    ///   - iv: IV for decryption
    /// - Returns: Decrypted data
    public static func decrypt(cipher: Data, info: CipherInfo, key: Data, iv: Data) throws -> Data {
        if cipher.count == 0 {
            throw C.invalidParameter(code: .cryptoUtils, name: "cipher").getError()
        }
        
        try isValid(cipherInfo: info, key: key, iv: iv)
        
        switch info.type {
        case .aes:
            return try aesCrypt(dataIn: cipher, info: info, key: key, iv: iv, operation: CCOperation(kCCDecrypt))
        }
    }
    
    //MARK: - Private methods
    
    private static func aesCrypt(dataIn: Data, info: CipherInfo, key: Data, iv: Data, operation: CCOperation) throws -> Data {        
        var paddingOption: CCOptions
        
        switch info.padding {
        case .noPad:
            paddingOption = 0
        case .pkcs5:
            paddingOption = CCOptions(kCCOptionPKCS7Padding)
        }
        
        switch info.mode {
        case .cbc:
            break
        case .ecb:
            paddingOption = paddingOption | CCOptions(kCCOptionECBMode)
        }
        
        var output = Data(repeating: 0, count: dataIn.count + kCCBlockSizeAES128)
        var outLen = Int(0)
        
        let status = CCCrypt(operation,
                             CCAlgorithm(kCCAlgorithmAES),
                             paddingOption,
                             (key as NSData).bytes,
                             key.count,
                             (iv as NSData).bytes,
                             (dataIn as NSData).bytes,
                             dataIn.count,
                             output.withUnsafeMutableBytes({ $0.baseAddress! }),
                             output.count,
                             &outLen)
        
        if status != kCCSuccess {
            if operation == kCCEncrypt {
                throw E.failToEncryptUsingAES.getError()
            } else {
                throw E.failToDecryptUsingAES.getError()
            }
        }
        
        return output.withUnsafeBytes({ Data(bytes: $0.baseAddress!, count: outLen) })
    }
    
    private static func isValid(cipherInfo: CipherInfo, key: Data, iv: Data) throws {
        if key.count != cipherInfo.size.rawValue / 8 {
            throw C.invalidParameter(code: .cryptoUtils, name: "key").getError()
        }
        
        if iv.count != 0 && iv.count != 16 {
            throw C.invalidParameter(code: .cryptoUtils, name: "iv").getError()
        }
    }

}
