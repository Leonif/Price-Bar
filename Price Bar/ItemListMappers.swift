//
//  ItemListMappers.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


class ItemListMappers {
    
    func mapper(from dpModel: DPProductModel, with price: Double) -> ItemListModelView {
        let dataProvider = Repository()
        let categoryName = dataProvider.getCategoryName(category: dpModel.categoryId)
        
        return ItemListModelView(id: dpModel.id,
                                 product: dpModel.name,
                                 brand: dpModel.brand,
                                 weightPerPiece: dpModel.weightPerPiece,
                                 currentPrice: price,
                                 categoryName: categoryName!)
    }
    
    
    static func merge(products: [ItemListModelView], with prices: [ProductPrice]) -> [ItemListModelView] {
        let productsWithPrices: [ItemListModelView] = products.compactMap { (product)  in
            var price: Double = 0.0
            
            if let index = prices.index(where: { $0.productId == product.id }) {
                price = prices[index].currentPrice
            }

            return ItemListModelView(id: product.id,
                                     product: product.product,
                                     brand: product.brand,
                                     weightPerPiece: product.weightPerPiece,
                                     currentPrice: price,
                                     categoryName: product.categoryName)

        }
        
        return productsWithPrices
        
    }
    
}
