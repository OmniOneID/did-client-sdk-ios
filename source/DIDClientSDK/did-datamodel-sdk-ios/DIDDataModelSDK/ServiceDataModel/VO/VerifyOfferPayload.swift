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

public struct VpOfferWrapper: Jsonable {
    public var txId: String?
    public var payload: VerifyOfferPayload
    
    public init(txId: String? = nil, payload: VerifyOfferPayload) {
        self.txId = txId
        self.payload = payload
    }
}

public struct VerifyOfferPayload: Jsonable {
    public var offerId: String
    public var type: OfferTypeEnum
    public var mode: PresentModeEnum
    public var device: String
    public var service: String
    public var endpoints: [String]
    public var validUntil: String
    public var locked: Bool = false
    
    public init(offerId: String, type: OfferTypeEnum, mode: PresentModeEnum, device: String, service: String, endpoints: [String], validUntil: String, locked: Bool) {
        self.offerId = offerId
        self.type = type
        self.mode = mode
        self.device = device
        self.service = service
        self.endpoints = endpoints
        self.validUntil = validUntil
        self.locked = locked
    }
}
