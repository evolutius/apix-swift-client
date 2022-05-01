//
//  File.swift
//  
//
//  Created by Bryan Morfe on 2/12/22.
//

import Foundation
import CommonCrypto

/// A typealias for the ``APIXClientRequestBuilder`` class. This name
/// is deprecated, and the class name should be used instead.
@available(*, deprecated, renamed: "APIXClientRequestBuilder")
typealias APIXClientRequest = APIXClientRequestBuilder

/// A class that handles creating requests for API-X servers.
///
/// API-X servers require very specific data with each request. In addition,
/// it requires that the data be formatted and properly constructed. This object
/// simplifies the process of creating API-X requests.
///
/// All API-X servers require that a valid application make the requests. Applications
/// are identified by their API Key and Application Key. This object requires that both
/// of those keys are provided in the available initializer ``init(apiKey:appKey:)``.
///
/// In addition, a request must be directed to a specific API-X server, and so in order to create
/// a request, the at least the ``scheme`` and ``host`` must be provided. Optionally,
/// users may also provide a ``port``.
///
/// ```swift
/// let requestBuilder = APIXClientRequestBuilder(
///     apiKey: "someAPIKey",
///     appKey: "someAppKey"
/// )
/// requestBuilder.host = "apixserver.com"
/// requestBuilder.scheme = APIXClient.Constants.URLScheme.https
/// let request = requestBuilder.request(
///     for: .get,
///     entity: "someEntity",
///     method: "someMethod"
/// )
/// APIXClient.shared.execute(with: request) { ... }
/// ```
public class APIXClientRequestBuilder {
    /// The scheme of an API-X server. The default value is `"http"`. See related structure ``APIXClient/Constants/URLScheme``.
    public var scheme: String?
    
    /// The hostname of an API-X server, e.g. `www.apixserver.com`. This does not include a ``scheme`` or ``port``.
    public var host: String?
    
    /// The port of an API-X server. The default depends on the ``scheme``, i.e., for an `"http"` scheme, the default is port `80`.
    public var port: Int?
    
    private var apiKey: String
    private var appKey: String
    
    /// Creates an API-X client request object with the specified API Key and Application Key.
    ///
    /// Use this method when initializing an API-X client request object. This method is the designated initializer.
    ///
    /// - Parameter apiKey: The API Key provided by the API-X server owner. Must not be empty.
    /// - Parameter appKey: The Application key provided by the API-X server owner. Must not be empty.
    ///
    /// - Returns: An initialized API-X client request object.
    public init(apiKey: String, appKey: String) {
        self.apiKey = apiKey
        self.appKey = appKey
    }
    
