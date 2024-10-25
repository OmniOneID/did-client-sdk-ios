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

extension SecKey {
    /// Get public key from SecKey
    /// self must have private key
    /// - Returns: Public key object
    func toPublicKey() throws -> SecKey
    {
        guard let pubKey = SecKeyCopyPublicKey(self)
        else
        {
            throw SecureEnclaveError.copyPublicKey.getError()
        }
        
        return pubKey
    }
    
    /// Get compressed public key data from SecKey
    /// - Returns: Compressed public key data
    func toCompressedPublicKeyData() throws -> Data
    {
        var error: Unmanaged<CFError>?
        
        guard let pubKeyData = SecKeyCopyExternalRepresentation(self,
                                                                &error) as? Data
        else
        {
            throw SecureEnclaveError.publicKeyRepresentation(detail: error!.toError()).getError()
        }
        
        return try pubKeyData.toCompressedRepresentationFromRawPublicKey()
    }
}
