//
//  OutletFactory.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/23/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class OutletFactory {

    class func transform(from fqOutlets: [FQOutletModel]) -> [OPOutletModel] {
        var opModel: [OPOutletModel] = []

        for out in fqOutlets {
            opModel.append(mapper(from: out))
        }

        return opModel
    }

    class func mapper(from outlet: FQOutletModel) -> OPOutletModel {

        return OPOutletModel(id: outlet.id,
                             name: outlet.name,
                             address: outlet.address, distance: outlet.distance)

    }

    class func transform(from fqOutlets: [OPOutletModel]) -> [Outlet] {
        var outlets: [Outlet] = []

        for out in fqOutlets {
            outlets.append(mapper(from: out))
        }

        return outlets
    }

    class func mapper(from outlet: OPOutletModel) -> Outlet {

        return Outlet(id: outlet.id,
                      name: outlet.name,
                      address: outlet.address,
                      distance: outlet.distance)

    }

}
