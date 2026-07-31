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
import os

public enum WalletLogLevel: String, Sendable {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

public enum WalletLogger {

    /// The logger's configuration.
    ///
    /// Every log call reads it from whatever thread the caller is on, while `setEnable` and
    /// `setLogLevel` may be called at any time, so the state is held behind a lock instead of being
    /// free-floating mutable statics. An uncontended lock costs far less than the string
    /// interpolation each log call already performs.
    private struct Config {
        var logLevel: WalletLogLevel = .debug
        var onOff: Bool = false
    }

    private static let config = OSAllocatedUnfairLock(initialState: Config())

    // MARK: - Config

    public static func setEnable(_ onOff: Bool) {
        config.withLock { $0.onOff = onOff }
    }

    public static func setLogLevel(_ level: WalletLogLevel) {
        config.withLock { $0.logLevel = level }
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
        // Read both values under one lock so the decision is made against a single consistent
        // configuration.
        let current = config.withLock { $0 }
        guard current.onOff else { return }
        guard shouldLog(level: level, minimum: current.logLevel) else { return }
        print("▶️[\(level.rawValue)]◀️ \(function): \(message)")
    }

    private static func shouldLog(level: WalletLogLevel, minimum: WalletLogLevel) -> Bool {
        let levels: [WalletLogLevel] = [.verbose, .debug, .info, .warning, .error]
        guard let currentIndex = levels.firstIndex(of: minimum),
              let levelIndex = levels.firstIndex(of: level) else {
            return false
        }
        return levelIndex >= currentIndex
    }
}
