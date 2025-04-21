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

enum MultibaseUtilsError: UtilityErrorProtocol {
    // Decode (011xx)
    case failToDecode
    
    // ETC (019xx)
    case unsupportedEncodingType(prefix: String)
    
    func getCodeAndMessage() -> (String, String) {
        switch self {
            // Decode (011xx)
        case .failToDecode:
            return ("01100", "Fail to decode")
            // ETC (019xx)
        case .unsupportedEncodingType(let prefix):
            return ("01900", "Unsupported encoding type. prefix : \(prefix)")
        }
    }
}

