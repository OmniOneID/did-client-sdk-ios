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

//MARK: - CryptoUtils

/// Elliptic Curve Key Pair information object.
public struct ECKeyPair {
    /// Elliptic curve type of key pair
    public var ecType: ECType
    /// Private key data
    public var privateKey: Data
    /// Public key data
    public var publicKey: Data
}

/// Encryption information object.
public struct CipherInfo {
    /// Symmetric key encryption algorithm type.
    public var type: EncryptionType
    /// Symmetric key encryption operation mode
    public var mode: EncryptionMode
    /// Symmetric key size
    public var size: SymmetricKeySize
    /// Symmetric key encryption padding type
    public var padding: SymmetricPaddingType
    
    /// Initializer
    /// - Parameters:
    ///   - cipherType: Information about encryption
    ///   - padding: Information of padding about encryption
    public init(cipherType: SymmetricCipherType, padding: SymmetricPaddingType) {
        
        let parsed = cipherType.rawValue.components(separatedBy: "-")
        
        let typePart = parsed[0]
        let sizePart = parsed[1]
        let modePart = parsed[2]
        
        let type = EncryptionType(rawValue: typePart)!
        let size = SymmetricKeySize(rawValue: UInt(sizePart)!)!
        let mode = EncryptionMode(rawValue: modePart)!
        
        self.type = type
        self.size = size
        self.mode = mode
        self.padding = padding
    }
}

