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
    var initCategories = [ItemCategory]()
    var initUoms = [ItemUom]()
    var synced = false
    
    
    var defaultCategory: ItemCategory? {
        
        guard let cat = self.getCategoriesFromCoreData().first else {
            return nil
        }
        
        return cat
    }
    
    

    
    
    func getUomsFromCoreData() -> [ItemUom] {
        var uoms = [Uom]()
        do {
            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
            uoms = try context.fetch(fetchRequest)
            if uoms.count != self.initUoms.count {
                uoms = []
                for u in self.initUoms { // пересоздаем категории заново
                    let uom = Uom(context: context)
                    uom.id = u.id
                    uom.uom = u.name
                    uom.iterator = u.iterator
                }
                ad.saveContext()
                uoms = try context.fetch(fetchRequest)
            }
            
        } catch  {
            print("Uoms are not got from database")
        }
        
        var itemUoms = [ItemUom]()
        
        uoms.forEach {
            if let uomName = $0.uom {
                let itemUom = ItemUom(id: $0.id, name: uomName, iterator: $0.iterator)
                itemUoms.append(itemUom)
            }
        }
        return itemUoms
    }
    
    func addToShopListAndSaveStatistics(_ item: ShopItem) {
        saveOrUpdate(item)
        print("From CoreData: addToShopListAndSaveStatistics - addToShopList")
        saveToShopList(item)
    }
    
    func save(new statistic: ItemStatistic) {
        guard statistic.price != 0 else {
            return
        }
        do {
            let stat = Statistic(context: context)
            stat.outlet_id = statistic.outletId
            stat.price = statistic.price
            stat.date = statistic.date as NSDate
            
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", statistic.productId)
            let productExist = try context.fetch(productRequest)
            
            let prd = productExist.first
            
            stat.toProduct = prd
            stat.price = statistic.price
            stat.outlet_id = statistic.outletId
            ad.saveContext()
        } catch  {
            print("Products is not got from database")
        }
    }
    
    
    
    func saveToShopList(_ item:ShopItem) {
        do {
            //find product in catalog
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", item.id)
            let productExist = try context.fetch(productRequest)
            //check has shoplist it?
            let shopProdRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            shopProdRequest.predicate = NSPredicate(format: "toProduct.id == %@", item.id)
            let shoppedProduct = try context.fetch(shopProdRequest)
            if shoppedProduct.isEmpty {
                let shpLst = ShopList(context: context)
                shpLst.outlet_id = item.outletId
                shpLst.quantity = item.quantity
                shpLst.checked = item.checked
                shpLst.toProduct = productExist.first
                
            } else {
                //change parametrs
                if let shpLst = shoppedProduct.first  {
                    shpLst.outlet_id = item.outletId
                    shpLst.quantity = item.quantity
                    shpLst.checked = item.checked
                    shpLst.toProduct = productExist.first
                }
            }
            ad.saveContext()
        } catch {
           print("Products is not got from database")
        }
        
        
    }
    
    func removeFromShopList(_ item: ShopItem) {
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            shpLstRequest.predicate = NSPredicate(format: "toProduct.id == %@", item.id)
            let productExist = try context.fetch(shpLstRequest)
            
            productExist.forEach { context.delete($0) }
            ad.saveContext()
        } catch {
            print("Products is not got from database")
        }
    }
    
    func removeAllItems() {
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            //shpLstRequest.predicate = NSPredicate(format: "toProduct.id == %@", item.id)
            let productExist = try context.fetch(shpLstRequest)
            
            productExist.forEach { context.delete($0) }
            ad.saveContext()
        } catch {
            print("Products is not got from database")
        }
        
        
    }
    
    func loadShopList(outletId: String) -> DataProvider?{
        let shopListService = DataProvider()
        
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            let shopList = try context.fetch(shpLstRequest)
            
            shopList.forEach { shoplistItem in
                if let shopListItem = shoplistItem.toProduct,
                    let id = shopListItem.id,
                    let name = shopListItem.name,
                    let prodUom = shopListItem.toUom,
                    let uomName = prodUom.uom,
                    let prodCat = shopListItem.toCategory,
                    let category = prodCat.category {
                
                    let price = getPrice(for: id, and: outletId)
                    let minPrice = getMinPrice(for: id, and: outletId)
                    
                    let itemUom = ItemUom(id: prodUom.id, name: uomName, iterator: prodUom.iterator)
                    
                    let itemCategory = ItemCategory(id: prodCat.id, name: category)
                    
                    let item = ShopItem(id: id, name: name, quantity: shoplistItem.quantity, minPrice: minPrice, price: price, itemCategory: itemCategory, itemUom: itemUom, outletId: outletId, scanned: shopListItem.scanned, checked: shoplistItem.checked)
                    
                    shopListService.append(item)
                }
            }
            return shopListService
        } catch {
            print("Products is not got from database")
        }
        return nil
        
    }
}


