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
/// (holder proof, `Secp256r1Signature2018`), and returns it. The signed VP is serialized to JSON as
/// the `vp_token` string. This is why `createVpToken` carries `hWalletToken`: `WalletAPI.createVp`
/// verifies the wallet access token before presenting.
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
    /// VP's `verifierNonce`); `WalletAPI.createVp` selects the holder signing key from `pin` presence
    /// (PIN key when a passcode is supplied, biometric otherwise).
    func createVpTokens(
        hWalletToken: String,
        claimInfos: [ClaimInfo],
        authRequest: AuthorizationRequest,
        pin: String?
    ) throws -> [String]
    {
        let vp = try WalletAPI.shared.createVp(
            hWalletToken: hWalletToken,
            claimInfos: claimInfos,
            passcode: pin,
            verifierNonce: authRequest.nonce
        )

        return [try vp.toJson()]
    }
}
