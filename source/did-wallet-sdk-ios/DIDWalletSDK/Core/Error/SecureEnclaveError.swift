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

enum SecureEnclaveError : WalletCoreErrorProcotol
{
    case createKey(detail : Error)
    case copyPublicKey
    case publicKeyRepresentation(detail : Error)
    case notExistKey
    case failToDeleteKey
    case createSignature(detail : Error)
    case createEncryptedData(detail : Error)
    case createDecryptedData(detail : Error)
    
    func getCodeAndMessage() -> (String, String) {
        switch self 
        {
            //KeyPair(121xx)
        case .createKey(let detail):
            return ("12100", "Failed to create secure key : \(detail)")
        case .copyPublicKey:
            return ("12101", "Failed to copy public key")
        case .publicKeyRepresentation(let detail):
            return ("12102", "Failed to get public key representation : \(detail)")
        case .notExistKey:
            return ("12103", "Cannot find secure key by given conditions")
        case .failToDeleteKey:
            return ("12104", "Failed to delete secure key")
            //Signature(122xx)
        case .createSignature(let detail):
            return ("12200", "Signing failed : \(detail)")
            //Encryption(123xx)
        case .createEncryptedData(let detail):
            return ("12300", "Cannot create encrypted data : \(detail)")
        case .createDecryptedData(let detail):
            return ("12301", "Cannot create decrypted data : \(detail)")
        }
    }
}
