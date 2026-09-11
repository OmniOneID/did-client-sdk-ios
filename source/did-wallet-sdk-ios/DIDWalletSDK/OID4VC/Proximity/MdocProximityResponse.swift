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

/// How one document was authenticated.
public enum MdocDeviceAuthMethod: String, Sendable
{
    case deviceSignature
    case deviceMac
}

/// A built `DeviceResponse`, and how each document in it was authenticated.
public struct MdocDeviceResponse
{
    /// The `DeviceResponse` CBOR. **Plaintext** — the transport SDK encrypts it before sending.
    public let response: Data
    /// `credentialId` → the method actually used for that document.
    ///
    /// Keyed by credential rather than document type, since a response may carry the same type
    /// twice, and because the method follows the document's device key.
    public let authMethods: [String: MdocDeviceAuthMethod]

    public init(response: Data, authMethods: [String: MdocDeviceAuthMethod])
    {
        self.response = response
        self.authMethods = authMethods
    }
}

/// What building a response needs from the wallet's keys.
///
/// Injected so the assembly can be exercised without the Secure Enclave; the wallet's
/// implementation is wired in at the API layer.
protocol MdocDeviceKeyOperations
{
    /// Whether this document's device key can perform ECDH at all.
    ///
    /// Asked of the key, not of the OS version: a key created before key agreement was requested
    /// cannot do it however new the device is.
    func canKeyAgree(credentialId: String) throws -> Bool

    /// The raw ECDH output with the reader's ephemeral public key. No KDF is applied.
    ///
    /// - Throws: `MdocDeviceKeyError.keyAgreementUnsupported` when the key turns out not to do key
    ///   agreement after all. Any other error means something else went wrong and is not a reason
    ///   to fall back.
    func keyAgreement(credentialId: String, readerPublicKey: [UInt8]) throws -> [UInt8]

    /// Signs a digest with the document's device key, returning the raw 65-byte compact signature.
    func sign(credentialId: String, digest: Data) throws -> Data
}

/// Errors the key operations raise that the builder interprets rather than propagates.
enum MdocDeviceKeyError: Error
{
    /// The key cannot do ECDH. The only condition that makes the MAC path fall back to a signature:
    /// a cancelled prompt or a missing key would fail the signature the same way, and an internal
    /// failure would be hidden by falling back.
    case keyAgreementUnsupported
}

/// Assembles a `DeviceResponse` from what the holder agreed to.
enum MdocProximityResponseBuilder
{
    private static let responseVersion = "1.0"
    private static let statusOK: UInt64 = 0

    /// `DeviceNameSpacesBytes` for an empty `DeviceNameSpaces`.
    ///
    /// Encoded once and used twice — as the fourth element of `DeviceAuthentication` and as
    /// `DeviceSigned.nameSpaces` — so the bytes signed and the bytes sent cannot differ.
    static let emptyDeviceNameSpacesBytes: [UInt8] =
        CBOR.tagged(CBOR.Tag(rawValue: 24), .byteString(CBOR.map([:]).encode())).encode()

    /// Checks the holder's selection against a fresh match of the same request.
    ///
    /// The comparison is against the match result rather than the request: the request also names
    /// elements this wallet does not hold, so comparing with it would let a selection through that
    /// cannot be assembled.
    static func validate(selected: [MdocRequestedDocument],
                         against matched: [MdocRequestedDocument]) throws
    {
        guard !selected.isEmpty
        else
        {
            throw OID4VCManagerError.emptyMdocSelection.getError()
        }

        var allowed: [String: (docType: String, codes: Set<String>)] = [:]
        for element in matched
        {
            allowed[key(element.docRequestIndex, element.credentialId)] =
                (element.docType, Set(element.claimCodes))
        }

        var seen: Set<String> = []
        for element in selected
        {
            let identity = key(element.docRequestIndex, element.credentialId)

            guard let match = allowed[identity]
            else
            {
                throw OID4VCManagerError.invalidSelectedMdocDocuments(
                    detail: "document '\(element.credentialId)' does not answer docRequest "
                          + "\(element.docRequestIndex)").getError()
            }
            guard match.docType == element.docType
            else
            {
                throw OID4VCManagerError.invalidSelectedMdocDocuments(
                    detail: "docType of document '\(element.credentialId)' was changed").getError()
            }
            guard seen.insert(identity).inserted
            else
            {
                throw OID4VCManagerError.duplicateSelectedMdocDocument.getError()
            }
            guard !element.claimCodes.isEmpty
            else
            {
                throw OID4VCManagerError.emptyMdocClaimCodes.getError()
            }
            // A repeated code would put the same IssuerSignedItem in twice, which the response
            // structure forbids.
            guard Set(element.claimCodes).count == element.claimCodes.count
            else
            {
                throw OID4VCManagerError.duplicateMdocClaimCode.getError()
            }
            // Dropping elements is the holder's consent; adding them is not.
            let extra = Set(element.claimCodes).subtracting(match.codes).sorted()
            guard extra.isEmpty
            else
            {
                throw OID4VCManagerError.invalidSelectedMdocDocuments(
                    detail: "document '\(element.credentialId)' names \(extra.joined(separator: ", "))"
                          + ", which did not match").getError()
            }
        }
    }

