//
//  APIXClientConstants.swift
//  
//
//  Created by Bryan Morfe on 2/12/22.
//

import Foundation

// MARK: Constants
public extension APIXClient {
    
    /// A structure containing utility constants that are useful when creating and making API-X server requests.
    struct Constants {
        
        /// A structure containing commonly used URL schemes (such as ``http`` and ``https``).
        public struct URLScheme {
            
            /// A string representation of the HTTP URL scheme.
            public static let http = "http"
            
            /// A string representation of the HTTPS URL scheme.
            public static let https = "https"
        }
        
        /// A structure containing API-X specific URL query item names.
        public struct QueryItemKey {
            
            /// A string representation of the API Key URL query name.
            public static let apiKey = "api_key"
            
            /// A string representation of the Application Session ID URL query name.
            public static let appSessionID = "app_session_id"
        }
        
        /// A structure containing utility HTTP header fields used when creating API-X requests.
        public struct HTTPHeaderField {
            
            /// A string representation of the Session ID HTTP header field name.
            public static let sessionId = "api-x-session-id"
            
            /// A string representation of the Date HTTP header field name.
            public static let date = "Date"
            
            /// A string representation of the Content type HTTP header field name.
            public static let contentType = "Content-Type"
            
            /// A string representation of the Accept type HTTP header field name.
            public static let acceptType = "Content-Type"
        }
        
        /// A structure containing utility HTTP header field values used when creating API-X requests.
        public struct HTTPHeaderValue {
            
            /// A string representation of the JSON content type HTTP header field value.
            public static let contentTypeJSON = "application/json"
        }
        
        /// A structure containing utility HTTP cookie names used when creating API-X requests.
        public struct CookieName {
            
            /// A string representation of the Session ID cookie name.
            public static let sessionId = "api-x-session-id"
        }
    }
}
