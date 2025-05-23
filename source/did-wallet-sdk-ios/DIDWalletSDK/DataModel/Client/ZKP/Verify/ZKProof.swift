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

public struct ZKProof : Jsonable
{
    public let proofs : [SubProof]
    public let aggregatedProof : AggregatedProof
    public let requestedProof : RequestedProof
    public let identifiers : [Identifier]
    
    public struct SubProof : Codable
    {
        public let primaryProof : PrimaryProof
        
        public struct PrimaryProof : Codable
        {
            public let eqProof : PrimaryEqualProof
            public let neProofs : [PrimaryPredicateInequalityProof]
            
            public struct PrimaryEqualProof : Codable
            {
                public let revealedAttrs : BigIntStringDictionary
                public let aPrime : BigIntString
                public let e : BigIntString
                public let v : BigIntString
                public let m : BigIntStringDictionary
                public let m2 : BigIntString
            }
            
            public struct PrimaryPredicateInequalityProof : Codable
            {
                public let u : BigIntStringDictionary
                public let r : BigIntStringDictionary
                public let t : BigIntStringDictionary
                public let mj : BigIntString
                public let alpha : BigIntString
                public let predicate : Predicate
            }
        }
    }

    public struct AggregatedProof : Codable
    {
        public let cHash : BigIntString
        public let cList : [[UInt8]]
    }

    public struct RequestedProof : Codable
    {
        public let selfAttestedAttrs : StringDictionary
        public let predicates : RequestedAttrDictionary
        public let revealedAttrs : RequestedAttrDictionary
        public let unrevealedAttrs : RequestedAttrDictionary
        
    }
    
    public struct RequestedAttribute : Codable
    {
        public let subProofIndex : Int
        public let raw : String?
        public let encoded : String?
    }

    public struct Identifier : Codable
    {
        public let credDefId : String
        public let schemaId : String
    }
    
    public struct Predicate : Codable
    {
        public let pType : PredicateType
        public let pValue : Int
        public let attrName : String
        
        init(pType: PredicateType, pValue: Int, attrName: String) {
            self.pType = pType
            self.pValue = pValue
            self.attrName = attrName
        }
        
        func getDelta(attrValue : Int) -> Int
        {
            var delta : Int = 0
            switch pType
            {
            case .GE:
                delta = attrValue - pValue
            case .GT:
                delta = attrValue - pValue - 1
            case .LE:
                delta = pValue - attrValue
            case .LT:
                delta = pValue - attrValue - 1
            }
            
            return delta
        }
        
        func isLess() -> Bool
        {
            return (pType == .LE || pType == .LT)
        }
    }
}


