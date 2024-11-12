//
//  Encodable.swift
//  DIDCoreSDKTests
//
//  Created by wskim on 11/18/24.
//

import Foundation

extension Encodable {
    func equals<T>(other: T) throws -> Bool where T: Encodable {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        
        let lh = try jsonEncoder.encode(self).sha256()
        let rh = try jsonEncoder.encode(other).sha256()
        
        return lh == rh
    }
}
