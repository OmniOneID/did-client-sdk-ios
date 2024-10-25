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

public struct VCMeta: Jsonable {
    public var vcId: String
    public var issuer: Provider
    public var did: String
    public var credentialSchema: VCSchema
    public var status: VCStatusEnum
    public var issuanceDate: String
    public var validFrom: String
    public var validUntil: String
    public var formatVersion: String
    public var language: String
    
    public init(vcId: String, issuer: Provider, did: String, credentialSchema: VCSchema, status: VCStatusEnum, issuanceDate: String, validFrom: String, validUntil: String, formatVersion: String, language: String) {
        self.vcId = vcId
        self.issuer = issuer
        self.did = did
        self.credentialSchema = credentialSchema
        self.status = status
        self.issuanceDate = issuanceDate
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.formatVersion = formatVersion
        self.language = language
    }
}

