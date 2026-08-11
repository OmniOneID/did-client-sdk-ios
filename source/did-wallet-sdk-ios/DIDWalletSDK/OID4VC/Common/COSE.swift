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

/// A decoded `COSE_Sign1` (RFC 9052 §4.2), as carried by an mdoc's `issuerAuth` and by a
/// presentation's `deviceSignature`.
///
/// The protected header is kept as the bytes that arrived, never as a re-encoding of the decoded
/// map: those bytes are an input to the signature, and CBOR admits more than one encoding of the
/// same map. Everything the signature covers is held here verbatim for the same reason.
struct COSESign1: Equatable {

    /// Header labels this SDK reads (RFC 9052 §3.1).
    enum Label {
        static let alg: Int64 = 1
        static let kid: Int64 = 4
        static let x5chain: Int64 = 33
    }

    /// `alg` value for ECDSA w/ SHA-256, the only algorithm the mdoc path signs or verifies with.
    static let algES256: Int64 = -7

    /// The protected header as received: a byte string whose contents are a CBOR map.
    let protectedBytes: [UInt8]
    let protectedHeader: [Int64: CBOR]
    let unprotectedHeader: [Int64: CBOR]
    /// The payload as received. `nil` for a detached payload, which this SDK does not accept.
    let payload: [UInt8]?
    /// The raw ECDSA signature, `r ‖ s`, 64 bytes for ES256.
    let signature: [UInt8]

    /// `alg`, from the protected header — the only place it is trusted, since the unprotected
    /// header is not covered by the signature.
    var algorithm: Int64? {
        guard let value = protectedHeader[Label.alg] else { return nil }
        return value.int64Value
    }

    /// `kid`, from either header, decoded as UTF-8.
    ///
    /// In this SDK's trust model a `kid` is a DID URL — `did:omn:issuer?versionId=1#assert` — that
    /// resolves to the DID Document holding the verification key. It travels as a byte string per
    /// RFC 9052, so the bytes are read as UTF-8 rather than used as an opaque identifier.
    var keyIdentifier: String? {
        let value = protectedHeader[Label.kid] ?? unprotectedHeader[Label.kid]
        guard case let .byteString(bytes)? = value else { return nil }
        return String(bytes: bytes, encoding: .utf8)
    }

    /// Whether the signer supplied an X.509 chain. This SDK verifies through the DID `kid`, so a
    /// chain is not consulted; the accessor exists to tell "no chain" apart from "chain ignored".
    var hasX5Chain: Bool {
        return protectedHeader[Label.x5chain] != nil || unprotectedHeader[Label.x5chain] != nil
    }

    /// The bytes the signature is computed over: `Sig_structure` for a signature1 context
    /// (RFC 9052 §4.4), encoded as a definite-length array of four elements.
    ///
    /// Array encoding is positional, so this is deterministic without depending on how the CBOR
    /// library orders map keys.
    func signatureInput(externalAAD: [UInt8] = []) throws -> [UInt8] {
        guard let payload = payload else {
            throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 has a detached payload").getError()
        }
        let structure = CBOR.array([
            .utf8String("Signature1"),
            .byteString(protectedBytes),
            .byteString(externalAAD),
            .byteString(payload)
        ])
        return structure.encode()
    }

    /// Decodes a `COSE_Sign1`, which is a four-element array whether or not it arrives inside the
    /// `18` tag.
    static func decode(_ item: CBOR) throws -> COSESign1 {
        var item = item
        if case let .tagged(tag, inner) = item {
            guard tag.rawValue == 18 else {
                throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 carries tag \(tag.rawValue)").getError()
            }
            item = inner
        }
        guard case let .array(elements) = item, elements.count == 4 else {
            throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 is not a 4-element array").getError()
        }
        guard case let .byteString(protectedBytes) = elements[0] else {
            throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 protected header is not a byte string").getError()
        }
        guard case let .map(unprotected) = elements[1] else {
            throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 unprotected header is not a map").getError()
        }
        guard case let .byteString(signature) = elements[3] else {
            throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 signature is not a byte string").getError()
        }

        let payload: [UInt8]?
        switch elements[2] {
        case let .byteString(bytes): payload = bytes
        case .null:                  payload = nil
        default:
            throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 payload is not a byte string").getError()
        }

        // An empty protected header is encoded as a zero-length byte string, not as an encoded
        // empty map, so it has no map to decode.
        var protectedHeader: [Int64: CBOR] = [:]
        if !protectedBytes.isEmpty {
            guard case let .map(decoded)? = try CBOR.decode(protectedBytes) else {
                throw OID4VCManagerError.invalidMdoc(detail: "COSE_Sign1 protected header is not a map").getError()
            }
            protectedHeader = COSESign1.labelled(decoded)
        }

        return COSESign1(protectedBytes: protectedBytes,
                         protectedHeader: protectedHeader,
                         unprotectedHeader: COSESign1.labelled(unprotected),
                         payload: payload,
                         signature: signature)
    }

    /// Keeps the integer-labelled header entries. Text labels are legal in COSE but name private
    /// extensions, and nothing in this SDK reads one.
    private static func labelled(_ map: OrderedDictionary<CBOR, CBOR>) -> [Int64: CBOR] {
        var out: [Int64: CBOR] = [:]
        for (key, value) in map {
            if let label = key.int64Value {
                out[label] = value
            }
        }
        return out
    }
}

extension CBOR {
    /// The value as a signed integer, for the small numbers COSE uses as labels and algorithms.
    var int64Value: Int64? {
        switch self {
        case let .unsignedInt(value):
            return value <= UInt64(Int64.max) ? Int64(value) : nil
        case let .negativeInt(value):
            return value <= UInt64(Int64.max) ? -1 - Int64(value) : nil
        default:
            return nil
        }
    }
}
