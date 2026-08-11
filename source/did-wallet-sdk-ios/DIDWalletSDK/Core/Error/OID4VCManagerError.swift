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
    case invalidJWS(detail: String)
    case invalidMdoc(detail: String)
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
    case missingJWSHeaderKey
    case mdocDigestMismatch(elementIdentifier: String)
    case mdocOutsideValidityPeriod
    case deviceKeyMismatch
    //OID4VP(055xx)
    case unsupportedPresentationFormat(format: String)
    case invalidDCQLQuery(detail: String)
    case noMatchedCredentials
    case credentialSetsNotSatisfied(detail: String)
    case credentialNotFound
    case holderKeyNotFound
    case missingVerifierEncryptionKey
    case unsupportedResponseEncryption(detail: String)
    case invalidSelectedCredentials(detail: String)
    case unsupportedResponseMode(mode: String)


    func getCodeAndMessage() -> (String, String) {
        switch self
        {
        case .unsupportedId(let id):
            return ("05100", "Unsupported in : \(id)")
        case .unsupportedFormat(let format):
            return ("05101", "Unsupported format : \(format)")
        case .invalidJWS(let detail):
            return ("05102", "Invalid JWS : \(detail)")
        case .invalidMdoc(let detail):
            return ("05103", "Invalid mdoc : \(detail)")
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
        case .missingJWSHeaderKey:
            return ("05402", "No 'jwk' in the JWS header to verify with")
        case .mdocDigestMismatch(let elementIdentifier):
            return ("05403", "Element \(elementIdentifier) does not match its digest in the MSO")
        case .mdocOutsideValidityPeriod:
            return ("05404", "The mdoc is outside its validity period")
        case .deviceKeyMismatch:
            return ("05405", "The mdoc is bound to a key this wallet does not hold")
        case .unsupportedPresentationFormat(let format):
            return ("05500", "Presentation for format \(format) is not supported")
        case .invalidDCQLQuery(let detail):
            return ("05501", "Invalid DCQL query: \(detail)")
        case .noMatchedCredentials:
            return ("05502", "No credentials matched the request")
        case .credentialSetsNotSatisfied(let detail):
            return ("05503", "Required credential_sets not satisfied: \(detail)")
        case .credentialNotFound:
            return ("05504", "Matched credential not found")
        case .holderKeyNotFound:
            return ("05505", "Holder signing key not found")
        case .missingVerifierEncryptionKey:
            return ("05506", "No verifier encryption key found in client_metadata for direct_post.jwt")
        case .unsupportedResponseEncryption(let detail):
            return ("05507", "Unsupported response encryption (\(detail))")
        case .invalidSelectedCredentials(let detail):
            return ("05508", "Invalid selected credentials: \(detail)")
        case .unsupportedResponseMode(let mode):
            return ("05509", "Unsupported response_mode : \(mode)")
        }
    }
}
