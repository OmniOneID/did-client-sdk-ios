//
/*
 * Copyright 2026 OmniOne.
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

enum OID4VCManagerError: WalletCoreErrorProcotol
{
    //Common(051xx)
    case unsupportedId(id: String)
    case unsupportedFormat(format: String)
    //JWE(052xx)
    case invalidJWE
    case unsupportedAlgorithmJWE
    case unsupportedJWEKey
    case invalidSealedBox
    case authenticationFailed
    case failedToEncrypt
    case keyDerivationFailed
    case invalidKDFInput
    //OID4VCI(053xx)
    case invalidCredentialResponse
    //verify(054xx)
    case notFoundKid
    case failedToVerifySignature
    
    
    func getCodeAndMessage() -> (String, String) {
        switch self
        {
        case .unsupportedId(let id):
            return ("05100", "Unsupported in : \(id)")
        case .unsupportedFormat(let format):
            return ("05101", "Unsupported format : \(format)")
        case .invalidJWE:
            return ("05210", "Invalid JWE")
        case .unsupportedAlgorithmJWE:
            return ("05211", "Unsupported algorithm for JWE")
        case .unsupportedJWEKey:
            return ("05212", "Unsupported JWE key")
        case .invalidSealedBox:
            return ("05213", "invalid SealedBox")
        case .authenticationFailed:
            return ("05214", "Authentication failed")
        case .failedToEncrypt:
            return ("05215", "Failed to encrypt")
        case .keyDerivationFailed:
            return ("05216", "Key derivation failed")
        case .invalidKDFInput:
            return ("05217", "Invalid KDF input")
        case .invalidCredentialResponse:
            return ("05300", "Invalid credential response")
        case .notFoundKid:
            return ("05400", "Not found kid for verify")
        case .failedToVerifySignature:
            return ("05401", "Failed to verify signature")
        }
    }
}
