/*
 * Copyright 2024 OmniOne.
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
@testable import DIDWalletSDK
import DIDDataModelSDK
import DIDUtilitySDK
import DIDCommunicationSDK
import DIDCoreSDK

class WalletTokenMock : WalletTokenImpl {
    
    
    
    func verifyWalletToken(hWalletToken: String, purposes: [DIDDataModelSDK.WalletTokenPurposeEnum]) throws {
        
        print("WalletTokenMock!!")
        
        var isPurpose = false
        
        guard let token = MockData.shared.getTokenMock() else {
            print("db verify 실패")
            throw WalletAPIError.selectQueryFail.getError()
        }
        
        if hWalletToken != token.hWalletToken {
            print("hWalletToken 실패")
            print("input hWalletToken: \(hWalletToken)")
            print("saved hWalletToken: \(token.hWalletToken)")
            throw WalletAPIError.verifyTokenFail.getError()
        }
        
        if try !DateUtil.checkDate(targetDateStr: token.validUntil) {
            print("isValidUntil 실패")
            throw WalletAPIError.verifyTokenFail.getError()
        }
        
        for purpose in purposes {
            
            if purpose.value == token.purpose {
                print("verify 성공")
                isPurpose = true
            } else {
//                print("input purpose: \(purpose.value)")
//                print("saved purpose: \(token.purpose)")
            }
        }
        
        if isPurpose == false {
            print("verify 실패")
            throw WalletAPIError.verifyTokenFail.getError()
        }
    }
    
    func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String, userId: String? = nil) throws -> WalletTokenSeed {
        let nonce = "F6438ED0B74B348E3635C89DA164E8FFE"
        
        let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: nonce.data(using: .utf8)!)
        let seed = WalletTokenSeed(purpose: purpose, pkgName: pkgName, nonce: hexNonce, validUntil: "2050-08-23T12:10:02Z", userId: userId)
        
        return seed
    }
    
    func createNonceForWalletToken(walletTokenData: DIDDataModelSDK.WalletTokenData?, APIGatewayURL: String) async throws -> String {
        
        
        let resultNonce = "F9909CA2B700D1EC658098ECE03A97343"
        // Hex
        let hWalletToken = MockData.shared.hWalletToken(purpose: walletTokenData!.seed.purpose)
        
        // certVcRef 검증
        let purpose = WalletTokenPurpose(purpose: walletTokenData!.seed.purpose)
        
        // insert DB
        MockData.shared.setTokenMock(token: TokenMock(idx: "id", walletId: "walletId", hWalletToken: hWalletToken, validUntil: "2050-08-23T12:10:02Z", purpose: purpose.purposeCode.value, nonce: walletTokenData!.seed.nonce, pkgName: walletTokenData!.seed.pkgName, pii: walletTokenData!.sha256_pii, createDate: "2024-08-23T11:40:03.566877Z"))
        
        
        
        return resultNonce
    }
}
