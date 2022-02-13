//
//  File.swift
//  
//
//  Created by Bryan Morfe on 2/12/22.
//

import Foundation
import CommonCrypto

public class APIXClientRequest {
    public var scheme: String?
    public var host: String?
    public var port: Int?
    private var apiKey: String
    private var appKey: String
    
    public init(apiKey: String, appKey: String) {
        self.apiKey = apiKey
        self.appKey = appKey
    }
    
    public func request(forHTTPMethod httpMethod: HTTPMethod, entity: String? = nil, method: String, parameters: [String : String] = [:], httpBody: [String : String]? = nil) -> URLRequest? {
        var httpBodyData: Data? = nil
        
        if let httpBody = httpBody {
            httpBodyData = try? JSONSerialization.data(withJSONObject: httpBody as Any, options: .sortedKeys)
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        let dateString = dateFormatter.string(from: date)
        
        let appSessionID = buildAppSessionID(httpBody: httpBodyData, dateString: dateString) ?? ""
        
        let requiredParameters: [String : String] = [
            APIXClient.Constants.QueryItemKey.apiKey : apiKey,
            APIXClient.Constants.QueryItemKey.appSessionID : appSessionID
        ]
        
        let urlQueryParameters = parameters.merging(requiredParameters) { (current, _) in current }  // User can override parameters
        
        guard let url = url(forEntity: entity, method: method, parameters: urlQueryParameters) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBodyData
        request.setValue(dateString, forHTTPHeaderField: APIXClient.Constants.HTTPHeaderField.date)
        request.setValue(APIXClient.Constants.HTTPHeaderValue.contentTypeJSON, forHTTPHeaderField: APIXClient.Constants.HTTPHeaderField.contentType)
        request.setValue(APIXClient.Constants.HTTPHeaderValue.contentTypeJSON, forHTTPHeaderField: APIXClient.Constants.HTTPHeaderField.acceptType)
                
        return request
    }
    
    public func getRequest(forEntity entity: String? = nil, method: String, parameters: [String : String] = [:]) -> URLRequest? {
        return request(forHTTPMethod: .get, entity: entity, method: method, parameters: parameters)
    }
    
    public func postRequest(forEntity entity: String? = nil, method: String, httpBody: [String : String] = [:]) -> URLRequest? {
        return request(forHTTPMethod: .post, entity: entity, method: method, httpBody: httpBody)
    }
}

// MARK: HTTPMethod
public extension APIXClientRequest {
    enum HTTPMethod : String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}

// MARK: URLBuilder
public extension APIXClientRequest {
    func url(forEntity entity: String?, method: String, parameters: [String : String] = [:]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        
        if let entity = entity {
            urlComponents.path = NSString.path(withComponents: [entity, method])
        } else {
            urlComponents.path = method
        }
        
        var queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let query = URLQueryItem(name: key, value: value)
            queryItems.append(query)
        }
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
}

// MARK: API Security
public extension APIXClientRequest {
    func buildAppSessionID(httpBody: Data?, dateString: String) -> String? {
        let stringToHash = (httpBody?.base64EncodedString() ?? "") + appKey + dateString
        
        guard let data = stringToHash.data(using: .utf8) else {
            return nil
        }
        
        let digest = APIXClientRequest.sha256Digest(forData: data)
        
        return APIXClientRequest.hexDigest(forDigest: digest)
    }
    
    static func sha256Digest(forData data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return Data(hash)
    }
    
    static func hexDigest(forDigest digest: Data) -> String {
        var hexString = ""
        
        digest.withUnsafeBytes({ bytes in
            for byte in bytes {
                hexString += String(format: "%02x", byte)
            }
        })
        
        return hexString
    }
}
