//
//  ItemListMappers.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


class ItemListMappers {

    static func merge(products: [ItemListViewEntity], with categories: [DPProductCategoryEntity]) -> [ItemListViewEntity] {
        let productsWithCategories: [ItemListViewEntity] = products.compactMap { (product)  in
            
            
            guard  let index = categories.index(where: { $0.productId == product.id }) else {
                fatalError()
            }
            
            return ItemListViewEntity(id: product.id,
                                      product: product.product,
                                      brand: product.brand,
                                      weightPerPiece: product.weightPerPiece,
                                      currentPrice: 0.0,
                                      categoryName: categories[index].categoryName )
            
        }
        return productsWithCategories
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
