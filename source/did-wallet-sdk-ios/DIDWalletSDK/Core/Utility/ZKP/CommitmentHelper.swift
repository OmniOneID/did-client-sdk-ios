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

struct CommitmentHelper
{
//    Pedersen Commitment Scheme
    static func commitment(z : BigInt, zExp : BigInt, s : BigInt, sExp : BigInt, modular : BigInt) -> BigInt
    {
        let zMod = z.power(zExp, modulus: modular)
        let sMod = s.power(sExp, modulus: modular)
        return (zMod * sMod) % modular
    }
    
    static func modPow(_ base : BigInt, _ exponent : BigInt, _ modulus : BigInt) -> BigInt
    {
        var result = BigInt(1)
        var base = base.modulus(modulus)
        var exp = exponent
        
        while exp > 0
        {
            if exp % 2 != 0
            {
                result = (result * base).modulus(modulus)
            }
            base = (base * base).modulus(modulus)
            exp /= 2
        }
        return result
        
    }
}
