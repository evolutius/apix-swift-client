import Foundation
import Combine

/// A client for an API-X server.
///
/// This class provides a mechanism for sending requests to an API-X server.
/// A request must be created using a ``APIXClient/Request`` object in order
/// to be a valid request.
public class APIXClient {
    /// A publisher that publishes Data objects.
    public typealias Publisher = AnyPublisher<Data, Error>
    
    /// A publisher that publishes JSON objects.
    public typealias JSONPublisher = AnyPublisher<Dictionary<String, Any>, Error>
    
    /// The shared singleton client object.
    public static let shared = APIXClient()
    
    private var session: URLSession

    /// Creates an API-X client object.
    ///
    /// This method will use the shared URL session by default.
    public init() {
        session = .shared
    }
    
    /// Creates an API-X client object and uses a session with the specified session configuration.
    ///
    /// - Parameter configuration: A `URLSession` session configuration object to use
    /// when creating the session that will be used in this client to make requests.
    public init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }
    
    /// Executes an HTTP request to an API-X server.
    ///
    /// The `URLRequest` objects must be created with an ``APIXClient/Request`` object  to ensure that the request
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
                handler(nil, ClientError(kind: .invalidData))
                return
            }
                        
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any> else {
                handler(nil, ClientError(kind: .invalidDataType))
                return
            }

            handler(jsonResponse, nil)
        }
        
        task.resume()
    }
    
    /// Downloads the content of an API-X server URL based on the specified `URLRequest` and
    /// delivers the data asynchronously.
    ///
    /// Use this method to wait until the API-X server finishes transfering data and receive it in a single Data Object instance.
    /// The `URLRequest` objects must be created with an ``APIXClient/Request`` object  to ensure that the request
    /// is compatible with API-X servers.
    ///
    /// - Parameter request: The `URLRequest` that must be executed.
    ///
    /// - Returns An asynchronously-delivered Data object with the contents of the response.
    public func data(from request: URLRequest) async throws -> Data {
        let (data, _) = try await session.data(for: request)
        return data
    }
    
    /// Downloads the content of an API-X server URL based on the specified `URLRequest` and
    /// delivers the data as a JSON object asynchronously.
    ///
    /// Use this method to wait until the API-X server finishes transfering data and receive it in a single JSON Object instance.
    /// The `URLRequest` objects must be created with an ``APIXClient/Request`` object  to ensure that the request
    /// is compatible with API-X servers.
    ///
    /// - Parameter request: The `URLRequest` that must be executed.
    ///
    /// - Returns An asynchronously-delivered JSON object with the contents of the response.
    public func json(from request: URLRequest) async throws -> Dictionary<String, Any> {
        let data = try await data(from: request)
        
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any> else {
            throw ClientError(kind: .invalidDataType)
        }
        
        return jsonResponse
    }
    
    /// Returns a publisher that wraps an API-X server request for a given URL request.
    ///
    /// The publisher publishes a Data object when the request is completed, or terminates
    /// if the request fails with an error. The request must be created with an ``APIXClient/Request``
    /// object. This publisher only produces one value, after which it completes.
    ///
    /// - Parameter request: The URL request for which to create an API-X request.
    ///
    /// - Returns A publisher that publishes Data objects for the given URL request.
    public func publisher(for request: URLRequest) -> Publisher {
        session
            .dataTaskPublisher(for: request)
            .tryMap { $0.data }
            .eraseToAnyPublisher()
    }
    
    /// Returns a publisher that wraps an API-X server request for a given URL request.
    ///
    /// The publisher publishes a JSON object when the request is completed, or terminates
    /// if the request fails with an error. The request must be created with an ``APIXClient/Request``
    /// object. This publisher only produces one value, after which it completes.
    ///
    /// - Parameter request: The URL request for which to create an API-X request.
    ///
    /// - Returns A publisher that publishes JSON objects for the given URL request.
    public func jsonPublisher(for request: URLRequest) -> JSONPublisher {
        session
            .dataTaskPublisher(for: request)
            .tryMap { element -> Dictionary<String, Any> in
                guard let jsonResponse = try? JSONSerialization.jsonObject(with: element.data) as? Dictionary<String, Any> else {
                    throw ClientError(kind: .invalidDataType)
                }
                
                return jsonResponse
            }
            .eraseToAnyPublisher()
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
    struct ClientError : Error {
        
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
