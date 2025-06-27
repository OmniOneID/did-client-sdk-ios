//
//  Parser.swift
//  
//
//  Created by Rob Napier on 2/28/21.
//

import Foundation

public class JSONParser {
    public init() {}

    public func parse(data: Data) throws -> JSON {
        var tokens = try JSONTokenizer().allTokens(from: data)[...]
        let value = try parseValue(for: &tokens)
        tokens.removeWhitespace()
        guard tokens.isEmpty else { throw JSONError.unexpectedToken(at: tokens.first!.location, expected: [], found: tokens.first!) }
        return value
    }

    private func parseValue<Tokens>(for tokens: inout Tokens) throws -> JSON where Tokens: Collection, Tokens.Element == JSONToken, Tokens.SubSequence == Tokens {
        let token = try tokens.requireToken()

        switch token {
        case is JSONTokenArrayOpen:    return try parseArray(for: &tokens)
        case is JSONTokenObjectOpen:   return try parseObject(for: &tokens)
        case is JSONTokenLiteralTrue:  return .bool(true)
        case is JSONTokenLiteralFalse: return .bool(false)
        case is JSONTokenLiteralNull:  return .null
        case let t as JSONTokenString: return try .init(t)
        case let t as JSONTokenNumber: return try .init(t)
        default:                       throw JSONError.unexpectedToken(at: token.location, expected: [JSONTokenArrayOpen.self, JSONTokenObjectOpen.self, JSONTokenLiteralTrue.self, JSONTokenLiteralFalse.self, JSONTokenLiteralNull.self, JSONTokenString.self, JSONTokenNumber.self], found: token)
        }
    }

    func parseArray<Tokens>(for tokens: inout Tokens) throws -> JSON where Tokens: Collection, Tokens.Element == JSONToken, Tokens.SubSequence == Tokens {
        var elements: JSONArray = []

        // Check the first token. It may be an empty list
        do {
            elements.append(try parseValue(for: &tokens))
        } catch let JSONError.unexpectedToken(at: _, expected: _, found: found) where found is JSONTokenArrayClose {
            return .array(elements)
        }

        // Check the rest of the tokens
        while true {
            let token = try tokens.requireToken()
            switch token {
            case is JSONTokenArrayClose: return .array(elements)
            case is JSONTokenListSeparator: elements.append(try parseValue(for: &tokens))

            default: throw JSONError.unexpectedToken(at: token.location,
                                                     expected: [JSONTokenArrayClose.self, JSONTokenListSeparator.self],
                                                     found: token)
            }
        }
    }

    func parseObject<Tokens>(for tokens: inout Tokens) throws -> JSON where Tokens: Collection, Tokens.Element == JSONToken, Tokens.SubSequence == Tokens {
        var object: JSONKeyValues = []

        var token = try tokens.requireToken()
        if token is JSONTokenObjectClose { return .object(keyValues: object) }

        while true {
            guard let stringToken = token as? JSONTokenString
            else { throw JSONError.unexpectedToken(at: token.location, expected: [JSONTokenString.self], found: token) }

            guard let key = stringToken.contents else { throw JSONError.dataCorrupted }

            let separator = try tokens.requireToken()
            guard separator is JSONTokenKeyValueSeparator else {
                throw JSONError.unexpectedToken(at: separator.location,
                                                expected: [JSONTokenKeyValueSeparator.self],
                                                found: separator)
            }

            object.append((key: key, value: try parseValue(for: &tokens)))

            token = try tokens.requireToken()

            switch token {
            case is JSONTokenObjectClose: return .object(keyValues: object)
            case is JSONTokenListSeparator: token = try tokens.requireToken()
            default: throw JSONError.unexpectedToken(at: token.location, expected: [JSONTokenObjectClose.self, JSONTokenListSeparator.self], found: token)
            }
        }
    }
}


private extension Collection where Element == JSONToken, SubSequence == Self {
    mutating func removeWhitespace() {
        while let token = self.first, token.isIgnored {
            self.removeFirst()
        }
    }

    mutating func requireToken() throws -> JSONToken {
        removeWhitespace()
        return try popFirst() ?? { throw JSONError.dataTruncated }()
    }
}
