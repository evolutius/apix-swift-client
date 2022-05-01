import Foundation

/// A client for an API-X server.
///
/// This class provides a mechanism for sending requests to an API-X server.
/// A request must be created using a ``APIXClientRequestBuilder`` object in order
/// to be a valid request.
public class APIXClient {
    
    /// The shared singleton client object.
    public static let shared = APIXClient()
    
    private var session: URLSession

    /// Creates an API-X client object.
    public init() {
        session = .shared
    }
    
    /// Executes an HTTP request to an API-X server.
    ///
    /// The `URLRequest` objects must be created with an ``APIXClientRequestBuilder`` object  to ensure that the request
    /// is compatible with API-X servers.
    ///
    /// - Parameter urlRequest: The `URLRequest` that must be executed.
    /// - Parameter handler: A completion handler that is called when a response is returned or a failure occurs while making the request.
    @available(*, deprecated, renamed: "execute(with:completion:)")
    public func makeRequest(urlRequest: URLRequest, completion handler: @escaping (Dictionary<String, Any>?, Error?) -> Void) {
        execute(with: urlRequest, completion: handler)
    }
    
    /// Executes an HTTP request to an API-X server.
    ///
    /// The `URLRequest` objects must be created with an ``APIXClientRequestBuilder``object  to ensure that the request
    /// is compatible with API-X servers. 
    ///
    /// - Parameter request: The `URLRequest` that must be executed.
    /// - Parameter handler: A completion handler that is called when a response is returned or a failure occurs while making the request.
    public func execute(with request: URLRequest, completion handler: @escaping (Dictionary<String, Any>?, Error?) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                handler(nil, error)
                return
            }
            
            guard let data = data else {
                handler(nil, APIXClient.APIXClientError(kind: .invalidData))
                return
            }
                        
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any> else {
                handler(nil, APIXClient.APIXClientError(kind: .invalidDataType))
                return
            }

            handler(jsonResponse, nil)
        }
        
        task.resume()
    }
}

// MARK: APIXClientError
public extension APIXClient {
    
    /// An API-X error object.
    ///
    /// When a request to an API-X server fails, a API-X Client Error object _may_ be returned.
    /// The kind of error determines where the failure occured. Note that errors may not necessarily
    /// be API-X-specific errors. For example, errors can occur if a server is unreachable, and in such
    /// cases, the error will not be an API-X Client Error object.
    struct APIXClientError : Error {
        
        /// A representation of possible API-X-specific error kinds.
        enum ErrorKind {
            
            /// Represents an error due to invalid data.
            ///
            /// This error can occur if there are no errors but the data is missing.
            case invalidData
            
            /// Represents an error due to invalid data type or shape.
            ///
            /// This error can occur if the received object cannot be converted in an expected
            /// JSON object, i.e., a `[String : Any]` object.
            case invalidDataType
        }
        
        /// The kind of error that occured.
        let kind: ErrorKind
    }
}
