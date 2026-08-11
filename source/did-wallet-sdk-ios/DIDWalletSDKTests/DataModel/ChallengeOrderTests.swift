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

/// The ZKP key-correctness challenge is a hash over attribute values concatenated **in order**, and
/// the map that carries them is now an SDK-owned type. These tests pin the one property that makes
/// the substitution safe: what the challenge consumes is the map's key order, and nothing else.
///
/// Without them the order requirement lives only in a comment — the SDK has no end-to-end ZKP test
/// that would notice a reordering.
final class ChallengeOrderTests: XCTestCase {

    private let attributes: [(String, BigIntString)] = [
        ("master_secret", BigIntString("1111111111")),
        ("birth_date", BigIntString("2222222222")),
        ("address", BigIntString("3333333333"))
    ]

    func testChallengeConcatenatesValuesInKeyOrder() {
        let map = OrderedStringMap(attributes)

        let built = ChallengeBuilder().append(map).build()
        let expected = attributes.reduce(into: Data()) { $0 += $1.1.bigInt.data }

        XCTAssertEqual(built, expected.sha256())
    }

    /// The same entries in a different order are a different challenge. If this ever passes, the
    /// map has started sorting or hashing its keys and every issued credential's key proof is at
    /// risk.
    func testADifferentKeyOrderIsADifferentChallenge() {
        let map = OrderedStringMap(attributes)
        let reordered = OrderedStringMap(attributes.reversed().map { ($0.0, $0.1) })

        XCTAssertNotEqual(ChallengeBuilder().append(map).build(),
                          ChallengeBuilder().append(reordered).build())
    }

    /// The `BigInt` overload is the one `KeyPairVerifier` reaches through `mapValues`; it has to
    /// agree with the `BigIntString` overload for the same attributes.
    func testBothOverloadsAgreeOnTheSameAttributes() {
        let map = OrderedStringMap(attributes)

        XCTAssertEqual(ChallengeBuilder().append(map).build(),
                       ChallengeBuilder().append(map.mapValues { $0.bigInt }).build())
    }
}
