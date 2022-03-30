//
//  DataStorageManager.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 29/03/2022.
//

import Foundation
import CoreData
protocol DataStorageManagerProtocol {
    var identifier: String { get set }
    var modelName: String { get set }
    var recordsLimitNumber: Int { get }
    func SaveRequestWith(requestData: RequestData, result: Result<URLSessionResponse, HTTPError>)
    func fetchAllRecords(completion: @escaping(_ records: [RequestRecord]) -> Void)
}

public class DataStorageManager: DataStorageManagerProtocol {
    public static let shared = DataStorageManager()
    var identifier: String  = Constants.bundleID.rawValue
    var modelName: String = Constants.dataModelName.rawValue
    var recordsLimitNumber: Int {
        return 3
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(identifier: self.identifier)
        let modelURL = bundle!.url(forResource: self.modelName, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { (storeDescription, error) in
            
            if let err = error {
                fatalError("loading failure :\(err.localizedDescription)")
            }
        }
        
        return container
    }()
    lazy var managedObjectContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    /// Saves request record given request data and result of API call
    public func SaveRequestWith(requestData: RequestData, result: Result<URLSessionResponse, HTTPError>) {
        fetchAllRecords { [weak self] records in
            guard let self = self else {
                return
            }
            if records.count == self.recordsLimitNumber {
                self.deleteFirstRecord(from: records)
            }
            self.creatRequestRecord(requestData: requestData, result: result)
        }
    }
    
    public func fetchAllRecords(completion: @escaping(_ records: [RequestRecord]) -> Void) {
        let fetchRequest = NSFetchRequest<RequestRecord>(entityName: Constants.record.rawValue)
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            completion(records)
            
        } catch let fetchError {
            print(Constants.fetchFailure.rawValue + ":" + fetchError.localizedDescription)
        }
    }
    
    fileprivate func deleteFirstRecord(from records: [RequestRecord]) {
        if let firstRequest = records.first {
            self.managedObjectContext.delete(firstRequest)
        }
        self.save()
        
    }
    
    fileprivate func save() {
        do {
            try managedObjectContext.save()
        } catch let error {
            print("Save operation failed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func creatRequestRecord(requestData: RequestData, result: Result<URLSessionResponse, HTTPError>) {
        let record = NSEntityDescription.insertNewObject(forEntityName: Constants.record.rawValue,
                                                         into: managedObjectContext) as! RequestRecord
        let request = createRequestObject(with: requestData)
        let response = createResponseObject(result: result)
        record.response = response
        record.request = request
        save()
    }
    
    fileprivate func createRequestObject(with requestData: RequestData) -> Request {
        let request = NSEntityDescription.insertNewObject(forEntityName: Constants.request.rawValue,
                                                          into: managedObjectContext) as! Request
        request.setValue(requestData.method, forKey: Constants.method.rawValue)
        request.setValue(requestData.url, forKey: Constants.url.rawValue)
        
        if let payloadString = requestData.requestPayload?.payloadString {
            request.setValue(payloadString, forKey: Constants.payloadBody.rawValue)
        }
        
        return request
    }
    
    
    fileprivate func createResponseObject(result: Result<URLSessionResponse, HTTPError>) -> Response {
        let response = NSEntityDescription.insertNewObject(forEntityName: Constants.response.rawValue,
                                                           into: managedObjectContext) as! Response
        switch result {
        case .success(let urlResponse):
            if let httpUrlResponse = urlResponse.response as? HTTPURLResponse {
                
                let statusCode = Int16(httpUrlResponse.statusCode)
                response.setValue(statusCode, forKey: Constants.statusCode.rawValue)
                
                let payloadString = urlResponse.data.payloadString
                response.setValue(payloadString, forKey: Constants.payloadBody.rawValue)
            }
            
        case .failure(let error):
            let errorCode = Int16((error as NSError).code)
            response.setValue(errorCode, forKey: Constants.errorCode.rawValue)
            let errorDomain = (error as NSError).domain
            response.setValue(errorDomain, forKey: Constants.errorDomain.rawValue)
        }
        
        return response
    }
    
}
