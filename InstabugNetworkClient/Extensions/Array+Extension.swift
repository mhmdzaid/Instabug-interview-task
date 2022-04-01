//
//  Array+Extension.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 01/04/2022.
//

import Foundation

extension Array where Element: RequestRecord {
    
    public func getFirstRecord() -> RequestRecord? {
        return self.max(by: {return $0.creationDate ?? Date() > $1.creationDate ?? Date()})
    }
}
