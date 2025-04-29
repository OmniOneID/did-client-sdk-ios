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

struct BigIntUtil {
    
    static let maxIterations : Int = 1000
    
    static let two   : BigInt = 2
    static let three : BigInt = 3
    
    static func generateX(p : BigInt, q : BigInt) throws -> BigInt
    {
        try createRandomInRange(min: two, max: (p * q) - three) + two
    }
    
    static func generateQR(n : BigInt) throws -> BigInt
    {
        let temp = try createRandomInRange(min: .zero, max: n)
        
        return temp * temp.modulus(n)
    }
    
    static func createRandomInRange(min : BigInt, max : BigInt) throws -> BigInt
    {
        if min.sign == .minus
        {
            throw WalletCoreCommonError.invalidParameter(code: .zkpManager, name: "min").getError()
        }
        if max.sign == .minus
        {
            throw WalletCoreCommonError.invalidParameter(code: .zkpManager, name: "max").getError()
        }
        
        switch BigUInt.compare(min.magnitude, max.magnitude)
        {
        case .orderedAscending:
            break
        case .orderedSame:
            return min
        case .orderedDescending:
            throw WalletCoreCommonError.invalidParameter(code: .zkpManager, name: "'MIN' may not be greater than 'MAX'").getError()
        }
        
        if min.bitWidth > (max.bitWidth / 2)
        {
            return try createRandomInRange(min: .zero, max: max - min) + min
        }
        
        for _ in 0 ..< maxIterations
        {
            let x = createRandomBigInt(bitLength: max.bitWidth)
            
            if BigUInt.compare(x.magnitude, min.magnitude) != .orderedAscending &&
                BigUInt.compare(x.magnitude, max.magnitude) != .orderedDescending
            {
                return x
            }
        }
        
        return createRandomBigInt(bitLength: (max - min).bitWidth - 1) + min
    }
    
    static func createRandomBigInt(bitLength : Int) -> BigInt
    {
        return BigInt(sign: .plus, magnitude: .init(createRandomData(bitLength: bitLength)))
    }
    
    static func createRandomPrime(start : BigInt, intervalBits : Int, maxBits : Int) -> BigInt
    {
        let certainty = (maxBits <= 1024)
        ? 80
        : (96 + 16 * ((maxBits) - 1) / 1024);
        
        while true
        {
            var base = createRandomData(bitLength: intervalBits)
            base |= 1
            
            let rv = start + BigInt(sign: .plus, magnitude: base)
            
            if rv.bitWidth > maxBits
            {
                continue
            }
            let cBig : BigInt = .init(integerLiteral: Int64(certainty))
            
            if rv.isStrongProbablePrime(cBig)
            {
                return rv
            }
        }
    }
    
    static func createRandomData(bitLength: Int) -> BigUInt
    {
        return BigUInt.randomInteger(withExactWidth: bitLength)
    }
    
    static func createRandomBigInt(max : BigInt) throws -> BigInt
    {
        return try createRandomInRange(min: .zero, max: max)
    }
    
    static func generateNonce() -> BigInt
    {
        return createRandomBigInt(bitLength: ZKPConstants.largeNonce)
    }
    
    static func generateMasterSecret() -> BigInt
    {
        return createRandomBigInt(bitLength: ZKPConstants.largeMasterSecret)
    }
}

