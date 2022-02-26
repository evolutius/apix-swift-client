import XCTest
@testable import APIXClient

final class APIXClientTests: XCTestCase {
    private let apiKey = "92e42e068f8f5ee625ba59e7e7144d74c24618b9631f75d70ee3cc1faa7060f1"
    private let appKey = "NTgxZWYxOWQ1YWYxNTgxOWFiY2E3YWUwY2QxNDk0M2IwNjJlM2M0MmU4YmEwMzRhMTUwNWEzN2I4ZTU3ZmJkMQ=="
    
    func testAPIXClientRequestRequestCreation() throws {
        let apiXClientRequest = APIXClientRequest(apiKey: apiKey, appKey: appKey)
        apiXClientRequest.scheme = APIXClient.Constants.URLScheme.https
        apiXClientRequest.host = "api.example.com"
        apiXClientRequest.port = 8443
        let entity = "/entity"
        let method = "/method"
        let httpBody = [
            "bodyParam1": "value1",
            "bodyParam2": "value2"
        ]
        
        let request = apiXClientRequest.request(forHTTPMethod: .post, entity: entity, method: method, parameters: [
            "param1": "value1",
            "param2": "value2"
        ], httpBody: httpBody)
        
        let url = request?.url
        
        XCTAssertNotNil(request)
        XCTAssertNotNil(url)
        
        if let url = url, let request = request {
            XCTAssertEqual(request.httpMethod, APIXClientRequest.HTTPMethod.post.rawValue)
            XCTAssertEqual(url.port, apiXClientRequest.port)
            XCTAssertEqual(url.scheme, apiXClientRequest.scheme)
            XCTAssertEqual(url.host, apiXClientRequest.host)
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
    
    func testAPIXClientRequestBuildAppSessionIDWithHTTPBody() {
        let apiXClientRequest = APIXClientRequest(apiKey: apiKey, appKey: appKey)
        let httpBody = [
            "bodyParam1": "value1",
            "bodyParam2": "value2",
        ]
        let httpBodyData = try? JSONSerialization.data(withJSONObject: httpBody as Any)
        let appSessionID = apiXClientRequest.buildAppSessionID(httpBody: httpBodyData, dateString: "Sat, 12 Feb 2022 07:52:00 GMT")
        let expectedAppSessionID = "18d45d1991f2d2d5c1f2e21c0560bf164a7566a8088dcb2e2168b6bb985c8a0b"  // Must be obtained from API-X Endpoint
        
        XCTAssertEqual(appSessionID, expectedAppSessionID)
    }
    
    func testAPIXClientRequestBuildAppSessionIDWithoutHTTPBody() {
        let apiXClientRequest = APIXClientRequest(apiKey: apiKey, appKey: appKey)
        let appSessionID = apiXClientRequest.buildAppSessionID(httpBody: nil, dateString: "Sat, 12 Feb 2022 07:52:00 GMT")
        let expectedAppSessionID = "e0de9837f57b939a8730d35972977cebadb705de9a2459a552d847fa6a45432a"
        
        XCTAssertEqual(appSessionID, expectedAppSessionID)
    }
    
    func testAPIXClientRequestSHA256() throws {
        let sampleData = "SomeData".data(using: .utf8)!
        let hash256 = "e2be1ef8ab38221875b44004a5f801ccd771648047d384b059031a6c65ca6a6f"
        
        let digest = APIXClientRequest.sha256Digest(forData: sampleData)
        
        XCTAssertEqual(APIXClientRequest.hexDigest(forDigest: digest), hash256)
    }
    
    func testAPIXClient() throws {
        let expectation = XCTestExpectation(description: "Reached endpoint successfully")
        
        /** This is a test endpoint that should always be available
         * The final URL + endpoint should be https://test-apix.bryanmorfe.com/apix/test (exclusing required parameters added by the API-X Client)
         */
        let apiXClientRequest = APIXClientRequest(apiKey: apiKey, appKey: appKey)
        apiXClientRequest.scheme = APIXClient.Constants.URLScheme.https
        apiXClientRequest.host = "apix-test.bryanmorfe.com"
        let entity = "/apix"
        let method = "/test"
        let request = apiXClientRequest.getRequest(forEntity: entity, method: method)
        
        XCTAssertNotNil(request)
        
        if let request = request {
            APIXClient.shared.makeRequest(urlRequest: request) { response, error in
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
}
