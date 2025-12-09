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

import Foundation


class WalletLockManager: WalletLockManagerImpl {
    
    // wallet status
    internal static var isLock: Bool = true
    
    init() {
        
    }
    
    // true로 설정 했을때
    @discardableResult
    func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool {
        if isLock {
            // Contents Encrypting Key
            let cek = try CryptoUtils.generateNonce(size: 32)
            let finalEncCek = try KeyChainWrapper.saveKeyChain(cek: cek,
                                                               passcode: passcode)
            WalletLogger.shared.debug("updateUser result \(try CoreDataManager.shared.updateUser(finalEncKey: MultibaseUtils.encode(type: MultibaseType.base58BTC, data: finalEncCek)))")
            WalletLockManager.isLock = false
        } else {
            try CoreDataManager.shared.updateUser(finalEncKey: "")
        }
        return true
    }
    
    
    // wallet type
    @discardableResult
    func isRegLock() throws -> Bool {
        if let user = try CoreDataManager.shared.selectUser() {
            WalletLogger.shared.debug("user.finalEncKey: \(user.finalEncKey)")
            if user.finalEncKey != "" {
                return true
            }
        }
        return false
    }
    @discardableResult
    func authenticateLock(passcode: String) throws -> Data? {
        let finalEncCek = try MultibaseUtils.decode(encoded: CoreDataManager.shared.selectUser()!.finalEncKey)
        let result = try KeyChainWrapper.matching(passcode: passcode,
                                                  finalEncCek: finalEncCek)
        
        WalletLockManager.isLock = (result == nil)
        return result
    }
    
    func changeLock(oldPasscode: String, newPasscode: String) throws
    {
        if try !isRegLock()
        {
            throw WalletAPIError.notLockType.getError()
        }
        
        if oldPasscode == newPasscode
        {
            throw WalletAPIError.newPasscodeEqualsOldPasscode.getError()
        }
        
        guard let cek = try authenticateLock(passcode: oldPasscode)
        else
        {
            throw WalletAPIError.incorrectPasscode.getError()
        }
        
        let finalEncCek = try KeyChainWrapper.saveKeyChain(cek: cek,
                                                           passcode: newPasscode)
        
        WalletLogger.shared.debug("updateUser result \(try CoreDataManager.shared.updateUser(finalEncKey: MultibaseUtils.encode(type: MultibaseType.base58BTC, data: finalEncCek)))")
    }
}
