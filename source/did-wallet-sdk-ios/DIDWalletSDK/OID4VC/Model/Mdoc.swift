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

/// An ISO/IEC 18013-5 `IssuerSigned` mobile document, as issued over OpenID4VCI.
///
/// The credential is exposed as decoded claims, but it is stored and presented as the bytes the
/// issuer signed: `issuerSigned` is the original base64url string, and every digest in the MSO is
/// computed over the item bytes exactly as received. Re-encoding a decoded document would produce
/// valid CBOR that no longer matches those digests, so the original always travels alongside.
public struct Mdoc: Sendable, Equatable {

    /// The document type, e.g. `eu.europa.ec.eudi.pid.1`.
    public let docType: String

    /// The disclosed elements, by namespace and then by element identifier.
    ///
    /// An mdoc namespaces its claims, so two namespaces may each carry an element of the same name;
    /// nothing here flattens them into a single space.
    public let namespaces: [String: [String: MdocElementValue]]

    /// The document's validity window, from the MSO.
    public let validityInfo: MdocValidityInfo

    /// The `IssuerSigned` structure as received, base64url-encoded.
    public let issuerSigned: String

    /// The issuer's signature over the MSO.
    let issuerAuth: COSESign1

    /// The DID of the issuer that signed this document, for a screen that names who issued it.
    ///
    /// The value is trusted by way of verification rather than by the bytes themselves. The `kid`
    /// it comes from sits in `issuerAuth`'s unprotected header, which the signature does not cover,
    /// but issuance resolved that DID to a key and checked the signature against it — a substituted
    /// `kid` names a different key and fails that check. It follows that the property means nothing
    /// on a document that was only parsed: read it from a stored credential, which was verified
    /// when it was stored.
    ///
    /// `nil` when the document carries no `kid`, or one that is not a DID URL this SDK can read.
    /// Neither happens for a credential this SDK stored, since issuance needs the DID to verify at
    /// all.
    public var issuerDid: String? {
        return issuerAuth.keyIdentifier.flatMap { DIDUtility.parseDIDKeyIdentifier($0)?.did }
    }

    /// The MSO the issuer signed, decoded.
    let mso: MobileSecurityObject

    /// The issuer-signed items, by namespace, each keeping the bytes its digest was taken over.
    let items: [String: [MdocIssuerSignedItem]]

    /// Two documents are the same document when they are the same bytes. The decoded views are
    /// derived from those bytes, so comparing them as well would only be slower.
    public static func == (lhs: Mdoc, rhs: Mdoc) -> Bool {
        return lhs.issuerSigned == rhs.issuerSigned
    }

