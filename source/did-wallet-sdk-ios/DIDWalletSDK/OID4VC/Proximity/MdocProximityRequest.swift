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

/// One match: a requested document, and a stored document that can fill at least one of its
/// elements.
///
/// Filling all of them is not required — what cannot be filled is listed in `missing`. The word
/// "satisfied" is avoided on purpose: the standard defines it as *all* requested elements being
/// returned, and this type does not require that.
public struct MdocRequestedDocument
{
    /// The zero-based index into `DeviceRequest.docRequests` this element answers.
    ///
    /// `docType` cannot identify a request: `docRequests` is `[+DocRequest]`, so a reader may ask
    /// for the same document type twice with different elements.
    public let docRequestIndex: Int
    /// The requested `ItemsRequest.docType`.
    public let docType: String
    /// The stored document that can fill at least one requested element.
    ///
    /// The same value the listing APIs return as `MdocCredentialItem.id`, so the app can line the
    /// two up.
    public let credentialId: String
    /// The elements to disclose, as codes. Built by `MdocClaimIndex`; never split or assembled by
    /// the app.
    public let claimCodes: [String]
    /// The reader's retention intent per code, over `claimCodes` and `missing` together — every
    /// element the request named for this document. Output only: it is not written to the wire, and
    /// `createDeviceResponse` does not read it back.
    public let intentToRetain: [String: Bool]
    /// Requested elements this document cannot supply, in the same code form as `claimCodes`.
    ///
    /// "Cannot supply" covers not holding the element and holding it under a code that names two
    /// elements — an ambiguous code cannot be resolved back to one element without guessing.
    public let missing: [String]

    public init(docRequestIndex: Int,
                docType: String,
                credentialId: String,
                claimCodes: [String],
                intentToRetain: [String: Bool],
                missing: [String])
    {
        self.docRequestIndex = docRequestIndex
        self.docType = docType
        self.credentialId = credentialId
        self.claimCodes = claimCodes
        self.intentToRetain = intentToRetain
        self.missing = missing
    }
}

/// One element a reader asked for.
struct MdocRequestedElement: Equatable
{
    let namespace: String
    let elementIdentifier: String
    /// The reader's declared retention intent. Carried to the consent screen; the obligation it
    /// creates is the reader's (IS 8.3.2.1.2.1).
    let intentToRetain: Bool
}

/// One decoded `DocRequest`.
struct MdocDocRequest
{
    let index: Int
    let docType: String
    /// In the order the reader wrote them.
    let elements: [MdocRequestedElement]
}

/// Decodes `DeviceRequest` far enough to match it.
///
/// Two things are deliberately not done. `version` is not compared — DIS lets a conforming reader
/// send `"1.1"` once it includes `deviceRequestInfo` or `readerAuthAll`, and refusing on the string
/// would block a legitimate reader. `readerAuth` is not read at all: it is optional in the CDDL, so
/// leaving it alone is conformant, and reader authentication is out of this design's scope.
enum MdocDeviceRequestDecoder
{
    static func decode(_ deviceRequest: [UInt8]) throws -> [MdocDocRequest]
    {
        guard case let .map(top)? = try? CBOR.decode(deviceRequest)
        else
        {
            throw OID4VCManagerError.invalidDeviceRequest(detail: "not a map").getError()
        }
        guard case let .array(docRequests)? = top["docRequests"]
        else
        {
            throw OID4VCManagerError.invalidDeviceRequest(detail: "no docRequests").getError()
        }

        return try docRequests.enumerated().map { index, element in
            try decodeDocRequest(element, at: index)
        }
    }

    // MARK: - Private