//MARK: Product
extension CoreDataService {
    func shopItem(parse product: Product, and outletId: String) -> ShopItem? {
        guard
            let id = product.id,
            let name = product.name,
            let category = product.toCategory?.category,
            let idCat = product.toCategory?.id, // optional chaining
            let prodUom = product.toUom,
            let uom = prodUom.uom  else {
                return nil
                
        }
        let price = getPrice(for: id, and: outletId)
        let minPrice = getMinPrice(for: id, and: outletId)
        
        let itemCategory = ItemCategory(id: idCat, name: category)
        let itemUom = ItemUom(id: prodUom.id, name: uom, iterator: prodUom.iterator)
        
        let item = ShopItem(id: id, name: name,
                            quantity: 1.0,
                            minPrice: minPrice,
                            price: price,
                            itemCategory: itemCategory,
                            itemUom: itemUom, outletId: outletId,
                            scanned: true,
                            checked: false)
        return item
    }
    
    func filterItemList(contains text: String, for outletId: String) -> [ShopItem]? {
        var shopItems = [ShopItem]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            let productList = try context.fetch(fetchRequest)
            for product in productList {
                if let item = shopItem(parse: product, and: outletId) {
                    shopItems.append(item)
                }
            }
            return shopItems
        } catch  {
            print("Products is not got from database")
        }
        return nil

    }
    
    
    func getShortItemList(for outletId: String, offset: Int) -> [ShopItem]? {
        var shopItems = [ShopItem]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.fetchLimit = 20
            fetchRequest.fetchOffset = offset
            let productList = try context.fetch(fetchRequest)
            
            
            for product in productList {
                if let item = shopItem(parse: product, and: outletId) {
                    shopItems.append(item)
                }
            }
            return shopItems
        } catch  {
            print("Products is not got from database")
        }
        return nil
    }


    func getItemList(for outletId: String) -> [ShopItem]? {
        var shopItems = [ShopItem]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            let productExist = try context.fetch(fetchRequest)
            if !productExist.isEmpty {
                productExist.forEach {
                    if let item = shopItem(parse: $0, and: outletId) {
                        shopItems.append(item)
                    }
                }
                return shopItems
            }
        } catch  {
            print("Products is not got from database")
        }
        return nil
    }
    
    
    
    func getItem(by barcode: String, and outletId: String) -> ShopItem? {
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.predicate = NSPredicate(format: "id == %@", barcode)
            let productExist = try context.fetch(fetchRequest)
            if !productExist.isEmpty {
                if let prd = productExist.first {
                    if let id = prd.id, let name = prd.name,
                        let prodUom = prd.toUom, let uomName = prodUom.uom,
                        let prodCat = prd.toCategory, let category = prodCat.category  {
                        
                        let price = getPrice(for: barcode, and: outletId)
                        let minPrice = getMinPrice(for: barcode, and: outletId)
                        
                        let itemCategory = ItemCategory(id: prodCat.id, name: category)
                        let itemUom = ItemUom(id: prodUom.id, name: uomName, iterator: prodUom.iterator)
                        
                        let item = ShopItem(id: id, name: name, quantity: 1.0, minPrice: minPrice, price: price, itemCategory: itemCategory, itemUom: itemUom, outletId: outletId, scanned: true, checked: false)
                        return item
                    }
                }
            }
        } catch  {
            print("Products is not got from database")
            return nil
        }
        return nil
    }

    func saveOrUpdate(_ item: ShopItem) {
        if update(item) {
            return
        } else {
            save(item)
        }
    }
    
    func save(_ item: ShopItem) {
        let product = Product(context: context)
        product.id = item.id
        product.name = item.name
        product.toUom = setUom(for: item)
        product.toCategory = setCategory(for: item)
        
        product.scanned = item.scanned
        ad.saveContext()
    }
    
    
    
    
    
    func update(_ item: ShopItem) -> Bool {
        do {
            // search item in coredata
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", item.id)
            let productExist = try context.fetch(productRequest)
            if !productExist.isEmpty {
                if let product = productExist.first {
                    product.name = item.name
                    product.toUom = setUom(for: item)
                    product.toCategory = setCategory(for: item)
                    product.scanned = item.scanned
                    ad.saveContext()
                    return true
                }
            }
        } catch  {
            print("Products is not got from database")
        }
        return false
    }
    

    func setUom(for item: ShopItem) -> Uom? {
        do {
            // search category in coredata
            let uomRequest = NSFetchRequest<Uom>(entityName: "Uom")
            uomRequest.predicate = NSPredicate(format: "id == %d", item.itemUom.id)
            let uom = try context.fetch(uomRequest)
            if uom.isEmpty {
                return setDefaultUom()
            } else {
                return uom.first
            }
        } catch {
            print("Error of setting not defined category")
            return nil
        }
    }

    
    func setDefaultCategory() -> Category? {
        let itemCategory = CoreDataService.data.initCategories[0]
        do {
            // search category in coredata
            let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
            categoryRequest.predicate = NSPredicate(format: "id == %d", itemCategory.id)
            let category = try context.fetch(categoryRequest)
            return category.first
        } catch {
            print("Error of setting not defined category")
            return nil
        }
    }
    
    func setDefaultUom() -> Uom? {
        let itemUom = CoreDataService.data.initUoms[0]
        do {
            // search category in coredata
            let uomRequest = NSFetchRequest<Uom>(entityName: "Uom")
            uomRequest.predicate = NSPredicate(format: "id == %d", itemUom.id)
            let uom = try context.fetch(uomRequest)
            return uom.first
        } catch {
            print("Error of setting not defined category")
            return nil
        }
    }
    
    
}



