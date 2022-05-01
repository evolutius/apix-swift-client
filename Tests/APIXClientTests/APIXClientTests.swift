import XCTest
@testable import APIXClient

final class APIXClientTests: XCTestCase {
    private let apiKey = "92e42e068f8f5ee625ba59e7e7144d74c24618b9631f75d70ee3cc1faa7060f1"
    private let appKey = "NTgxZWYxOWQ1YWYxNTgxOWFiY2E3YWUwY2QxNDk0M2IwNjJlM2M0MmU4YmEwMzRhMTUwNWEzN2I4ZTU3ZmJkMQ=="
    
    func testAPIXClientRequestRequestCreation() throws {
        let requestBuilder = APIXClientRequestBuilder(apiKey: apiKey, appKey: appKey)
        requestBuilder.scheme = APIXClient.Constants.URLScheme.https
        requestBuilder.host = "api.example.com"
        requestBuilder.port = 8443
        let entity = "/entity"
        let method = "/method"
        let httpBody = [
            "bodyParam1": "value1",
            "bodyParam2": "value2"
        ]
        
        let request = requestBuilder.request(for: .post, entity: entity, method: method, parameters: [
            "param1": "value1",
            "param2": "value2"
        ], httpBody: httpBody)
        
        let url = request?.url
        
        XCTAssertNotNil(request)
        XCTAssertNotNil(url)
        
        if let url = url, let request = request {
            XCTAssertEqual(request.httpMethod, APIXClientRequestBuilder.HTTPMethod.post.rawValue)
            XCTAssertEqual(url.port, requestBuilder.port)
            XCTAssertEqual(url.scheme, requestBuilder.scheme)
            XCTAssertEqual(url.host, requestBuilder.host)
            XCTAssertEqual(url.relativePath, NSString.path(withComponents: [entity, method]))
            
            XCTAssertNotNil(request.httpBody)
            if let httpBodyFromRequest = request.httpBody {
                let parsedHTTPBody = try? JSONSerialization.jsonObject(with: httpBodyFromRequest)
                XCTAssertNotNil(parsedHTTPBody)
                
                if let parsedHTTPBody = parsedHTTPBody as? Dictionary<String, String?> {
                    XCTAssertEqual(parsedHTTPBody["bodyParam1"], httpBody["bodyParam1"])
                    XCTAssertEqual(parsedHTTPBody["bodyParam2"], httpBody["bodyParam2"])
                }
            }
        }
    }
    
    func testAPIXClient() throws {
        let expectation = XCTestExpectation(description: "Reached endpoint successfully")
        
        /// This is a test endpoint that should always be available
        /// The final URL + endpoint should be https://test-apix.bryanmorfe.com/apix/test (exclusing required parameters added by the API-X Client)
        let requestBuilder = APIXClientRequestBuilder(apiKey: apiKey, appKey: appKey)
        requestBuilder.scheme = APIXClient.Constants.URLScheme.https
        requestBuilder.host = "apix-test.bryanmorfe.com"
        let entity = "/apix"
        let method = "/test"
        let request = requestBuilder.getRequest(for: entity, method: method)
        
        XCTAssertNotNil(request)
        
        if let request = request {
            APIXClient.shared.execute(with: request) { response, error in
                XCTAssertNil(error)
                XCTAssertNotNil(response)
                                
                if let response = response {
                    XCTAssertEqual(response["success"] as? Bool, true)
                    XCTAssertNotNil(response["message"] as? String)
                }
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testAPIXClientBuilderPerformanceWithNoParametersOrBody() {
        let requestBuilder = APIXClientRequestBuilder(apiKey: apiKey, appKey: appKey)
        requestBuilder.scheme = APIXClient.Constants.URLScheme.https
        requestBuilder.host = "apix-test.bryanmorfe.com"
        let entity = "/apix"
        let method = "/test"
        
        measure {
            let _ = requestBuilder.request(for: .get, entity: entity, method: method)
        }
    }
    
    func testAPIXClientBuilderPerformanceWithParametersAndBody() {
        let requestBuilder = APIXClientRequestBuilder(apiKey: apiKey, appKey: appKey)
        requestBuilder.scheme = APIXClient.Constants.URLScheme.https
        requestBuilder.host = "apix-test.bryanmorfe.com"
        let entity = "/apix"
        let method = "/test"
        
        measure {
            let _ = requestBuilder.request(
                for: .get,
                entity: entity,
                method: method,
                parameters: [
                    "someKey1" : "someValue1",
                    "someKey2" : "someValue2",
                    "someKey3" : "someValue3",
                    "someKey4" : "someValue4",
                    "someKey5" : "someValue5",
                    "someKey6" : "someValue6",
                ],
                httpBody: [
                    "someKey1" : [0, 1, 2, 3, 4, 5, 6],
                    "someKey2" : ["someKey1" : "someValue1", "someKey2" : "someValue2"],
                    "someKey3" : "someValue3",
                    "someKey4" : 566,
                    "someKey5" : 0.314159,
                    "someKey6" : true,
                ]
            )
        }
    }
}
