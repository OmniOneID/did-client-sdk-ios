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

//MARK: - Decode
extension String {
    
    var base16Decoded: Data? {
        let hexString = self
        let length = hexString.count / 2
        var data = Data(capacity: length)
        
        for i in 0 ..< length {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        
        return data
    }
    
    var base58BTCDecoded: Data? {
        return Base58BTC.decode(input: self)
    }
    
    var base64Decoded: Data? {
        var string = self
        
        switch string.count % 4 {
        case 0:
            break;
        case 2:
            string.append("==")
        case 3:
            string.append("=")
        default:
            return nil
        }
        
        return Data.init(base64Encoded: string, options: .ignoreUnknownCharacters)
    }
    
    var base64URLDecoded: Data? {
        return self
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
                .base64Decoded
    }
}

extension String
{
    func hexToData() -> Data?
    {
        return self.base16Decoded
    }
    
    func decodeBase64() -> Data? {
        return Data(base64Encoded: self)
    }
}

//MARK: - Regular expression
extension String
{
    func matches(regEx : String) ->Bool
    {
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    func isMatched(with pattern: String) throws -> Bool {
        if #available(iOS 16.0, *) {
            let regEx = try Regex(pattern)
            return self.contains(regEx)
        } else {
            let regEx = try NSRegularExpression(pattern: pattern)
            let output = regEx.numberOfMatches(in: self, range: .init(location: 0, length: self.count))
            return output > 0
        }
    }
}

//MARK: - Encode
extension String {
    func base64() -> String {
        if let strData = self.data(using: .utf8) {
            return strData.base64EncodedString()
        }
        return ""
    }
}

extension String {
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256().hexString()
        }
        return ""
    }
}
