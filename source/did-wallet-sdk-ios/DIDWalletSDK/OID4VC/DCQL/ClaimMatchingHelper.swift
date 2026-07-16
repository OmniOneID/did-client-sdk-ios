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

/// Shared JSON path-based claim matching + condition evaluation, used by the JSON-based credential
/// adapters (SD-JWT, opendid_vc). Operates on a Foundation-typed `[String: Any]` claim tree.
public enum ClaimMatchingHelper {

    /// Returns matching claim names for the given claim queries by navigating `allClaims` paths.
    /// If `claimQueries` is nil/empty, returns all top-level claim keys.
    public static func extractMatchingClaimsByPath(allClaims: [String: Any],
                                                   claimQueries: [DCQLQuery.ClaimQuery]?) -> Set<String> {
        var matchingClaims: Set<String> = []

        guard let claimQueries = claimQueries, !claimQueries.isEmpty else {
            matchingClaims.formUnion(allClaims.keys)
            return matchingClaims
        }

        for claimQuery in claimQueries {
            guard let path = claimQuery.path, !path.isEmpty else { continue }
            processPathAndCollectClaims(allClaims: allClaims,
                                        path: path,
                                        claimQuery: claimQuery,
                                        matchingClaims: &matchingClaims)
        }
        return matchingClaims
    }

    /// Evaluates a claim query's value conditions (values/value/min/max) against an actual value.
    public static func meetsConditions(claimQuery: DCQLQuery.ClaimQuery, actualValue: Any) -> Bool {
        let actualJSON = AnyJSON.fromFoundation(actualValue) ?? .null

        if let values = claimQuery.values, !values.isEmpty {
            if !values.contains(actualJSON) { return false }
        }
        if let v = claimQuery.value {
            if actualJSON != v { return false }
        }
        if let min = claimQuery.min, !checkMinCondition(actualValue: actualJSON, minValue: min) {
            return false
        }
        if let max = claimQuery.max, !checkMaxCondition(actualValue: actualJSON, maxValue: max) {
            return false
        }
        return true
    }

    // MARK: - Private

    private static func processPathAndCollectClaims(allClaims: [String: Any],
                                                    path: [DCQLPathElement],
                                                    claimQuery: DCQLQuery.ClaimQuery,
                                                    matchingClaims: inout Set<String>) {
        guard case .key(let topLevel) = path[0] else { return }
        guard let rootValue = allClaims[topLevel] else { return }

        if path.count == 1 {
            if meetsConditions(claimQuery: claimQuery, actualValue: rootValue) {
                matchingClaims.insert(topLevel)
            }
            return
        }

        let remaining = Array(path.dropFirst())
        collectMatchingValuesFromPath(current: rootValue,
                                      remainingPath: remaining,
                                      claimQuery: claimQuery,
                                      claimNamePrefix: topLevel,
                                      matchingClaims: &matchingClaims)
    }

    private static func collectMatchingValuesFromPath(current: Any,
                                                      remainingPath: [DCQLPathElement],
                                                      claimQuery: DCQLQuery.ClaimQuery,
                                                      claimNamePrefix: String,
                                                      matchingClaims: inout Set<String>) {
        if remainingPath.isEmpty {
            if meetsConditions(claimQuery: claimQuery, actualValue: current) {
                matchingClaims.insert(claimNamePrefix)
            }
            return
        }

        let next = remainingPath[0]
        let nextRemaining = Array(remainingPath.dropFirst())

        switch next {
        case .wildcard:
            guard let list = current as? [Any] else { return }
            for i in 0..<list.count {
                collectMatchingValuesFromPath(current: list[i],
                                              remainingPath: nextRemaining,
                                              claimQuery: claimQuery,
                                              claimNamePrefix: "\(claimNamePrefix)[\(i)]",
                                              matchingClaims: &matchingClaims)
            }
        case .index(let idx):
            guard let list = current as? [Any] else { return }
            guard idx >= 0, idx < list.count else { return }
            collectMatchingValuesFromPath(current: list[idx],
                                          remainingPath: nextRemaining,
                                          claimQuery: claimQuery,
                                          claimNamePrefix: "\(claimNamePrefix)[\(idx)]",
                                          matchingClaims: &matchingClaims)
        case .key(let key):
            guard let dict = current as? [String: Any] else { return }
            guard let nextValue = dict[key] else { return }
            collectMatchingValuesFromPath(current: nextValue,
                                          remainingPath: nextRemaining,
                                          claimQuery: claimQuery,
                                          claimNamePrefix: "\(claimNamePrefix).\(key)",
                                          matchingClaims: &matchingClaims)
        }
    }

    private static func checkMinCondition(actualValue: AnyJSON, minValue: AnyJSON) -> Bool {
        switch (actualValue, minValue) {
        case (.number(let a), .number(let m)): return a >= m
        case (.string(let a), .string(let m)): return a.compare(m) != .orderedAscending
        // A `min` bound was requested but the actual value is not comparable to it (wrong/missing
        // type). An unsatisfiable constraint must exclude the credential, not silently match.
        default: return false
        }
    }

    private static func checkMaxCondition(actualValue: AnyJSON, maxValue: AnyJSON) -> Bool {
        switch (actualValue, maxValue) {
        case (.number(let a), .number(let m)): return a <= m
        case (.string(let a), .string(let m)): return a.compare(m) != .orderedDescending
        // A `max` bound was requested but the actual value is not comparable to it (wrong/missing
        // type). An unsatisfiable constraint must exclude the credential, not silently match.
        default: return false
        }
    }
}
