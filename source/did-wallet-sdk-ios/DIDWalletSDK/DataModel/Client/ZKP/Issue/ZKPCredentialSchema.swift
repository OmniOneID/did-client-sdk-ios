//
/*
 * Copyright 2025 OmniOne.
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

public struct ZKPCredentialSchema : Jsonable
{
    /// Identifier for the credential schema
    public let id: String
    /// Name of the credential schema
    public let name: String
    /// Version
    public let version: String
    /// List of attribute names
    public let attrNames : [String]
    /// List of attribute types
    public let attrTypes : [AttributeType]
    /// Tag
    public let tag: String
    
    public struct AttributeType : Jsonable
    {
        /// Attribute namespace
        public struct Namespace : Jsonable
        {
            /// Attribute namespace
            public var id   : String
            /// Namespace name
            public var name : String
            /// URL for namespace information
            public var ref  : String?
        }
        
        /// Attribute Definition
        public struct AttributeDef : Jsonable
        {
            /// Attribute Label
            public var label       : String
            /// Attribute name
            public var caption     : CaptionString
            /// Attribute type
            public var type        : AttributeValueType
            /// Internationalization
            public var i18n        : [String : CaptionString]?
        }
        
        /// Attribute Value Type
        public enum AttributeValueType : String, Codable
        {
            case String
            case Number
        }
        
        /// Attribute namespace
        public var namespace : Namespace
        /// List of Attribute definitions
        public var items     : [AttributeDef]
    }
}
