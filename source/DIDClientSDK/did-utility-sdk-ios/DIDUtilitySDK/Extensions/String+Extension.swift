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

extension String {
    
    //MARK: - Decode
    
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
    
    //MARK: - Regular expression
    
    func matches(regEx : String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }

}
