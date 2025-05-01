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

final class VCManagerTests: XCTestCase {
    
    let vcManager: VCManager = try! .init(fileName: "test")

    override func setUpWithError() throws {
        if vcManager.isAnyCredentialsSaved {
            try vcManager.deleteAllCredentials()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddCredential() throws {
        let vc = try VerifiableCredential(from: vcJson)
        try vcManager.addCredential(credential: vc)
    }
    
    func testGetCredentials() throws {
        if !vcManager.isAnyCredentialsSaved {
            do {
                let _ = try vcManager.getCredentials(by: ["1234"])
                XCTAssert(false, "Unexpected case")
            } catch {
                guard let err = error as? WalletCoreError else {
                    XCTAssert(false, "Unexpected case")
                    return
                }
                
                let expectedErrorCode = StorageManagerError.noItemsSaved.getCodeAndMessage().0
                XCTAssert(err.code.hasSuffix(expectedErrorCode))
            }
        }
        
        let count: UInt = 2
        
        let addedIds = try makeTestCredentials(count: count)
        
        let vcs = try vcManager.getCredentials(by: addedIds)
        let getIds = vcs.map{ $0.id }
        
        XCTAssertEqual(count, UInt(getIds.count))
        XCTAssertEqual(Set(addedIds), Set(getIds))
    }
    
    func testGetAllCredentials() throws {
        if !vcManager.isAnyCredentialsSaved {
            do {
                let _ = try vcManager.getAllCredentials()
                XCTAssert(false, "Unexpected case")
            } catch {
                guard let err = error as? WalletCoreError else {
                    XCTAssert(false, "Unexpected case")
                    return
                }
                
                let expectedErrorCode = StorageManagerError.noItemsSaved.getCodeAndMessage().0
                XCTAssert(err.code.hasSuffix(expectedErrorCode))
            }
        }
        
        let count: UInt = 2
        
        let addedIds = try makeTestCredentials(count: count)
        
        let vcs = try vcManager.getAllCredentials()
        let getIds = vcs.map{ $0.id }
        
        XCTAssertEqual(count, UInt(getIds.count))
        XCTAssertEqual(Set(addedIds), Set(getIds))
    }
    
    func testDeleteCredentials() throws {
        if !vcManager.isAnyCredentialsSaved {
            do {
                let _ = try vcManager.deleteCredentials(by: ["1234"])
                XCTAssert(false, "Unexpected case")
            } catch {
                guard let err = error as? WalletCoreError else {
                    XCTAssert(false, "Unexpected case")
                    return
                }
                
                let expectedErrorCode = StorageManagerError.noItemsSaved.getCodeAndMessage().0
                XCTAssert(err.code.hasSuffix(expectedErrorCode))
            }
        }
        
        let count: UInt = 3
        
        var addedIds = try makeTestCredentials(count: count)
        let idToDelete = addedIds.popLast()!
        
        try vcManager.deleteCredentials(by: [idToDelete])
        
        let remainedVCs = try vcManager.getAllCredentials()
        
        XCTAssertEqual(remainedVCs.count, addedIds.count)
        XCTAssertTrue(remainedVCs.filter({ $0.id == idToDelete }).count == 0)
        
        try vcManager.deleteCredentials(by: addedIds)

        XCTAssertFalse(vcManager.isAnyCredentialsSaved)
    }
    
    func testDeleteAllCredentials() throws {
        if !vcManager.isAnyCredentialsSaved {
            do {
                let _ = try vcManager.deleteCredentials(by: ["1234"])
                XCTAssert(false, "Unexpected case")
            } catch {
                guard let err = error as? WalletCoreError else {
                    XCTAssert(false, "Unexpected case")
                    return
                }
                
                let expectedErrorCode = StorageManagerError.noItemsSaved.getCodeAndMessage().0
                XCTAssert(err.code.hasSuffix(expectedErrorCode))
            }
        }
        
        try makeTestCredentials(count: 3)
        
        try vcManager.deleteAllCredentials()
        
        XCTAssertFalse(vcManager.isAnyCredentialsSaved)
    }
    
    func testMakePresentation() throws {
        if !vcManager.isAnyCredentialsSaved {
            do {
                let claimInfo: ClaimInfo = .init(credentialId: "1234", claimCodes: ["code1"])
                let presentationInfo: PresentationInfo = .init(holder: "did:raon:holder", validFrom: "2024-09-02T00:00:00Z", validUntil: "2024-09-02T00:01:00Z", verifierNonce: "12345678123456781234567812345678")
                let _ = try vcManager.makePresentation(claimInfos: [claimInfo], presentationInfo: presentationInfo)
                XCTAssert(false, "Unexpected case")
            } catch {
                guard let err = error as? WalletCoreError else {
                    XCTAssert(false, "Unexpected case")
                    return
                }
                
                let expectedErrorCode = StorageManagerError.noItemsSaved.getCodeAndMessage().0
                XCTAssert(err.code.hasSuffix(expectedErrorCode))
            }
        }
        
        let vcIds: [String] = try makeTestCredentials(count: 1)
        
        let vcs = try vcManager.getCredentials(by: vcIds)
        let vcToPresent = vcs.first!
        
        let claimCodes: [String] = vcToPresent.credentialSubject.claims.map { $0.code }
        let claimInfo: ClaimInfo = .init(credentialId: vcToPresent.id, claimCodes: claimCodes)
        let holder = vcToPresent.credentialSubject.id
        let presentationInfo: PresentationInfo = .init(holder: holder, validFrom: "2024-09-02T00:00:00Z", validUntil: "2024-09-02T00:01:00Z", verifierNonce: "12345678123456781234567812345678")

        let vp = try vcManager.makePresentation(claimInfos: [claimInfo], presentationInfo: presentationInfo)
        
        print("vp json: \(try vp.toJson())")
    }
    
    //MARK: - methods to make data for test
    
    @discardableResult
    func makeTestCredentials(count: UInt) throws -> [String] {
        var ids: [String] = .init()
        
        for _ in 0..<count {
            var vc = try VerifiableCredential(from: vcJson)
            vc.id = UUID().uuidString   // for test
            ids.append(vc.id)
            try vcManager.addCredential(credential: vc)
        }
        
        return ids
    }
}

let vcJson = """
{
    "@context": [
        "https://www.w3.org/ns/credentials/v2"
    ],
    "id": "99999999-9999-9999-9999-999999999999",
    "type": [
        "VerifiableCredential"
    ],
    "issuer": {
        "id": "did:raon:issuer",
        "name": "issuer"
    },
    "issuanceDate": "2024-01-01T09:00:00Z",
    "validFrom": "2024-01-01T09:00:00Z",
    "validUntil": "2099-01-01T09:00:00Z",
    "encoding": "UTF-8",
    "formatVersion": "1.0",
    "language": "ko",
    "evidence": [
        {
            "type": "DocumentVerification",
            "verifier": "did:raon:issuer",
            "evidenceDocument": "BusinessLicense",
            "subjectPresence": "Physical",
            "documentPresence": "Physical"
        }
    ],
    "credentialSchema": {
        "id": "http://192.168.3.130:8090/tas/api/v1/download/schema?name=mdl",
        "type": "OsdSchemaCredential"
    },
    "credentialSubject": {
        "id": "did:raon:holder",
        "claims": [
            {
                "code": "org.iso.18013.5.family_name",
                "caption": "성",
                "value": "김",
                "type": "text",
                "format": "plain"
            },
            {
                "code": "org.iso.18013.5.given_name",
                "caption": "이름",
                "value": "라온",
                "type": "text",
                "format": "plain"
            },
            {
                "code": "org.iso.18013.5.birth_date",
                "caption": "생년월일",
                "value": "2012-10-02",
                "type": "text",
                "format": "plain"
            },
            {
                "code": "org.iso.18013.5.age_in_years",
                "caption": "연령",
                "value": "12",
                "type": "text",
                "format": "plain",
                "required": false
            },
            {
                "code": "org.iso.18013.5.portrait",
                "caption": "증명서진",
                "value": "",
                "type": "image",
                "format": "jpg"
            },
            {
                "code": "org.opendid.v1.pii",
                "caption": "개인식별자",
                "value": "123456",
                "type": "text",
                "format": "plain"
            }
        ]
    },
    "proof": {
        "type": "Secp256r1Signature2018",
        "created": "2024-01-01T09:00:00Z",
        "verificationMethod": "did:raon:issuer?version=1.0#assert",
        "proofPurpose": "assertionMethod",
        "proofValue": "전체 클레임에 대한 서명",
        "proofValueList": [
            "개별 클레임에 대한 서명1",
            "개별 클레임에 대한 서명2",
            "개별 클레임에 대한 서명3",
            "개별 클레임에 대한 서명4",
            "개별 클레임에 대한 서명5",
            "개별 클레임에 대한 서명6"
        ]
    }
}
"""
