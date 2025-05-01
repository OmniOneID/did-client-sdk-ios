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

import Foundation

public struct RequestIssueVc: Jsonable {
    public var id: String
    public var txId: String
    public var serverToken: String
    public var didAuth: DIDAuth
    public var accE2e: AccE2e
    public var encReqVc: String
    
    public init(id: String, txId: String, serverToken: String, didAuth: DIDAuth, accE2e: AccE2e, encReqVc: String) {
        self.id = id
        self.txId = txId
        self.serverToken = serverToken
        self.didAuth = didAuth
        self.accE2e = accE2e
        self.encReqVc = encReqVc
    }
}

public struct E2E: Jsonable {
    // E2E 암복호화 IV, byte_length(16)
    public var iv: String
    // multibase (enc(vc))
    public var encVc: String
    
    public init(iv: String, encVc: String) {
        self.iv = iv
        self.encVc = encVc
    }
}

public struct _RequestIssueVc: Jsonable {
    
    public var txId: String
    public var e2e: E2E
    
    public init(txId: String, e2e: E2E) {
        self.txId = txId
        self.e2e = e2e
    }
}
