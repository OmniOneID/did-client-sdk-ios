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

final class Secp256R1ManagerTests: XCTestCase {

    let secp256R1Manager : Secp256R1Manager = .init()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateKey() throws
    {
        for _ in 0..<10
        {
            let (privateKey, publicKey) = try secp256R1Manager.generateKey()
            print("privateKey \(privateKey.hexString())")
            print("publicKey \(publicKey.hexString())")
            print("------------------------------------------------------------------------------")
        }
    }
    
    func testSign() throws
    {
        for _ in 0..<5
        {
            let (privateKey, publicKey) = try secp256R1Manager.generateKey()
            
            let plainData = "Test".data(using: .utf8)!
            let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)
            let signature = try secp256R1Manager.sign(privateKey: privateKey,
                                                      digest: digest)
            
            print("privateKey \(privateKey.hexString())")
            print("publicKey \(publicKey.hexString())")
            print("signature \(signature.hexString())")
            print("------------------------------------------------------------------------------")
        }
    }
    
    func testVerify() throws
    {
        let plainData = "Test".data(using: .utf8)!
        let digest = DigestUtils.getDigest(source: plainData, digestEnum: .sha256)
        
        let publicKey = "037076c64485b44107af097576db296438a237450375924cdaa706aad318017db9".hexToData()!
        let signature = "1f4a0c4c010843d1395772671ce125c57d6afa2ea1606168f0d37f02cc67433fd56aa57e1403820992ac2b73066addddb717d99a03ad4d067757f5cfc339576649".hexToData()!
        
        let result = try secp256R1Manager.verify(publicKey: publicKey, digest: digest, signature: signature)
        
        print("result is \(result)")
    }
    
    func testCheckKeyPairMatch() throws
    {
        let privateKey = "689203d025c993575fc13526b196c74ecbc89e8c429a84c7da7362ea50d9d063".hexToData()!
        let publicKey  = "03e9fd6026080ca16e3e5a68a68d619cdaa0e53aba506787a5b0d8bb81da0a4438".hexToData()!
        
        try secp256R1Manager.checkKeyPairMatch(privateKey: privateKey, publicKey: publicKey)
        print("done")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
