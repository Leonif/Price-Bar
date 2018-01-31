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

    var defaultCategory: CDCategoryModel? {
        let defaultCategoryId: Int32 = 1
        guard
            let category = getCategory(by: defaultCategoryId),
            let categoryName = category.category
            else {
                return nil
        }
        return CDCategoryModel(id: category.id, name: categoryName)
    }

    var defaultUom: CDUomModel? {
        let defaultUomId: Int32 = 1
        guard
            let uom = getUom(by: defaultUomId),
            let uomName = uom.uom else {
                return nil
        }

        let uomUterator = uom.iterator

        return CDUomModel(id: uom.id, name: uomName, iterator: uomUterator)
    }

    func save(new statistic: CDStatisticModel) {
        guard statistic.price != 0 else {
            return
        }
        do {
            let stat = Statistic(context: context)
            stat.outlet_id = statistic.outletId
            stat.price = statistic.price
            stat.date = Date() as NSDate

            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", statistic.productId)
            let productExist = try context.fetch(productRequest)

            let prd = productExist.first

            stat.toProduct = prd
            stat.price = statistic.price
            stat.outlet_id = statistic.outletId
            ad.saveContext()
        } catch {
            print("Products is not got from database")
        }
    }

    func saveToShopList(_ shopItem: DPShoplistItemModel) {
        do {
            //find product in catalog
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", shopItem.productId)
            let productExist = try context.fetch(productRequest)

            let shopProdRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            shopProdRequest.predicate = NSPredicate(format: "toProduct.id == %@", shopItem.productId)
            let shoppedProduct = try context.fetch(shopProdRequest)

            if shoppedProduct.isEmpty {
                let shpLst = ShopList(context: context)
                //shpLst.outlet_id = shopItem.outletId
                shpLst.quantity = shopItem.quantity
                shpLst.checked = shopItem.checked
                shpLst.toProduct = productExist.first

            } else {
                //change parametrs
                if let shpLst = shoppedProduct.first {
                    //shpLst.outlet_id = shopItem.outletId
                    shpLst.quantity = shopItem.quantity
                    shpLst.checked = shopItem.checked
                    shpLst.toProduct = productExist.first
                }
            }
            ad.saveContext()
        } catch {
           print("Products is not got from database")
        }

    }

    func removeFromShopList(with productId: String) {
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            shpLstRequest.predicate = NSPredicate(format: "toProduct.id == %@", productId)
            let productExist = try context.fetch(shpLstRequest)

            productExist.forEach { context.delete($0) }
            ad.saveContext()
        } catch {
            print("Products is not got from database")
        }
    }

    func loadShopList(for outletId: String?) -> [DPShoplistItemModel] {
        var shopList: [DPShoplistItemModel] = []

        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            let savedShopList = try context.fetch(shpLstRequest)

            savedShopList.forEach { shoplistItem in
                if let product = shoplistItem.toProduct,
                    let id = product.id,
                    let name = product.name,
                    let category = product.toCategory,
                    let categoryName = category.category,
                    let uom = product.toUom,
                    let uomName = uom.uom {

                    let quantity = shoplistItem.quantity
                    let checked = shoplistItem.checked

                    let price = outletId != nil ? getPrice(for: id, and: outletId!) : 0.0
                    let isPerPiece = uom.iterator.truncatingRemainder(dividingBy: 1) == 0

                    let item = DPShoplistItemModel(productId: id,
                                                 productName: name,
                                                 categoryId: category.id,
                                                 productCategory: categoryName,
                                                 productPrice: price,
                                                 uomId: uom.id,
                                                 productUom: uomName,
                                                 quantity: quantity,
                                                 isPerPiece: isPerPiece,
                                                 checked: checked)

                    shopList.append(item)
                }
            }
        } catch {
            print("Products is not got from database")
        }
        return shopList

    }
}

// MARK: Product
extension CoreDataService {
    func filterItemList(contains text: String, for outletId: String) -> [DPProductModel]? {
        var shopItems = [DPProductModel]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            let productList = try context.fetch(fetchRequest)
            for product in productList {
                let item = productMapper(from: product)
                shopItems.append(item)
            }
            return shopItems
        } catch {
            print("Products is not got from database")
        }
        return nil

    }

    func productMapper(from product: Product) -> DPProductModel {
        guard let id = product.id,
            let name = product.name,
            let category = product.toCategory,
            let uom = product.toUom else {
                fatalError("Product is not parsed")
        }

        let isPerPiece = uom.iterator.truncatingRemainder(dividingBy: 1) == 0

        return DPProductModel(id: id,
                            name: name,
                            categoryId: category.id,
                            uomId: uom.id,
                            isPerPiece: isPerPiece)

    }

    func getProductList(for outletId: String, offset: Int) -> [DPProductModel]? {
        var shopItems = [DPProductModel]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.fetchLimit = 20
            fetchRequest.fetchOffset = offset
            let productList = try context.fetch(fetchRequest)

            for product in productList {
                let item = productMapper(from: product)
                shopItems.append(item)

            }
            return shopItems
        } catch {
            print("Products is not got from database")
        }
        return nil
    }

    func getItemList(for outletId: String) -> [DPProductModel]? {
        var shopItems = [DPProductModel]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            let productExist = try context.fetch(fetchRequest)
            if !productExist.isEmpty {
                productExist.forEach { product in
                    let item = productMapper(from: product)
                    shopItems.append(item)

                }
                return shopItems
            }
        } catch {
            print("Products is not got from database")
        }
        return nil
    }

    func getItem(by barcode: String, and outletId: String) -> CDProductModel? {
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.predicate = NSPredicate(format: "id == %@", barcode)
            let productList = try context.fetch(fetchRequest)
            if !productList.isEmpty {
                if let prd = productList.first {
                    if let id = prd.id, let name = prd.name,
                        let prodUom = prd.toUom,
                        let prodCat = prd.toCategory {

                        let item = CDProductModel(id: id,
                                                  name: name,
                                                  categoryId: prodCat.id,
                                                  uomId: prodUom.id)
                        return item
                    }
                }
            }
        } catch {
            print("Products is not got from database")
            return nil
        }
        return nil
    }

    func save(_ item: CDProductModel) {
        let product = Product(context: context)
        product.id = item.id
        product.name = item.name
        let uom = getUom(by: item.uomId)
        product.toUom = uom
        let category = getCategory(by: item.categoryId)
        product.toCategory = category

        ad.saveContext()
    }

    func update(_ item: CDProductModel) {

        guard let product = getProduct(by: item.id) else {
            fatalError("Product is not found!!!")
        }
        product.name = item.name

        let category = getCategory(by: item.categoryId)
        product.toCategory = category

        let uom = getUom(by: item.uomId)
        product.toUom = uom

        ad.saveContext()
    }

}

