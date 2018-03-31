//
//  StatisticMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/28/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol Transforming: class {
}




class StatisticMapper: Transforming {
    
    class func transform<InputModel, OutputModel>(from inputArray: [InputModel],
                                                  parseFunction: (InputModel)->(OutputModel)) -> [OutputModel] {
        var parsedArray: [OutputModel] = []

        inputArray.forEach { item in
            parsedArray.append(parseFunction(item))
        }

        return parsedArray
    }
    
    
    class func mapper(from model: CDStatisticModel) -> DPPriceStatisticModel {
        return DPPriceStatisticModel(outletId: model.outletId,
                                     productId: model.productId,
                                     price: model.price,
                                     date: model.date)
        
    }
}
