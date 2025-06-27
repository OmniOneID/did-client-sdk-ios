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


public struct WalletSDKError: Error {
    public var code: String
    public var message: String
}

protocol WalletAPIErrorProtocol {
    func getCodeAndMessage() -> (String, String)
    func getError() -> WalletSDKError
}

extension WalletAPIErrorProtocol {
    func getError() -> WalletSDKError {
        let (code, message) = getCodeAndMessage()
        return .init(code: "MSDKWLT" + code, message: message)
    }
}

// class(2), module(1), error(2)
enum WalletAPIError: WalletAPIErrorProtocol {
    // Common
    case unknown
    case generalFail
    case verifyParameterFail(String)
    case serialzaitionFail
    case deserialzaitionFail
    case createProofFail
    case roleMatchFail
    case verifyCertVCFail
    
    //Token
    case verifyTokenFail
    case createTokenFail
    
    // Lock
    case lockedWallet
    
    // DB
    case insertQueryFail
    case selectQueryFail
    case deleteQueryFail
    

    // Wallet
    case createWalletFail
    case personalizationFail
    case depersonalizationFail
    case saveKeychainFail
    case incorrectPasscode
    case notFoundWalletId
    
    // DID
    case userRegistrationFail
    case userRestoreFail
    case didMatchFail

    // VC
    case issueCredentialFail
    case revokeCredentialFail
    
    // VP
    case submitCredentialFail
    
    public func getCodeAndMessage() -> (String, String) {
        switch self {
            // Common
        case .unknown:
            return ("05000", "Unknown error")
        case .generalFail:
            return ("05001", "General failure")
        case .verifyParameterFail(let message):
            return ("05002", "Failed to verify parameter: \(String(describing: message))")
        case .serialzaitionFail:
            return ("05003", "Failed to serialize")
        case .deserialzaitionFail:
            return ("05004", "Failed to deserialize")
        case .createProofFail:
            return ("05005", "Failed to create proof")
        case .roleMatchFail:
            return ("05006", "Failed to match role")
        case .verifyCertVCFail:
            return ("05007", "Failed to verify certVC")
            
            //Token
        case .verifyTokenFail:
            return ("05010", "Failed to verify token")
        case .createTokenFail:
            return ("05011", "Failed to create wallet token")
            
            // Lock
        case .lockedWallet:
            return ("05020", "Wallet is locked")
            
            // DB
        case .insertQueryFail:
            return ("05030", "Failed to excute insert query")
        case .selectQueryFail:
            return ("05031", "Failed to excute select query")
        case .deleteQueryFail:
            return ("05032", "Failed to excute delete query")
            
            // Wallet
        case .createWalletFail:
            return ("05040", "Failed to create wallet")
        case .personalizationFail:
            return ("05041", "Failed to personalize")
        case .depersonalizationFail:
            return ("05042", "Failed to depersonalize")
        case .saveKeychainFail:
            return ("05043", "Failed to save keychain")
        case .incorrectPasscode:
            return ("05044", "Incorrect passcode")
        case .notFoundWalletId:
            return ("05045", "Wallet ID not found")
            
            // DID
        case .userRegistrationFail:
            return ("05050", "Failed to register user")
        case .userRestoreFail:
            return ("05051", "Failed to restore user")
        case .didMatchFail:
            return ("05052", "Failed to match DID")
            
            // VC
        case .issueCredentialFail:
            return ("05060", "Failed to issue credential")
        case .revokeCredentialFail:
            return ("05061", "Failed to revoke credential")
            
            // VP
        case .submitCredentialFail:
            return ("05070", "Failed to submit credential")
        }
    }
}






