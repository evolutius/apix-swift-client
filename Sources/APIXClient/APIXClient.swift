import Foundation

public class APIXClient {
    public static let shared = APIXClient()
    private var session: URLSession

    public init() {
        session = .shared
    }
    
    public func makeRequest(urlRequest: URLRequest, completion handler: @escaping (Dictionary<String, Any>?, Error?) -> Void) {
        let task = session.dataTask(with: urlRequest) { data, response, error in
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
    struct APIXClientError : Error {
        enum ErrorKind {
            case invalidData
            case invalidDataType
        }
        
        let kind: ErrorKind
    }
}
