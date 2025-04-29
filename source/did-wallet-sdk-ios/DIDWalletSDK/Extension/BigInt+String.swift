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

extension BigInt
{
    var decimalString: BigIntString
    {
        return self.description
    }
    
    var data: Data
    {
        
        let serializedData = self.serialize()
        let firstIndex = serializedData.firstIndex { $0 != 0 }

        if let firstIndex = firstIndex
        {
            return serializedData.subdata(in: firstIndex..<serializedData.endIndex)
        }
        return serializedData

    }
    
    func powerExpNegate(_ exponent: BigInt, modulus: BigInt) -> BigInt
    {
        if exponent.sign == .minus
        {
            guard let inversed = self.inverse(modulus)
            else
            {
                return BigInt.zero
            }
            
            return inversed.power(-exponent, modulus: modulus)
        }
        else
        {
            return self.power(exponent, modulus: modulus)
        }
    }
}

extension String
{
    var bigInt: BigInt
    {
        return BigInt.init(extendedGraphemeClusterLiteral: self)
    }
}
