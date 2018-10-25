//
//  FoursqareProviderError.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/31/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

enum FoursqareProviderError: Error {
    case foursqareDoesntResponce(String)

    case wrongURL(String)
    case parseError(String)
    case noOutlets(String)

    case other(String)

    var errorDescription: String {
        switch self {
        case let .foursqareDoesntResponce(description),
             let .wrongURL(description),
             let .parseError(description),
             let .noOutlets(description),
             let .other(description):
            return description
        }
    }
}
