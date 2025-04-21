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

public enum WalletTokenPurposeEnum: Int, Jsonable {
    case PERSONALIZED               = 1
    case DEPERSONALIZED             = 2
    case PERSONALIZE_AND_CONFIGLOCK = 3
    case CONFIGLOCK                 = 4
    case CREATE_DID                 = 5
    case UPDATE_DID                 = 6
    case RESTORE_DID                = 7
    case ISSUE_VC                   = 8
    case REMOVE_VC                  = 9
    case PRESENT_VP                 = 10
    case LIST_VC                    = 11
    case DETAIL_VC                  = 12
    case CREATE_DID_AND_ISSUE_VC    = 13
    case LIST_VC_AND_PRESENT_VP     = 14
    
    public var value: String {
        switch self {
        case .PERSONALIZED:
            return "Personalize"
        case .DEPERSONALIZED:
            return "Depersonalize"
        case .PERSONALIZE_AND_CONFIGLOCK:
            return "PersonalizeAndConfigLock"
        case .CONFIGLOCK:
            return "ConfigLock"
        case .CREATE_DID:
            return "CreateDid"
        case .UPDATE_DID:
            return "UpdateDid"
        case .RESTORE_DID:
            return "RestoreDid"
        case .ISSUE_VC:
            return "IssueVc"
        case .REMOVE_VC:
            return "RemoveVc"
        case .PRESENT_VP:
            return "PresentVp"
        case .LIST_VC:
            return "ListVc"
        case .DETAIL_VC:
            return "DetailVc"
        case .CREATE_DID_AND_ISSUE_VC:
            return "CreateDidAndIssueVc"
        case .LIST_VC_AND_PRESENT_VP:
            return "ListVcAndPresentVp"
        }
    }
}

public class WalletTokenPurpose {
    public var purposeCode: WalletTokenPurposeEnum
    public var description: String?
    
    public init(purpose: WalletTokenPurposeEnum) {
        self.purposeCode = purpose
    }
    
    public init(purpose: WalletTokenPurposeEnum, description: String? = nil) {
        self.purposeCode = purpose
        self.description = description
    }
}
