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
import CryptoKit
@_implementationOnly import OpenSSLWrapper


struct Secp256R1Manager : SignableProtocol
{
    typealias C = WalletCoreCommonError
    typealias E = SignableError
    
    let privateKeySize : Int = 32
    let compressedPublicKeySize : Int = 33
    let digestSize : Int = 32
    let signatureSize : Int = 65
    
    func generateKey() throws -> RawKeyPair
    {
        let privateKey = P256.Signing.PrivateKey()
        let privateKeyData = privateKey.rawRepresentation
        let publicKeyData = try privateKeyData.derivePublicKeyFromPrivateKeyData()
        
        return RawKeyPair(privateKey: privateKeyData,
                          publicKey: publicKeyData)
    }
    
    func sign(privateKey : Data, digest : Data) throws -> Data
    {
        if privateKey.count != privateKeySize
        {
            throw C.invalidParameter(code: .signable,
                                     name: "privateKey").getError()
        }
        
        if digest.count != digestSize
        {
            throw C.invalidParameter(code: .signable,
                                     name: "digest").getError()
        }
        
        let signingKey : P256.Signing.PrivateKey
        do
        {
            signingKey = try P256.Signing.PrivateKey(rawRepresentation: privateKey)
        }
        catch
        {
            throw E.invalidPrivateKey.getError()
        }
            
            
        let dataAsBufferPointer : UnsafeRawBufferPointer = digest.withUnsafeBytes { $0 }
        
        let digest256 = Digest256.init(bufferPointer: dataAsBufferPointer)!
        
        var signed : P256.Signing.ECDSASignature
        
        do
        {
            signed = try signingKey.signature(for: digest256)
        }
        catch
        {
            throw E.createSignature(detail: error).getError()
        }
        
        let derivedPublicKey = try signingKey.derivePublicKeyData()
        
        guard let signature = OpenSSLWrapper.toCompactRepresentation(fromX962Signature: signed.derRepresentation,
                                                                     digest: digest,
                                                                     publicKey: derivedPublicKey)
        else
        {
            throw E.failToConvertCompactRepresentation.getError()
        }
        return signature
    }
    
    func verify(publicKey : Data, digest : Data, signature : Data) throws -> Bool
    {
        if publicKey.count != compressedPublicKeySize
        {
            throw C.invalidParameter(code: .signable,
                                     name: "publicKey").getError()
        }
        
        if digest.count != digestSize
        {
            throw C.invalidParameter(code: .signable,
                                     name: "digest").getError()
        }
        
        if signature.count != signatureSize
        {
            throw C.invalidParameter(code: .signable,
                                     name: "signature").getError()
        }
        
        do
        {
            return try OpenSSLWrapper.verify(signature, 
                                             digest: digest,
                                             publicKey: publicKey)
        }
        catch
        {
            throw E.verifySignatureFailed(detail: error).getError()
        }
    }
    
    func checkKeyPairMatch(privateKey: Data, publicKey: Data) throws 
    {
        if privateKey.count != privateKeySize
        {
            throw C.invalidParameter(code: .signable,
                                     name: "privateKey").getError()
        }
        
        if publicKey.count != compressedPublicKeySize
        {
            throw C.invalidParameter(code: .signable,
                                     name: "publicKey").getError()
        }
        
        let derived = try privateKey.derivePublicKeyFromPrivateKeyData()
        if derived != publicKey
        {
            throw E.notDerivedKeyFromPrivateKey.getError()
        }
    }
    
}

//https://developer.apple.com/forums/thread/696715
fileprivate struct Digest256 : Digest
{
    let bytes: (UInt64, UInt64, UInt64, UInt64)
    
    public static var byteCount: Int = 32
    
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R 
    {
        return try Swift.withUnsafeBytes(of: bytes) {
            let boundsCheckedPtr = UnsafeRawBufferPointer(start: $0.baseAddress,
                                                          count: Self.byteCount)
            return try body(boundsCheckedPtr)
        }
    }
    
    public func hash(into hasher: inout Hasher) 
    {
        self.withUnsafeBytes { hasher.combine(bytes: $0) }
    }
    
    init?(bufferPointer: UnsafeRawBufferPointer)
    {
        guard bufferPointer.count == 32 else {
            return nil
        }
        
        var bytes = (UInt64(0), UInt64(0), UInt64(0), UInt64(0))
        withUnsafeMutableBytes(of: &bytes) { targetPtr in
            targetPtr.copyMemory(from: bufferPointer)
        }
        self.bytes = bytes
    }
    
    func toArray() -> ArraySlice<UInt8> 
    {
        var array = [UInt8]()
        array.appendByte(bytes.0)
        array.appendByte(bytes.1)
        array.appendByte(bytes.2)
        array.appendByte(bytes.3)
        return array.prefix(upTo: SHA256Digest.byteCount)
    }
}

fileprivate extension MutableDataProtocol
{
    mutating func appendByte(_ byte: UInt64)
    {
        withUnsafePointer(to: byte.littleEndian, { self.append(contentsOf: UnsafeRawBufferPointer(start: $0, count: 8)) })
    }
}
