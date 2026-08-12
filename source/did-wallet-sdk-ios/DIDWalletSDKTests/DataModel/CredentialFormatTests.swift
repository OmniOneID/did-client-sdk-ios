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


import XCTest
@testable import DIDWalletSDK

/// The DCQL format tokens, and the single place they are written down.
///
/// These strings cross the wire and cross into apps, so the values themselves are pinned here:
/// changing one is a breaking change and should have to be made twice, once in the code and once
/// in this file. The rest of the suite guards the other half -- that no second copy of a token
/// grows back somewhere in the SDK, which is how a token change goes silently half-applied.
final class CredentialFormatTests: XCTestCase {

    func testTokensAreTheValuesTheWireCarries() {
        XCTAssertEqual(CredentialFormat.vcdm.token, "opendid_vc")
        XCTAssertEqual(CredentialFormat.sdJwtVc.token, "dc+sd-jwt-did")
        XCTAssertEqual(CredentialFormat.msoMdoc.token, "mso_mdoc-did")
    }

    func testACanonicalTokenRoundTrips() {
        for format in [CredentialFormat.vcdm, .sdJwtVc, .msoMdoc] {
            XCTAssertEqual(CredentialFormat(token: format.token), format)
        }
    }

    /// A query is written by the other side, so more spellings are read than are ever written.
    func testAliasesResolveToTheFormatTheyName() {
        XCTAssertEqual(CredentialFormat(token: "vc+sd-jwt"), .sdJwtVc)
        XCTAssertEqual(CredentialFormat(token: "sd-jwt"), .sdJwtVc)
        XCTAssertEqual(CredentialFormat(token: "jwt_vc_json"), .vcdm)
        XCTAssertEqual(CredentialFormat(token: "jwt_vc"), .vcdm)
        XCTAssertEqual(CredentialFormat(token: "ldp_vc"), .vcdm)
    }

    func testAnUnhandledTokenNamesNoFormat() {
        XCTAssertNil(CredentialFormat(token: "mso_mdoc"))
        XCTAssertNil(CredentialFormat(token: ""))
        XCTAssertNil(CredentialFormat(token: "DC+SD-JWT-DID"))
    }

    /// mdoc queries used to warn "may not be supported" because the validator's own list never
    /// picked up the format. One list cannot disagree with itself.
    func testEveryFormatIsKnownToTheValidator() {
        for format in [CredentialFormat.vcdm, .sdJwtVc, .msoMdoc] {
            XCTAssertTrue(CredentialFormat.isKnown(token: format.token), format.token)
        }
    }

    // MARK: - No second copy

    func testAdaptersAnswerWithTheCanonicalTokens() {
        XCTAssertEqual(SDJWTCredentialAdapter().getSupportedFormats(), [CredentialFormat.sdJwtVc.token])
        XCTAssertEqual(MdocCredentialAdapter().getSupportedFormats(), [CredentialFormat.msoMdoc.token])
        XCTAssertEqual(VerifiableCredentialAdapter().getSupportedFormats(), [CredentialFormat.vcdm.token])
    }

    func testPresentersAgreeWithTheirAdapters() {
        XCTAssertEqual(SDJWTPresenter.supportedFormats, SDJWTCredentialAdapter().getSupportedFormats())
        XCTAssertEqual(MdocPresenter.supportedFormats, MdocCredentialAdapter().getSupportedFormats())
    }

    /// The registry picks an adapter from the credential's own shape; the token it looks up has to
    /// be one an adapter claims, or detection silently returns nothing.
    func testDetectionReachesAnAdapterForEveryFormat() throws {
        let registry = CredentialAdapterRegistry.shared

        XCTAssertTrue(registry.detectAdapter(MdocFixtures.pidIssuerSigned) is MdocCredentialAdapter)
        XCTAssertTrue(registry.detectAdapter("eyJhbGciOiJFUzI1NiJ9.eyJ2Y3QiOiJ4In0.sig~") is SDJWTCredentialAdapter)
    }
}
