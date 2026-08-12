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

/// `CredentialAdapter` for ISO/IEC 18013-5 mobile documents (format: mso_mdoc-did).
///
/// An mdoc addresses a claim by namespace and element identifier rather than by a JSON path, so
/// this adapter does its own claim matching instead of reusing `ClaimMatchingHelper`'s path walk:
/// every code it returns is built by `MdocClaimIndex`, the same type the presenter reads codes back
/// through. Value conditions are still shared, since those are format-independent.
public class MdocCredentialAdapter: CredentialAdapter {

    static let supportedFormats: Set<String> = [CredentialFormat.msoMdoc.token]

    public init() {}

    public func getSupportedFormats() -> Set<String> { MdocCredentialAdapter.supportedFormats }
    public func supports(_ format: String) -> Bool { MdocCredentialAdapter.supportedFormats.contains(format) }

    /// An mdoc has no envelope claims: everything in `nameSpaces` is a claim about the subject, and
    /// what the issuer says about the document itself lives in the MSO, not among the elements.
    public func getReservedClaimNames() -> Set<String> { [] }

    public func parse(_ rawCredential: String) throws -> ParsedCredential {
        guard !rawCredential.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DCQLError.parseError("Raw credential cannot be empty")
        }

        let mdoc: Mdoc
        do {
            mdoc = try Mdoc.parse(raw: rawCredential)
        } catch {
            throw DCQLError.parseError("Failed to decode mdoc: \(error)")
        }

        // Claims stay nested by namespace: two namespaces may each carry an element of the same
        // name, and flattening them here would merge two different claims into one.
        var claims: [String: Any] = [:]
        for (namespace, elements) in mdoc.namespaces {
            claims[namespace] = elements.mapValues { MdocCredentialAdapter.foundationValue($0) }
        }

        return ParsedCredential(
            format: CredentialFormat.msoMdoc.token,
            rawCredential: rawCredential,
            baseClaims: claims,
            allClaims: claims,
            metadata: ["doctype": mdoc.docType],
            nativeCredential: mdoc
        )
    }

    /// An mdoc query constrains the document type, and nothing else about the document itself.
    public func matchesMetadata(_ credential: ParsedCredential, metadata: [String: Any]) -> Bool {
        if metadata.isEmpty { return true }
        guard let required = metadata["doctype_value"] else { return true }
        guard let docType = credential.getMetadataValue("doctype") as? String else { return false }
        if let single = required as? String { return single == docType }
        // Some verifiers send the constraint as a list even though the standard states one value.
        if let list = required as? [String] { return list.contains(docType) }
        return false
    }

    public func extractAllClaims(_ credential: ParsedCredential) -> [String: Any] {
        credential.allClaims
    }

    /// The claims a query names, as codes.
    ///
    /// A query addresses an mdoc element either as a two-element `path` (`[namespace, element]`,
    /// OID4VP 1.0 §6.4.2) or as the `namespace` + `claim_name` pair earlier drafts used. Both are
    /// accepted, and both resolve to the same element and therefore to the same code.
    public func extractMatchingClaims(_ credential: ParsedCredential,
                                      claimQueries: [DCQLQuery.ClaimQuery]) -> Set<String> {
        var matched: Set<String> = []
        for claimQuery in claimQueries {
            guard let target = MdocCredentialAdapter.target(of: claimQuery),
                  let elements = credential.allClaims[target.namespace] as? [String: Any],
                  let value = elements[target.elementIdentifier],
                  ClaimMatchingHelper.meetsConditions(claimQuery: claimQuery, actualValue: value)
            else {
                continue
            }
            matched.insert(MdocClaimIndex.code(namespace: target.namespace,
                                               elementIdentifier: target.elementIdentifier))
        }
        return matched
    }

    /// Every element the document can disclose.
    ///
    /// Most mdoc queries constrain only `doctype_value`, so this is the path that names what the
    /// holder is asked to consent to in practice — an mdoc discloses per element, so every element
    /// has to be named for the holder to see what leaves the wallet.
    public func allClaimNames(_ credential: ParsedCredential) -> Set<String> {
        guard let mdoc = credential.getNativeCredentialAs(Mdoc.self) else {
            return []
        }
        return MdocClaimIndex.build(mdoc: mdoc).consentItemCodes
    }

    /// mdocs issued through this SDK are signed under a DID and carry no X.509 chain, so none of
    /// the authority types OID4VP defines (`x509_san_dns`, `aki`, …) can be evaluated against one.
    /// A request that demands a trusted authority is therefore not satisfiable by these documents,
    /// and saying so is safer than presenting a credential whose authority was never checked.
    public func matchesTrustedAuthorities(_ credential: ParsedCredential,
                                          trustedAuthorities: [DCQLQuery.TrustedAuthority]) -> Bool {
        return trustedAuthorities.isEmpty
    }

    // MARK: - Private

    /// The element a claim query addresses, in whichever of the two spellings it used.
    private static func target(of claimQuery: DCQLQuery.ClaimQuery) -> (namespace: String, elementIdentifier: String)? {
        if let namespace = claimQuery.namespace, let claimName = claimQuery.claimName {
            return (namespace, claimName)
        }
        // An mdoc path is exactly [namespace, element]; anything else addresses nothing an mdoc has.
        guard let path = claimQuery.path, path.count == 2,
              case let .key(namespace) = path[0],
              case let .key(elementIdentifier) = path[1] else {
            return nil
        }
        return (namespace, elementIdentifier)
    }

    /// Maps an element value to the Foundation types the shared condition matcher compares against.
    ///
    /// Dates become the strings they were written as: DCQL states `min`/`max`/`values` as JSON, so a
    /// date condition is a string comparison, and ISO 8601 orders the same way lexicographically.
    static func foundationValue(_ value: MdocElementValue) -> Any {
        switch value {
        case let .text(text):        return text
        case let .bytes(data):       return data
        case let .integer(number):   return number
        case let .double(number):    return number
        case let .bool(flag):        return flag
        case let .fullDate(text):    return text
        case let .dateTime(date):    return ISO8601DateFormatter().string(from: date)
        case let .array(values):     return values.map { foundationValue($0) }
        case let .map(values):       return values.mapValues { foundationValue($0) }
        case .null:                  return NSNull()
        }
    }
}
