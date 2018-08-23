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
        
        
//        do {
//            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
//            shpLstRequest.predicate = NSPredicate(format: "productId == %@", productId)
//            let productExist = try context.fetch(shpLstRequest)
//
//            productExist.forEach { context.delete($0) }
//            ad.saveContext()
//        } catch {
//            print("Products is not got from database")
//        }
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
    
    
}

// MARK: Product
extension CoreDataService {
//    func filterItemList(contains text: String, for outletId: String) -> [DPProductEntity]? {
//        var shopItems = [DPProductEntity]()
//        do {
//            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
//
//            let condition = "name CONTAINS[cd] %@ OR brand CONTAINS[cd] %@ OR weightPerPiece CONTAINS[cd] %@"
//            fetchRequest.predicate = NSPredicate(format: condition, text, text, text)
//            let productList = try context.fetch(fetchRequest)
//
//            shopItems = productList.compactMap { productMapper(from: $0) }
//            return shopItems
//        } catch {
//            print("Products is not got from database")
//        }
//        return nil
//
//    }
//
//    func productMapper(from product: Product) -> DPProductEntity? {
//        guard let id = product.id,
//            let name = product.name,
//            let category = product.toCategory,
//            let uom = product.toUom
//            else {
//                return nil
//        }
//
//        let brand = product.brand ?? ""
//        let weightPerPiece = product.weightPerPiece ?? ""
//
//        return DPProductEntity(id: id,
//                              name: name,
//                              brand: brand,
//                              weightPerPiece: weightPerPiece,
//                              categoryId: category.id,
//                              uomId: uom.id)
//
//    }

//    func getProductList(for outletId: String, offset: Int, limit: Int) -> [DPProductEntity]? {
//        var shopItems = [DPProductEntity]()
//        do {
//            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
//            fetchRequest.fetchLimit = limit
//            fetchRequest.fetchOffset = offset
//            let productList = try context.fetch(fetchRequest)
//            shopItems = productList.compactMap { self.productMapper(from: $0) }
//
//            return shopItems.isEmpty ? nil : shopItems
//        } catch {
//            print("Products is not got from database")
//        }
//        return nil
//    }
//    func getItemList(for outletId: String) -> [DPProductEntity]? {
//        var shopItems = [DPProductEntity]()
//        do {
//            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
//            let productExist = try context.fetch(fetchRequest)
//            if !productExist.isEmpty {
//                shopItems = productExist.compactMap { productMapper(from: $0) }
//                return shopItems
//            }
//        } catch {
//            print("Products is not got from database")
//        }
//        return nil
//    }

//    func getItem(by barcode: String, and outletId: String) -> CDProductModel? {
//        do {
//            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
//            fetchRequest.predicate = NSPredicate(format: "id == %@", barcode)
//            let productList = try context.fetch(fetchRequest)
//            if !productList.isEmpty {
//                if let prd = productList.first {
//                    if let id = prd.id,
//                        let name = prd.name,
//                        let prodUom = prd.toUom,
//                        let prodCat = prd.toCategory {
//
//                        let brand = prd.brand ?? ""
//                        let weightPerPiece = prd.weightPerPiece ?? ""
//
//                        let item = CDProductModel(id: id,
//                                                  name: name,
//                                                  brand: brand,
//                                                  weightPerPiece: weightPerPiece,
//                                                  categoryId: prodCat.id,
//                                                  uomId: prodUom.id)
//                        return item
//                    }
//                }
//            }
//        } catch {
//            print("Products is not got from database")
//            return nil
//        }
//        return nil
//    }
    
//    func getProductName(for productId: String) -> String? {
//        do {
//            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
//            fetchRequest.predicate = NSPredicate(format: "id == %@", productId)
//            let productList = try context.fetch(fetchRequest)
//            guard  !productList.isEmpty else  { return nil }
//            guard let prd = productList.first, let name = prd.name  else { return nil }
//            
//            return name
//        } catch {
//            print("Products is not got from database")
//            return nil
//        }
//    }
    

//    func save(_ item: CDProductModel) {
//        let product = Product(context: context)
//        product.id = item.id
//        product.name = item.name
//        product.brand = item.brand
//        product.weightPerPiece = item.weightPerPiece
//
//        let uom = getUom(by: item.uomId)
//        product.toUom = uom
//        let category = getCategory(by: item.categoryId)
//        product.toCategory = category
//
//        ad.saveContext()
//    }

//    func update(_ item: CDProductModel) {
//
//        guard let product = getProduct(by: item.id) else {
//            fatalError("Product is not found!!!")
//        }
//        product.name = item.name
//        product.brand = item.brand
//        product.weightPerPiece = item.weightPerPiece
//
//        let category = getCategory(by: item.categoryId)
//        product.toCategory = category
//
//        let uom = getUom(by: item.uomId)
//        product.toUom = uom
//
//        ad.saveContext()
//    }

}

