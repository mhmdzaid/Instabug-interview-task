//
//  HTTPError.swift
//  InstabugNetworkClient
//
//  Created by Mohamed Zead on 30/03/2022.
//

import Foundation

public enum HTTPError : Int, Error {
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case internalServerError = 500
    case networkIssue
}
