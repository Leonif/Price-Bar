//
//  UomMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class UomMapper {
    class func transform(input: UomEntity) -> UomViewItem {
        return UomViewItem(id: input.id,
                          name: input.name,
                          parameters: input.parameters)
    }
}
