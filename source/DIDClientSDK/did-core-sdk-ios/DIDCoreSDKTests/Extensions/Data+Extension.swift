//
//  Data+Extension.swift
//  DIDCoreSDKTests
//
//  Created by wskim on 11/18/24.
//

import Foundation
import CryptoKit

extension Data {
    func sha256() -> Data {
        return SHA256.hash(data: self).withUnsafeBytes({ Data(bytes: $0.baseAddress!, count: SHA256Digest.byteCount) })
    }
}
