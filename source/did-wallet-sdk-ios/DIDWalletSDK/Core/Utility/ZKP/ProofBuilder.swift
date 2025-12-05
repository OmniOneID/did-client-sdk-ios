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

#if SWIFT_PACKAGE
    import BigInt
#endif

struct ProofBuilder
{
    typealias E = ZKPManagerError
    
    var commonAttributes : [String : BigInt] = .init()
    
    var initProofs : [ProofInitiator.PrimaryInitProof] = .init()
    
    var cList   : [[UInt8]] = .init()
    var tauList : [[UInt8]] = .init()
    
    init()
    {
        self.commonAttributes[ZKPConstants.masterSecretKey] = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeMVect)
    }
    
    mutating func addInitProof(initProof : ProofInitiator.PrimaryInitProof)
    {
        cList.append(contentsOf: initProof.getCommonValue())
        tauList.append(contentsOf: initProof.getTValue())
        initProofs.append(initProof)
    }
  
    func build(nonce : BigInt) throws -> ([ZKProof.SubProof], ZKProof.AggregatedProof)
    {
        let challenge = ChallengeBuilder()
            .append(tauList)
            .append(cList)
            .append(nonce)
            .buildWithHashing()
        
        let aggregatedProof : ZKProof.AggregatedProof = .init(
            cHash: challenge.decimalString,
            cList: cList
        )
        
        var subProofs : [ZKProof.SubProof] = .init()
        for initProof in initProofs
        {
            
            let eqProof = try generateEqProof(
                eqInitProof: initProof.eqProof,
                challenge: challenge,
                credValues: initProof.credValues
            )
            let neProofs = try generateNeProofs(
                neInitProofs: initProof.neProofs,
                eqProof: eqProof,
                challenge: challenge
            )
            subProofs.append(.init(primaryProof: .init(
                eqProof: eqProof,
                neProofs: neProofs
            )))
        }
        
        return (subProofs, aggregatedProof)
    }
}

extension ProofBuilder
{
    fileprivate func generateEqProof(eqInitProof : ProofInitiator.PrimaryEqualInitProof,
                                     challenge : BigInt,
                                     credValues : CredentialValues) throws -> ZKProof.SubProof.PrimaryProof.PrimaryEqualProof
    {
        let aPrime = eqInitProof.aPrime
        let eTilde = eqInitProof.eTilde
        let vTilde = eqInitProof.vTilde
        let mTilde = eqInitProof.mTilde
        
        let e = challenge * eqInitProof.ePrime
        let eHat = eTilde + e
        
        let v = challenge * eqInitProof.vPrime
        let vHat = vTilde + v
        
        var mHat : BigIntStringDictionary = .init()
        var revealedAttrs : BigIntStringDictionary = .init()
        
        for (key, credValue) in credValues.attrValues
        {
            if credValue.type == .known
            {
                revealedAttrs[key] = credValue.value
            }
            else
            {
                guard let curMTilde = mTilde[key]
                else
                {
                   throw E.null(value: key, group: "eqInitProof.mTilde").getError()
                }
                
                let curValue = credValue.value.bigInt
                mHat[key] = ((curValue * challenge) + curMTilde).decimalString
                
            }
        }
        
        let m2 = ((eqInitProof.m2 * challenge) + eqInitProof.m2Tilde).decimalString
        
        return .init(
            revealedAttrs: revealedAttrs,
            aPrime: aPrime.decimalString,
            e: eHat.decimalString,
            v: vHat.decimalString,
            m: mHat,
            m2: m2
        )
    }
}

extension ProofBuilder
{
    fileprivate func generateNeProofs(neInitProofs : [ProofInitiator.PrimaryPredicateInequalityInitProof],
                                      eqProof : ZKProof.SubProof.PrimaryProof.PrimaryEqualProof,
                                      challenge : BigInt) throws -> [ZKProof.SubProof.PrimaryProof.PrimaryPredicateInequalityProof]
    {
        var neProofs : [ZKProof.SubProof.PrimaryProof.PrimaryPredicateInequalityProof] = .init()
        
        for neInitProof in neInitProofs
        {
            var u : BigIntStringDictionary = .init()
            var r : BigIntStringDictionary = .init()
            var ur = BigInt.zero
            
            for i in 0 ..< ZKPConstants.iteration
            {
                let strIndex = String(i)
                
                guard let curU = neInitProof.u[strIndex]
                else
                {
                    throw E.null(value: strIndex,
                                 group: "neInitProof.u").getError()
                }
                
                guard let curR = neInitProof.r[strIndex]
                else
                {
                    throw E.null(value: strIndex,
                                 group: "neInitProof.r").getError()
                }
                
                guard let uTilde = neInitProof.uTilde[strIndex]
                else
                {
                    throw E.null(value: strIndex,
                                 group: "neInitProof.uTilde").getError()
                }
                
                guard let rTilde = neInitProof.rTilde[strIndex]
                else
                {
                    throw E.null(value: strIndex,
                                 group: "neInitProof.rTilde").getError()
                }
                // For 1 ≤ i ≤ 4 compute ui ← ui + cu.
                u[strIndex] = ((challenge * curU) + uTilde).decimalString
                // For1 ≤ i ≤ 4 computer ri ← ri + cr.
                r[strIndex] = ((challenge * curR) + rTilde).decimalString
                
                ur = ((curU * curR) + ur)
            }
            
            guard let rDelta = neInitProof.r[ZKPConstants.delta]
            else
            {
                throw E.null(value: ZKPConstants.delta,
                             group: "neInitProof.r").getError()
            }
            
            guard let rDeltaTilde = neInitProof.rTilde[ZKPConstants.delta]
            else
            {
                throw E.null(value: ZKPConstants.delta,
                             group: "neInitProof.rTilde").getError()
            }
            
            r[ZKPConstants.delta] = ((challenge * rDelta) + rDeltaTilde).decimalString
            
            // Compute r∆ ← r∆ + c * r∆.
            // Compute α ← α + c(r∆ − u1*r1 − u2*r2 − u3*r3 − u4*r4).
            let alpha = (((rDelta - ur) * challenge) + neInitProof.alphaTilde).decimalString
            
            guard let mj = eqProof.m[neInitProof.predicate.attrName]
            else
            {
                throw E.null(value: neInitProof.predicate.attrName,
                             group: "eqProof.m").getError()
            }
            
            //The values Prp = ({ui},{ri},r∆,α,mj) are the sub-proof for predicate p
            neProofs.append(.init(
                u: u,
                r: r,
                t: neInitProof.t.mapValues({ $0.decimalString }),
                mj: mj,
                alpha: alpha,
                predicate: neInitProof.predicate
            ))
        }
        
        return neProofs
    }
}
