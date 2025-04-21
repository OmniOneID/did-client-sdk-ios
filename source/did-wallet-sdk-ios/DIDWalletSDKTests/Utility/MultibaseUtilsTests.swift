/*
 * Copyright 2024-2025 OmniOne.
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

final class MultibaseUtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEncode() throws {
        let source = "68656c6c6f2c20776f726c6421".base16Decoded! // "hello, world!".data(using: .utf8)!
        
        let multibaseBase16 = "f68656c6c6f2c20776f726c6421"
        let multibaseBase16Upper = "F68656C6C6F2C20776F726C6421"
        let multibaseBase58BTC = "z9hLF3DC74NBvQxntSt"
        let multibaseBase64 = "maGVsbG8sIHdvcmxkIQ"
        let multibaseBase64URL = "uaGVsbG8sIHdvcmxkIQ"
        
        XCTAssertEqual(MultibaseUtils.encode(type: .base16, data: source), multibaseBase16)
        XCTAssertEqual(MultibaseUtils.encode(type: .base16Upper, data: source), multibaseBase16Upper)
        XCTAssertEqual(MultibaseUtils.encode(type: .base58BTC, data: source), multibaseBase58BTC)
        XCTAssertEqual(MultibaseUtils.encode(type: .base64, data: source), multibaseBase64)
        XCTAssertEqual(MultibaseUtils.encode(type: .base64URL, data: source), multibaseBase64URL)
    }

    func testDecode() throws {
        let source = "68656c6c6f2c20776f726c6421".base16Decoded! // "hello, world!".data(using: .utf8)!
        
        let multibaseBase16 = "f68656c6c6f2c20776f726c6421"
        let multibaseBase16Upper = "F68656C6C6F2C20776F726C6421"
        let multibaseBase58BTC = "z9hLF3DC74NBvQxntSt"
        let multibaseBase64 = "maGVsbG8sIHdvcmxkIQ"
        let multibaseBase64URL = "uaGVsbG8sIHdvcmxkIQ"

        XCTAssertEqual(try MultibaseUtils.decode(encoded: multibaseBase16), source)
        XCTAssertEqual(try MultibaseUtils.decode(encoded: multibaseBase16Upper), source)
        XCTAssertEqual(try MultibaseUtils.decode(encoded: multibaseBase58BTC), source)
        XCTAssertEqual(try MultibaseUtils.decode(encoded: multibaseBase64), source)
        XCTAssertEqual(try MultibaseUtils.decode(encoded: multibaseBase64URL), source)
    }
    
    func testEncodeAndDecodeRepeatedly() throws {
        for _ in 0 ..< 10000 {
            let nonce = try CryptoUtils.generateNonce(size: 16)
            
            func runBase16() throws {
                let encoded = MultibaseUtils.encode(type: .base16, data: nonce)
                let _ = try MultibaseUtils.decode(encoded: encoded)
            }
            
            func runBase16Upper() throws {
                let encoded = MultibaseUtils.encode(type: .base16Upper, data: nonce)
                let _ = try MultibaseUtils.decode(encoded: encoded)
            }
            
            func runBase58() throws {
                let encoded = MultibaseUtils.encode(type: .base58BTC, data: nonce)
                let _ = try MultibaseUtils.decode(encoded: encoded)
            }
            
            func runBase64() throws {
                let encoded = MultibaseUtils.encode(type: .base64, data: nonce)
                let _ = try MultibaseUtils.decode(encoded: encoded)
            }
            
            func runBase64URL() throws {
                let encoded = MultibaseUtils.encode(type: .base64URL, data: nonce)
                let _ = try MultibaseUtils.decode(encoded: encoded)
            }
            
            try runBase16()
            try runBase16Upper()
            try runBase58()
            try runBase64()
            try runBase64URL()
        }
    }
    
}
