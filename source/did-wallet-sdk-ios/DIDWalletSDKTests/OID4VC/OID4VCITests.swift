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
@testable import DIDWalletSDK

final class OID4VCITests: XCTestCase {
    
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOffer() throws
    {
        let offerString = """
        {
          "credential_configuration_ids": [
            "UniversityDegree",
            "VerifiableIdSD",
            "VerifiableIdLDP",
            "mDoc",
            "StudentID"
          ],
          "credential_issuer": "http://10.48.17.124:8082",
          "grants": {
            "urn:ietf:params:oauth:grant-type:pre-authorized_code": {
              "pre-authorized_code": "1499bc66-f28c-4c99-972e-2443bc900a92",
              "tx_code": {
                "description": "Please enter the PIN.",
                "input_mode": "numeric",
                "length": 6
              }
            }
          }
        }
        """
        
        let offer : CredentialOfferResponse = try .init(from: offerString)
        
        let json = try offer.toJson(isPretty: true)
        print("json \(json)")
        print("offer \(offer.grants)")
        XCTAssert(offerString == json, "not equal")
    }
    
    
    func testIssuanceProtocol() async throws
    {
        let offerURI = "openid-credential-offer://?credential_offer_uri=http://192.168.3.130:8096/credential-offer/p0nNKrV4MXLN3Gqwaa00DxYDY_4oL8e3btDyY4Jyg_AQ"
        let offer = try await OID4VCIProtocol.getCredentialOffer(offerURI: offerURI)
    
        let pinCode = "940171"
            
        let tokenResponse = try await OID4VCIProtocol.getTokenByPreAuthorizedCode(
            pinCode: pinCode,
            offer: offer
        )
        
        let authorizationDetail = tokenResponse.authorizationDetails![3]
        
        try await OID4VCIProtocol.processIssuing(
            offer: offer,
            tokenResponse: tokenResponse,
            selectedConfigId: authorizationDetail.credentialConfigurationId,
            selectedCredentialID: authorizationDetail.credentialIdentifiers?.first,
            APIGatewayURL: ""
        )
        
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
