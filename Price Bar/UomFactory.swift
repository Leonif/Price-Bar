//
//  UomMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class UomMapper {
    class func mapper(from fbModel: FBUomModel) -> CDUomModel {
        return CDUomModel(id: fbModel.id,
                          name: fbModel.name,
                          iterator: fbModel.iterator,
                          koefficients: fbModel.koefficients,
                          suffixes: fbModel.suffixes)
    }

    class func transform(from fbModelList: [FBUomModel]) -> [CDUomModel] {
        return fbModelList.map { fbUom in
            mapper(from: fbUom)
        }
    }
}


