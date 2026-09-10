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

import XCTest
import CryptoKit
@testable import DIDWalletSDK

/// Vectors for mdoc device authentication.
///
/// The values are the reader implementation's shared test vectors (`cose/device-authentication`,
/// `cose/mac0-self`, `session/keys`), recomputed independently on that side. They are inlined
/// rather than read from disk so the suite does not depend on another repository being present.
final class MdocDeviceAuthTests: XCTestCase
{
    // MARK: - Vector input

    /// The `SessionTranscript` as it arrives from the transport SDK: the bare three-element array.
    private let sessionTranscript = hex(
        "83d8185858a20063312e30018201d818584ba401022001215820101112131415161718191a1b1c1d1e1f2021" +
        "22232425262728292a2b2c2d2e2f225820303132333435363738393a3b3c3d3e3f404142434445464748494a" +
        "4b4c4d4e4fd818584ba401022001215820505152535455565758595a5b5c5d5e5f606162636465666768696a" +
        "6b6c6d6e6f225820707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8ff6")

    /// `SessionTranscriptBytes` — the same transcript, tag-24 wrapped. The HKDF salt is over this.
    private let sessionTranscriptBytes = hex(
        "d81858ad83d8185858a20063312e30018201d818584ba401022001215820101112131415161718191a1b1c1d" +
        "1e1f202122232425262728292a2b2c2d2e2f225820303132333435363738393a3b3c3d3e3f40414243444546" +
        "4748494a4b4c4d4e4fd818584ba401022001215820505152535455565758595a5b5c5d5e5f60616263646566" +
        "6768696a6b6c6d6e6f225820707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f" +
        "f6")

    private let docType = "org.iso.18013.5.1.mDL"

    /// `DeviceNameSpacesBytes` for an empty `DeviceNameSpaces`: tag 24 over `a0`.
    private let deviceNameSpacesBytes = hex("d81841a0")

    // MARK: - deviceAuthentication

    func testDeviceAuthenticationMatchesVector() throws
    {
        let expected = hex(
            "847444657669636541757468656e7469636174696f6e83d8185858a20063312e30018201d818584ba401" +
            "022001215820101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f22582030" +
            "3132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4fd818584ba4010220012158" +
            "20505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f22582070717273747576" +
            "7778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8ff6756f72672e69736f2e31383031332e35" +
            "2e312e6d444cd81841a0")

        let built = MdocDeviceAuth.deviceAuthentication(sessionTranscript: sessionTranscript,
                                                        docType: docType,
                                                        deviceNameSpacesBytes: deviceNameSpacesBytes)

        XCTAssertEqual(built.count, 221)
        XCTAssertEqual(built, expected)
    }

    /// The transcript has to come back out byte for byte — that is the whole point of splicing it
    /// in rather than decoding it.
    func testDeviceAuthenticationCarriesTranscriptVerbatim() throws
    {
        let built = MdocDeviceAuth.deviceAuthentication(sessionTranscript: sessionTranscript,
                                                        docType: docType,
                                                        deviceNameSpacesBytes: deviceNameSpacesBytes)

        let header = [UInt8]([0x84]) + CBOR.utf8String("DeviceAuthentication").encode()
        XCTAssertEqual(Array(built[header.count ..< header.count + sessionTranscript.count]),
                       sessionTranscript)
    }

    func testDeviceAuthenticationBytesMatchesVector() throws
    {
        let deviceAuthentication = MdocDeviceAuth.deviceAuthentication(
            sessionTranscript: sessionTranscript,
            docType: docType,
            deviceNameSpacesBytes: deviceNameSpacesBytes)

        let wrapped = MdocDeviceAuth.deviceAuthenticationBytes(deviceAuthentication)

        // 221 bytes of payload: tag 24 (2 bytes) + bstr header 0x58 0xdd (2 bytes) + 221.
        XCTAssertEqual(wrapped.count, 225)
        XCTAssertEqual(Array(wrapped.prefix(4)), hex("d81858dd"))
        XCTAssertEqual(Array(wrapped.suffix(deviceAuthentication.count)), deviceAuthentication)
    }

    // MARK: - MAC_structure

    func testMacStructureMatchesVector() throws
    {
        let deviceAuthenticationBytes = MdocDeviceAuth.deviceAuthenticationBytes(
            MdocDeviceAuth.deviceAuthentication(sessionTranscript: sessionTranscript,
                                                docType: docType,
                                                deviceNameSpacesBytes: deviceNameSpacesBytes))

        let structure = MdocDeviceAuth.macStructure(
            deviceAuthenticationBytes: deviceAuthenticationBytes)

        XCTAssertEqual(structure.count, 238)
        // "MAC0" / h'A10105' / h'' / the detached payload.
        XCTAssertEqual(Array(structure.prefix(11)), hex("84644d41433043a1010540"))
        XCTAssertEqual(Array(structure.suffix(deviceAuthenticationBytes.count)),
                       deviceAuthenticationBytes)
    }

    // MARK: - EMacKey

