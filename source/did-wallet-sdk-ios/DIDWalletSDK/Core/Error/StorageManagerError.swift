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

enum StorageManagerError: WalletCoreErrorProcotol {
    // Save (101xx)
    case failToSaveWallet(Error)        // Fail to save wallet
    case itemDuplicatedWithItInWallet   // Item duplicated with it in wallet

    // Update (102xx)
    case noItemToUpdate             // No item to update in wallet
    
    // Remove (103xx)
    case noItemsToRemove            // No items to remove in wallet
    case failToRemoveItems(Error)    // Fail to remove items from wallet
    
    // Find (104xx)
    case noItemsSaved               // No items saved in wallet
    case noItemsToFind              // No items to find in wallet
    case failToReadWalletFile(Error)    // Fail to read wallet file
    
    // Item type (105xx)
    case malformedExternalWallet(Error) // Malformed external wallet format
    case malformedWalletSignature       // Malformed wallet signature
    case malformedInnerWallet(Error)    // Malformed inner wallet format
    case malformedItemType(Error)       // Item type designated when object initialize is different with item type of that saved in wallet
    
    // ETC (109xx)
    case unexpectedError(Error)     // Unexpected error occurred
    
    
    func getCodeAndMessage() -> (String, String) {
        switch self {
            // Save (101xx)
        case .failToSaveWallet(let error):
            return ("10100", "Fail to save wallet. error : \(error.toString())")
        case .itemDuplicatedWithItInWallet:
            return ("10101", "Item duplicated with it in wallet")
            
            // Update (102xx)
        case .noItemToUpdate:
            return ("10200", "No item to update in wallet")
            
            // Remove (103xx)
        case .noItemsToRemove:
            return ("10300", "No items to remove in wallet")
        case .failToRemoveItems(let error):
            return ("10301", "Fail to remove items from wallet. error : \(error.toString())")
            
            // Find (104xx)
        case .noItemsSaved:
            return ("10400", "No items saved in wallet")
        case .noItemsToFind:
            return ("10401", "No items to find in wallet")
        case .failToReadWalletFile(let error):
            return ("10402", "Fail to read wallet file. error : \(error.toString())")
            
            // Item type (105xx)
        case .malformedExternalWallet(let error):
            return ("10500", "Malformed external wallet format. error : \(error.toString())")
        case .malformedWalletSignature:
            return ("10501", "Malformed wallet signature")
        case .malformedInnerWallet(let error):
            return ("10502", "Malformed inner wallet format. error : \(error.toString())")
        case .malformedItemType(let error):
            return ("10503", "Malformed item object type about item of inner wallet. error : \(error.toString())")
            
            // ETC (109xx)
        case .unexpectedError(let error):
            return ("10900", "Unexpected error occurred. error : \(error.toString())")
        }
    }
}
