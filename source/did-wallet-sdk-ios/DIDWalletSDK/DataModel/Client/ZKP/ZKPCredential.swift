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

public struct ZKPCredential : Jsonable
{
    public let credentialId              : String
    public let schemaId                  : String
    public let credDefId                 : String
    public let values                    : [String : AttributeValue]
    public var signature                 : CredentialSignature
    public let signatureCorrectnessProof : SignatureCorrectnessProof
    
    public struct CredentialSignature : Jsonable
    {
        public var pCredential : PrimaryCredentialSignature
        
        public struct PrimaryCredentialSignature : Jsonable
        {
            public let a : BigIntString
            public let e : BigIntString
            public let m2 : BigIntString
            public let q : BigIntString
            public var v : BigIntString
        }
    }
    
    public struct SignatureCorrectnessProof : Jsonable
    {
        public let se : BigIntString
        public let c  : BigIntString
    }
}





