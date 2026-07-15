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

/// Registry of credential adapters. Selects the adapter for a format (or by content sniffing).
/// Phase 1 registers SD-JWT and opendid_vc adapters. mdoc is added in Phase 2.
public class CredentialAdapterRegistry {

    public static let shared = CredentialAdapterRegistry()

    private var adapters: [CredentialAdapter] = []

    private init() {
        registerAdapter(SDJWTCredentialAdapter())
        registerAdapter(VerifiableCredentialAdapter())
        // Phase 2: registerAdapter(MDocCredentialAdapter())
    }

    public func registerAdapter(_ adapter: CredentialAdapter) {
        adapters.append(adapter)
    }

    public func findAdapter(_ format: String) -> CredentialAdapter? {
        adapters.first { $0.supports(format) }
    }

    /// Sniffs the raw credential to pick an adapter when the format is not given.
    public func detectAdapter(_ rawCredential: String) -> CredentialAdapter? {
        let trimmed = rawCredential.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // SD-JWT compact form contains '~' disclosure separators.
        if trimmed.contains("~") {
            return findAdapter("dc+sd-jwt-did")
        }
        // opendid_vc is stored as a VerifiableCredential JSON object.
        if trimmed.hasPrefix("{") {
            return findAdapter("opendid_vc")
        }
        return nil
    }

    public func getAllSupportedFormats() -> Set<String> {
        var formats: Set<String> = []
        for adapter in adapters { formats.formUnion(adapter.getSupportedFormats()) }
        return formats
    }

    public func isFormatSupported(_ format: String) -> Bool {
        adapters.contains { $0.supports(format) }
    }

    public func getAllAdapters() -> [CredentialAdapter] { adapters }
}
