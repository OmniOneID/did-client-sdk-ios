//
//  DIDManagerTests.swift
//
//  Copyright 2024 Raonsecure
//

import XCTest
@testable import DIDCoreSDK
import DIDDataModelSDK

final class DIDManagerTests: XCTestCase {
    
    var didManager: DIDManager = try! .init(fileName: "test")

    override func setUpWithError() throws {
        if didManager.isSaved {
            try didManager.deleteDocument()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateAndSaveDocument() throws {
        let did = try DIDManager.genDID(methodName: "raon")
        
        let keyIds: [String] = ["pin"]
        var keyInfos: [DIDKeyInfo] = .init()
        
        let keyInfo = KeyInfo(algorithmType: .secp256r1, id: keyIds.first!, accessMethod: .walletPin, authType: .pin, publicKey: "z52u5dowpzhNde4nTRryWWWjqSSxB8xhkXpLLm4bXWkSy")   // actually, you should take this object using `KeyManager.getKeyInfos`
        
        keyInfos.append(.init(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication]))
        
        try didManager.createDocument(did: did, keyInfos: keyInfos, controller: nil, service: nil)
        
        var didDoc = try didManager.getDocument()
        print("getDocument after createDocument: \n\n\(try didDoc.toJson(isPretty: true))")
        
        XCTAssertEqual(didDoc.verificationMethod.first!.id, keyIds.first!)
        XCTAssertEqual(didDoc.assertionMethod!.first!, keyIds.first!)
        XCTAssertEqual(didDoc.authentication!.first!, keyIds.first!)
        XCTAssertNil(didDoc.keyAgreement)
        XCTAssertNil(didDoc.capabilityInvocation)
        XCTAssertNil(didDoc.capabilityDelegation)
        XCTAssertEqual(didDoc.id, did)
        XCTAssertEqual(didDoc.controller, did)
        XCTAssertEqual(didDoc.versionId, "1")
        
        //=========== Start signing and registering process ===========//
        var proof: Proof = .init(
            created: "2024-09-02T00:00:00Z",
            proofPurpose: .assertionMethod,
            verificationMethod: "did:raon:holder#\(keyIds.first!)",
            type: .secp256r1Signature2018
        )
        
        didDoc.proofs = [proof] // Set the `proof` before sign
        
        let _ /*sourceToSign*/ = try didDoc.toJson()
        
        let proofValue = "z3rjveoeDebHCmLiwFEU5URcQ4EgB57sLjSPZ23vM9Z73ZWRJqcm6K7mKt9W5zmyTkv4pYHVzX1jLodhC4ta3XHDmB"   // It should take this value using `MultibaseUtils.encode` after sign `sourceToSign` using `KeyManager.sign`
        
        proof.proofValue = proofValue
        
        didDoc.proofs = [proof] // Set the `proof` after sign. If `keyInfos`'s count is above one, it can be `proofs`'s count is above one, also.
        
        // Request registering `didDoc` to blockchain.
        // Above process skipped for independant unit test.
        
        //=========== Finish signing and registering process ===========//
        
        didManager.replaceDocument(didDocument: didDoc, needUpdate: false)
        
        try didManager.saveDocument()
        
        let didDocAfterSaved = try didManager.getDocument()
        print("getDocument after saveDocument: \n\n\(try didDocAfterSaved.toJson(isPretty: true))")
        
        XCTAssertTrue(didManager.isSaved)
    }
    
    func testEditVerificationMethodAndSaveDocument() throws {
        try makeTestDocument()
        
        let didDoc = try didManager.getDocument()
        
        let originVerificationCount = didDoc.verificationMethod.count
        let originAssertionCount = didDoc.assertionMethod!.count
        let originAuthenticationCount = didDoc.authentication!.count
        
        //MARK: Scenario to add verification method
        
        let keyId = "bio"
        let keyInfo = KeyInfo(algorithmType: .secp256r1, id: keyId, accessMethod: .secureEnclaveAny, authType: .bio, publicKey: "z52u5dowpzhNde4nTRryWWWjqSSxB8xhkXpLLm4bXWkSy")   // actually, you should take this object using `KeyManager.getKeyInfos`
        let didKeyInfo: DIDKeyInfo = .init(keyInfo: keyInfo, methodType: [.assertionMethod, .authentication, .keyAgreement, .capabilityDelegation, .capabilityInvocation])
        
        try didManager.addVerificationMethod(keyInfo: didKeyInfo)
        
        let didDocAfterAdd = try didManager.getDocument()
        
        print("didDoc after add verification: \(try didDocAfterAdd.toJson(isPretty: true))")
        
        XCTAssertEqual(didDocAfterAdd.verificationMethod.last!.id, keyId)
        XCTAssertEqual(didDocAfterAdd.keyAgreement!.first!, keyId)
        XCTAssertEqual(didDocAfterAdd.capabilityInvocation!.first!, keyId)
        XCTAssertEqual(didDocAfterAdd.capabilityDelegation!.first!, keyId)

        XCTAssertEqual(didDocAfterAdd.verificationMethod.count, originVerificationCount + 1)
        XCTAssertEqual(didDocAfterAdd.assertionMethod!.count, originAssertionCount + 1)
        XCTAssertEqual(didDocAfterAdd.authentication!.count, originAuthenticationCount + 1)
        XCTAssertEqual(didDocAfterAdd.keyAgreement!.count, 1)
        XCTAssertEqual(didDocAfterAdd.capabilityInvocation!.count, 1)
        XCTAssertEqual(didDocAfterAdd.capabilityDelegation!.count, 1)

        //=========== Start signing and registering process ===========//
        //
        // Need to make proof at DID Document and
        // request registering `didDocAfterAdd` to blockchain.
        // Above process skipped for independant unit test.
        //
        //=========== Finish signing and registering process ===========//
        
        didManager.replaceDocument(didDocument: didDocAfterAdd, needUpdate: false)
        
        try didManager.saveDocument()
        
        //MARK: Scenario to remove verification method
        
        try didManager.removeVerificationMethod(keyId: keyId)
        
        let didDocAfterRemove = try didManager.getDocument()
        
        print("didDoc after remove verification: \(try didDocAfterRemove.toJson(isPretty: true))")
        
        XCTAssertNotEqual(didDocAfterRemove.verificationMethod.last!.id, keyId)
        XCTAssertNil(didDocAfterRemove.keyAgreement)
        XCTAssertNil(didDocAfterRemove.capabilityInvocation)
        XCTAssertNil(didDocAfterRemove.capabilityDelegation)

        XCTAssertEqual(didDocAfterRemove.verificationMethod.count, originVerificationCount)
        XCTAssertEqual(didDocAfterRemove.assertionMethod!.count, originAssertionCount)
        XCTAssertEqual(didDocAfterRemove.authentication!.count, originAuthenticationCount)

        //=========== Start signing and registering process ===========//
        //
        // Need to make proof at DID Document and
        // request registering `didDocAfterRemove` to blockchain.
        // Above process skipped for independant unit test.
        //
        //=========== Finish signing and registering process ===========//
        
        didManager.replaceDocument(didDocument: didDocAfterRemove, needUpdate: false)
        
        try didManager.saveDocument()
    }
    
    func testEditServiceAndSaveDocument() throws {
        try makeTestDocument()
        
//        let didDoc = try didManager.getDocument()
                
        //MARK: Scenario to add service
        
        let serviceId = "your service id"
        let service: DIDDocument.Service = .init(id: "your service id", type: .linkedDomains, serviceEndpoint: ["linked domain endpoint"])
        
        try didManager.addService(service: service)
        
        let didDocAfterAdd = try didManager.getDocument()
        
        print("didDoc after add service: \(try didDocAfterAdd.toJson(isPretty: true))")
        
        XCTAssertEqual(didDocAfterAdd.service!.last!.id, serviceId)
        XCTAssertEqual(didDocAfterAdd.service!.count, 1)

        //=========== Start signing and registering process ===========//
        //
        // Need to make proof at DID Document and
        // request registering `didDocAfterAdd` to blockchain.
        // Above process skipped for independant unit test.
        //
        //=========== Finish signing and registering process ===========//
        
        didManager.replaceDocument(didDocument: didDocAfterAdd, needUpdate: false)
        
        try didManager.saveDocument()
        
        //MARK: Scenario to remove service
        
        try didManager.removeService(serviceId: serviceId)
        
        let didDocAfterRemove = try didManager.getDocument()
        
        print("didDoc after remove service: \(try didDocAfterRemove.toJson(isPretty: true))")
        
        XCTAssertNil(didDocAfterRemove.service)

        //=========== Start signing and registering process ===========//
        //
        // Need to make proof at DID Document and
        // request registering `didDocAfterRemove` to blockchain.
        // Above process skipped for independant unit test.
        //
        //=========== Finish signing and registering process ===========//
        
        didManager.replaceDocument(didDocument: didDocAfterRemove, needUpdate: false)
        
        try didManager.saveDocument()
    }

    //MARK: - methods to make data for test
    
    func makeTestDocument() throws {
        let didDoc: DIDDocument = try .init(from: didDocJson)
        didManager.replaceDocument(didDocument: didDoc, needUpdate: false)
    }
}


let didDocJson = """
{
  "@context" : [
    "https://www.w3.org/ns/did/v1"
  ],
  "assertionMethod" : [
    "pin"
  ],
  "authentication" : [
    "pin"
  ],
  "controller" : "did:raon:HveM6mbTzFNVFpre3Jt5B8Lz35A",
  "created" : "2024-09-02T07:16:36Z",
  "deactivated" : false,
  "id" : "did:raon:HveM6mbTzFNVFpre3Jt5B8Lz35A",
  "proof" : {
    "created" : "2024-09-02T00:00:00Z",
    "proofPurpose" : "assertionMethod",
    "proofValue" : "z3rjveoeDebHCmLiwFEU5URcQ4EgB57sLjSPZ23vM9Z73ZWRJqcm6K7mKt9W5zmyTkv4pYHVzX1jLodhC4ta3XHDmB",
    "type" : "Secp256r1Signature2018",
    "verificationMethod" : "did:raon:holder"
  },
  "updated" : "2024-09-02T07:16:36Z",
  "verificationMethod" : [
    {
      "authType" : 2,
      "controller" : "did:raon:HveM6mbTzFNVFpre3Jt5B8Lz35A",
      "id" : "pin",
      "publicKeyMultibase" : "z52u5dowpzhNde4nTRryWWWjqSSxB8xhkXpLLm4bXWkSy",
      "type" : "Secp256r1VerificationKey2018"
    }
  ],
  "versionId" : "1"
}
"""
