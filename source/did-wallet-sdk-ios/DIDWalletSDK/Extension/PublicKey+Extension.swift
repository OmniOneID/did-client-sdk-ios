//
/*
 * Copyright 2025-2026 OmniOne.
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

extension P256.Signing.PublicKey
{
    func toCompressedData() throws -> Data
    {
        let publicKey = self
        if #available(iOS 16.0, *)
        {
            return publicKey.compressedRepresentation
        }
        else
        {
            return try publicKey.x963Representation.toCompressedRepresentationFromRawPublicKey()
        }
    }
    
    func getPublicKeyJwk() -> JWK {
        let x963Data = self.x963Representation
        let x = x963Data.subdata(in: 1..<33)
        let y = x963Data.subdata(in: 33..<65)
        
        let jwk : JWK = .init(
//            alg: .es256,
            crv: .p256,
            kty: .ec,
            x: x.base64URLEncoded,
            y: y.base64URLEncoded
        )
        
        return jwk
    }
}

extension P256.Signing.PublicKey {
    
    public init(
        x: Data,
        y: Data
    ) throws {

        guard x.count == 32, y.count == 32
        else
        {
            //TODO: Error
            throw NSError(domain: "InvalidKey", code: -1, userInfo: [NSLocalizedDescriptionKey: "x and y must be 32 bytes"])
        }
        
        // x963: 0x04 || x || y
        var data = Data([0x04])
        data.append(x)
        data.append(y)
        
        try self.init(x963Representation: data)
    }
    
    public init(
        xBase64URL: String,
        yBase64URL: String
    ) throws {
        
        guard let xData = xBase64URL.base64URLDecoded,
              let yData = yBase64URL.base64URLDecoded
        else {
            //TODO: Confirm the error
            throw MultibaseUtilsError.failToDecode.getError()
        }
        
        try self.init(x: xData, y: yData)
    }
}
