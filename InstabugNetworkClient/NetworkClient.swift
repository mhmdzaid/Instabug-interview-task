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
        executeRequest(url, method: "POSt", payload: payload, completionHandler: completionHandler)
    }
    
    public func put(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "PUT", payload: payload, completionHandler: completionHandler)
    }
    
    public func delete(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "DELETE", payload: nil, completionHandler: completionHandler)
    }
    
    func executeRequest(_ url: URL, method: String, payload: Data?, completionHandler: @escaping (Data?) -> Void) {
        let requestData = RequestData(url: url.absoluteString,
                                      requestPayload: payload,
                                      method: method)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = payload
        URLSession.shared.dataTask(with: urlRequest) {[weak self] data, response, error in
            guard let self = self else {
                return
            }
            if let response = response, let data = data {
                self.handle(requestData: requestData, response: response as! HTTPURLResponse, data: data)
            } else {
                self.storageManager?.SaveRequestWith(requestData: requestData,
                                                     result: .failure(.networkIssue))
            }
            
            DispatchQueue.main.async {
                completionHandler(data)
            }
        }.resume()
    }
    
    private func handle(requestData: RequestData, response: HTTPURLResponse, data: Data) {
        
        switch response.statusCode {
        case 200:
            let requestResponse = URLSessionResponse(response: response,
                                                     data: data)
            storageManager?.SaveRequestWith(requestData: requestData,
                                            result: .success(requestResponse))
            
        case 400:
            storageManager?.SaveRequestWith(requestData: requestData,
                                            result: .failure(.badRequest))
            
        case 401:
            storageManager?.SaveRequestWith(requestData: requestData,
                                            result: .failure(.unauthorized))
            
        case 403:
            storageManager?.SaveRequestWith(requestData: requestData,
                                            result: .failure(.forbidden))
            
        case 404:
            storageManager?.SaveRequestWith(requestData: requestData,
                                            result: .failure(.notFound))
            
        case 500:
            storageManager?.SaveRequestWith(requestData: requestData,
                                            result: .failure(.internalServerError))
            
        default:
            break
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
}
