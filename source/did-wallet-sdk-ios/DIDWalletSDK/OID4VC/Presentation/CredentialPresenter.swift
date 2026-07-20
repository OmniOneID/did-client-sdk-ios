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

/// Builds the `vp_token` presentation string(s) for one DCQL credential query, for a single
/// credential format. Mirrors the `CredentialAdapter` layer on the matching side: each concrete
/// presenter owns its format's store lookup and presentation assembly, and the registry selects
/// one by the query's `format`.
///
/// `OID4VPProtocol.createVpToken` branches per DCQL query id on `AuthorizationRequest`'s
/// `dcql_query.credentials[].format` and delegates here. SD-JWT and W3C (`opendid_vc`) are
/// implemented in Phase 1; mdoc is deferred to Phase 2.
protocol CredentialPresenter
{
    /// Credential formats this presenter can build a presentation for.
    func getSupportedFormats() -> Set<String>

    /// Whether this presenter handles the given DCQL credential format token.
    func supports(_ format: String) -> Bool

    /// Builds the presentation strings for the matched credentials of one DCQL query.
    ///
    /// - Parameters:
    ///   - claimInfos: The matched credentials/claims for a single DCQL query id (from
    ///     `findEligibleSubmittables`). All entries share the query's format (no mixed formats).
    ///   - authRequest: The parsed authorization request — supplies `client_id` (aud) and `nonce`.
    ///   - hWalletToken: Wallet access token; both presenters reach the wallet through `WalletAPI`
    ///     (SD-JWT credential fetch and W3C VP build).
    ///   - claimInfos: The matched credentials/claims for a single DCQL query id.
    ///   - authRequest: The parsed authorization request — supplies `client_id` (aud) and `nonce`.
    ///   - passcode: The wallet passcode when unlocking with a PIN; `nil` for biometric. Each
    ///     presenter resolves the holder signing key itself (SD-JWT from the credential's bound
    ///     `kid`, W3C from `passcode` presence).
    /// - Returns: The presentation values for this query (the `vp_token` map value). The element type
    ///   is format-dependent: SD-JWT (and mdoc in Phase 2) presentations are strings, while a W3C
    ///   `ldp_vp` presentation is a JSON object — hence `AnyJSON` rather than `String`.
    func createVpTokens(
        hWalletToken: String,
        claimInfos: [ClaimInfo],
        authRequest: AuthorizationRequest,
        passcode: String?
    ) throws -> [AnyJSON]
}

/// Registry of credential presenters. Selects the presenter for a DCQL credential format.
/// Phase 1 registers the SD-JWT and W3C (`opendid_vc`) presenters; mdoc is added in Phase 2.
final class CredentialPresenterRegistry
{
    static let shared = CredentialPresenterRegistry()

    private var presenters: [CredentialPresenter] = []

    private init()
    {
        register(SDJWTPresenter())
        register(VerifiableCredentialPresenter())
        // Phase 2: register(MDocPresenter())
    }

    func register(_ presenter: CredentialPresenter)
    {
        presenters.append(presenter)
    }

    func findPresenter(_ format: String) -> CredentialPresenter?
    {
        presenters.first { $0.supports(format) }
    }
}
