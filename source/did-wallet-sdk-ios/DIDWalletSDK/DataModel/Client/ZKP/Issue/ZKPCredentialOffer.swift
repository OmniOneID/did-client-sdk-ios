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

public struct ZKPCredentialOffer : Jsonable
{
    /// Identifier for crendential definition
    public let credDefId : String
    /// Identifier for crendential schama
    public let schemaId : String
    /// KeyCorrectness proof
    public let keyCorrectnessProof : KeyCorrectnessProof
    /// Nonce
    public let nonce : BigIntString
    
}

public struct KeyCorrectnessProof : Jsonable
{
    /// Hash value
    public let c : BigIntString
    /// xzCap
    public let xzCap : BigIntString
    /// xrCap
    public let xrCap : BigIntStringDictionary
}
