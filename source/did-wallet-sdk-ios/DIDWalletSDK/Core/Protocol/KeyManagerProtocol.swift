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


//MARK: Public
/// General KeyGenRequest Protocol
public protocol KeyGenRequestProtocol
{
    /// Algorithm type for Key
    var algorithmType : AlgorithmType { get }
    /// Key name
    var id : String { get }
    /// Key storage
    var storage : StorageOption { get }
}

/// KeyGenRequest Protocol for Wallet Storage
public protocol WalletKeyGenRequestProtocol : KeyGenRequestProtocol
{
    /// Access method for Wallet
    var accessMethod : WalletAccessMethod { get }
}

/// KeyGenRequest Protocol for Secure Enclave
public protocol SecureKeyGenRequestProtocol : KeyGenRequestProtocol
{
    /// Access method for Secure Enclave
    var accessMethod : SecureEnclaveAccessMethod { get }
    /// Description for Touch ID usage
    var prompt : String { get }
}

//MARK: Private
protocol SignableProtocol
{
    typealias RawKeyPair = (privateKey : Data, publicKey : Data)
    
    func generateKey() throws -> RawKeyPair
    func sign(privateKey : Data, digest : Data) throws -> Data
    func verify(publicKey : Data, digest : Data, signature : Data) throws -> Bool
    func checkKeyPairMatch(privateKey : Data, publicKey : Data) throws
}
