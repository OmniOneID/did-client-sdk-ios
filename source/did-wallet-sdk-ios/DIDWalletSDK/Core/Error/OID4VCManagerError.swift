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
    //Common(061xx)
    case unsupportedId(id: String)
    case unsupportedFormat(format: String)
    case invalidJWS(detail: String)
    case invalidMdoc(detail: String)
    //JWE(062xx)
    case invalidJWE
    case unsupportedAlgorithmJWE
    case unsupportedJWEKey
    case invalidSealedBox
    case authenticationFailed
    case failedToEncrypt
    case keyDerivationFailed
    case invalidKDFInput
    //OID4VCI(063xx)
    case invalidCredentialResponse
    //verify(064xx)
    case notFoundKid
    case failedToVerifySignature
    case missingJWSHeaderKey
    case mdocDigestMismatch(elementIdentifier: String)
    case mdocOutsideValidityPeriod
    case deviceKeyMismatch
    //OID4VP(065xx)
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
    //Proximity, ISO/IEC 18013-5(066xx)
    //  0660x: shown to the user, 0661x: the app's bug, 0662x: bytes handed to us are wrong
    case noMatchedMdocDocuments
    case emptyMdocSelection
    case invalidSelectedMdocDocuments(detail: String)
    case emptyMdocClaimCodes
    case duplicateSelectedMdocDocument
    case duplicateMdocClaimCode
    case invalidDeviceRequest(detail: String)
    case invalidSessionTranscript(detail: String)


    func getCodeAndMessage() -> (String, String) {
        switch self
        {
        case .unsupportedId(let id):
            return ("06100", "Unsupported in : \(id)")
        case .unsupportedFormat(let format):
            return ("06101", "Unsupported format : \(format)")
        case .invalidJWS(let detail):
            return ("06102", "Invalid JWS : \(detail)")
        case .invalidMdoc(let detail):
            return ("06103", "Invalid mdoc : \(detail)")
        case .invalidJWE:
            return ("06210", "Invalid JWE")
        case .unsupportedAlgorithmJWE:
            return ("06211", "Unsupported algorithm for JWE")
        case .unsupportedJWEKey:
            return ("06212", "Unsupported JWE key")
        case .invalidSealedBox:
            return ("06213", "invalid SealedBox")
        case .authenticationFailed:
            return ("06214", "Authentication failed")
        case .failedToEncrypt:
            return ("06215", "Failed to encrypt")
        case .keyDerivationFailed:
            return ("06216", "Key derivation failed")
        case .invalidKDFInput:
            return ("06217", "Invalid KDF input")
        case .invalidCredentialResponse:
            return ("06300", "Invalid credential response")
        case .notFoundKid:
            return ("06400", "Not found kid for verify")
        case .failedToVerifySignature:
            return ("06401", "Failed to verify signature")
        case .missingJWSHeaderKey:
            return ("06402", "No 'jwk' in the JWS header to verify with")
        case .mdocDigestMismatch(let elementIdentifier):
            return ("06403", "Element \(elementIdentifier) does not match its digest in the MSO")
        case .mdocOutsideValidityPeriod:
            return ("06404", "The mdoc is outside its validity period")
        case .deviceKeyMismatch:
            return ("06405", "The mdoc is bound to a key this wallet does not hold")
        case .unsupportedPresentationFormat(let format):
            return ("06500", "Presentation for format \(format) is not supported")
        case .invalidDCQLQuery(let detail):
            return ("06501", "Invalid DCQL query: \(detail)")
        case .noMatchedCredentials:
            return ("06502", "No credentials matched the request")
        case .credentialSetsNotSatisfied(let detail):
            return ("06503", "Required credential_sets not satisfied: \(detail)")
        case .credentialNotFound:
            return ("06504", "Matched credential not found")
        case .holderKeyNotFound:
            return ("06505", "Holder signing key not found")
        case .missingVerifierEncryptionKey:
            return ("06506", "No verifier encryption key found in client_metadata for direct_post.jwt")
        case .unsupportedResponseEncryption(let detail):
            return ("06507", "Unsupported response encryption (\(detail))")
        case .invalidSelectedCredentials(let detail):
            return ("06508", "Invalid selected credentials: \(detail)")
        case .unsupportedResponseMode(let mode):
            return ("06509", "Unsupported response_mode : \(mode)")

        case .noMatchedMdocDocuments:
            return ("06600", "No stored document can answer any docRequest")
        case .emptyMdocSelection:
            return ("06610", "No document was selected")
        case .invalidSelectedMdocDocuments(let detail):
            return ("06611", "Invalid selected mdoc documents: \(detail)")
        case .emptyMdocClaimCodes:
            return ("06612", "A selected document carries no claim code")
        case .duplicateSelectedMdocDocument:
            return ("06613", "The same document is selected twice for the same docRequest")
        case .duplicateMdocClaimCode:
            return ("06614", "A selected document names the same claim code twice")
        case .invalidDeviceRequest(let detail):
            return ("06620", "Invalid DeviceRequest: \(detail)")
        case .invalidSessionTranscript(let detail):
            return ("06621", "Invalid SessionTranscript: \(detail)")
        }
    }
}
