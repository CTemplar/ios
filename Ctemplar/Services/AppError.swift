//
//  AppError.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation

public enum AppError: Error {
    case downcastingFailed
    case cryptoFailed
    case connectivityIssue
//    case timeoutIssue
//    case unauthorized(value: ServerError?)
//    case serverMaintenance
    case serverError(value: String)
//    case custom(message: String)
//    case userDiscardedRequest
    case unknown

    public var isConnectionError: Bool {
        if case .connectivityIssue = self { return true }
        return false
    }

//    public var allowsRetry: Bool {
//        switch self {
//        case .serverError, .connectivityIssue:
//            return true
//        default:
//            return false
//        }
//    }
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .downcastingFailed:
            return "Downcasting failed"
        case .cryptoFailed:
            return "Hashing failed"
        case .connectivityIssue:
            return "No connection error"
        case .unknown:
            return "Unknown error"
        case .serverError(let value):
            return value
//        case .unauthorized(let value):
//            return value?.message
//        case .userDiscardedRequest:
//            return nil
//        case .custom(let message):
//            return message
//        case .serverMaintenance:
//            return Localization.Errors.maintenanceError.localized
//        case .timeoutIssue:
//            return Localization.Errors.noConnectionError.localized
        }
    }
}

//extension DTDError {
//    public static func from(response: HTTPURLResponse, with data: Data?) -> DTDError? {
//        switch response.statusCode {
//        case 200..<300:
//            return nil
//        case 503:
//            return .serverMaintenance
//        case 400..<600:
//            let serverError: () -> ServerError? = {
//                guard let d = data else {
//                    return nil
//                }
//                let jsonDecoder = JSONDecoder()
//                let errorData = try? jsonDecoder.decode(ServerErrorResponse.self, from: d)
//
//                guard let serverErrors = errorData?.errors, let first = serverErrors.first else {
//                    let errorString = String(data: d, encoding: .utf8)
//                    log.debug(errorString ?? "Error")
//
//                    return nil
//                }
//
//                log.debug(serverErrors)
//
//                return first
//            }
//            let serErr = serverError()
//
//            guard response.statusCode != 401 else {
//                return .unauthorized(value: serErr)
//            }
//            return .serverError(value: serErr)
//        default:
//            return .unknown
//        }
//    }
//}

//extension Error {
//    var dtd: DTDError {
//        if let dtd = self as? DTDError {
//            return dtd
//        }
//        let nsError = self as NSError
//
//        switch nsError.code {
//        case NSURLErrorTimedOut:
//            return .timeoutIssue
//        case -1009:
//            return .connectivityIssue
//        case 401:
//            return .unauthorized(value: nil)
//        case 503:
//            return .serverMaintenance
//        default:
//            return .unknown
//        }
//    }
//}
