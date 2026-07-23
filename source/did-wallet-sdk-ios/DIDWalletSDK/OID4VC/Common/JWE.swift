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

struct JWE
{
    let protectedHeader: JWEProtectedHeader
    let rawProtectedHeader: String
    let encryptedKey: Data
    let iv: Data
    let ciphertext: Data
    let authTag: Data
    
    struct JWEProtectedHeader: Jsonable, FromSnake {
        let alg: JWEAlgorithm     // "ECDH-ES"
        let enc: JWEEncryption    // "A256GCM"
        let epk: JWK
        let kid: String?
        let apu: String?          // base64url, Concat KDF PartyUInfo
        let apv: String?          // base64url, Concat KDF PartyVInfo
    }
    
    enum JWEAlgorithm: String, Codable {
        case ecdhES       = "ECDH-ES"
        case ecdhESA128KW = "ECDH-ES+A128KW"
        case ecdhESA192KW = "ECDH-ES+A192KW"
        case ecdhESA256KW = "ECDH-ES+A256KW"

        var isKeyWrapping: Bool { self != .ecdhES }
        var kdfAlgorithmID: String? { isKeyWrapping ? rawValue : nil }
    }
    
    enum JWEEncryption: String, Codable {
        case a128GCM = "A128GCM"
        case a256GCM = "A256GCM"
        var cekBitLength: Int { self == .a256GCM ? 256 : 128 }
    }
    
    init(data: Data) throws
    {
        guard let compact = String(data: data, encoding: .utf8)
        else
        {
            throw OID4VCManagerError.invalidJWE.getError()
        }
        
        try self.init(compact: compact)
    }
    
    init(compact: String) throws
    {
        let parts = compact.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 5
        else {
            throw OID4VCManagerError.invalidJWE.getError()
        }
        
        self.rawProtectedHeader = String(parts[0])
        
        self.protectedHeader = try JWEProtectedHeader.init(from: rawProtectedHeader.base64URLDecoded!)
        self.encryptedKey = String(parts[1]).base64URLDecoded!
        self.iv           = String(parts[2]).base64URLDecoded!
        self.ciphertext   = String(parts[3]).base64URLDecoded!
        self.authTag      = String(parts[4]).base64URLDecoded!
    }

}

enum JWEError: Error {
    case unsupportedAlgorithm(String)
    case unsupportedKeyType
    case invalidRecipientKey
    case encryptionFailed
}

extension JWE
{
    var isKeyWrapping: Bool { !encryptedKey.isEmpty }
}

extension JWE
{
    func decrypt(using privateKey: P256.KeyAgreement.PrivateKey) throws -> Data
    {
        guard protectedHeader.alg == .ecdhES else
        {
            throw OID4VCManagerError.unsupportedAlgorithmJWE.getError()
//protectedHeader.alg.rawValue
        }

        guard encryptedKey.isEmpty else
        {
            throw OID4VCManagerError.unsupportedAlgorithmJWE.getError()
//("\(protectedHeader.alg.rawValue): unexpected encrypted key")
        }

        guard protectedHeader.epk.kty == .ec,
              protectedHeader.epk.crv == .p256
        else
        {
            throw OID4VCManagerError.unsupportedJWEKey.getError()
        }

        let publicKey: P256.KeyAgreement.PublicKey = try .init(
            xBase64URL: protectedHeader.epk.x,
            yBase64URL: protectedHeader.epk.y
        )
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(
            with: publicKey
        )
        
        let contentEncryptionKey = try Self.deriveContentEncryptionKey(
            sharedSecret: sharedSecret,
            header: protectedHeader
        )
        
        let sealedBox: AES.GCM.SealedBox
        
        do {
            sealedBox = try AES.GCM.SealedBox(
                nonce: AES.GCM.Nonce(data: iv),
                ciphertext: ciphertext,
                tag: authTag
            )
        } catch {
            throw OID4VCManagerError.invalidSealedBox.getError()
        }
        
        
        do {
            return try AES.GCM.open(
                sealedBox,
                using: contentEncryptionKey,
                authenticating: Data(rawProtectedHeader.utf8)
            )
        } catch {
            throw OID4VCManagerError.authenticationFailed.getError()
        }

    }

