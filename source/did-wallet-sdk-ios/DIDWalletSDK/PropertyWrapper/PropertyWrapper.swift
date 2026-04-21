/*
 * Copyright 2024-2026 OmniOne.
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

@propertyWrapper
public struct UTCDatetime: Codable
{
    // ISO 8601: yyyy-MM-dd'T'HH:mm:ss(.fraction)?(Z)?
    private static let regEx =
        #"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,9})?(Z)?$"#

    private var value: String

    public var wrappedValue: String {
        get { value }
        set {
            precondition(
                newValue.matches(regEx: Self.regEx),
                "\(newValue) does not match the regex \(Self.regEx)"
            )
            value = newValue
        }
    }

    public init(wrappedValue: String) {
        precondition(
            wrappedValue.matches(regEx: Self.regEx),
            "\(wrappedValue) does not match the regex \(Self.regEx)"
        )
        self.value = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decoded = try container.decode(String.self)

        guard decoded.matches(regEx: Self.regEx) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid UTCDatetime: \(decoded)"
            )
        }

        self.value = decoded
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}


@propertyWrapper
public struct DIDVersionId : Codable
{
    private static let regEx : String = "^[0-9]+$"
    private var value : String

    public var wrappedValue : String
    {
        get{ self.value }
        set{
            precondition(
                newValue.matches(regEx: Self.regEx),
                "\(newValue) does not match the regex \(Self.regEx)"
            )
            self.value = newValue
        }
    }
    
    public init(wrappedValue : String)
    {
        precondition(
            wrappedValue.matches(regEx: Self.regEx),
            "\(wrappedValue) does not match the regex \(Self.regEx)"
        )
        self.value = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decoded = try container.decode(String.self)

        guard decoded.matches(regEx: Self.regEx) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid DIDVersionId: \(decoded)"
            )
        }

        self.value = decoded
    }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

@propertyWrapper
public struct ValidURL : Codable
{
    private var value: String

    public var wrappedValue: String {
        get { value }
        set {
            precondition(
                URL(string: newValue) != nil,
                "\(wrappedValue) is not valid URL."
            )
            value = newValue
        }
    }

//    var projectedValue: URL? {
//        URL(string: value)
//    }

    public init(wrappedValue: String) {
        precondition(
            URL(string: wrappedValue) != nil,
            "\(wrappedValue) is not valid URL."
        )
        self.value = wrappedValue
    }
    
    private static func isValid(_ string: String) -> Bool {
        guard let url = URL(string: string),
              url.scheme != nil,
              url.host != nil else {
            return false
        }
        return true
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        guard Self.isValid(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid URL string: \(string)"
            )
        }
        
        self.value = string
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension ValidURL
{
    func appendingPath(_ component: String) -> String
    {
        URL(string: wrappedValue)!
            .appendingPathComponent(component)
            .absoluteString
    }
}
