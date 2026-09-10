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
import CryptoKit
import LocalAuthentication
@testable import DIDWalletSDK

final class KeyManagerTests: XCTestCase {

    var keyManager : KeyManager!
    
    let freeID = "free"
    let pinID  = "pin"
    let bioID  = "bio"
    
    let pinData = "password".data(using: .utf8)!
    let newPinData = "newPassword".data(using: .utf8)!
    
    override func setUpWithError() throws
    {
        keyManager = try .init(fileName: "myWallet")
        if keyManager.isAnyKeysSaved
        {
            try keyManager.deleteAllKeys()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIsKeySaved() throws
    {
        XCTAssertFalse(try keyManager.isKeySaved(id: pinID),
                       "This should be false")
        
        try testGenerateKey()
        
        XCTAssertTrue(try keyManager.isKeySaved(id: pinID),
                      "This should be true")
    }
    
    func testGenerateKey() throws
    {
        //Free
        let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1,
                                                 id: freeID,
                                                 methodType: .none)
        try keyManager.generateKey(keyGenRequest: freeKeyRequest)
        
        //Pin
        let pinKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1,
                                                id: pinID,
                                                methodType: .pin(value: pinData))
        try keyManager.generateKey(keyGenRequest: pinKeyRequest)
        
        //Bio
        let bioKeyRequest = SecureKeyGenRequest(id: bioID,
                                                accessMethod: .none,
                                                prompt: "prompt")
        try keyManager.generateKey(keyGenRequest: bioKeyRequest)
    }

    func testGetKeyInfosByKeyType() throws
    {
        if !keyManager.isAnyKeysSaved
        {
            try testGenerateKey()
        }
        
        let keyInfos = try keyManager.getKeyInfos(keyType: [])
        for keyInfo in keyInfos 
        {
            print("keyInfo - \(keyInfo)")
        }
    }
    
    func testGetKeyInfosByIds() throws
    {
        if !keyManager.isAnyKeysSaved
        {
            try testGenerateKey()
        }
        
        let keyInfos = try keyManager.getKeyInfos(ids: [pinID, bioID])
        for keyInfo in keyInfos
        {
            print("keyInfo - \(keyInfo)")
        }
    }
    
    func testChangePin() throws
    {
        try testGenerateKey()
        
        try keyManager.changePin(id: pinID,
                                 oldPin: pinData,
                                 newPin: newPinData)
    }
    
    func testDeleteKeys() throws
    {
        try testGenerateKey()
        
        try keyManager.deleteKeys(ids: [pinID, bioID])
    }
    
    func testSign() throws
    {
        try testGenerateKey()
        
        let plainData = "Test".data(using: .utf8)!
        let digest = DigestUtils.getDigest(source: plainData, 
                                           digestEnum: .sha256)
        
        
        //Not Pin key
        let signature1 = try keyManager.sign(id: freeID, digest: digest)
        let mSignature1 = MultibaseUtils.encode(type: .base58BTC, data: signature1)
        print("mSignature1 - \(mSignature1)")
        
        //Pin key
        let signature2 = try keyManager.sign(id: pinID, pin: pinData, digest: digest)
        let mSignature2 = MultibaseUtils.encode(type: .base58BTC, data: signature2)
        print("mSignature2 - \(mSignature2)")
        
        try testGetKeyInfosByKeyType()
    }
    
    /// A software key does ECDH, and the secret is the one the peer arrives at.
    ///
    /// Checked against the other side of the exchange rather than a recorded value: agreeing with
    /// the peer is the whole property, and a wrong-but-stable secret would satisfy a fixture.
    func testKeyAgreement() throws
    {
        try testGenerateKey()

        XCTAssertTrue(try keyManager.canKeyAgree(id: freeID))
        XCTAssertTrue(try keyManager.canKeyAgree(id: pinID))

        let peer = P256.KeyAgreement.PrivateKey()
        let peerPublicKey = peer.publicKey.x963Representation

        for (id, pin) in [(freeID, nil as Data?), (pinID, pinData)]
        {
            let secret = try keyManager.keyAgreement(id: id,
                                                     pin: pin,
                                                     publicKey: peerPublicKey)

            let walletPublicKey = try MultibaseUtils.decode(
                encoded: try keyManager.getKeyInfos(ids: [id])[0].publicKey)
            let expected = try peer.sharedSecretFromKeyAgreement(
                with: try P256.KeyAgreement.PublicKey(
                    compactRepresentation: walletPublicKey[1...]))

            XCTAssertEqual(secret, expected.withUnsafeBytes { Data($0) })
            XCTAssertEqual(secret.count, 32)
        }
    }

