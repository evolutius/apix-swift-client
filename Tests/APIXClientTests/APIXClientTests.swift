import XCTest
@testable import APIXClient

final class APIXClientTests: XCTestCase {
    private let apiKey = "2e9bc6c94a4cbdfe2a31d2df79103a5eb3702eaf5d7018d47a774e9540a8ec29"
    private let appKey = "2e9bc6c94a4cbdfe2a31d2df79103a5eb3702eaf5d7018d47a774e9540a8ec29"
    
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
        let expectedAppSessionID = "5d9d593814b5392e90295f280ebef4477422beb04cf250ac4645042f4b3a2489"  // Must be obtained from API-X Endpoint
        
        XCTAssertEqual(appSessionID, expectedAppSessionID)
    }
    
    func testAPIXClientRequestBuildAppSessionIDWithoutHTTPBody() {
        let apiXClientRequest = APIXClientRequest(apiKey: apiKey, appKey: appKey)
        let appSessionID = apiXClientRequest.buildAppSessionID(httpBody: nil, dateString: "Sat, 12 Feb 2022 07:52:00 GMT")
        let expectedAppSessionID = "6831ad0ab0bb84bc964c4200a73064439fca39f5de169168be8e3d071d1ef1b0"
        
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
        apiXClientRequest.scheme = APIXClient.Constants.URLScheme.http
        apiXClientRequest.host = "localhost"
        apiXClientRequest.port = 3000
        let entity = "/apix"
        let method = "/test"
        let request = apiXClientRequest.getRequest(forEntity: entity, method: method, parameters: [
            "message": "Hello, there",
            "reftag": "test_api_x"
        ])
        
        XCTAssertNotNil(request)
        
        if let request = request {
            APIXClient.shared.makeRequest(urlRequest: request) { response, error in
                XCTAssertNil(error)
                XCTAssertNotNil(response)
                                
                if let response = response {
                    XCTAssertEqual(response["yourMessage"] as? String, "Hello, there")
                    XCTAssertEqual(response["yourReftag"] as? String, "test_api_x")
                }
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
