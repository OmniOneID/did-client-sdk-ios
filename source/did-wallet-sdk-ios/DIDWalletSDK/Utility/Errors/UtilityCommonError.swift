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

enum UtilityCommonError: UtilityErrorProtocol {
    enum FunctionCode: String {
        case cryptoUtils    = "00"
        case multibaseUtils = "01"
        case digestUtils    = "02"
    }
    
    case invalidParameter(code: FunctionCode, name: String)     // Parameter delivered from function is invalid

    func getCodeAndMessage() -> (String, String) {
        switch self {
        case .invalidParameter(let code, let name):
            return ("\(code.rawValue)000", "Invalid parameter : \(name)")
        }
    }
}
