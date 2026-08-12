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
    

public protocol CredentialItem: Identifiable {
    var id: String { get }
    var format: CredentialFormat { get }
}

public enum CredentialFormat { case vcdm, sdJwtVc, msoMdoc }

public struct VCDMCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let vc: VerifiableCredential
    public let zkp: ZKPCredential?
}

public struct SdJwtCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let configurationId: String
    public let kid: String
    public let credentialIdentifier: String?
    public let sdjwt: SDJWT

    /// Every claim the holder can be asked to consent to, sorted by code.
    ///
    /// Reading it can fail because an SD-JWT's claims live in its issuer JWT payload, which is
    /// parsed on demand — unlike an mdoc, whose elements were already decoded when it was parsed.
    public var consentItems: [SdJwtConsentItem] {
        get throws { try sdjwt.consentItems() }
    }
}

public struct MdocCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let configurationId: String
    public let kid: String
    public let credentialIdentifier: String?
    public let mdoc: Mdoc

    /// Every element the holder can be asked to consent to, in the issuer's order.
    ///
    /// The stored item and the document it holds answer this the same way; the property is here so
    /// a screen built from a wallet listing does not have to reach through to `mdoc` first.
    public var consentItems: [MdocConsentItem] { mdoc.consentItems }
}


