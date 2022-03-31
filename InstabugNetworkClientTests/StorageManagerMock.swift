//
//  StorageManagerMock.swift
//  InstabugNetworkClientTests
//
//  Created by Mohamed Zead on 31/03/2022.
//

import Foundation
@testable import InstabugNetworkClient

class StorageManagerMock: DataStorageManagerProtocol {
    var isFetchAllRecordsCalled = false
    var isStorageClear = false
    var result: Result<URLSessionResponse, HTTPError>?
    var request: RequestData?
    var identifier: String = "mocked bundle identifier"
    
    var modelName: String = "fake"
    
    var recordsLimitNumber: Int {
        return 3
    }
    
    func SaveRequestWith(requestData: RequestData, result: Result<URLSessionResponse, HTTPError>) {
        request = requestData
        self.result = result
    }
    
    func fetchAllRecords(completion: @escaping ([RequestRecord]) -> Void) {
        isFetchAllRecordsCalled = true
        completion([])
    }
    
    func clear() {
        isStorageClear = true
    }
}
