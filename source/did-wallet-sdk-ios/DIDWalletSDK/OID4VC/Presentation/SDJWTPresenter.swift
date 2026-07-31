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

/// Builds an SD-JWT + Key-Binding JWT presentation (a `vp_token` entry) for OID4VP.
///
/// Picks up where DCQL matching leaves off: given a stored SD-JWT and the claim codes the holder
/// agreed to disclose, it filters the disclosures, signs a `kb+jwt` with the holder wallet key
/// (the key the credential was bound to at issuance, supplied by the caller as `signDigest`),
/// and returns the combined presentation string
/// `<issuer JWT>~<selected disclosures>~<KB-JWT>`.
struct SDJWTPresenter
{
    /// SD-JWT credential format tokens this presenter can handle.
    static let supportedFormats: Set<String> = ["dc+sd-jwt-did"]

    init() {}

    /// Pure: no wallet access. The caller supplies the holder public JWK (for the KB-JWT header) and
    /// a `signDigest` closure that signs the KB-JWT signing input with the holder key.
    /// - Parameters:
    ///   - sdjwt: The stored SD-JWT (issuer JWT + disclosures), as returned by the wallet.
    ///   - claimCodes: The claim names to disclose. Empty discloses all of the credential's claims.
    ///   - aud: The verifier audience — the request's `client_id`.
    ///   - nonce: The request's `nonce`, bound into the KB-JWT.
    ///   - holderJwk: The holder public key as a JWK, embedded in the KB-JWT protected header.
    ///   - signDigest: Signs the KB-JWT signing-input digest with the holder key; returns the raw
    ///     65-byte compact signature (`v‖r‖s`).
    /// - Returns: The combined SD-JWT presentation string with a key-binding JWT appended.
    static func createVpToken(
        sdjwt: SDJWT,
        claimCodes: [String],
        aud: String,
        nonce: String,
        holderJwk: JWK,
        signDigest: (_ digest: Data) throws -> Data
    ) throws -> String
    {
        // Disclose only the agreed claims; an empty list discloses everything.
        let selected: [Disclosure]
        if claimCodes.isEmpty
        {
            selected = sdjwt.disclosures
        }
        else
        {
            selected = try resolveDisclosures(sdjwt: sdjwt, claimCodes: claimCodes)
        }

        // sd_hash is computed over the PRESENTED SD-JWT — issuer JWT + selected disclosures with the
        // trailing '~', KB-JWT excluded — not over the original full credential.
        let presented = SDJWT(credentialJwt: sdjwt.credentialJwt,
                              disclosures: selected,
                              keyBindingJwt: nil).toString()
        let sdHash = presented.data(using: .utf8)!.sha256().base64URLEncoded

        let header = try JWSHeader(typ: "kb+jwt", jwk: holderJwk).toJsonData().base64URLEncoded
        let payload = try KBJWTPayload(aud: aud, nonce: nonce, sdHash: sdHash).toJsonData().base64URLEncoded

        let signSource = "\(header).\(payload)"
        let digest = signSource.data(using: .utf8)!.sha256()

        // The signer returns a 65-byte compact signature (v‖r‖s); JOSE ES256 wants 64-byte r‖s.
        let compactSignature = try signDigest(digest)
        let signature = Data(compactSignature.dropFirst()).base64URLEncoded
        let keyBindingJwt = "\(signSource).\(signature)"

        return SDJWT(credentialJwt: sdjwt.credentialJwt,
                     disclosures: selected,
                     keyBindingJwt: keyBindingJwt).toString()
    }

