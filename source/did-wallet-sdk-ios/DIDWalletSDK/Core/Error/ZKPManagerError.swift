//
/*
 * Copyright 2025 OmniOne.
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

enum ZKPManagerError: WalletCoreErrorProcotol
{
    //Common
    case null(value : String, group : String)
    case negativeDelta
    case bigNumberCompare(lhs : String, rhs : String)
    case inverse(value : String)
    //MasterSecret
    case masterSecretNotFound
    //IssueCredential
    case verifySignatureCorrectnessProof
    //GetCredential
    case notFoundCredentialStored
    case notFoundCredentialByIdentifiers
    //SearchCredentials
    case predicateMustHaveRestictions
    case notFoundAvailableRequestAttribute
    case notFoundAvailablePredicateAttribute
    //Proof
    case invalidReferentKey
    case invalidSelfAttributeReferent
    case invalidAttributeReferentName
    case invalidPredicateReferentName
    case insufficientProofRequestReferents
    case duplicated(detail : String)
    case notFoundSchemaFromProofParam
    case notFoundCredentialDefinitionFromProofParam
    
    func getCodeAndMessage() -> (String, String) {
        switch self
        {
            //ZKPCommon(041xx)
        case .null(let value, let group):
            return ("04100", "Value by key \(value) not found in \(group)")
        case .negativeDelta:
            return ("04101", "Delta must be positive")
        case .bigNumberCompare(let lhs, let rhs):
            return ("04102", "Big Number compare failed \(lhs) and \(rhs)")
        case .inverse(let value):
            return ("04103", "Failed to inverse \(value)")
            //MasterSecret(042xx)
        case .masterSecretNotFound:
            return ("04200", "Master secret not found")
            //IssueCredential(043xx)
        case .verifySignatureCorrectnessProof:
            return ("04300", "Failed to verify signature correctness proof")
            //GetCredential(044xx)
        case .notFoundCredentialStored:
            return ("04400", "Credential not found in storage")
        case .notFoundCredentialByIdentifiers:
            return ("04401", "Credential not found by identifiers in storage")
            //SearchCredentials(045xx)
        case .predicateMustHaveRestictions:
            return ("04500", "Proof request's predicate must have restrictions")
        case .notFoundAvailableRequestAttribute:
            return ("04501", "Not found available request attribute")
        case .notFoundAvailablePredicateAttribute:
            return ("04502", "Not found available predicate attribute")
            //Proof(046xx)
        case .invalidReferentKey:
            return ("04600", "Invalid referent name")
        case .invalidSelfAttributeReferent:
            return ("04601", "Invalid self attribute referent")
        case .invalidAttributeReferentName:
            return ("04602", "Invalid attribute referent name")
        case .invalidPredicateReferentName:
            return ("04603", "Invalid predicate referent name")
        case .insufficientProofRequestReferents:
            return ("04604", "Insufficient referents for proof request")
        case .duplicated(let detail):
            return ("04605", "\(detail) is duplicated")
        case .notFoundSchemaFromProofParam:
            return ("04606", "Not found schema from proof param")
        case .notFoundCredentialDefinitionFromProofParam:
            return ("04607", "Not found credential definition from proof param")
        }
    }
}
