/*
 * Copyright 2024 OmniOne.
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
@testable import DIDUtilitySDK

final class CryptoUtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGenerateNonce() throws {
        let size: UInt = 32
        let nonce = try CryptoUtils.generateNonce(size: size)
        XCTAssertTrue(nonce.count == size)
    }

    func testGenerateECKeyPair() throws {
        let keyPair = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)
        XCTAssertTrue(keyPair.ecType == .secp256r1)
        XCTAssertTrue(keyPair.privateKey.count == 32)
        XCTAssertTrue(keyPair.publicKey.count == 33)
        
        guard let firstByte = keyPair.publicKey.first else {
            XCTAssert(false, "First byte of public key is missing.")
            return
        }
        
        XCTAssertTrue(firstByte == 0x02 || firstByte == 0x03)
    }

    func testGenerateSharedSecret() throws {
        let keyPair1 = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)
        let keyPair2 = try CryptoUtils.generateECKeyPair(ecType: .secp256r1)
        
        let sharedSecret1 = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: keyPair1.privateKey, publicKey: keyPair2.publicKey)

        XCTAssertTrue(sharedSecret1.count == 32)

        let sharedSecret2 = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: keyPair2.privateKey, publicKey: keyPair1.publicKey)
        
        XCTAssertTrue(sharedSecret1 == sharedSecret2)
        
        let privateKey = "3beb3727fb4d987434ef92ab4dfea0694173ff2cbd6977c2f120bf03e5c47656".base16Decoded!
        let publicKey = "0387fa054d2e6254b4180c408201ae39424ec08e943320d24e8bcf7c7057394ac6".base16Decoded!
        let expectedSharedSecret = "c8b229089c25985ec2ac94edd3c84c3681d44802bb8b3d418787767c2b71ca4a".base16Decoded!
        
        let testKeyPair = ECKeyPair(ecType: .secp256r1, privateKey: privateKey, publicKey: publicKey)
        let testSharedSecret = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: testKeyPair.privateKey, publicKey: testKeyPair.publicKey)
        
        XCTAssertTrue(testSharedSecret == expectedSharedSecret)
    }

    func testPbkdf2() throws {
        let password = "822829cc4cb3c1390aa76acfbea3ff45".base16Decoded!
        let salt = "8bcb7d25aeeada21498e38eee46b5fd2".base16Decoded!
        let iterations: UInt32 = 3000
        let derivedKeyLength: UInt = 48
        
        let expectedResult = "456daee1980b4e9dc70c945c3868d4074f7b1720b08bfe5ad8a60d443b76b29e7d1aa1b8e97d55654173cfa19e65ea42".base16Decoded!
        
        let derivedKey = try CryptoUtils.pbkdf2(password: password, salt: salt, iterations: iterations, derivedKeyLength: derivedKeyLength)
        
        XCTAssertTrue(derivedKey.count == derivedKeyLength)
        XCTAssertTrue(derivedKey == expectedResult)
    }
    
    func testEncrypt() throws {
        let infoWithCBC = CipherInfo(cipherType: .aes256CBC, padding: .pkcs5)
        let infoWithECB = CipherInfo(cipherType: .aes256ECB, padding: .pkcs5)

        let key = "822829cc4cb3c1390aa76acfbea3ff458bcb7d25aeeada21498e38eee46b5fd2".base16Decoded!
        let iv = "8bcb7d25aeeada21498e38eee46b5fd2".base16Decoded!
        
        let plain = "68656c6c6f20776f726c64".base16Decoded!

        let expectedCipherWithCBC = "57eadc6a926ed3aa13b3a84e9e95daa4".base16Decoded!
        let expectedCipherWithECB = "bade9692a89ff2ec256f4693dc00fe05".base16Decoded!
        
        let encryptedWithCBC = try CryptoUtils.encrypt(plain: plain, info: infoWithCBC, key: key, iv: iv)
        
        XCTAssertTrue(encryptedWithCBC == expectedCipherWithCBC)
        
        let encryptedWithECB = try CryptoUtils.encrypt(plain: plain, info: infoWithECB, key: key, iv: Data())
        
        print("encryptedWithECB: \(encryptedWithECB.base16Encoded)")
        XCTAssertTrue(encryptedWithECB == expectedCipherWithECB)
    }

    func testDecrypt() throws {
        let infoWithCBC = CipherInfo(cipherType: .aes256CBC, padding: .pkcs5)
        let infoWithECB = CipherInfo(cipherType: .aes256ECB, padding: .pkcs5)

        let key = "822829cc4cb3c1390aa76acfbea3ff458bcb7d25aeeada21498e38eee46b5fd2".base16Decoded!
        let iv = "8bcb7d25aeeada21498e38eee46b5fd2".base16Decoded!
        
        let cipherWithCBC = "57eadc6a926ed3aa13b3a84e9e95daa4".base16Decoded!
        let cipherWithECB = "bade9692a89ff2ec256f4693dc00fe05".base16Decoded!
        
        let expectedPlain = "68656c6c6f20776f726c64".base16Decoded!
        
        let decryptedWithCBC = try CryptoUtils.decrypt(cipher: cipherWithCBC, info: infoWithCBC, key: key, iv: iv)
        
        XCTAssertTrue(decryptedWithCBC == expectedPlain)
        
        let decryptedWithECB = try CryptoUtils.decrypt(cipher: cipherWithECB, info: infoWithECB, key: key, iv: Data())
        
        XCTAssertTrue(decryptedWithECB == expectedPlain)
    }
    
    func testGenerateSharedSecretAndEncrypt() throws {
        let privateKey = "3beb3727fb4d987434ef92ab4dfea0694173ff2cbd6977c2f120bf03e5c47656".base16Decoded!
        let publicKey = "0387fa054d2e6254b4180c408201ae39424ec08e943320d24e8bcf7c7057394ac6".base16Decoded!
        
        let sharedSecret = try CryptoUtils.generateSharedSecret(ecType: .secp256r1, privateKey: privateKey, publicKey: publicKey)
        
        let salt = "8bcb7d25aeeada21498e38eee46b5fd2".base16Decoded!
        let iterations: UInt32 = 3000
        let derivedKeyLength: UInt = 48
        
        let expectedDerivedKey = "fbee7e588106a9f35b174608f7111ea266ebde598cabf320f18738e7cbcf168b0d48e6b8d50410a104a72491fb9aa4fb".base16Decoded!
        
        let derivedKey = try CryptoUtils.pbkdf2(password: sharedSecret, salt: salt, iterations: iterations, derivedKeyLength: derivedKeyLength)
        
        XCTAssertTrue(derivedKey.count == derivedKeyLength)
        XCTAssertTrue(derivedKey == expectedDerivedKey)
        
        let key = derivedKey[0..<32]
        let iv = derivedKey[32..<derivedKeyLength]
        
        let plain = "68656c6c6f20776f726c64".base16Decoded!
        let cipher = "318d4c307865887ec14724caa830617a".base16Decoded!
        
        let info = CipherInfo(cipherType: .aes256CBC, padding: .pkcs5)
        
        let encrypted = try CryptoUtils.encrypt(plain: plain, info: info, key: key, iv: iv)
        XCTAssertTrue(encrypted == cipher)
        
        let decrypted = try CryptoUtils.decrypt(cipher: encrypted, info: info, key: key, iv: iv)
        XCTAssertTrue(decrypted == plain)
    }
    
}
