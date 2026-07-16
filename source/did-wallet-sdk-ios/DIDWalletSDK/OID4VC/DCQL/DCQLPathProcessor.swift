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
import CryptoKit

public enum DCQLPathProcessor {
    public static func isValidPath(_ path: [DCQLPathElement]?) -> Bool {
        guard let path = path, !path.isEmpty else { return false }
        return true
    }
}



public enum SimpleJWTDecoder {
    public struct SimpleJWT {
        public let header: [String: Any]
        public let payload: [String: Any]
    }

    public enum JWTError: Error {
        case invalidFormat
        case invalidBase64
        case invalidJSON
    }

    public static func parse(_ jwt: String) throws -> SimpleJWT {
        let parts = jwt.split(separator: ".").map(String.init)
        guard parts.count >= 2 else { throw JWTError.invalidFormat }

        guard let headerData = parts[0].base64URLDecoded,
              let payloadData = parts[1].base64URLDecoded
        else
        {
            throw JWTError.invalidBase64
        }

        guard
            let headerObj = try JSONSerialization.jsonObject(with: headerData, options: []) as? [String: Any],
            let payloadObj = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any]
        else {
            throw JWTError.invalidJSON
        }

        return SimpleJWT(header: headerObj, payload: payloadObj)
    }
}
