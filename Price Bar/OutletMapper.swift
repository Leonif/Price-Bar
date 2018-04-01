//
//  OutletMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/23/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class OutletMapper {

    class func mapper(from outlet: FQOutletModel) -> OPOutletModel {

        return OPOutletModel(id: outlet.id,
                             name: outlet.name,
                             address: outlet.address, distance: outlet.distance)

    }

    class func mapper(from outlet: OPOutletModel) -> Outlet {

        return Outlet(id: outlet.id,
                      name: outlet.name,
                      address: outlet.address,
                      distance: outlet.distance)

    }

}
