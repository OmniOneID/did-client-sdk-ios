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
/// (the PIN key when a passcode is supplied, the biometric key otherwise — mirroring the proof
/// signing in `OID4VCIProtocol`), and returns the combined presentation string
/// `<issuer JWT>~<selected disclosures>~<KB-JWT>`.
struct SDJWTPresenter
{
    /// SD-JWT credential format tokens this presenter can handle.
    static let supportedFormats: Set<String> = ["dc+sd-jwt", "vc+sd-jwt", "dc+sd-jwt-did"]

    /// - Parameters:
    ///   - rawCredential: The stored SD-JWT compact string.
    ///   - claimCodes: The claim names to disclose. Empty discloses all of the credential's claims.
    ///   - aud: The verifier audience — the request's `client_id`.
    ///   - nonce: The request's `nonce`, bound into the KB-JWT.
    ///   - keyId: The holder key id (`"pin"` / `"bio"`).
    ///   - pin: The wallet PIN as data when `keyId` is the PIN key; `nil` for biometric.
    /// - Returns: The combined SD-JWT presentation string with a key-binding JWT appended.
    static func createVpToken(
        rawCredential: String,
        claimCodes: [String],
        aud: String,
        nonce: String,
        keyId: String,
        pin: Data?
    ) throws -> String
    {
        let sdjwt = SDJWT.parse(raw: rawCredential)

        // Disclose only the agreed claims; an empty list discloses everything.
        let selected: [Disclosure]
        if claimCodes.isEmpty
        {
            selected = sdjwt.disclosures
        }
        else
        {
            selected = sdjwt.disclosures.filter { claimCodes.contains($0.claimName ?? "") }
        }

        // sd_hash is computed over the PRESENTED SD-JWT — issuer JWT + selected disclosures with the
        // trailing '~', KB-JWT excluded — not over the original full credential.
        let presented = SDJWT(credentialJwt: sdjwt.credentialJwt,
                              disclosures: selected,
                              keyBindingJwt: nil).toString()
        let sdHash = presented.data(using: .utf8)!.sha256().base64URLEncoded

        // Holder key-bound signature. PIN key when a passcode is supplied, biometric key otherwise.
        let keyManager = try KeyManager(fileName: "holder")
        guard try keyManager.isKeySaved(id: keyId),
              let keyInfo = try keyManager.getKeyInfos(ids: [keyId]).first
        else
        {
            throw OID4VPError.holderKeyNotFound(keyId)
        }

        let compressedPublicKey = try MultibaseUtils.decode(encoded: keyInfo.publicKey)
        let jwk = try P256V.decompressPublicKey(compressedPublicKey: compressedPublicKey).getPublicKeyJwk()

        let header = try JWSHeader(typ: "kb+jwt", jwk: jwk).toJsonData().base64URLEncoded
        let payload = try KBJWTPayload(aud: aud, nonce: nonce, sdHash: sdHash).toJsonData().base64URLEncoded

        let signSource = "\(header).\(payload)"
        let digest = signSource.data(using: .utf8)!.sha256()

        // KeyManager returns a 65-byte compact signature (v‖r‖s); JOSE ES256 wants 64-byte r‖s.
        let compactSignature = try keyManager.sign(id: keyId, pin: pin, digest: digest)
        let signature = Data(compactSignature.dropFirst()).base64URLEncoded
        let keyBindingJwt = "\(signSource).\(signature)"

        return SDJWT(credentialJwt: sdjwt.credentialJwt,
                     disclosures: selected,
                     keyBindingJwt: keyBindingJwt).toString()
    }
}
