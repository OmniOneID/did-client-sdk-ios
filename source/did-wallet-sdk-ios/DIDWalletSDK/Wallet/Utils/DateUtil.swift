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

public class DateUtil {
    
    public static func checkDate(targetDateStr: String) throws -> Bool {
        WalletLogger.shared.debug("targetDateStr: \(targetDateStr)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC 타임존 설정
        
        guard let targetDate = dateFormatter.date(from: targetDateStr) else {
            throw NSError(domain: "InvalidDateFormat", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC 타임존 설정
        
        
        let utcDate = Date() // 현재 날짜
        let utcDateString = utcDateFormatter.string(from: utcDate)
        
        guard let today = utcDateFormatter.date(from: utcDateString) else {
            throw NSError(domain: "InvalidDateFormat", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        WalletLogger.shared.debug("today: \(today)")
        WalletLogger.shared.debug("untilDate: \(targetDate)")
        
        return today < targetDate
    }
}