extension BigIntUtil
{
    static func calculateTEqual(publicKey       : CredentialPrimaryPublicKey,
                                aPrime          : BigInt,
                                e               : BigInt,
                                v               : BigInt,
                                mTilde          : Dictionary<String, BigInt>,
                                m2Tilde         : BigInt,
                                unrevealedAttrs : Set<String>) throws -> BigInt
    {
        let publicKeyN = publicKey.n.bigInt
        // Compute t-values
        // a_prime^e % p_pub_key.n
        var t = aPrime.power(e, modulus: publicKeyN)
        
        var tProduct : BigInt = 1
        
        for key in unrevealedAttrs
        {
            
            guard let curR = publicKey.r[key]?.bigInt
            else
            {
                throw ZKPManagerError.null(value: key, group: "publicKey.r").getError()
            }
            
            guard let curM = mTilde[key]
            else
            {
                throw ZKPManagerError.null(value: key, group: "mTilde").getError()
            }
            
            // result = result * (cur_r^cur_m % p_pub_key.n) % p_pub_key.n
            tProduct = (tProduct * (curR.power(curM, modulus: publicKeyN))) % publicKeyN
        }
        
        // result = result *(S^v %n)%n
        tProduct = tProduct * publicKey.s.bigInt.power(v, modulus: publicKeyN)
        
        // result = result *(rctxt^m2_tilde%n)%n
        tProduct = tProduct * publicKey.rctxt.bigInt.power(m2Tilde, modulus: publicKeyN)
        
        t = (t * tProduct).modulus(publicKeyN)
        
        return t
    }
    
    
    static func calculateTNotEqual(publicKey : CredentialPrimaryPublicKey,
                                   u         : [String : BigInt],
                                   r         : [String : BigInt],
                                   mj        : BigInt,
                                   alpha     : BigInt,
                                   t         : [String : BigInt],
                                   isLess    : Bool) throws -> [BigInt]
    {
        
        
        
        let publicKeyN = publicKey.n.bigInt
        
        var tList : [BigInt] = .init()
        
        for i in 0 ..< ZKPConstants.iteration
        {
            let indexString = "\(i)"
            guard let curU = u[indexString]
            else
            {
                throw ZKPManagerError.null(value: "[\(indexString)]", group: "u").getError()
            }
            
            guard let curR = r[indexString]
            else
            {
                throw ZKPManagerError.null(value: "[\(indexString)]", group: "r").getError()
            }
            
            let tTau = (publicKey.z.bigInt.power(curU, modulus: publicKeyN) * publicKey.s.bigInt.power(curR, modulus: publicKeyN)).modulus(publicKeyN)
            // add this values to T in the order T1, T2, T3, T4, T∆.
            tList.append(tTau)
        }
        
        guard var delta = r[ZKPConstants.delta]
        else
        {
            throw ZKPManagerError.null(value: ZKPConstants.delta, group: "r").getError()
        }
        
        if isLess
        {
            delta.negate()
        }
        
        let zMod = publicKey.z.bigInt.power(mj, modulus: publicKeyN)
        let sMod = publicKey.s.bigInt.powerExpNegate(delta, modulus: publicKeyN)
        let multiplied = zMod * sMod
        let tTau = multiplied.modulus(publicKeyN)

        tList.append(tTau)
        
        var q : BigInt = 1

        for i in 0 ..< ZKPConstants.iteration
        {
            let indexString = "\(i)"
            guard let curT = t[indexString]
            else
            {
                throw ZKPManagerError.null(value: "[\(indexString)]", group: "t").getError()
            }
            
            guard let curU = u[indexString]
            else
            {
                throw ZKPManagerError.null(value: "[\(indexString)]", group: "u").getError()
            }
            
            q = curT.power(curU, modulus: publicKeyN) * q
        }
        
        q = (publicKey.s.bigInt.power(alpha, modulus: publicKeyN) * q).modulus(publicKeyN)
        // Add q to tList
        tList.append(q)

        return tList;
    }
    
    /**
     * n = a^2 + b^2 + c^2 + d^2
     * */
    static func fourSquares(delta : Int) throws -> [Int]
    {
        if delta < 0
        {
            throw WalletCoreCommonError.invalidParameter(code: .zkpManager, name: "delta").getError()
        }
        
        var roots : [Int] = [largestSquareLessThan(usize: delta), 0, 0, 0]
        
        for i in (1 ... roots[0]).reversed()
        {
            roots[0] = i
            
            if delta == roots[0]
            {
                for j in 1..<4
                {
                    roots[j] = 0
                }
                return roots
            }
            
            roots[1] = largestSquareLessThan(usize: delta - (roots[0] * roots[0]))
            
            for j in (1 ... roots[1]).reversed()
            {
                roots[1] = j
                
                if delta == ((roots[0] * roots[0]) + (roots[1] * roots[1]))
                {
                    roots[2] = 0
                    roots[3] = 0
                    return roots
                }
                
                roots[2] = largestSquareLessThan(usize: delta - ((roots[0] * roots[0]) + (roots[1] * roots[1])))
                
                for k in (1 ... roots[2]).reversed()
                {
                    roots[2] = k
                    var exptemp = ((roots[0] * roots[0]) + (roots[1] * roots[1])) + (roots[2] * roots[2])
                    
                    if delta == exptemp
                    {
                        roots[3] = 0
                        return roots
                    }
                    
                    roots[3] = largestSquareLessThan(usize: delta - exptemp)
                    exptemp += (roots[3] * roots[3])
                    if delta == exptemp
                    {
                        return roots
                    }
                }
            }
        }
        
        return roots
    }
}

extension BigIntUtil
{
    private static func largestSquareLessThan(usize : Int) -> Int
    {
        return Int(floor(sqrt(Double(usize))))
    }
}
