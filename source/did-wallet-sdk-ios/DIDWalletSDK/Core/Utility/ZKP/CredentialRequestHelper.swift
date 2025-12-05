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

#if SWIFT_PACKAGE
    import BigInt
#endif

struct CredentialRequestHelper
{
    static func generateCredentialRequest(credentialPublicKey : CredentialPrimaryPublicKey,
                                          proverDid : String,
                                          masterSecret : BigIntString,
                                          credOffer : ZKPCredentialOffer,
                                          nonce : BigIntString,
                                          vPrime : BigInt) throws -> ZKPCredentialRequest
    {
        let ms = masterSecret.bigInt

        let blindedCredSecret = try generateBlindedSecrets(credentialPublicKey: credentialPublicKey,
                                                           masterSecret: ms,
                                                           vPrime: vPrime)
        
        let blindedCredSecretProof = try generateBlindedSecretsProof(publicKey: credentialPublicKey,
                                                                     vPrime: vPrime,
                                                                     blindedSecret: blindedCredSecret,
                                                                     masterSecret: ms,
                                                                     nonce: credOffer.nonce.bigInt)
        
        return ZKPCredentialRequest.init(proverDID: proverDid,
                                      credDefId: credOffer.credDefId,
                                      nonce: nonce,
                                      blindedMs: blindedCredSecret,
                                      blindedMsCorrectnessProof: blindedCredSecretProof)
    }
    
    //BlindedSecretsGenerator
    static func generateBlindedSecrets(credentialPublicKey : CredentialPrimaryPublicKey,
                                       masterSecret : BigInt,
                                       vPrime : BigInt) throws -> BlindedCredentialSecrets
    {
        /**
         * Pseudonym registration
         * For the master secret m1 and Issuer’s public key pkI Prover
         * 1. Generates random r < ρ and computes nym = gm1 hr (mod Γ).
         * 2. Sends nym to the Issuer.
         * */
        
        let s = credentialPublicKey.s.bigInt
        let n = credentialPublicKey.n.bigInt
        
        guard let rMs = credentialPublicKey.r[ZKPConstants.masterSecretKey]
        else
        {
            throw ZKPManagerError.null(value: ZKPConstants.masterSecretKey, group: "credentialPublicKey.r").getError()
        }
        
        /**
         Create nym using issuer publicKey(pk) and masterSecret(m1)
         generates r < p, nym = g^m1 * h^r (mod T)
         u : nym
         u = r1^m1 * s^vPrime (mod n)
         */
        let u = CommitmentHelper.commitment(z: s, zExp: vPrime, s: rMs.bigInt, sExp: masterSecret, modular: n)
        
        var hiddenAttrs : [String] = .init()
        hiddenAttrs.append(ZKPConstants.masterSecretKey)
        
        let blindedCredentialSecrets : BlindedCredentialSecrets = .init(u: u.decimalString,
                                                                        hiddenAttributes: hiddenAttrs)
        
        return blindedCredentialSecrets
        
    }
    
    //BlindedSecretsProofgenerator
    static func generateBlindedSecretsProof(publicKey : CredentialPrimaryPublicKey,
                                            vPrime : BigInt,
                                            blindedSecret : BlindedCredentialSecrets,
                                            masterSecret : BigInt,
                                            nonce : BigInt) throws -> BlindedCredentialSecretsCorrectnessProof
    {
        
        let s = publicKey.s.bigInt
        let n = publicKey.n.bigInt
        
        guard let rMs = publicKey.r[ZKPConstants.masterSecretKey]
        else
        {
            throw ZKPManagerError.null(value: ZKPConstants.masterSecretKey, group: "credentialPublicKey.r").getError()
        }
        
        let vDashTilde = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeVPrimeTilde)

        let mTilde = BigIntUtil.createRandomBigInt(bitLength: ZKPConstants.largeMTilde)

        //1 + Fiat-Shamir Heuristic + security parameter + attribute size
        
        var uTilde = s.power(vDashTilde, modulus: n)
        
        uTilde = uTilde * rMs.bigInt.power(mTilde, modulus: n)
        
        func mod(_ a : BigInt, _ b: BigInt) -> BigInt
        {
            let remainder = a % b
            if remainder.sign == .minus
            {
                return remainder + b
            }
            return remainder
        }
        
//        uTilde %= n
//        uTilde = uTilde.modulus(n)
        uTilde = mod(uTilde, n)
        
        let c = ChallengeBuilder()
            .append(blindedSecret.u)
            .append(uTilde)
            .append(nonce)
            .buildWithHashing()
            
        let vDashCap = (c * vPrime) + vDashTilde
        
        
        let mCap = (c * masterSecret) + mTilde

        let mCaps = [ZKPConstants.masterSecretKey : mCap.decimalString]
        
        let secretProof : BlindedCredentialSecretsCorrectnessProof = .init(c: c.decimalString, vDashCap: vDashCap.decimalString, mCaps: mCaps)
        
        return secretProof
    }
    
}
