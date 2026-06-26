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

import Foundation

/// Payload of a Key-Binding JWT (`kb+jwt`) presented alongside an SD-JWT in an OID4VP response.
///
/// `sdHash` is base64url(SHA-256(presented SD-JWT)) — the issuer JWT plus the selected disclosures
/// (trailing `~`, KB-JWT excluded). Explicit `CodingKeys` emit `sd_hash`; this type is encode-only.
struct KBJWTPayload: Jsonable, FromSnake
{
    var aud: String
    var nonce: String
    var iat: Int = Int(Date().timeIntervalSince1970)
    var sdHash: String
}
