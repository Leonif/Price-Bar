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
    func onFetchData(offset: Int, limit: Int, for outletId: String)
    func onFilterList(basedOn searchText: String, with outletId: String)
    func onAddNewItem(suggestedName: String)
}

class ItemListPresenterImpl: ItemListPresenter {

    weak var view: ItemListView!
    var filtering = false

    var itemListOutput: ItemListOutput!
    var productModel: ProductModelImpl!

    func onFetchData(offset: Int, limit: Int, for outletId: String) {
        self.view.showLoading(with: "Получение списка товаров")
        self.productModel.getProductList(with: offset, limit: limit, for: outletId) { [weak self] (result) in
            self?.view.hideLoading()
            guard let `self` = self else { return }
            switch result {
            case let .success(products):
                self.view.showLoading(with: R.string.localizable.getting_actual_price())
                self.getItemsWithPrices(for: products, outletId: outletId, completion: { [weak self] (itemsWithPrices) in
                    self?.view.hideLoading()
                    guard let `self` = self else { return }

                    self.view.onFetchedNewBatch(items: itemsWithPrices)
                })
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }

    func onFilterList(basedOn searchText: String, with outletId: String) {
        if  searchText.count >= 3 && !filtering {
            filtering = true
            self.view.showLoading(with: R.string.localizable.common_get_product_info())
            self.productModel.filterItemList(contains: searchText, for: outletId) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case let .success(products):
                    self.getItemsWithPrices(for: products, outletId: outletId, completion: { [weak self] (itemsWithPrices) in
                        self?.view.hideLoading()

                        guard let `self` = self else { return }

                        self.view.onFiltredItems(items: itemsWithPrices)
                        self.filtering.toggle()
                    })
                case let .failure(error):
                    self.view.onError(with: error.errorDescription)
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
    private func getItemsWithPrices(for products: [ProductEntity], outletId: String, completion: @escaping ([ItemListViewEntity]) -> Void) {
        guard !products.isEmpty else {
            completion([])
            return
        }

        var productAdjusted: [ItemListViewEntity] = []
        let itemDispatchGroup = DispatchGroup()

        for product in products {
            itemDispatchGroup.enter()
            self.getItemWithPrice(for: product.productId, outletId: outletId, completion: { (itemListView) in
                productAdjusted.append(itemListView)
                itemDispatchGroup.leave()
            })
        }

        itemDispatchGroup.notify(queue: .main) {
            completion(productAdjusted)
        }
    }

    private func getItemWithPrice(for produtId: String, outletId: String, completion: @escaping (ItemListViewEntity) -> Void) {

        self.productModel.getProductEntity(for: produtId) { [weak self] (result) in

            guard let `self` = self else { return }
            switch result {
            case let .success(product):
                self.productModel.getCategoryName(for: product.categoryId!, completion: { [weak self] (result) in
                    guard let `self` = self else { return }
                    switch result {
                    case let .success(categoryName):
                        self.productModel.getPrice(for: produtId, and: outletId, completion: { (price) in
                            let item = ItemListViewEntity(id: produtId,
                                                          product: product.name,
                                                          brand: product.brand!,
                                                          weightPerPiece: product.weightPerPiece!,
                                                          currentPrice: price, categoryName: categoryName)
                            completion(item)
                        })
                    case let .failure(error):
                        self.view.hideLoading()
                        self.view.onError(with: error.errorDescription)
                    }
                })
            case let .failure(error):
                self.view.hideLoading()
                self.view.onError(with: error.errorDescription)
            }
        }
    }
}
