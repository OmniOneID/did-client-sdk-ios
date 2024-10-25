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

final class DigestUtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHash() throws {
        let source = "68656c6c6f2c20776f726c6421".base16Decoded! // "hello, world!".data(using: .utf8)!
        
        let sha256 = "68e656b251e67e8358bef8483ab0d51c6619f3e7a1a9f0e75838d41ff368f728".base16Decoded!
        let sha384 = "6f9f238425eca2439ed4581ac1fdb45fc76379e7fba94bc0a7624fa3e7ab1ec3701b4bfcdda376ca755192e6f45f2a4e".base16Decoded!
        let sha512 = "6c2618358da07c830b88c5af8c3535080e8e603c88b891028a259ccdb9ac802d0fc0170c99d58affcf00786ce188fc5d753e8c6628af2071c3270d50445c4b1c".base16Decoded!
        
        XCTAssertEqual(DigestUtils.getDigest(source: source, digestEnum: .sha256), sha256)
        XCTAssertEqual(DigestUtils.getDigest(source: source, digestEnum: .sha384), sha384)
        XCTAssertEqual(DigestUtils.getDigest(source: source, digestEnum: .sha512), sha512)
    }

}
