//
//  DataStorageManagerProtocol.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 30/03/2022.
//

import Foundation

protocol DataStorageManagerProtocol {
    var recordsLimitNumber: Int { get }
    func SaveRequestWith(requestData: RequestData, result: Result<URLSessionResponse, HTTPError>)
    func fetchAllRecords(completion: @escaping(_ records: [RequestRecord]) -> Void)
    func clear()
}
