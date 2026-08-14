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
    
    /// The DID of the issuer that signed this credential, for a screen that names who issued it.
    ///
    /// Read from the issuer JWT's `kid` rather than from the payload's `iss`. Both are covered by
    /// the signature, but they answer different questions: `iss` is what the issuer wrote about
    /// itself, while `kid` is the key the signature was actually checked against at issuance. Where
    /// the two disagree, `kid` is the one with a verification behind it.
    ///
    /// `nil` when the credential JWT cannot be read or its `kid` is not a DID URL — neither happens
    /// for a credential this SDK stored, since issuance needs that DID to verify at all. Mirrors
    /// `Mdoc.issuerDid`, so a screen can name the issuer of either format the same way.
    public var issuerDid: String? {
        guard let kid = try? JWS(from: credentialJwt).protectedHeader.kid else { return nil }
        return DIDUtility.parseDIDKeyIdentifier(kid)?.did
    }

    /// Every claim the holder can be asked to consent to, each carrying the code that names it.
    ///
    /// The codes come from the same walk the presenter reads them back through, which is what an
    /// app cannot reproduce by parsing disclosures itself: whether a claim rides along with a
    /// parent already listed, whether it is in the clear, and whether one code names two claims are
    /// all decided by that walk.
    ///
    /// Ordered the way the issuer wrote the credential down: each claim sits where its own
    /// disclosure sits in the credential, matching how `Mdoc.consentItems` follows the order the
    /// issuer signed its elements in. Whatever the order came from, it is fixed per credential, so
    /// a screen drawn from it does not reshuffle between runs.
    ///
    /// One caveat on how much that order means. SD-JWT gives the tilde-separated disclosures no
    /// defined order — RFC 9901 constrains only the digests inside `_sd`, which the issuer must
    /// write in an order that hides the original one. So this is the order the issuer's serializer
    /// produced, not necessarily an order it chose for reading.
    ///
    /// Claims the issuer left in the clear have no disclosure and therefore no position; they come
    /// after the rest, ordered by code among themselves.
    /// Where this credential's revocation status is published, from the issuer-signed payload.
    ///
    /// A function rather than a property because the payload is only decoded on demand: an
    /// `SDJWT` holds the issuer JWT as a string until something asks it a question about the
    /// claims inside. `Mdoc.status` is a property for the mirror-image reason — an mdoc is decoded
    /// in full when it is parsed, so its answer is already in hand.
    ///
    /// `nil` when the credential carries no status list reference; the base standards make the
    /// claim optional. A reference the issuer wrote but wrote wrongly throws instead, so a `nil`
    /// always means "nothing to check" rather than "something we could not read".
    ///
    /// - Returns: The reference, or `nil` when the credential publishes no status.
    /// - Throws: `OID4VCManagerError.invalidJWS` when the payload cannot be read, or when it holds
    ///           a `status` that cannot be understood.
    public func status() throws -> StatusListReference? {
        return try StatusListReference.decode(payload: decodedPayload())
    }

    /// - Returns: The consentable claims, in disclosure order.
    /// - Throws: `OID4VCManagerError.invalidJWS` when the issuer JWT payload cannot be read.
    public func consentItems() throws -> [SdJwtConsentItem] {
        let payload = try decodedPayload()

        var positions: [String: Int] = [:]
        for (position, disclosure) in disclosures.enumerated() {
            positions[disclosure.getDisclosure()] = position
        }

        let index = SDJWTClaimIndex.build(sdjwt: self, payload: payload)
        return index.entries
            .filter { $0.value.isConsentItem }
            .map { code, entry in
                (position: entry.ownDisclosure.flatMap { positions[$0] },
                 item: SdJwtConsentItem(code: code,
                                        claimName: entry.claimName,
                                        value: entry.value,
                                        isAmbiguous: entry.isAmbiguous,
                                        isSelectivelyDisclosable: !entry.disclosures.isEmpty))
            }
            .sorted { left, right in
                switch (left.position, right.position) {
                case let (l?, r?): return l == r ? left.item.code < right.item.code : l < r
                case (nil, _?):    return false
                case (_?, nil):    return true
                case (nil, nil):   return left.item.code < right.item.code
                }
            }
            .map { $0.item }
    }

    /// The issuer JWT's payload, decoded.
    ///
    /// - Returns: The payload claims.
    /// - Throws: `OID4VCManagerError.invalidJWS` when the JWT cannot be read.
    private func decodedPayload() throws -> [String: Any] {
        do {
            return try SimpleJWTDecoder.parse(credentialJwt).payload
        } catch {
            throw OID4VCManagerError.invalidJWS(
                detail: "issuer JWT payload is not readable: \(error)").getError()
        }
    }

    public func getSignSource() -> (String, String)
    {
        var separated = credentialJwt.components(separatedBy: ".")
        
        let signature = separated.popLast()!
        let source = separated.joined(separator: ".")
        
        return (source, signature)
    }
}

/// One claim of an SD-JWT, as the holder is asked to consent to it.
///
/// `code` is the value that travels: matching names claims with it, the holder's selection is
/// expressed in it, and `createVpToken` resolves it back to the disclosures it needs. It is
/// opaque — display it and compare it, but never split it on `.` or `[]`, and never assemble one:
/// a claim named `"address.street_address"` in one piece is a different claim from `address` →
/// `street_address`, and only the side that walked the credential can tell them apart.
public struct SdJwtConsentItem: Sendable, Equatable {

    /// The claim code. Hand this back in `MatchedCredential.claimCodes` unchanged.
    public let code: String

    /// The last segment of the code, for a screen that shows a label rather than a path.
    public let claimName: String

    /// The claim's value.
    public let value: AnyJSON

    /// Whether this code names more than one claim of the credential. Presenting it fails rather
    /// than guessing which one the holder meant.
    public let isAmbiguous: Bool

    /// Whether withholding the claim actually hides it.
    ///
    /// `false` means the issuer left it in the clear: the verifier reads it from the issuer JWT
    /// whether or not the holder selects it. A screen that offered it as a choice would promise
    /// something the format cannot deliver.
    public let isSelectivelyDisclosable: Bool
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
