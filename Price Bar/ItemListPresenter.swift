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
                self.mergePricesWithProducts(products, outletId: outletId)
            case let .failure(error):
                self.view.onError(with: error.message)
            }
        }
    }
    
    
    
    
    
    
    private func mergePricesWithProducts(_ products: [DPProductEntity], outletId: String) {
        var productAdjusted: [ItemListViewEntity] = []
        
        let categoryDispatchGruop = DispatchGroup()
        
        for item in products {
            categoryDispatchGruop.enter()
            repository.getCategoryName(for: item.categoryId, completion: { (result) in
                switch result {
                case let .success(categoryName):
                    
                    guard let categoryName = categoryName else {
                        self.view.onError(with: R.string.localizable.error_something_went_wrong())
                        return
                    }
                    
                    productAdjusted.append(ItemListViewEntity(id: item.id,
                                                              product: item.name,
                                                              brand: item.brand,
                                                              weightPerPiece: item.weightPerPiece,
                                                              currentPrice: 0,
                                                              categoryName: categoryName))
                    categoryDispatchGruop.leave()
                case let .failure(error):
                    self.view.onError(with: error.message)
                    categoryDispatchGruop.leave()
                }
            })
        }
        
        
        categoryDispatchGruop.notify(queue: .main) {
            self.repository.getPricesFor(outletId: outletId, completion: { (prices) in
                let productsWithPrices = ItemListMappers
                    .merge(products: productAdjusted, with: prices)
                    .sorted { $0.currentPrice > $1.currentPrice  }
                
                self.view.onFetchedData(items: productsWithPrices)
            })
        }
    }
    
    
    func onFilterList(basedOn searchText: String, with outletId: String) {
        
        if  searchText.count >= 3 {
//            guard let products = repository.//filterItemList(contains: searchText, for: outletId) else {
//                return
//            }
            
            repository.filterItemList(contains: searchText, for: outletId) { (result) in
                switch result {
                case let .success(products):
                    let productAdjusted: [ItemListViewEntity] = products.compactMap {
                        //guard let categoryName = repository.getCategoryName(category: $0.categoryId) else { return nil }
                        
                        
                        
                        
                        
                        
                        return ItemListViewEntity(id: $0.id,
                                                  product: $0.name,
                                                  brand: $0.brand,
                                                  weightPerPiece: $0.weightPerPiece,
                                                  currentPrice: 0,
                                                  categoryName: categoryName)
                    }
                    
                    
                    self.repository.getPricesFor(outletId: outletId, completion: { (prices) in
                        let productsWithPrices = ItemListMappers
                            .merge(products: productAdjusted, with: prices)
                            .sorted { $0.currentPrice > $1.currentPrice  }
                        
                        self.view.onFetchedData(items: productsWithPrices)
                        
                    })
                case let .failure(error):
                    self.view.onError(with: error.message)
                }
            }
            
            
        }
    }
    
    func onAddNewItem(suggestedName: String) {
        self.itemListOutput.addNewItem(suggestedName: suggestedName)
    }
    
    
    func onItemChoosen(productId: String) {
        self.itemListOutput.itemChoosen(productId: productId)
    }
    
    
}

// FIXME: move to interactor
extension ItemListPresenterImpl {
    
    private func onGetItemWithPrice(for produtId: String, outletId: String, completion: @escaping (ItemListViewEntity) -> Void) {
        
        self.repository.getProductEntity(for: produtId) { (result) in
            switch result {
            case let .success(product):
                self.repository.getCategoryName(for: product.categoryId, completion: { (result) in
                    switch result {
                    case let .success(categoryName):
                        
                        guard let categoryName = categoryName else {
                            self.view.onError(with: R.string.localizable.error_something_went_wrong())
                            return
                        }
                        let item = ItemListViewEntity(id: produtId,
                                                      product: product.name,
                                                      brand: product.brand,
                                                      weightPerPiece: product.weightPerPiece,
                                                      currentPrice: 0.0, categoryName: categoryName)
                        completion(item)
                    case let .failure(error):
                        self.view.onError(with: error.message)
                    }
                })
                
            case let .failure(error):
                self.view.onError(with: error.message)
                
                
            }
        }
        
        
        
        
        
        
    }
    
}


