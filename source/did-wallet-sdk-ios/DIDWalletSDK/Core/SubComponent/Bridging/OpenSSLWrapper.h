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

#import <Foundation/Foundation.h>

typedef NS_CLOSED_ENUM(NSInteger, OSWSignError) {
    OSWFailToConvertDataToObject = 1,
    OSWFailToSign,
    OSWFailToConvertFormatToCompact,
};

typedef NS_CLOSED_ENUM(NSInteger, OSWVerifyError) {
    OSWVerifyInvalidParameter = 1,
    OSWVerifyInvalidRecoveryId,
    OSWVerifyFailToRecoverPublicKey,
};

NS_ASSUME_NONNULL_BEGIN

@interface OpenSSLWrapper : NSObject

+ (nullable NSData *)toCompactRepresentationFromX962Signature:(NSData *)x962
                                                       digest:(NSData *)digest
                                                    publicKey:(NSData *)publicKey;

+ (nullable NSData *)sign:(NSData *)digest
               privateKey:(NSData *)privateKey
                publicKey:(NSData *)publicKey
                    error:(NSError *_Nullable *_Nullable)error;

//https://stackoverflow.com/questions/45565960/ns-refined-for-swift-and-return-value
//https://github.com/apple/swift-clang/blob/383859a9c4b964af3d127b5cc8abd0a8f11dd164/include/clang/Basic/AttrDocs.td#L1800-L1819
+ (BOOL)verify:(NSData *)signature
        digest:(NSData *)digest
     publicKey:(NSData *)publicKey
         error:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error)));

@end

NS_ASSUME_NONNULL_END
