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

//MARK: - Jsonable
/// Model to Json, and vice versa
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
        catch let e
        {
            throw e
        }
    }
    
    init(from jsonString: String) throws {
        let data = jsonString.data(using: .utf8)!
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
        catch let e
        {
            throw e
        }
    }
    
    func toJson(isPretty: Bool = false) throws -> String {
        return String(data: try toJsonData(isPretty: isPretty), encoding: .utf8)!
    }
}

//MARK: - Proof
/// General proof protocol
public protocol ProofProtocol : Jsonable
{
    var created : String { get set }
    var verificationMethod : String { get set }
    var proofPurpose : ProofPurpose { get set }
    var type : ProofType { get set }
    var proofValue : String? { get set }
}

/// Protocol contains proof
public protocol ProofContainer : Jsonable
{
    var proof : Proof? { get set }
}

/// Protocol contains multi proofs
public protocol ProofsContainer : Jsonable
{
    var proof  : Proof? { get set }
    var proofs : [Proof]? { get set }
}

/// Convertible to AlgorithmType protocol
public protocol ConvertibleToAlgorithmType : RawRepresentable where RawValue == String
{
    static var commonString : String { get }
    /// Convert to AlgorithmType
    ///
    /// - Returns: AlgorithmType
    func convertTo() -> AlgorithmType
}

public protocol ConvertibleFromAlgorithmType : RawRepresentable where RawValue == String
{
    static var commonString : String { get }
    
    /// Convert from AlgorithmType
    ///
    /// - Parameters:
    ///   - algorithmType: AlgorithmType value
    /// - Returns: Self type value
    static func convertFrom(algorithmType : AlgorithmType) -> Self
}

public typealias AlgorithmTypeConvertible = ConvertibleToAlgorithmType & ConvertibleFromAlgorithmType

extension ConvertibleToAlgorithmType
{
    public func convertTo() -> AlgorithmType
    {
        let rawString = self.rawValue.replacingOccurrences(of: Self.commonString,
                                                           with: emptyString)
        return AlgorithmType(rawValue: rawString)!
    }
}

extension ConvertibleFromAlgorithmType
{
    public static func convertFrom(algorithmType: AlgorithmType) -> Self
    {
        let rawString = algorithmType.rawValue + Self.commonString
        return Self.init(rawValue: rawString)!
    }
}


//MARK: Misc
let emptyString : String = ""
