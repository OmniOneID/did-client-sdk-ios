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

public enum RoleTypeEnum: String, Jsonable {
    case Tas = "Tas"
    case Wallet = "Wallet"
    case Issuer = "Issuer"
    case Verifier = "Verifier"
    case WalletProvider = "WalletProvider"
    case CAS_SERVICE = "AppProvider"
    case ListProvider = "ListProvider"
    case OpProvider = "OpProvider"
    case KycProvider = "KycProvider"
    case NotificationProvider = "NotificationProvider"
    case LogProvider = "LogProvider"
    case PortalProvider = "PortalProvider"
    case DelegationProvider = "DelegationProvider"
    case StorageProvider = "StorageProvider"
    case BackupProvider = "BackupProvider"
    case Etc = "Etc"
}
