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

enum VCManagerError: WalletCoreErrorProcotol {
    case noClaimCodeInCredentialForPresentation(code: String)     // No claim code in credential(VC) for presentation
    
    func getCodeAndMessage() -> (String, String) {
        switch self {
        case .noClaimCodeInCredentialForPresentation(let code):
            return ("02100", "No claim code in credential(VC) for presentation. Not found code(s) : \(code)")
        }
    }
}
