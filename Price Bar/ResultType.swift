//
//  ResultType.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/8/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

enum ResultType<A, ErrorType: Error> {
    case success(A)
    case failure(ErrorType)
}
