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

public enum CredentialFormat {
    case vcdm, sdJwtVc, msoMdoc

    /// The DCQL `format` token this SDK writes for the format.
    ///
    /// One definition for a string the SDK compares against in a dozen places and an app renders
    /// from: a second copy of it anywhere is a copy that can fall out of step, and the failure is
    /// silent — a stale token matches nothing and the screen simply comes up empty.
    public var token: String {
        switch self {
        case .vcdm:    return "opendid_vc"
        case .sdJwtVc: return "dc+sd-jwt-did"
        case .msoMdoc: return "mso_mdoc-did"
        }
    }

    /// The format a DCQL `format` token names, or `nil` for a token this SDK does not handle.
    ///
    /// Accepts the aliases a verifier may send as well as the canonical token, because a query is
    /// written by the other side and this SDK reads more spellings than it writes.
    /// - Parameter token: The `format` value from a DCQL credential query.
    public init?(token: String) {
        guard let format = CredentialFormat.byToken[token] else { return nil }
        self = format
    }

    /// Every token that names a format, canonical and alias alike.
    private static let byToken: [String: CredentialFormat] = [
        CredentialFormat.vcdm.token:    .vcdm,
        "jwt_vc_json":                  .vcdm,
        "jwt_vc":                       .vcdm,
        "ldp_vc":                       .vcdm,
        CredentialFormat.sdJwtVc.token: .sdJwtVc,
        "vc+sd-jwt":                    .sdJwtVc,
        "sd-jwt":                       .sdJwtVc,
        CredentialFormat.msoMdoc.token: .msoMdoc
    ]

    /// Whether any format this SDK handles goes by the token.
    static func isKnown(token: String) -> Bool { byToken[token] != nil }
}

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

    /// The DID of the issuer that signed this credential. See `SDJWT.issuerDid`.
    public var issuerDid: String? { sdjwt.issuerDid }

    /// Every claim the holder can be asked to consent to, in the order the issuer wrote them.
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

    /// The DID of the issuer that signed this document. See `Mdoc.issuerDid`.
    public var issuerDid: String? { mdoc.issuerDid }

    /// Every element the holder can be asked to consent to, in the issuer's order.
    ///
    /// The stored item and the document it holds answer this the same way; the property is here so
    /// a screen built from a wallet listing does not have to reach through to `mdoc` first.
    public var consentItems: [MdocConsentItem] { mdoc.consentItems }
}


