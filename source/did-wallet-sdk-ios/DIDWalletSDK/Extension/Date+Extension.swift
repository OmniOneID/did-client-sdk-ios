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
    public static func getUTC0Date(seconds : UInt) -> String
    {
        var date = Date()
        if seconds > 0
        {
            let doubleSec = TimeInterval(seconds)
            date.addTimeInterval(doubleSec)
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = .init(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.locale = .init(identifier: "en_US_POSIX")
        
        return formatter.string(from: date)
    }
}
