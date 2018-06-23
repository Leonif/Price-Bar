//
//  ItemListPresenter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


class ItemListPresenter {
    var repository: Repository!
    var onLoadedData: (([ItemListModelView])->Void) = { _ in}
    var onNextBatch: (([ItemListModelView])->Void) = { _ in}
    
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func getProductWithPrices(offset: Int, limit: Int,  for outletId: String) {
        guard
            let products = repository.getShopItems(with: offset, limit: limit, for: outletId) else {
                return
        }
        
        let productAdjusted: [ItemListModelView] = products.compactMap {
            guard let categoryName = repository.getCategoryName(category: $0.categoryId) else { return nil }
            
            return ItemListModelView(id: $0.id,
                              product: $0.name,
                              brand: $0.brand,
                              weightPerPiece: $0.weightPerPiece,
                              currentPrice: 0,
                              categoryName: categoryName)
        }
        
        
        repository.getPricesFor(outletId: outletId, completion: { (prices) in
            let productsWithPrices = ItemListMappers
                .merge(products: productAdjusted, with: prices)
                .sorted { $0.currentPrice > $1.currentPrice  }
            
            self.onLoadedData(productsWithPrices)
        })
    }
    
    
    func getNextBatch(offset: Int, limit: Int,  for outletId: String) {
        guard
            let products = repository.getShopItems(with: offset, limit: limit, for: outletId) else {
                return
        }
        
        
        let productAdjusted: [ItemListModelView] = products.compactMap {
            guard let categoryName = repository.getCategoryName(category: $0.categoryId) else { return nil }
            
            return ItemListModelView(id: $0.id,
                                     product: $0.name,
                                     brand: $0.brand,
                                     weightPerPiece: $0.weightPerPiece,
                                     currentPrice: 0,
                                     categoryName: categoryName)
        }
        
        
        repository.getPricesFor(outletId: outletId, completion: { (prices) in
            let productsWithPrices = ItemListMappers
                .merge(products: productAdjusted, with: prices)
                .sorted { $0.currentPrice > $1.currentPrice  }
            
            self.onNextBatch(productsWithPrices)
        })
        
    }
    
    
    func filterList(basedOn searchText: String, with outletId: String) {
        
        if  searchText.count >= 3 {
            guard let products = repository.filterItemList(contains: searchText, for: outletId) else {
                return
            }
            
            let productAdjusted: [ItemListModelView] = products.compactMap {
                guard let categoryName = repository.getCategoryName(category: $0.categoryId) else { return nil }
                
                return ItemListModelView(id: $0.id,
                                         product: $0.name,
                                         brand: $0.brand,
                                         weightPerPiece: $0.weightPerPiece,
                                         currentPrice: 0,
                                         categoryName: categoryName)
            }
            
            
            repository.getPricesFor(outletId: outletId, completion: { (prices) in
                let productsWithPrices = ItemListMappers
                    .merge(products: productAdjusted, with: prices)
                    .sorted { $0.currentPrice > $1.currentPrice  }
                
                self.onLoadedData(productsWithPrices)
                
            })
        }
    }
    
    
    
}