    /// Builds the response.
    ///
    /// - Parameters:
    ///   - selected: What the holder agreed to, already checked against `matched`.
    ///   - documents: `credentialId` → the stored document.
    ///   - sessionTranscript: The transcript **as received** from the transport SDK — either
    ///     `SessionTranscriptBytes` (`#6.24(bstr .cbor SessionTranscript)`) or the bare
    ///     `SessionTranscript` array. Neither form is re-encoded; see `SessionTranscriptInput`.
    ///   - keys: The wallet's key operations.
    /// - Returns: The plaintext response and the method used per document.
    static func build(selected: [MdocRequestedDocument],
                      documents: [String: Mdoc],
                      sessionTranscript: [UInt8],
                      keys: MdocDeviceKeyOperations) throws -> MdocDeviceResponse
    {
        let transcript = try SessionTranscriptInput(sessionTranscript)

        var authMethods: [String: MdocDeviceAuthMethod] = [:]
        var deviceAuthByCredential: [String: CBOR] = [:]
        var documentItems: [CBOR] = []

        for element in selected
        {
            guard let mdoc = documents[element.credentialId]
            else
            {
                throw OID4VCManagerError.invalidSelectedMdocDocuments(
                    detail: "document '\(element.credentialId)' is not stored").getError()
            }

            let items = try MdocPresenter.resolveElements(mdoc: mdoc,
                                                          claimCodes: element.claimCodes)
            let issuerSigned = try MdocPresenter.issuerSignedStructure(mdoc: mdoc, selected: items)

            // One decision, one computation per document: the same credential used for two
            // requests authenticates identically, and `authMethods` could not describe it
            // otherwise.
            let authStructure: CBOR
            if let cached = deviceAuthByCredential[element.credentialId]
            {
                authStructure = cached
            }
            else
            {
                let built = try makeDeviceAuth(credentialId: element.credentialId,
                                               docType: mdoc.docType,
                                               transcript: transcript,
                                               keys: keys)
                deviceAuthByCredential[element.credentialId] = built.structure
                authMethods[element.credentialId] = built.method
                authStructure = built.structure
            }

            documentItems.append(.map([
                "docType": .utf8String(mdoc.docType),
                "issuerSigned": issuerSigned,
                "deviceSigned": .map([
                    "nameSpaces": CBOR.tagged(CBOR.Tag(rawValue: 24),
                                              .byteString(CBOR.map([:]).encode())),
                    "deviceAuth": authStructure
                ])
            ]))
        }

        // Partial disclosure is still status 0: any other value forbids returning documents at all.
        let response = CBOR.map([
            "version": .utf8String(responseVersion),
            "documents": .array(documentItems),
            "status": .unsignedInt(statusOK)
        ])

        return MdocDeviceResponse(response: Data(response.encode()), authMethods: authMethods)
    }

    // MARK: - Private

    private static func key(_ docRequestIndex: Int, _ credentialId: String) -> String
    {
        return "\(docRequestIndex)\u{0}\(credentialId)"
    }

    /// Decides the method for one document and produces its `DeviceAuth`.
    private static func makeDeviceAuth(credentialId: String,
                                       docType: String,
                                       transcript: SessionTranscriptInput,
                                       keys: MdocDeviceKeyOperations)
        throws -> (structure: CBOR, method: MdocDeviceAuthMethod)
    {
        let deviceAuthenticationBytes = MdocDeviceAuth.deviceAuthenticationBytes(
            MdocDeviceAuth.deviceAuthentication(sessionTranscript: transcript.sessionTranscript,
                                                docType: docType,
                                                deviceNameSpacesBytes: emptyDeviceNameSpacesBytes))

        // No reader ephemeral key means no shared secret to MAC with. Not reachable over device
        // retrieval, where a session always carries one, but it is over the paths that reuse this
        // API with a transcript built without one.
        if let readerPublicKey = transcript.readerPublicKey,
           try keys.canKeyAgree(credentialId: credentialId)
        {
            do
            {
                let sharedSecret = try keys.keyAgreement(credentialId: credentialId,
                                                         readerPublicKey: readerPublicKey)
                let emacKey = MdocDeviceAuth.emacKey(
                    sharedSecret: sharedSecret,
                    sessionTranscriptBytes: transcript.sessionTranscriptBytes)
                let structure = MdocDeviceAuth.macStructure(
                    deviceAuthenticationBytes: deviceAuthenticationBytes)
                let tag = MdocDeviceAuth.mac(macStructure: structure, emacKey: emacKey)

                return (.map(["deviceMac": MdocDeviceAuth.deviceMac(tag: tag)]), .deviceMac)
            }
            catch MdocDeviceKeyError.keyAgreementUnsupported
            {
                // The pre-check said yes and the operation said no. Falling back beats failing the
                // whole submission, and the reader verifies either form.
            }
        }

        let signature = try deviceSignature(credentialId: credentialId,
                                            deviceAuthenticationBytes: deviceAuthenticationBytes,
                                            keys: keys)
        return (.map(["deviceSignature": signature]), .deviceSignature)
    }

