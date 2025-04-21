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

//MARK: KeyManager
/// Access method in Wallet
public enum WalletAccessMethod
{
    case none
    case pin(value : Data)
}

/// Access method in Secure Enclave
public enum SecureEnclaveAccessMethod : Int, Codable
{
    case none       = 0
    case currentSet = 1
    case any        = 2
}

/// Indicate key storage
public enum StorageOption : Int, Codable
{
    case wallet         = 0
    case secureEnclave  = 1
}

/// Indicate key storage and its access method
public enum KeyAccessMethod : Int, Codable
{
    case walletNone = 0
    case walletPin  = 1
    case secureEnclaveNone       = 8
    case secureEnclaveCurrentSet = 9
    case secureEnclaveAny        = 10
}


