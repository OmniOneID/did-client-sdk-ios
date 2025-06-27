//
//  Tokenizer.swift
//
//
//  Created by Rob Napier on 1/31/21.
//

import Foundation

// TODO: Track token locations in order to provide better error messages

public protocol JSONToken {
    var data: Data { get }
    var possiblyTruncated: Bool { get }
    var isIgnored: Bool { get }
    var location: Int { get }
}

public extension JSONToken {
    var length: Int { data.count }
    var possiblyTruncated: Bool { false }
    var isIgnored: Bool { false }
    var location: Int { data.startIndex }
}

public struct JSONTokenArrayOpen: JSONToken { public let data = Data("[".utf8); public var location: Int }
public struct JSONTokenArrayClose: JSONToken { public let data = Data("]".utf8); public var location: Int }

public struct JSONTokenObjectOpen: JSONToken { public let data = Data("{".utf8); public var location: Int }
public struct JSONTokenObjectClose: JSONToken { public let data = Data("}".utf8); public var location: Int }

public struct JSONTokenKeyValueSeparator: JSONToken { public let data = Data(":".utf8); public var location: Int }
public struct JSONTokenListSeparator: JSONToken { public let data = Data(",".utf8); public var location: Int }

public struct JSONTokenLiteralTrue: JSONToken { public let data = Data("true".utf8); public var location: Int }
public struct JSONTokenLiteralFalse: JSONToken { public let data = Data("false".utf8); public var location: Int }
public struct JSONTokenLiteralNull: JSONToken { public let data = Data("null".utf8); public var location: Int }

public struct JSONTokenString: JSONToken {
    public var data: Data
    public var contents: String? { String(data: data.dropFirst().dropLast(), encoding: .utf8) }
}

public struct JSONTokenNumber: JSONToken {
    public var data: Data
    public var possiblyTruncated: Bool
    public var contents: String? { String(data: data, encoding: .utf8) }
}

public struct JSONTokenWhitespace: JSONToken {
    public var data: Data
    public var possiblyTruncated: Bool
    public var isIgnored: Bool { true }
}

// Tokenizer splits up Data into semantic components.
// The resulting Tokens can be used to reconstruct the original JSON, including whitespace.
// Tokenizer does the bare minimum required to tokenize. It does not verify that the JSON if valid. For
// example, it does not parse strings; it just looks for a double-quote followed by a non-escaped
// double-quote. This allows parsers to deal with many kinds of technically invalid JSON.

public class JSONTokenizer {
    public init() {}
    private let whitespaceBytes: [UInt8] = [0x09, 0x0a, 0x0d, 0x20]
    private let newlineBytes: [UInt8] = [0x0a, 0x0d]
    private let numberBytes: [UInt8] = [0x2b,   // +
                                        0x2d,   // -
                                        0x2e,   // .
                                        0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, // 0-9
                                        0x45,   // E
                                        0x65    // e
    ]

    public func allTokens(from data: Data) throws -> [JSONToken] {
        var json = data
        var tokens: [JSONToken] = []
        while !json.isEmpty {
            let result = try firstToken(from: json)
            tokens.append(result)
            json.removeFirst(result.length)
        }
        return tokens
    }

    // Extracts first token. Returns nil if incomplete token is found. Throws for invalid token. Note that
    // it is possible for a number to be incomplete if data is not complete. It is up to the caller to check
    // for that situation.
    public func firstToken(from data: Data) throws -> JSONToken {
        guard let byte = data.first else {
            throw JSONError.dataTruncated
        }

        switch byte {
        case 0x5b: // [
            return JSONTokenArrayOpen(location: data.startIndex)

        case 0x7b: // {
            return JSONTokenObjectOpen(location: data.startIndex)

        case 0x5d: // ]
            return JSONTokenArrayClose(location: data.startIndex)

        case 0x7d: // }
            return JSONTokenObjectClose(location: data.startIndex)

        case 0x3a: // :
            return JSONTokenKeyValueSeparator(location: data.startIndex)

        case 0x2c: // ,
            return JSONTokenListSeparator(location: data.startIndex)

        case 0x74: // t(rue)
            return try extract(JSONTokenLiteralTrue(location: data.startIndex), from: data)

        case 0x66: // f(alse)
            return try extract(JSONTokenLiteralFalse(location: data.startIndex), from: data)

        case 0x6E: // n(ull)
            return try extract(JSONTokenLiteralNull(location: data.startIndex), from: data)

        case 0x22: // "
            return try extractString(from: data)

        case 0x2d, 0x30...0x39: // -, 0-9
            return extractNumber(from: data)

        case 0x09, 0x0a, 0x0d, 0x20: // consume whitespace
            return extractWhitespace(from: data)

        default:
            throw JSONError.unexpectedByte(at: data.startIndex, found: [byte])
        }
    }

    // data must begin with a prefix of needle, or this throws.
    private func extract(_ token: JSONToken, from data: Data) throws -> JSONToken {
        let needle = token.data

        // Check that the starting data matches needle
        guard data.starts(with: needle.prefix(data.count)) else {
            throw JSONError.unexpectedByte(at: data.startIndex, found: Array(token.data.prefix(needle.count)))
        }

        // Check that the complete needle is found
        guard data.count >= needle.count else {
            throw JSONError.dataTruncated
        }

        return token
    }

    // Extracts a complete string (including quotation marks). If the string is incomplete, throw .dataTruncated.
    // Does not validate string. Any characters between unescaped double-quotes are returned.
    private func extractString(from data: Data) throws -> JSONToken {
        var index = data.index(after: data.startIndex) // Drop leading "

        LOOP: while index < data.endIndex {
            switch data[index] {
            case 0x5c: // \
                // Don't worry about what the next character is. At this point, we're not validating
                // the string, just looking for an unescaped double-quote.
                if !data.formIndex(&index, offsetBy: 2, limitedBy: data.endIndex) {
                    // Couldn't advance by 2, so data ends in a \
                    break LOOP
                }

            case 0x22: // "
                return JSONTokenString(data: data.prefix(through: index))

            default:
                index = data.index(after: index)
            }
        }

        // Couldn't find end of string
        throw JSONError.dataTruncated
    }

    // Extracts a number. Does not validate the number. Any sequence of "number-like" characters is accepted.
    // Note that it is possible that this number is truncated if data is incomplete; the caller must check for that situation.
    private func extractNumber(from data: Data) -> JSONToken {
        let number = data.prefix { numberBytes.contains($0) }
        return JSONTokenNumber(data: number, possiblyTruncated: number.count == data.count)
    }

    // Extracts whitespace until the last newline character. This splits trailing whitespace from indentation.
    // Blank lines are attached to the trailing whitespace
    private func extractWhitespace(from data: Data) -> JSONToken {
        let allWhitespace = data.prefix(while: { whitespaceBytes.contains($0) })
        let endTrailingIndex = allWhitespace.lastIndex(where: { newlineBytes.contains($0) } )?.advanced(by: 1) ?? allWhitespace.endIndex
        let trailingWhitespace = allWhitespace[..<endTrailingIndex]
        return JSONTokenWhitespace(data: trailingWhitespace, possiblyTruncated: trailingWhitespace.count == data.count)
    }
}