    /// Creates an HTTP request with the specified HTTP method and API-X specific parameters.
    ///
    /// This method creates a request for an API-X server. It will use the content in the parameters, API Key, and
    /// Application Key to generate additional data required for an API-X server to understand and validate the
    /// request.
    ///
    /// - Parameter httpMethod: The ``HTTPMethod`` value corresponding to the HTTP request method.
    /// - Parameter entity: The API-X entity string. This parameter is optional and defaults to `nil`.
    /// - Parameter method: The API-X method string. This parameter is required but can be an empty string.
    /// - Parameter parameters: The URL query parameters to use in the request.
    /// - Parameter httpBody: The HTTP Body of the request.
    ///
    /// - Returns: An `URLRequest` object or `nil` if it could not be created.
    public func request(for httpMethod: HTTPMethod, entity: String? = nil, method: String, parameters: [String : String] = [:], httpBody: [String : Any]? = nil) -> URLRequest? {
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
        
        guard let url = url(for: entity, method: method, parameters: urlQueryParameters) else {
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
    
    /// Creates an HTTP GET request with the specified API-X specific parameters.
    ///
    /// This method creates a GET request for an API-X server. It will use the content in the parameters, API Key, and
    /// Application Key to generate additional data required for an API-X server to understand and validate the
    /// request.
    ///
    /// - Parameter entity: The API-X entity string. This parameter is optional and defaults to `nil`.
    /// - Parameter method: The API-X method string. This parameter is required but can be an empty string.
    /// - Parameter parameters: The URL query parameters to use in the request.
    ///
    /// - Returns: An `URLRequest` object or `nil` if it could not be created.
    @available(*, deprecated, renamed: "getRequest(for:method:parameters:)")
    public func getRequest(forEntity entity: String? = nil, method: String, parameters: [String : String] = [:]) -> URLRequest? {
        return getRequest(for: entity, method: method, parameters: parameters)
    }
    
    /// Creates an HTTP GET request with the specified API-X specific parameters.
    ///
    /// This method creates a GET request for an API-X server. It will use the content in the parameters, API Key, and
    /// Application Key to generate additional data required for an API-X server to understand and validate the
    /// request.
    ///
    /// - Parameter entity: The API-X entity string. This parameter is optional and defaults to `nil`.
    /// - Parameter method: The API-X method string. This parameter is required but can be an empty string.
    /// - Parameter parameters: The URL query parameters to use in the request.
    ///
    /// - Returns: An `URLRequest` object or `nil` if it could not be created.
    public func getRequest(for entity: String? = nil, method: String, parameters: [String : String] = [:]) -> URLRequest? {
        return request(for: .get, entity: entity, method: method, parameters: parameters)
    }
    
    /// Creates an HTTP POST request with the specified API-X specific parameters.
    ///
    /// This method creates a POST request for an API-X server. It will use the content in the parameters, API Key, and
    /// Application Key to generate additional data required for an API-X server to understand and validate the
    /// request.
    ///
    /// - Parameter entity: The API-X entity string. This parameter is optional and defaults to `nil`.
    /// - Parameter method: The API-X method string. This parameter is required but can be an empty string.
    /// - Parameter parameters: The URL query parameters to use in the request.
    /// - Parameter httpBody: The HTTP Body of the request.
    ///
    /// - Returns: An `URLRequest` object or `nil` if it could not be created.
    @available(*, deprecated, renamed: "postRequest(for:method:parameters:httpBody:)")
    public func postRequest(forEntity entity: String? = nil, method: String, parameters: [String : String] = [:], httpBody: [String : Any] = [:]) -> URLRequest? {
        return postRequest(for: entity, method: method, parameters: parameters, httpBody: httpBody)
    }
    
    /// Creates an HTTP POST request with the specified API-X specific parameters.
    ///
    /// This method creates a POST request for an API-X server. It will use the content in the parameters, API Key, and
    /// Application Key to generate additional data required for an API-X server to understand and validate the
    /// request.
    ///
    /// - Parameter entity: The API-X entity string. This parameter is optional and defaults to `nil`.
    /// - Parameter method: The API-X method string. This parameter is required but can be an empty string.
    /// - Parameter parameters: The URL query parameters to use in the request.
    /// - Parameter httpBody: The HTTP Body of the request.
    ///
    /// - Returns: An `URLRequest` object or `nil` if it could not be created.
    public func postRequest(for entity: String? = nil, method: String, parameters: [String : String] = [:], httpBody: [String : Any] = [:]) -> URLRequest? {
        return request(for: .post, entity: entity, method: method, parameters: parameters, httpBody: httpBody)
    }
    
    /// Creates an HTTP PUT request with the specified API-X specific parameters.
    ///
    /// This method creates a PUT request for an API-X server. It will use the content in the parameters, API Key, and
    /// Application Key to generate additional data required for an API-X server to understand and validate the
    /// request.
    ///
    /// - Parameter entity: The API-X entity string. This parameter is optional and defaults to `nil`.
    /// - Parameter method: The API-X method string. This parameter is required but can be an empty string.
    /// - Parameter parameters: The URL query parameters to use in the request.
    /// - Parameter httpBody: The HTTP Body of the request.
    ///
    /// - Returns: An `URLRequest` object or `nil` if it could not be created.
    @available(*, deprecated, renamed: "putRequest(for:method:parameters:httpBody:)")
    public func putRequest(forEntity entity: String? = nil, method: String, parameters: [String : String] = [:], httpBody: [String : Any] = [:]) -> URLRequest? {
        return putRequest(for: entity, method: method, parameters: parameters, httpBody: httpBody)
    }
    
    /// Creates an HTTP PUT request with the specified API-X specific parameters.
    ///
    /// This method creates a PUT request for an API-X server. It will use the content in the parameters, API Key, and
    /// Application Key to generate additional data required for an API-X server to understand and validate the
    /// request.
    ///
    /// - Parameter entity: The API-X entity string. This parameter is optional and defaults to `nil`.
    /// - Parameter method: The API-X method string. This parameter is required but can be an empty string.
    /// - Parameter parameters: The URL query parameters to use in the request.
    /// - Parameter httpBody: The HTTP Body of the request.
    ///
    /// - Returns: An `URLRequest` object or `nil` if it could not be created.
    public func putRequest(for entity: String? = nil, method: String, parameters: [String : String] = [:], httpBody: [String : Any] = [:]) -> URLRequest? {
        return request(for: .put, entity: entity, method: method, parameters: parameters, httpBody: httpBody)
    }
}

// MARK: HTTPMethod
public extension APIXClientRequestBuilder {
    
    /// A representation of HTTP methods that can be specified when creating a request.
    ///
    /// This enum contains values that can be used when creating a request with the
    /// ``request(for:entity:method:parameters:httpBody:)`` method.
    enum HTTPMethod : String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}

// MARK: URLBuilder
private extension APIXClientRequestBuilder {
    func url(for entity: String?, method: String, parameters: [String : String] = [:]) -> URL? {
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
private extension APIXClientRequestBuilder {
    func buildAppSessionID(httpBody: Data?, dateString: String) -> String? {
        let stringToHash = (httpBody?.base64EncodedString() ?? "") + appKey + dateString
        
        guard let data = stringToHash.data(using: .utf8) else {
            return nil
        }
        
        let digest = APIXClientRequestBuilder.sha256Digest(forData: data)
        
        return APIXClientRequestBuilder.hexDigest(forDigest: digest)
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
