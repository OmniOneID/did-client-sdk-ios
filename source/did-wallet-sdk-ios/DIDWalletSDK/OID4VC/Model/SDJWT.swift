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
    
    public func getSignSource() -> (String, String)
    {
        var separated = credentialJwt.components(separatedBy: ".")
        
        let signature = separated.popLast()!
        let source = separated.joined(separator: ".")
        
        return (source, signature)
    }
}

/// A structure representing a disclosure within an SD-JWT.
public struct Disclosure: Codable, Equatable, Sendable {
    public let salt: String
    public let claimName: String?
    public let claimValue: JSON

    /// The issuer's disclosure string, exactly as it arrived.
    ///
    /// The credential's `_sd` digests are computed over these exact bytes, and JSON serialization is
    /// not canonical — re-encoding the decoded value can change spacing or member order and would
    /// make every digest mismatch at the verifier. A disclosure that was parsed from a credential is
    /// therefore presented byte-for-byte. `nil` for a disclosure built in code, which has no
    /// issuer-supplied form and is serialized on demand.
    public let raw: String?

    /// Initializes a new instance of Disclosure.
    public init(salt: String, claimName: String?, claimValue: JSON) {
        self.init(salt: salt, claimName: claimName, claimValue: claimValue, raw: nil)
    }

    init(salt: String, claimName: String?, claimValue: JSON, raw: String?) {
        self.salt = salt
        self.claimName = claimName
        self.claimValue = claimValue
        self.raw = raw
    }

    /// Two disclosures are equal when they carry the same claim, regardless of how each was
    /// serialized: `raw` is a transport detail, not part of the disclosure's identity.
    public static func == (lhs: Disclosure, rhs: Disclosure) -> Bool {
        return lhs.salt == rhs.salt
            && lhs.claimName == rhs.claimName
            && lhs.claimValue == rhs.claimValue
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
    ///
    /// A parsed disclosure returns the issuer's original string; only a disclosure built in code is
    /// serialized here.
    /// - Returns: The disclosure string.
    public func getDisclosure() -> String {
        return raw ?? self.toData().base64URLEncoded
    }

    /// Returns a base64URL-encoded digest of the disclosure.
    ///
    /// SD-JWT hashes the US-ASCII bytes of the *base64url-encoded* disclosure, not the JSON those
    /// bytes decode to, so the digest is taken over `getDisclosure()`. This is what the credential's
    /// `_sd` entries hold, which is how a disclosure is matched to its digest.
    /// - Returns: The digest string.
    public func digest() -> String {
        return Data(self.getDisclosure().utf8).sha256().base64URLEncoded
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
            return Disclosure(salt: salt, claimName: claimName, claimValue: claimValue, raw: raw)
        }

        if items.count == 2 {
            let claimValue = items[1]
            return Disclosure(salt: salt, claimName: nil, claimValue: claimValue, raw: raw)
        }

        return nil
    }
}