    /// Encrypts `plaintext` for `recipient` (ECDH-ES Direct + AES-GCM) and returns a compact JWE.
    ///
    /// Mirror of `decrypt`: an ephemeral P-256 key is generated, the shared secret is run through
    /// the Concat KDF (NIST SP 800-56A, SHA-256) to derive the content-encryption key, and the
    /// base64url protected header is used as the AES-GCM additional authenticated data. Only the
    /// algorithm set `decrypt` supports is produced here (`ECDH-ES`, `A128GCM`/`A256GCM`); key
    /// wrapping is not implemented, so the encrypted-key segment is always empty.
    /// The recipient JWK's `kid` (if any) is echoed into the top-level protected header so the
    /// recipient can select which of its keys to run the ECDH agreement with (RFC 7516 §4.1.6);
    /// it is omitted when the JWK has no `kid`. This is the recipient's static-key id, distinct
    /// from the ephemeral `epk`, which never carries a `kid`.
    /// - Parameters:
    ///   - plaintext: The bytes to encrypt.
    ///   - recipient: The recipient's public key as a JWK (must be `EC` / `P-256`).
    ///   - enc: The content encryption algorithm. Defaults to `A256GCM`.
    ///   - apu: Optional base64url PartyUInfo for the Concat KDF.
    ///   - apv: Optional base64url PartyVInfo for the Concat KDF.
    /// - Returns: The compact JWE string (`header..iv.ciphertext.tag`).
    static func encrypt(
        plaintext: Data,
        to recipient: JWK,
        enc: JWEEncryption = .a256GCM,
        apu: String? = nil,
        apv: String? = nil
    ) throws -> String
    {
        guard recipient.kty == .ec, recipient.crv == .p256
        else
        {
            throw OID4VCManagerError.unsupportedJWEKey.getError()
        }

        let recipientPublicKey: P256.KeyAgreement.PublicKey
        do {
            recipientPublicKey = try .init(
                xBase64URL: recipient.x,
                yBase64URL: recipient.y
            )
        } catch {
            throw SignableError.invalidPublicKey.getError()
        }

        let ephemeralPrivateKey = P256.KeyAgreement.PrivateKey()
        let epk = ephemeralPrivateKey.publicKey.getPublicKeyJwk()

        let header = JWEProtectedHeader(
            alg: .ecdhES,
            enc: enc,
            epk: epk,
            kid: recipient.kid,
            apu: apu,
            apv: apv
        )

        let rawProtectedHeader = try header.toJsonData().base64URLEncoded

        let sharedSecret = try ephemeralPrivateKey.sharedSecretFromKeyAgreement(
            with: recipientPublicKey
        )

        let contentEncryptionKey = try deriveContentEncryptionKey(
            sharedSecret: sharedSecret,
            header: header
        )

        let sealedBox: AES.GCM.SealedBox
        do {
            sealedBox = try AES.GCM.seal(
                plaintext,
                using: contentEncryptionKey,
                authenticating: Data(rawProtectedHeader.utf8)
            )
        } catch {
            throw OID4VCManagerError.failedToEncrypt.getError()
        }

        // ECDH-ES Direct: no wrapped key, so the encrypted-key segment is empty.
        return [
            rawProtectedHeader,
            "",
            sealedBox.nonce.withUnsafeBytes { Data($0) }.base64URLEncoded,
            sealedBox.ciphertext.base64URLEncoded,
            sealedBox.tag.base64URLEncoded
        ].joined(separator: ".")
    }
}

private extension JWE {
    static func deriveContentEncryptionKey(
        sharedSecret: SharedSecret,
        header: JWEProtectedHeader
    ) throws -> SymmetricKey {
        let sharedSecretData = sharedSecret.withUnsafeBytes {
            Data($0)
        }

        let algorithmIDValue = header.alg.kdfAlgorithmID ?? header.enc.rawValue
        let algorithmID = try lengthPrefixedData(
            Data(algorithmIDValue.utf8)
        )

        let partyUInfo = try lengthPrefixedData(
            decodeOptionalBase64URL(header.apu)
        )

        let partyVInfo = try lengthPrefixedData(
            decodeOptionalBase64URL(header.apv)
        )

        let keyDataLengthBits = header.enc.cekBitLength
        let keyDataLengthBytes = keyDataLengthBits / 8

        var suppPubInfo = Data()
        suppPubInfo.appendUInt32BigEndian(UInt32(keyDataLengthBits))

        let suppPrivInfo = Data()

        var otherInfo = Data()
        otherInfo.append(algorithmID)
        otherInfo.append(partyUInfo)
        otherInfo.append(partyVInfo)
        otherInfo.append(suppPubInfo)
        otherInfo.append(suppPrivInfo)

        // NIST SP 800-56A Concat KDF (single-step, SHA-256).
        let hashLengthBytes = 32
        let reps = (keyDataLengthBytes + hashLengthBytes - 1) / hashLengthBytes

        var keyMaterial = Data()
        for counter in 1...reps {
            var digestInput = Data()
            digestInput.appendUInt32BigEndian(UInt32(counter))
            digestInput.append(sharedSecretData)
            digestInput.append(otherInfo)
            keyMaterial.append(Data(SHA256.hash(data: digestInput)))
        }

        let derivedKey = keyMaterial.prefix(keyDataLengthBytes)

        guard derivedKey.count == keyDataLengthBytes else {
            throw OID4VCManagerError.keyDerivationFailed.getError()
        }

        return SymmetricKey(data: derivedKey)
    }

    static func decodeOptionalBase64URL(
        _ value: String?
    ) throws -> Data {
        guard let value else {
            return Data()
        }

        
        guard let data = value.base64URLDecoded
        else
        {
            throw MultibaseUtilsError.failToDecode.getError()
        }

        return data
    }

    static func lengthPrefixedData(
        _ data: Data
    ) throws -> Data {
        guard data.count <= Int(UInt32.max) else {
            throw OID4VCManagerError.invalidKDFInput.getError()
        }

        var result = Data()
        result.appendUInt32BigEndian(UInt32(data.count))
        result.append(data)

        return result
    }
}


private extension Data {
    

    mutating func appendUInt32BigEndian(_ value: UInt32) {
        var bigEndianValue = value.bigEndian

        Swift.withUnsafeBytes(of: &bigEndianValue) {
            append(contentsOf: $0)
        }
    }
}
