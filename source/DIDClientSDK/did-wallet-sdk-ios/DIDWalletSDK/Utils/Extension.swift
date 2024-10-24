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
import CommonCrypto

extension Digest
{
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    var hexStr: String
    {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
public extension Data {
    
    func sha256() -> String {
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}
public extension String {
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
    
    func base64() -> String {
        if let strData = self.data(using: .utf8) {
            return strData.base64EncodedString()
        }
        
        return ""
    }
}



extension Character
{
    func toUInt8() -> UInt8
    {
        return String(self).utf8.map{UInt8($0)}[0]
    }
}

public typealias DataModelable = Jsonable & Loopable

public protocol Loopable : Hashable {

    var allProperties: [String : Any] { get }

    override static func == (lhs: Self, rhs: Self) -> Bool
}

extension Loopable {

    public var allProperties: [String: Any]
    {
        var result = [String: Any]()
        Mirror(reflecting: self).children.forEach { child in
            if let property = child.label {
                result[property] = child.value
            }
        }
        return result
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashedValue() == rhs.hashedValue()
    }
    
    func hashedValue() -> Int
    {
        var hasher: Hasher = .init()
        self.hash(into: &hasher)
        let hashed = hasher.finalize()
        
        return hashed
    }
    
    public func hash(into hasher: inout Hasher)
    {
        let properties = allProperties
        for key in properties.keys.sorted() {
            
            if let h = properties[key] as? AnyHashable {
                let cover = "\(h)"
                hasher.combine(cover)
            }
        }
    }}

public protocol Jsonable : Codable
{
    init(from jsonData: Data) throws
    init(from jsonString: String) throws
    func toJsonData(isPretty: Bool) throws -> Data
    func toJson(isPretty: Bool) throws -> String
}

public extension Jsonable
{
    init(from jsonData: Data) throws {
        do
        {
            self = try JSONDecoder().decode(Self.self, from: jsonData)
        }
//        catch let e
//        {
//            throw OdiError.genError2(code:JsonError.failToDecode, message: e.localizedDescription)
//        }
    }
    
    init(from jsonString: String) throws {
        let data = jsonString.data(using: .utf8)! 
//        else
//        {
//            throw OdiError.genError2(code:JsonError.failToData)
//        }
        
        try self.init(from: data)
    }
    
    func toJsonData(isPretty: Bool = false) throws -> Data {
        var formatting : JSONEncoder.OutputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        if isPretty
        {
            formatting.insert(.prettyPrinted)
        }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = formatting
        
        do
        {
            let data = try jsonEncoder.encode(self)
            return data
        }
//        catch let e
//        {
//            throw OdiError.genError2(code:JsonError.failToEncode,message: e.localizedDescription)
//        }
    }
    
    func toJson(isPretty: Bool = false) throws -> String {
        return String(data: try toJsonData(isPretty: isPretty), encoding: .utf8)!
    }
    
}
