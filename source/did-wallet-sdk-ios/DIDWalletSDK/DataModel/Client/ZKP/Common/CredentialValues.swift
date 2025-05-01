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

struct CredentialValues
{
    struct CredentialValue
    {
        enum AttributeType
        {
            case known
            case hidden
        }
        
        let type : AttributeType
        let value : BigIntString
    }
    
    var attrValues : [String : CredentialValue] = .init()
    
    mutating func addHidden(key : String, value : BigIntString) throws
    {
        try addValue(type: .hidden, key: key, value: value)
    }
    
    mutating func addHidden(key : String, value : AttributeValue) throws
    {
        try addHidden(key: key, value: value.encoded)
    }
    
    mutating func addKnown(key : String, value : BigIntString) throws
    {
        try addValue(type: .known, key: key, value: value)
    }
    
    mutating func addKnown(key : String, value : AttributeValue) throws
    {
        try addKnown(key: key, value: value.encoded)
    }
    
    private mutating func addValue(type : CredentialValue.AttributeType, key : String, value : BigIntString) throws
    {
        if attrValues.contains(where: { $0.key == key })
        {
            throw ZKPManagerError.duplicated(detail: key).getError()
        }
        
        attrValues[key] = .init(type: type, value: value)
    }
}

extension CredentialValues
{
    static func generateCredentialValues(credValues : [String : AttributeValue], masterSecret : BigIntString) throws -> CredentialValues
    {
        var credentialValues = CredentialValues()
        
        try credentialValues.addHidden(key: ZKPConstants.masterSecretKey, value: masterSecret)
        
        for (key, value) in credValues
        {
            try credentialValues.addKnown(key: key, value: value)
        }
        
        return credentialValues
    }
}
