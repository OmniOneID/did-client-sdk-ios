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


/// Manages OID4VCI-issued credentials (SD-JWT, mdoc, …) stored in the wallet.

struct OID4VCManager
{
    typealias C = WalletCoreCommonError

    var storageManager: StorageManager<IssuedCredentialMeta, OID4VCICredential>

    /// Whether at least one issued credential is saved.
    public var isAnyCredentialsSaved: Bool {
        return storageManager.isSaved()
    }

    /// Creates an instance of OID4VCManager to manage the issued-credential wallet.
    /// - Parameter fileName: Name of the wallet file to store the credentials.
    public init(fileName: String) throws {
        if fileName.isEmpty {
            throw C.invalidParameter(code: .oid4vcManager, name: "fileName").getError()
        }

        storageManager = try .init(fileName: fileName, fileExtension: .oid4vc, isEncrypted: true)
    }

    /// Stores an issued credential in the wallet.
    /// - Parameter credential: The issued credential to store.
    func addCredential(credential: OID4VCICredential) throws {
        try storageManager.addItem(walletItem: .init(
            meta: .init(id: credential.id, format: credential.format),
            item: credential))
    }

    /// Returns all issued credentials from the wallet that match the `identifiers`.
    /// - Parameter identifiers: Array of issued-credential IDs.
    /// - Returns: Array of issued credentials.
    func getCredentials(by identifiers: [String]) throws -> [OID4VCICredential] {
        if identifiers.isEmpty {
            throw C.invalidParameter(code: .oid4vcManager, name: "identifiers").getError()
        }

        if identifiers.count != Set(identifiers).count {
            throw C.duplicateParameter(code: .oid4vcManager, name: "identifiers").getError()
        }

        return try storageManager.getItems(by: identifiers).map { $0.item }
    }

    /// Returns all issued credentials stored in the wallet.
    /// - Returns: Array of issued credentials.
    func getAllCredentials() throws -> [OID4VCICredential] {
        return try storageManager.getAllItems().map { $0.item }
    }

    /// Deletes all issued credentials in the wallet that match the `identifiers`.
    /// - Parameter identifiers: Array of issued-credential IDs.
    func deleteCredentials(by identifiers: [String]) throws {
        if identifiers.isEmpty {
            throw C.invalidParameter(code: .oid4vcManager, name: "identifiers").getError()
        }

        if identifiers.count != Set(identifiers).count {
            throw C.duplicateParameter(code: .oid4vcManager, name: "identifiers").getError()
        }

        try storageManager.removeItems(by: identifiers)
    }

    /// Deletes the wallet where the issued credentials are stored.
    func deleteAllCredentials() throws {
        try storageManager.removeAllItems()
    }
}
