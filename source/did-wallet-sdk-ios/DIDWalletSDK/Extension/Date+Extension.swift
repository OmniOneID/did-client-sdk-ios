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

extension Date {
    
    private static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    
    public static func getUTC0Date(seconds : UInt) -> String
    {
        var date = Date()
        if seconds > 0
        {
            let doubleSec = TimeInterval(seconds)
            date.addTimeInterval(doubleSec)
        }
        
        let formatter = getDateFormatter()
        
        return formatter.string(from: date)
    }
    
    public static func getDateFormatter() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.timeZone = .init(identifier: "UTC")
        formatter.dateFormat = dateFormat
        formatter.locale = .init(identifier: "en_US_POSIX")
        
        return formatter
    }
    
    public static func checkValidation(dateString : String) throws
    {
        WalletLogger.shared.debug("dateString: \(dateString)")
        
        let dateFormatter = getDateFormatter()
        
        guard let targetDate = dateFormatter.date(from: dateString) else {
            throw NSError(domain: "InvalidDateFormat", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        let utcDateFormatter = getDateFormatter()
        
        let utcDate = Date()
        let utcDateString = utcDateFormatter.string(from: utcDate)
        
        let today = utcDateFormatter.date(from: utcDateString)!
        
        WalletLogger.shared.debug("today: \(today)")
        WalletLogger.shared.debug("untilDate: \(targetDate)")
        
        if today >= targetDate
        {
            WalletLogger.shared.debug("isValidUntil fail")
            throw WalletAPIError.verifyTokenFail.getError()
        }
    }
}
