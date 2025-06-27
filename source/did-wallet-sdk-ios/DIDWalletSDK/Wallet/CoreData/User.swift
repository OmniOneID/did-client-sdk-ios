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

struct User {
    var idx: String
    var pii: String
    var finalEncKey: String
    var createDate: String
    var updateDate: String
    
    init(idx: String, pii: String, finalEncKey: String, createDate: String, updateDate: String) {
        self.idx = idx
        self.pii = pii
        self.finalEncKey = finalEncKey
        self.createDate = createDate
        self.updateDate = updateDate
    }
}
