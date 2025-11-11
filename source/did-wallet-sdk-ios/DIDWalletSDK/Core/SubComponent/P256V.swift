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
import CryptoKit

enum P256V
{
    // secp256r1 parameters
    static let p = BigUInt("FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF", radix: 16)!
    static let n = BigUInt("FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551", radix: 16)!
    static let a = BigUInt("FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC", radix: 16)!
    static let b = BigUInt("5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B", radix: 16)!
    
    static let Gx = BigUInt("6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296", radix: 16)!
    static let Gy = BigUInt("4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5", radix: 16)!
    
    static let compactAndCompressed : UInt8 = 27 + 4
    
    struct Point: Equatable {
        public let x: BigUInt
        public let y: BigUInt
        public let inf: Bool
        public static let infinity = Point(x: 0, y: 0, inf: true)
    }
}

fileprivate extension P256V
{
    @inline(__always) static func modP(_ x: BigUInt) -> BigUInt { x % p }
    @inline(__always) static func modN(_ x: BigUInt) -> BigUInt { x % n }
    
    @inline(__always) static func addP(_ x: BigUInt, _ y: BigUInt) -> BigUInt { return (x + y) % p }
    
    @inline(__always) static func subP(_ x: BigUInt, _ y: BigUInt) -> BigUInt
    {
        // (x - y) mod p
        return x >= y ? (x - y) : (p - ((y - x) % p))
    }
    
    @inline(__always) static func mulP(_ x: BigUInt, _ y: BigUInt) -> BigUInt { return (x * y) % p }
    
    // Extended Euclidean inverse
    static func modInverse(_ aIn: BigUInt, _ mIn: BigUInt) -> BigUInt
    {
        let a = BigInt(aIn)
        let m = BigInt(mIn)
        if a == 0 { return 0 }
        
        var (lm, hm) = (BigInt(1), BigInt(0))
        var (low, high) = ((a % m + m) % m, m)
        while low != 0 {
            let r = high / low
            (lm, hm) = (hm - r * lm, lm)
            (low, high) = (high - r * low, low)
        }
        
        var inv = hm % m
        if inv < 0 { inv += m }
        return BigUInt(inv)
    }
    
    static let G = Point(x: Gx, y: Gy, inf: false)
    
    static func pointDouble(_ P: Point) -> Point
    {
        if P.inf { return P }
        if P.y == 0 { return .infinity }
        
        // lambda = (3*x^2 + a) / (2*y)  (mod p)
        let threeX2 = mulP(BigUInt(3), mulP(P.x, P.x))        // 3*x^2 mod p
        let num     = addP(threeX2, a)                        // 3*x^2 + a
        let den     = mulP(BigUInt(2), P.y)                   // 2*y
        let denInv  = modInverse(den, p)                      // (2*y)^{-1} mod p
        let lambda  = mulP(num, denInv)                       // slope
        
        // x_r = lambda^2 - 2*x (mod p)
        let lambda2 = mulP(lambda, lambda)
        let xr      = subP(subP(lambda2, P.x), P.x)
        
        // y_r = lambda*(x - x_r) - y (mod p)
        let yr      = subP(mulP(lambda, subP(P.x, xr)), P.y)
        
        return Point(x: xr, y: yr, inf: false)
    }
    
    static func pointAdd(_ P: Point, _ Q: Point) -> Point
    {
        if P.inf { return Q }
        if Q.inf { return P }
        if P.x == Q.x {
            // P + (-P) = O
            if (P.y + Q.y) % p == 0 { return .infinity }
            // P == Q → doubling
            return pointDouble(P)
        }
        // lambda = (y_Q - y_P) / (x_Q - x_P)
        let num    = subP(Q.y, P.y)
        let den    = subP(Q.x, P.x)
        let denInv = modInverse(den, p)
        let lambda = mulP(num, denInv)
        
        // x_r = lambda^2 - x_P - x_Q
        let xr     = subP(subP(mulP(lambda, lambda), P.x), Q.x)
        
        // y_r = lambda*(x_P - x_r) - y_P
        let yr     = subP(mulP(lambda, subP(P.x, xr)), P.y)
        
        return Point(x: xr, y: yr, inf: false)
    }
    
    static func mul(_ P: Point, _ k: BigUInt) -> Point
    {
        if k == 0 || P.inf { return .infinity }
        var Q = Point.infinity
        var N = P
        var scalar = k
        while scalar > 0 {
            if (scalar & 1) == 1 { Q = pointAdd(Q, N) }
            N = pointDouble(N)
            scalar >>= 1
        }
        return Q
    }
    
    static func mulG(_ k: BigUInt) -> Point { mul(G, k) }
    
    static func negate(_ P: Point) -> Point
    {
        if P.inf { return P }
        return Point(x: P.x, y: (p - P.y) % p, inf: false)
    }
    
    static func publicKeyPoint(_ x963Representation: Data) -> Point
    {
        let x = BigUInt(x963Representation[1..<(1+32)])
        let y = BigUInt(x963Representation[(1+32)..<(1+64)])
        return Point(x: x, y: y, inf: false)
    }
    
    // DER(X9.62) to 64B r||s
    static func derToRS64(_ der: Data) throws -> Data
    {
        var idx = 0
        func need(_ n: Int) throws { if idx + n > der.count { throw NSError(domain: "DER", code: -100) } }
        func readByte() throws -> UInt8 { try need(1); defer { idx += 1 }; return der[idx] }
        func read(_ n: Int) throws -> Data { try need(n); defer { idx += n }; return Data(der[idx..<(idx+n)]) }
        func readLen() throws -> Int {
            let first = try readByte()
            if first < 0x80 { return Int(first) }
            let cnt = Int(first & 0x7F)
            guard cnt > 0 && cnt <= 4 else { throw NSError(domain: "DER", code: -101) }
            var len = 0
            for _ in 0..<cnt { len = (len << 8) | Int(try readByte()) }
            return len
        }
        guard try readByte() == 0x30 else { throw NSError(domain: "DER", code: -110) }
        _ = try readLen()
        guard try readByte() == 0x02 else { throw NSError(domain: "DER", code: -111) }
        let rlen = try readLen(); var r = try read(rlen)
        guard try readByte() == 0x02 else { throw NSError(domain: "DER", code: -112) }
        let slen = try readLen(); var s = try read(slen)
        while r.count > 0 && r.first == 0x00 { r.removeFirst() }
        while s.count > 0 && s.first == 0x00 { s.removeFirst() }
        guard r.count <= 32, s.count <= 32 else { throw NSError(domain: "DER", code: -113) }
        let r32 = Data(repeating: 0, count: 32 - r.count) + r
        let s32 = Data(repeating: 0, count: 32 - s.count) + s
        return r32 + s32
    }
    
    static func normalizeS(_ rs64: Data) -> Data
    {
        let r = rs64.prefix(32)
        var s = BigUInt(rs64.suffix(32))
        let half = n >> 1
        
        if s > half { s = n - s }
        
        let sBytes = s.serialize()
        let s32 = sBytes.count >= 32 ? sBytes.suffix(32)
        : Data(repeating: 0, count: 32 - sBytes.count) + sBytes
        return r + s32
    }
    
    static func computeV(digest: Data,
                         uncompressedPublicKey: Data,
                         rs64: Data) -> UInt8
    {
        let e = BigUInt(Data(digest))
        let r = BigUInt(rs64.prefix(32))
        let s = BigUInt(rs64.suffix(32))
        let w = modInverse(s % n, n)
        let u1 = (e * w) % n
        let u2 = (r * w) % n
        let Q  = publicKeyPoint(uncompressedPublicKey)
        let R  = pointAdd(mulG(u1), mul(Q, u2))
        
        let v : UInt8 = ((R.y & 1) == 0 ? 0 : 1)
        
        return v + compactAndCompressed
    }
}

