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
import DIDUtilitySDK
import DIDCoreSDK

public class KeyChainWrapper {
    
    public init() {}
    
    private var seedKey: Data? = nil
    
    public func saveKeyChain(passcode: String) throws -> Data {
        
        var errorRef: Unmanaged<CFError>?
        
        let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault
                                                        , kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                                                        , []
                                                        , &errorRef)
        
        let queryForDelete: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                            kSecAttrService: "KEY_PIN_CHAIN_DATA"]
        
        // Delete a saved keychain service item
        var status = SecItemDelete(queryForDelete as CFDictionary)
        WalletLogger.shared.debug("item delete status: \(status)")
        
        // 1. cek = gen random (Contents Encrypting Key)
        var cek: NSMutableData
        if self.seedKey == nil {
            cek = NSMutableData(length: 32)!
            _ = SecRandomCopyBytes(kSecRandomDefault, 32, cek.mutableBytes)
        }  else {
            cek = NSMutableData(data: self.seedKey!)
        }
        
        WalletLogger.shared.debug("======[H] cek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: cek as Data))")
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "KEY_PIN_CHAIN_DATA",
            kSecValueData: cek as CFData,
            kSecAttrAccessControl: sacObject!
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        WalletLogger.shared.debug("item add status : \(status)")
        
        if status == errSecSuccess {
            
        }
//        else if status == errSecDuplicateItem {
//            throw WalletAPIError(errorCode: WalletErrorCodeEnum.saveKeychainFail)
//        } 
        else {
            throw WalletAPIError.saveKeychainFail.getError()
        }
        
        let walletId = Properties.getWalletId()?.data(using: .utf8)
        let data = DigestUtils.getDigest(source: walletId!, digestEnum: DigestEnum.sha384)
        
        WalletLogger.shared.debug("data len: \(data.count)")
        // walletID -> 48byte (32 salt, 16 iv)
        let (saltData, ivData) = WalletUtil.splitData(data: data)!
        WalletLogger.shared.debug("saltData len: \(saltData.count)")
        WalletLogger.shared.debug("ivData len: \(ivData.count)")
        
//        let salt = try MultibaseUtils.decode(encoded: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")    // 32byte
        let kek = try CryptoUtils.pbkdf2(password: passcode.data(using: .utf8)!, salt: saltData, iterations: 2048, derivedKeyLength: 32)
        WalletLogger.shared.debug("======[H] kek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: kek))")
        
//        let iv = try MultibaseUtils.decode(encoded: "z75M7MfQsC4p2rTxeKxYh2M")  //16byte
        
        let encCek = try CryptoUtils.encrypt(plain: cek as Data, info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: kek, iv: ivData)
        WalletLogger.shared.debug("======[H] encCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: encCek))")
        
        let finalEncCek = try SecureEncryptor.encrypt(plainData: encCek as Data)
        WalletLogger.shared.debug("======[H] finalEncCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: finalEncCek))")
        return finalEncCek
    }
     
    public func matching(passcode: String, finalEncCek: Data) throws -> Data? {
        
        WalletLogger.shared.debug("======[H] finalEncCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: finalEncCek))")
        
        let encCek = try SecureEncryptor.decrypt(cipherData: finalEncCek)
        WalletLogger.shared.debug("======[H] encCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: encCek))")
        
        let walletId = Properties.getWalletId()?.data(using: .utf8)
        let data = DigestUtils.getDigest(source: walletId!, digestEnum: DigestEnum.sha384)
        WalletLogger.shared.debug("data len: \(data.count)")
        // walletID -> 48byte (32 salt, 16 iv)
        let (saltData, ivData) = WalletUtil.splitData(data: data)!
        WalletLogger.shared.debug("saltData len: \(saltData.count)")
        WalletLogger.shared.debug("ivData len: \(ivData.count)")
        
//        let salt = try MultibaseUtils.decode(encoded: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")
        let kek = try CryptoUtils.pbkdf2(password: passcode.data(using: .utf8)!, salt: saltData, iterations: 2048, derivedKeyLength: 32)
        
        WalletLogger.shared.debug("======[H] kek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: kek))")
        
//        let iv = try MultibaseUtils.decode(encoded: "z75M7MfQsC4p2rTxeKxYh2M")
        let decCek = try CryptoUtils.decrypt(cipher: encCek, info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: kek, iv: ivData)
        WalletLogger.shared.debug("======[H] decCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: decCek))")
        
        var dataTypeRef: CFTypeRef?
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "KEY_PIN_CHAIN_DATA",
            kSecReturnData: true
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        WalletLogger.shared.debug("item matching status : \(status)")
        // need to throw
        
        let cek = dataTypeRef as! Data
        WalletLogger.shared.debug("======[H] load cek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: cek))")
        
        if cek as Data == decCek {
            WalletLogger.shared.debug("correct passcode")
            return cek as Data
        }
        WalletLogger.shared.debug("incorrect passcode")
        return nil
    }
}