    /// Decodes an `IssuerSigned` from its base64url form.
    ///
    /// Parsing decodes; it does not verify. `WalletService.verifyMdoc` checks the issuer signature,
    /// the element digests and the validity window.
    /// - Parameter raw: The base64url-encoded `IssuerSigned` CBOR.
    /// - Returns: The decoded document.
    /// - Throws: `OID4VCManagerError.invalidMdoc` when the input is not a well-formed `IssuerSigned`.
    public static func parse(raw: String) throws -> Mdoc {
        guard let data = raw.base64URLDecoded else {
            throw OID4VCManagerError.invalidMdoc(detail: "not base64url").getError()
        }
        guard let top = try? CBOR.decode([UInt8](data)) else {
            throw OID4VCManagerError.invalidMdoc(detail: "not CBOR").getError()
        }
        guard case let .map(issuerSigned) = top else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSigned is not a map").getError()
        }
        guard let issuerAuthItem = issuerSigned["issuerAuth"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "no issuerAuth").getError()
        }
        guard case let .map(nameSpaces)? = issuerSigned["nameSpaces"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "no nameSpaces").getError()
        }

        let issuerAuth = try COSESign1.decode(issuerAuthItem)
        let mso = try MobileSecurityObject.decode(issuerAuth)

        var items: [String: [MdocIssuerSignedItem]] = [:]
        var claims: [String: [String: MdocElementValue]] = [:]
        for (namespaceKey, itemList) in nameSpaces {
            guard case let .utf8String(namespace) = namespaceKey else {
                throw OID4VCManagerError.invalidMdoc(detail: "namespace is not a string").getError()
            }
            guard case let .array(encodedItems) = itemList else {
                throw OID4VCManagerError.invalidMdoc(detail: "namespace \(namespace) is not an array").getError()
            }
            var decodedItems: [MdocIssuerSignedItem] = []
            var namespaceClaims: [String: MdocElementValue] = [:]
            for encodedItem in encodedItems {
                let item = try MdocIssuerSignedItem.decode(encodedItem)
                decodedItems.append(item)
                namespaceClaims[item.elementIdentifier] = item.elementValue
            }
            items[namespace] = decodedItems
            claims[namespace] = namespaceClaims
        }

        return Mdoc(docType: mso.docType,
                    namespaces: claims,
                    validityInfo: mso.validityInfo,
                    issuerSigned: raw,
                    issuerAuth: issuerAuth,
                    mso: mso,
                    items: items)
    }

    /// The document as it travels: the issuer's own bytes, unchanged.
    /// - Returns: The base64url-encoded `IssuerSigned`.
    public func toString() -> String {
        return issuerSigned
    }

    /// Every element the holder can be asked to consent to, each carrying the code that names it.
    ///
    /// A wallet screen has to show a row per element and then hand back the codes the holder
    /// agreed to. Both halves need the same naming, so the codes here are built by the same type
    /// the presenter reads them back through — an app that assembled `"namespace.element"` itself
    /// would be a second implementation of that naming, and the two would disagree exactly where it
    /// matters (see `isAmbiguous`).
    ///
    /// The order is the issuer's: elements come in the order they were signed, namespaces in name
    /// order. `namespaces` cannot give that — it is a `Dictionary`, so its iteration order differs
    /// from run to run, and a screen drawn from it would reshuffle itself.
    public var consentItems: [MdocConsentItem] {
        var codeCounts: [String: Int] = [:]
        for (namespace, namespaceItems) in items {
            for item in namespaceItems {
                let code = MdocClaimIndex.code(namespace: namespace,
                                               elementIdentifier: item.elementIdentifier)
                codeCounts[code, default: 0] += 1
            }
        }

        return items.keys.sorted().flatMap { namespace -> [MdocConsentItem] in
            (items[namespace] ?? []).map { item in
                let code = MdocClaimIndex.code(namespace: namespace,
                                               elementIdentifier: item.elementIdentifier)
                return MdocConsentItem(code: code,
                                       namespace: namespace,
                                       elementIdentifier: item.elementIdentifier,
                                       value: item.elementValue,
                                       isAmbiguous: (codeCounts[code] ?? 0) > 1)
            }
        }
    }

    /// Checks every element against the digest the issuer signed for it.
    ///
    /// The issuer's signature covers the MSO, and the MSO covers the elements only through these
    /// digests — so an element that is not checked here is an element nobody signed. The digest is
    /// taken over the item bytes as received, which is why they are carried rather than rebuilt.
    /// - Throws: `OID4VCManagerError.mdocDigestMismatch` naming the first element that fails, or
    ///   `.invalidMdoc` when the document uses a digest algorithm this SDK does not implement.
    func verifyDigests() throws {
        guard mso.digestAlgorithm == "SHA-256" else {
            throw OID4VCManagerError.invalidMdoc(detail: "unsupported digest algorithm \(mso.digestAlgorithm)").getError()
        }
        for (namespace, namespaceItems) in items {
            guard let digests = mso.valueDigests[namespace] else {
                throw OID4VCManagerError.invalidMdoc(detail: "no digests for namespace \(namespace)").getError()
            }
            for item in namespaceItems where digests[item.digestID] != Data(item.itemBytes).sha256() {
                throw OID4VCManagerError.mdocDigestMismatch(elementIdentifier: item.elementIdentifier).getError()
            }
        }
    }

    /// Checks that the document is inside the window the issuer stated.
    /// - Parameter date: The instant to judge against.
    /// - Throws: `OID4VCManagerError.mdocOutsideValidityPeriod`.
    func verifyValidity(at date: Date) throws {
        guard date >= validityInfo.validFrom, date <= validityInfo.validUntil else {
            throw OID4VCManagerError.mdocOutsideValidityPeriod.getError()
        }
    }
}

