//
//  LocalStoreService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 10/13/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreData

protocol LocalStoreService {
    func saveToShopList(_ shopItem: ShoplistItemEntity)
    func removeFromShopList(with productId: String)
    func loadShopList() -> [ShoplistItemEntity]?
    func removeAll(from entity: String)
    func getQuantityOfProduct(productId: String) -> Double
    func changeShoplistItem(_ quantity: Double, for productId: String)
}

class CoreDataServiceImpl: LocalStoreService {

    private let stack = CoreDataStack(modelName: "PriceBar")
    private let shopListEntity = "ShopList"

    func saveToShopList(_ shopItem: ShoplistItemEntity) {
        let shpLst = ShopList(context: stack.managedContext)
        shpLst.productId = shopItem.productId
        shpLst.quantity = shopItem.quantity
        stack.saveContext()
    }

    func removeFromShopList(with productId: String) {
        guard let product = self.getProductFromShopList(with: productId) else {
            fatalError()
        }
        stack.managedContext.delete(product)
        stack.saveContext()
    }

    private func getProductFromShopList(with productId: String) -> ShopList? {
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: shopListEntity)
            shpLstRequest.predicate = NSPredicate(format: "productId == %@", productId)
            let productExist = try stack.managedContext.fetch(shpLstRequest)

            return productExist.first

        } catch {
            print("Products is not got from database")
        }
        return nil
    }

    func loadShopList() -> [ShoplistItemEntity]? {
        var shopList: [ShoplistItemEntity] = []
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: shopListEntity)
            let savedShopList = try stack.managedContext.fetch(shpLstRequest)

            shopList = savedShopList.map { shoplistItem in

                guard let id = shoplistItem.productId else {
                    fatalError()
                }

                return ShoplistItemEntity(productId: id, quantity: shoplistItem.quantity)
            }
        } catch {
            print("Products is not got from database")
            return nil
        }
        return shopList
    }

    func removeAll(from entity: String) {
        let requestCategories = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: requestCategories)

        do {
            try stack.managedContext.execute(deleteRequest)
            stack.saveContext()
        } catch {
            fatalError("\(entity) removing error")
        }
    }

    func getQuantityOfProduct(productId: String) -> Double {
        guard let product = self.getProductFromShopList(with: productId) else {
            fatalError()
        }

        return product.quantity
    }

    func changeShoplistItem(_ quantity: Double, for productId: String) {
        guard let item = self.getProductFromShopList(with: productId) else {
            fatalError("item is not found in shoplist")
        }
        item.quantity = quantity
        stack.saveContext()
    }
}
