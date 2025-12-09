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

struct ProofInitiator
{
    struct AEVPrimes
    {
        let aPrime : BigInt
        let ePrime : BigInt
        let vPrime : BigInt
    }
    
    struct PrimaryEqualInitProof
    {
        let aPrime : BigInt
        let t      : BigInt
        let eTilde : BigInt
        let ePrime : BigInt
        let vTilde : BigInt
        let vPrime : BigInt
        let mTilde : [String : BigInt]
        let m2Tilde : BigInt
        let m2      : BigInt
        
        func getCommonValue() -> [UInt8]
        {
            return [UInt8](aPrime.data)
        }
        
        func getTValue() -> [UInt8]
        {
            return [UInt8](t.data)
        }
    }
    
    static func createUnrevealedAttributes(schema : ZKPCredentialSchema,
                                           revealedAttrNames : [String]) -> Set<String>
    {
        var unrevealedAttrNames = Set(schema.attrNames).subtracting(Set(revealedAttrNames))
        unrevealedAttrNames.insert(ZKPConstants.masterSecretKey)

        return unrevealedAttrNames
    }
                                
    
    static func generateMTilde(unrevealedAttrs : Set<String>,
                               commonAttributes : [String : BigInt]) -> [String : BigInt]
    {
        
        
        var mTilde : [String : BigInt] = .init()
        
        mTilde.merge(commonAttributes) { $1 }
        
        for key in unrevealedAttrs
        {
            if key != ZKPConstants.masterSecretKey
            {
                mTilde[key] = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeMVect)
            }
        }
        
        return mTilde
    }
    
    
    static func createAEVPrimes(publicKey : CredentialPrimaryPublicKey,
                                credSign : ZKPCredential.CredentialSignature.PrimaryCredentialSignature) -> AEVPrimes
    {
        
        
        
        let r = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeVPrime)
        
        let s = publicKey.s.bigInt
        let n = publicKey.n.bigInt
        
        let a = credSign.a.bigInt
        let e = credSign.e.bigInt
        let v = credSign.v.bigInt
        
        //Function was below
        // A′ ← A * S^r (mod n)
        //Modified for performance improvement below
        //{(S^r mod n)*(A mod n)} mod n
        let aPrime = (s.power(r, modulus: n) * a.modulus(n)).modulus(n)
        //  e′ ← e - 2^596.
        let ePrime = e - (ZKPConstants.largeEStartValue)
        
        // v′ ← v−e * r in integers.
        let vPrime = v - (e * r)
        
        return .init(aPrime: aPrime,
                     ePrime: ePrime,
                     vPrime: vPrime)
    }
    
    
    static func initEqProof(publicKey : CredentialPrimaryPublicKey,
                            unrevealedAttrs  : Set<String>,
                            aevPrime : AEVPrimes,
                            mTilde : [String : BigInt],
                            m2 : BigInt) throws -> PrimaryEqualInitProof
    {
        let eTilde = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeETilde)
        let vTilde = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeVTilde)
        
        let m2Tilde = BigIntUtil.generateNonce()
        
        let t = try BigIntUtil.calculateTEqual(publicKey: publicKey,
                                               aPrime: aevPrime.aPrime,
                                               e: eTilde,
                                               v: vTilde,
                                               mTilde: mTilde,
                                               m2Tilde: m2Tilde,
                                               unrevealedAttrs: unrevealedAttrs)
        
        return .init(aPrime: aevPrime.aPrime,
                     t: t,
                     eTilde: eTilde,
                     ePrime: aevPrime.ePrime,
                     vTilde: vTilde,
                     vPrime: aevPrime.vPrime,
                     mTilde: mTilde,
                     m2Tilde: m2Tilde,
                     m2: m2)
    }
    
}

extension ProofInitiator
{
    struct PrimaryPredicateInequalityInitProof
    {
        let cList      : [BigInt]
        let tauList    : [BigInt]
        let u          : [String : BigInt]
        let uTilde     : [String : BigInt]
        let r          : [String : BigInt]
        let rTilde     : [String : BigInt]
        let alphaTilde : BigInt
        let predicate  : ZKProof.Predicate
        let t          : [String : BigInt]
    }
    
    
    static func generateInitNeProofs(publicKey : CredentialPrimaryPublicKey,
                                     mTilde : [String : BigInt],
                                     credValues : CredentialValues,
                                     predicates : [ZKProof.Predicate]) throws -> [PrimaryPredicateInequalityInitProof]
    {
        
        
        
        var neProofs : [PrimaryPredicateInequalityInitProof] = .init()
        
        for predicate in predicates
        {
            neProofs.append(try initNeProof(publicKey: publicKey,
                                            mTilde: mTilde,
                                            credValues: credValues,
                                            predicate: predicate))
        }
        
        return neProofs
    }
    