    private static func deviceSignature(credentialId: String,
                                        deviceAuthenticationBytes: [UInt8],
                                        keys: MdocDeviceKeyOperations) throws -> CBOR
    {
        let protectedHeader = CBOR.map([1: -7]).encode()   // {1: -7}, ES256
        let signatureInput = CBOR.array([
            .utf8String("Signature1"),
            .byteString(protectedHeader),
            .byteString([]),
            .byteString(deviceAuthenticationBytes)
        ]).encode()

        let signature = try keys.sign(credentialId: credentialId,
                                      digest: Data(signatureInput).sha256())

        return .array([
            .byteString(protectedHeader),
            .map([:]),
            .null,
            .byteString([UInt8](signature.dropFirst()))    // 65-byte compact (v‖r‖s) → 64-byte r‖s
        ])
    }
}

/// The transcript in the two forms the response needs, taken from whichever form the caller had.
///
/// The transport SDK derives its session keys over `SessionTranscriptBytes`, so that is what it
/// hands on; a caller that built the transcript itself may hold the bare `SessionTranscript`
/// array instead. Both are accepted, and neither is re-encoded: `bstr .cbor` preserves the bytes
/// it wraps, so the array inside `SessionTranscriptBytes` is exactly what the reader hashed, and
/// wrapping the bare array in a minimal tag-24 header reproduces `SessionTranscriptBytes`.
///
/// The two forms go to different places. `DeviceAuthentication` embeds the bare array as its
/// second element; the `EMacKey` salt is taken over the tag-24 form (ISO/IEC 18013-5 9.1.3.5 /
/// DIS 12.4.5, with `SessionTranscriptBytes` defined in 9.1.5.1 / DIS 12.7.1).
struct SessionTranscriptInput
{
    /// `SessionTranscript`, the bare three-element array, spliced into `DeviceAuthentication`.
    let sessionTranscript: [UInt8]

    /// `SessionTranscriptBytes`, the tag-24 wrapped form the `EMacKey` salt is taken over.
    let sessionTranscriptBytes: [UInt8]

    /// The reader's ephemeral public point from `EReaderKeyBytes`, or nil where the transcript
    /// carries none.
    let readerPublicKey: [UInt8]?

    init(_ received: [UInt8]) throws
    {
        let parts: [CBOR]
        switch try? CBOR.decode(received)
        {
        case let .tagged(tag, .byteString(inner))? where tag.rawValue == 24:
            guard case let .array(innerParts)? = try? CBOR.decode(inner), innerParts.count == 3
            else
            {
                throw OID4VCManagerError.invalidSessionTranscript(
                    detail: "SessionTranscriptBytes does not wrap a three-element array").getError()
            }
            parts = innerParts
            sessionTranscript = inner
            sessionTranscriptBytes = received

        case let .array(receivedParts)? where receivedParts.count == 3:
            parts = receivedParts
            sessionTranscript = received
            sessionTranscriptBytes = CBOR.tagged(CBOR.Tag(rawValue: 24),
                                                 .byteString(received)).encode()

        default:
            throw OID4VCManagerError.invalidSessionTranscript(
                detail: "neither SessionTranscriptBytes nor a three-element array").getError()
        }

        readerPublicKey = try Self.readerPublicKey(eReaderKeyBytes: parts[1])
    }

    /// Reads `EReaderKeyBytes` and returns the reader's public point.
    private static func readerPublicKey(eReaderKeyBytes: CBOR) throws -> [UInt8]?
    {
        if case .null = eReaderKeyBytes { return nil }

        guard case let .tagged(tag, payload) = eReaderKeyBytes,
              tag.rawValue == 24,
              case let .byteString(coseKeyBytes) = payload,
              case let .map(coseKey)? = try? CBOR.decode(coseKeyBytes)
        else
        {
            throw OID4VCManagerError.invalidSessionTranscript(
                detail: "EReaderKeyBytes is not an embedded COSE_Key").getError()
        }
        guard case let .byteString(x)? = coseKey[.negativeInt(1)],      // label -2
              case let .byteString(y)? = coseKey[.negativeInt(2)],      // label -3
              x.count == 32, y.count == 32
        else
        {
            throw OID4VCManagerError.invalidSessionTranscript(
                detail: "EReaderKey is not a P-256 public key").getError()
        }

        return [0x04] + x + y
    }
}
