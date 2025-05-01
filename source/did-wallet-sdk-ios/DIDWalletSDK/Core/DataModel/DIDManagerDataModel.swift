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

/// An object containing public key information to register in the DID document.
public struct DIDKeyInfo {
    /// Public key information object returned by KeyManager
    public var keyInfo: KeyInfo
    /// Type specifying the purpose of the public key registered in the DID document
    public var methodType: DIDMethodType
    /// DID to be registered as the controller of the public key in the DID document. If nil, the DID document's id will be registered as the controller.
    public var controller: String?
    
    /// Initializer
    /// - Parameters:
    ///   - keyInfo: Public key information object returned by KeyManager
    ///   - methodType: Type specifying the purpose of the public key registered in the DID document
    ///   - controller: DID to be registered as the controller of the public key in the DID document. If nil, the DID document's id will be registered as the controller.
    public init(keyInfo: KeyInfo, methodType: DIDMethodType, controller: String? = nil) {
        self.keyInfo = keyInfo
        self.methodType = methodType
        self.controller = controller
    }
}

/// A type that specifies the purpose of the keys to register in the DID document.
public struct DIDMethodType : OptionSet
{
    public let rawValue: Int
    
    public static let assertionMethod       = DIDMethodType(rawValue: 1 << 0)
    public static let authentication        = DIDMethodType(rawValue: 1 << 1)
    public static let keyAgreement          = DIDMethodType(rawValue: 1 << 2)
    public static let capabilityInvocation  = DIDMethodType(rawValue: 1 << 3)
    public static let capabilityDelegation  = DIDMethodType(rawValue: 1 << 4)
    
    /// Initializer
    /// - Parameter rawValue: Raw value of DIDMethodType
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

struct DIDMeta: MetaProtocol {
    var id: String
}
