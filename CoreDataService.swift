//
//  CoreDataService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/18/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataErrors: Error {
    case error(String)
}

class CoreDataService {

    static let data = CoreDataService()
    var synced = false

    func saveToShopList(_ shopItem: ShoplistItemEntity) {
        let shpLst = ShopList(context: context)
        shpLst.productId = shopItem.productId
        shpLst.quantity = shopItem.quantity
        ad.saveContext()
    }

    func removeFromShopList(with productId: String) {
        guard let product = self.getProductFromShopList(with: productId) else {
            fatalError()
        }
        context.delete(product)
        ad.saveContext()
    }
    
    private func getProductFromShopList(with productId: String) -> ShopList? {
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            shpLstRequest.predicate = NSPredicate(format: "productId == %@", productId)
            let productExist = try context.fetch(shpLstRequest)
            
            return productExist.first
            
        } catch {
            print("Products is not got from database")
        }
        
        return nil
    }

    func loadShopList() -> [ShoplistItemEntity]? {
        var shopList: [ShoplistItemEntity] = []
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            let savedShopList = try context.fetch(shpLstRequest)

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
            try context.execute(deleteRequest)
            try context.save()
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
        ad.saveContext()
    }
}