    func testEmacKeyMatchesVector() throws
    {
        let zab = hex("a95137b042ccb44b378c7c0c9182164fc1b54afc9c6e154ca77958ddd681bd34")
        let expectedSalt = hex("919232350b8073cfb2e0db4417e23e5940d306840f1600173e4d26fa280ff8ab")
        let expected = hex("aaf1259c9e7c7ce05fee2512c0085d28bbf28023d376a3c30f0c9594d883925d")

        // The salt is SHA-256 of the wrapped form, not of the bare array.
        XCTAssertEqual([UInt8](SHA256.hash(data: Data(sessionTranscriptBytes))), expectedSalt)

        let derived = MdocDeviceAuth.emacKey(sharedSecret: zab,
                                             sessionTranscriptBytes: sessionTranscriptBytes)
        XCTAssertEqual(derived, expected)
    }

    /// The reader's `session/emackey-short-transcript` vector: the one input size where the two
    /// readings of the salt diverge.
    ///
    /// A real transcript always exceeds HMAC's 64-byte block size, so HMAC hashes an oversized key
    /// down with SHA-256 and `salt = SessionTranscriptBytes` reaches the same value as
    /// `salt = SHA-256(SessionTranscriptBytes)`. The standard requires the latter, and only a
    /// transcript short enough to skip that reduction can tell them apart -- 13 bytes here.
    func testEmacKeySaltIsHashedNotRaw() throws
    {
        let transcriptBytes = hex("d8184a83d81841a0d81841a0f6")
        let zab = hex("1b7ec8f83e896ebcf2d1266df5d3f7af1e5147084120e9ce59b51f145889fa41")
        let expected = hex("ee23f57f7d7f5a03a2d6af7fe56b90c072863d89ddd96cc75aebefa30bd64b4a")
        // What an implementation salting with the raw transcript would produce.
        let rawSalted = hex("4d47489aaaaf084496056644dd19d387143373c74d01b05542b228d579a0af7c")

        // The point of the vector is this size: an input the block-size reduction does not touch.
        // Replace it with a "realistic" transcript and the test still passes while checking nothing.
        XCTAssertLessThanOrEqual(transcriptBytes.count, 64)

        let derived = MdocDeviceAuth.emacKey(sharedSecret: zab,
                                             sessionTranscriptBytes: transcriptBytes)
        XCTAssertEqual(derived, expected)
        XCTAssertNotEqual(derived, rawSalted)
    }

    // MARK: - Tag

    func testMacMatchesVector() throws
    {
        let emacKey = hex("aaf1259c9e7c7ce05fee2512c0085d28bbf28023d376a3c30f0c9594d883925d")
        let expectedTag = hex("4f2e17fbfe9e3408a0f96b8e341780420cf37f8d816138014ec58fc8e660e4c1")

        let deviceAuthenticationBytes = MdocDeviceAuth.deviceAuthenticationBytes(
            MdocDeviceAuth.deviceAuthentication(sessionTranscript: sessionTranscript,
                                                docType: docType,
                                                deviceNameSpacesBytes: deviceNameSpacesBytes))
        let structure = MdocDeviceAuth.macStructure(
            deviceAuthenticationBytes: deviceAuthenticationBytes)

        XCTAssertEqual(MdocDeviceAuth.mac(macStructure: structure, emacKey: emacKey), expectedTag)
    }

    /// Hashing the detached payload directly, without the `MAC_structure` wrapper, must not produce
    /// the tag — the mistake this vector exists to catch.
    func testMacOverDetachedPayloadAloneDoesNotMatch() throws
    {
        let emacKey = hex("aaf1259c9e7c7ce05fee2512c0085d28bbf28023d376a3c30f0c9594d883925d")
        let expectedTag = hex("4f2e17fbfe9e3408a0f96b8e341780420cf37f8d816138014ec58fc8e660e4c1")

        let deviceAuthenticationBytes = MdocDeviceAuth.deviceAuthenticationBytes(
            MdocDeviceAuth.deviceAuthentication(sessionTranscript: sessionTranscript,
                                                docType: docType,
                                                deviceNameSpacesBytes: deviceNameSpacesBytes))

        XCTAssertNotEqual(MdocDeviceAuth.mac(macStructure: deviceAuthenticationBytes,
                                             emacKey: emacKey),
                          expectedTag)
    }

    // MARK: - COSE_Mac0

    func testDeviceMacIsUntaggedFourElementArrayWithNullPayload() throws
    {
        let tag = hex("4f2e17fbfe9e3408a0f96b8e341780420cf37f8d816138014ec58fc8e660e4c1")

        guard case let .array(items) = MdocDeviceAuth.deviceMac(tag: tag) else {
            return XCTFail("COSE_Mac0 is a four-element array")
        }
        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items[0], .byteString(MdocDeviceAuth.macProtectedHeader))
        XCTAssertEqual(items[2], .null)
        XCTAssertEqual(items[3], .byteString(tag))
    }
}

/// Decodes a hex string. Test-local: the SDK has no such helper in scope here.
private func hex(_ string: String) -> [UInt8]
{
    var out: [UInt8] = []
    out.reserveCapacity(string.count / 2)
    var index = string.startIndex
    while index < string.endIndex {
        let next = string.index(index, offsetBy: 2)
        out.append(UInt8(string[index ..< next], radix: 16)!)
        index = next
    }
    return out
}
