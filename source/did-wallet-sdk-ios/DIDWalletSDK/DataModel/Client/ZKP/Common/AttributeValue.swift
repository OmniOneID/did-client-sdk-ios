//
/*
 * Copyright 2025 OmniOne.
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

public struct AttributeValue : Jsonable
{
    public              let encoded : BigIntString
    public private(set) var raw     : String
    
    public init(raw: String)
    {
        self.raw = raw
        self.encoded = Self.getEncoded(raw: raw)
    }
}

extension AttributeValue
{
    private static func getEncoded(raw: String) -> BigIntString
    {
        if raw.isNumber
        {
            return raw.bigInt.decimalString
        }
        
        let hashed = DigestUtils.getDigest(source: raw.data(using: .utf8)!,
                                           digestEnum: .sha256)
        return BigInt(sign: .plus, magnitude: .init(hashed)).decimalString
    }
}
 
extension AttributeValue
{
    enum CodingKeys: String, CodingKey
    {
        case encoded,
             raw
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(encoded, forKey: .encoded)
        try container.encode(raw, forKey: .raw)
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        encoded = try container.decode(String.self, forKey: .encoded)
        raw = try container.decode(String.self, forKey: .raw)
    }
}

extension String
{
    var isNumber: Bool
    {
        let characters = CharacterSet.decimalDigits
        
        return CharacterSet(charactersIn: self).isSubset(of: characters)
    }
}
