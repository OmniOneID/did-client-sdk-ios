//
//  Writer.swift
//  
//
//  Created by Rob Napier on 3/28/21.
//

import Foundation

public class JSONWriter {
    public struct Options : OptionSet {
        public var rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let prettyPrinted = Options(rawValue: 1 << 0)

        /* Sorts dictionary keys for output using [NSLocale systemLocale]. Keys are compared using NSNumericSearch. The specific sorting method used is subject to change.
         */
        public static var sortedKeys = Options(rawValue: 1 << 1)
        public static var withoutEscapingSlashes = Options(rawValue: 1 << 3)
    }

    public init(options: Options = []) { self.options = options }

    public let options: Options

    public func encode(_ value: JSON) throws -> String {
        try encode(value, depth: 0)
    }

    private func encode(_ value: JSON, depth: Int) throws -> String {
        switch value {
        case let .string(string): return escaped("\"\(string)\"")
        case let .number(digits): return digits
        case let .bool(value): return value ? "true" : "false"
        case let .object(object): return try encode(object: object, depth: depth)
        case let .array(array): return try encode(array: array, depth: depth)
        case .null: return "null"
        }
    }

    private func encode(object: [(key: String, value: JSON)], depth: Int) throws -> String {
        var afterBrace = ""
        var outsideIndent = ""
        var insideIndent = ""
        var aroundColon = ""
        var afterComma = ""

        if options.contains(.prettyPrinted) {
            afterBrace = "\n"
            outsideIndent = String(repeating: " ", count: 2 * depth)
            insideIndent = String(repeating: " ", count: 2 * (depth + 1))
            aroundColon = " "
            afterComma = "\n"
        }

        let keyValues = options.contains(.sortedKeys) ? object.sorted(by: { $0.key < $1.key }) : object

        let body = try keyValues.map { key, value in
            try "\(insideIndent)\"\(key)\"\(aroundColon):\(aroundColon)\(encode(value))"
        }
        .joined(separator: ",\(afterComma)")

        return "\(outsideIndent){\(afterBrace)\(body)\(afterComma)\(outsideIndent)}"
    }

    // FIXME: Doesn't pretty-print
    private func encode(array: [JSON], depth: Int) throws -> String {
        let values = try array.map { (value) in try encode(value) }
        let body = values.joined(separator: ",")
        return "[\(body)]"
    }

    private func escaped(_ string: String) -> String {
        return options.contains(.withoutEscapingSlashes) ? string : string.replacingOccurrences(of: "/", with: "\\/")
    }
}
