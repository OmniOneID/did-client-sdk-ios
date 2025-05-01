//
/*
 * Copyright 2025 OmniOne.
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
import OrderedCollections

struct ZKPManager
{
    typealias C = WalletCoreCommonError
    typealias E = ZKPManagerError
    
    fileprivate var storageManager: StorageManager<ZKPMeta, ZKPInfo>
    
    /// Initializer
    /// 
    /// - Parameter fileName: Name to use when saving the file
    public init(fileName : String) throws
    {
        if fileName.isEmpty
        {
            throw C.invalidParameter(code: .zkpManager,
                                     name: "fileName").getError()
        }
        
        storageManager = try .init(fileName: fileName,
                                   fileExtension: .zkp,
                                   isEncrypted: true)
        
        if !isAnyItemSaved
        {
            try generateMasterSecret(id: UUID().uuidString)
        }
    }
    
    private var isAnyItemSaved : Bool { storageManager.isSaved() }
    
    /// Check if there is at least one saved ZKPCredential.
    public var isAnyCredentialsSaved : Bool {
        if !isAnyItemSaved { return false }
        
        let metas = try! getAllCredentialMetas()
        return !metas.isEmpty
    }
}

extension ZKPManager
{
    private func generateMasterSecret(id : String) throws
    {
        let ms = BigIntUtil.generateMasterSecret().decimalString
        try addMasterSecret(id: id, value: ms)
    }
    
    private func addMasterSecret(id : String, value : BigIntString) throws
    {
        let masterSecret : MasterSecret = .init(
            masterSecretId: id,
            masterSecret: value
        )
        
        let meta = ZKPMeta(id: id, category: .masterSecret)
        let item = ZKPInfo(id: id, msId: id, category: .masterSecret, value: try! masterSecret.toJson())
        
        try storageManager.addItem(
            walletItem: .init(
                meta: meta,
                item: item
            )
        )
    }
    
    private func loadMasterSecret() throws -> MasterSecret
    {
        let items = try getItems(by: .masterSecret)
        
        if items.count == 0
        {
            throw E.masterSecretNotFound.getError()
        }
        
        let first = items.first!
        let ms : MasterSecret = try! .init(from: first.value)
        
        return ms
    }
    
    private func getCredentialMetasAndItems() throws -> [StorageManager<ZKPMeta, ZKPInfo>.UsableInnerWalletItem]
    {
        return try storageManager.getAllItems().filter { $0.meta.category == .credential }
    }
    
    private func getItems(by category : ZKPStoredCategory) throws -> [ZKPInfo]
    {
        return try storageManager.getAllItems().filter { $0.meta.category == category }.lazy.map { $0.item }
    }
    
    func getAllCredentialMetas() throws -> [ZKPMeta]
    {
        return try storageManager.getAllMetas().filter { $0.category == .credential }
    }
    
    func reset() throws
    {
        try storageManager.removeAllItems()
    }
}

extension ZKPManager
{
    /// Creates the CredentialRequest and its meta
    ///
    /// - Parameters:
    ///   - proverDid: The prover's DID
    ///   - credentialPublicKey: The `primary` of the credential definition’s `value`
    ///   - credOffer: ZKPCredentialOffer
    /// - Returns: A `ZKPCredentialRequestContainer` instance
    public func createCredentialRequest(proverDid : String,
                                        credentialPublicKey : CredentialPrimaryPublicKey,
                                        credOffer : ZKPCredentialOffer) throws -> ZKPCredentialRequestContainer
    {
        if proverDid.isEmpty
        {
            throw C.invalidParameter(code: .zkpManager,
                                     name: "proverDID").getError()
        }
        
        if try !KeyPairVerifier.verify(publicKey: credentialPublicKey, keyProof: credOffer.keyCorrectnessProof)
        {
            throw E.bigNumberCompare(lhs: "credentialPublicKey", rhs: "keyCorrectnessProof").getError()
        }
        
        let masterSecret = try loadMasterSecret()
        
        let proverNonce = BigIntUtil.generateNonce().decimalString
        let vPrime = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeVPrime)
        
        let credentialRequest = try CredentialRequestHelper.generateCredentialRequest(
            credentialPublicKey: credentialPublicKey,
            proverDid: proverDid,
            masterSecret: masterSecret.masterSecret,
            credOffer: credOffer,
            nonce: proverNonce,
            vPrime: vPrime
        )
        
        let credentialMeta = ZKPCredentialRequestMeta(
            masterSecretBlidingData: .init(vPrime: vPrime.decimalString),
            nonce: proverNonce,
            masterSecretName: masterSecret.masterSecretId
        )
        
        return .init(
            credentialRequest: credentialRequest,
            credentialRequestMeta: credentialMeta
        )
    }
    
    /// Verifies and stores a ZKP credential.
    ///
    /// - Parameters:
    ///   - credentialMeta: Metadata from the credential request
    ///   - publicKey: The `primary` of the credential definition’s `value`
    ///   - credential: The credential to be verified and stored
    public func verifyAndStoreCredential(credentialMeta : ZKPCredentialRequestMeta,
                                         publicKey : CredentialPrimaryPublicKey,
                                         credential : ZKPCredential) throws
    {
        let masterSecret = try loadMasterSecret()
        if masterSecret.masterSecretId != credentialMeta.masterSecretName
        {
            throw E.masterSecretNotFound.getError()
        }
        
        var innerCredential = credential
        
        try verifyCredential(credentialMeta: credentialMeta,
                             publicKey: publicKey,
                             credential: &innerCredential,
                             masterSecret: masterSecret.masterSecret)
        
        try storeCredential(credential: innerCredential,
                            msId: masterSecret.masterSecretId)
    }
    
    func verifyCredential(credentialMeta : ZKPCredentialRequestMeta,
                          publicKey : CredentialPrimaryPublicKey,
                          credential : inout ZKPCredential,
                          masterSecret : BigIntString) throws
    {
        //Verify
        let s = publicKey.s.bigInt
        let z = publicKey.z.bigInt
        let n = publicKey.n.bigInt
        
        // v = v' + v''
        //Avoiding value copy
        let v = credential.signature.pCredential.v.bigInt + credentialMeta.masterSecretBlidingData.vPrime.bigInt
        credential.signature.pCredential.v = v.decimalString
        
        let pCredSign = credential.signature.pCredential
        let a  = pCredSign.a.bigInt
        let e  = pCredSign.e.bigInt
        let m2 = pCredSign.m2.bigInt
        
        let rctxt = publicKey.rctxt.bigInt
        
        let credValues = try CredentialValues.generateCredentialValues(credValues: credential.values,
                                                                       masterSecret: masterSecret)
        
        var sv = CommitmentHelper.commitment(z: s, zExp: v, s: rctxt, sExp: m2, modular: n)
        
        for (key, attrValue) in credValues.attrValues
        {
            guard let rValue = publicKey.r[key]
            else
            {
                throw E.null(value: key, group: "credentialPublicKey.r").getError()
            }
            
            sv = (sv * rValue.bigInt.power(attrValue.value.bigInt, modulus: n)).modulus(n)
        }
        
        if sv.bitWidth == 0
        {
            throw E.verifySignatureCorrectnessProof.getError()
        }
        
        // Check e and v are in range, and e is prime
        // Ae ≡ Z Sv ⋅ ∏i R mi i (mod n)
        
        guard let svInverse = sv.inverse(n)
        else
        {
            throw E.inverse(value: "sv").getError()
        }
        
        let q = z * svInverse % n
        let qCap = a.power(e, modulus: n)
        
        if q != qCap
        {
            throw E.bigNumberCompare(lhs: "publicKey", rhs: "credential.CredentialSignature").getError()
        }
        
        let c = credential.signatureCorrectnessProof.c.bigInt
        
        let exp = c + credential.signatureCorrectnessProof.se.bigInt * e
        let aCap = a.power(exp, modulus: n)
        
        let cCap = ChallengeBuilder()
            .append(q)
            .append(a)
            .append(aCap)
            .append(credentialMeta.nonce)
            .buildWithHashing()
        
        if cCap != c
        {
            throw E.bigNumberCompare(lhs: "publicKey", rhs: "credential.signatureCorrectnessProof").getError()
        }
    }
    
    func storeCredential(credential: ZKPCredential,
                         msId : String) throws
    {
        let meta : ZKPMeta = .init(
            id: credential.credentialId,
            category: .credential
        )
        
        let info : ZKPInfo = .init(
            id: credential.credentialId,
            msId: msId,
            category: .credential,
            value: try! credential.toJson()
        )
        
        try storageManager.addItem(walletItem: .init(meta: meta,
                                                     item: info))
    }
}

extension ZKPManager
{
    /// Returns all stored ZKP credentials.
    ///
    /// - Returns: An array of `ZKPCredential` instances
    public func getAllCredentials() throws -> [ZKPCredential]
    {
        let items = try getItems(by: .credential)
        if items.count == 0
        {
            throw E.notFoundCredentialStored.getError()
        }
        
        return items.map { try! .init(from: $0.value) }
    }
    
    /// Returns ZKP credentials for the given identifiers.
    ///
    /// - Parameter by: A list of credential identifiers
    /// - Returns: A list of `ZKPCredential` instances
    public func getCredentials(by identifiers : [String]) throws -> [ZKPCredential]
    {
        if identifiers.isEmpty {
            throw C.invalidParameter(code: .zkpManager, name: "identifiers").getError()
        }
        
        if identifiers.count != Set(identifiers).count {
            throw C.duplicateParameter(code: .zkpManager, name: "identifiers").getError()
        }
        
        let items = try storageManager.getItems(by: identifiers).filter { $0.meta.category == .credential }.map { $0.item }
        
        if items.count != identifiers.count
        {
            throw E.notFoundCredentialByIdentifiers.getError()
        }
        
        return items.map { try! .init(from: $0.value) }
    }
    
    /// Removes all stored credentials.
    public func removeAllCredentials() throws
    {
        let identifiers = try storageManager.getAllMetas().filter { $0.category == .credential }.map { $0.id }
        
        if identifiers.count > 0
        {
            try storageManager.removeItems(by: identifiers)
        }
    }
    
    /// Removes credentials matching the given identifiers.
    ///
    /// - Parameter by: An array of credential identifiers
    public func removeCredentials(by identifiers : [String]) throws
    {
        if identifiers.isEmpty {
            throw C.invalidParameter(code: .zkpManager, name: "identifiers").getError()
        }
        
        if identifiers.count != Set(identifiers).count {
            throw C.duplicateParameter(code: .zkpManager, name: "identifiers").getError()
        }
        
        try storageManager.removeItems(by: identifiers)
    }
    
}

extension ZKPManager
{
    struct InnerRequestedAttribute
    {
        let credDefIds    : [String]
        let referentName : String
    }
    
    struct InnerRequestedPredicate
    {
        let credDefIds    : [String]
        let referentName : String
        let pType        : PredicateType
        let pValue       : Int
    }
    
    struct SearchedMeta
    {
        let id        : String
        let credDefId : String
        let schemaId  : String
        let values    : [String : AttributeValue]
    }
    
    /// Searches for credentials that satisfy the given proof request.
    ///
    /// - Parameter proofRequest: The proof request specifying required attributes and predicates
    /// - Returns: An `AvailableReferent` containing referents for matching credentials
    public func searchCredentials(proofRequest : ProofRequest) throws -> AvailableReferent
    {
        let credentials = try getAllCredentials()
        
        if credentials.isEmpty
        {
            throw E.notFoundCredentialStored.getError()
        }
        
        return try searchCredentials(credentials: credentials,
                                     proofRequest: proofRequest)
    }
    
    
    func searchCredentials(credentials : [ZKPCredential],
                           proofRequest : ProofRequest) throws -> AvailableReferent
    {
        let (selfAttrReferents, requestedAttributes) = getRequestedAttributes(attributes: proofRequest.requestedAttributes)
        let requestedPredicates = try getRequestedPredicates(predicates: proofRequest.requestedPredicates)
        
        let searchedMetas : [SearchedMeta] = credentials.map {
            return .init(
                id: $0.credentialId,
                credDefId: $0.credDefId,
                schemaId: $0.schemaId,
                values: $0.values
            )
        }
        
        let availableReferent : AvailableReferent = .init(selfAttrReferent: selfAttrReferents,
                                                          attrReferent: try getAvailableReferents(requestedAttributes: requestedAttributes,
                                                                                                  searchedMetas: searchedMetas),
                                                          predicateReferent: try getPredicateReferents(requestedPredicates: requestedPredicates,
                                                                                                       searchedMetas: searchedMetas))
        
        return availableReferent
    }
    
    typealias SelfAttrReferents = [AttrReferent]
    typealias RequestedAttributes = [String : InnerRequestedAttribute]
    typealias RequestedPredicates = [String : InnerRequestedPredicate]
                                    
    
    func getRequestedAttributes(attributes : [String : AttributeInfo]) -> (SelfAttrReferents, RequestedAttributes)
    {
        var requestedAttributes : [String : InnerRequestedAttribute] = .init()
        var selfAttrReferents   : [AttrReferent] = .init()
        
        for (referentKey, value) in attributes
        {
            let restrictions = value.restrictions.map { $0.values }.reduce(into: Array<String>()) { $0.append(contentsOf: $1)
            }
            
            if restrictions.isEmpty
            {
                selfAttrReferents.append(.init(key: referentKey,
                                               name: value.name,
                                               checkRevealed: true,
                                               referent: .init()))
            }
            else
            {
                requestedAttributes[referentKey] = .init(credDefIds: restrictions,
                                                        referentName: value.name)
            }
        }
        
        return (selfAttrReferents, requestedAttributes)
    }
    
    func getRequestedPredicates(predicates : [String : PredicateInfo]) throws -> RequestedPredicates
    {
        var requestedPredicates : [String : InnerRequestedPredicate] = .init()
        
        for (referentKey, value) in predicates
        {
            let restrictions = value.restrictions.map { $0.values }.reduce(into: Array<String>()) { $0.append(contentsOf: $1)
            }
            
            if restrictions.isEmpty
            {
                throw E.predicateMustHaveRestictions.getError()
            }
            else
            {
                requestedPredicates[referentKey] = .init(credDefIds: restrictions,
                                                         referentName: value.name,
                                                         pType: value.pType,
                                                         pValue: value.pValue)
            }
        }
        
        return requestedPredicates
    }
    
    func getAvailableReferents(requestedAttributes : [String : InnerRequestedAttribute],
                               searchedMetas : [SearchedMeta]) throws -> [AttrReferent]
    {
        var attrReferents : [AttrReferent] = .init()
        
        for (referentKey, requestedAttribute) in requestedAttributes
        {
            let referents = searchedMetas.compactMap { searchedMeta in
                if requestedAttribute.credDefIds.contains(searchedMeta.credDefId),
                   let raw = searchedMeta.values[requestedAttribute.referentName]?.raw
                {
                    let referent : SubReferent = .init(raw: raw,
                                                           credId: searchedMeta.id,
                                                           credDefId: searchedMeta.credDefId,
                                                           schemaId: searchedMeta.schemaId)
                    return referent
                }
                return nil
            }
                
            if referents.isEmpty
            {
                throw E.notFoundAvailableRequestAttribute.getError()
            }
            
            attrReferents.append(.init(key: referentKey,
                                       name: requestedAttribute.referentName,
                                       checkRevealed: true,
                                       referent: referents))
        }
        
        return attrReferents
    }
    
    func getPredicateReferents(requestedPredicates : [String : InnerRequestedPredicate],
                               searchedMetas : [SearchedMeta]) throws -> [AttrReferent]
    {
        var predicateReferents  : [AttrReferent] = .init()
        
        for (referentKey, requestedPredicate) in requestedPredicates
        {
            let referents = searchedMetas.compactMap { searchedMeta in
                if requestedPredicate.credDefIds.contains(searchedMeta.credDefId),
                   let raw = searchedMeta.values[requestedPredicate.referentName]?.raw,
                   let iRaw = Int(raw)
                {
                    let isMatch : Bool
                    switch requestedPredicate.pType {
                    case .GE:
                        isMatch = (iRaw >= requestedPredicate.pValue)
                    case .LE:
                        isMatch = (iRaw <= requestedPredicate.pValue)
                    case .GT:
                        isMatch = (iRaw > requestedPredicate.pValue)
                    case .LT:
                        isMatch = (iRaw < requestedPredicate.pValue)
                    }
                    
                    if isMatch
                    {
                        let referent : SubReferent = .init(raw: raw,
                                                               credId: searchedMeta.id,
                                                               credDefId: searchedMeta.credDefId,
                                                               schemaId: searchedMeta.schemaId)
                        return referent
                    }
                    return nil
                    
                }
                return nil
            }
                
            if referents.isEmpty
            {
                throw E.notFoundAvailablePredicateAttribute.getError()
            }
            
            predicateReferents.append(.init(key: referentKey,
                                            name: requestedPredicate.referentName,
                                            checkRevealed: false,
                                            referent: referents))
        }
        
        return predicateReferents
    }
}

extension ZKPManager
{
    struct ProveCredential
    {
        var proveAttributes : [String : ProveAttribute] = .init()
        var provePredicates : [String : ProvePredicate] = .init()
    }
    
    struct ProveAttribute
    {
        let isRevealed   : Bool
        let referentKey  : String
    }
    
    struct ProvePredicate
    {
        let referentKey  : String
        let predicate    : ZKPProof.Predicate
    }
    
    func getProveCredentials(proofRequest : ProofRequest,
                             selectedReferents : [UserReferent]) throws -> (StringDictionary, OrderedDictionary<String, ProveCredential>)
    {
        var selfAttributes : StringDictionary = .init()
        
        var proveCredentials : OrderedDictionary<String, ProveCredential> = .init()
        
        var attrCounter : Int = proofRequest.requestedAttributes.filter { !$0.value.restrictions.isEmpty }.count
        var predicateCounter : Int = proofRequest.requestedPredicates.count
        
        
        for selectedReferent in selectedReferents
        {
            if let info = proofRequest.requestedAttributes[selectedReferent.referentKey]
            {
                if let credId = selectedReferent.credId
                {
                    if info.restrictions.isEmpty
                    {
                        throw E.invalidSelfAttributeReferent.getError()
                    }
                    else if info.name != selectedReferent.referentName
                    {
                        throw E.invalidAttributeReferentName.getError()
                    }
                    
                    var proveCredential = proveCredentials[credId]
                    if proveCredential == nil
                    {
                        proveCredential = .init()
                    }
                    let proveAttribute : ProveAttribute = .init(isRevealed: selectedReferent.isRevealed,
                                                                referentKey: selectedReferent.referentKey)
                    proveCredential!.proveAttributes[selectedReferent.referentName] = proveAttribute
                    
                    proveCredentials[credId] = proveCredential
                    
                    attrCounter -= 1
                }
                else
                {
                    if !info.restrictions.isEmpty
                    {
                        throw E.invalidAttributeReferentName.getError()
                    }
                    
                    if let attributeInfo = proofRequest.requestedAttributes[selectedReferent.referentKey],
                       attributeInfo.restrictions.isEmpty,
                       !selectedReferent.raw.isEmpty
                    {
                        selfAttributes[selectedReferent.referentKey] = selectedReferent.raw
                    }
                    else
                    {
                        throw E.invalidSelfAttributeReferent.getError()
                    }
                }
                
            }
            else if proofRequest.requestedPredicates[selectedReferent.referentKey] != nil
            {
                guard let credId = selectedReferent.credId
                else
                {
                    throw E.invalidSelfAttributeReferent.getError()
                }
                
                let predicateInfo = proofRequest.requestedPredicates[selectedReferent.referentKey]!
                
                var proveCredential = proveCredentials[credId]
                if proveCredential == nil
                {
                    proveCredential = .init()
                }
                let provePredicate : ProvePredicate = .init(referentKey: selectedReferent.referentKey,
                                                            predicate: .init(pType: predicateInfo.pType,
                                                                             pValue: predicateInfo.pValue,
                                                                             attrName: predicateInfo.name))
                proveCredential!.provePredicates[selectedReferent.referentName] = provePredicate
                
                proveCredentials[credId] = proveCredential
                
                predicateCounter -= 1
            }
            else
            {
                throw E.invalidReferentKey.getError()
            }
        }
        
        if (attrCounter + predicateCounter) > 0
        {
            throw E.insufficientProofRequestReferents.getError()
        }
        
        return (selfAttributes, proveCredentials)
    }
    
    typealias SubProofIndex = [String : Int]
    
    func createIdentifiers(credentials :[String : ZKPCredential],
                           credIds : OrderedSet<String>) -> (SubProofIndex, [ZKPProof.Identifier])
    {
        var subProofIndex : SubProofIndex = .init()
        var identifiers : [ZKPProof.Identifier] = .init()
        
        for credId in credIds
        {
            subProofIndex[credId] = subProofIndex.keys.count
            let credential = credentials[credId]!
            identifiers.append(.init(credDefId: credential.credDefId,
                                     schemaId: credential.schemaId))
        }
        
        return (subProofIndex, identifiers)
    }
    
    /// Creates a zero-knowledge proof based on the given request and selected referents.
    ///
    /// - Parameters:
    ///   - proofRequest: The proof request specifying required attributes and predicates
    ///   - selectedReferents: The referents selected by the user to satisfy the proof request
    ///   - proofParam: Additional parameters used to construct the proof
    /// - Returns: A `ZKPProof` instance
    public func createProof(proofRequest : ProofRequest,
                            selectedReferents : [UserReferent],
                            proofParam : ZKPProofParam) throws -> ZKPProof
    {
        let masterSecret = try loadMasterSecret()
        
        let (selfAttributes, proveCredentials) = try getProveCredentials(proofRequest: proofRequest,
                                                                         selectedReferents: selectedReferents)
        
        let credIds = proveCredentials.reduce(into: [String]()) { $0.append($1.key) }
        
        let credentials = try getCredentials(by: credIds).reduce(into: [String : ZKPCredential](), {
            $0[$1.credentialId] = $1
        })
        
        let (subProofIndex, identifiers) = createIdentifiers(
            credentials: credentials,
            credIds: proveCredentials.keys
        )
        
        var revealedAttrs : RequestedAttrDictionary = .init()
        var unrevealedAttrs : RequestedAttrDictionary = .init()
        var predicateAttrs : RequestedAttrDictionary = .init()
        
        var builder = ProofBuilder()
        
        for (credId, proveCredential) in proveCredentials
        {
            let credential = credentials[credId]!
            let primarySignature = credential.signature.pCredential
            var remainValues = credential.values
            
            let schemaId = credential.schemaId
            let credDefId = credential.credDefId
            
            guard let schema = proofParam.schemas[schemaId],
                  schema.id == schemaId
            else
            {
                throw E.notFoundSchemaFromProofParam.getError()
            }
            
            guard let credDef = proofParam.creDefs[credDefId],
                  credDef.id == credDefId
            else
            {
                throw E.notFoundCredentialDefinitionFromProofParam.getError()
            }
            
            let index = subProofIndex[credId]!
            
            var revealedAttrNames : [String]  = .init()
            var predicates : [ZKPProof.Predicate] = .init()
            var credValues = CredentialValues()
            try credValues.addHidden(key: ZKPConstants.masterSecretKey, value: masterSecret.masterSecret)
            
            for (referentName, proveAttribute) in proveCredential.proveAttributes
            {
                
                guard let attrbuteValue = remainValues.removeValue(forKey: referentName)
                else
                {
                    throw E.invalidAttributeReferentName.getError()
                }
                
                if proveAttribute.isRevealed
                {
                    revealedAttrs[proveAttribute.referentKey] = .init(subProofIndex: index,
                                                                      raw: attrbuteValue.raw,
                                                                      encoded: attrbuteValue.encoded)
                    revealedAttrNames.append(referentName)
                    try credValues.addKnown(key: referentName, value: attrbuteValue.encoded)
                    
                }
                else
                {
                    unrevealedAttrs[proveAttribute.referentKey] = .init(subProofIndex: index,
                                                                      raw: nil,
                                                                      encoded: nil)
                    try credValues.addHidden(key: referentName, value: attrbuteValue.encoded)
                }
            }
            
            for (referentName, provePredicate) in proveCredential.provePredicates
            {
                guard let attrbuteValue = remainValues.removeValue(forKey: referentName)
                else
                {
                    throw E.invalidPredicateReferentName.getError()
                }
                
                predicateAttrs[provePredicate.referentKey] = .init(subProofIndex: index,
                                                                  raw: nil,
                                                                  encoded: nil)
                predicates.append(provePredicate.predicate)
                try credValues.addHidden(key: referentName, value: attrbuteValue.encoded)
            }
            
            for (key, remainValue) in remainValues
            {
                try credValues.addHidden(key: key, value: remainValue.encoded)
            }
            
            let unrevealedAttrSet = ProofInitiator.createUnrevealedAttributes(schema: schema,
                                                                            revealedAttrNames: revealedAttrNames)
            
            let mTilde = ProofInitiator.generateMTilde(unrevealedAttrs: unrevealedAttrSet,
                                                       commonAttributes: builder.commonAttributes)
            
            let aevPrimes = ProofInitiator.createAEVPrimes(publicKey: credDef.value.primary,
                                                           credSign: primarySignature)
            
            let eqProof = try ProofInitiator.initEqProof(publicKey: credDef.value.primary,
                                                         unrevealedAttrs: unrevealedAttrSet,
                                                         aevPrime: aevPrimes,
                                                         mTilde: mTilde,
                                                         m2: primarySignature.m2.bigInt)
            
            let neProofs = try ProofInitiator.generateInitNeProofs(publicKey: credDef.value.primary,
                                                                   mTilde: mTilde,
                                                                   credValues: credValues,
                                                                   predicates: predicates)
            
            builder.addInitProof(initProof: .init(eqProof: eqProof,
                                                  neProofs: neProofs,
                                                  credValues: credValues))
            
        }
        
        let (subProofs, aggregatedProof) =  try builder.build(nonce: proofRequest.nonce.bigInt)
        
        return ZKPProof.init(
            proofs: subProofs,
            aggregatedProof: aggregatedProof,
            requestedProof: .init(
                selfAttestedAttrs: selfAttributes,
                predicates: predicateAttrs,
                revealedAttrs: revealedAttrs,
                unrevealedAttrs: unrevealedAttrs
            ),
            identifiers: identifiers
        )
    }
}
