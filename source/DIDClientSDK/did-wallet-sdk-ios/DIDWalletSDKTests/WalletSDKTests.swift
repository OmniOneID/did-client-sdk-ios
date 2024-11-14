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
@testable import DIDWalletSDK
import DIDDataModelSDK
import DIDUtilitySDK
import DIDCommunicationSDK
import DIDCoreSDK

final class DIDWalletSDKTests: XCTestCase {
        
    var walletServiceMock: WalletServiceImpl!
    var walletTokenMock: WalletTokenImpl!
    var lockManagerMock: WalletLockManagerImpl!
    var walletCoreMock: WalletCoreMock!
    let walletAPI = WalletAPI.shared
    
    override func setUp() {
    
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        WalletLogger.shared.setLogLevel(.debug)
        WalletLogger.shared.setEnable(true)
        
        self.walletCoreMock = WalletCoreMock()
        self.walletServiceMock = WalletServiceMock(walletCoreMock)
        self.walletTokenMock = WalletTokenMock()
        self.lockManagerMock = WalletLockManagerMock()
        
        for child in Mirror(reflecting: walletAPI).children {
            WalletLogger.shared.debug("WalletAPI child: \(child)")
            if child.label == "walletService" {
                walletAPI.walletService = self.walletServiceMock
            } else if child.label == "walletToken" {
                walletAPI.walletToken = self.walletTokenMock
            } else if child.label == "lockMnr" {
                walletAPI.lockMnr = self.lockManagerMock
            } else if child.label == "walletCore" {
                walletAPI.walletCore = self.walletCoreMock
            }
        }
        
        try self.testDeleteWallet()
        try self.testCreateWallet()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testDeleteWallet() throws {
        // Mock
        Task { @MainActor in
            do {
                try self.walletAPI.deleteWallet()
            } catch {
                print("testDeleteWallet error: \(error)")
            }
        }
    }
    
    // 월랫 생성
    func testCreateWallet() throws {
        // Mock
        Task { @MainActor in
            do {
                let isCreateWallet = try await self.walletAPI.createWallet(tasURL: "test", walletURL: "test")
                assert(isCreateWallet)
            } catch {
                print("testCreateWallet error: \(error)")
            }
        }
    }
    
    
    
    // 개인화 (unlock/ unlock)
    func testBindUserWithLockUnlock() throws {
        
        Task { @MainActor in
            do {
                let walletTokenDataJson = """
            {"nonce":"mHaq6qqiUKLt8N6raGc+/5g","proof":{"created":"2024-08-23T11:40:03.566877Z","proofPurpose":"assertionMethod","proofValue":"mH6qvGRLx8qpMPhQwJMeEQsz0eGYhZQI1y9yu1xl4b+qIQM2tfFueWHpuffAvdioqSrR0K4Qb0AgbzcdtQO4ds7A","type":"Secp256r1Signature2018","verificationMethod":"did:omn:cas?versionId=1#assert"},"provider":{"certVcRef":"http://192.168.3.130:8094/cas/api/v1/certificate-vc","did":"did:omn:cas"},"seed":{"nonce":"F6438ED0B74B348E3635C89DA164E8FFE","pkgName":"org.omnione.did.ca","purpose":3,"userId":"7156af3d","validUntil":"2050-08-23T12:10:02Z"},"sha256_pii":"zCWYkiLKjXUHu5xCRcJoJ9nfiyKzhiYW3YiWwdDwfh2vx"}
            """
                let walletTokenData = try WalletTokenData(from: walletTokenDataJson)
                
                let resultNonce = try await walletAPI.createNonceForWalletToken(walletTokenData: walletTokenData, APIGatewayURL: "NONE")
                
                let digest = DigestUtils.getDigest(source: (walletTokenDataJson + resultNonce).data(using: String.Encoding.utf8)!, digestEnum: DigestEnum.sha256)
                // Hex
                let hWalletToken = String(MultibaseUtils.encode(type: MultibaseType.base16, data: digest).dropFirst())
                
                let result = try walletAPI.bindUser(hWalletToken: hWalletToken)
                assert(result, "bind user fail")
                
                let setLock = try walletAPI.registerLock(hWalletToken: hWalletToken, passcode: "123456", isLock: true)
                assert(setLock, "register Lock fail")
                
                let cek = try walletAPI.authenticateLock(passcode: "123456")
                
                XCTAssertNil(cek)
                
            } catch let error as WalletAPIError {
                print("testBindUser error: \(error)")
            }
        }
    }
    
    // 개인화
    func testBindUser() throws {
        Task { @MainActor in
            do {
                let walletTokenDataJson = """
            {"nonce":"mHaq6qqiUKLt8N6raGc+/5g","proof":{"created":"2024-08-23T11:40:03.566877Z","proofPurpose":"assertionMethod","proofValue":"mH6qvGRLx8qpMPhQwJMeEQsz0eGYhZQI1y9yu1xl4b+qIQM2tfFueWHpuffAvdioqSrR0K4Qb0AgbzcdtQO4ds7A","type":"Secp256r1Signature2018","verificationMethod":"did:omn:cas?versionId=1#assert"},"provider":{"certVcRef":"http://192.168.3.130:8094/cas/api/v1/certificate-vc","did":"did:omn:cas"},"seed":{"nonce":"F6438ED0B74B348E3635C89DA164E8FFE","pkgName":"org.omnione.did.ca","purpose":1,"userId":"7156af3d","validUntil":"2050-08-23T12:10:02Z"},"sha256_pii":"zCWYkiLKjXUHu5xCRcJoJ9nfiyKzhiYW3YiWwdDwfh2vx"}
            """
                let walletTokenData = try WalletTokenData(from: walletTokenDataJson)
                
                let resultNonce = try await walletAPI.createNonceForWalletToken(walletTokenData: walletTokenData, APIGatewayURL: "NONE")
                
                let digest = DigestUtils.getDigest(source: (walletTokenDataJson + resultNonce).data(using: String.Encoding.utf8)!, digestEnum: DigestEnum.sha256)
                // Hex
                let hWalletToken = String(MultibaseUtils.encode(type: MultibaseType.base16, data: digest).dropFirst())
                
                let result = try walletAPI.bindUser(hWalletToken: hWalletToken)
                
                assert(result, "bind user fail")
            } catch let error as WalletAPIError {
                print("testBindUser error: \(error)")
            }
        }
    }
    
    // 개인화 (lock/ unlock)
    func testUnBindUser() throws {
        
    }
    
    // 유저 등록
    func testRegisterUser() async throws {
//        print("################### testRegisterUser")
//        do {
//            let walletTokenDataJson = """
//        {"nonce":"mHaq6qqiUKLt8N6raGc+/5g","proof":{"created":"2024-08-23T11:40:03.566877Z","proofPurpose":"assertionMethod","proofValue":"mH6qvGRLx8qpMPhQwJMeEQsz0eGYhZQI1y9yu1xl4b+qIQM2tfFueWHpuffAvdioqSrR0K4Qb0AgbzcdtQO4ds7A","type":"Secp256r1Signature2018","verificationMethod":"did:omn:cas?versionId=1#assert"},"provider":{"certVcRef":"http://192.168.3.130:8094/cas/api/v1/certificate-vc","did":"did:omn:cas"},"seed":{"nonce":"F6438ED0B74B348E3635C89DA164E8FFE","pkgName":"org.omnione.did.ca","purpose":5,"userId":"7156af3d","validUntil":"2050-08-23T12:10:02Z"},"sha256_pii":"zCWYkiLKjXUHu5xCRcJoJ9nfiyKzhiYW3YiWwdDwfh2vx"}
//        """
//            let walletTokenData = try WalletTokenData(from: walletTokenDataJson)
//            
//            let resultNonce = try await walletAPI.createNonceForWalletToken(walletTokenData: walletTokenData, APIGatewayURL: "NONE")
//            
//            let digest = DigestUtils.getDigest(source: (walletTokenDataJson + resultNonce).data(using: String.Encoding.utf8)!, digestEnum: DigestEnum.sha256)
//            // Hex
//            let hWalletToken = String(MultibaseUtils.encode(type: MultibaseType.base16, data: digest).dropFirst())
//            
//            try WalletAPI.shared.generateKeyPair(hWalletToken: hWalletToken, keyId: "keyagree", algType: AlgorithmType.secp256r1)
//            // PIN 등록
//            try WalletAPI.shared.generateKeyPair(hWalletToken: hWalletToken, passcode: "123456", keyId: "pin", algType: AlgorithmType.secp256r1)
//            
//            let signedDIDDoc = try walletAPI.createSignedDIDDoc(passcode: "123456")
//            
//            print("success signedDidDoc")
//            
//            _ = try await walletAPI.requestRegisterUser(tasURL: "NONE", txId: "txId", hWalletToken: hWalletToken, serverToken: "serverToken", signedDIDDoc: signedDIDDoc)
//
//            print("success requestRegisterUser")
//            
//        } catch let error as WalletAPIError {
//            print("testRegisterUser error: \(error)")
//        }
    }
    
    // vc발급
    func testIssueCredential() async throws {
        
//        try await testRegisterUser()
//        
//        print("###################### 5. VC 발급")
//        do {
//            let walletTokenDataJson = """
//        {"nonce":"mHaq6qqiUKLt8N6raGc+/5g","proof":{"created":"2024-08-23T11:40:03.566877Z","proofPurpose":"assertionMethod","proofValue":"mH6qvGRLx8qpMPhQwJMeEQsz0eGYhZQI1y9yu1xl4b+qIQM2tfFueWHpuffAvdioqSrR0K4Qb0AgbzcdtQO4ds7A","type":"Secp256r1Signature2018","verificationMethod":"did:omn:cas?versionId=1#assert"},"provider":{"certVcRef":"http://192.168.3.130:8094/cas/api/v1/certificate-vc","did":"did:omn:cas"},"seed":{"nonce":"F6438ED0B74B348E3635C89DA164E8FFE","pkgName":"org.omnione.did.ca","purpose":8,"userId":"7156af3d","validUntil":"2050-08-23T12:10:02Z"},"sha256_pii":"zCWYkiLKjXUHu5xCRcJoJ9nfiyKzhiYW3YiWwdDwfh2vx"}
//        """
//            let walletTokenData = try WalletTokenData(from: walletTokenDataJson)
//            
//            let resultNonce = try await walletAPI.createNonceForWalletToken(walletTokenData: walletTokenData, APIGatewayURL: "NONE")
//            
//            let digest = DigestUtils.getDigest(source: (walletTokenDataJson + resultNonce).data(using: String.Encoding.utf8)!, digestEnum: DigestEnum.sha256)
//            // Hex
//            let hWalletToken = String(MultibaseUtils.encode(type: MultibaseType.base16, data: digest).dropFirst())
//
//            let didAuth = try walletAPI.getSignedDidAuth(authNonce: "authNonce", passcode: "123456")
//            
//            let isserProfileDummy = """
//                            {
//                              "txId": "1ca4e278-76cd-47e4-978f-139273e0a28a",
//                              "authNonce": "authNonce",
//                              "profile": {
//                                "description": "National ID",
//                                "encoding": "UTF-8",
//                                "id": "4d2c9387-7239-43c0-b829-c899d4aeac19",
//                                "language": "ko",
//                                "profile": {
//                                  "credentialSchema": {
//                                    "id": "http://192.168.3.130:8091/issuer/api/v1/vc/vcschema?name=national_id",
//                                    "type": "OsdSchemaCredential"
//                                  },
//                                  "issuer": {
//                                    "certVcRef": "http://192.168.3.130:8091/issuer/api/v1/certificate-vc",
//                                    "did": "did:omn:issuer",
//                                    "name": "issuer"
//                                  },
//                                  "process": {
//                                    "endpoints": [
//                                      "http://192.168.3.130:8091/issuer"
//                                    ],
//                                    "issuerNonce": "mbRz+NJ7fEZEyFiAGIcfktQ",
//                                    "reqE2e": {
//                                      "cipher": "AES-256-CBC",
//                                      "curve": "Secp256r1",
//                                      "nonce": "mbRz+NJ7fEZEyFiAGIcfktQ",
//                                      "padding": "PKCS5",
//                                      "publicKey": "mA+1jfCC06BtbLwUkkAAsiU46i4GWz17SWnaME4yx7g2c"
//                                    }
//                                  }
//                                },
//                                "proof": {
//                                  "created": "2024-08-29T10:36:10.879887Z",
//                                  "proofPurpose": "assertionMethod",
//                                  "proofValue": "mIGTSOOl3ij0TnXd3xnk368PFDNuvaus2SXlWeiyITsZ7RAPvzi0QZqdWbMPMEh5K2OFTJ0FW/vR/njfvPZBkJc0",
//                                  "type": "Secp256r1Signature2018",
//                                  "verificationMethod": "did:omn:issuer#assert"
//                                },
//                                "title": "National ID",
//                                "type": "IssueProfile"
//                              }
//                            }
//                """
//            
//            let issueProfile = try _RequestIssueProfile(from: isserProfileDummy)
//            
//            _ = try await walletAPI.requestIssueVc(tasURL: "NONE", hWalletToken: hWalletToken, didAuth: didAuth!, issuerProfile: issueProfile, refId: "refId", serverToken: "serverToken", APIGatewayURL: "NONE")
//            
//        } catch let error as WalletAPIError {
//            print("testIssueCredential error: \(error)")
//        } catch {
//            print("testIssueCredential error: \(error)")
//        }
    }
    
//     vp 제출
    func testSubmitCredential() async throws {
        
//        try await testIssueCredential()
//        
//        Task { @MainActor in
//            do {
//                let walletTokenDataJson = """
//                {"nonce":"mHaq6qqiUKLt8N6raGc+/5g","proof":{"created":"2024-08-23T11:40:03.566877Z","proofPurpose":"assertionMethod","proofValue":"mH6qvGRLx8qpMPhQwJMeEQsz0eGYhZQI1y9yu1xl4b+qIQM2tfFueWHpuffAvdioqSrR0K4Qb0AgbzcdtQO4ds7A","type":"Secp256r1Signature2018","verificationMethod":"did:omn:cas?versionId=1#assert"},"provider":{"certVcRef":"http://192.168.3.130:8094/cas/api/v1/certificate-vc","did":"did:omn:cas"},"seed":{"nonce":"F6438ED0B74B348E3635C89DA164E8FFE","pkgName":"org.omnione.did.ca","purpose":14,"userId":"7156af3d","validUntil":"2050-08-23T12:10:02Z"},"sha256_pii":"zCWYkiLKjXUHu5xCRcJoJ9nfiyKzhiYW3YiWwdDwfh2vx"}
//                """
//                let walletTokenData = try WalletTokenData(from: walletTokenDataJson)
//                
//                let resultNonce = try await walletAPI.createNonceForWalletToken(walletTokenData: walletTokenData, APIGatewayURL: "NONE")
//                
//                let digest = DigestUtils.getDigest(source: (walletTokenDataJson + resultNonce).data(using: String.Encoding.utf8)!, digestEnum: DigestEnum.sha256)
//                // Hex
//                let hWalletToken = String(MultibaseUtils.encode(type: MultibaseType.base16, data: digest).dropFirst())
//                let verifierProfile = try _RequestProfile(from:"""
//                {"profile":{"description":"11번가 로그인을 위해 제출이 필요한 VP에 대한 프로파일 입니다.","encoding":"UTF-8","id":"affdb518-34f7-4b85-aaba-d4f9262bd3a7","language":"ko","profile":{"filter":{"credentialSchemas":[{"allowedIssuers":["did:omn:issuer"],"displayClaims":["testId.aa"],"id":"http://192.168.3.130:8091/issuer/api/v1/vc/vcschema?name=national_id",
//                "requiredClaims":["org.opendid.v1.national_id.family_name","org.opendid.v1.national_id.given_name","org.opendid.v1.national_id.birth_date"],"type":"OsdSchemaCredential","value":"VerifiableProfile"}]},"process":{"authType":6,"endpoints":["http://192.168.3.130:8092/verifier"],"reqE2e":{"cipher":"AES-256-CBC","curve":"Secp256r1","nonce":"mMMg3gVgwEsbpxORRNp1SRA","padding":"PKCS5","publicKey":"zw2oVJVmfEqKxjXjE9wc3LBX33WHmusGA91HADm5PRr7D"},"verifierNonce":"mMMg3gVgwEsbpxORRNp1SRA"},"verifier":{"certVcRef":"http://192.168.3.130:8092/verifier/api/v1/certificate-vc","description":"verifier","did":"did:omn:verifier","name":"verifier","ref":"http://192.168.3.130:8092/verifier/api/v1/certificate-vc"}},"proof":{"created":"2024-08-29T18:20:39.666665Z","proofPurpose":"assertionMethod","proofValue":"z3oJhN6sQ7d71doPZAkgumZVyZxSXJw4jL9g8hkPkxaVyU4vKCDXpMf4vS6dh7jUFkKtrb2hSjEyU1mNv7kZXUWUmP","type":"Secp256r1Signature2018","verificationMethod":"did:omn:verifier?versionId=1#assert"},"title":"11번가 로그인 VP 프로파일","type":"VerifyProfile"},"txId":"1b1451bd-db27-4e57-96f2-5543fa365c7b"}
//                """)
//                
//                
//                let schemas = verifierProfile.profile.profile.filter.credentialSchemas
//                let vcs = try WalletAPI.shared.getAllCrentials(hWalletToken: hWalletToken)!
//                var claimInfos:[ClaimInfo]? = []
//                for schema in schemas {
//                    for vc in vcs {
//                        print("----> vc.credentialSchema.id: \(vc.credentialSchema.id)")
//                        print("----> schema.id: \(schema.id)")
//                        if vc.credentialSchema.id == schema.id {
//                            let claimInfo = ClaimInfo(credentialId: vc.id, claimCodes: schema.requiredClaims!)
//                            claimInfos?.append(claimInfo)
//                        }
//                    }
//                }
//                
//                _ = try await walletAPI.createEncVp(hWalletToken: hWalletToken, claimInfos: claimInfos, verifierProfile: verifierProfile, APIGatewayURL: "NONE", passcode: "123456")
//            } catch let error as WalletAPIError {
//                print("testSubmitCredential error: \(error)")
//            } catch {
//                print("testSubmitCredential error: \(error)")
//            }
//        }
//        
//        sleep(10)
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testGenHolderKey() throws {
        do {
            
            let holderKey = try KeyManager(fileName: "holderKey")
            if holderKey.isAnyKeysSaved {
                try holderKey.deleteAllKeys()
            }
            
            if try holderKey.isKeySaved(id: "free") == false {
                let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "free", methodType: .none)
                try holderKey.generateKey(keyGenRequest: freeKeyRequest)
                print("device Key 생성 완료")
            }
            
            if try holderKey.isKeySaved(id: "pin") == false {
                let pinData = "password".data(using: .utf8)!
                let pinKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "pin", methodType: WalletAccessMethod.pin(value: pinData))
                try holderKey.generateKey(keyGenRequest: pinKeyRequest)
                print("PIN Key 생성 완료")
            }

            
            let did = try DIDManager.genDID(methodName: "omn")
            var didMnr = try DIDManager(fileName: "holderDidDoc")
            print("DID String : \(did)")
            
            
            if didMnr.isSaved {
                print("월렛에 저장된 DID Doc 존재 함")
                try didMnr.deleteDocument()
                return
            }
            
            let keyInfos = try holderKey.getKeyInfos(ids: ["free", "pin"])
            var didKeyInfos: [DIDKeyInfo] = .init()
            
            for keyInfo in keyInfos {
                if keyInfo.id == "free" {
                    didKeyInfos.append(DIDKeyInfo(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))
                } else {
                    didKeyInfos.append(DIDKeyInfo(keyInfo: keyInfo, methodType: [.authentication]))
                }
            }
            
            print("keyInfos: \(keyInfos)")
            try didMnr.createDocument(did: did, keyInfos: didKeyInfos, controller: nil, service: nil)
            
            
            
            if try holderKey.isKeySaved(id: "addfree") == false {
                let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "addfree", methodType: .none)
                try holderKey.generateKey(keyGenRequest: freeKeyRequest)
                print("add Key 생성 완료")
            }
            
            if try holderKey.isKeySaved(id: "addfree") == false {
                let addKeyInfo = try holderKey.getKeyInfos(ids: ["addfree"])
                let addDidKeyInfo = DIDKeyInfo(keyInfo: addKeyInfo.first!, methodType: [.authentication, .assertionMethod], controller: nil)
                
                try didMnr.addVerificationMethod(keyInfo: addDidKeyInfo)
            }
           
            let deviceDidDoc = try didMnr.getDocument()
            print("holderDidDoc: \(try deviceDidDoc.toJson())")
            
            try didMnr.saveDocument()
            
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func testGenDeviceKey() throws {
        do {
            let deviceKey = try KeyManager(fileName: "deivceKey")
            if deviceKey.isAnyKeysSaved {
                try deviceKey.deleteAllKeys()
            }
            
            if try deviceKey.isKeySaved(id: "free") == false {
                let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "free", methodType: .none)
                try deviceKey.generateKey(keyGenRequest: freeKeyRequest)
                print("device Key 생성 완료")
            }
            
            let did = try DIDManager.genDID(methodName: "omn")
            var didMnr = try DIDManager(fileName: "deviceDidDoc")
            print("DID String : \(did)")
            
            if didMnr.isSaved {
                print("월렛에 저장된 DID Doc 존재 함")
                try didMnr.deleteDocument()
                return
            }
            
            let keyInfo = try deviceKey.getKeyInfos(ids: ["free"])
            
            var keyInfos: [DIDKeyInfo] = .init()
            keyInfos.append(DIDKeyInfo(keyInfo: keyInfo[0], methodType: [.keyAgreement, .authentication]))
            print("keyInfos: \(keyInfos)")
            
            try didMnr.createDocument(did: did, keyInfos: keyInfos, controller: nil, service: nil)
            
            let deviceDidDoc = try didMnr.getDocument()
            print("deviceDidDoc: \(try deviceDidDoc.toJson())")
            
            try didMnr.saveDocument()
            
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func testVCManager() throws {
        do {
            /// Issuer DID/Key
            let issuerKey = try KeyManager(fileName: "issuerKey")
            if issuerKey.isAnyKeysSaved {
                try issuerKey.deleteAllKeys()
            }
            
            if try issuerKey.isKeySaved(id: "free") == false {
                let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "free", methodType: .none)
                try issuerKey.generateKey(keyGenRequest: freeKeyRequest)
                print("issuer Key 생성 완료")
            }
            
            
            let keyInfos = try issuerKey.getKeyInfos(ids: ["free"])
            var didKeyInfos: [DIDKeyInfo] = .init()
            
            for keyInfo in keyInfos {
                if keyInfo.id == "free" {
                    didKeyInfos.append(DIDKeyInfo(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))
                }
            }
            
            var dummyIssuerDidMnr = try DIDManager(fileName: "issuerDidDoc")
            
            let issuerDid = try DIDManager.genDID(methodName: "omn")
//            try dummyIssuerDidMnr.deleteDocument()
            try dummyIssuerDidMnr.createDocument(did: issuerDid, keyInfos: didKeyInfos, controller: nil, service: nil)
            
            /// holder DID/Key
            let holderKey = try KeyManager(fileName: "holderKey")
            if holderKey.isAnyKeysSaved {
                try holderKey.deleteAllKeys()
            }
            
            if try holderKey.isKeySaved(id: "free") == false {
                let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "free", methodType: .none)
                try holderKey.generateKey(keyGenRequest: freeKeyRequest)
                print("holder Key 생성 완료")
            }
            
            if try holderKey.isKeySaved(id: "pin") == false {
                let pinData = "password".data(using: .utf8)!
                let pinKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "pin", methodType: WalletAccessMethod.pin(value: pinData))
                try holderKey.generateKey(keyGenRequest: pinKeyRequest)
                print("holder PIN Key 생성 완료")
            }
            
            let holderKeyInfos = try holderKey.getKeyInfos(ids: ["free", "pin"])
            var hodelrDidKeyInfos: [DIDKeyInfo] = .init()
            
            for keyInfo in holderKeyInfos {
                if keyInfo.id == "free" {
                    hodelrDidKeyInfos.append(DIDKeyInfo(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))
                } else {
                    hodelrDidKeyInfos.append(DIDKeyInfo(keyInfo: keyInfo, methodType: [.authentication]))
                }
            }

            var holderDidMnr = try DIDManager(fileName: "holderDidDoc")
            let holderDid = try DIDManager.genDID(methodName: "omn")
            
//            try holderDidMnr.deleteDocument()
            try holderDidMnr.createDocument(did: holderDid, keyInfos: hodelrDidKeyInfos, controller: nil, service: nil)
            
            let vcMnr = try VCManager(fileName: "vcWallet")
            
            if vcMnr.isAnyCredentialsSaved {
                print("월렛에 저장된 vc가 존재함")
                try vcMnr.deleteAllCredentials()
            } else {
                print("월렛에 저장된 vc가 없음")
            }
            
            let vcsample = """
            {"@context" : [ "https://www.w3.org/ns/credentials/v2" ],"id" : "99999999-9999-9999-9999-999999999999","type" : [ "VerifiableCredential" ],"issuer" : {"id" : "did:raon:issuer","name" : "issuer"},"issuanceDate" : "2024-01-01T09:00:00Z","validFrom" : "2024-01-01T09:00:00Z","validUntil" : "2099-01-01T09:00:00Z",
              "encoding" : "UTF-8","formatVersion" : "1.0","language" : "ko","evidence" : [{"type": "DocumentVerification","verifier": "did:raon:issuer","evidenceDocument": "BusinessLicense","subjectPresence": "Physical","documentPresence": "Physical"}],"credentialSchema" : {"id" : "http://192.168.3.130:8090/tas/api/v1/download/schema?name=mdl","type" : "OsdSchemaCredential"},"credentialSubject" : {"id" : "did:raon:issuer",
                "claims" : [{"code" : "org.iso.18013.5.family_name","caption" : "성","value" : "김","type" : "text","format" : "plain"},
                  {"code" : "org.iso.18013.5.given_name","caption" : "이름","value" : "라온","type" : "text","format" : "plain"
                  },{"code" : "org.iso.18013.5.birth_date","caption" : "생년월일","value" : "2012-10-02","type" : "text","format" : "plain"
                  },{"code" : "org.iso.18013.5.age_in_years","caption" : "연령","value" : "12","type" : "text","format" : "plain","required" : false
                  },{"code" : "org.iso.18013.5.portrait","caption" : "증명서진","value" : "","type" : "image","format" : "jpg"
                  },{"code" : "org.opendid.v1.pii","caption" : "개인식별자","value" : "123456","type" : "text","format" : "plain"
                  }]},"proof" : {"type" : "Secp256r1Signature2018","created" : "2024-01-01T09:00:00Z","verificationMethod" : "did:raon:issuer?version=1.0#assert",
                "proofPurpose" : "assertionMethod","proofValue" : "전체 클레임에 대한 서명","proofValueList" : [ "Y3KazIOqOWavduu2xLD-RtHMEeRCVbtaLKc2Y18hqjHIULQbHTMeQveqBK9hpqca7bd8MjghuK","Y3KazIOqOWavduu2xLD-RtHMEeRCVbtaLKc2Y18hqjHIULQbHTMeQveqBK9hpqca7bd8MjghuK","Y3KazIOqOWavduu2xLD-RtHMEeRCVbtaLKc2Y18hqjHIULQbHTMeQveqBK9hpqca7bd8MjghuK","Y3KazIOqOWavduu2xLD-RtHMEeRCVbtaLKc2Y18hqjHIULQbHTMeQveqBK9hpqca7bd8MjghuK","Y3KazIOqOWavduu2xLD-RtHMEeRCVbtaLKc2Y18hqjHIULQbHTMeQveqBK9hpqca7bd8MjghuK","Y3KazIOqOWavduu2xLD-RtHMEeRCVbtaLKc2Y18hqjHIULQbHTMeQveqBK9hpqca7bd8MjghuK" ]}}
            """
            let vc = try VerifiableCredential(from: vcsample)
            
            
            try vcMnr.addCredential(credential: vc)
            
            let savedVcs = try vcMnr.getAllCredentials()
            print("vcs count: \(savedVcs.count)")
            print("vc json: \(try savedVcs[0].toJson())")
            
            /* 
             schema Id라면..
            VCManager.getSchemaId()
            VCManager.getVcMetas() - 객체 정의 필요.
            
            vc 저장때 중복체크
             
             VC Meta: id, schemaType, title
             
             화면에 그릴때
             1. vc 리스트에 item표시할 것
              - schemaName, validUntil만 그리는데 issuance
             2. vc 대표 이미지 (vc schema)
             
             */
            let claimInfos:[ClaimInfo] = [ClaimInfo(credentialId: savedVcs[0].id, claimCodes: ["org.iso.18013.5.given_name", "org.iso.18013.5.birth_date"])]
            
            print("holderdid: \(holderDid)")
            let presentationInfo = PresentationInfo(holder: holderDid, 
                                                    validFrom: "2024-07-12T10:48:00Z",
                                                    validUntil: "2024-07-12T10:50:00Z", 
                                                    verifierNonce:"fbce87d9cfac255867a8d4488650a4fbd")
            
//            holderKey.getKeyInfos(keyType: VerifyAuthType.)
            
            let vp = try vcMnr.makePresentation(claimInfos: claimInfos, presentationInfo: presentationInfo)
            print("vp json: \(try vp.toJson())")
            
        } catch {
            print("error \(error.localizedDescription)")
        }
    }
    
    
    func testKeyManager() throws {
        let decode = try MultibaseUtils.decode(encoded: "meyJwYXlsb2FkIjoiSXNzdWVyT2ZmZXJQYXlsb2FkKG9mZmVySWQ9NWVlMzk1YmQtZjZiZC00YzBmLWFiYjUtZWRkNThmYWViZjQwLHZjUGxhbklkPXZjcGxhbmlkMDAwMDAwMDAwMDAxLHR5cGU9SXNzdWVPZmZlcixpc3N1ZXI9ZGlkOm9tbjppc3N1ZXIsdmFsaWRVbnRpbD0yMDI0LTA3LTI5VDExOjM0OjI3LjE1NDA0MDA3NVopIiwicGF5bG9hZFR5cGUiOiJJU1NVRV9WQyJ9")
        print("decode: \(decode)")
//        do {
//            let holderKey = try KeyManager(fileName: "holderKey")
//            if holderKey.isAnyKeysSaved {
//                try holderKey.deleteAllKeys()
//            }
//            
//            if try holderKey.isKeySaved(id: "free") == false {
//                let freeKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "free", methodType: .none)
//                try holderKey.generateKey(keyGenRequest: freeKeyRequest)
//                print("무인증 Key 생성 완료")
//            }
//            
//            if try holderKey.isKeySaved(id: "pin") == false {
//                let pinData = "password".data(using: .utf8)!
//                let pinKeyRequest = WalletKeyGenRequest(algorithmType: .secp256r1, id: "pin", methodType: WalletAccessMethod.pin(value: pinData))
//                try holderKey.generateKey(keyGenRequest: pinKeyRequest)
//                print("PIN Key 생성 완료")
//            }
//            
//            // not supply simulator
////            if !keyManager.isKeySaved(id: "bio") {
////                let bioKeyRequest = SecureKeyGenRequest(id: "bio", accessMethod: .currentSet, prompt: "touch your fingerprint")
////                try keyManager.generateKey(keyGenRequest: bioKeyRequest)
////                print("바이오키 생성 완료")
////            }
//            
//            // id로 조회
//            let keyInfos = try holderKey.getKeyInfos(ids: ["free", "pin"])
//            print("keyInfos: \(keyInfos)")
//            
//            // keyType으로 조회
//            let orKeyInfos = try holderKey.getKeyInfos(keyType: [.free, .pin])
//            print("orKeyInfos: \(orKeyInfos)")
//            
//            // free키 삭제
////            try keyManager.deleteKeys(ids: ["free", "pin"])
//            
//            // 모든 키정보 조회
//            let keyAllInfos = try holderKey.getKeyInfos(keyType: [])
//            print("keyAllInfos: \(keyAllInfos)")
//            print("keyManager.isAnyKeysSaved :\(holderKey.isAnyKeysSaved)")
//            
//            let plainData = "password".data(using: .utf8)!
//            let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)
//            
//            /// sign
//            let signature1 = try holderKey.sign(id: "free", digest: digest)
//            print("free sign: \(MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature1))")
//            
//            // 패스워드 입력 필요
//            let signature2 = try holderKey.sign(id: "pin", pin: plainData, digest: digest)
//            print("pin sign: \(MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature2))")
//            
//            let freeKeyInfos = try holderKey.getKeyInfos(ids: ["free"])
//            let yourPubKey = try MultibaseUtils.decode(encoded:freeKeyInfos[0].publicKey)
//            /// verify - 무인증키로 서명한걸 pin키로 검증
//            let result = try holderKey.verify(algorithmType: .secp256r1, publicKey: yourPubKey, digest: digest, signature: signature1)
//            
//        } catch {
//            print("error: \(error.localizedDescription)")
//        }
    }
    
    func testRestoreDID() throws {
//        Task {
//            do {
//                try await RestoreUserProtocol.shared.preProcess(offerId: "aae54cdf-0412-4878-bd32-b9745dd60482", did: "did:omn:gagws6YDE6qAGac2MsjPkAQah3t")
//
//                let pinVC = UIStoryboard.init(name: "PIN", bundle: nil).instantiateViewController(withIdentifier: "PincodeViewController") as! PincodeViewController
//                pinVC.modalPresentationStyle = .fullScreen
//                pinVC.setRequestType(type: PinCodeTypeEnum.PIN_CODE_AUTHENTICATION_SIGNATURE_TYPE)
//                pinVC.confirmButtonCompleteClosure = { [self] passcode in
//                    Task { @MainActor in
//                        do {
//                            try await RestoreUserProtocol.shared.process(passcode: passcode)
//
//                        } catch let error as WalletSDKError {
//                            print("error code: \(error.code), message: \(error.message)")
//                            PopupUtils.showAlertPopup(title: error.code, content: error.message, VC: self)
//                        } catch let error as WalletCoreError {
//                            print("error code: \(error.code), message: \(error.message)")
//                            PopupUtils.showAlertPopup(title: error.code, content: error.message, VC: self)
//                        } catch let error as CommunicationSDKError {
//                            print("error code: \(error.code), message: \(error.message)")
//                            PopupUtils.showAlertPopup(title: error.code, content: error.message, VC: self)
//                        } catch {
//                            print("error: \(error)")
//                        }
//                    }
//                }
//                pinVC.cancelButtonCompleteClosure = { }
//                DispatchQueue.main.async { self.present(pinVC, animated: false, completion: nil) }
//
//            } catch let error as WalletSDKError {
//                print("error code: \(error.code), message: \(error.message)")
//                PopupUtils.showAlertPopup(title: error.code, content: error.message, VC: self)
//            } catch let error as WalletCoreError {
//                print("error code: \(error.code), message: \(error.message)")
//                PopupUtils.showAlertPopup(title: error.code, content: error.message, VC: self)
//            } catch let error as CommunicationSDKError {
//                print("error code: \(error.code), message: \(error.message)")
//                PopupUtils.showAlertPopup(title: error.code, content: error.message, VC: self)
//            } catch {
//                print("error: \(error)")
//            }
//        }
    }

    func testMultibase() throws {
        
//        let data = "test".data(using: .utf8)!
//        let encode = MultibaseUtils.encode(type: MultibaseType.base16, data: data)
        let decode = try MultibaseUtils.decode(encoded: "meyJwYXlsb2FkIjoiSXNzdWVyT2ZmZXJQYXlsb2FkKG9mZmVySWQ9NWVlMzk1YmQtZjZiZC00YzBmLWFiYjUtZWRkNThmYWViZjQwLHZjUGxhbklkPXZjcGxhbmlkMDAwMDAwMDAwMDAxLHR5cGU9SXNzdWVPZmZlcixpc3N1ZXI9ZGlkOm9tbjppc3N1ZXIsdmFsaWRVbnRpbD0yMDI0LTA3LTI5VDExOjM0OjI3LjE1NDA0MDA3NVopIiwicGF5bG9hZFR5cGUiOiJJU1NVRV9WQyJ9")
        print("decode: \(decode)")
    }
    
    func testDigest() throws {
        
        let data = "test".data(using: .utf8)!
        let sha256 = DigestUtils.getDigest(source: data, digestEnum: DigestEnum.sha256)
        print("sha256: \(sha256)")
    }
    
    func testChangePin() throws {
        
    }
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}
