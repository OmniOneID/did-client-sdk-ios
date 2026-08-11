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

/// A string-keyed map that keeps the order its entries were inserted in.
///
/// Some values the SDK exchanges are ordered as a matter of correctness rather than presentation:
/// the ZKP key-correctness challenge is a hash over the attribute values *in order*, so a map whose
/// iteration order came from hashing would verify or fail depending on the run. A Swift
/// `Dictionary` cannot carry that, and the order-preserving map the implementation uses internally
/// belongs to a third-party module — putting that type in a public signature would drag the module
/// into this SDK's generated interface and force every consuming app to declare and pin it, whether
/// or not the app ever touches the value.
///
/// So the public surface uses this type, and the third-party map stays an implementation detail.
public struct OrderedStringMap<Value>
{
    /// The keys, in insertion order. This is the order everything else here iterates in.
    public private(set) var keys: [String]

    private var storage: [String: Value]

    public init()
    {
        self.keys = []
        self.storage = [:]
    }

    /// Builds a map from key-value pairs, keeping the order given. A repeated key keeps its first
    /// position and takes the later value, matching how the subscript behaves.
    public init(_ pairs: [(String, Value)])
    {
        self.init()
        for (key, value) in pairs
        {
            self[key] = value
        }
    }

    /// Reads or writes a value. A new key is appended; an existing key keeps its position, and
    /// assigning `nil` removes it.
    public subscript(key: String) -> Value?
    {
        get
        {
            return storage[key]
        }
        set
        {
            guard let newValue = newValue
            else
            {
                if storage.removeValue(forKey: key) != nil
                {
                    keys.removeAll { $0 == key }
                }
                return
            }
            if storage.updateValue(newValue, forKey: key) == nil
            {
                keys.append(key)
            }
        }
    }

    /// The values, in key order.
    public var values: [Value]
    {
        return keys.compactMap { storage[$0] }
    }

    public var count: Int { keys.count }
    public var isEmpty: Bool { keys.isEmpty }

    /// Transforms every value, keeping the order — the transformed map is as ordered as its source,
    /// which is what lets a caller map to another representation before hashing.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> OrderedStringMap<T>
    {
        var result = OrderedStringMap<T>()
        for key in keys
        {
            guard let value = storage[key] else { continue }
            result[key] = try transform(value)
        }
        return result
    }
}

extension OrderedStringMap: Sequence
{
    public func makeIterator() -> AnyIterator<(key: String, value: Value)>
    {
        var remaining = keys[...]
        return AnyIterator
        {
            while let key = remaining.popFirst()
            {
                if let value = self.storage[key]
                {
                    return (key: key, value: value)
                }
            }
            return nil
        }
    }
}

extension OrderedStringMap: ExpressibleByDictionaryLiteral
{
    /// The literal's written order is the map's order.
    public init(dictionaryLiteral elements: (String, Value)...)
    {
        self.init(elements)
    }
}

extension OrderedStringMap: Equatable where Value: Equatable
{
    /// Two maps are equal when they hold the same entries in the same order — order is part of the
    /// value here, not an incidental detail of storage.
    public static func == (lhs: OrderedStringMap<Value>, rhs: OrderedStringMap<Value>) -> Bool
    {
        guard lhs.keys == rhs.keys else { return false }
        return lhs.keys.allSatisfy { lhs.storage[$0] == rhs.storage[$0] }
    }
}

extension OrderedStringMap: Sendable where Value: Sendable {}
