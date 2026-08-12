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

/// Every claim code an SD-JWT can produce, mapped to what presenting that code costs.
///
/// Matching and presentation both have to walk the issuer payload — matching to name the claims the
/// holder is shown, presentation to turn those names back into disclosures. Walking twice with two
/// implementations is what made a claim whose *name* contains a code separator
/// (`"address.street_address"` as a single member) indistinguishable from the nested path
/// `address` → `street_address`: one side named it, the other parsed it apart and found nothing.
///
/// This type walks once. The code strings are keys of the map it returns and carry no structure of
/// their own — nothing parses them back into a path. Where one code would name two different claims
/// of the same credential the entry is marked ambiguous rather than silently resolved, because
/// either choice would present a claim the holder did not single out.
struct SDJWTClaimIndex
{
    /// What one claim code costs to present, and what it holds.
    struct Entry
    {
        /// The disclosures the presentation must carry: the claim's own, plus every ancestor that
        /// hides it. Empty when the issuer left the claim in the clear — the verifier reads it from
        /// the issuer JWT either way.
        let disclosures: Set<String>

        /// The last segment of the code, for a screen that shows a label rather than a path:
        /// the member name, or `[n]` for an array element.
        let claimName: String

        /// The claim's value.
        let value: AnyJSON

        /// The one disclosure that hides this claim itself, as opposed to the ancestors in
        /// `disclosures` that hide the branch it sits on. `nil` for a claim the issuer left in the
        /// clear, which no disclosure carries.
        ///
        /// Kept apart from the set because the set has no order and no way to say which member is
        /// the claim's own — and ordering a consent list by where the issuer put each claim needs
        /// exactly that one.
        let ownDisclosure: String?

        /// Whether the code stands on its own in the holder's consent list. A plaintext member of a
        /// claim that is already listed is disclosed with its parent, so it is indexed (a verifier
        /// may still point at it) but not listed again.
        let isConsentItem: Bool

        /// Whether this code names more than one claim of the credential. Presenting it would have
        /// to guess which one the holder agreed to, so the presenter refuses instead.
        let isAmbiguous: Bool
    }

    /// Claim names the issuer JWT carries for its own sake — never claims about the subject.
    static let reservedClaims: Set<String> = [
        "iss", "sub", "aud", "exp", "nbf", "iat", "jti",
        "_sd_alg", "_sd", "cnf", "vct"
    ]

    private(set) var entries: [String: Entry] = [:]

    /// The codes to show the holder: every claim the credential can disclose, named the way DCQL
    /// paths name them (`address`, `address.street_address`, `degrees[0]`), minus the plaintext
    /// members that ride along with a parent already in the list.
    var consentItemCodes: Set<String>
    {
        Set(entries.filter { $0.value.isConsentItem }.keys)
    }

    /// Walks the issuer payload, following each `_sd` digest and array `{"...": digest}` placeholder
    /// into the disclosure it hides, and records what reaching every node requires.
    static func build(sdjwt: SDJWT, payload: [String: Any]) -> SDJWTClaimIndex
    {
        var digestToDisclosure: [String: Disclosure] = [:]
        for disclosure in sdjwt.disclosures
        {
            digestToDisclosure[disclosure.digest()] = disclosure
        }

        var index = SDJWTClaimIndex()
        var usedDigests: Set<String> = []
        index.walk(value: payload,
                   prefix: nil,
                   ancestors: [],
                   digestToDisclosure: digestToDisclosure,
                   usedDigests: &usedDigests)

        // A disclosure whose digest the payload never references cannot be reached by the walk. It is
        // still presentable by its own name, and dropping it would shrink what "all claims" means.
        for disclosure in sdjwt.disclosures where !usedDigests.contains(disclosure.digest())
        {
            guard let claimName = disclosure.claimName,
                  !SDJWTClaimIndex.reservedClaims.contains(claimName)
            else
            {
                continue
            }
            index.insert(code: claimName,
                         claimName: claimName,
                         value: disclosure.claimValue.jsonToAny,
                         disclosures: [disclosure.getDisclosure()],
                         ownDisclosure: disclosure.getDisclosure(),
                         isConsentItem: true)
        }
        return index
    }

    // MARK: - Private

