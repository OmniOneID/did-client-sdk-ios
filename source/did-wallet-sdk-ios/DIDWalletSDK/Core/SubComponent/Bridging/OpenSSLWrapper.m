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

#import "OpenSSLWrapper.h"
#import <openssl/ec.h>
#import <openssl/ecdsa.h>
#import <openssl/bn.h>
#import <openssl/obj_mac.h>

@implementation OpenSSLWrapper


//MARK: - Public Methods
+ (NSData *)toCompactRepresentationFromX962Signature:(NSData *)signature
                                              digest:(NSData *)digest
                                           publicKey:(NSData *)publicKey
{
    //    ex) 70 bytes = sequence tag byte (1) + sequence length byte (1) + integer tag byte (1) + integer length byte (1) + r value (32) + integer tag byte (1) + integer length byte (1) + s value (32)
        
        const NSUInteger lengthByte = 1;
        const NSUInteger dataSize = 32;
        
        NSUInteger location = 3;    // r length byte location
        NSData *rDataLengthData = [signature subdataWithRange:NSMakeRange(location, lengthByte)];
        NSUInteger rDataLength = 0;
        [rDataLengthData getBytes:&rDataLength length:1];
        location++;
        NSData *rData = [signature subdataWithRange:NSMakeRange(location, rDataLength)];
        location += rDataLength;
        
        location++;
        NSData *sDataLengthData = [signature subdataWithRange:NSMakeRange(location, lengthByte)];
        NSUInteger sDataLength = 0;
        [sDataLengthData getBytes:&sDataLength length:1];
        location++;
        NSData *sData = [signature subdataWithRange:NSMakeRange(location, sDataLength)];
        
        if (rDataLength < dataSize) {
            rData = [self appendZeroToDesignatedLength:dataSize withIsLeft:YES withSourceData:rData];
        } else if (rDataLength > dataSize) {
            rData = [rData subdataWithRange:NSMakeRange(1, dataSize)];
        }
        
        if (sDataLength < dataSize) {
            sData = [self appendZeroToDesignatedLength:dataSize withIsLeft:YES withSourceData:sData];
        } else if (sDataLength > dataSize) {
            sData = [sData subdataWithRange:NSMakeRange(1, dataSize)];
        }
        
        __block ECDSA_SIG *ecdsaSig = ECDSA_SIG_new();

        if (ecdsaSig == NULL) {
            return nil;
        }
            
        __block EC_KEY *ecKey = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
        __block BN_CTX *ctx = BN_CTX_new();
        BN_CTX_start(ctx);
        
        const EC_GROUP *group = EC_KEY_get0_group(ecKey);
        BIGNUM *order = BN_CTX_get(ctx);
        BIGNUM *halforder = BN_CTX_get(ctx);
        EC_GROUP_get_order(group, order, ctx);
        BN_rshift1(halforder, order);
        
        BIGNUM *sourcePr = BN_bin2bn(rData.bytes, (int)rData.length, NULL);
        BIGNUM *sourcePs = BN_bin2bn(sData.bytes, (int)sData.length, NULL);

        void (^freeOpenSSLVariables)(void) = ^{
            BN_CTX_end(ctx);
            BN_CTX_free(ctx);
            EC_KEY_free(ecKey);
            ECDSA_SIG_free(ecdsaSig);
        };

        if (BN_cmp(sourcePs, halforder) > 0) {
            // enforce low S values, by negating the value (modulo the order) if above order/2.
            // cf. https://github.com/bitcoin/bitcoin/blob/v0.9.3/src/key.cpp#L207-L219
            BIGNUM *modifiedPs = BN_new();
            
            if (modifiedPs == NULL) {
                freeOpenSSLVariables();
                return nil;
            }
            
            BN_sub(modifiedPs, order, sourcePs);
            ECDSA_SIG_set0(ecdsaSig, sourcePr, modifiedPs);
            
            unsigned char *convertedBinPs = malloc((BN_num_bytes(modifiedPs)+1) * sizeof(char));
            int retConvertedBinPs = BN_bn2bin(modifiedPs, convertedBinPs);
            if (retConvertedBinPs == 0) {
                free(convertedBinPs);
                freeOpenSSLVariables();
                return nil;
            }
            
            sData = [NSData dataWithBytes:convertedBinPs length:retConvertedBinPs];
            free(convertedBinPs);
            
            if (retConvertedBinPs != dataSize) {
                sData = [self appendZeroToDesignatedLength:dataSize withIsLeft:YES withSourceData:sData];
            }

            BN_clear_free(sourcePs);
        }
        else {
            ECDSA_SIG_set0(ecdsaSig, sourcePr, sourcePs);   
        }
        
        EC_KEY_set_conv_form( ecKey, POINT_CONVERSION_COMPRESSED );
        int recId = 0;
        while (recId < 4) {
            if ([self ECDSA_SIG_recover_key_GFp:ecKey ecSig:ecdsaSig digest:digest.bytes digestLength:(int)digest.length recid:recId check:YES]) {
                int pubKeySize = i2o_ECPublicKey(ecKey, NULL);
                
                unsigned char *pubKey = malloc(pubKeySize);
                unsigned char *front = &pubKey[0];

                i2o_ECPublicKey(ecKey, &front);
                NSData *recoveredPubkey = [NSData dataWithBytes:pubKey length:pubKeySize];
                
                free(pubKey);
                
                if ([recoveredPubkey isEqualToData:publicKey]) {
                    break;
                }
            }
            ++recId;
        }
        
        freeOpenSSLVariables();

        if (recId == 4) {
            return nil;
        }
        
        recId += (27 + 4);

        NSMutableData *modified = [NSMutableData data];
        [modified appendBytes:&recId length:1];
        [modified appendData:rData];
        [modified appendData:sData];
        return modified;
}

