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

struct ZKPConstants
{
    static let masterSecretKey   : String = "masterSecret"
    static let delta             : String = "DELTA"
    
    static let iteration         : Int = 4
    
    static let largeNonce        : Int = 80
    static let largeMasterSecret : Int = 256
    
    static let largePrime        : Int = 1024
    static let largeVPrime       : Int = (largePrime * 2) + largeNonce
    static let largeVPrimeTilde  : Int = 673
        
    static let largeEStart       : Int = 596
    static let largeEStartValue  : BigInt = BigInt(1) << largeEStart
    
    static let largeMTilde       : Int = 593
    static let largeETilde       : Int = 456
    static let largeVTilde       : Int = 3060
    
    static let largeMVect        : Int = 592
    static let largeUTilde       : Int = 592
    static let largeRTilde       : Int = 672
    static let largeAlphaTilde   : Int = 2787
}
