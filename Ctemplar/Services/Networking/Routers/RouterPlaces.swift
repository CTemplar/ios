//
//  RouterPlaces.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

enum RouterPlaces: BaseRouter {
//    case list(lat: Double, lng: Double, radius: Int?, query: String?, types: [Place.Kind]?)
//
    static let group = "/places"
//
    var method: HTTPMethod {
        switch self {
//        case .list:
        default:
            return .get
        }
    }
//
    var path: String {
        switch self {
//        case .list:
        default:
            return RouterPlaces.group
        }
    }
//
    func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
//        case .list(let lat, let lng, let rad, let qry, let types):
//            var params: [String: Any] = ["lat": lat,
//                                         "lng": lng]
//            if let rad = rad {
//                params["radius"] = rad
//            }
//            if let qry = qry {
//                params["q"] = qry
//            }
//            if let types = types {
//                params["types"] = types.map {$0.rawValue}
//            }
//            return try URLEncoding.default.encode(request, with: params)
        default:
            return try URLEncoding.default.encode(request, with: [:])
        }
    }
}