+ (NSData *)sign:(NSData *)digest
      privateKey:(NSData *)privateKey
       publicKey:(NSData *)publicKey
           error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    EC_KEY *pkey = [self convertPrivateKeyToEC_KEY:privateKey];
    if (pkey == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWFailToConvertDataToObject userInfo:nil];
        }
        return nil;
    }
    
    ECDSA_SIG *sig = ECDSA_do_sign(digest.bytes, 32, pkey);
    if (sig == NULL){
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWFailToSign userInfo:nil];
        }
        return nil;
    }
    
    int sig_size = i2d_ECDSA_SIG(sig, NULL);
    unsigned char *sig_bytes = malloc(sig_size);
    unsigned char *p;
    memset(sig_bytes, 6, sig_size);

    p = sig_bytes;
    int new_sig_size = i2d_ECDSA_SIG(sig, &p);
    
    NSData *signature = [NSData dataWithBytes:sig_bytes length:new_sig_size];
    
    free(sig_bytes);
    ECDSA_SIG_free(sig);
    
    NSData *result = [self toCompactRepresentationFromX962Signature:signature
                                                             digest:digest
                                                          publicKey:publicKey];
    
    if (!result) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWFailToConvertFormatToCompact userInfo:nil];
        }
        return nil;
    }
    
    return result;
}

+ (BOOL)verify:(NSData *)signature
        digest:(NSData *)digest
     publicKey:(NSData *)publicKey
         error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!signature || signature.length != 65) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWVerifyInvalidParameter userInfo:nil];
        }
        return NO;
    }
    if (!digest || digest.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWVerifyInvalidParameter userInfo:nil];
        }
        return NO;
    }
    if (!publicKey || publicKey.length != 33) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWVerifyInvalidParameter userInfo:nil];
        }
        return NO;
    }

    NSData *recIdData = [signature subdataWithRange:NSMakeRange(0, 1)];
    int recId = 0;
    [recIdData getBytes:&recId length:sizeof(recId)];
    
    if (recId > 3) {
        recId -= 27;
        recId -= 4;
        //27 : compact 24 or 27 ( forcing odd-y 2nd key candidate)
        // 4 : compressed
    }
    if (recId < 0 || recId > 3) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWVerifyInvalidRecoveryId userInfo:nil];
        }
        return NO;
    }
    
    const NSUInteger rLocation = 1;
    const NSUInteger sLocation = 33;
    const NSUInteger dataLength = 32;
    
    NSData *rData = [signature subdataWithRange:NSMakeRange(rLocation, dataLength)];
    NSData *sData = [signature subdataWithRange:NSMakeRange(sLocation, dataLength)];
    
    ECDSA_SIG *ecdsaSig = ECDSA_SIG_new();
    ECDSA_SIG_set0(ecdsaSig, BN_bin2bn(rData.bytes, (int)rData.length, NULL), BN_bin2bn(sData.bytes, (int)sData.length, NULL));
    
    EC_KEY *ecKey = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
    EC_KEY_set_conv_form( ecKey, POINT_CONVERSION_COMPRESSED );
        
    if ([self ECDSA_SIG_recover_key_GFp:ecKey
                                  ecSig:ecdsaSig
                                 digest:digest.bytes
                           digestLength:(int)digest.length
                                  recid:recId
                                  check:YES]) {
        int pubKeySize = i2o_ECPublicKey(ecKey, NULL);
        
        unsigned char * pubKey = malloc(pubKeySize);
        unsigned char *front = &pubKey[0];

        i2o_ECPublicKey(ecKey, &front);
        NSData *recoveredPubkey = [NSData dataWithBytes:pubKey length:pubKeySize];
        
        free(pubKey);
        
        if (![recoveredPubkey isEqualToData:publicKey]) {
            return NO;
        }
        
        return YES;
    }
    else{
        if (error) {
            *error = [NSError errorWithDomain:@"" code:OSWVerifyFailToRecoverPublicKey userInfo:nil];
        }
        return NO;
    }
}


