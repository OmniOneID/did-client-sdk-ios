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

public struct CommunicationSDKError: Error {
    public var code: String
    public var message: String
}

protocol CommunicationAPIErrorProtocol {
    func getCodeAndMessage() -> (String, String)
    func getError() -> CommunicationSDKError
}

extension CommunicationAPIErrorProtocol {
    func getError() -> CommunicationSDKError {
        let (code, message) = getCodeAndMessage()
        return .init(code: "MSDKCMM" + code, message: message)
    }
}

enum CommunicationAPIError: CommunicationAPIErrorProtocol {
    case unknown
    case incorrectURLconnection
    case invaildParameter
    case serverFail(String)

    public func getCodeAndMessage() -> (String, String) {
        switch self {
        case .unknown:
            return ("00000", "unknown error")
        case .incorrectURLconnection:
            return ("00001", "incorrect url connection")
        case .invaildParameter:
            return ("00002", "invaild parameter")
        case .serverFail(let message):
            return ("00003", "\(String(describing: message))")
        }
    }
}
