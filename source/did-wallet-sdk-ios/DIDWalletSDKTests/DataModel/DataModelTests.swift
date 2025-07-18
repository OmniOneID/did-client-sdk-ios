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

final class DIDDataModelSDKTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAlgorithmConvertible() throws
    {
        let proofTypeConvertedTo = ProofType.secp256r1Signature2018.convertTo()
        let ecTypeConvertedTo = ECType.secp256r1.convertTo()
        let didKeyTypeConvertedTo = DIDDocument.DIDKeyType.secp256r1VerificationKey2018.convertTo()
        
        for converted in [proofTypeConvertedTo,
                          ecTypeConvertedTo,
                          didKeyTypeConvertedTo]
        {
            print("converted rawValue - \(converted.rawValue)")
        }
        
        let proofType = ProofType.convertFrom(algorithmType: .secp256r1)
        let didKeyType = DIDDocument.DIDKeyType.convertFrom(algorithmType: .secp256r1)
        
        for rawValue in [proofType.rawValue,
                         didKeyType.rawValue]
        {
            print("rawValue - \(rawValue)")
        }
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
