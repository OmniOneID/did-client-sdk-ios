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

class ChallengeBuilder
{
    private var storedData : Data = .init()
}

extension ChallengeBuilder
{
    func append(_ value : Data) -> Self
    {
        storedData.append(value)
        return self
    }
    
    func append(_ value : BigInt) -> Self
    {
        return self.append(value.data)
    }
    
    func append(_ value : BigIntString) -> Self
    {
        return self.append(value.bigInt)
    }
    
    func append(_ value : [UInt8]) -> Self
    {
        return self.append(Data(value))
    }
    
    func append(_ ordered : [[UInt8]]) -> Self
    {
        let datas = ordered.map { Data($0) }
        return self.append(datas)
    }
    
    func append(_ ordered : [Data]) -> Self
    {
        let temp = ordered.reduce(into: Data()) { $0 += $1}
        storedData.append(temp)
        return self
    }
    
    func append(_ ordered : [BigInt]) -> Self
    {
        let temp = ordered.reduce(into: Data()) { $0 += $1.data}
        storedData.append(temp)
        return self
    }
    
    func append(_ ordered : [BigIntString]) -> Self
    {
        let temp = ordered.reduce(into: Data()) { $0 += $1.bigInt.data}
        storedData.append(temp)
        return self
    }
    
    func append(_ ordered : OrderedDictionary<String, BigInt>) -> Self
    {
        let temp = ordered.reduce(into: Data()) { $0 += $1.value.data }
        storedData.append(temp)
        return self
    }
    
    func append(_ ordered : OrderedDictionary<String, BigIntString>) -> Self
    {
        let temp = ordered.reduce(into: Data()) { $0 += $1.value.bigInt.data }
        storedData.append(temp)
        return self
    }
}

extension ChallengeBuilder
{
    func build() -> Data
    {
        defer
        {
            storedData = .init()
        }
        
        return storedData.sha256()
    }
    
    func buildWithHashing() -> BigInt
    {
        BigInt(sign: .plus, magnitude: .init(build()))
    }
}
