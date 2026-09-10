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
internal import OrderedCollections

/// Builds an ISO/IEC 18013-5 `DeviceResponse` (a `vp_token` entry) for OID4VP.
///
/// Picks up where DCQL matching leaves off, and keeps the same contract as `SDJWTPresenter`: pure,
/// no wallet access, the holder key reached only through an injected `signDigest`.
///
/// Two properties decide whether a presentation verifies, and both are about bytes rather than
/// values:
///
/// - **The issuer's items are moved across verbatim.** The MSO digests were computed over those
///   exact bytes; re-encoding an item would produce equivalent CBOR with a different digest.
/// - **Every structure built here inserts its keys in one fixed order.** The vendored CBOR encoder
///   preserves insertion order and never sorts, so a map assembled in a different order encodes to
///   different bytes — and both sides hash these structures independently. Do not reorder the
///   literals below.
struct MdocPresenter
{
    /// mdoc credential format tokens this presenter can handle.
    static let supportedFormats: Set<String> = [CredentialFormat.msoMdoc.token]

    /// `DeviceResponse.version`, and the only version this SDK emits.
    private static let deviceResponseVersion = "1.0"

    /// `DeviceResponse.status` 0 — OK (ISO/IEC 18013-5 §8.3.2.1.2.3).
    private static let statusOK: UInt64 = 0

    /// What the verifier's response-encryption key contributes to the session binding.
    ///
    /// For `direct_post.jwt` the handover carries the thumbprint of the key the response is sealed
    /// to, which is what stops a sealed response from being replayed to a different verifier. For
    /// `direct_post` there is no such key and the slot is null — the distinction is the caller's to
    /// make, so it is passed in rather than guessed here.
    enum ResponseEncryption
    {
        case none
        case key(JWK)
    }

    /// Builds the `DeviceResponse` for one credential.
    /// - Parameters:
    ///   - mdoc: The stored document, as issued.
    ///   - claimCodes: The codes the holder agreed to disclose, as named by `MdocClaimIndex`.
    ///   - clientId: The request's `client_id`.
    ///   - nonce: The request's `nonce`.
    ///   - responseUri: The request's `response_uri`.
    ///   - responseEncryption: The verifier's response-encryption key, when the response is sealed.
    ///   - signDigest: Signs the `Sig_structure` digest with the holder key; returns the raw
    ///     65-byte compact signature (`v‖r‖s`).
    /// - Returns: The base64url-encoded `DeviceResponse`.
    /// - Throws: `OID4VCManagerError.invalidSelectedCredentials` when a code names no element of the
    ///   document or names two of them.
    static func createVpToken(
        mdoc: Mdoc,
        claimCodes: [String],
        clientId: String,
        nonce: String,
        responseUri: String,
        responseEncryption: ResponseEncryption,
        signDigest: (_ digest: Data) throws -> Data
    ) throws -> String
    {
        // Full disclosure is expressed by naming every element, so an empty list would present
        // nothing the holder was shown — reject it rather than read it as "everything".
        guard !claimCodes.isEmpty
        else
        {
            throw OID4VCManagerError.invalidSelectedCredentials(
                detail: "no claim selected for the credential to present").getError()
        }

        let selected = try resolveElements(mdoc: mdoc, claimCodes: claimCodes)
        let issuerSigned = try issuerSignedStructure(mdoc: mdoc, selected: selected)

        let sessionTranscript = try sessionTranscript(clientId: clientId,
                                                      nonce: nonce,
                                                      responseUri: responseUri,
                                                      responseEncryption: responseEncryption)
        let deviceSignature = try deviceSignature(docType: mdoc.docType,
                                                  sessionTranscript: sessionTranscript,
                                                  signDigest: signDigest)

        // Fixed insertion order, here and in every helper below.
        let document = CBOR.map([
            "docType": .utf8String(mdoc.docType),
            "issuerSigned": issuerSigned,
            "deviceSigned": .map([
                "nameSpaces": taggedBytes(CBOR.map([:]).encode()),
                "deviceAuth": .map(["deviceSignature": deviceSignature])
            ])
        ])

        let deviceResponse = CBOR.map([
            "version": .utf8String(deviceResponseVersion),
            "documents": .array([document]),
            "status": .unsignedInt(statusOK)
        ])

        return Data(deviceResponse.encode()).base64URLEncoded
    }

    /// Resolves claim codes to the issuer-signed items they name.
    ///
    /// The codes are looked up in `MdocClaimIndex` — the same index that named them during matching
    /// — and never split back into a namespace and an element identifier. A code naming two
    /// elements is refused rather than resolved, since either choice would disclose an element the
    /// holder did not single out.
    static func resolveElements(mdoc: Mdoc, claimCodes: [String]) throws -> [String: [MdocIssuerSignedItem]]
    {
        let index = MdocClaimIndex.build(mdoc: mdoc)

        var wanted: [String: Set<String>] = [:]
        var missing: [String] = []
        var ambiguous: [String] = []

        for code in claimCodes
        {
            guard let entry = index.entry(for: code)
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
            wanted[entry.namespace, default: []].insert(entry.elementIdentifier)
        }

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

        // Filtering the document's own lists keeps the issuer's element order.
        var selected: [String: [MdocIssuerSignedItem]] = [:]
        for (namespace, identifiers) in wanted
        {
            selected[namespace] = (mdoc.items[namespace] ?? []).filter {
                identifiers.contains($0.elementIdentifier)
            }
        }
        return selected
    }