/// One element of an mdoc, as the holder is asked to consent to it.
///
/// `code` is the value that travels: matching names claims with it, the holder's selection is
/// expressed in it, and `createVpToken` resolves it back to this element. It is opaque — display
/// it and compare it, but never split it apart or build one from `namespace` and
/// `elementIdentifier`, which are here to render the row, not to reconstruct the code.
public struct MdocConsentItem: Sendable, Equatable {

    /// The claim code. Hand this back in `MatchedCredential.claimCodes` unchanged.
    public let code: String

    /// The namespace the element belongs to.
    public let namespace: String

    /// The element's identifier within its namespace.
    public let elementIdentifier: String

    /// The value the issuer put in the element.
    public let value: MdocElementValue

    /// Whether this code names more than one element of the document.
    ///
    /// When it does, no selection can say which one the holder meant, so presenting it fails rather
    /// than guessing. It takes an element identifier containing the code separator to happen, which
    /// no deployed document type does — but a screen that offered the row anyway would collect a
    /// consent the wallet cannot honour.
    public let isAmbiguous: Bool
}

/// The validity window an issuer states in the MSO.
public struct MdocValidityInfo: Sendable, Equatable {
    /// When the MSO was signed.
    public let signed: Date
    /// The start of the document's validity.
    public let validFrom: Date
    /// The end of the document's validity.
    public let validUntil: Date
    /// When the issuer expects to re-issue, if it said.
    public let expectedUpdate: Date?
}

/// A value an mdoc element can hold.
///
/// An mdoc element is CBOR, not JSON, so it reaches past what `AnyJSON` can carry: a `portrait` is
/// a JPEG byte string, and a `birth_date` is a tagged date rather than a plain string. The cases
/// below are the shapes ISO/IEC 18013-5 defines for element values.
public enum MdocElementValue: Sendable, Equatable {
    case text(String)
    case bytes(Data)
    case integer(Int64)
    case double(Double)
    case bool(Bool)
    /// A `full-date` (tag 1004): a calendar date with no time and no zone, kept as written.
    ///
    /// It stays a string because it denotes a date, not an instant — turning `1990-05-15` into a
    /// `Date` would have to invent a time zone, and could move the date across a day boundary when
    /// it is shown again.
    case fullDate(String)
    /// A point in time (tag 0 / tag 1).
    case dateTime(Date)
    case array([MdocElementValue])
    case map([String: MdocElementValue])
    case null

    static func decode(_ item: CBOR) throws -> MdocElementValue {
        switch item {
        case let .utf8String(value):
            return .text(value)
        case let .byteString(bytes):
            return .bytes(Data(bytes))
        case let .unsignedInt(value):
            guard value <= UInt64(Int64.max) else {
                throw OID4VCManagerError.invalidMdoc(detail: "integer element out of range").getError()
            }
            return .integer(Int64(value))
        case let .negativeInt(value):
            guard value <= UInt64(Int64.max) else {
                throw OID4VCManagerError.invalidMdoc(detail: "integer element out of range").getError()
            }
            return .integer(-1 - Int64(value))
        case let .boolean(value):
            return .bool(value)
        case let .double(value):
            return .double(value)
        case let .float(value):
            return .double(Double(value))
        case let .half(value):
            return .double(Double(value))
        case .null, .undefined:
            return .null
        case let .date(value):
            return .dateTime(value)
        case let .array(values):
            return .array(try values.map { try MdocElementValue.decode($0) })
        case let .map(entries):
            var out: [String: MdocElementValue] = [:]
            for (key, value) in entries {
                guard case let .utf8String(name) = key else {
                    throw OID4VCManagerError.invalidMdoc(detail: "map element has a non-string key").getError()
                }
                out[name] = try MdocElementValue.decode(value)
            }
            return .map(out)
        case let .tagged(tag, value):
            return try MdocElementValue.decode(tag: tag, value: value)
        default:
            throw OID4VCManagerError.invalidMdoc(detail: "unsupported element value").getError()
        }
    }

