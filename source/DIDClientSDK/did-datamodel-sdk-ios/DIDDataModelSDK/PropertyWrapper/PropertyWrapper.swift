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

/// TBD
@propertyWrapper
public struct UTCDatetime {
//    private let regEx : String = "[0-9a-zA-Z_\\-\\.]+"
    private var value : String
    public var wrappedValue : String
    {
        get{ self.value }
        set{ self.value = newValue }
    }
    
    public init(wrappedValue : String)
    {
//        precondition(wrappedValue.matches(regEx: regEx))
        self.value = wrappedValue
    }
}

/// TBD
@propertyWrapper
public struct DIDVersionId {
    private let regEx : String = "[0-9]+"
    private var value : String

    public var wrappedValue : String
    {
        get{ self.value }
        set{
            precondition(newValue.matches(regEx: regEx), "\(regEx) does not match the regex")
            self.value = newValue
        }
    }
    
    public init(wrappedValue : String)
    {
        precondition(wrappedValue.matches(regEx: regEx), "\(regEx) does not match the regex")
        self.value = wrappedValue
    }
}

//MARK: - Private

fileprivate extension String
{
    func matches(regEx : String) ->Bool
    {
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
}
