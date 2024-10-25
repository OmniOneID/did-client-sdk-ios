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

public enum CommunicationLogLevel: String {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

public class CommunicationLogger {
    
    public static let shared = CommunicationLogger()
    
    private var logLevel: CommunicationLogLevel = .debug
    private var onOff: Bool = false
    
    private init() {}
    
    public func setEnable(_ onOff: Bool) {
        self.onOff = onOff
    }
    
    public func setLogLevel(_ level: CommunicationLogLevel) {
        self.logLevel = level
    }
    
    public func debug(_ message: String, function: String = #function) {
        log(message, level: .debug, function: function)
    }
    
    public func info(_ message: String, function: String = #function) {
        log(message, level: .info, function: function)
    }
    
    public func warning(_ message: String, function: String = #function) {
        log(message, level: .warning, function: function)
    }
    
    public func verbose(_ message: String, function: String = #function) {
        log(message, level: .verbose, function: function)
    }
    
    public func error(_ message: String, function: String = #function) {
        log(message, level: .error, function: function)
    }
    
    
    private func log(_ message: String, level: CommunicationLogLevel, function: String) {
        if self.onOff == false { return }
        guard shouldLog(level: level) else { return }
        print("▶️[\(level.rawValue)]◀️ \(function): \(message)")
    }
    
    private func shouldLog(level: CommunicationLogLevel) -> Bool {
        let levels: [CommunicationLogLevel] = [.verbose, .debug, .info, .warning, .error]
        guard let currentIndex = levels.firstIndex(of: logLevel) else { return false }
        guard let levelIndex = levels.firstIndex(of: level) else { return false }
        return levelIndex >= currentIndex
    }
}
