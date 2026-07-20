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

/// Builds a W3C Verifiable Presentation (`opendid_vc`) `vp_token` entry for OID4VP.
///
/// Unlike the SD-JWT presenter — which signs a key-binding JWT directly — the W3C path reuses the
/// existing wallet VP pipeline: it delegates to `WalletAPI.createVp`, which pulls the matched
/// credentials from `VCManager` by `ClaimInfo.credentialId`, builds a `VerifiablePresentation`
/// (holder proof, `Secp256r1Signature2018`), and returns it. The signed VP is carried in `vp_token`
/// as a JSON object (`ldp_vp`), not as a serialized string. This is why `createVpToken` carries
/// `hWalletToken`: `WalletAPI.createVp` verifies the wallet access token before presenting.
struct VerifiableCredentialPresenter: CredentialPresenter
{
    /// W3C credential format token this presenter can handle (matches `VerifiableCredentialAdapter`).
    static let supportedFormats: Set<String> = [VerifiableCredentialAdapter.format]

    init() {}

    func getSupportedFormats() -> Set<String> { VerifiableCredentialPresenter.supportedFormats }

    func supports(_ format: String) -> Bool
    {
        VerifiableCredentialPresenter.supportedFormats.contains(format)
    }

    /// Builds one signed W3C `VerifiablePresentation` bundling the query's matched credentials and
    /// returns it serialized to JSON. The verifier binding is `authRequest.nonce` (embedded as the
    /// VP's `verifierNonce`, and as the proof's `challenge` alongside `domain` = `client_id`);
    /// `WalletAPI.createVp` selects the holder signing key from `passcode` presence (PIN key when a
    /// passcode is supplied, biometric otherwise).
    func createVpTokens(
        hWalletToken: String,
        claimInfos: [ClaimInfo],
        authRequest: AuthorizationRequest,
        passcode: String?
    ) throws -> [AnyJSON]
    {
        // `challenge` carries the presentation binding into the VP proof (`domain` / `challenge`).
        // It defaults to nil in `WalletAPI.createVp`, so omitting it compiles but submits an unbound
        // VP that verifiers reject — always bind to the request's client_id and nonce here.
        let vp = try WalletAPI.shared.createVp(
            hWalletToken: hWalletToken,
            claimInfos: claimInfos,
            passcode: passcode,
            verifierNonce: authRequest.nonce,
            challenge: OIDV4VPChallenge(
                domain: authRequest.clientId,
                challenge: authRequest.nonce
            )
        )

        // The VP must stay a JSON *object* in `vp_token` (ldp_vp). Serializing it to a string here
        // would make the form/JWE encoder escape it a second time, and the verifier — which parses
        // the element as an object — rejects the result.
        return [try JSONDecoder().decode(AnyJSON.self, from: vp.toJsonData())]
    }
}
