//
//  APIXClientConstants.swift
//  
//
//  Created by Bryan Morfe on 2/12/22.
//

import Foundation

// MARK: Constants
public extension APIXClient {
    struct Constants {
        public struct URLScheme {
            public static let http = "http"
            public static let https = "http"
        }
        
        public struct QueryItemKey {
            public static let apiKey = "api_key"
            public static let appSessionID = "app_session_id"
        }
        
        public struct HTTPHeaderField {
            public static let sessionId = "api-x-session-id"
            public static let date = "Date"
            public static let contentType = "Content-Type"
            public static let acceptType = "Content-Type"
        }
        
        public struct HTTPHeaderValue {
            public static let contentTypeJSON = "application/json"
        }
        
        public struct CookieName {
            public static let sessionId = "api-x-session-id"
        }
    }
}
