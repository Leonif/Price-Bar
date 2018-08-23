//
//  UomMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class UomMapper {
    
    class func mapper(from fbModel: UomEntity) -> UomViewItem {
        return UomViewItem(id: fbModel.id,
                          name: fbModel.name,
                          parameters: fbModel.parameters)
    }
    
    class func transform(from fbModelList: [UomEntity]) -> [UomViewItem] {
        return fbModelList.map { fbUom in
            mapper(from: fbUom)
        }
    }
}
