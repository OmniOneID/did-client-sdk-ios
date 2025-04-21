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

class WalletLockManagerMock: WalletLockManagerImpl {
    
    // wallet status
    internal static var isLock: Bool = true
    
    func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool {
        if isLock {
            let finalEncCek = try KeyChainWrapper().saveKeyChain(passcode: passcode)
            
            MockData.shared.userMock.setFinalEncKey(MultibaseUtils.encode(type: MultibaseType.base58BTC, data: finalEncCek))
            WalletLockManagerMock.isLock = false
        } else {
            MockData.shared.userMock.setFinalEncKey("")
        }
        return true
    }
    
    func isRegLock() throws -> Bool {
        let user = MockData.shared.getUserMock()
        WalletLogger.shared.debug("user.finalEncKey: \(user.finalEncKey)")
        
        if user.finalEncKey != "" {
            return true
        }
        
        return false
    }
    
    func authenticateLock(passcode: String) throws -> Data? {
        let finalEncCek = try MultibaseUtils.decode(encoded: MockData.shared.getUserMock().finalEncKey)
        let result = try KeyChainWrapper().matching(passcode: passcode, finalEncCek: finalEncCek)
        WalletLockManagerMock.isLock = false
        return result
    }
}
