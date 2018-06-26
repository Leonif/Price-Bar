//
//  ItemListMappers.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


class ItemListMappers {
    
    func mapper(from dpModel: DPProductModel, with price: Double) -> ItemListViewEntity {
        let dataProvider = Repository()
        let categoryName = dataProvider.getCategoryName(category: dpModel.categoryId)
        
        return ItemListViewEntity(id: dpModel.id,
                                 product: dpModel.name,
                                 brand: dpModel.brand,
                                 weightPerPiece: dpModel.weightPerPiece,
                                 currentPrice: price,
                                 categoryName: categoryName!)
    }
    
    
    static func merge(products: [ItemListViewEntity], with prices: [ProductPrice]) -> [ItemListViewEntity] {
        let productsWithPrices: [ItemListViewEntity] = products.compactMap { (product)  in
            var price: Double = 0.0
            
            if let index = prices.index(where: { $0.productId == product.id }) {
                price = prices[index].currentPrice
            }

            return ItemListViewEntity(id: product.id,
                                     product: product.product,
                                     brand: product.brand,
                                     weightPerPiece: product.weightPerPiece,
                                     currentPrice: price,
                                     categoryName: product.categoryName)

        }
        
        return productsWithPrices
        
    }
    
}
