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

public struct WalletTokenData: Jsonable, ProofContainer {
    public var seed: WalletTokenSeed
    public var sha256_pii: String
    public var provider: Provider
    public var nonce: String
    public var proof: Proof?
        
    public init(seed: WalletTokenSeed, sha256_pii: String, provider: Provider, nonce: String, proof: Proof?) {
        self.seed = seed
        self.sha256_pii = sha256_pii
        self.provider = provider
        self.nonce = nonce
        self.proof = proof
    }
}