//MARK: Categories
extension CoreDataService {
    func getCategoriesFromCoreData() -> [ItemCategory] {
        var cats = [Category]()
        do {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            cats = try context.fetch(fetchRequest)
            if cats.count != self.initCategories.count {
                cats = []
                for c in self.initCategories { // пересоздаем категории заново
                    let cat = Category(context: context)
                    cat.id = c.id
                    cat.category = c.name
                }
                ad.saveContext()
                cats = try context.fetch(fetchRequest)
            }
            
        } catch  {
            print("Categories are not got from database")
        }
        
        var itemCategories = [ItemCategory]()
        
        cats.forEach {
            if let categoryName = $0.category {
                let itemCategory = ItemCategory(id: $0.id, name: categoryName)
                itemCategories.append(itemCategory)
            }
        }
        return itemCategories
    }
    
    
    
    
    func setCategory(for item: ShopItem) -> Category? {
        do {
            // search category in coredata
            let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
            categoryRequest.predicate = NSPredicate(format: "id == %d", item.itemCategory.id)
            let category = try context.fetch(categoryRequest)
            
            if category.isEmpty {
                return setDefaultCategory()
            } else {
                return category.first
            }
        } catch {
            print("Error of setting not defined category")
            return nil
        }
    }
    
    func save(new category: ItemCategory) {
        let cat = Category(context: context)
        cat.id = category.id
        cat.category = category.name
        ad.saveContext()
    }
    
    func save(new uom: ItemUom) {
        let u = Uom(context: context)
        u.id = uom.id
        u.uom = uom.name
        ad.saveContext()
    }
    
    
    func save(new product: ShopItem) {
        let prod = Product(context: context)
        
        prod.id = product.id
        prod.name = product.name
        prod.scanned = product.scanned
        if let categ = getCategory(by: product.itemCategory.id) {
            prod.toCategory = categ
        }
        if let uom = getUom(by: product.itemUom.id) {
            prod.toUom = uom
        }
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
        } catch  {
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
        } catch  {
            fatalError("uom is not got from database")
        }
        
        return nil
    }
    
    
    
}






extension CoreDataService {
    
    func categoryPrint() {
        do {
            // search category in coredata
            let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
            let categories = try context.fetch(categoryRequest)
            
            if categories.count == self.initCategories.count {
            
                print("TEST: \(categories.count) vs dyn array: \(self.initCategories.count)")
                
            } else {
                print("TEST ATTENTION!!!: \(categories.count) vs dyn array: \(self.initCategories.count)")
                for cat in categories {
                    print("TEST: \(cat.id):\(cat.category ?? "")")
                }
            }
            
        } catch {
            print("Error of category data")
        }
    }
    
    
    
}