    private static func decodeDocRequest(_ element: CBOR, at index: Int) throws -> MdocDocRequest
    {
        guard case let .map(docRequest) = element
        else
        {
            throw OID4VCManagerError.invalidDeviceRequest(
                detail: "docRequests[\(index)] is not a map").getError()
        }
        // The items request is embedded CBOR: the issuer of the request hashed these bytes, so they
        // are opened rather than rebuilt.
        guard case let .tagged(tag, payload)? = docRequest["itemsRequest"],
              tag.rawValue == 24,
              case let .byteString(itemsRequestBytes) = payload
        else
        {
            throw OID4VCManagerError.invalidDeviceRequest(
                detail: "docRequests[\(index)].itemsRequest is not tagged 24").getError()
        }
        guard case let .map(itemsRequest)? = try? CBOR.decode(itemsRequestBytes)
        else
        {
            throw OID4VCManagerError.invalidDeviceRequest(
                detail: "docRequests[\(index)].itemsRequest is not a map").getError()
        }
        guard case let .utf8String(docType)? = itemsRequest["docType"]
        else
        {
            throw OID4VCManagerError.invalidDeviceRequest(
                detail: "docRequests[\(index)] has no docType").getError()
        }
        guard case let .map(nameSpaces)? = itemsRequest["nameSpaces"]
        else
        {
            throw OID4VCManagerError.invalidDeviceRequest(
                detail: "docRequests[\(index)] has no nameSpaces").getError()
        }

        var elements: [MdocRequestedElement] = []
        for (namespaceKey, dataElements) in nameSpaces
        {
            guard case let .utf8String(namespace) = namespaceKey,
                  case let .map(items) = dataElements
            else
            {
                throw OID4VCManagerError.invalidDeviceRequest(
                    detail: "docRequests[\(index)].nameSpaces is malformed").getError()
            }
            for (identifierKey, retain) in items
            {
                guard case let .utf8String(elementIdentifier) = identifierKey,
                      case let .boolean(intentToRetain) = retain
                else
                {
                    throw OID4VCManagerError.invalidDeviceRequest(
                        detail: "docRequests[\(index)].nameSpaces[\(namespace)] is malformed")
                        .getError()
                }
                elements.append(MdocRequestedElement(namespace: namespace,
                                                     elementIdentifier: elementIdentifier,
                                                     intentToRetain: intentToRetain))
            }
        }

        return MdocDocRequest(index: index, docType: docType, elements: elements)
    }
}

/// Pairs decoded requests with stored documents.
enum MdocRequestMatcher
{
    /// A stored document offered as a candidate.
    struct Candidate
    {
        let credentialId: String
        let mdoc: Mdoc
    }

    /// Matches every request against every candidate of the same document type.
    ///
    /// A document is a candidate when it can fill **at least one** requested element; the rest go to
    /// `missing`. Requests no document can answer drop out of the result entirely, which is how "we
    /// can give nothing for this request" is expressed — the app compares against the indices it
    /// sent. Whether a partial answer is enough is the reader's business rule, so nothing here
    /// judges it.
    ///
    /// - Throws: `noMatchedMdocDocuments` when no request has a candidate. That is the only failure.
    static func match(docRequests: [MdocDocRequest],
                      candidates: [Candidate]) throws -> [MdocRequestedDocument]
    {
        var matched: [MdocRequestedDocument] = []

        for docRequest in docRequests
        {
            for candidate in candidates where candidate.mdoc.docType == docRequest.docType
            {
                if let element = matchOne(docRequest: docRequest, candidate: candidate)
                {
                    matched.append(element)
                }
            }
        }

        guard !matched.isEmpty
        else
        {
            throw OID4VCManagerError.noMatchedMdocDocuments.getError()
        }

        // Deterministic, and deliberately not a ranking: the holder chooses.
        return matched.sorted
        {
            $0.docRequestIndex != $1.docRequestIndex
                ? $0.docRequestIndex < $1.docRequestIndex
                : $0.credentialId < $1.credentialId
        }
    }

    // MARK: - Private

    private static func matchOne(docRequest: MdocDocRequest,
                                 candidate: Candidate) -> MdocRequestedDocument?
    {
        let index = MdocClaimIndex.build(mdoc: candidate.mdoc)

        var claimCodes: [String] = []
        var missing: [String] = []
        var intentToRetain: [String: Bool] = [:]

        // The reader's order is kept: the consent screen shows the request as it was made.
        for element in docRequest.elements
        {
            let code = MdocClaimIndex.code(namespace: element.namespace,
                                           elementIdentifier: element.elementIdentifier)
            intentToRetain[code] = element.intentToRetain

            if canDisclose(code: code, element: element, index: index)
            {
                claimCodes.append(code)
            }
            else
            {
                missing.append(code)
            }
        }

        guard !claimCodes.isEmpty else { return nil }

        return MdocRequestedDocument(docRequestIndex: docRequest.index,
                                     docType: docRequest.docType,
                                     credentialId: candidate.credentialId,
                                     claimCodes: claimCodes,
                                     intentToRetain: intentToRetain,
                                     missing: missing)
    }

    /// Whether the document can hand over exactly the element that was asked for.
    ///
    /// An ambiguous code is treated as not holdable even though the element is there: the code is
    /// the only handle presentation has, and resolving it would mean guessing which of two elements
    /// the holder agreed to.
    private static func canDisclose(code: String,
                                    element: MdocRequestedElement,
                                    index: MdocClaimIndex) -> Bool
    {
        guard let entry = index.entry(for: code), !entry.isAmbiguous else { return false }
        // A code built from a different pair can collide with this one; the entry has to name the
        // element that was actually requested.
        return entry.namespace == element.namespace
            && entry.elementIdentifier == element.elementIdentifier
    }
}
