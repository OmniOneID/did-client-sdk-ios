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

/// One matched credential for a single DCQL credential query: which stored credential
/// (`credentialId`) satisfies the query (`queryId`) and which claims to disclose (`claimCodes`).
/// Returned by `matchCredentials`; the app may drop entries or rebuild the list (hence the public
/// initializer) before passing it to `createVpToken`, but not narrow `claimCodes`.
public struct MatchedCredential
{
    /// The DCQL credential query id this match answers (`dcql_query.credentials[].id`).
    public let queryId: String
    /// The matched stored credential id.
    public let credentialId: String
    /// The claims to disclose, named as DCQL path codes.
    ///
    /// `matchCredentials` always fills this: the claims the query asked for, or — when the query
    /// asked for the credential as a whole — every claim it can disclose. The app can therefore
    /// show the holder exactly what leaves the wallet without knowing the credential's shape.
    ///
    /// On the way back into `createVpToken` the list must still carry every matched claim: consent
    /// is given per credential, not per claim, so withholding one means dropping the whole
    /// `MatchedCredential`. An empty list is rejected — full disclosure is expressed by naming every
    /// claim, which is exactly what matching returned.
    public let claimCodes: [String]

    public init(queryId: String, credentialId: String, claimCodes: [String])
    {
        self.queryId = queryId
        self.credentialId = credentialId
        self.claimCodes = claimCodes
    }
}
