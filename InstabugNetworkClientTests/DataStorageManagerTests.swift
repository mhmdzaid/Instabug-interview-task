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
    
    func testSaveRequest() {
        do {
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
            var records: [RequestRecord] = []
            let fetchExpectation = expectation(description: "Fetch is done")
            
            context.perform { [weak self] in
                let fetchRequest = NSFetchRequest<RequestRecord>(entityName: EntityKey.record.rawValue)
                do {
                    records = try self?.context.fetch(fetchRequest) ?? []
                    fetchExpectation.fulfill()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
            wait(for: [fetchExpectation], timeout: 2.0)
            XCTAssertFalse(records.isEmpty)
            XCTAssertEqual(records.first?.request?.url ?? "", "https://httpbin.org/get")
            XCTAssertNotEqual(records.first?.response?.payloadBody ?? "", Messages.largePayload.rawValue)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
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
        
        var returnedRecords: [RequestRecord] = []
        context.perform { [weak self] in
            let fetchRequest = NSFetchRequest<RequestRecord>(entityName: EntityKey.record.rawValue)
            do {
                returnedRecords = try self?.context.fetch(fetchRequest) ?? []
                fetchingExpectation.fulfill()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        wait(for: [fetchingExpectation], timeout: 2)
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
        var returnedRecords: [RequestRecord] = []
        context.perform { [weak self] in
            let fetchRequest = NSFetchRequest<RequestRecord>(entityName: EntityKey.record.rawValue)
            do {
                returnedRecords = try self?.context.fetch(fetchRequest) ?? []
                fetchingExpectation.fulfill()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        wait(for: [fetchingExpectation], timeout: 2)
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
        let url = URL(string: urlString)!
        let urlResponse = URLResponse(url: url,
                                      mimeType: "application/json",
                                      expectedContentLength: -1,
                                      textEncodingName: nil)
        let response = URLSessionResponse(urlResponse: urlResponse, payloadResponseData: responseData)
        let savingExpectation = expectation(description: "saving is done")
        context.perform { [weak self] in
            self?.storageManager.SaveRequestWith(requestData: requestData, result: .success(response))
            savingExpectation.fulfill()
        }
        wait(for: [savingExpectation], timeout: 2)
        var records: [RequestRecord] = []
        let fetchExpectation = expectation(description: "Fetch is done")
        
        context.perform { [weak self] in
            let fetchRequest = NSFetchRequest<RequestRecord>(entityName: EntityKey.record.rawValue)
            do {
                records = try self?.context.fetch(fetchRequest) ?? []
                fetchExpectation.fulfill()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        wait(for: [fetchExpectation], timeout: 2.0)
        XCTAssertFalse(records.isEmpty)
        XCTAssertEqual(Messages.largePayload.rawValue, "(payload too large)")
        XCTAssertEqual(records.first?.response?.payloadBody ?? "", Messages.largePayload.rawValue)
    }
    
    // MARK: - Utilities
    
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