// MARK: Categories
extension CoreDataService {
    func getCategories() -> [CDCategoryModel]? {
        //var categories: [Category] = []
        var categoryList: [CDCategoryModel] = []
        do {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            let categories = try context.fetch(fetchRequest)

            guard !categories.isEmpty else {
                return nil
            }
            for category in categories {
                if let categoryName = category.category {
                    categoryList.append(CDCategoryModel(id: category.id,
                                                      name: categoryName))
                } else {
                    fatalError("No name of category !!!!")
                }
            }
        } catch {
            print("Categories are not got from database")
        }
        return categoryList
    }

    func save(new category: CDCategoryModel) {
        if let cat = getCategory(by: category.id) {
            cat.category = category.name
        } else {
            let cat = Category(context: context)
            cat.id = category.id
            cat.category = category.name
        }
        ad.saveContext()
    }

    func save(new uom: CDUomModel) {

        let u = Uom(context: context)
        u.id = uom.id
        u.uom = uom.name
        u.iterator = uom.iterator

        ad.saveContext()
    }

    func save(new product: CDProductModel) {
        let prod = Product(context: context)
        prod.id = product.id
        prod.name = product.name
        guard
            let category = getCategory(by: product.categoryId) else {
            fatalError("Category is not found")
        }
        prod.toCategory = category

        guard
            let uom = getUom(by: product.uomId) else {
            fatalError("Uom is not found")
        }
        prod.toUom = uom

        ad.saveContext()
    }

    func getCategory(by id: Int32) -> Category? {
        do {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            let categories = try context.fetch(fetchRequest)

            guard !categories.isEmpty, let category = categories.first else {
                return nil
            }
            return category
        } catch {
            fatalError("category is not got from database")
        }

        return nil
    }

    func getUom(by id: Int32) -> Uom? {
        do {
            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            let uoms = try context.fetch(fetchRequest)

            guard !uoms.isEmpty, let uom = uoms.first else {
                return nil
            }
            return uom
        } catch {
            fatalError("uom is not got from database")
        }
        return nil
    }

    func getUomList() -> [Uom]? {
        do {
            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
            let uoms = try context.fetch(fetchRequest)

            guard !uoms.isEmpty else {
                return nil
            }
            return uoms
        } catch {
            fatalError("uom is not got from database")
        }
        return nil
    }

    func getUomName(by id: Int32) -> String? {
        do {
            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            let uoms = try context.fetch(fetchRequest)

            guard !uoms.isEmpty, let uom = uoms.first else {
                return nil
            }
            return uom.uom
        } catch {
            fatalError("uom is not got from database")
        }
        return nil
    }

    func getProduct(by id: String) -> Product? {
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let products = try context.fetch(fetchRequest)

            guard !products.isEmpty, let product = products.first else {
                return nil
            }
            return product
        } catch {
            fatalError("uom is not got from database")
        }
        return nil
    }

    func changeShoplistItem(_ quantity: Double, for productId: String) {

        guard let item = getShopItemInShopList(by: productId) else {
            fatalError("item is not found in shoplist")
        }
        item.quantity = quantity

        ad.saveContext()
    }

    func getShopItemInShopList(by productId: String) -> ShopList? {

        do {
            let shopProdRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            shopProdRequest.predicate = NSPredicate(format: "toProduct.id == %@", productId)
            let shoppedProduct = try context.fetch(shopProdRequest)
            guard !shoppedProduct.isEmpty, let item = shoppedProduct.first else {
                return nil
            }
            return item
        } catch {
            fatalError("shopitem is not found")
        }
        return nil

    }

}

//extension CoreDataService {
//    
//    func categoryPrint() {
//        do {
//            // search category in coredata
//            let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
//            let categories = try context.fetch(categoryRequest)
//            
//            if categories.count == self.initCategories.count {
//            
//                print("TEST: \(categories.count) vs dyn array: \(self.initCategories.count)")
//                
//            } else {
//                print("TEST ATTENTION!!!: \(categories.count) vs dyn array: \(self.initCategories.count)")
//                for cat in categories {
//                    print("TEST: \(cat.id):\(cat.category ?? "")")
//                }
//            }
//            
//        } catch {
//            print("Error of category data")
//        }
//    }
//    
//    
//    
//}
