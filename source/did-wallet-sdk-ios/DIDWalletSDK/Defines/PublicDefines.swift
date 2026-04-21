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

public typealias BigIntString = String
public typealias StringDictionary = [String : String]
public typealias BigIntStringDictionary = [String : BigIntString]

public typealias RequestedAttrDictionary = [String : ZKProof.RequestedAttribute]

public typealias CaptionString = String

public let DefaultHttpHeaderFields : StringDictionary = [
    "Content-Type"    : "application/json;charset=utf-8",
    "Accept"          : "application/json",
    "Accept-Language" : Locale.preferredLanguages.first ?? "en-US"
]

public let XWWWFormHttpHeaderFields : StringDictionary = [
    "Content-Type"    : "application/x-www-form-urlencoded",
    "Accept"          : "application/json",
    "Accept-Language" : Locale.preferredLanguages.first ?? "en-US"
]
