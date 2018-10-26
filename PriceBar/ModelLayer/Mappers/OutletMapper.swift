//
//  OutletMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/23/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class OutletMapper {
    class func mapper(from outlet: OutletEntity) -> OutletViewItem {
        return OutletViewItem(outletId: outlet.id,
                      name: outlet.name,
                      address: outlet.address,
                      distance: outlet.distance)
    }

}
