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
import CryptoKit

extension Data {
    
    //MARK: - Encode
    
    var base16Encoded: String {
        return self.reduce(into: "", { $0.append(String(format: "%02x", $1)) })
    }
    
    var base16UpperEncoded: String {
        return self.reduce(into: "", { $0.append(String(format: "%02X", $1)) })
    }
    
    var base58BTCEncoded: String {
        return Base58BTC.encode(input: self)
    }
    
    var base64Encoded: String {
        return self.base64EncodedString().replacingOccurrences(of: "=", with: "")
    }
    
    var base64URLEncoded: String {
        return self.base64Encoded
                    .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
    }
}

extension Data {
    func hexString() -> String {
        return self.reduce("", {String(format: "\($0)%02x", $1)})
    }
}

extension Data {
    
    func sha256() -> Data {
        return DigestUtils.getDigest(source: self, digestEnum: .sha256)
    }
}

//MARK: Secp256R1
extension Data
{
    func derivePublicKeyFromPrivateKeyData() throws -> Data
    {
        let privateKey : P256.Signing.PrivateKey
        do
        {
            privateKey = try P256.Signing.PrivateKey(rawRepresentation: self)
        }
        catch
        {
            throw SignableError.invalidPrivateKey.getError()
        }
        
        return try privateKey.derivePublicKeyData()
    }
    
    func toCompressedRepresentationFromRawPublicKey() throws -> Data
    {
        if count != 65 || self[0] != 0x04
        {
            throw SignableError.invalidPublicKey.getError()
        }
        
        let offsetX = 1
        let offsetY = 33
        
        let x = self[offsetX..<offsetY]
        let y = self[offsetY...]
        
        var tag: Data!
        
        if y.last! & 0x01 == 0x01
        {
            tag = Data(repeating: 0x03, count: 1)
        } else
        {
            tag = Data(repeating: 0x02, count: 1)
        }
        return tag + x
    }
}
