/*
 * Copyright 2024-2026 OmniOne.
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
import CryptoKit
import LocalAuthentication

class WalletService: WalletServiceImpl {
    
    let walletCore: WalletCoreImpl
    
    public init(_ walletCore: WalletCoreImpl) {
        self.walletCore = walletCore
    }
    
    public func deleteWallet(deleteAll: Bool) throws {
        
        if deleteAll
        {
            try CoreDataManager.shared.deleteUser()
            try CoreDataManager.shared.deleteToken()
            try CoreDataManager.shared.deleteCaPakage()
        }
        try walletCore.deleteWallet(deleteAll:deleteAll)
    }
    
    public func createWallet(tasURL: String, walletURL: String) async throws -> Bool {
        
        guard !tasURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("tasURL").getError()
        }
        guard !walletURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("walletURL").getError()
        }
        
        // Fetch and save CA (Certified App) information
        try await self.fetchCaInfo(tasURL: tasURL)
        
        WalletLogger.debug("fetchCaInfo completed")
        
        // Create a device key (device document)
        let deviceKey = try self.createDeviceDocument()
        WalletLogger.debug("deviceKey completed")
        
        WalletLogger.debug("deviceKey: \(try deviceKey.toJson(isPretty: true))")
        
        // Register the wallet using the provided URLs and the generated device key
        return try await self.requestRegisterWallet(tasURL: tasURL, walletURL: walletURL, ownerDidDoc: deviceKey)
    }
    
    public func requestVp(hWalletToken: String, claimInfos: [ClaimInfo], verifierProfile: _RequestProfile?, APIGatewayURL: String, passcode: String? = nil) async throws -> (AccE2e, Data) {
        
//        guard !hWalletToken.isEmpty else {
//            throw WalletAPIError.verifyParameterFail("hWalletToken").getError()
//        }
        guard let verifierProfile = verifierProfile else {
            throw WalletAPIError.verifyParameterFail("verifierProfile").getError()
        }
        guard !APIGatewayURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("APIGatewayURL").getError()
        }
        
        let roleType = RoleTypeEnum.Verifier
        // checkCertVcRef
        try await WalletToken(self.walletCore).verifyCertVcRef(roleType: roleType, providerDID:verifierProfile.profile.profile.verifier.did, providerURL: verifierProfile.profile.profile.verifier.certVcRef, APIGatewayURL: APIGatewayURL)
        
        let holderDidDoc = try WalletAPI.shared.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                          proofPurpose: ProofPurpose.keyAgreement,
                          verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#keyagree",
                          type: ProofType.secp256r1Signature2018)
        
        let reqE2e = verifierProfile.profile.profile.process.reqE2e
        let curve = reqE2e.curve
        let cipher = reqE2e.cipher
        let padding = reqE2e.padding
        
        let keyPair = try CryptoUtils.generateECKeyPair(ecType: curve)
        let iv = try CryptoUtils.generateNonce(size: 16)
        
        var accE2e = AccE2e(publicKey: MultibaseUtils.encode(type: MultibaseType.base58BTC,
                                                             data: keyPair.publicKey),
                            iv: MultibaseUtils.encode(type: MultibaseType.base58BTC,
                                                      data: iv),
                            proof: proof)
        
        let source = try DigestUtils.getDigest(source: accE2e.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature = try WalletAPI.shared.sign(keyId: "keyagree", data: source, type: DidDocumentType.HolderDidDocumnet)
        accE2e.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
        
        
//        let presentationInfo = PresentationInfo(holder: holderDidDoc.id,
//                                                validFrom: Date.getUTC0Date(seconds: 0),
//                                                validUntil: Date.getUTC0Date(seconds: 5000),
//                                                verifierNonce: verifierProfile.profile.profile.process.verifierNonce)
//        
//        var vp = try walletCore.makePresentation(claimInfos:claimInfos!,
//                                                 presentationInfo: presentationInfo)
//        
//        let authType = passcode != nil ? "#pin" : "#bio"
//        WalletLogger.debug("vp: \(try vp.toJson())")
//        let vpProof = VPProof(created: Date.getUTC0Date(seconds: 0),
//                            proofPurpose: ProofPurpose.assertionMethod,
//                            verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + authType,
//                            type: ProofType.secp256r1Signature2018)
//        vp.proof = vpProof
//        let vpSource = try DigestUtils.getDigest(source: vp.toJsonData(), digestEnum: DigestEnum.sha256)
//        
//        let vpSignature: Data?
//        if passcode != nil {
//            vpSignature = try walletCore.sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: vpSource, type: DidDocumentType.HolderDidDocumnet)
//        } else {
//            vpSignature = try walletCore.sign(keyId: "bio", pin: nil, data: vpSource, type: DidDocumentType.HolderDidDocumnet)
//        }
//        vp.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: vpSignature!)
        
        let vp = try createVp(
            claimInfos: claimInfos,
            passcode: passcode,
            verifierNonce: verifierProfile.profile.profile.process.verifierNonce
        )
        let serverNonce = try MultibaseUtils.decode(encoded: verifierProfile.profile.profile.process.reqE2e.nonce)
        
        let sessKey = try CryptoUtils.generateSharedSecret(ecType: curve,
                                                           privateKey: keyPair.privateKey,
                                                           publicKey: MultibaseUtils.decode(encoded: verifierProfile.profile.profile.process.reqE2e.publicKey))
        
        let clientMergedSharedSecret = WalletUtil.mergeSharedSecretAndNonce(sharedSecret: sessKey, nonce: serverNonce, symmetricCipherType: cipher)
        
        let encVp = try CryptoUtils.encrypt(plain: vp.toJsonData(),
                                            info: CipherInfo(cipherType: cipher,
                                                             padding: padding),
                                            key: clientMergedSharedSecret,
                                            iv: iv)
        return (accE2e, encVp)
    }
    
    func createVp(claimInfos: [ClaimInfo],
                  passcode: String?,
                  verifierNonce: String,
                  challenge: OIDV4VPChallenge? = nil) throws -> VerifiablePresentation
    {
        let holderDidDoc = try WalletAPI.shared.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        
        let presentationInfo = PresentationInfo(holder: holderDidDoc.id,
                                                validFrom: Date.getUTC0Date(seconds: 0),
                                                validUntil: Date.getUTC0Date(seconds: 5000),
                                                verifierNonce: verifierNonce)
        
        var vp = try walletCore.makePresentation(claimInfos:claimInfos,
                                                 presentationInfo: presentationInfo)
        
        let authType = passcode != nil ? "#pin" : "#bio"
        WalletLogger.debug("vp: \(try vp.toJson())")
        let vpProof = VPProof(
            created: Date.getUTC0Date(seconds: 0),
            proofPurpose: ProofPurpose.assertionMethod,
            verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + authType,
            type: ProofType.secp256r1Signature2018,
            domain: challenge?.domain,
            challenge: challenge?.challenge
        )
        
        vp.proof = vpProof
        let vpSource = try DigestUtils.getDigest(source: vp.toJsonData(), digestEnum: DigestEnum.sha256)
        
        let vpSignature: Data?
        if passcode != nil {
            vpSignature = try walletCore.sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: vpSource, type: DidDocumentType.HolderDidDocumnet)
        } else {
            vpSignature = try walletCore.sign(keyId: "bio", pin: nil, data: vpSource, type: DidDocumentType.HolderDidDocumnet)
        }
        vp.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: vpSignature!)

        return vp
    }

    // MARK: - OID4VP

    /// Matches the credentials stored in the wallet against the verifier's DCQL query.
    ///
    /// Internal steps, in order:
    /// 1. Validate the DCQL query — `OID4VCManagerError.invalidDCQLQuery`.
    /// 2. Resolve the single presentation format the query asks for —
    ///    `OID4VCManagerError.unsupportedPresentationFormat`.
    /// 3. Load the stored credentials of that format from `WalletCore` and run DCQL matching —
    ///    `OID4VCManagerError.noMatchedCredentials`, `.credentialSetsNotSatisfied`.
    /// 4. Flatten the match into one entry per credential, in DCQL declaration order.
    ///
    /// - Parameter authRequest: Verifier authorization request carrying the DCQL query.
    /// - Returns: One `MatchedCredential` per matched credential, each naming the claims it would
    ///   disclose (all of the credential's when the query constrains none); before calling
    ///   `createVpToken` the app may drop entries, but not narrow their `claimCodes` — the codes are
    ///   opaque to the app, to display and compare but never to split or assemble.
    func matchCredentials(authRequest: AuthorizationRequest) throws -> [MatchedCredential]
    {
        let queries = try DCQLCredentialMatcher.validatedQueries(authRequest)
        let format = try presentationFormat(of: queries)
        let infos = try matchStoredCredentials(authRequest: authRequest, format: format)
        return flattenMatches(infos, queries: queries)
    }

    /// Resolves the one credential format the DCQL query asks for: a single request maps to a
    /// single presentation pipeline, so mixed formats are rejected.
    private func presentationFormat(of queries: [DCQLQuery.CredentialQuery]) throws -> String
    {
        // Validation runs first and rejects a query without a format, so an empty set cannot occur.
        let formats = Set(queries.compactMap { $0.format })
        guard formats.count == 1, let format = formats.first
        else
        {
            throw OID4VCManagerError.unsupportedPresentationFormat(
                format: "mixed credential formats are not supported: \(formats.sorted().joined(separator: ", "))").getError()
        }
        return format
    }

    /// Loads the stored credentials of `format` and matches them against the query.
    /// The service owns only the wallet fetch; DCQL matching lives in `DCQLCredentialMatcher`.
    private func matchStoredCredentials(authRequest: AuthorizationRequest,
                                        format: String) throws -> [ClientID: [ClaimInfo]]
    {
        if format == VerifiableCredentialAdapter.format
        {
            return try DCQLCredentialMatcher.matchCredentials(authRequest: authRequest,
                                                              credentials: walletCore.getAllCredentials())
        }
        // The store holds every OID4VC format together, so each branch narrows to the credentials
        // that can answer the query at all — a credential of another format never matches.
        if SDJWTPresenter.supportedFormats.contains(format)
        {
            let sdJwtCredentials = try walletCore.getAllOID4VCICredentials().compactMap { $0 as? SdJwtCredentialItem }
            return try DCQLCredentialMatcher.matchCredentials(authRequest: authRequest,
                                                              sdJwtCredentials: sdJwtCredentials)
        }
        if MdocCredentialAdapter.supportedFormats.contains(format)
        {
            let mdocCredentials = try walletCore.getAllOID4VCICredentials().compactMap { $0 as? MdocCredentialItem }
            return try DCQLCredentialMatcher.matchCredentials(authRequest: authRequest,
                                                              mdocCredentials: mdocCredentials)
        }
        throw OID4VCManagerError.unsupportedPresentationFormat(format: format).getError()
    }

    /// Flattens the per-query match to one entry per credential, in DCQL declaration order
    /// (deterministic).
    private func flattenMatches(_ infos: [ClientID: [ClaimInfo]],
                                queries: [DCQLQuery.CredentialQuery]) -> [MatchedCredential]
    {
        return queries.flatMap { query -> [MatchedCredential] in
            guard let id = query.id else { return [] }
            return (infos[id] ?? []).map {
                MatchedCredential(queryId: id, credentialId: $0.credentialId, claimCodes: $0.claimCodes)
            }
        }
    }

    /// Builds the `vp_token` for the credentials the app selected and encodes the authorization
    /// response body to send to the verifier.
    ///
    /// Internal steps, in order:
    /// 1. Validate the arguments — `WalletAPIError.verifyParameterFail`.
    /// 2. Validate the selection against a fresh match of the same request —
    ///    `OID4VCManagerError.invalidSelectedCredentials`, `.credentialSetsNotSatisfied`.
    /// 3. Regroup the selection by DCQL query id, preserving first-seen order.
    /// 4. Per query, resolve its presentation format and build the `vp_token` element —
    ///    `OID4VCManagerError.invalidDCQLQuery`, `.unsupportedPresentationFormat`,
    ///    `.credentialNotFound`, `.holderKeyNotFound`, and `.invalidSelectedCredentials` when a code
    ///    resolves to no claim of its credential or to more than one.
    /// 5. Assemble the response body and, for `direct_post.jwt`, JWE-seal it —
    ///    `OID4VCManagerError.unsupportedResponseMode`, `.missingVerifierEncryptionKey`,
    ///    `.unsupportedResponseEncryption`.
    ///
    /// - Parameters:
    ///   - authRequest: Verifier authorization request the selection was matched against.
    ///   - matchedCredentials: The credentials to present, as returned by `matchCredentials` minus
    ///     the entries the holder refused. Each entry keeps the `claimCodes` matching produced.
    ///   - passcode: PIN when the holder key is PIN-protected, otherwise nil (biometrics).
    /// - Returns: The transfer-ready response body.
    func createVpToken(authRequest: AuthorizationRequest,
                       matchedCredentials: [MatchedCredential],
                       passcode: String?) throws -> Data
    {
        guard !matchedCredentials.isEmpty
        else
        {
            throw WalletAPIError.verifyParameterFail("matchedCredentials").getError()
        }

        // The app drops what the holder refused, so the selection is untrusted input: re-match the
        // request and gate the selection on it before anything is built or sent.
        try DCQLCredentialMatcher.validateSelection(matchedCredentials,
                                                    against: matchCredentials(authRequest: authRequest),
                                                    dcqlQuery: authRequest.dcqlQuery)

        var vpToken: [String: [AnyJSON]] = [:]
        for (queryId, group) in groupedByQueryId(matchedCredentials)
        {
            vpToken[queryId] = try vpTokenElements(queryId: queryId,
                                                   group: group,
                                                   authRequest: authRequest,
                                                   passcode: passcode)
        }

        // Assemble the authorization response and, for direct_post.jwt, JWE-seal it.
        return try OID4VPResponseUtil.encodeResponseBody(authRequest: authRequest, vpToken: vpToken)
    }

    // MARK: - Proximity (ISO/IEC 18013-5)

    /// Finds the stored documents that can answer a proximity request.
    ///
    /// Every mdoc the wallet holds is a candidate; whether one can fill anything is decided by the
    /// matcher. Documents outside their validity window are **not** filtered out — that judgement
    /// belongs to the reader, and the holder may have nothing else to offer.
    func matchMdocRequest(deviceRequest: Data) throws -> [MdocRequestedDocument]
    {
        let docRequests = try MdocDeviceRequestDecoder.decode([UInt8](deviceRequest))
        return try MdocRequestMatcher.match(docRequests: docRequests,
                                            candidates: try mdocCandidates())
    }

    /// Builds the `DeviceResponse` for what the holder agreed to.
    ///
    /// The request is matched again here rather than trusted: the app returns a selection the
    /// holder pruned, and only a fresh match says what this wallet could actually have offered.
    func createDeviceResponse(deviceRequest: Data,
                              sessionTranscript: Data,
                              selected: [MdocRequestedDocument],
                              passcode: String?) throws -> MdocDeviceResponse
    {
        let matched = try matchMdocRequest(deviceRequest: deviceRequest)
        try MdocProximityResponseBuilder.validate(selected: selected, against: matched)

        let items = try walletCore.getAllOID4VCICredentials().compactMap { $0 as? MdocCredentialItem }
        var documents: [String: Mdoc] = [:]
        var keyIds: [String: String] = [:]
        for element in selected
        {
            guard let item = items.first(where: { $0.id == element.credentialId })
            else { throw OID4VCManagerError.credentialNotFound.getError() }
            guard try walletCore.isSavedKey(keyId: item.kid)
            else { throw OID4VCManagerError.holderKeyNotFound.getError() }

            documents[element.credentialId] = item.mdoc
            keyIds[element.credentialId] = item.kid
        }

        // One authentication context for the whole submission: a Secure Enclave key that asks the
        // user to confirm asks once, not once per document (5장). It dies with this call.
        return try MdocProximityResponseBuilder.build(
            selected: selected,
            documents: documents,
            sessionTranscript: [UInt8](sessionTranscript),
            keys: WalletKeyOperations(walletCore: walletCore,
                                      keyIds: keyIds,
                                      passcode: passcode,
                                      context: LAContext()))
    }

    /// Every stored mdoc, as a matching candidate.
    private func mdocCandidates() throws -> [MdocRequestMatcher.Candidate]
    {
        return try walletCore.getAllOID4VCICredentials()
            .compactMap { $0 as? MdocCredentialItem }
            .map { .init(credentialId: $0.id, mdoc: $0.mdoc) }
    }

    /// The wallet's keys, as the response builder needs them.
    ///
    /// The passcode is captured here rather than passed down: it belongs to this one call, and the
    /// builder has no business holding it.
    private struct WalletKeyOperations: MdocDeviceKeyOperations
    {
        let walletCore: any WalletCoreImpl
        let keyIds: [String: String]
        let passcode: String?
        /// Shared by every key use of this submission, so one confirmation covers them all.
        let context: LAContext

        func canKeyAgree(credentialId: String) throws -> Bool
        {
            guard let keyId = keyIds[credentialId] else { return false }
            return try walletCore.canKeyAgree(keyId: keyId)
        }

        func keyAgreement(credentialId: String, readerPublicKey: [UInt8]) throws -> [UInt8]
        {
            guard let keyId = keyIds[credentialId]
            else { throw OID4VCManagerError.holderKeyNotFound.getError() }
            do
            {
                return [UInt8](try walletCore.keyAgreement(keyId: keyId,
                                                            pin: passcode?.data(using: .utf8),
                                                            publicKey: Data(readerPublicKey),
                                                            context: context))
            }
            catch let error as WalletCoreError
                where error.code == SecureEnclaveError.keyAgreementUnsupported.getError().code
            {
                // The key cannot do ECDH after all: the one failure the builder may answer with a
                // signature instead.
                throw MdocDeviceKeyError.keyAgreementUnsupported
            }
        }

        func sign(credentialId: String, digest: Data) throws -> Data
        {
            guard let keyId = keyIds[credentialId]
            else { throw OID4VCManagerError.holderKeyNotFound.getError() }
            return try walletCore.sign(keyId: keyId,
                                       pin: passcode?.data(using: .utf8),
                                       data: digest,
                                       type: DidDocumentType.HolderDidDocumnet,
                                       context: context)
        }
    }

    /// Regroups the selection by DCQL query id, preserving first-seen order (deterministic).
    private func groupedByQueryId(
        _ matchedCredentials: [MatchedCredential]
    ) -> [(queryId: String, group: [MatchedCredential])]
    {
        var order: [String] = []
        var grouped: [String: [MatchedCredential]] = [:]
        for mc in matchedCredentials
        {
            if grouped[mc.queryId] == nil { order.append(mc.queryId) }
            grouped[mc.queryId, default: []].append(mc)
        }
        return order.map { (queryId: $0, group: grouped[$0]!) }
    }

    /// Builds the `vp_token` elements of one DCQL query, dispatching on its presentation format.
    private func vpTokenElements(queryId: String,
                                 group: [MatchedCredential],
                                 authRequest: AuthorizationRequest,
                                 passcode: String?) throws -> [AnyJSON]
    {
        let format = try presentationFormat(for: queryId, in: authRequest)

        if format == VerifiableCredentialAdapter.format
        {
            return [try w3cVpTokenElement(group: group, authRequest: authRequest, passcode: passcode)]
        }
        if SDJWTPresenter.supportedFormats.contains(format)
        {
            return try sdJwtVpTokenElements(group: group, authRequest: authRequest, passcode: passcode)
        }
        if MdocPresenter.supportedFormats.contains(format)
        {
            return try mdocVpTokenElements(group: group, authRequest: authRequest, passcode: passcode)
        }
        throw OID4VCManagerError.unsupportedPresentationFormat(format: format).getError()
    }

    /// W3C: reuses the existing VP pipeline unchanged. The VP is carried as an ldp_vp JSON object.
    private func w3cVpTokenElement(group: [MatchedCredential],
                                   authRequest: AuthorizationRequest,
                                   passcode: String?) throws -> AnyJSON
    {
        let claimInfos = group.map { ClaimInfo(credentialId: $0.credentialId, claimCodes: $0.claimCodes) }
        let vp = try createVp(
            claimInfos: claimInfos,
            passcode: passcode,
            verifierNonce: authRequest.nonce,
            challenge: OIDV4VPChallenge(domain: authRequest.clientId, challenge: authRequest.nonce))
        return try JSONDecoder().decode(AnyJSON.self, from: vp.toJsonData())
    }

    /// mdoc: one `DeviceResponse` per credential, each signed with the key the document is bound to.
    ///
    /// The response is bound to this request through the session transcript, which for
    /// `direct_post.jwt` also commits to the verifier's encryption key — so the key is resolved here,
    /// where the request lives, and handed to the presenter rather than looked up inside it.
    private func mdocVpTokenElements(group: [MatchedCredential],
                                     authRequest: AuthorizationRequest,
                                     passcode: String?) throws -> [AnyJSON]
    {
        let items = try walletCore.getOID4VCICredentials(ids: group.map { $0.credentialId })
            .compactMap { $0 as? MdocCredentialItem }

        let responseEncryption: MdocPresenter.ResponseEncryption
        if authRequest.responseMode == "direct_post.jwt"
        {
            let (jwk, _) = try OID4VPResponseUtil.parseResponseEncryption(from: authRequest.clientMetadata)
            responseEncryption = .key(jwk)
        }
        else
        {
            responseEncryption = .none
        }

        return try group.map { mc in
            // A credential stored in another format cannot answer an mdoc query, so it reads here
            // as a credential that is not there.
            guard let item = items.first(where: { $0.id == mc.credentialId })
            else { throw OID4VCManagerError.credentialNotFound.getError() }

            // Wallet-touching key ops live here (walletCore owner); the presenter stays pure.
            guard try walletCore.isSavedKey(keyId: item.kid)
            else { throw OID4VCManagerError.holderKeyNotFound.getError() }

            let token = try MdocPresenter.createVpToken(
                mdoc: item.mdoc,
                claimCodes: mc.claimCodes,
                clientId: authRequest.clientId,
                nonce: authRequest.nonce,
                responseUri: authRequest.responseUri,
                responseEncryption: responseEncryption,
                signDigest: { digest in
                    try self.walletCore.sign(keyId: item.kid,
                                             pin: passcode?.data(using: .utf8),
                                             data: digest,
                                             type: DidDocumentType.HolderDidDocumnet)
                })
            return .string(token)
        }
    }

    /// SD-JWT: one presentation string per credential, each with its own key-bound KB-JWT.
    private func sdJwtVpTokenElements(group: [MatchedCredential],
                                      authRequest: AuthorizationRequest,
                                      passcode: String?) throws -> [AnyJSON]
    {
        let items = try walletCore.getOID4VCICredentials(ids: group.map { $0.credentialId })
            .compactMap { $0 as? SdJwtCredentialItem }
        return try group.map { mc in
            // A credential stored in another format cannot answer an SD-JWT query, so it reads
            // here as a credential that is not there.
            guard let item = items.first(where: { $0.id == mc.credentialId })
            else { throw OID4VCManagerError.credentialNotFound.getError() }

            // Wallet-touching key ops live here (walletCore owner); the presenter stays pure.
            guard try walletCore.isSavedKey(keyId: item.kid),
                  let keyInfo = try walletCore.getKeyInfos(ids: [item.kid]).first
            else { throw OID4VCManagerError.holderKeyNotFound.getError() }
            let holderJwk = try P256V.decompressPublicKey(
                compressedPublicKey: MultibaseUtils.decode(encoded: keyInfo.publicKey)).getPublicKeyJwk()

            let token = try SDJWTPresenter.createVpToken(
                sdjwt: item.sdjwt,
                claimCodes: mc.claimCodes,
                aud: authRequest.clientId,
                nonce: authRequest.nonce,
                holderJwk: holderJwk,
                signDigest: { digest in
                    try self.walletCore.sign(keyId: item.kid,
                                             pin: passcode?.data(using: .utf8),
                                             data: digest,
                                             type: .HolderDidDocumnet)
                })
            return .string(token)
        }
    }

    /// Resolves the presentation format of one DCQL query. Selection validation already rejected
    /// query ids the request does not declare; the guard stays as a defence in depth.
    private func presentationFormat(for queryId: String,
                                    in authRequest: AuthorizationRequest) throws -> String
    {
        guard let query = authRequest.dcqlQuery.credentials?.first(where: { $0.id == queryId })
        else
        {
            throw OID4VCManagerError.invalidSelectedCredentials(
                detail: "no credential query with id '\(queryId)' in the request").getError()
        }
        guard let format = query.format
        else
        {
            throw OID4VCManagerError.invalidDCQLQuery(
                detail: "missing 'format' in credential query '\(queryId)'").getError()
        }
        return format
    }

    public func requestZKProof(hWalletToken:String,
                               selectedReferents : [UserReferent],
                               proofParam: ZKProofParam,
                               proofRequestProfile: _RequestProofRequestProfile?,
                               APIGatewayURL: String) async throws -> (AccE2e, Data)
    {
        
        guard !hWalletToken.isEmpty else {
            throw WalletAPIError.verifyParameterFail("hWalletToken").getError()
        }
        guard let proofRequestProfile = proofRequestProfile else {
            throw WalletAPIError.verifyParameterFail("proofRequestProfile").getError()
        }
        guard !APIGatewayURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("APIGatewayURL").getError()
        }
        
        let roleType = RoleTypeEnum.Verifier
        // checkCertVcRef
        try await WalletToken(self.walletCore).verifyCertVcRef(roleType: roleType, providerDID:proofRequestProfile.proofRequestProfile.profile.verifier.did, providerURL: proofRequestProfile.proofRequestProfile.profile.verifier.certVcRef, APIGatewayURL: APIGatewayURL)
        
        let holderDidDoc = try WalletAPI.shared.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                          proofPurpose: ProofPurpose.keyAgreement,
                          verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#keyagree",
                          type: ProofType.secp256r1Signature2018)
        
        let reqE2e = proofRequestProfile.proofRequestProfile.profile.reqE2e
        let curve = reqE2e.curve
        let cipher = reqE2e.cipher
        let padding = reqE2e.padding
        
        let keyPair = try CryptoUtils.generateECKeyPair(ecType: curve)
        let iv = try CryptoUtils.generateNonce(size: 16)
        
        var accE2e = AccE2e(publicKey: MultibaseUtils.encode(type: MultibaseType.base58BTC,
                                                             data: keyPair.publicKey),
                            iv: MultibaseUtils.encode(type: MultibaseType.base58BTC,
                                                      data: iv),
                            proof: proof)
        
        let source = try DigestUtils.getDigest(source: accE2e.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature = try WalletAPI.shared.sign(keyId: "keyagree", data: source, type: DidDocumentType.HolderDidDocumnet)
        accE2e.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
        
        
        let zkproof = try walletCore.createZKProof(proofRequest: proofRequestProfile.proofRequestProfile.profile.proofRequest,
                                                   selectedReferents: selectedReferents,
                                                   proofParam: proofParam)
        
        let serverNonce = try MultibaseUtils.decode(encoded: proofRequestProfile.proofRequestProfile.profile.reqE2e.nonce)
        let sessKey = try CryptoUtils.generateSharedSecret(ecType: curve,
                                                           privateKey: keyPair.privateKey,
                                                           publicKey: MultibaseUtils.decode(encoded: proofRequestProfile.proofRequestProfile.profile.reqE2e.publicKey))
        
        let clientMergedSharedSecret = WalletUtil.mergeSharedSecretAndNonce(sharedSecret: sessKey, nonce: serverNonce, symmetricCipherType: cipher)
        let encVp = try CryptoUtils.encrypt(plain: zkproof.toJsonData(),
                                            info: CipherInfo(cipherType: cipher,
                                                             padding: padding),
                                            key: clientMergedSharedSecret,
                                            iv: iv)
        return (accE2e, encVp)
    }
    
    private func fetchCaInfo(tasURL: String) async throws
    {
        let path : String = "\(tasURL)/list/api/v1/allowed-ca/list?wallet=org.omnione.did.sdk.wallet"
        
        let allowCAList : AllowCAList = try await CommunicationClient.sendRequest(urlString: path,
                                                                                  httpMethod: .GET)
        
        guard allowCAList.count != 0 else {
            throw WalletAPIError.createWalletFail.getError()
        }
        try CoreDataManager.shared.deleteCaPakage()
        
        for item in allowCAList.items {
            try CoreDataManager.shared.insertCaPakage(pkgName: item)
        }
    }
    
    public func createSignedDIDDoc(passcode: String? = nil) throws -> SignedDIDDoc {
        
        let deviceDidDoc = try walletCore.getDidDocument(type: DidDocumentType.DeviceDidDocument)
        WalletLogger.debug("saved deviceDidDoc: \(try deviceDidDoc.toJson())")
        var holderDidDoc = try walletCore.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        WalletLogger.debug("saved holderDidDoc: \(try holderDidDoc.toJson())")
        let wallet = Wallet(id: Properties.getWalletId()!, did: deviceDidDoc.id)
        let nonce =  try CryptoUtils.generateNonce(size: 16)
        let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: nonce)
        
        var proofArry: [Proof] = .init()
        if try walletCore.isSavedKey(keyId: "pin") {
            var pinProof = Proof(created: Date.getUTC0Date(seconds: 0),
                                 proofPurpose: ProofPurpose.assertionMethod,
                                 verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#pin",
                                 type: ProofType.secp256r1Signature2018)
            
            holderDidDoc.proof = pinProof
            let firstSource = try DigestUtils.getDigest(source: holderDidDoc.toJsonData(), digestEnum: DigestEnum.sha256)
            WalletLogger.debug("assert holderDidDoc Str: \(try holderDidDoc.toJson(isPretty: true))")
            
            let pinSignature = try walletCore.sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: firstSource, type: DidDocumentType.HolderDidDocumnet)
            holderDidDoc.proof = nil
            pinProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: pinSignature)
            proofArry.append(pinProof)
        }
        
        if try walletCore.isSavedKey(keyId: "bio") {
            var bioProof = Proof(created: Date.getUTC0Date(seconds: 0),
                                 proofPurpose: ProofPurpose.assertionMethod,
                                 verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#bio",
                                 type: ProofType.secp256r1Signature2018)
            
            holderDidDoc.proof = bioProof
            let secondSource = try DigestUtils.getDigest(source: holderDidDoc.toJsonData(), digestEnum: DigestEnum.sha256)
            
            WalletLogger.debug("auth holderDidDoc Str: \(try holderDidDoc.toJson(isPretty: true))")
            let bioSignature = try walletCore.sign(keyId: "bio", pin: nil, data: secondSource, type: DidDocumentType.HolderDidDocumnet)
            // (core func)
            holderDidDoc.proof = nil
            bioProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: bioSignature)
            proofArry.append(bioProof)
            
        }
        holderDidDoc.proofs = proofArry
        WalletLogger.debug("final holderDidDoc Str: \(try holderDidDoc.toJson(isPretty: true))")
        let ownerDIDDoc = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: try holderDidDoc.toJsonData())
        // deviceKey
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                          proofPurpose: ProofPurpose.assertionMethod,
                          verificationMethod: deviceDidDoc.id + "?versionId=" + deviceDidDoc.versionId + "#assert",
                          type: ProofType.secp256r1Signature2018)
        
        var signedDidDoc = SignedDIDDoc(ownerDidDoc: ownerDIDDoc, wallet: wallet, nonce: hexNonce, proof: proof)
        let source = try DigestUtils.getDigest(source: signedDidDoc.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature = try walletCore.sign(keyId: "assert", pin: nil, data: source, type: DidDocumentType.DeviceDidDocument)
        signedDidDoc.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
        WalletLogger.debug("signed holderDidDoc Str: \(try signedDidDoc.toJson(isPretty: true))")
        return signedDidDoc
    }
    
    public func createProofs(ownerDidDoc: DIDDocument?, proofPurpose: String) throws -> Data {
        
        guard !proofPurpose.isEmpty else {
            throw WalletAPIError.verifyParameterFail("proofPurpose").getError()
        }
        guard let ownerDidDoc = ownerDidDoc else {
            throw WalletAPIError.verifyParameterFail("ownerDidDoc").getError()
        }
        
        var didDoc = ownerDidDoc
        
        var proofPurposeEnum: ProofPurpose? = nil
        switch proofPurpose {
        case "assert", "pin", "bio":
            proofPurposeEnum = ProofPurpose.assertionMethod
        case "auth":
            proofPurposeEnum = ProofPurpose.authentication
        case "keyagree":
            proofPurposeEnum = ProofPurpose.keyAgreement
        default:
            WalletLogger.debug("proofPurpose: \(proofPurpose)")
        }
        
        didDoc.proof = Proof(created: Date.getUTC0Date(seconds: 0), proofPurpose: proofPurposeEnum!, verificationMethod: didDoc.id+"?versionId="+didDoc.versionId+"#"+proofPurpose, type: ProofType.secp256r1Signature2018)
        let source = try DigestUtils.getDigest(source: didDoc.toJsonData(), digestEnum: DigestEnum.sha256)
        
        return try walletCore.sign(keyId: proofPurpose, pin: nil, data: source, type: DidDocumentType.DeviceDidDocument)
    }
    
    public func createDeviceDocument() throws -> DIDDocument {
        // generate deviceKey
        var didDoc = try walletCore.createDeviceDidDocument()
        var proofArry: [Proof] = .init()
        var assertProof = Proof(created: Date.getUTC0Date(seconds: 0), proofPurpose: ProofPurpose.assertionMethod, verificationMethod: didDoc.id+"?versionId="+didDoc.versionId+"#assert", type: ProofType.secp256r1Signature2018)
        didDoc.proof = assertProof
        let assertSource = try DigestUtils.getDigest(source: didDoc.toJsonData(), digestEnum: DigestEnum.sha256)
        WalletLogger.debug("assert didDoc Str: \(try didDoc.toJson())")
        let assertSignature = try walletCore.sign(keyId: "assert", pin: nil, data: assertSource, type: DidDocumentType.DeviceDidDocument)
        didDoc.proof = nil
        assertProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: assertSignature)
        proofArry.append(assertProof)
        
        var authProof = Proof(created: Date.getUTC0Date(seconds: 0), proofPurpose: ProofPurpose.authentication, verificationMethod: didDoc.id+"?versionId="+didDoc.versionId+"#auth", type: ProofType.secp256r1Signature2018)
        
        didDoc.proof = authProof
        let authSource = try DigestUtils.getDigest(source: didDoc.toJsonData(), digestEnum: DigestEnum.sha256)
        
        WalletLogger.debug("auth didDoc Str: \(try didDoc.toJson())")
        let authSignature = try walletCore.sign(keyId: "auth", pin: nil, data: authSource, type: DidDocumentType.DeviceDidDocument)
        // (core func)
        didDoc.proof = nil
        authProof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: authSignature)
        proofArry.append(authProof)
        didDoc.proofs = proofArry
        WalletLogger.debug("fianl didDoc Str: \(try didDoc.toJson())")
        return didDoc
    }
    
    public func requestRegisterWallet(tasURL: String, walletURL: String, ownerDidDoc: DIDDocument?) async throws -> Bool
    {
        guard !tasURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("tasURL").getError()
        }
        guard !walletURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("walletURL").getError()
        }
        guard let ownerDidDoc = ownerDidDoc else {
            throw WalletAPIError.verifyParameterFail("ownerDidDoc").getError()
        }
        
        let pathForSign = "\(walletURL)/wallet/api/v1/request-sign-wallet"
        let attDIDDoc : AttestedDIDDoc = try await CommunicationClient.sendRequest(urlString: pathForSign,
                                                                                   requestJsonable: ownerDidDoc)
        
        let pathForRegister = "\(tasURL)/tas/api/v1/request-register-wallet"
        
        let reqAttDidDoc = RequestAttestedDIDDoc(id: WalletUtil.generateMessageID(),
                                                 attestedDIDDoc: attDIDDoc)
        
        let _ : ResponseTxId = try await CommunicationClient.sendRequest(urlString: pathForRegister,
                                                                         requestJsonable: reqAttDidDoc)
        
        Properties.setWalletId(id: attDIDDoc.walletId)
        WalletLogger.debug("saved walletId")
        try walletCore.saveDidDocument(type: DidDocumentType.DeviceDidDocument)
        return true
    }
    
    public func bindUser() throws -> Bool {
        
        if let token = try CoreDataManager.shared.selectToken() {
            WalletLogger.debug("bindUser verifyWalletToken reg success")
            try CoreDataManager.shared.insertUser(finalEncKey: "", pii: token.pii)
            return true
        } else {
            WalletLogger.debug("bindUser selectToken fail")
            throw WalletAPIError.selectQueryFail.getError()
        }
    }
    
    public func unbindUser() throws -> Bool {
        return try CoreDataManager.shared.deleteUser()
    }
    
    // user restore (didDoc)
    public func requestRegisterUser(tasURL: String,
                                    txId: String,
                                    serverToken: String,
                                    signedDIDDoc: SignedDIDDoc?) async throws -> _RequestRegisterUser
    {
        guard !tasURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("tasURL").getError()
        }
        guard !txId.isEmpty else {
            throw WalletAPIError.verifyParameterFail("txId").getError()
        }
        guard !serverToken.isEmpty else {
            throw WalletAPIError.verifyParameterFail("serverToken").getError()
        }
        guard let signedDIDDoc = signedDIDDoc else {
            throw WalletAPIError.verifyParameterFail("signedDIDDoc").getError()
        }
        
        let parameter = RequestRegisterUser(id: WalletUtil.generateMessageID(),
                                            txId: txId,
                                            signedDidDoc: signedDIDDoc,
                                            serverToken: serverToken)
        
        return try await CommunicationClient.sendRequest(urlString: tasURL,
                                                         requestJsonable: parameter)
    }
    
    // user restore (didDoc)
    public func requestRestoreUser(tasURL: String, txId: String, serverToken: String, didAuth: DIDAuth?) async throws -> _RequestRestoreDidDoc
    {
        guard !tasURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("tasURL").getError()
        }
        guard !txId.isEmpty else {
            throw WalletAPIError.verifyParameterFail("txId").getError()
        }
        guard !serverToken.isEmpty else {
            throw WalletAPIError.verifyParameterFail("serverToken").getError()
        }
        guard let didAuth = didAuth else {
            throw WalletAPIError.verifyParameterFail("didAuth").getError()
        }
        
        let parameter = RequestRestoreDidDoc(id: WalletUtil.generateMessageID(),
                                             txId: txId,
                                             serverToken: serverToken,
                                             didAuth: didAuth)
        
        return try await CommunicationClient.sendRequest(urlString: tasURL,
                                                         requestJsonable: parameter)
    }
    
    // user update (didDoc)
    public func requestUpdateUser(tasURL: String, txId: String, serverToken: String, didAuth: DIDAuth?, signedDIDDoc: SignedDIDDoc?) async throws -> _RequestUpdateDidDoc {
        
        guard !tasURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("tasURL").getError()
        }
        guard !txId.isEmpty else {
            throw WalletAPIError.verifyParameterFail("txId").getError()
        }
        guard !serverToken.isEmpty else {
            throw WalletAPIError.verifyParameterFail("serverToken").getError()
        }
        guard let didAuth = didAuth else {
            throw WalletAPIError.verifyParameterFail("didAuth").getError()
        }
        
        guard let signedDIDDoc = signedDIDDoc else {
            throw WalletAPIError.verifyParameterFail("signedDIDDoc").getError()
        }
        
        let parameter = RequestUpdateDidDoc(id: WalletUtil.generateMessageID(),
                                            txId: txId,
                                            serverToken: serverToken,
                                            didAuth: didAuth,
                                            signedDidDoc: signedDIDDoc)
        
        return try await CommunicationClient.sendRequest(urlString: tasURL,
                                                         requestJsonable: parameter)
    }
    
    
    public func getSignedDidAuth(authNonce: String, passcode: String? = nil) throws -> DIDAuth {
        
        guard !authNonce.isEmpty
        else
        {
            throw WalletAPIError.verifyParameterFail("authNonce").getError()
        }
        
        // 1. query did
        var didDoc = try walletCore.getDidDocument(type: .HolderDidDocumnet)
        // 2. except proofValue and generate proof
        let authType = passcode != nil
        ? "pin"
        : "bio"
        
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                          proofPurpose: .authentication,
                          verificationMethod: "\(didDoc.id)?versionId=\(didDoc.versionId)#\(authType)",
                          type: .secp256r1Signature2018)
        didDoc.proof = proof
        // 3. prepare holder did, authnonce, proof(except proofValue)
        var didAuth = DIDAuth(did: didDoc.id, authNonce: authNonce, proof: proof)
        // 4. digest for signature
        let source = try DigestUtils.getDigest(source: didAuth.toJsonData(), digestEnum: DigestEnum.sha256)
        
        let signature = try walletCore.sign(keyId: authType,
                                            pin: passcode?.data(using: .utf8) ?? nil,
                                            data: source,
                                            type: .HolderDidDocumnet)
        
        // 5. proofValue in DidAuth
        didAuth.proof?.proofValue = MultibaseUtils.encode(type: .base58BTC,
                                                          data: signature)
        return didAuth
    }
    
    public func requestIssueVc(url: String, didAuth: DIDAuth?, issuerProfile: _RequestIssueProfile?, refId: String, serverToken: String?, APIGatewayURL: String) async throws -> (String, _RequestIssueVc?) {
        
        guard !url.isEmpty else {
            throw WalletAPIError.verifyParameterFail("tasURL").getError()
        }
        guard let didAuth = didAuth else {
            throw WalletAPIError.verifyParameterFail("didAuth").getError()
        }
        guard let issuerProfile = issuerProfile else {
            throw WalletAPIError.verifyParameterFail("issuerProfile").getError()
        }
        guard !refId.isEmpty else {
            throw WalletAPIError.verifyParameterFail("refId").getError()
        }
//        guard !serverToken.isEmpty else {
//            throw WalletAPIError.verifyParameterFail("serverToken").getError()
//        }
        guard !APIGatewayURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("APIGatewayURL").getError()
        }
        
        let roleType = RoleTypeEnum.Issuer
        // checkCertVcRef
        try await WalletToken(self.walletCore).verifyCertVcRef(roleType: roleType, providerDID:issuerProfile.profile.profile.issuer.did, providerURL: issuerProfile.profile.profile.issuer.certVcRef, APIGatewayURL: APIGatewayURL)
        
        let holderDidDoc = try walletCore.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                          proofPurpose: ProofPurpose.keyAgreement,
                          verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + "#keyagree",
                          type: ProofType.secp256r1Signature2018)
        
        
        let reqE2e = issuerProfile.profile.profile.process.reqE2e
        let curve = reqE2e.curve
        let cipher = reqE2e.cipher
        let padding = reqE2e.padding
        
        let keyPair = try CryptoUtils.generateECKeyPair(ecType: curve)
        let iv = try CryptoUtils.generateNonce(size: 16)
        var accE2e = AccE2e(publicKey: MultibaseUtils.encode(type: MultibaseType.base58BTC,
                                                             data: keyPair.publicKey),
                            iv: MultibaseUtils.encode(type: MultibaseType.base58BTC,
                                                      data: iv),
                            proof: proof)
        
        let source = try DigestUtils.getDigest(source: accE2e.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature = try walletCore.sign(keyId: "keyagree", pin: nil, data: source, type: DidDocumentType.HolderDidDocumnet)
        accE2e.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
        let reqVcProfile = ReqVcProfile(id: issuerProfile.profile.id, issuerNonce: issuerProfile.profile.profile.process.issuerNonce)
        
        var reqVC = ReqVC(refId: refId, profile: reqVcProfile)
        
        var credentialMeta : ZKPCredentialRequestMeta?
        var credDef : ZKPCredentialDefinition?
        
        if let credentialOffer = issuerProfile.profile.profile.credentialOffer
        {
            credDef = try await CommunicationClient.getZKPCredentialDefinition(hostUrlString: APIGatewayURL,
                                                                               id: credentialOffer.credDefId)
            
            let container = try walletCore.createZKPCredentialRequest(proverDid: holderDidDoc.id,
                                                                      credentialDefinition: credDef!,
                                                                      credOffer: credentialOffer)
            credentialMeta = container.credentialRequestMeta
            reqVC.credentialRequest = container.credentialRequest
        }
        
        WalletLogger.debug("reqVc: \(try reqVC.toJson(isPretty: true))")
        let serverNonce = try MultibaseUtils.decode(encoded: issuerProfile.profile.profile.process.reqE2e.nonce)
        // generate sessionk ey
        let sessKey = try CryptoUtils.generateSharedSecret(ecType: curve,
                                                           privateKey: keyPair.privateKey,
                                                           publicKey: MultibaseUtils.decode(encoded: issuerProfile.profile.profile.process.reqE2e.publicKey))
        
        let clientMergedSharedSecret = WalletUtil.mergeSharedSecretAndNonce(sharedSecret: sessKey, nonce: serverNonce, symmetricCipherType: cipher)
        
        let encReqVc = try CryptoUtils.encrypt(plain: reqVC.toJsonData(),
                                               info: CipherInfo(cipherType: cipher,
                                                                padding: padding),
                                               key: clientMergedSharedSecret,
                                               iv: iv)
        
        let multiEncReqVc = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: encReqVc)
        let parameter = RequestIssueVc(id: WalletUtil.generateMessageID(),
                                       txId: issuerProfile.txId,
                                       serverToken: serverToken,
                                       didAuth: didAuth,
                                       accE2e: accE2e,
                                       encReqVc: multiEncReqVc)
        
        let decodedResponse : _RequestIssueVc = try await CommunicationClient.sendRequest(urlString: url,
                                                                                          requestJsonable: parameter)
        
        let envVc = try MultibaseUtils.decode(encoded: decodedResponse.e2e.encVc)
        
        let decVc = try CryptoUtils.decrypt(cipher: envVc,
                                            info: CipherInfo(cipherType: cipher,
                                                             padding: padding),
                                            key: clientMergedSharedSecret,
                                            iv: MultibaseUtils.decode(encoded: decodedResponse.e2e.iv))
        
        let credInfo = try CredInfo(from: decVc)
        
        if let credential = credInfo.credential
        {
            try walletCore.verifyAndStoreZKPCredential(credentialMeta: credentialMeta!,
                                                       credentialDefinition: credDef!,
                                                       credential: credential)
        }
        
        var vc = credInfo.vc
        
        let issuerDIDDoc = try await CommunicationClient.getDIDDocument(hostUrlString: APIGatewayURL,
                                                                        did: vc.issuer.id)
        
        WalletLogger.debug("issuerDIDDoc: \(try issuerDIDDoc.toJson(isPretty: true))")
        
        let tempProofValue = vc.proof.proofValue
        let tempProofValueList = vc.proof.proofValueList
        
        // verify issuer proof
        for method in issuerDIDDoc.verificationMethod {
            if method.id == "assert" {
                let pubKey = try MultibaseUtils.decode(encoded: method.publicKeyMultibase)
                let signature = try MultibaseUtils.decode(encoded: vc.proof.proofValue!)
                vc.proof.proofValue = nil
                vc.proof.proofValueList = nil
                let digest = DigestUtils.getDigest(source: try vc.toJsonData(), digestEnum: .sha256)
                let result = try walletCore.verify(publicKey: pubKey, data: digest, signature: signature)
                WalletLogger.debug("result: \(result)")
                guard result else {
                    throw WalletAPIError.verifyCertVCFail.getError()
                }
            }
        }
        
        if walletCore.isAnyCredentialsSaved() {
            let vcs = try walletCore.getAllCredentials()
            for v in vcs {
                if v.credentialSchema.id == vc.credentialSchema.id {
                    let vcId = v.id
                    WalletLogger.debug("v.credentialSchema.id: \(v.credentialSchema.id)")
                    WalletLogger.debug("vc.credentialSchema.id: \(vc.credentialSchema.id)")
                    _ = try walletCore.deleteCredential(ids: [vcId])
                    
                    if walletCore.isZKPCredentialSaved(id: vcId)
                    {
                        try walletCore.deleteZKPCredential(ids: [vcId])
                    }
                    
                    break
                }
            }
        }
        
        vc.proof.proofValue = tempProofValue
        vc.proof.proofValueList = tempProofValueList
        
        WalletLogger.debug("vc!!!!!: \(try vc.toJson(isPretty: true))")
        
        _ = try walletCore.addCredential(credential: vc)
        
        return (vc.id, decodedResponse)
    }
    
    public func requestRevokeVc(url: String, authType: VerifyAuthType, vcId: String, issuerNonce:String, txId: String, serverToken: String?, passcode: String? = nil) async throws -> _RequestRevokeVc {
        
        guard !url.isEmpty else {
            throw WalletAPIError.verifyParameterFail("url").getError()
        }
        guard !vcId.isEmpty else {
            throw WalletAPIError.verifyParameterFail("vcId").getError()
        }
        guard !issuerNonce.isEmpty else {
            throw WalletAPIError.verifyParameterFail("issuerNonce").getError()
        }
        guard !txId.isEmpty else {
            throw WalletAPIError.verifyParameterFail("txId").getError()
        }
       
        
        let holderDidDoc = try WalletAPI.shared.getDidDocument(type: DidDocumentType.HolderDidDocumnet)
        let authType = passcode != nil ? "#pin" : "#bio"
        let revokeProof = Proof(created: Date.getUTC0Date(seconds: 0),
                                proofPurpose: ProofPurpose.assertionMethod,
                                verificationMethod: holderDidDoc.id + "?versionId=" + holderDidDoc.versionId + authType,
                                type: ProofType.secp256r1Signature2018)
        
        var reqRevokeVc = ReqRevokeVc(vcId: vcId, issuerNonce: issuerNonce)
        reqRevokeVc.proof = revokeProof
        
        let reqRevokeVcSource = try DigestUtils.getDigest(source: reqRevokeVc.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature: Data?
        if passcode != nil {
            signature = try walletCore.sign(keyId: "pin", pin: passcode?.data(using: .utf8), data: reqRevokeVcSource, type: DidDocumentType.HolderDidDocumnet)
        } else {
            signature = try walletCore.sign(keyId: "bio", pin: nil, data: reqRevokeVcSource, type: DidDocumentType.HolderDidDocumnet)
        }
        
        reqRevokeVc.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature!)
        let parameter = RequestRevokeVc.init(id: WalletUtil.generateMessageID(),
                                             txId: txId,
                                             serverToken: serverToken,
                                             request: reqRevokeVc)
        
        return try await CommunicationClient.sendRequest(urlString: url,
                                                         requestJsonable: parameter)
    }
    
    
    public func getSignedWalletInfo() throws -> SignedWalletInfo {
        
        let didDoc = try walletCore.getDidDocument(type: DidDocumentType.DeviceDidDocument)
        let proof = Proof(created: Date.getUTC0Date(seconds: 0),
                          proofPurpose: ProofPurpose.assertionMethod,
                          verificationMethod: didDoc.id+"?versionId="+didDoc.versionId+"#assert",
                          type: ProofType.secp256r1Signature2018)
        
        let wallet = Wallet(id: Properties.getWalletId()!, did: didDoc.id)
        let nonce = try CryptoUtils.generateNonce(size: 16)
        let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data:nonce)
        var signedWalletInfo = SignedWalletInfo(wallet: wallet, nonce: hexNonce, proof: proof)
        
        WalletLogger.debug("signedWalletInfo: \(try signedWalletInfo.toJson())")
        let source = try DigestUtils.getDigest(source: signedWalletInfo.toJsonData(), digestEnum: DigestEnum.sha256)
        let signature = try walletCore.sign(keyId: "assert", pin: nil, data: source, type: DidDocumentType.DeviceDidDocument)
        signedWalletInfo.proof?.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
        return signedWalletInfo
    }
}


extension WalletService 
{
    public func requestIssueOID4VC(metadata: IssuerMetadataResponse,
                                   token: TokenResponse,
                                   passcode: String?,
                                   configurationId: String,
                                   credentialIdentifier: String?,
                                   APIGatewayURL: String) async throws -> String
    {
        guard !configurationId.isEmpty else {
            throw WalletAPIError.verifyParameterFail("configurationId").getError()
        }
        
        guard !APIGatewayURL.isEmpty else {
            throw WalletAPIError.verifyParameterFail("APIGatewayURL").getError()
        }
        
        guard let credentialConfig = metadata.credentialConfigurationsSupported[configurationId]
        else
        {
            throw OID4VCManagerError.unsupportedId(id: configurationId).getError()
        }

        if case .unknown(let value) = credentialConfig.format
        {
            throw OID4VCManagerError.unsupportedFormat(format: value).getError()
        }
        
        let authType = passcode != nil
        ? "pin"
        : "bio"

        let keyInfos = try walletCore.getKeyInfos(ids: [authType])

        let compressedPublicKey = try MultibaseUtils.decode(encoded: keyInfos.first!.publicKey)
        let jwk = try P256V.decompressPublicKey(compressedPublicKey: compressedPublicKey).getPublicKeyJwk()

        var nonce : String?
        if let nonceEndpoint = metadata.nonceEndpoint
        {
            let cNonce : CNonce = try await CommunicationClient.sendRequest(urlString: nonceEndpoint)
            nonce = cNonce.cNonce
        }

        let typ = "openid4vci-proof+jwt"

        let header = try JWSHeader.init(
            typ: typ,
            jwk: jwk
        ).toJsonData().base64URLEncoded

        let payload = try JWSAudiencePayload.init(
            aud: metadata.credentialIssuer,
            nonce: nonce
        ).toJsonData().base64URLEncoded

        let signSource = "\(header).\(payload)"
        let digest = signSource.data(using: .utf8)!.sha256()

        // KeyManager returns a 65-byte compact signature (v‖r‖s); JOSE ES256 wants 64-byte r‖s.
        let compactSignature = try walletCore.sign(keyId: authType,
                                                   pin: passcode?.data(using: .utf8),
                                                   data: digest, type: DidDocumentType.HolderDidDocumnet)
        let signature = Data(compactSignature.dropFirst()).base64URLEncoded
        let jws = "\(signSource).\(signature)"

        var credentialRequest : CredentialRequest

        if let selectedCredentialID = credentialIdentifier
        {
            credentialRequest = CredentialRequest(
                credentialConfigurationId: nil,
                credentialIdentifier: selectedCredentialID,
                proofs: .init(jwt: [jws])
            )
        }
        else
        {
            credentialRequest = CredentialRequest(
                credentialConfigurationId: configurationId,
                credentialIdentifier: nil,
                proofs: .init(jwt: [jws])
            )
        }
        
        
        var keyAgreePrivateKey : P256.KeyAgreement.PrivateKey?
        
        if let responseEncryption = metadata.credentialResponseEncryption,
           let encryptionRequired = responseEncryption.encryptionRequired,
           encryptionRequired == true
        {
            
            keyAgreePrivateKey = P256.KeyAgreement.PrivateKey()
            let keyAgreeJWK = keyAgreePrivateKey!.publicKey.getPublicKeyJwk()
            credentialRequest.credentialResponseEncryption = .init(jwk: keyAgreeJWK)
        }

        let authorizationHeader = "\(token.tokenType) \(token.accessToken)"

        var headers: [String: String] = [:]
        headers["Authorization"] = authorizationHeader
        headers.merge(DefaultHttpHeaderFields) { current, _ in current }

        let (resultData, statusCode) = try await CommunicationClient.sendRequest(
            urlString: metadata.credentialEndpoint,
            headerFields: headers,
            requestJsonData: credentialRequest.toJsonData()
        )
        
        if statusCode != 200
        {
            if let errorString = String(data: resultData, encoding: .utf8)
            {
                throw CommunicationAPIError.serverFail(errorString).getError()
            }
            throw CommunicationAPIError.unknown.getError()
        }
        
        let credentialResponseData : Data
        if let privateKey = keyAgreePrivateKey
        {
            // Encrypted response: the JWE plaintext is the Credential Response JSON object,
            // not the bare credential — decrypt, then parse it the same way as the clear branch.
            let jwe = try JWE(data: resultData)
            credentialResponseData = try jwe.decrypt(using: privateKey)
        }
        else
        {
            credentialResponseData = resultData
        }

        let credentialResponse = try CredentialResponse.init(from: credentialResponseData)

        guard let rawCredential = credentialResponse.credentials.first?.credential
        else
        {
            throw OID4VCManagerError.invalidCredentialResponse.getError()
        }

        // Verify. Each format names its signer differently — an SD-JWT in a JWS header, an mdoc in
        // a COSE header — so the credential is parsed and its key resolved inside the branch. Both
        // land on the same DID key, which is why they share `issuerPublicKey`.
        let format : String
        switch credentialConfig.format
        {
        case .sdjwt:
            let credentialJws = try JWS.init(from: SDJWT.parse(raw: rawCredential).credentialJwt)
            let publicKeyData = try await issuerPublicKey(kid: try credentialJws.protectedHeader.kid,
                                                          APIGatewayURL: APIGatewayURL)
            try veryfySDJWT(credential: rawCredential, publicKeyData: publicKeyData)
            format = CredentialFormat.sdJwtVc.token

        case .mdoc:
            let mdoc = try Mdoc.parse(raw: rawCredential)
            let publicKeyData = try await issuerPublicKey(kid: mdoc.issuerAuth.keyIdentifier,
                                                          APIGatewayURL: APIGatewayURL)
            try verifyMdoc(mdoc: mdoc, publicKeyData: publicKeyData, holderKeyId: authType)
            format = CredentialFormat.msoMdoc.token

        case .unknown(let value):
            // Unreachable: an unknown format is rejected before the credential is requested. The
            // case is here so that adding a format cannot silently store an unverified credential.
            throw OID4VCManagerError.unsupportedFormat(format: value).getError()
        }

        let credential = OID4VCICredential(
            id: UUID().uuidString,
            format: format,
            credentialConfigurationId: configurationId,
            credentialIdentifier: credentialIdentifier,
            kid: authType,
            credential: rawCredential
        )

        _ = try walletCore.addOID4VCICredential(credential: credential)

        return credential.id
    }
}

extension WalletService
{
    /// Resolves the key a credential was signed with, from the DID URL its header names.
    ///
    /// Both credential formats identify the issuer the same way — a DID URL naming a verification
    /// method — so the walk from `kid` to key bytes is shared: parse the DID URL, fetch that
    /// version of the DID Document, and take the multibase key of the method it points at.
    /// - Parameters:
    ///   - kid: The DID URL from the credential's signature header.
    ///   - APIGatewayURL: The gateway that serves DID Documents.
    /// - Returns: The verification key, decoded.
    /// - Throws: `OID4VCManagerError.notFoundKid` when the credential names no key, or the
    ///   document holds no method by that name.
    private func issuerPublicKey(kid: String?, APIGatewayURL: String) async throws -> Data
    {
        guard let kid = kid, let identifier = DIDUtility.parseDIDKeyIdentifier(kid)
        else
        {
            throw OID4VCManagerError.notFoundKid.getError()
        }

        let issuerDIDDoc = try await CommunicationClient.getDIDDocument(hostUrlString: APIGatewayURL,
                                                                       did: identifier.did,
                                                                       versionId: identifier.versionId)

        guard let publicKeyMultibase = issuerDIDDoc.verificationMethod.filter({ $0.id == identifier.kid }).first.map(\.publicKeyMultibase)
        else
        {
            throw OID4VCManagerError.notFoundKid.getError()
        }

        return try MultibaseUtils.decode(encoded: publicKeyMultibase)
    }

    /// Checks an issued mdoc before it is stored.
    ///
    /// Four things have to hold, and each fails differently:
    /// 1. the issuer signed the MSO — otherwise the document is not from this issuer;
    /// 2. every element matches its digest in that MSO — otherwise an element was altered after
    ///    signing, since the signature covers the digests rather than the elements;
    /// 3. the document is inside its validity window;
    /// 4. the MSO's `deviceKey` is the wallet key that proved possession during issuance —
    ///    without this the document would store fine and then fail every presentation, because
    ///    presenting means signing with the key the issuer bound it to.
    ///
    /// Everything is checked against the bytes as received. Re-encoding the document first would
    /// produce valid CBOR whose digests and signature no longer match.
    private func verifyMdoc(mdoc: Mdoc, publicKeyData: Data, holderKeyId: String) throws
    {
        guard mdoc.issuerAuth.algorithm == COSESign1.algES256
        else
        {
            throw OID4VCManagerError.invalidMdoc(detail: "issuerAuth is not signed with ES256").getError()
        }

        let signatureInput = try mdoc.issuerAuth.signatureInput()
        let isValid = try Secp256R1Manager.verifyRawRepresentation(signature: Data(mdoc.issuerAuth.signature),
                                                                   message: Data(signatureInput),
                                                                   publicKey: publicKeyData)
        guard isValid else
        {
            throw OID4VCManagerError.failedToVerifySignature.getError()
        }

        try mdoc.verifyDigests()
        try mdoc.verifyValidity(at: Date())
        try verifyDeviceKey(mdoc.mso.deviceKey, matches: holderKeyId)
    }

    /// Checks that the MSO binds the document to the wallet key that signed the issuance proof.
    ///
    /// The COSE_Key carries the curve point in the clear, so the comparison is against the same
    /// point taken from the wallet's own key rather than against an encoding of it.
    private func verifyDeviceKey(_ deviceKey: CBOR, matches keyId: String) throws
    {
        guard case let .map(fields) = deviceKey,
              case let .byteString(x)? = fields[.negativeInt(1)],
              case let .byteString(y)? = fields[.negativeInt(2)]
        else
        {
            throw OID4VCManagerError.invalidMdoc(detail: "deviceKey is not an EC2 COSE_Key").getError()
        }

        guard let keyInfo = try walletCore.getKeyInfos(ids: [keyId]).first
        else
        {
            throw OID4VCManagerError.holderKeyNotFound.getError()
        }

        let compressedPublicKey = try MultibaseUtils.decode(encoded: keyInfo.publicKey)
        let holderJwk = try P256V.decompressPublicKey(compressedPublicKey: compressedPublicKey).getPublicKeyJwk()

        guard holderJwk.x.base64URLDecoded == Data(x),
              holderJwk.y.base64URLDecoded == Data(y)
        else
        {
            throw OID4VCManagerError.deviceKeyMismatch.getError()
        }
    }

    private func veryfySDJWT(credential : String, publicKeyData : Data) throws
    {
        let sdJWT = SDJWT.parse(raw: credential)
        let (source, signature) = sdJWT.getSignSource()

        guard let signatureData = signature.base64URLDecoded
        else
        {
            throw OID4VCManagerError.invalidJWS(detail: "signature is not base64url").getError()
        }

        let isValid = try Secp256R1Manager.verifyRawRepresentation(signature: signatureData,
                                                                   message: source.data(using: .utf8)!,
                                                                   publicKey: publicKeyData)
        
        guard isValid else
        {
            throw OID4VCManagerError.failedToVerifySignature.getError()
        }
    }
}
