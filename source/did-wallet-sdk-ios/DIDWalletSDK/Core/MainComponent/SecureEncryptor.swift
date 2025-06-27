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

struct SecureEncryptor
{
    typealias C = WalletCoreCommonError
    
    static let group : String = "SecureEncryptor"
    static let identifier : String = "encryptKey"
    
    /// Encrypt the plainData via SecureEnclave
    ///
    /// - Parameters:
    ///   - plainData : Data to encrypt
    /// - Returns: Encrypted data
    public static func encrypt(plainData : Data) throws -> Data
    {
        if plainData.isEmpty
        {
            throw C.invalidParameter(code: .secureEncryptor,
                                     name: "plainData").getError()
        }
        
        if !SecureEnclaveManager.isKeySaved(group: group,
                                            identifier: identifier)
        {
            try SecureEnclaveManager.generateKey(group: group,
                                                 identifier: identifier,
                                                 accessMethod: .none)
        }
        return try SecureEnclaveManager.encrypt(group: group,
                                                identifier: identifier,
                                                plainData: plainData)
    }
    
    /// Decrypt the cipherData that encrypted via SecureEnclave
    ///
    /// - Parameters:
    ///   - cipherData Encrypted data via Secure Enclave
    /// - Returns: Plain data
    public static func decrypt(cipherData : Data) throws -> Data
    {
        if cipherData.isEmpty
        {
            throw C.invalidParameter(code: .secureEncryptor,
                                     name: "cipherData").getError()
        }
        
        return try SecureEnclaveManager.decrypt(group: group,
                                                identifier: identifier,
                                                cipherData: cipherData)
    }
}
