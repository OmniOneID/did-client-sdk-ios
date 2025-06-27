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
import OrderedCollections

public enum CredentialType : String, Codable
{
    case cl  = "CL"
}

public struct ZKPCredentialDefinition : Jsonable, OrderedJson
{
    public let id: String
    public let schemaId: String
    public let ver : String
    public let type : CredentialType
    public let value : CredentialDefinitionValue
    public let tag : String
}

public struct CredentialDefinitionValue : Jsonable, OrderedJson
{
    public let primary : CredentialPrimaryPublicKey
}

public struct CredentialPrimaryPublicKey : Jsonable, OrderedJson
{
    public let n : BigIntString
    public let z : BigIntString
    public let s : BigIntString
    public var r : OrderedDictionary<String, BigIntString>
    public let rctxt : BigIntString
}

extension CredentialPrimaryPublicKey
{
    enum CodingKeys: String, CodingKey
    {
        case n,
             z,
             s,
             r,
             rctxt
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(n, forKey: .n)
        try container.encode(z, forKey: .z)
        try container.encode(s, forKey: .s)
    
        var rContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .r)
        r.keys.forEach { key in
            try! rContainer.encode(r[key]!, forKey: AnyCodingKey(stringValue: key)!)
        }
        try container.encode(rctxt, forKey: .rctxt)
    }

    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        n = try container.decode(BigIntString.self, forKey: .n)
        
        z = try container.decode(BigIntString.self, forKey: .z)
        
        s = try container.decode(BigIntString.self, forKey: .s)

        let rContainer = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .r)

        r = .init()

        for key in rContainer.allKeys
        {
            let rValueString = try rContainer.decode(BigIntString.self, forKey: key)
            r[key.stringValue] = rValueString
        }
        
        rctxt = try container.decode(BigIntString.self, forKey: .rctxt)
    }
}
