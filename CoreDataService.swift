//
//  CoreDataService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/18/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData


class CoreDataService {
    
    static let data = CoreDataService()
    var initCategories = [ItemCategory]()
    var initUoms = [ItemUom]()
    
    
    var defaultCategory: ItemCategory {
        return initCategories[0]
    }
    
    
    func loadCategories(_ complete: @escaping ()->()) {
        initCategories = []
        FirebaseService.data.loadCategories { (categories) in
            self.initCategories = categories
            complete()
        }
    }
    
    func loadUoms(_ complete: @escaping ()->()) {
        initUoms = []
        FirebaseService.data.loadUoms { (uoms) in
            self.initUoms = uoms
            complete()
        }
        
    }
    
    
    func getCategories(complete: @escaping ([ItemCategory])->()) {
        loadCategories {
            let itemCategories = self.getCategoriesFromCoreData()
            complete(itemCategories)
        }   
    }
    
    func getUoms(complete: @escaping ([ItemUom])->()) {
        loadUoms {
            let itemUoms = self.getUomsFromCoreData()
            complete(itemUoms)
        }
    }
    
    
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
        FirebaseService.data.saveOrUpdate(item)
        saveStatistic(item)
        print("From CoreData: addToShopListAndSaveStatistics - addToShopList")
        saveToShopList(item)
    }
    
    func saveStatistic(_ item: ShopItem)  {
        savePrice(for: item)
        FirebaseService.data.savePrice(for: item)
    }
    
    func savePrice(for item: ShopItem) {
        guard item.price != 0 else {
            return
        }
        do {
            let stat = Statistic(context: context)
            stat.outlet_id = item.outletId
            stat.price = item.price
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", item.id)
            let productExist = try context.fetch(productRequest)
            
            let prd = productExist.first
            
            stat.toProduct = prd
            stat.price = item.price
            stat.outlet_id = item.outletId
            ad.saveContext()
        } catch  {
            print("Products is not got from database")
        }
    }
    
    func importPricesFromCloud(completion: @escaping ()->()) {
        
        FirebaseService.data.importPricesFromCloud { (itemPrices) in
            for item in itemPrices {
                self.savePrice(for: item)
            }
            completion()
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
    
    func loadShopList(outletId: String) -> ShopListService?{
        let shopListService = ShopListService()
        
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            
            let productExist = try context.fetch(shpLstRequest)
            
            productExist.forEach {
                if let prd = $0.toProduct,
                    let id = prd.id,
                    let name = prd.name,
                    let prodUom = prd.toUom,
                    let uomName = prodUom.uom,
                    let prodCat = prd.toCategory,
                    let category = prodCat.category {
                
                    let price = getPrice(for: id, and: outletId)
                    let minPrice = getMinPrice(id, outletId: outletId)
                    
                    let itemUom = ItemUom(id: prodUom.id, name: uomName, iterator: prodUom.iterator)
                    
                    let itemCategory = ItemCategory(id: prodCat.id, name: category)
                    
                    let item = ShopItem(id: id, name: name, quantity: $0.quantity, minPrice: minPrice, price: price, itemCategory: itemCategory, itemUom: itemUom, outletId: outletId, scanned: prd.scanned, checked: $0.checked)
                    
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


//MARK: Firebase work
extension CoreDataService {
    
    func importItemsFromCloud(completion: @escaping ()->()) {
        FirebaseService.data.loadGoods { (goods) in
            goods.forEach {
                self.saveOrUpdate($0)
            }
            completion()
            
        }
    }
}


//MARK: Product
extension CoreDataService {
    func shopItem(parse product: Product, and outletId: String) -> ShopItem? {
        if let id = product.id, let name = product.name,
            let category = product.toCategory?.category, let idCat = product.toCategory?.id, // optional chaining
            let prodUom = product.toUom, let uom = prodUom.uom  {
            let price = getPrice(for: id, and: outletId)
            let minPrice = getMinPrice(id, outletId: outletId)
            
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
        else {
            return nil
        }
    }
    
    func filterItemList(itemName: String, for outletId: String) -> [ShopItem]? {
        var shopItems = [ShopItem]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", itemName)
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
    
    
    func getShortItemList(outletId: String, offset: Int) -> [ShopItem]? {
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
                        let minPrice = getMinPrice(barcode, outletId: outletId)
                        
                        let itemCategory = ItemCategory(id: prodCat.id, name: category)
                        let itemUom = ItemUom(id: prodUom.id, name: uomName, iterator: prodUom.iterator)
                        
                        let item = ShopItem(id: id, name: name, quantity: 1.0, minPrice: minPrice, price: price, itemCategory: itemCategory, itemUom: itemUom, outletId: outletId, scanned: true, checked: false)
                        return item
                    }
                }
            }
        } catch  {
            print("Products is not got from database")
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


