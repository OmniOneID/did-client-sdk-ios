/*
 * Copyright 2024-2026 OmniOne.
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

extension Encodable {
    func equals<T>(other: T) throws -> Bool where T: Encodable {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        let lh = try jsonEncoder.encode(self).sha256()
        let rh = try jsonEncoder.encode(other).sha256()

        return lh == rh
    }
}

extension Jsonable
{
    func toFormData() throws -> Data {
        let data = try self.toJsonData()
        let json = try JSONSerialization.jsonObject(with: data)

        guard let dict = json as? [String: Any] else {
            //TODO: Error
            throw NSError(domain: "FormEncoding", code: -1)
        }

        let body = dict.map { key, value -> String in
            let stringValue: String

            if JSONSerialization.isValidJSONObject(value),
               let data = try? JSONSerialization.data(withJSONObject: value),
               let jsonString = String(data: data, encoding: .utf8) {
                stringValue = jsonString
            } else {
                stringValue = "\(value)"
            }

            return "\(key.formURLEncoded())=\(stringValue.formURLEncoded())"
        }
        .joined(separator: "&")

        return body.data(using: .utf8) ?? Data()
    }
}
