/*
 * Copyright 2024-2025 OmniOne.
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

public struct Option: Jsonable {
    public var allowUserInit: Bool
    public var allowIssuerInit: Bool
    public var delegatedIssuance: Bool
}

public struct VCPlan: Jsonable
{
    public struct CredentialDefinition: Jsonable
    {
        public var id: String
        public var schemaId: String
    }
    
    public var vcPlanId: String
    public var name: String
    public var description: String
    public var url: String?
    public var logo: LogoImage?
    public var validFrom: String?
    public var validUntil: String?
    public var tags: [String]?
    public var credentialSchema: IssueProfile.Profile.CredentialSchema
    public var option: Option
    public var delegate: String?
    public var allowedIssuers: [String]?
    public var manager: String
    
    public var credentialDefinition : VCPlan.CredentialDefinition?
    
    public init(vcPlanId: String, name: String, description: String, url: String? = nil, logo: LogoImage? = nil, validFrom: String? = nil, validUntil: String? = nil, tags: [String]? = nil, credentialSchema: IssueProfile.Profile.CredentialSchema, option: Option, delegate: String? = nil, allowedIssuers: [String]? = nil, manager: String, credentialDefinition : VCPlan.CredentialDefinition?)
    {
        self.vcPlanId = vcPlanId
        self.name = name
        self.description = description
        self.url = url
        self.logo = logo
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.tags = tags
        self.credentialSchema = credentialSchema
        self.option = option
        self.delegate = delegate
        self.allowedIssuers = allowedIssuers
        self.manager = manager
        
        self.credentialDefinition = credentialDefinition
    }
    
}
