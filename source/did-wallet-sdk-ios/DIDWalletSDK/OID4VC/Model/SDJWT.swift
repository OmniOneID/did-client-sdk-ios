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

public struct SDJWT: Jsonable {
    public let credentialJwt: String
    public let disclosures: [Disclosure]
    public var keyBindingJwt: String?
    
    public init(credentialJwt: String, disclosures: [Disclosure] = [], keyBindingJwt: String? = nil) {
        self.credentialJwt = credentialJwt
        self.disclosures   = disclosures
        self.keyBindingJwt = keyBindingJwt
    }
    
    public static func parse(raw: String) -> SDJWT {
        let parts = raw.components(separatedBy: "~")
        guard !parts.isEmpty else {
            return SDJWT(credentialJwt: raw, disclosures: [], keyBindingJwt: nil)
        }

        let credentialJwt = parts[0]
        let hasKeyBinding = raw.getCount(of: ".") >= 4

        let startIndexForDisclosures = 1
        let endIndexForDisclosuresExclusive = hasKeyBinding ? (parts.count - 1) : parts.count
        let disclosureSegments: [String]
        if startIndexForDisclosures < endIndexForDisclosuresExclusive {
            disclosureSegments = Array(parts[startIndexForDisclosures..<endIndexForDisclosuresExclusive])
        } else {
            disclosureSegments = []
        }

        let disclosures = disclosureSegments.compactMap { Disclosure.parse(raw: $0) }
        let keyBindingJwt: String? = hasKeyBinding ? parts.last : nil

        return SDJWT(credentialJwt: credentialJwt, disclosures: disclosures, keyBindingJwt: keyBindingJwt)
    }
    
    /// Converts the SDJWT structure into its string representation.
    /// - Returns: The SD-JWT string.
    public func toString() -> String {
        var jwt = credentialJwt
        for disclosure in disclosures {
            jwt.append("~\(disclosure.getDisclosure())")
        }
        jwt.append("~")
        if let keyBinding = keyBindingJwt {
            jwt.append(keyBinding)
        }
        return jwt
    }
}

/// A structure representing a disclosure within an SD-JWT.
public struct Disclosure: Codable, Equatable {
    public let salt: String
    public let claimName: String?
    public let claimValue: JSON

    /// Initializes a new instance of Disclosure.
    public init(salt: String, claimName: String?, claimValue: JSON) {
        self.salt = salt
        self.claimName = claimName
        self.claimValue = claimValue
    }

    /// Converts the disclosure into its raw data representation.
    /// - Returns: The data representation.
    func toData() -> Data {
        var arr: [JSON] = [.string(salt)]
        if let claimName = claimName {
            arr.append(.string(claimName))
        }
        arr.append(claimValue)

        let encoder = RNJSONEncoder()
        return (try? encoder.encode(arr)) ?? Data()
    }

    /// Returns the base64URL-encoded disclosure string.
    /// - Returns: The disclosure string.
    public func getDisclosure() -> String {
        return self.toData().base64URLEncoded
    }

    /// Returns a base64-encoded digest of the disclosure.
    /// - Returns: The digest string.
    public func digest() -> String {
        return self.toData().sha256().base64URLEncoded
    }

    /// Parses a raw disclosure string into a Disclosure structure.
    /// - Parameter raw: The base64URL-encoded disclosure string.
    /// - Returns: A Disclosure instance if parsing is successful.
    public static func parse(raw: String) -> Disclosure? {
        
        guard let decoded = raw.base64URLDecoded else { return nil }

        let top: JSON
        do {
            top = try JSONParser().parse(data: decoded)
        } catch {
            return nil
        }

        guard case let .array(items) = top, items.count >= 2 else { return nil }
        guard case let .string(salt) = items[0] else { return nil }

        if items.count == 3 {
            guard case let .string(claimName) = items[1] else { return nil }
            let claimValue = items[2]
            return Disclosure(salt: salt, claimName: claimName, claimValue: claimValue)
        }

        if items.count == 2 {
            let claimValue = items[1]
            return Disclosure(salt: salt, claimName: nil, claimValue: claimValue)
        }

        return nil
    }
}
