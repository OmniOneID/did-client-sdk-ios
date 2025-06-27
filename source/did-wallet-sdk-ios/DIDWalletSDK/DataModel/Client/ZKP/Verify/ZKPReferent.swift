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

public struct AvailableReferent
{
    public let selfAttrReferent  : [AttrReferent]
    public let attrReferent      : [AttrReferent]
    public let predicateReferent : [AttrReferent]
}

public struct AttrReferent
{
    public let key : String
    public let name : String
    public let checkRevealed : Bool
    public let referent : [SubReferent]
}

public struct SubReferent
{
    public let raw : String
    public let credId : String
    public let credDefId : String
    public let schemaId : String
}

public struct UserReferent
{
    public let credId       : String?
    public let raw          : String
    public let referentKey  : String
    public let referentName : String
    public let isRevealed   : Bool
    
    //Initialize for self attribute referent only
    public init(raw          : String,
                referentKey  : String,
                referentName : String)
    {
        self.credId = nil
        self.raw    = raw
        self.referentKey  = referentKey
        self.referentName = referentName
        self.isRevealed   = true
    }
    
    //Initialize by selected subReferent
    public init(selectedAttrSubReferent : SubReferent,
                referentKey  : String,
                referentName : String,
                isRevealed   : Bool)
    {
        self.credId       = selectedAttrSubReferent.credId
        self.raw          = selectedAttrSubReferent.raw
        self.referentKey  = referentKey
        self.referentName = referentName
        self.isRevealed   = isRevealed
    }
    
    //Initialize by selected attrReferent index
    public init(attrReferent  : AttrReferent,
                selectedIndex : UInt,
                isRevealed    : Bool) throws
    {
        if attrReferent.referent.count <= selectedIndex
        {
            throw WalletCoreCommonError.invalidParameter(code: .zkpManager, name: "selectedIndex out of range").getError()
        }
        
        self.credId       = attrReferent.referent[Int(selectedIndex)].credId
        self.raw          = attrReferent.referent[Int(selectedIndex)].raw
        self.referentKey  = attrReferent.key
        self.referentName = attrReferent.name
        self.isRevealed   = isRevealed
    }
}
