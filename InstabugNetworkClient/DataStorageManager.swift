//
//  DataStorageManager.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 29/03/2022.
//

import Foundation
import CoreData

class DataStorageManager: DataStorageManagerProtocol {
    private static let identifier: String  = Constants.bundleID.rawValue
    public static let modelName: String = Constants.modelName.rawValue
    var recordsLimitNumber: Int {
        return 1000
    }
    
    public static let model: NSManagedObjectModel = {
        let bundle = Bundle(identifier: DataStorageManager.identifier)
        let modelURL = bundle!.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(identifier: DataStorageManager.identifier)
        let container = NSPersistentContainer(name: DataStorageManager.modelName,
                                              managedObjectModel: DataStorageManager.model)
        container.loadPersistentStores { (storeDescription, error) in
            if let err = error {
                fatalError("loading failure :\(err.localizedDescription)")
            }
        }
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        return context
    }()
    
    /// Saves request record given request data and result of API call
    func SaveRequestWith(requestData: RequestData, result: Result<URLSessionResponse, HTTPError>) {
        managedObjectContext.perform {
            self.deleteFirstRecordIfExceededLimit()
            self.creatRequestRecord(requestData: requestData, result: result)
        }
    }
    
    func deleteFirstRecordIfExceededLimit() {
        self.fetchAllRecords { [weak self] records in
            guard let self = self else {
                return
            }
            if records.count == self.recordsLimitNumber {
                self.deleteFirstRecord(from: records)
            }
        }
    }
    
    func fetchAllRecords(completion: @escaping(_ records: [RequestRecord]) -> Void) {
        let fetchRequest = NSFetchRequest<RequestRecord>(entityName: EntityKey.record.rawValue)
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            completion(records)
            
        } catch let fetchError {
            print(Messages.fetchFailure.rawValue + ":" + fetchError.localizedDescription)
        }
    }
    
    fileprivate func deleteFirstRecord(from records: [RequestRecord]) {
        if let firstRequest = records.getFirstRecord() {
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
        let record = NSEntityDescription.insertNewObject(forEntityName: EntityKey.record.rawValue,
                                                         into: managedObjectContext) as! RequestRecord
        let request = createRequestObject(with: requestData)
        let response = createResponseObject(result: result)
        record.response = response
        record.request = request
        record.creationDate = Date()
        save()
    }
    
    fileprivate func createRequestObject(with requestData: RequestData) -> Request {
        let request = NSEntityDescription.insertNewObject(forEntityName: EntityKey.request.rawValue,
                                                          into: managedObjectContext) as! Request
        request.setValue(requestData.method, forKey: AttributeKey.method.rawValue)
        request.setValue(requestData.url, forKey: AttributeKey.url.rawValue)
        
        if let payloadString = requestData.requestPayload?.payloadEncodedString {
            request.setValue(payloadString, forKey: AttributeKey.payloadBody.rawValue)
        }
        
        return request
    }
    
    
    fileprivate func createResponseObject(result: Result<URLSessionResponse, HTTPError>) -> Response {
        let response = NSEntityDescription.insertNewObject(forEntityName: EntityKey.response.rawValue,
                                                           into: managedObjectContext) as! Response
        switch result {
        case .success(let urlResponse):
            let httpUrlResponse = urlResponse.urlResponse as? HTTPURLResponse
            
            let statusCode = Int16(httpUrlResponse?.statusCode ?? 200)
            response.setValue(statusCode, forKey: AttributeKey.statusCode.rawValue)
            
            let payloadString = urlResponse.payloadResponseData.payloadEncodedString
            response.setValue(payloadString, forKey: AttributeKey.payloadBody.rawValue)
            
        case .failure(let error):
            let errorCode = Int16((error as NSError).code)
            response.setValue(errorCode, forKey: AttributeKey.errorCode.rawValue)
            
            let errorDomain = (error as NSError).domain
            response.setValue(errorDomain, forKey: AttributeKey.errorDomain.rawValue)
        }
        
        return response
    }
    /// Removes all records from the disk
    func clear() {
        managedObjectContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            
            self.fetchAllRecords { records in
                for record in records {
                    self.managedObjectContext.delete(record)
                }
                self.save()
            }
        }
    }
}
