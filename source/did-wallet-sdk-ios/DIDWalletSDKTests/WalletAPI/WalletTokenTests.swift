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

/// Exercises the real `WalletToken` against CoreData, so the local issuance path and the
/// unchanged `verifyWalletToken` are tested together rather than through `WalletTokenMock`.
final class WalletTokenTests: XCTestCase {
    
    let walletToken = WalletToken(WalletCore())
    let pkgName = "org.omnione.did.wallet.test"
    
    override func setUpWithError() throws {
        Properties.setWalletId(id: "walletId")
        try CoreDataManager.shared.deleteToken()
        try CoreDataManager.shared.deleteUser()
    }
    
    override func tearDownWithError() throws {
        try CoreDataManager.shared.deleteToken()
        try CoreDataManager.shared.deleteUser()
    }
    
    private func personalize() throws {
        try CoreDataManager.shared.insertUser(finalEncKey: "", pii: "sha256_pii")
    }
    
    private func assertCode(_ expected: String, _ body: () throws -> Void, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try body(), file: file, line: line) { error in
            guard let sdkError = error as? WalletSDKError else {
                return XCTFail("unexpected error type: \(error)", file: file, line: line)
            }
            XCTAssertEqual(sdkError.code, "MSDKWLT" + expected, file: file, line: line)
        }
    }
    
    // MARK: - Issuance conditions
    
    func testEmptyPkgNameIsRejected() throws {
        try personalize()
        assertCode("05002") {
            _ = try walletToken.createLocalWalletToken(purpose: .LIST_VC, pkgName: "")
        }
    }
    
    func testPurposeOutsideWhitelistIsRejected() throws {
        try personalize()
        assertCode("05002") {
            _ = try walletToken.createLocalWalletToken(purpose: .REMOVE_VC, pkgName: pkgName)
        }
        XCTAssertNil(try CoreDataManager.shared.selectToken(), "a rejected purpose must not leave a token behind")
    }
    
    func testNotPersonalizedIsRejected() throws {
        assertCode("05046") {
            _ = try walletToken.createLocalWalletToken(purpose: .LIST_VC, pkgName: pkgName)
        }
    }
    
    // MARK: - Issued token
    
    func testIssuedTokenVerifiesForItsPurpose() throws {
        try personalize()
        let token = try walletToken.createLocalWalletToken(purpose: .LIST_VC, pkgName: pkgName)
        
        XCTAssertEqual(token.count, 64)
        XCTAssertNotNil(token.range(of: "^[0-9a-f]+$", options: .regularExpression), "token must be lowercase hex with no multibase prefix")
        XCTAssertNoThrow(try walletToken.verifyWalletToken(hWalletToken: token, purposes: [.LIST_VC]))
        
        let stored = try XCTUnwrap(try CoreDataManager.shared.selectToken())
        XCTAssertEqual(stored.hWalletToken, token)
        XCTAssertEqual(stored.purpose, WalletTokenPurposeEnum.LIST_VC.value)
        XCTAssertEqual(stored.nonce, "")
        XCTAssertEqual(stored.pii, "sha256_pii")
    }
    
    func testIssuedTokenIsRejectedForAnotherPurpose() throws {
        try personalize()
        let token = try walletToken.createLocalWalletToken(purpose: .LIST_VC, pkgName: pkgName)
        
        assertCode("05010") {
            try walletToken.verifyWalletToken(hWalletToken: token, purposes: [.REMOVE_VC])
        }
    }
    
    func testNewTokenInvalidatesPreviousOne() throws {
        try personalize()
        let first = try walletToken.createLocalWalletToken(purpose: .LIST_VC, pkgName: pkgName)
        
        // Any insert replaces the single stored row -- here the online path's insert, stood in for directly.
        try CoreDataManager.shared.insertToken(walletId: "walletId", hWalletToken: "online", purpose: WalletTokenPurposeEnum.ISSUE_VC.value, pkgName: pkgName, nonce: "nonce", pii: "sha256_pii")
        
        assertCode("05010") {
            try walletToken.verifyWalletToken(hWalletToken: first, purposes: [.LIST_VC])
        }
        
        // And the other way round: a new local token replaces the online one.
        let second = try walletToken.createLocalWalletToken(purpose: .LIST_VC, pkgName: pkgName)
        assertCode("05010") {
            try walletToken.verifyWalletToken(hWalletToken: "online", purposes: [.ISSUE_VC])
        }
        XCTAssertNoThrow(try walletToken.verifyWalletToken(hWalletToken: second, purposes: [.LIST_VC]))
    }
    
    func testEveryWhitelistedPurposeIssues() throws {
        try personalize()
        for purpose in WalletToken.localTokenPurposes {
            let token = try walletToken.createLocalWalletToken(purpose: purpose, pkgName: pkgName)
            XCTAssertNoThrow(try walletToken.verifyWalletToken(hWalletToken: token, purposes: [purpose]), "\(purpose)")
        }
        XCTAssertEqual(WalletToken.localTokenPurposes.count, 4)
    }
}
