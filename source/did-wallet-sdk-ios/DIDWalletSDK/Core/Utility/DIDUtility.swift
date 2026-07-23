//
/*
 * Copyright 2026 OmniOne.
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
    
struct DIDKeyIdentifier
{
    let did: String
    let versionId: String
    let kid: String
}

struct DIDUtility
{
    static func parseDIDKeyIdentifier(_ input: String) -> DIDKeyIdentifier?
    {
        let kidParts = input.split(
            separator: "#",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )

        guard kidParts.count == 2 else {
            return nil
        }

        let beforeKid = String(kidParts[0])
        let kid = String(kidParts[1])

        let versionParts = beforeKid.components(separatedBy: "?versionId=")

        guard versionParts.count == 2 else {
            return nil
        }

        return DIDKeyIdentifier(
            did: versionParts[0],
            versionId: versionParts[1],
            kid: kid
        )
    }
}




