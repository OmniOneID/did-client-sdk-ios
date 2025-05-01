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

class Base58BTC {
    
    // Base58BTC character set
    // 123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
    
    private static let characterArray : [Character] =
    ["1","2","3","4","5","6","7","8","9",
     "A","B","C","D","E","F","G","H","J",
     "K","L","M","N","P","Q","R","S","T",
     "U","V","W","X","Y","Z","a","b","c",
     "d","e","f","g","h","i","j","k","m",
     "n","o","p","q","r","s","t","u","v",
     "w","x","y","z"]
    
    private static let regEx = "[1-9A-HJ-NP-Za-km-z]*"
    
    static func encode(input : Data) -> String
    {
        if input.count == 0 {
            return ""
        }
        
        var source = input
        
        var zeroCount : Int = 0
        while zeroCount < source.count && source[zeroCount] == 0 {
            zeroCount += 1
        }
        
        var temp : Data = .init(count: source.count * 2)
        var j : Int = temp.count
        
        var startAt = zeroCount
        while startAt < source.count {
            let mod = Int(divmod58(number: &source, startAt: startAt))
            if source[startAt] == 0 {
                startAt += 1
            }
            j -= 1
            temp[j] = characterArray[mod].toUInt8()
        }
        
        let char1 = characterArray[0].toUInt8()
        while j < temp.count && temp[j] == char1 {
            j += 1
        }
        
        zeroCount -= 1
        while zeroCount >= 0 {
            j -= 1
            temp[j] = char1
            zeroCount -= 1
        }
        
        let output = Data(temp[j..<temp.count])
        return String.init(data: output, encoding: .utf8)!
    }
    
    static func decode(input : String) -> Data?
    {
        if input.count == 0 || !input.matches(regEx: regEx){
            return nil
        }
        
        var input58 : Data = .init(count: input.count)
        
        var index = 0
        for char in input {
            var charUInt = Int(char.toUInt8())
            switch char {
            case "1"..."9":
                charUInt -= Int(Character("1").toUInt8())
            case "A"..."H":
                charUInt += 9 - Int(Character("A").toUInt8())
            case "J"..."N":
                charUInt += 17 - Int(Character("J").toUInt8())
            case "P"..."Z":
                charUInt += 22 - Int(Character("P").toUInt8())
            case "a"..."k":
                charUInt += 33 - Int(Character("a").toUInt8())
            case "m"..."z":
                charUInt += 44 - Int(Character("m").toUInt8())
            default:
                ()
            }

            input58[index] = UInt8(charUInt)
            index += 1
        }
        
        var zeroCount = 0
        while zeroCount < input58.count && input58[zeroCount] == 0 {
            zeroCount += 1
        }
        
        var temp = Data.init(count: input.count)
        var j = temp.count
        
        var startAt = zeroCount
        while startAt < input58.count {
            let mod = divmod256(number58: &input58, startAt: startAt)
            if input58[startAt] == 0 {
                startAt += 1
            }
            j -= 1
            temp[j] = mod
        }
        
        while j < temp.count && temp[j] == 0 {
            j += 1
        }
        
        return Data(temp[j - zeroCount ..< temp.count])
    }
    
    private static func divmod58(number : inout Data, startAt : Int) -> UInt8
    {
        var remainder : Int = 0
        for i in startAt ..< number.count {
            let digit256 = Int(number[i] & 0xff)
            let temp = remainder * 256 + digit256
            
            number[i] = UInt8(temp / 58)
            
            remainder = temp % 58
        }
        return UInt8(remainder)
    }
    
    private static func divmod256(number58 : inout Data, startAt : Int) -> UInt8
    {
        var remainder : Int = 0
        for i in startAt ..< number58.count {
            let digit58 = Int(number58[i] & 0xff)
            let temp = remainder * 58 + digit58
            
            number58[i] = UInt8(temp / 256)
            
            remainder = temp % 256
        }
        return UInt8(remainder)
    }
}
