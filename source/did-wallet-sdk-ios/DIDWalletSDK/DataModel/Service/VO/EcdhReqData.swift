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

public class ReqEcdhBuilder {
    private var client: String = ""
    private var clientNonce: String = ""
    private var publicKey: String = ""
    private var curve: ECType = .secp256r1
    var candidate: [SymmetricCipherType]? = [.aes256CBC]
    var proof: Proof? = nil
    
    public init() {}
    
    public func setClient(_ client: String) -> ReqEcdhBuilder {
        self.client = client
        return self
    }
    
    public func setClientNonce(_ clientNonce: String) -> ReqEcdhBuilder {
        self.clientNonce = clientNonce
        return self
    }
    
    public func setPublicKey(_ publicKey: String) -> ReqEcdhBuilder {
        self.publicKey = publicKey
        return self
    }
    
    public func setCurve(_ curve: ECType) -> ReqEcdhBuilder {
        self.curve = curve
        return self
    }
    
    public func setCandidate(_ candidate: [SymmetricCipherType]) -> ReqEcdhBuilder {
        self.candidate = candidate
        return self
    }
    
    public func setProof(_ proof: Proof?) -> ReqEcdhBuilder {
        self.proof = proof
        return self
    }
    
    public func build() -> ReqEcdh {
        return ReqEcdh(client: client, clientNonce: clientNonce, publicKey: publicKey, curve: curve, proof: proof)
    }
}


public struct ReqEcdh: Jsonable, ProofContainer {
    var client: String
    var clientNonce: String
    var publicKey: String
    var curve: ECType
    var candidate: [SymmetricCipherType]?
    public var proof: Proof?
    
        
    public init(client: String, clientNonce: String, publicKey: String, curve: ECType, candidate: [SymmetricCipherType]? = nil, proof: Proof? = nil) {
        self.client = client
        self.clientNonce = clientNonce
        self.publicKey = publicKey
        self.curve = curve
        self.candidate = candidate
        self.proof = proof
    }
}
