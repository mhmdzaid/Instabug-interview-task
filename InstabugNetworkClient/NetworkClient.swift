//
//  NetworkClient.swift
//  InstabugNetworkClient
//
//  Created by Yousef Hamza on 1/13/21.
//

import Foundation

public class NetworkClient {
    public static var shared = NetworkClient()
    var storageManager: DataStorageManagerProtocol? = DataStorageManager()
    // MARK: Network requests
    public func get(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "GET", payload: nil, completionHandler: completionHandler)
    }
    
    public func post(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "POST", payload: payload, completionHandler: completionHandler)
    }
    
    public func put(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "PUT", payload: payload, completionHandler: completionHandler)
    }
    
    public func delete(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "DELETE", payload: nil, completionHandler: completionHandler)
    }
    
    func executeRequest(_ url: URL, method: String, payload: Data?, completionHandler: @escaping (Data?) -> Void) {
        let requestData = RequestData(url: url.absoluteString, requestPayload: payload, method: method)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = payload
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let response = response, let data = data {
                self.handle(requestData: requestData, response: response as! HTTPURLResponse, data: data)
            } else {
                self.storageManager?.SaveRequestWith(requestData: requestData, result: .failure(.serviceUnavailable))
            }
            
            DispatchQueue.main.async {
                completionHandler(data)
            }
        }.resume()
    }
    
    private func handle(requestData: RequestData, response: HTTPURLResponse, data: Data) {
        
        if let domain = response.domain, domain == .success {
            
            let requestResponse = URLSessionResponse(urlResponse: response, payloadResponseData: data)
            storageManager?.SaveRequestWith(requestData: requestData, result: .success(requestResponse))
            
        } else {
            
            let error = HTTPError(rawValue: response.statusCode) ?? .serviceUnavailable
            storageManager?.SaveRequestWith(requestData: requestData, result: .failure(error))
        }
    }
    
    // MARK: Network recording
    public func allNetworkRequests() -> [RequestRecord] {
        var records: [RequestRecord] = []
        storageManager?.fetchAllRecords(completion: { returnedRecords in
            records = returnedRecords
        })
        return records
    }
    
    public func clearAllRecords() {
        storageManager?.clear()
    }
}
