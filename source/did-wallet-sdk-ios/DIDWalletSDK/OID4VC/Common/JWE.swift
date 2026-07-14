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
    let protectedHeader: JWEProtectedHeader   // 디코딩된 헤더
    let rawProtectedHeader: String            // ← base64url 원본 문자열 (AAD로 그대로 사용)
    let encryptedKey: Data                    // KW면 채워짐, Direct(ECDH-ES)면 empty
    let iv: Data                              // A256GCM 논스 (12바이트)
    let ciphertext: Data
    let authTag: Data                         // GCM 인증 태그 (16바이트)
    
    struct JWEProtectedHeader: Jsonable, FromSnake {
        let alg: JWEAlgorithm     // "ECDH-ES"
        let enc: JWEEncryption    // "A256GCM"
        let epk: JWK              // 발신자(issuer) 임시 공개키
        let kid: String?          // 지갑 임시키 선택 힌트
        let apu: String?          // base64url, Concat KDF PartyUInfo
        let apv: String?          // base64url, Concat KDF PartyVInfo
    }
    
    enum JWEAlgorithm: String, Codable {
        case ecdhES       = "ECDH-ES"
        case ecdhESA128KW = "ECDH-ES+A128KW"
        case ecdhESA192KW = "ECDH-ES+A192KW"
        case ecdhESA256KW = "ECDH-ES+A256KW"

        var isKeyWrapping: Bool { self != .ecdhES }
        /// Concat KDF의 AlgorithmID에 들어가는 값: KW는 alg 자신, Direct는 enc 값
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
            fatalError("Invalid JWE format")
        }
        
        try self.init(compact: compact)
    }
    
    init(compact: String) throws
    {
        // omittingEmptySubsequences: false → Direct 모드의 빈 encryptedKey 파트 보존
        let parts = compact.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 5 else { fatalError("Invalid JWE format") }
        
        self.rawProtectedHeader = String(parts[0])
        
        self.protectedHeader = try JWEProtectedHeader.init(from: rawProtectedHeader.base64URLDecoded!)
        self.encryptedKey = String(parts[1]).base64URLDecoded!  // 빈 파트면 empty Data
        self.iv           = String(parts[2]).base64URLDecoded!
        self.ciphertext   = String(parts[3]).base64URLDecoded!
        self.authTag      = String(parts[4]).base64URLDecoded!
    }
    
}

extension JWE
{
    var isKeyWrapping: Bool { !encryptedKey.isEmpty }
}

extension JWE
{
    func decrypt(using privateKey: P256.KeyAgreement.PrivateKey) throws -> Data
    {
        guard protectedHeader.epk.kty == .ec,
              protectedHeader.epk.crv == .p256
        else
        {
            //TODO: Error
            fatalError("Unsupport Algorithm")
        }
        
        let publicKey: P256.KeyAgreement.PublicKey = try .init(
            xBase64URL: protectedHeader.epk.x,
            yBase64URL: protectedHeader.epk.y
        )
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(
            with: publicKey
        )
        
        let contentEncryptionKey = try deriveContentEncryptionKey(
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
            //TODO: Error
            fatalError("JWEError.invalidSealedBox")
        }
        
        
        do {
            return try AES.GCM.open(
                sealedBox,
                using: contentEncryptionKey,
                authenticating: Data(rawProtectedHeader.utf8)
            )
        } catch {
            //TODO: Error
            fatalError("JWEError.authenticationFailed")
        }
        
    }
    
    
}

private extension JWE {
    func deriveContentEncryptionKey(
        sharedSecret: SharedSecret,
        header: JWEProtectedHeader
    ) throws -> SymmetricKey {
        let sharedSecretData = sharedSecret.withUnsafeBytes {
            Data($0)
        }

        let algorithmID = try lengthPrefixedData(
            Data(header.enc.rawValue.utf8)
        )

        let partyUInfo = try lengthPrefixedData(
            decodeOptionalBase64URL(header.apu)
        )

        let partyVInfo = try lengthPrefixedData(
            decodeOptionalBase64URL(header.apv)
        )

        // A256GCM 키 길이: 256 bits
        let keyDataLength = UInt32(256)

        var suppPubInfo = Data()
        suppPubInfo.appendUInt32BigEndian(keyDataLength)

        let suppPrivInfo = Data()

        var otherInfo = Data()
        otherInfo.append(algorithmID)
        otherInfo.append(partyUInfo)
        otherInfo.append(partyVInfo)
        otherInfo.append(suppPubInfo)
        otherInfo.append(suppPrivInfo)

        // SHA-256 출력이 256비트이므로 A256GCM에서는 한 번만 계산하면 된다.
        var digestInput = Data()
        digestInput.appendUInt32BigEndian(1)
        digestInput.append(sharedSecretData)
        digestInput.append(otherInfo)

        let digest = SHA256.hash(data: digestInput)
        let derivedKey = Data(digest)

        guard derivedKey.count == 32 else {
            //TODO: Error
            fatalError("JWEError.keyDerivationFailed")
        }

        return SymmetricKey(data: derivedKey)
    }

    func decodeOptionalBase64URL(
        _ value: String?
    ) throws -> Data {
        guard let value else {
            return Data()
        }

        
        guard let data = value.base64URLDecoded
        else
        {
            //TODO: Error
            fatalError("JWEError.invalidBase64URL")
        }

        return data
    }

    func lengthPrefixedData(
        _ data: Data
    ) throws -> Data {
        guard data.count <= Int(UInt32.max) else {
            //TODO: Error
            fatalError("JWEError.invalidKDFInput")
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
