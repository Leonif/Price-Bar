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
    func onFilterList(basedOn searchText: String, with outletId: String)
    func onAddNewItem(suggestedName: String)
}


class ItemListPresenterImpl: ItemListPresenter {
    
    weak var view: ItemListView!
    
    var itemListOutput: ItemListOutput!
    var repository: Repository!
    
    func onFetchData(offset: Int, limit: Int,  for outletId: String) {
        self.view.showLoading(with: "Получение списка товаров")
        self.repository.getShopItems(with: offset, limit: limit, for: outletId) { (result) in
            self.view.hideLoading()
            switch result {
            case let .success(products):
                self.getItemsWithPrices(for: products, outletId: outletId)
            case let .failure(error):
                self.view.onError(with: error.message)
            }
        }
    }
    
    
    func onFilterList(basedOn searchText: String, with outletId: String) {
        if  searchText.count >= 3 {
            repository.filterItemList(contains: searchText, for: outletId) { (result) in
                switch result {
                case let .success(products):
                    self.getItemsWithPrices(for: products, outletId: outletId)
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

// FIXME: move to Interactor/Use case
extension ItemListPresenterImpl {
    
    private func getItemsWithPrices(for products: [DPProductEntity], outletId: String) {
        
        guard !products.isEmpty else {
            self.view.onFetchedNewBatch(items: [])
            return
        }
        
        
        var productAdjusted: [ItemListViewEntity] = []
        let itemDispatchGroup = DispatchGroup()
        
        self.view.showLoading(with: R.string.localizable.common_get_product_info())
        
        for product in products {
            itemDispatchGroup.enter()
            self.getItemWithPrice(for: product.id, outletId: outletId, completion: { (itemListView) in
                productAdjusted.append(itemListView)
                itemDispatchGroup.leave()
            })
        }
        
        itemDispatchGroup.notify(queue: .main) {
            self.view.hideLoading()
            self.view.onFetchedNewBatch(items: productAdjusted)
        }
    }
    
    private func getItemWithPrice(for produtId: String, outletId: String, completion: @escaping (ItemListViewEntity) -> Void) {
        
        
        self.repository.getProductEntity(for: produtId) { (result) in
            switch result {
            case let .success(product):
                self.repository.getCategoryName(for: product.categoryId, completion: { (result) in
                    switch result {
                    case let .success(categoryName):

                        guard let categoryName = categoryName else {
                            self.view.onError(with: R.string.localizable.common_category_is_absent(product.name))
                            return
                        }
                        self.repository.getPrice(for: produtId, and: outletId, completion: { (price) in
                            let item = ItemListViewEntity(id: produtId,
                                                          product: product.name,
                                                          brand: product.brand,
                                                          weightPerPiece: product.weightPerPiece,
                                                          currentPrice: price, categoryName: categoryName)
                            completion(item)
                        })
                    case let .failure(error):
                        self.view.hideLoading()
                        self.view.onError(with: error.message)
                    }
                })
            case let .failure(error):
                self.view.hideLoading()
                self.view.onError(with: error.message)
            }
        }
    }
}