//MARK: - Private Methods
+ (NSData *)appendZeroToDesignatedLength:(NSUInteger)designatedLength withIsLeft:(BOOL)isLeft withSourceData:(NSData*)sourceData {
    NSUInteger sourceLength = sourceData.length;
    
    if (sourceLength >= designatedLength) {
        NSUInteger loc = 0;
        if (!isLeft) {
            loc = sourceLength - designatedLength;
        }
        return [sourceData subdataWithRange:NSMakeRange(loc, designatedLength)];
    }
    
    NSData *resultData = [sourceData copy];

    for (int i = 0; i < designatedLength - sourceLength; i++) {
        char zero = 0;
        NSData *zeroData = [NSData dataWithBytes:&zero length:1];
        NSMutableData *tempData = [NSMutableData dataWithData:zeroData];
        [tempData appendData:resultData];
        resultData = tempData;
    }
    
    return resultData;
}

+ (BOOL)ECDSA_SIG_recover_key_GFp:(EC_KEY *)eckey ecSig:(ECDSA_SIG *)ecsig digest:(const unsigned char *)msg digestLength:(int)msglen recid:(int)recid check:(BOOL)check
{
    if (!eckey) return NO;
    int ret = 0;
    BN_CTX *ctx = NULL;
    BIGNUM *x = NULL;
    BIGNUM *e = NULL;
    BIGNUM *order = NULL;
    BIGNUM *sor = NULL;
    BIGNUM *eor = NULL;
    BIGNUM *field = NULL;
    EC_POINT *R = NULL;
    EC_POINT *O = NULL;
    EC_POINT *Q = NULL;
    BIGNUM *rr = NULL;
    BIGNUM *zero = NULL;
    const BIGNUM *pr = NULL;
    const BIGNUM *ps = NULL;
    ECDSA_SIG_get0(ecsig, &pr, &ps);
    int n = 0;
    int i = recid / 2;
    const EC_GROUP *group = EC_KEY_get0_group(eckey);
    if ((ctx = BN_CTX_new()) == NULL) { ret = -1; goto err; }
    BN_CTX_start(ctx);
    order = BN_CTX_get(ctx);
    if (!EC_GROUP_get_order(group, order, ctx)) { ret = -2; goto err; }
    x = BN_CTX_get(ctx);
    if (!BN_copy(x, order)) { ret=-1; goto err; }
    if (!BN_mul_word(x, i)) { ret=-1; goto err; }
    if (!BN_add(x, x, pr)) { ret=-1; goto err; }
    field = BN_CTX_get(ctx);
    if (!EC_GROUP_get_curve_GFp(group, field, NULL, NULL, ctx)) { ret=-2; goto err; }
    if (BN_cmp(x, field) >= 0) { ret=0; goto err; }
    if ((R = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    if (!EC_POINT_set_compressed_coordinates_GFp(group, R, x, recid % 2, ctx)) { ret=0; goto err; }
    if (check)
    {
        if ((O = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
        if (!EC_POINT_mul(group, O, NULL, R, order, ctx)) { ret=-2; goto err; }
        if (!EC_POINT_is_at_infinity(group, O)) { ret = 0; goto err; }
    }
    if ((Q = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    n = EC_GROUP_get_degree(group);
    e = BN_CTX_get(ctx);
    if (!BN_bin2bn(msg, msglen, e)) { ret=-1; goto err; }
    if (8*msglen > n) BN_rshift(e, e, 8-(n & 7));
    zero = BN_CTX_get(ctx);
//    if (!BN_zero(zero)) { ret=-1; goto err; }
    BN_zero(zero);
    if (!BN_mod_sub(e, zero, e, order, ctx)) { ret=-1; goto err; }
    rr = BN_CTX_get(ctx);
    if (!BN_mod_inverse(rr, pr, order, ctx)) { ret=-1; goto err; }
    sor = BN_CTX_get(ctx);
    if (!BN_mod_mul(sor, ps, rr, order, ctx)) { ret=-1; goto err; }
    eor = BN_CTX_get(ctx);
    if (!BN_mod_mul(eor, e, rr, order, ctx)) { ret=-1; goto err; }
    if (!EC_POINT_mul(group, Q, eor, R, sor, ctx)) { ret=-2; goto err; }
    if (!EC_KEY_set_public_key(eckey, Q)) { ret=-2; goto err; }
    ret = 1;
err:
    if (ctx) {
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
    }
    if (R != NULL) EC_POINT_free(R);
    if (O != NULL) EC_POINT_free(O);
    if (Q != NULL) EC_POINT_free(Q);
    
    return (ret == 1);
}

+ (EC_KEY *)convertPrivateKeyToEC_KEY:(NSData *)privateKey
{
    EC_KEY* eckey = NULL;
    BIGNUM *bn = NULL;
    
    eckey = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
    if (eckey == NULL) {
        return NULL;
    }
    const unsigned char* byte = (const unsigned char*)privateKey.bytes;
    int length = (int)privateKey.length;

    bn = BN_bin2bn(byte, length, NULL);
    if (bn) {
        if (EC_KEY_set_private_key(eckey, bn) != 1) {
            if (eckey) {
                EC_KEY_free(eckey);
            }
        }
    }
    if (bn) {
        BN_free(bn);
    }
    
    return eckey;
}


@end