    private static func initNeProof(publicKey : CredentialPrimaryPublicKey,
                                    mTilde : [String : BigInt],
                                    credValues : CredentialValues,
                                    predicate : ZKProof.Predicate) throws -> PrimaryPredicateInequalityInitProof
    {
        
        
        
        
        let z = publicKey.z.bigInt
        let s = publicKey.s.bigInt
        let n = publicKey.n.bigInt
        
        guard let credValue = credValues.attrValues[predicate.attrName], let intValue = Int(credValue.value)
        else
        {
            throw ZKPManagerError.null(value: predicate.attrName, group: "credValues").getError()
        }
        
        let delta = predicate.getDelta(attrValue: intValue)
        
        if delta < 0
        {
            throw ZKPManagerError.negativeDelta.getError()
        }
        
        // ∆ ← mj − zj
        // ∆ = (u1)^2 + (u2)^2 + (u3)^2 + (u4)^2
        // Find satisfied u1, u2, u3, u4
        let uList = try BigIntUtil.fourSquares(delta: delta)
        
        var u : [String : BigInt] = .init()
        var r : [String : BigInt] = .init()
        var t : [String : BigInt] = .init()
        
        var cList : [BigInt] = .init()
        
        for i in 0 ..< uList.count
        {
            let value = uList[i]
            let strIndex = String(i)
            // Generate random 2128-bit numbers r1, r2, r3, r4, r∆, compute
            let curR = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeVPrime)
            let curT = CommitmentHelper.commitment(z: z, zExp: BigInt(value), s: s, sExp: curR, modular: n)
            
            u[strIndex] = BigInt(value)
            r[strIndex] = curR
            t[strIndex] = curT
            // add these values to cList
            cList.append(curT)
        }
        
        let rDelta = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeVPrime)
        // T∆ ← Z∆ Sr∆
        let tDelta = CommitmentHelper.commitment(z: z, zExp: BigInt(delta), s: s, sExp: rDelta, modular: n)
        
        r[ZKPConstants.delta] = rDelta
        t[ZKPConstants.delta] = tDelta
        // add these values to cList
        cList.append(tDelta)
        
        var uTilde : [String : BigInt] = .init()
        var rTilde : [String : BigInt] = .init()
        
        for i in 0 ..< ZKPConstants.iteration
        {
            let strIndex = String(i)
            // generate random 592-bit numbers u1,u2,u3,u4
            uTilde[strIndex] = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeUTilde)
            // generate random 672-bit numbers r1 , r2 , r3 , r4 , r∆ compute
            rTilde[strIndex] = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeRTilde)
        }
        rTilde[ZKPConstants.delta] = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeRTilde)
        
        // Generate random 2787-bit number α and compute
        let alphaTilde = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeAlphaTilde)
        
        guard let mj = mTilde[predicate.attrName]
        else
        {
            throw ZKPManagerError.null(value: predicate.attrName, group: "eqProof.mTilde").getError()
        }
        
        let tList = try BigIntUtil.calculateTNotEqual(publicKey: publicKey,
                                                      u: uTilde,
                                                      r: rTilde,
                                                      mj: mj,
                                                      alpha: alphaTilde,
                                                      t: t,
                                                      isLess: predicate.isLess())
        
        
        return .init(cList: cList,
                     tauList: tList,
                     u: u,
                     uTilde: uTilde,
                     r: r,
                     rTilde: rTilde,
                     alphaTilde: alphaTilde,
                     predicate: predicate,
                     t: t)
    }
    
}

extension ProofInitiator
{
    struct PrimaryInitProof
    {
        let eqProof : PrimaryEqualInitProof
        let neProofs : [PrimaryPredicateInequalityInitProof]
        let credValues : CredentialValues
        
        func getCommonValue() -> [[UInt8]]
        {
            var retValue : [[UInt8]] = .init()
            retValue.append(eqProof.getCommonValue())
            
            for entry in neProofs
            {
                for entry1 in entry.cList {
                    retValue.append([UInt8](entry1.data))
                }
            }
            
            return retValue
        }
        
        func getTValue() -> [[UInt8]]
        {
            var retValue : [[UInt8]] = .init()
            retValue.append(eqProof.getTValue())
//            print("tauList : eqProof.t \(eqProof.t.decimalString)")
            for entry in neProofs
            {
                for entry1 in entry.tauList {
                    retValue.append([UInt8](entry1.data))
//                    print("tauList : entry1 \(entry1.decimalString)")
                }
            }
            
            return retValue
        }
    }

}
