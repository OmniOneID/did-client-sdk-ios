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

/// Utility class for encoding/decoding using Multibase.
public class MultibaseUtils {

    typealias C = CommonError
    typealias E = MultibaseUtilsError
    
    /// Encodes the input data using Multibase encoding.
    /// - Parameters:
    ///   - type: Multibase encoding type
    ///   - data: Data to be encoded
    /// - Returns: Encoded data
    public static func encode(type: MultibaseType, data: Data) -> String {
        if data.count == 0 {
            return ""
        }
        
        var result = type.rawValue
        
        switch type {
        case .base16:
            result.append(data.base16Encoded)
        case .base16Upper:
            result.append(data.base16UpperEncoded)
        case .base58BTC:
            result.append(data.base58BTCEncoded)
        case .base64:
            result.append(data.base64Encoded)
        case .base64URL:
            result.append(data.base64URLEncoded)
        }
        
        return result
    }
    
    /// Decodes the given Multibase encoded string.
    /// - Parameters:
    ///   - encoded: Multibase encoded string to be decoded
    /// - Returns: Decoded data
    public static func decode(encoded: String) throws -> Data {

        if encoded.count < 2 {
            throw C.invalidParameter(code: .multibaseUtils, name: "encoded").getError()
        }
        
        let prefix = String(encoded.prefix(1))
        let startIndex = encoded.index(encoded.startIndex, offsetBy: 1)
        let value = String(encoded[startIndex...])
        
        guard let type = MultibaseType(rawValue: prefix) else {
            throw E.unsupportedEncodingType(prefix: prefix).getError()
        }
        
        let result: Data?
        
        switch type {
        case .base16, .base16Upper:
            result = value.base16Decoded
        case .base58BTC:
            result = value.base58BTCDecoded
        case .base64:
            result = value.base64Decoded
        case .base64URL:
            result = value.base64URLDecoded
        }
        
        guard let result = result else {
            throw E.failToDecode.getError()
        }
        
        return result
        
    }
    
}
