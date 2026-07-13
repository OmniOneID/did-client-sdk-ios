//
/*
 * Copyright 2026 OmniOne.
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
    

public protocol CredentialItem: Identifiable {
    var id: String { get }
    var format: CredentialFormat { get }
}

public enum CredentialFormat { case vcdm, sdJwtVc, msoMdoc }

public struct VCDMCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let vc: VerifiableCredential
    public let zkp: ZKPCredential?
}

public struct SdJwtCredentialItem: CredentialItem
{
    public let id: String
    public let format: CredentialFormat
    public let configurationId: String
    public let kid: String
    public let credentialIdentifier: String?
    public let sdjwt: SDJWT
}


