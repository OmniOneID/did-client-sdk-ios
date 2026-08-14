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

/// Where a credential's revocation status is published, as an IETF Token Status List entry.
///
/// A credential says nothing about its own status: it points at a list, and whoever wants the
/// answer fetches that list and reads the entry at `idx`. Both credential formats this SDK issues
/// carry the reference the same way — `status.status_list` with these two members — so one type
/// serves both, and a screen does not branch on format to find out where to look.
///
/// The SDK exposes the reference and stops there. It does not fetch the list, decode its bitstring,
/// or decide whether a credential is revoked or suspended; the status list token is signed by the
/// issuer and lives behind a URL, and reading it is a network round trip on someone else's clock.
/// The wallet app owns that call and the judgement that follows.
public struct StatusListReference: Sendable, Equatable {

    /// The URL the status list token is published at.
    public let uri: String

    /// This credential's position in the list the `uri` resolves to.
    public let idx: Int

    /// - Parameters:
    ///   - uri: The URL the status list token is published at.
    ///   - idx: This credential's position in that list.
    public init(uri: String, idx: Int) {
        self.uri = uri
        self.idx = idx
    }
}

extension StatusListReference {

    /// Reads the reference out of an mdoc's `MobileSecurityObject`.
    ///
    /// - Parameter status: The MSO's `status` member, or `nil` when it has none.
    /// - Returns: The reference, or `nil` when the document carries no status at all.
    /// - Throws: `OID4VCManagerError.invalidMdoc` when a `status` is present but unreadable.
    static func decode(mso status: CBOR?) throws -> StatusListReference? {
        guard let status else { return nil }
        guard case let .map(fields) = status else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO status is not a map").getError()
        }
        // An MSO may reference other status mechanisms alongside this one, so a status without a
        // status_list is a document this SDK has nothing to say about, not a malformed one.
        guard let entry = fields["status_list"] else { return nil }
        guard case let .map(members) = entry else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO status_list is not a map").getError()
        }
        guard case let .utf8String(uri)? = members["uri"] else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO status_list has no uri").getError()
        }
        guard let idx = members["idx"]?.uint64Value else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO status_list has no idx").getError()
        }
        guard let reference = StatusListReference(validating: uri, idx: idx) else {
            throw OID4VCManagerError.invalidMdoc(detail: "MSO status_list is out of range").getError()
        }
        return reference
    }

    /// Reads the reference out of an SD-JWT's issuer-signed payload.
    ///
    /// The claim is never selectively disclosable, so the payload is the only place to look: a
    /// credential whose payload has no `status` has no status, whatever its disclosures hold.
    ///
    /// - Parameter payload: The issuer JWT's decoded payload.
    /// - Returns: The reference, or `nil` when the credential carries no status at all.
    /// - Throws: `OID4VCManagerError.invalidJWS` when a `status` is present but unreadable.
    static func decode(payload: [String: Any]) throws -> StatusListReference? {
        guard let status = payload["status"] else { return nil }
        guard let fields = status as? [String: Any] else {
            throw OID4VCManagerError.invalidJWS(detail: "status is not an object").getError()
        }
        guard let entry = fields["status_list"] else { return nil }
        guard let members = entry as? [String: Any] else {
            throw OID4VCManagerError.invalidJWS(detail: "status_list is not an object").getError()
        }
        guard let uri = members["uri"] as? String else {
            throw OID4VCManagerError.invalidJWS(detail: "status_list has no uri").getError()
        }
        guard let idx = members["idx"] as? Int else {
            throw OID4VCManagerError.invalidJWS(detail: "status_list has no idx").getError()
        }
        guard idx >= 0, let reference = StatusListReference(validating: uri, idx: UInt64(idx)) else {
            throw OID4VCManagerError.invalidJWS(detail: "status_list is out of range").getError()
        }
        return reference
    }

    /// A reference only if both members can be acted on: an empty `uri` names nothing to fetch, and
    /// an `idx` past `Int` cannot index the list once it is decoded.
    private init?(validating uri: String, idx: UInt64) {
        guard !uri.isEmpty, let idx = Int(exactly: idx) else { return nil }
        self.init(uri: uri, idx: idx)
    }
}
