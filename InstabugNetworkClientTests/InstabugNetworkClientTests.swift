//
//  InstabugNetworkClientTests.swift
//  InstabugNetworkClientTests
//
//  Created by Yousef Hamza on 1/13/21.
//

import XCTest
@testable import InstabugNetworkClient

class InstabugNetworkClientTests: XCTestCase {
    var networkClient: NetworkClient!
    var storageManager: StorageManagerMock!
    override func setUpWithError() throws {
        networkClient = NetworkClient()
        storageManager = StorageManagerMock()
        networkClient.storageManager = storageManager
    }
    
    func testClear() {
        networkClient.clearAllRecords()
        XCTAssertTrue(storageManager.isStorageClear)
    }
    
    func testAllNetworkRequests() {
        _ = networkClient.allNetworkRequests()
        XCTAssertTrue(storageManager.isFetchAllRecordsCalled)
    }
    // MARK: GET tests
    
    func testGetRequestSuccess() {
        let requestExpectation = expectation(description: "get request success response")
        guard let url = URL(string: "https://httpbin.org/get") else {
            XCTFail("wrong url .. ")
            return
        }
        networkClient.get(url) { _ in
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 5)
        
        let result = storageManager.result
        
        switch result {
        case .success:
            let request = storageManager.request
            XCTAssertNotNil(request)
            self.runAssertionsFor(request: request!, ofType: .get)
            
            
        case .failure(let error):
            XCTAssertEqual(error, .serviceUnavailable)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    func testGetRequestFailure() {
        let requestExpectation = expectation(description: "get request failure response")
        guard let url = URL(string: "https://httpbin.org/status/500") else {
            XCTFail("wrong url .. ")
            return
        }
        networkClient.get(url) { _ in
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 5)
        
        let result = storageManager.result
        
        switch result {
        case .success:
            let request = storageManager.request
            XCTAssertNotNil(request)
            self.runAssertionsFor(request: request, ofType: .get)
            
        case .failure(let error):
            XCTAssertEqual(error, .internalServerError)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    // MARK: POST tests
    func testPostRequestSuccess() throws {
        let requestExpectation = expectation(description: "post request success response")
        guard let url = URL(string: "https://httpbin.org/post") else {
            XCTFail("wrong url .. ")
            return
        }
        let parameters: [String: Any] = ["id": 10]
        let payloadData = try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        networkClient.post(url, payload: payloadData) { _ in
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 5)
        
        let result = storageManager.result
        
        switch result {
        case .success:
            let request = storageManager.request
            XCTAssertNotNil(request)
            self.runAssertionsFor(request: request!, ofType: .post)
            
        case .failure(let error):
            XCTAssertEqual(error, .serviceUnavailable)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    func testPostRequestFailure() throws {
        let requestExpectation = expectation(description: "post request failure response")
        guard let url = URL(string: "https://httpbin.org/status/401") else {
            XCTFail("wrong url .. ")
            return
        }
        let parameters: [String: Any] = ["id": 10]
        let payloadData = try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        networkClient.post(url, payload: payloadData) { _ in
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 5)
        
        let result = storageManager.result
        
        switch result {
        case .success:
            let request = storageManager.request
            XCTAssertNotNil(request)
            self.runAssertionsFor(request: request!, ofType: .post)
            
        case .failure(let error):
            XCTAssertEqual(error, .unauthorized)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    // MARK: PUT tests
    
    func testPutRequestSuccess() throws {
        let requestExpectation = expectation(description: "put request success response")
        guard let url = URL(string: "https://httpbin.org/put") else {
            XCTFail("wrong url .. ")
            return
        }
        let parameters: [String: Any] = ["id": 10]
        let payloadData = try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        networkClient.put(url, payload: payloadData) { _ in
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 5)
        
        let result = storageManager.result
        
        switch result {
        case .success:
            let request = storageManager.request
            XCTAssertNotNil(request)
            self.runAssertionsFor(request: request!, ofType: .put)
            
        case .failure(let error):
            XCTAssertEqual(error, .serviceUnavailable)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    func testPutRequestFailure() throws {
        let requestExpectation = expectation(description: "put request failure response")
        guard let url = URL(string: "https://httpbin.org/status/403") else {
            XCTFail("wrong url .. ")
            return
        }
        let parameters: [String: Any] = ["id": 10]
        let payloadData = try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        networkClient.put(url, payload: payloadData) { _ in
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 5)
        
        let result = storageManager.result
        
        switch result {
        case .success:
            let request = storageManager.request
            self.runAssertionsFor(request: request, ofType: .put)
            
        case .failure(let error):
            XCTAssertEqual(error, .forbidden)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    // MARK: DELETE tests
    
    func testDeleteRequestSuccess() throws {
        let requestExpectation = expectation(description: "delete request success response")
        guard let url = URL(string: "https://httpbin.org/delete") else {
            XCTFail("wrong url .. ")
            return
        }
        networkClient.delete(url) { _ in
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 5)
        
        let result = self.storageManager.result
        
        switch result {
        case .success:
            let request = self.storageManager.request
            self.runAssertionsFor(request: request, ofType: .delete)
            
        case .failure(let error):
            XCTAssertEqual(error, .serviceUnavailable)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    func testDeleteRequestFailure() throws {
        let requestExpectation = expectation(description: "delete request failure response")
        guard let url = URL(string: "https://httpbin.org/status/400") else {
            XCTFail("wrong url .. ")
            return
        }
        networkClient.delete(url) { _ in
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 5)
        
        let result = storageManager.result
        
        switch result {
        case .success:
            let request = storageManager.request
            self.runAssertionsFor(request: request, ofType: .put)
            
        case .failure(let error):
            XCTAssertEqual(error, .badRequest)
            
        case .none:
            assertionFailure("No response from the API.")
        }
    }
    
    // MARK: Other
    /// Runs assertions on each request based on its type
    fileprivate func runAssertionsFor(request: RequestData?, ofType requestType: RequestType) {
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.method ?? "" , requestType.rawValue.uppercased())
        XCTAssertEqual(request?.url ?? "", requestType.typeStringURL)
        if let payloadData = request?.requestPayload {
            do {
                let payloadDictionary = try JSONSerialization.jsonObject(with: payloadData, options: .fragmentsAllowed) as! [String: Any]
                XCTAssertEqual(payloadDictionary["id"] as! Int, 10)
            } catch let error {
                XCTAssertThrowsError(error)
            }
        }
    }
    
    override func tearDown() {
        storageManager = nil
        networkClient = nil
        super.tearDown()
    }
    
}

enum RequestType: String {
    case get
    case post
    case put
    case delete
    
    var typeStringURL: String {
        return "https://httpbin.org/" + self.rawValue
    }
    /// returns url that will generate response with given status code
    func urlForErrorWith(status: Int) -> String {
        return "https://httpbin.org/status/\(status)"
    }
}
