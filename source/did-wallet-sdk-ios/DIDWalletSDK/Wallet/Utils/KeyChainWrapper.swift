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



public struct KeyChainWrapper
{
    static public func saveKeyChain(cek: Data,
                                    passcode: String) throws -> Data {
        
        deleteItem()
        
        WalletLogger.shared.debug("======[H] cek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: cek))")
        
        try saveItem(data: cek)
        
        let walletId = Properties.getWalletId()?.data(using: .utf8)
        
        let (key, iv) = try createKeyIV(saltData: walletId!,
                                        passcode: passcode)
    
        let encCek = try CryptoUtils.encrypt(plain: cek as Data,
                                             info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC,
                                                              padding: SymmetricPaddingType.pkcs5),
                                             key: key,
                                             iv: iv)
        
        WalletLogger.shared.debug("======[H] encCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: encCek))")
        
        let finalEncCek = try SecureEncryptor.encrypt(plainData: encCek)
        WalletLogger.shared.debug("======[H] finalEncCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: finalEncCek))")
        return finalEncCek
    }
     
    static public func matching(passcode: String, finalEncCek: Data) throws -> Data? {
        
        WalletLogger.shared.debug("======[H] finalEncCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: finalEncCek))")
        
        let encCek = try SecureEncryptor.decrypt(cipherData: finalEncCek)
        WalletLogger.shared.debug("======[H] encCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: encCek))")
        
        let walletId = Properties.getWalletId()?.data(using: .utf8)
        
        let (key, iv) = try createKeyIV(saltData: walletId!,
                                        passcode: passcode)
        
        let decCek = try CryptoUtils.decrypt(cipher: encCek,
                                             info: CipherInfo(cipherType: .aes256CBC,
                                                              padding: .pkcs5),
                                             key: key,
                                             iv: iv)
        WalletLogger.shared.debug("======[H] decCek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: decCek))")
        
        let cek = try getItem()
        WalletLogger.shared.debug("======[H] load cek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: cek))")
        
        if cek != decCek
        {
            WalletLogger.shared.debug("incorrect passcode")
            return nil
        }
        
        WalletLogger.shared.debug("correct passcode")
        return cek
    }
}

extension KeyChainWrapper
{
    static func deleteItem() //throws
    {
        let queryForDelete: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "KEY_PIN_CHAIN_DATA"
        ]
        
        // Delete a saved keychain service item
        let status = SecItemDelete(queryForDelete as CFDictionary)
        WalletLogger.shared.debug("item delete status: \(status)")
        
//        if status != errSecSuccess
//        {
//            throw WalletAPIError.saveKeychainFail.getError()
//        }
    }
    
    static func saveItem(data: Data) throws
    {
        var errorRef: Unmanaged<CFError>?
        
        let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault
                                                        , kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                                                        , []
                                                        , &errorRef)
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "KEY_PIN_CHAIN_DATA",
            kSecValueData: data as CFData,
            kSecAttrAccessControl: sacObject!
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        WalletLogger.shared.debug("item add status : \(status)")
        
        if status != errSecSuccess
        {
            throw WalletAPIError.saveKeychainFail.getError()
        }
    }
    
    static func getItem() throws -> Data
    {
        var dataTypeRef: CFTypeRef?
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "KEY_PIN_CHAIN_DATA",
            kSecReturnData: true
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        WalletLogger.shared.debug("item matching status : \(status)")
        // need to throw
        
        let data = dataTypeRef as! Data
        
        return data
    }
}

extension KeyChainWrapper
{
    static func createKeyIV(saltData: Data,
                     passcode: String) throws -> (Data, Data)
    {
        let saltSource = DigestUtils.getDigest(source: saltData,
                                               digestEnum: DigestEnum.sha384)
        
        WalletLogger.shared.debug("saltSource len: \(saltSource.count)")
        // walletID -> 48byte (32 salt, 16 iv)
        let (saltData, ivData) = WalletUtil.splitData(data: saltSource)!
        WalletLogger.shared.debug("saltData len: \(saltData.count)")
        WalletLogger.shared.debug("ivData len: \(ivData.count)")
        

        let kek = try CryptoUtils.pbkdf2(password: passcode.data(using: .utf8)!,
                                         salt: saltData,
                                         iterations: 2048,
                                         derivedKeyLength: 32)
        
        WalletLogger.shared.debug("======[H] kek: \(MultibaseUtils.encode(type: MultibaseType.base16, data: kek))")
        
        return (kek, ivData)
    }
}

