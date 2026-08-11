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


import XCTest
@testable import DIDWalletSDK

/// `OrderedStringMap` carries an order that is part of the value, not a storage detail: the ZKP
/// key-correctness challenge hashes `CredentialPrimaryPublicKey.r`'s values in order, so a map that
/// reordered its entries would make a valid credential fail verification.
final class OrderedStringMapTests: XCTestCase {

    // MARK: - The map itself

    func testKeepsInsertionOrder() {
        var map = OrderedStringMap<Int>()
        map["master_secret"] = 1
        map["age"] = 2
        map["name"] = 3

        XCTAssertEqual(map.keys, ["master_secret", "age", "name"])
        XCTAssertEqual(map.values, [1, 2, 3])
        XCTAssertEqual(map.map { $0.key }, ["master_secret", "age", "name"])
    }

    /// Overwriting is not reinsertion — a value that arrives twice must not jump to the end, or the
    /// hash over the map would depend on how the value was built.
    func testOverwritingAValueKeepsItsPosition() {
        var map: OrderedStringMap<Int> = ["a": 1, "b": 2, "c": 3]
        map["a"] = 99

        XCTAssertEqual(map.keys, ["a", "b", "c"])
        XCTAssertEqual(map["a"], 99)
    }

    func testRemovingAKeyDropsItFromTheOrder() {
        var map: OrderedStringMap<Int> = ["a": 1, "b": 2, "c": 3]
        map["b"] = nil

        XCTAssertEqual(map.keys, ["a", "c"])
        XCTAssertNil(map["b"])
        XCTAssertEqual(map.count, 2)
    }

    func testMapValuesPreservesOrder() {
        let map: OrderedStringMap<Int> = ["z": 1, "a": 2, "m": 3]

        let doubled = map.mapValues { $0 * 2 }

        XCTAssertEqual(doubled.keys, ["z", "a", "m"])
        XCTAssertEqual(doubled.values, [2, 4, 6])
    }

    /// Order is part of equality: two maps holding the same entries in a different order would hash
    /// differently, so they are not the same value.
    func testEqualityIsOrderSensitive() {
        let one: OrderedStringMap<Int> = ["a": 1, "b": 2]
        let same: OrderedStringMap<Int> = ["a": 1, "b": 2]
        let reordered: OrderedStringMap<Int> = ["b": 2, "a": 1]

        XCTAssertEqual(one, same)
        XCTAssertNotEqual(one, reordered)
    }

    // MARK: - Through the model

    private let json = """
    {
      "id": "did:omn:issuer?versionId=1",
      "schemaId": "did:omn:issuer?versionId=1#schema",
      "ver": "1.0",
      "type": "CL",
      "value": {
        "primary": {
          "n": "123",
          "z": "456",
          "s": "789",
          "r": {
            "master_secret": "111",
            "birth_date": "222",
            "address": "333"
          },
          "rctxt": "999"
        }
      },
      "tag": "tag"
    }
    """

    /// The issuer's key order has to survive decoding: `r` is hashed in order, and JSON objects are
    /// unordered by default — which is why the model is `OrderedJson` and decodes through RNJSON.
    func testDecodingKeepsTheIssuersKeyOrder() throws {
        let definition = try ZKPCredentialDefinition(from: json)

        XCTAssertEqual(definition.value.primary.r.keys, ["master_secret", "birth_date", "address"])
        XCTAssertEqual(definition.value.primary.r["birth_date"]?.description, "222")
    }

    /// A credential definition that is stored and read back must hash the same way, so re-encoding
    /// has to write `r` in the order it was received — not sorted, not rearranged.
    func testReEncodingWritesTheSameKeyOrder() throws {
        let definition = try ZKPCredentialDefinition(from: json)

        let encoded = try definition.toJson()
        let masterSecret = try XCTUnwrap(encoded.range(of: "master_secret"))
        let birthDate = try XCTUnwrap(encoded.range(of: "birth_date"))
        let address = try XCTUnwrap(encoded.range(of: "address"))

        XCTAssertTrue(masterSecret.lowerBound < birthDate.lowerBound)
        XCTAssertTrue(birthDate.lowerBound < address.lowerBound)

        // And a full round trip lands on the same model.
        XCTAssertEqual(try ZKPCredentialDefinition(from: encoded).value.primary.r.keys,
                       definition.value.primary.r.keys)
    }
}
