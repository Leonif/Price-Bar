//
//  ItemListPresenter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


protocol ItemListOutput {
    func itemChoosen(productId: String)
    func addNewItem(suggestedName: String)
}

protocol ItemListPresenter {
    func onItemChoosen(productId: String)
    func onFetchData(offset: Int, limit: Int,  for outletId: String)
//    func onFetchNextBatch(offset: Int, limit: Int,  for outletId: String)
    func onFilterList(basedOn searchText: String, with outletId: String)
    func onAddNewItem(suggestedName: String)
}


class ItemListPresenterImpl: ItemListPresenter {
    
    weak var view: ItemListView!
    
    var itemListOutput: ItemListOutput!
    var repository: Repository!
    
    
    func onFetchData(offset: Int, limit: Int,  for outletId: String) {
        self.repository.getShopItems(with: offset, limit: limit, for: outletId) { (result) in
            switch result {
            case let .success(products):
                self.mergePricesWith(products: products, outletId: outletId)
            case let .failure(error):
                self.view.onError(with: error.message)
            }
        }
    }
    
    
    private func mergePricesWith(products: [DPProductEntity], outletId: String) {
        
        let productAdjusted: [ItemListViewEntity] = products.compactMap {
            guard let categoryName = repository.getCategoryName(category: $0.categoryId) else { return nil }
            
            return ItemListViewEntity(id: $0.id,
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
            
            self.view.onFetchedData(items: productsWithPrices)
        })
        
        
    }
    
    
    // USE onFetchDATA
//    func onFetchNextBatch(offset: Int, limit: Int,  for outletId: String) {
//        guard
//            let products = repository.getShopItems(with: offset, limit: limit, for: outletId) else {
//                return
//        }
//
//
//        let productAdjusted: [ItemListViewEntity] = products.compactMap {
//            guard let categoryName = repository.getCategoryName(category: $0.categoryId) else { return nil }
//
//            return ItemListViewEntity(id: $0.id,
//                                     product: $0.name,
//                                     brand: $0.brand,
//                                     weightPerPiece: $0.weightPerPiece,
//                                     currentPrice: 0,
//                                     categoryName: categoryName)
//        }
//
//
//        repository.getPricesFor(outletId: outletId, completion: { (prices) in
//            let productsWithPrices = ItemListMappers
//                .merge(products: productAdjusted, with: prices)
//                .sorted { $0.currentPrice > $1.currentPrice  }
//
//            self.view.onFetchedNewBatch(items: productsWithPrices)
//        })
//
//    }
    
    
    func onFilterList(basedOn searchText: String, with outletId: String) {
        
        if  searchText.count >= 3 {
            guard let products = repository.filterItemList(contains: searchText, for: outletId) else {
                return
            }
            
            let productAdjusted: [ItemListViewEntity] = products.compactMap {
                guard let categoryName = repository.getCategoryName(category: $0.categoryId) else { return nil }
                
                return ItemListViewEntity(id: $0.id,
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

                self.view.onFetchedData(items: productsWithPrices)
                
            })
        }
    }
    
    func onAddNewItem(suggestedName: String) {
        self.itemListOutput.addNewItem(suggestedName: suggestedName)
    }
    
    
    func onItemChoosen(productId: String) {
        self.itemListOutput.itemChoosen(productId: productId)
    }
    
    
}
