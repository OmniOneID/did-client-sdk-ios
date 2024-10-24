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
import DIDUtilitySDK
import DIDDataModelSDK
import DIDCommunicationSDK
import DIDCoreSDK

public class WalletUtil {
    
    public init() {
        
    }
    
    public static func generateMessageID() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSSSSS"
        let dateString = dateFormatter.string(from: currentDate)
        let randomHex = String(format: "%08X", arc4random_uniform(UINT32_MAX))
        let messageID = dateString + randomHex
        return messageID
    }
    
    /// Description
    /// - Parameters:
    ///   - clientNonce: <#clientNonce description#>
    ///   - serverNonce: <#serverNonce description#>
    /// - Returns: <#description#>
    public static func mergeNonce(clientNonce: Data?, serverNonce: Data?) throws -> Data {
        guard let clientNonce = clientNonce, let serverNonce = serverNonce else {
            throw NSError(domain: "mergeNonce error", code: 1)
        }
        
        var combinedData = Data()
        combinedData.append(clientNonce)
        combinedData.append(serverNonce)
        
        return DigestUtils.getDigest(source: combinedData, digestEnum: DigestEnum.sha256)
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - sharedSecret: <#sharedSecret description#>
    ///   - nonce: <#nonce description#>
    ///   - symmetricCipherType: <#symmetricCipherType description#>
    /// - Returns: <#description#>
    public static func mergeSharedSecretAndNonce(sharedSecret: Data, nonce: Data, symmetricCipherType: DIDUtilitySDK.SymmetricCipherType) -> Data {
        
        var digest = Data()
        digest.append(sharedSecret)
        digest.append(nonce)
        
        let combinedResult = DigestUtils.getDigest(source: digest, digestEnum: DigestEnum.sha256)
        
        switch symmetricCipherType {
        case DIDUtilitySDK.SymmetricCipherType.aes128CBC, DIDUtilitySDK.SymmetricCipherType.aes128ECB:
            return combinedResult.prefix(16)
        case DIDUtilitySDK.SymmetricCipherType.aes256CBC, DIDUtilitySDK.SymmetricCipherType.aes256ECB:
            return combinedResult.prefix(32)
        @unknown default:
            fatalError()
        }   
    }
    
    public static func splitData(data: Data) -> (Data, Data)? {
        // check 48byte
        guard data.count == 48 else {
            return nil
        }

        // divide 32byte, 16byte
        let firstData = data.prefix(32)
        let secondData = data.suffix(16)

        return (firstData, secondData)
    }
}
