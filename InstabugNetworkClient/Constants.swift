//
//  Constants.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 30/03/2022.
//

import Foundation



enum Constants: String {
    
    // Configs
    case bundleID = "com.Instabug.InstabugNetworkClient"
    case dataModelName = "RequestDataModel"
    
    // Entity names
    
    case record = "RequestRecord"
    case request = "Request"
    case response = "Response"
    
    // Request attributes
    
    case method
    case url
    
    // Response attributes
    
    case errorCode
    case errorDomain
    case statusCode
    
    // shared Attributes (Request, Response)
    
    case payloadBody
    
    // Messages
    case largePayload = "(payload too large)"
    case fetchFailure = "Failed to fetch records"
}