//MARK: Recovery
fileprivate extension P256V
{
    // MARK: ECRecover (recover public key from v,r,s,e)
    static func recoverPublicKey(digest: Data,
                                        vrs: Data) throws -> P256.Signing.PublicKey
    {
        let v = vrs.first!
        let rs64 = vrs.suffix(64)
        
        return try recoverPublicKey(digest: digest,
                                    v: v - compactAndCompressed,
                                    rs64: rs64)
    }
    
    static func recoverPublicKey(digest: Data,
                                        v: UInt8,
                                        rs64: Data) throws -> P256.Signing.PublicKey
    {
        let e = BigUInt(digest)
        let r = BigUInt(rs64.prefix(32))
        let s = BigUInt(rs64.suffix(32))
        precondition(r > 0 && r < n && s > 0 && s < n)
        
        // Candidates x: r, r+n if < p
        var xs = [BigUInt]()
        xs.append(r)
        let rPlusN = r + n
        if rPlusN < p { xs.append(rPlusN) }
        
        func modPow(_ base: BigUInt, _ exp: BigUInt, _ mod: BigUInt) -> BigUInt {
            var result = BigUInt(1)
            var b = base % mod
            var e = exp
            while e > 0 {
                if (e & 1) == 1 { result = (result * b) % mod }
                b = (b * b) % mod
                e >>= 1
            }
            return result
        }
        
        let sqrtExp = (p + 1) >> 2 // since p ≡ 3 (mod 4)
        func yForX(_ x: BigUInt, wantOdd: Bool) -> BigUInt? {
            // rhs = x³ - 3x + b (mod p)
            let rhs = ((x.power(3, modulus: p) + (p - 3) * x) % p + b) % p
            let y = modPow(rhs, sqrtExp, p)
            if (y * y) % p != rhs { return nil }
            let isOdd = (y & 1) == 1
            return (isOdd == wantOdd) ? y : (p - y) % p
        }
        
        var R: Point? = nil
        for x in xs {
            if let y = yForX(x, wantOdd: v == 1) {
                R = Point(x: x, y: y, inf: false)
                break
            }
        }
        guard let Rpoint = R else { throw NSError(domain: "ECRecover", code: -200, userInfo: nil) }
        
        // Q = r^{-1}(sR - eG)
        let rInv = modInverse(r % n, n)
        let sR   = mul(Rpoint, s % n)
        let eG   = mulG(e % n)
        let sR_minus_eG = pointAdd(sR, negate(eG))
        let Qpt  = mul(sR_minus_eG, rInv % n)
        
        func be32(_ x: BigUInt) -> Data {
            let b = x.serialize()
            return b.count >= 32 ? Data(b.suffix(32)) : Data(repeating: 0, count: 32 - b.count) + b
        }
        let x963 = Data([0x04]) + be32(Qpt.x) + be32(Qpt.y)
        return try P256.Signing.PublicKey(x963Representation: x963)
    }
}

extension P256V
{
    public static func convertToCompactRepresentation(x962Signature: Data,
                                                      digest: Data,
                                                      uncompressedPublicKey: Data) throws -> Data
    {
        do
        {
            let rs64Orig = try P256V.derToRS64(x962Signature)
            let rs64 = P256V.normalizeS(rs64Orig)
            let v: UInt8 = P256V.computeV(digest: digest,
                                          uncompressedPublicKey: uncompressedPublicKey,
                                          rs64: rs64)
            let vrs = Data([v]) + rs64
            return vrs
        }
        catch
        {
            throw SignableError.failToConvertCompactRepresentation(detail: error).getError()
        }
    }
    
    public static func verify(signature: Data,
                              digest: Data,
                              compressedPublicKey: Data) throws -> Bool
    {
        let publicKey = try recoverPublicKey(digest: digest,
                                             vrs: signature)
        let recoveredKey = try publicKey.toCompressedData()
        
        return compressedPublicKey == recoveredKey
    }
}
