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

public enum WalletLogLevel: String {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

public enum WalletLogger {
    
    private static var logLevel: WalletLogLevel = .debug
    private static var onOff: Bool = false
    
    // MARK: - Config
    
    public static func setEnable(_ onOff: Bool) {
        self.onOff = onOff
    }
    
    public static func setLogLevel(_ level: WalletLogLevel) {
        self.logLevel = level
    }
    
    // MARK: - Log Methods
    
    public static func debug(_ message: String, function: String = #function) {
        log(message, level: .debug, function: function)
    }
    
    public static func info(_ message: String, function: String = #function) {
        log(message, level: .info, function: function)
    }
    
    public static func warning(_ message: String, function: String = #function) {
        log(message, level: .warning, function: function)
    }
    
    public static func verbose(_ message: String, function: String = #function) {
        log(message, level: .verbose, function: function)
    }
    
    public static func error(_ message: String, function: String = #function) {
        log(message, level: .error, function: function)
    }
    
    // MARK: - Private
    
    private static func log(_ message: String, level: WalletLogLevel, function: String) {
        guard onOff else { return }
        guard shouldLog(level: level) else { return }
        print("▶️[\(level.rawValue)]◀️ \(function): \(message)")
    }
    
    private static func shouldLog(level: WalletLogLevel) -> Bool {
        let levels: [WalletLogLevel] = [.verbose, .debug, .info, .warning, .error]
        guard let currentIndex = levels.firstIndex(of: logLevel),
              let levelIndex = levels.firstIndex(of: level) else {
            return false
        }
        return levelIndex >= currentIndex
    }
}
