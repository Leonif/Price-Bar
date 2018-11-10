//
//  ShoplistModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 8/23/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol ShopListModel {
    func clearShoplist()
    func getProductQuantity(productId: String) -> Double
    func remove(itemId: String)
    func changeShoplistItem( _ quantity: Double, for productId: String)
    func saveToShopList(new item: ShopListViewItem, completion: @escaping (ResultType<Bool, ProductModelError>) -> Void)
    func loadShopList(completion: ([ShoplistItemEntity]) -> Void)
}

class ShoplistModelImpl: ShopListModel {

    private var localStoreService: LocalStoreService!

    init(localStoreService: LocalStoreService) {
        self.localStoreService = localStoreService
    }

    func clearShoplist() {
        self.localStoreService.removeAll(from: "ShopList")
    }
    func getProductQuantity(productId: String) -> Double {
        return self.localStoreService.getQuantityOfProduct(productId: productId)
    }
    func remove(itemId: String) {
        self.localStoreService.removeFromShopList(with: itemId)
    }
    func changeShoplistItem( _ quantity: Double, for productId: String) {
        localStoreService.changeShoplistItem(quantity, for: productId)
    }

    func saveToShopList(new item: ShopListViewItem,
                        completion: @escaping (ResultType<Bool, ProductModelError>) -> Void) {
        guard let shoplist = self.localStoreService.loadShopList() else { fatalError() }

        if shoplist.contains(where: { $0.productId == item.productId }) {
            let errorMessage = R.string.localizable.common_already_in_list()
            let result: ResultType<Bool, ProductModelError> = ResultType
                .failure(ProductModelError
                    .alreadyAdded(errorMessage))
            completion(result)
            return
        }
        self.localStoreService.saveToShopList(ShoplistItemEntity(productId: item.productId, quantity: item.quantity))
        completion(ResultType.success(true))
    }

    func loadShopList(completion: ([ShoplistItemEntity]) -> Void) {
        guard let items = self.localStoreService.loadShopList() else {
            return
        }
        completion(items)
    }
}