    /// Records one code. A code reached twice by the same disclosure requirement is the same claim;
    /// reached twice with different requirements it names two claims, which no selection can tell
    /// apart.
    private mutating func insert(code: String,
                                 claimName: String,
                                 value: Any,
                                 disclosures: Set<String>,
                                 ownDisclosure: String? = nil,
                                 isConsentItem: Bool)
    {
        guard let existing = entries[code]
        else
        {
            entries[code] = Entry(disclosures: disclosures,
                                  claimName: claimName,
                                  value: AnyJSON.fromFoundation(value) ?? .null,
                                  ownDisclosure: ownDisclosure,
                                  isConsentItem: isConsentItem,
                                  isAmbiguous: false)
            return
        }
        // The first reading wins: a code that names two claims is marked rather than merged, and
        // showing the value it first resolved to is no more wrong than showing the other one. Its
        // position follows for the same reason — the row is already marked unpresentable.
        entries[code] = Entry(disclosures: existing.disclosures,
                              claimName: existing.claimName,
                              value: existing.value,
                              ownDisclosure: existing.ownDisclosure,
                              isConsentItem: existing.isConsentItem || isConsentItem,
                              isAmbiguous: existing.isAmbiguous || existing.disclosures != disclosures)
    }

    private mutating func walk(value: Any,
                               prefix: String?,
                               ancestors: Set<String>,
                               digestToDisclosure: [String: Disclosure],
                               usedDigests: inout Set<String>)
    {
        if let object = value as? [String: Any]
        {
            for (key, child) in object where key != "_sd" && key != "_sd_alg"
            {
                let code: String
                if let prefix = prefix
                {
                    code = "\(prefix).\(key)"
                    insert(code: code, claimName: key, value: child,
                           disclosures: ancestors, isConsentItem: false)
                }
                else if !SDJWTClaimIndex.reservedClaims.contains(key)
                {
                    code = key
                    insert(code: code, claimName: key, value: child,
                           disclosures: ancestors, isConsentItem: true)
                }
                else
                {
                    continue
                }
                walk(value: child,
                     prefix: code,
                     ancestors: ancestors,
                     digestToDisclosure: digestToDisclosure,
                     usedDigests: &usedDigests)
            }

            for entry in (object["_sd"] as? [Any]) ?? []
            {
                guard let digest = entry as? String,
                      let disclosure = digestToDisclosure[digest],
                      let claimName = disclosure.claimName
                else
                {
                    continue
                }
                usedDigests.insert(digest)
                let code = prefix.map { "\($0).\(claimName)" } ?? claimName
                let required = ancestors.union([disclosure.getDisclosure()])
                insert(code: code, claimName: claimName, value: disclosure.claimValue.jsonToAny,
                       disclosures: required, ownDisclosure: disclosure.getDisclosure(),
                       isConsentItem: true)
                // Only the structure matters here; number typing is irrelevant to the walk.
                walk(value: disclosure.claimValue.jsonToAny,
                     prefix: code,
                     ancestors: required,
                     digestToDisclosure: digestToDisclosure,
                     usedDigests: &usedDigests)
            }
            return
        }

        guard let array = value as? [Any], let prefix = prefix else { return }
        for (position, element) in array.enumerated()
        {
            let code = "\(prefix)[\(position)]"

            // A selectively disclosable array element is the placeholder {"...": "<digest>"}.
            if let placeholder = element as? [String: Any],
               let digest = placeholder["..."] as? String
            {
                guard let disclosure = digestToDisclosure[digest] else { continue }
                usedDigests.insert(digest)
                let required = ancestors.union([disclosure.getDisclosure()])
                insert(code: code, claimName: "[\(position)]", value: disclosure.claimValue.jsonToAny,
                       disclosures: required, ownDisclosure: disclosure.getDisclosure(),
                       isConsentItem: true)
                walk(value: disclosure.claimValue.jsonToAny,
                     prefix: code,
                     ancestors: required,
                     digestToDisclosure: digestToDisclosure,
                     usedDigests: &usedDigests)
            }
            else
            {
                insert(code: code, claimName: "[\(position)]", value: element,
                       disclosures: ancestors, isConsentItem: false)
                walk(value: element,
                     prefix: code,
                     ancestors: ancestors,
                     digestToDisclosure: digestToDisclosure,
                     usedDigests: &usedDigests)
            }
        }
    }
}
