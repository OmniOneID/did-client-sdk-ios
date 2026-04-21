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

extension JSON
{
    var jsonToAny : Any {
        switch self {
        case .string(let s): return s
        case .number(let n):
            if let i = Int(n) { return i }
            if let d = Double(n) { return d }
            return n
        case .bool(let b): return b
        case .object(let keyValues):
            var dict: [String: Any] = [:]
            for (key, value) in keyValues {
                dict[key] = value.jsonToAny
            }
            return dict
        case .array(let array):
            return array.map { $0.jsonToAny }
        case .null:
            return NSNull()
        }
    }
}