    /// `SessionTranscript` for OID4VP (OpenID4VP 1.0, Annex B.2.6.1): the two transports ISO defines
    /// are unused, and the third element carries the handover that binds this response to this
    /// request.
    ///
    /// Nothing of this structure travels with the response — the verifier rebuilds it from the
    /// request it sent — so every field has to be the type the CDDL names rather than an equivalent
    /// spelling of the same value. `jwkThumbprint` in particular is a `bstr` of the digest, not the
    /// base64url text a JSON member would carry.
    static func sessionTranscript(clientId: String,
                                  nonce: String,
                                  responseUri: String,
                                  responseEncryption: ResponseEncryption) throws -> CBOR
    {
        let thumbprint: CBOR
        switch responseEncryption
        {
        case .none:
            thumbprint = .null
        case .key(let jwk):
            thumbprint = .byteString([UInt8](try JWKThumbprint.sha256(of: jwk)))
        }

        // OpenID4VPHandoverInfo — positional, so its encoding does not depend on map ordering.
        let handoverInfo = CBOR.array([
            .utf8String(clientId),
            .utf8String(nonce),
            thumbprint,
            .utf8String(responseUri)
        ])
        let handoverInfoHash = Data(handoverInfo.encode()).sha256()

        return .array([
            .null,  // DeviceEngagementBytes — not used over OID4VP
            .null,  // EReaderKeyBytes — not used over OID4VP
            .array([.utf8String("OpenID4VPHandover"), .byteString([UInt8](handoverInfoHash))])
        ])
    }

    // MARK: - Private

    /// The `IssuerSigned` to send: the issuer's own `issuerAuth`, and only the selected items —
    /// each still the bytes the issuer signed.
    /// Internal rather than private: the proximity path builds the same structure, and one encoder
    /// for issuer bytes is the point — two would be free to drift.
    static func issuerSignedStructure(mdoc: Mdoc,
                                      selected: [String: [MdocIssuerSignedItem]]) throws -> CBOR
    {
        var nameSpaces = OrderedDictionary<CBOR, CBOR>()
        // The document's own namespace order, not the selection's, so the same selection always
        // encodes the same way.
        for namespace in mdoc.items.keys.sorted()
        {
            guard let items = selected[namespace], !items.isEmpty else { continue }
            nameSpaces[.utf8String(namespace)] = .array(try items.map { item in
                // The item bytes carry their own tag 24 wrapper: they are moved, never rebuilt.
                //
                // Bytes that will not decode mean the stored document is not what it was when it
                // was verified. Writing a placeholder instead would hand the verifier a document
                // that fails its digest check, which reads as the holder having tampered with it.
                guard let decoded = try CBOR.decode(item.itemBytes)
                else
                {
                    throw OID4VCManagerError.invalidMdoc(
                        detail: "IssuerSignedItemBytes of '\(item.elementIdentifier)' is not CBOR").getError()
                }
                return decoded
            })
        }

        return .map([
            "nameSpaces": .map(nameSpaces),
            "issuerAuth": issuerAuthStructure(mdoc.issuerAuth)
        ])
    }

    private static func issuerAuthStructure(_ issuerAuth: COSESign1) -> CBOR
    {
        var unprotected = OrderedDictionary<CBOR, CBOR>()
        for (label, value) in issuerAuth.unprotectedHeader.sorted(by: { $0.key < $1.key })
        {
            unprotected[cbor(label)] = value
        }
        return .array([
            .byteString(issuerAuth.protectedBytes),
            .map(unprotected),
            issuerAuth.payload.map { CBOR.byteString($0) } ?? .null,
            .byteString(issuerAuth.signature)
        ])
    }

    /// The holder's `COSE_Sign1` over `DeviceAuthenticationBytes`.
    ///
    /// The payload is detached: the verifier rebuilds `DeviceAuthentication` from the request it
    /// sent and the document it received, so sending it back would only be an assertion of what the
    /// verifier already knows.
    private static func deviceSignature(docType: String,
                                        sessionTranscript: CBOR,
                                        signDigest: (_ digest: Data) throws -> Data) throws -> CBOR
    {
        let deviceNameSpaces = taggedBytes(CBOR.map([:]).encode())
        let deviceAuthentication = CBOR.array([
            .utf8String("DeviceAuthentication"),
            sessionTranscript,
            .utf8String(docType),
            deviceNameSpaces
        ])
        let deviceAuthenticationBytes = taggedBytes(deviceAuthentication.encode())

        // Protected header {1: -7} (ES256), which is what the signature commits to.
        let protectedBytes = CBOR.map([.unsignedInt(1): .negativeInt(6)]).encode()
        let sigStructure = CBOR.array([
            .utf8String("Signature1"),
            .byteString(protectedBytes),
            .byteString([]),
            .byteString(deviceAuthenticationBytes.encode())
        ])

        // The signer returns a 65-byte compact signature (v‖r‖s); COSE ES256 wants 64-byte r‖s.
        let compactSignature = try signDigest(Data(sigStructure.encode()).sha256())
        let signature = [UInt8](compactSignature.dropFirst())

        return .array([
            .byteString(protectedBytes),
            .map([:]),
            .null,
            .byteString(signature)
        ])
    }

    /// Wraps encoded CBOR in tag 24, the "embedded CBOR" wrapper every hashed mdoc structure uses.
    private static func taggedBytes(_ encoded: [UInt8]) -> CBOR
    {
        return .tagged(CBOR.Tag(rawValue: 24), .byteString(encoded))
    }

    private static func cbor(_ label: Int64) -> CBOR
    {
        return label < 0 ? .negativeInt(UInt64(-1 - label)) : .unsignedInt(UInt64(label))
    }
}
