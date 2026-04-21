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
    public static func isIndexBasedPath(_ path: [DCQLPathElement]?) -> Bool {
        guard let path = path, !path.isEmpty else { return false }
        if path.count != 1 { return false }
        if case .index = path[0] { return true }
        return false
    }

    public static func extractIndex(_ path: [DCQLPathElement]?) -> Int? {
        guard isIndexBasedPath(path), let p = path else { return nil }
        if case .index(let i) = p[0] { return i }
        return nil
    }

    public static func pathToClaimName(_ path: [DCQLPathElement]?) -> String? {
        guard let path = path, !path.isEmpty else { return nil }
        var parts: [String] = []
        for el in path {
            switch el {
            case .wildcard: parts.append("*")
            case .key(let s): parts.append(s)
            case .index(let i): parts.append(String(i))
            }
        }
        return parts.joined(separator: ".")
    }

    public static func isValidPath(_ path: [DCQLPathElement]?) -> Bool {
        guard let path = path, !path.isEmpty else { return false }
        return true
    }

    /// Navigate using Foundation JSON (Dictionary/Array) or AnyJSON
    public static func navigatePath(root: Any?, path: [DCQLPathElement]?) -> Any? {
        guard let root = root, let path = path, !path.isEmpty else { return nil }
        let foundationRoot: Any
        if let j = root as? AnyJSON { foundationRoot = j.toFoundation() }
        else { foundationRoot = root }
        return navigatePathRecursive(current: foundationRoot, path: path, index: 0)
    }

    private static func navigatePathRecursive(current: Any, path: [DCQLPathElement], index: Int) -> Any? {
        if index >= path.count { return current }

        let el = path[index]

        switch el {
        case .wildcard:
            guard let list = current as? [Any] else { return nil }
            var results: [Any] = []
            for item in list {
                if let r = navigatePathRecursive(current: item, path: path, index: index + 1) {
                    if let rList = r as? [Any] { results.append(contentsOf: rList) }
                    else { results.append(r) }
                }
            }
            return results.isEmpty ? nil : results

        case .index(let idx):
            guard let list = current as? [Any] else { return nil }
            guard idx >= 0, idx < list.count else { return nil }
            return navigatePathRecursive(current: list[idx], path: path, index: index + 1)

        case .key(let key):
            guard let dict = current as? [String: Any] else { return nil }
            guard let next = dict[key] else { return nil }
            return navigatePathRecursive(current: next, path: path, index: index + 1)
        }
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
