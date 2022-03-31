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
    
    override func setUp() {
        storageManager = TestDataStoreManager()
    }
    
    func testSaveRequest() {
        do {
            let payloadData = try JSONSerialization.data(withJSONObject: ["id": 5],
                                                         options: .fragmentsAllowed)
            let requestData = RequestData(url: "https://httpbin.org/get",
                                          requestPayload: payloadData,
                                          method: "GET")
            let response = URLSessionResponse(response: URLResponse(),
                                              data: getDataFrom("RequestToBeSavedResponse"))
            
            storageManager.SaveRequestWith(requestData: requestData,
                                           result: .success(response))
            
            let context = storageManager.managedObjectContext
            var records: [RequestRecord] = []
            let fetchExpectation = expectation(description: "Fetch is done")
            
            context.perform {
                let fetchRequest = NSFetchRequest<RequestRecord>(entityName: EntityKey.record.rawValue)
                do {
                    records = try context.fetch(fetchRequest)
                    fetchExpectation.fulfill()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
            wait(for: [fetchExpectation], timeout: 2.0)
            XCTAssertFalse(records.isEmpty)
            XCTAssertEqual(records.first?.request?.url ?? "", "https://httpbin.org/get")
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFetchAllRecords() throws {
        let payloadData = try JSONSerialization.data(withJSONObject: ["id": 5],
                                                     options: .fragmentsAllowed)
        let requestData = RequestData(url: "https://httpbin.org/get",
                                      requestPayload: payloadData,
                                      method: "GET")
        let response = URLSessionResponse(response: URLResponse(),
                                          data: getDataFrom("RequestToBeSavedResponse"))
        
        let request2Data = RequestData(url: "https://httpbin.org/put",
                                                  requestPayload: payloadData,
                                                  method: "PUT")
        
        let savingExpectation = expectation(description: "saving is done")
        let context = storageManager.managedObjectContext
        context.performAndWait {
            self.storageManager.SaveRequestWith(requestData: requestData, result: .success(response))
            self.storageManager.SaveRequestWith(requestData: request2Data, result: .failure(.unauthorized))
            savingExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        let fetchingExpectation = expectation(description: "Fetching all records")
        var returnedRecords: [RequestRecord] = []
        storageManager.fetchAllRecords { records in
            fetchingExpectation.fulfill()
            returnedRecords = records
        }
        wait(for: [fetchingExpectation], timeout: 2)
        XCTAssertFalse(returnedRecords.isEmpty)
        XCTAssertEqual(returnedRecords.count, 2)
        XCTAssertEqual(returnedRecords.first?.request?.method ?? "", "GET")
        XCTAssertEqual(returnedRecords[1].request?.url ?? "", "https://httpbin.org/put")
    }
    
    func test() {
        storageManager.deleteFirstRecordIfExceededLimit()
    }
    fileprivate func getDataFrom(_ file: String) -> Data {
        return bundle.path(forResource: file, ofType: "json")?.data(using: .utf8) ?? Data()
    }
    
    private var bundle: Bundle {
        return Bundle(for: DataStorageManagerTests.self)
    }
    
    override func tearDown() {
        storageManager = nil
        super.tearDown()
    }
    
}
