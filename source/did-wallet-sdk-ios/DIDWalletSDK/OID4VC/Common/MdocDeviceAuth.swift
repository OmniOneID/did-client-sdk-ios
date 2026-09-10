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

/// The input mdoc authentication is computed over, and the MAC form of it.
///
/// `DeviceAuthentication` never travels: the holder and the reader each build it from what they
/// already hold, and only the signature or MAC is sent, as detached content (ISO/IEC 18013-5
/// 9.1.3.5 / DIS 12.4.5). Both sides therefore have to arrive at the same bytes.
///
/// That is why the array is concatenated by hand. The `SessionTranscript` reaches this SDK already
/// encoded, and the vendored `CBOR` enum has no case meaning "these bytes are already CBOR, splice
/// them in" — decoding and re-encoding would rebuild whatever the sender wrote, and an
/// indefinite-length or non-minimal encoding would come back out different from the bytes the
/// reader hashed.
enum MdocDeviceAuth
{
    /// `COSE_Mac0` protected header for mdoc authentication: `{1: 5}`, HMAC 256/256.
    ///
    /// A constant rather than something re-encoded per call, so the bytes cannot drift.
    static let macProtectedHeader: [UInt8] = [0xA1, 0x01, 0x05]

    /// `DeviceAuthentication = ["DeviceAuthentication", SessionTranscript, DocType,
    /// DeviceNameSpacesBytes]`.
    ///
    /// - Parameters:
    ///   - sessionTranscript: The transcript **as received** from the transport SDK. Spliced in
    ///     unchanged; this is the whole reason the array is built by hand.
    ///   - docType: The document type of the document being authenticated.
    ///   - deviceNameSpacesBytes: `DeviceNameSpacesBytes`, already tag-24 wrapped. Encoded once by
    ///     the caller and used both here and in `DeviceSigned.nameSpaces`, so the two cannot differ.
    /// - Returns: The encoded array.
    static func deviceAuthentication(sessionTranscript: [UInt8],
                                     docType: String,
                                     deviceNameSpacesBytes: [UInt8]) -> [UInt8]
    {
        var out: [UInt8] = [0x84]                                   // array of 4, definite length
        out += CBOR.utf8String("DeviceAuthentication").encode()
        out += sessionTranscript                                    // as received
        out += CBOR.utf8String(docType).encode()
        out += deviceNameSpacesBytes                                // as encoded by the caller
        return out
    }

    /// `DeviceAuthenticationBytes = #6.24(bstr .cbor DeviceAuthentication)`.
    ///
    /// The wrapper is safe to build with the encoder: a byte string is opaque, so nothing inside is
    /// re-encoded.
    static func deviceAuthenticationBytes(_ deviceAuthentication: [UInt8]) -> [UInt8]
    {
        return CBOR.tagged(CBOR.Tag(rawValue: 24), .byteString(deviceAuthentication)).encode()
    }

    /// The `MAC_structure` the tag is computed over (RFC 9052 §6.3).
    ///
    /// `["MAC0", protected, external_aad, payload]`. The payload is `DeviceAuthenticationBytes`
    /// itself — passing those bytes to HMAC directly, without this wrapper, is the first thing that
    /// breaks between two implementations.
    static func macStructure(deviceAuthenticationBytes: [UInt8],
                             externalAAD: [UInt8] = []) -> [UInt8]
    {
        return CBOR.array([
            .utf8String("MAC0"),
            .byteString(macProtectedHeader),
            .byteString(externalAAD),
            .byteString(deviceAuthenticationBytes)
        ]).encode()
    }

    /// Derives `EMacKey` from the ECDH shared secret.
    ///
    /// `HKDF-SHA256(Z, salt: SHA-256(SessionTranscriptBytes), info: "EMacKey", 32)`. Note the salt
    /// is over `SessionTranscriptBytes` — the tag-24 wrapped form — not the bare transcript array.
    ///
    /// - Parameters:
    ///   - sharedSecret: The raw ECDH output. Raw: no KDF has been applied to it yet.
    ///   - sessionTranscriptBytes: `SessionTranscriptBytes`, tag-24 wrapped.
    static func emacKey(sharedSecret: [UInt8], sessionTranscriptBytes: [UInt8]) -> [UInt8]
    {
        let salt = SHA256.hash(data: Data(sessionTranscriptBytes))
        let key = HKDF<SHA256>.deriveKey(inputKeyMaterial: SymmetricKey(data: Data(sharedSecret)),
                                         salt: Data(salt),
                                         info: Data("EMacKey".utf8),
                                         outputByteCount: 32)
        return key.withUnsafeBytes { [UInt8]($0) }
    }

    /// The `COSE_Mac0` tag: `HMAC-SHA-256(EMacKey, MAC_structure)`.
    static func mac(macStructure: [UInt8], emacKey: [UInt8]) -> [UInt8]
    {
        let code = HMAC<SHA256>.authenticationCode(for: Data(macStructure),
                                                   using: SymmetricKey(data: Data(emacKey)))
        return [UInt8](code)
    }

    /// The untagged `COSE_Mac0` that goes into `DeviceAuth`: `[protected, {}, null, tag]`.
    ///
    /// The payload stays `null` because `DeviceAuthenticationBytes` is detached.
    static func deviceMac(tag: [UInt8]) -> CBOR
    {
        return .array([
            .byteString(macProtectedHeader),
            .map([:]),
            .null,
            .byteString(tag)
        ])
    }
}
