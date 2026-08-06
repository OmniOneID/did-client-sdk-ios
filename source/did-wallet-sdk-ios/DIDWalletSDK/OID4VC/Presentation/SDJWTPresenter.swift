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
    ///   - claimCodes: The claim names to disclose. Matching names them all, including the nested
    ///     ones, so the list is never empty in the wallet flow; an empty one is a caller error, not
    ///     a request for full disclosure.
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
        // Disclose only the agreed claims. Full disclosure is expressed by naming every claim, so an
        // empty list would silently present nothing the holder was shown — reject it instead.
        guard !claimCodes.isEmpty
        else
        {
            throw OID4VCManagerError.invalidSelectedCredentials(
                detail: "no claim selected for the credential to present").getError()
        }
        let selected = try resolveDisclosures(sdjwt: sdjwt, claimCodes: claimCodes)

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
    /// The codes are looked up in `SDJWTClaimIndex`, which is built by the same walk that named them
    /// in the first place — they are keys, never re-parsed into a path. That is what lets a claim
    /// whose name contains a code separator (`"address.street_address"` as one member) resolve to
    /// itself instead of to the nested path it happens to look like.
    ///
    /// A claim the issuer put in the JWT in the clear resolves to no disclosure at all. That is not
    /// an error — the verifier receives it either way — so it contributes nothing to the selection.
    ///
    /// - Throws: `OID4VCManagerError.invalidSelectedCredentials` when a code names a claim the
    ///   credential does not hold or names two of them, `.invalidJWS` when the issuer JWT payload
    ///   cannot be read.
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

        let index = SDJWTClaimIndex.build(sdjwt: sdjwt, payload: payload)

        var required: Set<String> = []
        var missing: [String] = []
        var ambiguous: [String] = []

        for code in claimCodes
        {
            guard let entry = index.entries[code]
            else
            {
                missing.append(code)
                continue
            }
            guard !entry.isAmbiguous
            else
            {
                ambiguous.append(code)
                continue
            }
            required.formUnion(entry.disclosures)
        }

        // Two claims sharing a code cannot be told apart by a selection, and presenting either would
        // disclose one the holder did not single out. Refuse rather than pick.
        guard ambiguous.isEmpty
        else
        {
            throw OID4VCManagerError.invalidSelectedCredentials(
                detail: "claim(s) \(ambiguous.sorted().joined(separator: ", ")) name more than one claim of the credential").getError()
        }

        guard missing.isEmpty
        else
        {
            throw OID4VCManagerError.invalidSelectedCredentials(
                detail: "claim(s) \(missing.sorted().joined(separator: ", ")) are not disclosable in the credential").getError()
        }

        // Filtering the credential's own list keeps the issuer's disclosure order and drops the
        // duplicates that overlapping claims produce.
        return sdjwt.disclosures.filter { required.contains($0.getDisclosure()) }
    }
}
