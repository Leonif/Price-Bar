//
//  ProductMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ProductMapper {
    
    class func transformToDPProductEntity(from fBProductModel: ProductEntity) -> DPProductEntity {
        return DPProductEntity(id: fBProductModel.id,
                               name: fBProductModel.name,
                               brand: fBProductModel.brand,
                               weightPerPiece: fBProductModel.weightPerPiece,
                               categoryId: fBProductModel.categoryId,
                               uomId: fBProductModel.uomId)
        
    }
}
