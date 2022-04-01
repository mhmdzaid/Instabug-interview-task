//
//  DataStorageManagerTests.swift
//  InstabugNetworkClientTests
//
//  Created by Mohamed Zead on 31/03/2022.
//

import XCTest
import CoreData
@testable import InstabugNetworkClient

class DataStorageManagerTests: XCTestCase {
    var storageManager: DataStorageManager!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        storageManager = TestableDataStoreManager()
        context = storageManager.managedObjectContext
    }
    
    func testSaveRequest() throws {
        let payloadData = try JSONSerialization.data(withJSONObject: ["id": 5], options: .fragmentsAllowed)
        let requestData = RequestData(url: "https://httpbin.org/get", requestPayload: payloadData, method: "GET")
        let responsePayload = try getDataFrom("RequestToBeSavedResponse")
        let response = URLSessionResponse(urlResponse: URLResponse(), payloadResponseData: responsePayload)
        
        let saveExpectation = expectation(description: "save is done")
        
        context.perform {
            self.storageManager.SaveRequestWith(requestData: requestData, result: .success(response))
            saveExpectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        let fetchExpectation = expectation(description: "Fetch is done")
        let returnedRecords = fetchAllRecords(with: fetchExpectation)
        
        XCTAssertFalse(returnedRecords.isEmpty)
        XCTAssertEqual(returnedRecords.first?.request?.url ?? "", "https://httpbin.org/get")
        XCTAssertNotEqual(returnedRecords.first?.response?.payloadBody ?? "", Messages.largePayload.rawValue)
        
    }
    
    func testFetchAllRecords() throws {
        let payloadData = try JSONSerialization.data(withJSONObject: ["id": 5], options: .fragmentsAllowed)
        let requestData = RequestData(url: "https://httpbin.org/get", requestPayload: payloadData, method: "GET")
        let responsePayload = try getDataFrom("RequestToBeSavedResponse")
        let response = URLSessionResponse(urlResponse: URLResponse(), payloadResponseData: responsePayload)
        
        let request2Data = RequestData(url: "https://httpbin.org/put", requestPayload: payloadData, method: "PUT")
        
        let savingExpectation = expectation(description: "saving is done")
        context.perform {
            self.storageManager.SaveRequestWith(requestData: requestData, result: .success(response))
            self.storageManager.SaveRequestWith(requestData: request2Data, result: .failure(.unauthorized))
            savingExpectation.fulfill()
        }
        
        wait(for: [savingExpectation], timeout: 2)
        
        let fetchingExpectation = expectation(description: "Fetching all records")
        let returnedRecords = fetchAllRecords(with: fetchingExpectation)
        
        XCTAssertFalse(returnedRecords.isEmpty)
        XCTAssertEqual(returnedRecords.count, 2)
        let firstRecord = returnedRecords.getFirstRecord()
        XCTAssertEqual(firstRecord?.request?.method ?? "", "GET")
        XCTAssertEqual(firstRecord?.request?.url, "https://httpbin.org/get")
    }
    
    func testRespectingRecordingLimit() throws {
        let payloadData = try JSONSerialization.data(withJSONObject: ["id": 5], options: .fragmentsAllowed)
        let requestData = RequestData(url: "https://httpbin.org/get", requestPayload: payloadData, method: "GET")
        let responsePayload = try getDataFrom("RequestToBeSavedResponse")
        let response = URLSessionResponse(urlResponse: URLResponse(), payloadResponseData: responsePayload)
        let request2Data = RequestData(url: "https://httpbin.org/put", requestPayload: payloadData, method: "PUT")
        let request3Data = RequestData(url: "https://httpbin.org/post", requestPayload: payloadData, method: "POST")
        let request4Data = RequestData(url: "https://httpbin.org/delete", requestPayload: payloadData, method: "DELETE")
        
        let savingExpectation = expectation(description: "saving is done")
        
        context.perform { // here we save 4 and our limit is 3 so assertion will be on first GET request
            self.storageManager.SaveRequestWith(requestData: requestData, result: .success(response))
            self.storageManager.SaveRequestWith(requestData: request2Data, result: .failure(.unauthorized))
            self.storageManager.SaveRequestWith(requestData: request3Data, result: .success(response))
            self.storageManager.SaveRequestWith(requestData: request4Data, result: .failure(.internalServerError))
            savingExpectation.fulfill()
        }
        
        wait(for: [savingExpectation], timeout: 2)
        
        let fetchingExpectation = expectation(description: "Fetching all records")
        let returnedRecords = fetchAllRecords(with: fetchingExpectation)

        XCTAssertEqual(storageManager.recordsLimitNumber, 3)
        returnedRecords.forEach { record in
            XCTAssertFalse(record.request?.method ?? "" == "GET")
        }
        let firstRecord = returnedRecords.getFirstRecord()
        XCTAssertEqual(firstRecord?.request?.method ?? "", "PUT")
    }
    
    func testResponseWithPayloadMoreThanMB() throws {
        let urlString = "https://httpbin.org/get"
        let requestData = RequestData(url: urlString, requestPayload: nil, method: "GET")
        let responseData = try getDataFrom("ResponseWithBigPayload")
        let response = URLSessionResponse(urlResponse: URLResponse(), payloadResponseData: responseData)
        let savingExpectation = expectation(description: "saving is done")
        context.perform { [weak self] in
            self?.storageManager.SaveRequestWith(requestData: requestData, result: .success(response))
            savingExpectation.fulfill()
        }
        wait(for: [savingExpectation], timeout: 2)
        
        let fetchExpectation = expectation(description: "Fetch is done")
        let returnedRecords = fetchAllRecords(with: fetchExpectation)
        
        XCTAssertFalse(returnedRecords.isEmpty)
        XCTAssertEqual(Messages.largePayload.rawValue, "(payload too large)")
        XCTAssertEqual(returnedRecords.first?.response?.payloadBody ?? "", Messages.largePayload.rawValue)
    }
    
    func testClearAllRecords() throws {
        let payloadData = try JSONSerialization.data(withJSONObject: ["id": 5], options: .fragmentsAllowed)
        let requestData = RequestData(url: "https://httpbin.org/get", requestPayload: payloadData, method: "GET")
        let responsePayload = try getDataFrom("RequestToBeSavedResponse")
        let response = URLSessionResponse(urlResponse: URLResponse(), payloadResponseData: responsePayload)
        let request2Data = RequestData(url: "https://httpbin.org/put", requestPayload: payloadData, method: "PUT")
        let request3Data = RequestData(url: "https://httpbin.org/post", requestPayload: payloadData, method: "POST")
        let request4Data = RequestData(url: "https://httpbin.org/delete", requestPayload: payloadData, method: "DELETE")
        
        let savingExpectation = expectation(description: "saving is done")
        
        context.perform {
            self.storageManager.SaveRequestWith(requestData: requestData, result: .success(response))
            self.storageManager.SaveRequestWith(requestData: request2Data, result: .failure(.unauthorized))
            self.storageManager.SaveRequestWith(requestData: request3Data, result: .success(response))
            self.storageManager.SaveRequestWith(requestData: request4Data, result: .failure(.internalServerError))
            savingExpectation.fulfill()
        }
        
        wait(for: [savingExpectation], timeout: 2)
        let fetchingExpectation = expectation(description: "Fetching all records")
        var returnedRecords = fetchAllRecords(with: fetchingExpectation)

        XCTAssertFalse(returnedRecords.isEmpty)
        
        storageManager.clear()
        
        let nextFetching = expectation(description: "Fetching after clear all records")
        
        returnedRecords = fetchAllRecords(with: nextFetching)
        XCTAssertTrue(returnedRecords.isEmpty)
    }
    
    // MARK: - Utilities
  
    fileprivate func fetchAllRecords(with expectation: XCTestExpectation) -> [RequestRecord] {
        var records: [RequestRecord] = []
        context.perform { [weak self] in
            self?.storageManager.fetchAllRecords(completion: { returnedRecords in
                records = returnedRecords
                expectation.fulfill()
            })
        }
        waitForExpectations(timeout: 2.0, handler: nil)
        return records
    }
    
    
    fileprivate func getDataFrom(_ file: String) throws -> Data {
        let path = bundle.path(forResource: file, ofType: "json")
        return try Data(contentsOf: URL(fileURLWithPath: path ?? ""))
    }
    
    private var bundle: Bundle {
        return Bundle(for: DataStorageManagerTests.self)
    }
    
    override func tearDown() {
        storageManager = nil
        context = nil
        super.tearDown()
    }
    
}
