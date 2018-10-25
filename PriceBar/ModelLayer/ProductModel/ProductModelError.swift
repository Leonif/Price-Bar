//
//  ProductModelError.swift
//  PriceBar Prod
//
//  Created by Leonid Nifantyev on 8/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

enum ProductModelError: Error {
    case syncError(String)
    case alreadyAdded(String)
    case productIsNotFound(String)
    case statisticError(String)
    case other(String)

    var errorDescription: String {
        switch self {
        case .syncError:
            return R.string.localizable.error_sync_stopped()
        case .alreadyAdded:
            return R.string.localizable.common_already_in_list()
        case .productIsNotFound:
            return R.string.localizable.error_product_is_not_found()
        case .other:
            return R.string.localizable.error_something_went_wrong()
        case .statisticError:
            return R.string.localizable.error_no_statistics()
        }
    }
}
