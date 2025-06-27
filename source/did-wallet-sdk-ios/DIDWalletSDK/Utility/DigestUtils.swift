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
import CryptoKit

/// Utility class for hash function.
public class DigestUtils {
    
    /// Hashes the input data.
    /// - Parameters:
    ///   - source: Data to be hashed
    ///   - digestEnum: Type of hash
    /// - Returns: Hashed data
    public static func getDigest(source: Data, digestEnum: DigestEnum) -> Data {
        
        switch digestEnum {
        case .sha256:
            return SHA256.hash(data: source).withUnsafeBytes({ Data(bytes: $0.baseAddress!, count: SHA256Digest.byteCount) })

        case .sha384:
            return SHA384.hash(data: source).withUnsafeBytes({ Data(bytes: $0.baseAddress!, count: SHA384Digest.byteCount) })
            
        case .sha512:
            return SHA512.hash(data: source).withUnsafeBytes({ Data(bytes: $0.baseAddress!, count: SHA512Digest.byteCount) })
        }
        
    }
    
}
