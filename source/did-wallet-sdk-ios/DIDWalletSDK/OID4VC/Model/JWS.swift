//
/*
 * Copyright 2026 OmniOne.
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
import CryptoKit

struct JWSHeader : Jsonable
{
    var alg : JWK.Algorithm = .es256
    var typ : String
    var kid : String?
    var jwk : JWK
}

struct JWSAudiencePayload : Jsonable
{
    var aud : String
    var iat : Int       = Int(Date().timeIntervalSince1970)
    var nonce : String?
}

struct JWS
{
    let header: String
    let payload: String
    let signature: String
    
    public init(from string : String)
    {
        let parts = string.split(separator: ".")
        guard parts.count == 3 else { fatalError("Invalid JWS format") }
        
        self.header = String(parts[0])
        self.payload = String(parts[1])
        self.signature = String(parts[2])
    }
    
    func getPayload<T : Jsonable>() throws -> T
    {
        guard let decoded = payload.base64URLDecoded
        else
        {
            //TODO: Confirm the error
            throw MultibaseUtilsError.failToDecode.getError()
        }
        return try T.init(from: decoded)
    }
    
    func verify() throws -> Bool
    {
        let message = header + "." + payload
        
        let publicKey = try getPublicKey()
        
        guard let signatureData = signature.base64URLDecoded
        else
        {
            //TODO: Confirm the error
            throw MultibaseUtilsError.failToDecode.getError()
        }
        
        let sig = try P256.Signing.ECDSASignature.init(rawRepresentation: signatureData)
        
        let digest = SHA256.hash(data: message.data(using: .utf8)!)
        
        return publicKey.isValidSignature(sig, for: digest)
    }
    
    private func getPublicKey() throws -> P256.Signing.PublicKey
    {
        guard let decodedHeader = header.base64URLDecoded
        else
        {
            //TODO: Confirm the error
            throw MultibaseUtilsError.failToDecode.getError()
        }
        
        let jwsHeader : JWSHeader = try .init(from: decodedHeader)
        
        return try .init(
            xBase64URL: jwsHeader.jwk.x,
            yBase64URL: jwsHeader.jwk.y
        )
    }
}
