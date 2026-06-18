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

/// Manages OID4VCI-issued credentials (SD-JWT, mdoc, …) in an encrypted wallet file.
///
/// This is the OID4VC counterpart to `VCManager`: where `VCManager` stores W3C `VerifiableCredential`
/// VOs, this stores format-specific `IssuedCredential`s keyed by their `id`. Stored in its own file
/// (`oid4vc_credential.vc`) so it never collides with the W3C VC wallet (`vc.vc`).
struct IssuedCredentialManager
{
    private static let fileName = "oid4vc_credential"

    var storageManager: StorageManager<IssuedCredentialMeta, IssuedCredential>

    /// Whether at least one issued credential is saved.
    public var isAnyCredentialsSaved: Bool {
        return storageManager.isSaved()
    }

    init() throws {
        storageManager = try .init(fileName: Self.fileName, fileExtension: .vc, isEncrypted: true)
    }

    /// Stores an issued credential, replacing any existing entry with the same `id`.
    /// - Parameter credential: The issued credential to store.
    func saveCredential(_ credential: IssuedCredential) throws {
        let walletItem: StorageManager<IssuedCredentialMeta, IssuedCredential>.UsableInnerWalletItem =
            .init(meta: .init(id: credential.id, format: credential.format), item: credential)

        if storageManager.isSaved(), (try? storageManager.getMetas(by: [credential.id])) != nil {
            try storageManager.updateItem(walletItem: walletItem)
        } else {
            try storageManager.addItem(walletItem: walletItem)
        }
    }

    /// Returns the issued credentials matching `identifiers`.
    func getCredentials(by identifiers: [String]) throws -> [IssuedCredential] {
        return try storageManager.getItems(by: identifiers).map { $0.item }
    }

    /// Returns all stored issued credentials.
    func getAllCredentials() throws -> [IssuedCredential] {
        return try storageManager.getAllItems().map { $0.item }
    }

    /// Returns the meta (id + format) of all stored issued credentials, without decrypting them.
    func getAllMetas() throws -> [IssuedCredentialMeta] {
        return try storageManager.getAllMetas()
    }

    /// Deletes the issued credentials matching `identifiers`.
    func deleteCredentials(by identifiers: [String]) throws {
        try storageManager.removeItems(by: identifiers)
    }

    /// Deletes the entire issued-credential wallet file.
    func deleteAllCredentials() throws {
        try storageManager.removeAllItems()
    }
}