    private static func decode(tag: CBOR.Tag, value: CBOR) throws -> MdocElementValue {
        switch tag.rawValue {
        case 1004:
            guard case let .utf8String(text) = value else {
                throw OID4VCManagerError.invalidMdoc(detail: "full-date is not a string").getError()
            }
            return .fullDate(text)
        case 0:
            guard case let .utf8String(text) = value else {
                throw OID4VCManagerError.invalidMdoc(detail: "tdate is not a string").getError()
            }
            // Issuers have been seen tagging a date-only value as tag 0, which RFC 8949 reserves
            // for a full date-time. Reading it as a date would have to invent a time, so the value
            // is kept as the `full-date` it actually is rather than rejected.
            if let date = MdocDateFormat.date(from: text) {
                return .dateTime(date)
            }
            return .fullDate(text)
        case 1:
            guard let seconds = value.int64Value else {
                throw OID4VCManagerError.invalidMdoc(detail: "epoch time is not an integer").getError()
            }
            return .dateTime(Date(timeIntervalSince1970: TimeInterval(seconds)))
        default:
            // A tag this SDK does not model still has a value underneath it worth showing.
            return try MdocElementValue.decode(value)
        }
    }
}

/// One `IssuerSignedItem`, together with the bytes its digest was taken over.
struct MdocIssuerSignedItem: Equatable {
    let digestID: UInt64
    let random: Data
    let elementIdentifier: String
    let elementValue: MdocElementValue
    /// The `IssuerSignedItemBytes` — the item wrapped in tag 24 — as it must be hashed and as it
    /// must be re-sent when the element is disclosed.
    let itemBytes: [UInt8]

    static func decode(_ item: CBOR) throws -> MdocIssuerSignedItem {
        guard case let .tagged(tag, payload) = item, tag.rawValue == 24 else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSignedItem is not tagged 24").getError()
        }
        guard case let .byteString(bytes) = payload else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSignedItemBytes is not a byte string").getError()
        }
        guard case let .map(fields)? = try? CBOR.decode(bytes) else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSignedItem is not a map").getError()
        }
        guard let digestID = fields["digestID"]?.uint64Value else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSignedItem has no digestID").getError()
        }
        guard case let .byteString(random)? = fields["random"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSignedItem has no random").getError()
        }
        guard case let .utf8String(identifier)? = fields["elementIdentifier"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSignedItem has no elementIdentifier").getError()
        }
        guard let value = fields["elementValue"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "IssuerSignedItem has no elementValue").getError()
        }

        return MdocIssuerSignedItem(digestID: digestID,
                                    random: Data(random),
                                    elementIdentifier: identifier,
                                    elementValue: try MdocElementValue.decode(value),
                                    itemBytes: item.encode())
    }
}

/// The `MobileSecurityObject` the issuer signs: what the document is, and the digests that pin
/// every element it may disclose.
struct MobileSecurityObject: Equatable {
    let version: String
    let digestAlgorithm: String
    let docType: String
    let validityInfo: MdocValidityInfo
    /// Element digests, by namespace and then by `digestID`.
    let valueDigests: [String: [UInt64: Data]]
    /// The holder key the document is bound to, as a COSE_Key.
    let deviceKey: CBOR

