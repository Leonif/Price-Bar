//
//  OutletModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreLocation

typealias OutletResultType = (ResultType<OPOutletModel, OutletModelError>) -> Void
typealias OutletListResultType = (ResultType<[OPOutletModel], OutletModelError>) -> Void


protocol OutletModel {
    
    func searchOutletList(with text: String, nearby coordinates: (lat: Double, lon: Double), completion: @escaping OutletListResultType)
    func getOutlet(with outletId: String, completion: @escaping OutletResultType)
    func nearestOutlet(nearby coordinates: (lat: Double, lon: Double), completion: @escaping OutletResultType)
    func outletList(nearby coordinates: (lat: Double, lon: Double), completion: @escaping OutletListResultType)
}


public enum OutletModelError: Error {
    case outletNotFound(String)
    case userDeniedLocation(String)
    case foursqareDoesntResponce(String)
    case wrongURL(String)
    case parseError(String)
    case other(String)

    var errorDescription: String {
        switch self {
        case let .outletNotFound(description),
             let .userDeniedLocation(description),
             let .foursqareDoesntResponce(description),
             let .wrongURL(description),
             let .parseError(description),
             let .other(description):
            return description
        }
    }
}




