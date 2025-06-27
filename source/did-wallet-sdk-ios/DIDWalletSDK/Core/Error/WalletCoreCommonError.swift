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

import Foundation

enum WalletCoreCommonError: WalletCoreErrorProcotol {
    enum FunctionCode: String {
        case keyManager      = "00"
        case didManager      = "01"
        case vcManager       = "02"
        case secureEncryptor = "03"
        case zkpManager      = "04"

        case storageMaanger  = "10"
        case signable        = "11"
        case secureEnclave   = "12"
    }
    
    case invalidParameter(code: FunctionCode, name: String)     // Parameter delivered from function is invalid
    case duplicateParameter(code: FunctionCode, name: String)   // Parameter delivered from function has duplicated
    case failToDecode(code: FunctionCode, name: String)         // Fail to decode some data

    func getCodeAndMessage() -> (String, String) {
        switch self {
        case .invalidParameter(let code, let name):
            return ("\(code.rawValue)000", "Invalid parameter : \(name)")
        case .duplicateParameter(let code, let name):
            return ("\(code.rawValue)001", "Duplicate parameter : \(name)")
        case .failToDecode(let code, let name):
            return ("\(code.rawValue)002", "Fail to decode : \(name)")
        }
    }
}
