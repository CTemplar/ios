//
//  Place.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation

//public struct Place: Codable {
//    let id: String
//    let code: String?
//    let name: String
//    let type: String
//    let location: Location
//    let address: Address?
//    let locality: String?
//    let services: [Service]?
//
//    enum Kind: String {
//        case generic
//        case busStop = "busstop"
//        case place
//        case poi
//        case busStation = "busstation"
//        case trainStation = "trainstation"
//        case undergroundStation = "undergroundstation"
//        case tramStop = "tramstop"
//        case taxiRank = "taxirank"
//        case cycleDock = "cycledock"
//        case ferryTerminal = "ferryterminal"
//        case airport
//    }
//    var placeKind: Kind? {
//        return Kind(rawValue: type.lowercased())
//    }
//
//    static func markedLocation(with location: Location) -> Place {
//        return Place(id: "",
//                     code: nil,
//                     name: "Marked location",
//                     type: "place",
//                     location: location,
//                     address: nil,
//                     locality: "",
//                     services: nil)
//    }
//}
//
//extension Place {
//    var searchSubtitle: String? {
//        switch placeKind {
//        case .some(.busStop), .some(.poi), .some(.place), .some(.generic):
//            return locality
//        default:
//            return nil
//        }
//    }
//}
//
//extension Place: Equatable {
//}
