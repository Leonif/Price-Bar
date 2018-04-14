//
//  BaseStatisticsInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class BaseStatisticsInteractor {

    var repository: Repository!
    
    
    
    func getQuantityOfGood() -> Int {
        return self.repository.getQuantityOfProducts()
    }
}
