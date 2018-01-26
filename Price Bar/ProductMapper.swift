//
//  ProductMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation



class ProductMapper {
    
    
    class func mapper(from dpModel: DPProductModel, for outletId: String) -> ItemListModel {
        
        let dataProvider = DataProvider()
        
        let price = dataProvider.getPrice(for: dpModel.id, and: outletId)
        let minPrice = dataProvider.getMinPrice(for: dpModel.id, and: outletId)
        
        
        return ItemListModel(id: dpModel.id,
                             product: dpModel.name,
                             currentPrice: price,
                             minPrice: minPrice)
    }
    
    
    class func transform(from dpModels: [DPProductModel], for outletId: String) -> [ItemListModel]? {
    
        var itemModels: [ItemListModel] = []
        
    
        for dpModel in dpModels {
            
            itemModels.append(mapper(from: dpModel, for: outletId))
        }
        
        return itemModels
    
    }
    
    
}
