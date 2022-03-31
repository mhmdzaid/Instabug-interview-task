//
//  DataStorageManagerTests.swift
//  InstabugNetworkClientTests
//
//  Created by Mohamed Zead on 31/03/2022.
//

import XCTest
@testable import InstabugNetworkClient

class DataStorageManagerTests: XCTestCase {
    var storeManager: DataStorageManager!
    
    override func setUp() {
        storeManager = TestDataStoreManager()
    }
    
    func testSaveRequest() throws {
        let payloadData = try JSONSerialization.data(withJSONObject: ["id": 5],
                                                     options: .fragmentsAllowed)
        
        let requestData = RequestData(url: "https://httpbin.org/get",
                                      requestPayload: payloadData,
                                      method: "GET")
        
        let response = URLSessionResponse(response: URLResponse(),
                                          data: getDataFrom("RequestToBeSavedResponse"))
        
        storeManager.SaveRequestWith(requestData: requestData,
                                     result: .success(response))
        
        
    }
    
    fileprivate func getDataFrom(_ file: String) -> Data {
        return bundle.path(forResource: file, ofType: "json")?.data(using: .utf8) ?? Data()
    }
    
    private var bundle: Bundle {
        return Bundle(for: DataStorageManagerTests.self)
    }
    
    override func tearDown() {
        storeManager = nil
        super.tearDown()
    }
    
}