    /// Resolves the claim codes DCQL matching produced to the disclosures the presentation must
    /// carry.
    ///
    /// The two sides speak different name spaces. Matching reports a claim by its DCQL *path* —
    /// `address.street_address`, `degrees[0].type` — while a disclosure knows only its own claim
    /// name (`street_address`). Walking the issuer payload from the root translates one into the
    /// other, and picks up every disclosure along the way: a nested claim is unreadable unless the
    /// object holding it is disclosed too.
    ///
    /// A claim the issuer put in the JWT in the clear resolves to no disclosure at all. That is not
    /// an error — the verifier receives it either way — so it contributes nothing to the selection.
    ///
    /// - Note: A path element containing `.` or `[` cannot be told apart from the separators, since
    ///   the codes arrive as flat strings. Matching builds them with the same encoding, so ordinary
    ///   claim names round-trip; exotic ones would need the structured path instead of a code.
    /// - Throws: `OID4VCManagerError.invalidSelectedCredentials` when a code names a claim the
    ///   credential does not hold, `.invalidJWS` when the issuer JWT payload cannot be read.
    static func resolveDisclosures(sdjwt: SDJWT, claimCodes: [String]) throws -> [Disclosure]
    {
        let payload: [String: Any]
        do
        {
            payload = try SimpleJWTDecoder.parse(sdjwt.credentialJwt).payload
        }
        catch
        {
            throw OID4VCManagerError.invalidJWS(
                detail: "issuer JWT payload is not readable: \(error)").getError()
        }

        var digestToDisclosure: [String: Disclosure] = [:]
        for disclosure in sdjwt.disclosures
        {
            digestToDisclosure[disclosure.digest()] = disclosure
        }

        var required: Set<String> = []
        var missing: [String] = []

        for code in claimCodes
        {
            let path = parsePath(code)

            if let resolved = resolve(path: path,
                                      payload: payload,
                                      digestToDisclosure: digestToDisclosure)
            {
                required.formUnion(resolved.map { $0.getDisclosure() })
            }
            else if path.count == 1, case .key(let name) = path[0],
                    let flat = sdjwt.disclosures.first(where: { $0.claimName == name })
            {
                // The payload does not reference this disclosure's digest, so the walk above cannot
                // reach it. A top-level claim is still unambiguous by name, and dropping it would
                // hand the verifier a presentation missing a claim the holder agreed to.
                required.insert(flat.getDisclosure())
            }
            else
            {
                missing.append(code)
            }
        }

        guard missing.isEmpty
        else
        {
            throw OID4VCManagerError.invalidSelectedCredentials(
                detail: "claim(s) \(missing.sorted().joined(separator: ", ")) are not disclosable in the credential").getError()
        }

        // Filtering the credential's own list keeps the issuer's disclosure order and drops the
        // duplicates that overlapping paths produce.
        return sdjwt.disclosures.filter { required.contains($0.getDisclosure()) }
    }

    /// One step of a claim code: an object member or an array element.
    private enum PathStep
    {
        case key(String)
        case index(Int)
    }

    /// Splits a claim code such as `degrees[0].type` into `[.key("degrees"), .index(0), .key("type")]`.
    private static func parsePath(_ code: String) -> [PathStep]
    {
        var steps: [PathStep] = []

        for segment in code.split(separator: ".", omittingEmptySubsequences: false)
        {
            var name = ""
            var indexDigits = ""
            var inBracket = false

            for character in segment
            {
                switch character
                {
                case "[":
                    inBracket = true
                case "]":
                    if inBracket
                    {
                        steps.append(.key(name))
                        name = ""
                        if let index = Int(indexDigits)
                        {
                            steps.append(.index(index))
                        }
                        indexDigits = ""
                        inBracket = false
                    }
                default:
                    if inBracket { indexDigits.append(character) } else { name.append(character) }
                }
            }

            if !name.isEmpty { steps.append(.key(name)) }
        }

        return steps
    }

    /// Walks `payload` along `path`, collecting the disclosures needed to reach the value.
    /// - Returns: The disclosures to present, or `nil` when the path does not exist in this
    ///   credential. An empty array means the claim is in the clear.
    private static func resolve(path: [PathStep],
                                payload: [String: Any],
                                digestToDisclosure: [String: Disclosure]) -> [Disclosure]?
    {
        guard !path.isEmpty else { return nil }

        var current: Any = payload
        var collected: [Disclosure] = []

        for step in path
        {
            switch step
            {
            case .key(let key):
                guard let object = current as? [String: Any] else { return nil }

                if let value = object[key]
                {
                    current = value
                }
                else if let hidden = disclosedMember(named: key,
                                                     in: object,
                                                     digestToDisclosure: digestToDisclosure)
                {
                    collected.append(hidden.disclosure)
                    current = hidden.value
                }
                else
                {
                    return nil
                }

            case .index(let index):
                guard let array = current as? [Any], index >= 0, index < array.count else { return nil }

                // A selectively disclosable array element is the placeholder {"...": "<digest>"}.
                if let placeholder = array[index] as? [String: Any],
                   let digest = placeholder["..."] as? String
                {
                    guard let disclosure = digestToDisclosure[digest] else { return nil }
                    collected.append(disclosure)
                    current = SDJWTCredentialAdapter.jsonToAny(disclosure.claimValue)
                }
                else
                {
                    current = array[index]
                }
            }
        }

        return collected
    }

    /// Finds the disclosure that reveals `name` among an object's `_sd` digests.
    private static func disclosedMember(named name: String,
                                        in object: [String: Any],
                                        digestToDisclosure: [String: Disclosure]) -> (disclosure: Disclosure, value: Any)?
    {
        guard let digests = object["_sd"] as? [Any] else { return nil }

        for entry in digests
        {
            guard let digest = entry as? String,
                  let disclosure = digestToDisclosure[digest],
                  disclosure.claimName == name
            else
            {
                continue
            }

            return (disclosure, SDJWTCredentialAdapter.jsonToAny(disclosure.claimValue))
        }

        return nil
    }
}
