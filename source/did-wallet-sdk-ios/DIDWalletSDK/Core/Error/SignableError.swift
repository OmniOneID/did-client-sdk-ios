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

enum SignableError : WalletCoreErrorProcotol
{
    case invalidPublicKey
    case invalidPrivateKey
    case notDerivedKeyFromPrivateKey
    case failToConvertCompactRepresentation(detail : Error)
    case createSignature(detail : Error)
    case verifySignatureFailed(detail : Error)
    
    func getCodeAndMessage() -> (String, String) 
    {
        switch self
        {
            //KeyPair(111xx)
        case .invalidPublicKey:
            return ("11100", "Not proper public key format")
        case .invalidPrivateKey:
            return ("11101", "Not proper private key format")
        case .notDerivedKeyFromPrivateKey:
            return ("11102", "Private and public keys are not pair")
            //Signature(112xx)
        case .failToConvertCompactRepresentation(let detail):
            return ("11200", "Converting failed to compact representation : \(detail)")
        case .createSignature(let detail):
            return ("11201", "Signing failed : \(detail)")
        case .verifySignatureFailed(let detail):
            return ("11202", "Failed to verify signature : \(detail)")
        }
    }
}
