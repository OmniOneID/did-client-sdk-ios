//
/*
 * Copyright 2025 OmniOne.
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
import OrderedCollections

struct KeyPairVerifier
{
    static func verify(publicKey : CredentialPrimaryPublicKey, keyProof : KeyCorrectnessProof) throws -> Bool
    {
        let n = publicKey.n.bigInt
        let s = publicKey.s.bigInt
        let z = publicKey.z.bigInt
        let r : OrderedDictionary<String, BigInt> = publicKey.r.mapValues { $0.bigInt }
        
        let proofC = keyProof.c.bigInt
        let xzCap = keyProof.xzCap.bigInt
        let xrCap = keyProof.xrCap.mapValues { $0.bigInt }
        
        guard let zInverse = z.inverse(n) else {
            throw ZKPManagerError.inverse(value: "z").getError()
        }
        
        let zCap = CommitmentHelper.commitment(z: zInverse,
                                               zExp: proofC,
                                               s: s,
                                               sExp: xzCap,
                                               modular: n)
        var rCap : [BigInt] = .init()
        for attrName in r.keys
        {
            guard let rValue = r[attrName]
            else
            {
                throw ZKPManagerError.null(value: attrName, group: "r").getError()
            }
            
            guard let rInverse = rValue.inverse(n)
            else
            {
                throw ZKPManagerError.inverse(value: "r[\(attrName)]").getError()
            }
            
            
            guard let xrCapValue = xrCap[attrName]
            else {
                throw ZKPManagerError.null(value: attrName, group: "xrCap").getError()
            }
            
            let rCapValue = CommitmentHelper.commitment(z: rInverse,
                                                        zExp: proofC,
                                                        s: s,
                                                        sExp: xrCapValue,
                                                        modular: n)
            rCap.append(rCapValue)
        }
        
        let c = ChallengeBuilder()
            .append(z)
            .append(r)
            .append(zCap)
            .append(rCap)
            .buildWithHashing()
                                                                                        
        return (c == proofC)
    }
        
}
