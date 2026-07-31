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

// MARK: - AnyJSON (lossless JSON value container)

public enum AnyJSON: Codable, Equatable, Hashable, Sendable {
    case null
    case bool(Bool)
    case number(Double)          // JSON numbers; keep as Double
    case string(String)
    case array([AnyJSON])
    case object([String: AnyJSON])

    // Convenience accessors
    public var asBool: Bool? { if case .bool(let v) = self { return v } else { return nil } }
    public var asDouble: Double? { if case .number(let v) = self { return v } else { return nil } }
    public var asString: String? { if case .string(let v) = self { return v } else { return nil } }
    public var asArray: [AnyJSON]? { if case .array(let v) = self { return v } else { return nil } }
    public var asObject: [String: AnyJSON]? { if case .object(let v) = self { return v } else { return nil } }

    // Convert to Foundation types for JSONSerialization / path navigation
    public func toFoundation() -> Any {
        switch self {
        case .null: return NSNull()
        case .bool(let b): return b
        case .number(let n): return n
        case .string(let s): return s
        case .array(let a): return a.map { $0.toFoundation() }
        case .object(let o): return o.mapValues { $0.toFoundation() }
        }
    }

    // Create from Foundation JSON types
    public static func fromFoundation(_ value: Any) -> AnyJSON? {
        if value is NSNull { return .null }
        // NSNumber must be inspected before any Bool cast. JSONSerialization returns every JSON
        // scalar as NSNumber, and `as? Bool` also succeeds for the numbers 0 and 1 — testing Bool
        // first would turn those numbers into booleans and break every value/min/max comparison.
        // Only a CFBoolean is a real JSON boolean.
        if let n = value as? NSNumber {
            if CFGetTypeID(n as CFTypeRef) == CFBooleanGetTypeID() { return .bool(n.boolValue) }
            return .number(n.doubleValue)
        }
        if let b = value as? Bool { return .bool(b) }
        if let s = value as? String { return .string(s) }
        if let a = value as? [Any] {
            return .array(a.compactMap { AnyJSON.fromFoundation($0) })
        }
        if let o = value as? [String: Any] {
            var dict: [String: AnyJSON] = [:]
            for (k, v) in o {
                if let j = AnyJSON.fromFoundation(v) {
                    dict[k] = j
                } else {
                    // Non-JSON value -> drop as null (shouldn't happen with JSONSerialization)
                    dict[k] = .null
                }
            }
            return .object(dict)
        }
        return nil
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if c.decodeNil() {
            self = .null
            return
        }

        if let b = try? c.decode(Bool.self) {
            self = .bool(b)
            return
        }

        // Decode numbers as Double. This preserves JSON numeric semantics.
        if let n = try? c.decode(Double.self) {
            self = .number(n)
            return
        }

        if let s = try? c.decode(String.self) {
            self = .string(s)
            return
        }

        if let a = try? c.decode([AnyJSON].self) {
            self = .array(a)
            return
        }

        if let o = try? c.decode([String: AnyJSON].self) {
            self = .object(o)
            return
        }

        throw DecodingError.typeMismatch(
            AnyJSON.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value")
        )
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()

        switch self {
        case .null:
            try c.encodeNil()
        case .bool(let b):
            try c.encode(b)
        case .number(let n):
            try c.encode(n)
        case .string(let s):
            try c.encode(s)
        case .array(let a):
            try c.encode(a)
        case .object(let o):
            try c.encode(o)
        }
    }

    // MARK: Hashable (canonical JSON)

    public func hash(into hasher: inout Hasher) {
        // Stable canonical JSON ensures hash stability for object key ordering etc.
        hasher.combine(canonicalJSONString())
    }

    private func canonicalJSONString() -> String {
        // Encode as canonical JSON (sorted keys for objects).
        // Not the fastest, but robust and deterministic for hashing/equality validation use-cases.
        switch self {
        case .null:
            return "null"
        case .bool(let b):
            return b ? "true" : "false"
        case .number(let n):
            // Use JSON-style minimal representation where possible.
            // Avoid scientific notation differences by using a normalized string.
            if n.isNaN || n.isInfinite { return "null" } // JSON can't represent these
            // Strip trailing .0 if integer-like
            if floor(n) == n { return String(format: "%.0f", n) }
            // Use a reasonable precision
            return String(n)
        case .string(let s):
            return AnyJSON.escapeJSONString(s)
        case .array(let a):
            return "[" + a.map { $0.canonicalJSONString() }.joined(separator: ",") + "]"
        case .object(let o):
            let keys = o.keys.sorted()
            let parts = keys.map { key -> String in
                let k = AnyJSON.escapeJSONString(key)
                let v = o[key]?.canonicalJSONString() ?? "null"
                return "\(k):\(v)"
            }
            return "{" + parts.joined(separator: ",") + "}"
        }
    }

    private static func escapeJSONString(_ s: String) -> String {
        // Minimal JSON string escaping
        var out = "\""
        for ch in s.unicodeScalars {
            switch ch.value {
            case 0x22: out += "\\\""        // "
            case 0x5C: out += "\\\\"        // \
            case 0x08: out += "\\b"
            case 0x0C: out += "\\f"
            case 0x0A: out += "\\n"
            case 0x0D: out += "\\r"
            case 0x09: out += "\\t"
            default:
                if ch.value < 0x20 {
                    out += String(format: "\\u%04X", ch.value)
                } else {
                    out += String(ch)
                }
            }
        }
        out += "\""
        return out
    }
}