    /// The Secure Enclave path, run for real: `SecKeyCopyKeyExchangeResult` against a peer that
    /// computes the same secret from the other side.
    ///
    /// The private half never leaves the enclave, so the only way to know the secret is right is
    /// that the peer -- holding an ordinary CryptoKit key -- arrives at the same bytes.
    func testKeyAgreementWithASecureEnclaveKey() throws
    {
        try testGenerateKey()

        XCTAssertTrue(try keyManager.canKeyAgree(id: bioID))

        let peer = P256.KeyAgreement.PrivateKey()
        let secret = try keyManager.keyAgreement(id: bioID,
                                                publicKey: peer.publicKey.x963Representation)

        let enclavePublicKey = try MultibaseUtils.decode(
            encoded: try keyManager.getKeyInfos(ids: [bioID])[0].publicKey)
        let expected = try peer.sharedSecretFromKeyAgreement(
            with: try P256.KeyAgreement.PublicKey(
                compactRepresentation: enclavePublicKey[1...]))

        XCTAssertEqual(secret, expected.withUnsafeBytes { Data($0) })
        XCTAssertEqual(secret.count, 32)
    }

    /// One authentication context, both key uses.
    ///
    /// The prompt itself cannot be exercised here -- this suite's enclave key carries no biometry
    /// flag, and a real prompt needs a device. What is checked is the wiring: the context reaches
    /// the keychain query and both operations still produce correct output through it. A context
    /// the query rejected would fail the lookup, not silently ignore it.
    func testSecureEnclaveOperationsShareOneAuthenticationContext() throws
    {
        try testGenerateKey()

        let context = LAContext()
        let digest = DigestUtils.getDigest(source: "Test".data(using: .utf8)!,
                                           digestEnum: .sha256)

        let signature = try keyManager.sign(id: bioID, digest: digest, context: context)
        let peer = P256.KeyAgreement.PrivateKey()
        let secret = try keyManager.keyAgreement(id: bioID,
                                                publicKey: peer.publicKey.x963Representation,
                                                context: context)

        let publicKey = try MultibaseUtils.decode(
            encoded: try keyManager.getKeyInfos(ids: [bioID])[0].publicKey)
        XCTAssertTrue(try keyManager.verify(algorithmType: .secp256r1,
                                            publicKey: publicKey,
                                            digest: digest,
                                            signature: signature))

        let expected = try peer.sharedSecretFromKeyAgreement(
            with: try P256.KeyAgreement.PublicKey(compactRepresentation: publicKey[1...]))
        XCTAssertEqual(secret, expected.withUnsafeBytes { Data($0) })
    }

    /// The PIN gates key agreement exactly as it gates signing: without it there is no private key
    /// to agree with, and the caller hears that rather than getting a wrong secret.
    func testKeyAgreementNeedsThePinOfAPinKey() throws
    {
        try testGenerateKey()

        let peerPublicKey = P256.KeyAgreement.PrivateKey().publicKey.x963Representation

        XCTAssertThrowsError(try keyManager.keyAgreement(id: pinID, publicKey: peerPublicKey))
        XCTAssertThrowsError(try keyManager.keyAgreement(id: pinID,
                                                        pin: newPinData,
                                                        publicKey: peerPublicKey))
    }

    /// A peer point that is not a P-256 point is refused, not fed to the curve.
    func testKeyAgreementRejectsAMalformedPeerKey() throws
    {
        try testGenerateKey()

        XCTAssertThrowsError(try keyManager.keyAgreement(id: freeID,
                                                         publicKey: Data(repeating: 0x04, count: 65)))
    }

    func testVerify() throws
    {
        let plainData = "Test".data(using: .utf8)!
        let digest = DigestUtils.getDigest(source: plainData,
                                           digestEnum: .sha256)
        
        let publicKey1 = try MultibaseUtils.decode(encoded: "zeZDsJJfZxggomwKnwPEdpMKtGvxQANRbJjXMdHsG2SXx")
        let signature1 = try MultibaseUtils.decode(encoded: "z3uF8E6tiEtHqYEFTVE2sL2L1dYDFxgnMyhs9jzu3ZvYxDhPmFRpyM85EAtGmau8ajfEQxqxKpHhVSUSYyRYn2XEV1")
        
        let result1 = try keyManager.verify(algorithmType: .secp256r1,
                                           publicKey: publicKey1,
                                           digest: digest,
                                           signature: signature1)
        
        print("result1 - \(result1)")
        
        let publicKey2 = try MultibaseUtils.decode(encoded: "z271e4Qnaqb5SeF8a2BAftEYuW5bnVnco7T2nMpYeLC9sa")
        let signature2 = try MultibaseUtils.decode(encoded: "z3u7kkdobu3wmGUDz3iH6p8a96JXFD52EZ3vq6ocWPA8htGWWnEcVqsfdU3m6hnjSwX9bU1Vnvw7Rxv1ne4B8Xvod3")
        
        let result2 = try keyManager.verify(algorithmType: .secp256r1,
                                           publicKey: publicKey2,
                                           digest: digest,
                                           signature: signature2)
        print("result2 - \(result2)")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