// MARK: Categories
extension CoreDataService {
//    func getCategories() -> [CDCategoryModel]? {
//        var categoryList: [CDCategoryModel] = []
//        do {
//            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
//            let categories = try context.fetch(fetchRequest)
//
//            guard !categories.isEmpty else {
//                return nil
//            }
//            for category in categories {
//                if let categoryName = category.category {
//                    categoryList.append(CDCategoryModel(id: category.id,
//                                                      name: categoryName))
//                } else {
//                    fatalError("No name of category !!!!")
//                }
//            }
//        } catch {
//            print("Categories are not got from database")
//        }
//        return categoryList
//    }

//    func save(new category: CDCategoryModel) {
//        if let cat = getCategory(by: category.id) {
//            cat.category = category.name
//        } else {
//            let cat = Category(context: context)
//            cat.id = category.id
//            cat.category = category.name
//        }
//        ad.saveContext()
//    }

//    func save(new uom: CDUomModel) {
//
//        let u = Uom(context: context)
//        u.id = uom.id
//        u.uom = uom.name
//        u.parameters = UomMapper.transform(from: uom.parameters)
//
//        ad.saveContext()
//    }

//    func save(new product: CDProductModel) {
//        let prod = Product(context: context)
//        prod.id = product.id
//        prod.name = product.name
//        prod.brand = product.brand
//        prod.weightPerPiece = product.weightPerPiece
//        guard
//            let category = getCategory(by: product.categoryId) else {
//            fatalError("Category is not found")
//        }
//        prod.toCategory = category
//
//        guard
//            let uom = getUom(by: product.uomId) else {
//            fatalError("Uom is not found")
//        }
//        prod.toUom = uom
//
//        ad.saveContext()
//    }

//    func getCategory(by id: Int32) -> Category? {
//        do {
//            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
//            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
//            let categories = try context.fetch(fetchRequest)
//
//            guard !categories.isEmpty, let category = categories.first else {
//                return nil
//            }
//            return category
//        } catch {
//            fatalError("category is not got from database")
//        }
//
//        return nil
//    }
//
//    func getUom(by id: Int32) -> Uom? {
//        do {
//            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
//            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
//            let uoms = try context.fetch(fetchRequest)
//
//            guard !uoms.isEmpty, let uom = uoms.first else {
//                return nil
//            }
//            return uom
//        } catch {
//            fatalError("uom is not got from database")
//        }
//        return nil
//    }

//    func getUomList() -> [Uom]? {
//        do {
//            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
//            let uoms = try context.fetch(fetchRequest)
//
//            guard !uoms.isEmpty else {
//                return nil
//            }
//            return uoms
//        } catch {
//            fatalError("uom is not got from database")
//        }
//        return nil
//    }


//    func getProduct(by id: String) -> Product? {
//        do {
//            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
//            let products = try context.fetch(fetchRequest)
//
//            guard !products.isEmpty, let product = products.first else {
//                return nil
//            }
//            return product
//        } catch {
//            fatalError("uom is not got from database")
//        }
//        return nil
//    }

    func changeShoplistItem(_ quantity: Double, for productId: String) {
        guard let item = self.getProductFromShopList(with: productId) else {
            fatalError("item is not found in shoplist")
        }
        item.quantity = quantity

        ad.saveContext()
    }

//    func getShopItemInShopList(by productId: String) -> ShopList? {
//
//        do {
//            let shopProdRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
//            shopProdRequest.predicate = NSPredicate(format: "productId == %@", productId)
//            let shoppedProduct = try context.fetch(shopProdRequest)
//            guard !shoppedProduct.isEmpty, let item = shoppedProduct.first else {
//                return nil
//            }
//            return item
//        } catch {
//            fatalError("shopitem is not found")
//        }
//        return nil
//    }
}

