//
//  Data + Extension.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 30/03/2022.
//

import Foundation

extension Data {
    func isGreaterThanOneMegaByte() -> Bool {
        return Double(self.count / (1024 * 1024)) >= 1
    }
    /// The payload string to be stored directly 
    var payloadString: String {
        let encodedString = (String(data: self, encoding: .utf8) ?? "")
        return isGreaterThanOneMegaByte() ? Messages.largePayload.rawValue : encodedString
    }
}
