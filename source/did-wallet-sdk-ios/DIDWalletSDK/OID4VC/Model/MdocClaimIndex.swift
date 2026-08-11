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

/// Every claim code an mdoc can produce, mapped to the element it names.
///
/// An mdoc claim is addressed by two things — a namespace and an element identifier — while a claim
/// code is one string. Building that string in one place and reading it back in another is what
/// this type exists to prevent: matching names the claims the holder is shown, presentation turns
/// those names back into elements, and both go through here.
///
/// Nothing splits a code back into its parts. `"eu.europa.ec.eudi.pid.1.given_name"` is looked up,
/// not parsed — which is why a namespace or element identifier that itself contains the separator
/// cannot mislead the presenter into disclosing the wrong element. Where one code would name two
/// elements of the same document the entry is marked ambiguous instead, and presenting it fails
/// rather than guessing which one the holder agreed to.
///
/// This is `SDJWTClaimIndex`'s counterpart, and deliberately the same shape: matching and
/// presentation share one naming for every format the wallet holds.
struct MdocClaimIndex
{
    /// The element one claim code names.
    struct Entry
    {
        let namespace: String
        let elementIdentifier: String

        /// Whether this code names more than one element of the document. Presenting it would have
        /// to guess which one the holder agreed to, so the presenter refuses instead.
        let isAmbiguous: Bool
    }

    private(set) var entries: [String: Entry] = [:]

    /// The codes to show the holder. Every element of an mdoc is separately disclosable, so unlike
    /// SD-JWT there is no claim that rides along with a parent: the whole set is consentable.
    var consentItemCodes: Set<String>
    {
        Set(entries.keys)
    }

    /// The one place a claim code is built.
    static func code(namespace: String, elementIdentifier: String) -> String
    {
        return "\(namespace).\(elementIdentifier)"
    }

    /// Indexes every element the document carries.
    static func build(mdoc: Mdoc) -> MdocClaimIndex
    {
        var index = MdocClaimIndex()
        for (namespace, elements) in mdoc.namespaces
        {
            for elementIdentifier in elements.keys
            {
                index.insert(namespace: namespace, elementIdentifier: elementIdentifier)
            }
        }
        return index
    }

    /// The entry for a code, or `nil` when the document has no such claim.
    func entry(for code: String) -> Entry?
    {
        return entries[code]
    }

    // MARK: - Private

    private mutating func insert(namespace: String, elementIdentifier: String)
    {
        let code = MdocClaimIndex.code(namespace: namespace, elementIdentifier: elementIdentifier)
        guard let existing = entries[code]
        else
        {
            entries[code] = Entry(namespace: namespace,
                                  elementIdentifier: elementIdentifier,
                                  isAmbiguous: false)
            return
        }
        let namesTheSameElement = existing.namespace == namespace
            && existing.elementIdentifier == elementIdentifier
        entries[code] = Entry(namespace: existing.namespace,
                              elementIdentifier: existing.elementIdentifier,
                              isAmbiguous: existing.isAmbiguous || !namesTheSameElement)
    }
}
