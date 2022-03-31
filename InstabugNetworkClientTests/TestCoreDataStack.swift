//
//  TestDataStoreManager.swift
//  InstabugNetworkClientTests
//
//  Created by Mohamed Zead on 31/03/2022.
//

import CoreData
@testable import InstabugNetworkClient

class TestDataStoreManager: DataStorageManager {
    
    override var recordsLimitNumber: Int {
        return 3
    }
    
    override init() {
        super.init()
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: DataStorageManager.modelName,
                                              managedObjectModel: DataStorageManager.model)
        
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        persistentContainer = container
    }
}
