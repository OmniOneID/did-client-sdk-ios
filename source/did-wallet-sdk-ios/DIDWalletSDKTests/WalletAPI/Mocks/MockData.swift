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

@testable import DIDWalletSDK

struct TokenMock {
    public var idx: String
    public var walletId: String
    public var hWalletToken: String
    public var validUntil: String
    public var purpose: String
    public var nonce: String
    public var pkgName: String
    public var pii: String
    public var createDate: String
    
    public init(idx: String, walletId: String, hWalletToken: String, validUntil: String, purpose: String, nonce: String, pkgName: String, pii: String, createDate: String) {
        self.idx = idx
        self.walletId = walletId
        self.hWalletToken = hWalletToken
        self.validUntil = validUntil
        self.purpose = purpose
        self.nonce = nonce
        self.pkgName = pkgName
        self.pii = pii
        self.createDate = createDate
    }
}

struct UserMock {
    var idx: String
    var pii: String
    public var finalEncKey: String
    var createDate: String
    var updateDate: String
    
    init(idx: String, pii: String, finalEncKey: String, createDate: String, updateDate: String) {
        self.idx = idx
        self.pii = pii
        self.finalEncKey = finalEncKey
        self.createDate = createDate
        self.updateDate = updateDate
    }
    
    public mutating func setFinalEncKey(_ finalEncKey: String) {
        self.finalEncKey = finalEncKey
    }
}

class MockData {
    
    var tokenMock: TokenMock!
    var userMock: UserMock!
    
    public static let shared: MockData = MockData()

    private init() {
        
    }
    
    public func setUserMock(user: UserMock) {
        print("user: \(user)")
        self.userMock = user
    }
    
    public func getUserMock() -> UserMock {
        return self.userMock
    }
    
    public func setTokenMock(token: TokenMock) {
        print("token: \(token)")
        self.tokenMock = token
    }
    
    public func getTokenMock() -> TokenMock? {
        return self.tokenMock
    }
    
    public func hWalletToken(purpose: WalletTokenPurposeEnum) -> String {
        
        switch purpose {
        case .PERSONALIZED:
            return "b1fa33d7e1d6de3ef5d26ddac500f7cd772a84ac1265a68a7e7a26d088898178"
        case .DEPERSONALIZED:
            return "b58d39273d5dcd217d81f9e8be32fbedc06c3a47c07f246757738f09f3c4642e"
        case .PERSONALIZE_AND_CONFIGLOCK:
            return "4d3099ed8c756720be266501befd96d05a59da43bbb6c7a69563437278917a2e"
        case .CONFIGLOCK:
            return "14e54fe537897257c7c20e8fc2a95f8d3a3eac72989ccb728b248b802282dc8f"
        case .CREATE_DID:
            return "faac3d6a5e47227d69cc40117d6cc3b46e02976e83b3a2e0d5a1d34d015772a0"
        case .UPDATE_DID:
            return "13c21914000973473af82d89e0960d6ed5e6f6492d9db921052a4bb58d748db1"
        case .RESTORE_DID:
            return "24ce59f41d35ef91117b6f2462ab7d76658c7b2ed1304b930714e1a57908bae9"
        case .ISSUE_VC:
            return "6480686ee2b148949220ca4f4d923e082a877aba0209932167519b9fba58b84b"
        case .REMOVE_VC:
            return "4d2fb9764498322c2948a88e5b509ffc6c44e86311e56f0bba9c8c0af6ac1583"
        case .PRESENT_VP:
            return "0b5cf2697ec41aee9007e3bd0f4ba14fb47b89caeb977f79d667ef9abd385082"
        case .LIST_VC:
            return "6f44e4617d75b3d3bfd7135078c193a5995c56e24a566c40e2ae757786f30ed0"
        case .DETAIL_VC:
            return "5799678b95649aaea7c2f08a44515b949a1b5c4725d8ae400d16542810f4790e"
        case .CREATE_DID_AND_ISSUE_VC:
            return "4a72b96d613c161535ad27dbe816fbb7c451d689f1b9d05b8637057796f6e49d"
        case .LIST_VC_AND_PRESENT_VP:
            return "15e67a17d1759faf62b1e33e8a40335a5804df36961deed5c94722d53124c036"
        @unknown default:
            return ""
        }
    }
}