    static func decode(_ issuerAuth: COSESign1) throws -> MobileSecurityObject {
        guard let payload = issuerAuth.payload else {
            throw OID4VCManagerError.invalidMdoc(detail: "issuerAuth has no payload").getError()
        }
        guard case let .tagged(tag, wrapped)? = try? CBOR.decode(payload), tag.rawValue == 24 else {
            throw OID4VCManagerError.invalidMdoc(detail: "MobileSecurityObjectBytes is not tagged 24").getError()
        }
        guard case let .byteString(msoBytes) = wrapped,
              case let .map(mso)? = try? CBOR.decode(msoBytes) else {
            throw OID4VCManagerError.invalidMdoc(detail: "MobileSecurityObject is not a map").getError()
        }
        guard case let .utf8String(version)? = mso["version"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO has no version").getError()
        }
        guard case let .utf8String(digestAlgorithm)? = mso["digestAlgorithm"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO has no digestAlgorithm").getError()
        }
        guard case let .utf8String(docType)? = mso["docType"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO has no docType").getError()
        }
        guard case let .map(digestsByNamespace)? = mso["valueDigests"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO has no valueDigests").getError()
        }
        guard case let .map(deviceKeyInfo)? = mso["deviceKeyInfo"],
              let deviceKey = deviceKeyInfo["deviceKey"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO has no deviceKey").getError()
        }

        var valueDigests: [String: [UInt64: Data]] = [:]
        for (namespaceKey, digestMap) in digestsByNamespace {
            guard case let .utf8String(namespace) = namespaceKey,
                  case let .map(digests) = digestMap else {
                throw OID4VCManagerError.invalidMdoc(detail: "valueDigests is malformed").getError()
            }
            var byIdentifier: [UInt64: Data] = [:]
            for (digestKey, digestValue) in digests {
                guard let digestID = digestKey.uint64Value,
                      case let .byteString(digest) = digestValue else {
                    throw OID4VCManagerError.invalidMdoc(detail: "valueDigests entry is malformed").getError()
                }
                byIdentifier[digestID] = Data(digest)
            }
            valueDigests[namespace] = byIdentifier
        }

        return MobileSecurityObject(version: version,
                                    digestAlgorithm: digestAlgorithm,
                                    docType: docType,
                                    validityInfo: try MobileSecurityObject.validity(mso["validityInfo"]),
                                    valueDigests: valueDigests,
                                    deviceKey: deviceKey)
    }

    private static func validity(_ item: CBOR?) throws -> MdocValidityInfo {
        guard case let .map(fields)? = item else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO has no validityInfo").getError()
        }
        func date(_ name: String) throws -> Date {
            guard let value = try MobileSecurityObject.optionalDate(fields[.utf8String(name)]) else {
                throw OID4VCManagerError.invalidMdoc(detail: "validityInfo has no \(name)").getError()
            }
            return value
        }
        return MdocValidityInfo(signed: try date("signed"),
                                validFrom: try date("validFrom"),
                                validUntil: try date("validUntil"),
                                expectedUpdate: try MobileSecurityObject.optionalDate(fields["expectedUpdate"]))
    }

    private static func optionalDate(_ item: CBOR?) throws -> Date? {
        switch item {
        case .none:
            return nil
        case let .some(.date(value)):
            return value
        case let .some(.tagged(tag, .utf8String(text))) where tag.rawValue == 0:
            guard let date = MdocDateFormat.date(from: text) else {
                throw OID4VCManagerError.invalidMdoc(detail: "validityInfo holds an unreadable tdate").getError()
            }
            return date
        case let .some(.utf8String(text)):
            guard let date = MdocDateFormat.date(from: text) else {
                throw OID4VCManagerError.invalidMdoc(detail: "validityInfo holds an unreadable tdate").getError()
            }
            return date
        default:
            throw OID4VCManagerError.invalidMdoc(detail: "validityInfo holds a non-date value").getError()
        }
    }
}

/// Reads the date-time strings an mdoc carries.
///
/// ISO/IEC 18013-5 specifies a tdate without fractional seconds, but issuers do emit them, so both
/// forms are accepted — being strict here would reject documents that verify.
enum MdocDateFormat {

    private static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let withoutFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func date(from text: String) -> Date? {
        return withFractionalSeconds.date(from: text) ?? withoutFractionalSeconds.date(from: text)
    }
}

extension CBOR {
    /// The value as an unsigned integer, for digest identifiers and other counts.
    var uint64Value: UInt64? {
        guard case let .unsignedInt(value) = self else { return nil }
        return value
    }
}
