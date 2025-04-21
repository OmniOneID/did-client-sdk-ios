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

public struct WalletTokenSeed: Jsonable {
    public var purpose: WalletTokenPurposeEnum
    public var pkgName: String
    public var nonce: String
    public var validUntil: String
    public var userId: String?
    
    public init(purpose: WalletTokenPurposeEnum, pkgName: String, nonce: String, validUntil: String, userId: String? = nil) {
        self.purpose = purpose
        self.pkgName = pkgName
        self.nonce = nonce
        self.validUntil = validUntil
        self.userId = userId
    }
}

