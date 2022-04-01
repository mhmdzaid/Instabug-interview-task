//
//  Constants.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 30/03/2022.
//

import Foundation



enum Constants: String {
    case bundleID = "com.Instabug.InstabugNetworkClient"
    case modelName = "RequestDataModel"
}

enum AttributeKey: String {
    case method
    case url
    case errorCode
    case errorDomain
    case statusCode
    case payloadBody
}

enum Messages: String {
    case largePayload = "(payload too large)"
    case fetchFailure = "Failed to fetch records"
}

enum EntityKey: String {
    case record = "RequestRecord"
    case request = "Request"
    case response = "Response"
}
