//
/*
 * Copyright 2026 OmniOne.
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

/// A JSON Web Key. Only EC P-256 keys are modelled: `x` and `y` are the required coordinates.
///
/// Callers read this type — for example off a `JWSHeader` — but do not construct it; the
/// memberwise initializer stays internal to the SDK.
public struct JWK: Jsonable
{
    public var alg : Algorithm?
    public var kid : String?
    public var crv : Curve      = .p256
    public var kty : KeyType    = .ec
    public var x   : String
    public var y   : String
    public var use : JWKUse?

    public enum Algorithm: Jsonable, Equatable
    {
        case es256
        case ecdhES
        case unknown(String)
    }

    public enum Curve: Jsonable, Equatable
    {
        case p256
        case unknown(String)
    }

    public enum KeyType: Jsonable, Equatable
    {
        case ec
        case unknown(String)
    }

    public enum JWKUse: String, Jsonable, Equatable
    {
        case sig
        case enc
    }

}


extension JWK.KeyType
{
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "EC":
            self = .ec
        default:
            self = .unknown(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .ec:
            try container.encode("EC")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}

extension JWK.Curve
{
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "P-256":
            self = .p256
        default:
            self = .unknown(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .p256:
            try container.encode("P-256")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}

extension JWK.Algorithm
{
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "ES256":
            self = .es256
        case "ECDH-ES":
            self = .ecdhES
        default:
            self = .unknown(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .es256:
            try container.encode("ES256")
        case .ecdhES:
            try container.encode("ECDH-ES")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}


