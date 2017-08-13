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
    var unitsOfMeasure: [ShopItemUom] = [ShopItemUom(),ShopItemUom(uom: "1 уп",increment: 1.0),ShopItemUom(uom: "100 мл",increment: 0.01),ShopItemUom(uom: "1 л",increment: 0.1),ShopItemUom(uom: "100 г",increment: 0.01),ShopItemUom(uom: "1 кг",increment: 0.1)]
    
    
    func loadCategories(_ complete: @escaping ()->()) {
        initCategories = []
        FirebaseService.data.loadCategories { (categories) in
            self.initCategories = categories
            //print("coredata: \(categories)")
            complete()
        }
        
    }
    
    
    func getCategories(complete: @escaping ([ItemCategory])->()) {
        
        
        loadCategories {
            let itemCategories = self.getCategoriesFromCoreData()
            complete(itemCategories)
        }   
        
        
    }
    
    
    func getCategoriesFromCoreData() -> [ItemCategory] {
        var cats = [Category]()
        do {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            cats = try context.fetch(fetchRequest)
            //print("core data category BEFORE: \(cats.count) vs dyn array: \(self.initCategories.count)")
            if cats.count != self.initCategories.count {
                cats = []
                for c in self.initCategories { // пересоздаем категории заново
                    let cat = Category(context: context)
                    cat.id = c.id
                    cat.category = c.name
                    //print("create category: \(cat.category  ?? "не создано")")
                }
                ad.saveContext()
                cats = try context.fetch(fetchRequest)
                //print("core data category AFTER: \(cats.count) vs dyn array: \(self.initCategories.count)")
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
        //print("core data category AFTER2: \(cats.count) vs dyn array: \(self.initCategories.count)")
        return itemCategories
    }
    
    
    func getUom() ->[Uom] {
        var uoms = [Uom]()
        do {
            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
            uoms = try context.fetch(fetchRequest)
            if uoms.count != unitsOfMeasure.count {
                uoms.removeAll()
                for u in unitsOfMeasure {
                    //print(u)
                    let um = Uom(context: context)
                    um.uom = u.uom
                    um.iterator = u.increment
                }
                ad.saveContext()
                uoms = try context.fetch(fetchRequest)
            }
        } catch  {
            print("Uom are not got from database")
        }
        return uoms
    }
    
    
    func addToShopListAndSaveStatistics(_ item: ShopItem) {
        saveProduct(item)
        FirebaseService.data.addGoodToCloud(item)
        saveStatistic(item)
        print("From CoreData: addToShopListAndSaveStatistics - addToShopList")
        addToShopList(item)
    }
    
    
    
    
    
    func saveStatistic(_ itemPrice: ShopItem)  {
        savePrice(itemPrice)
        FirebaseService.data.savePriceSatistics(itemPrice)
        
    }
    
    
    func savePrice(_ itemPrice: ShopItem) {
        guard itemPrice.price != 0 else {
            return
        }
        
        do {
            let stat = Statistic(context: context)
            stat.outlet_id = itemPrice.outletId
            stat.price = itemPrice.price
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", itemPrice.id)
            let productExist = try context.fetch(productRequest)
            
            let prd = productExist.first
            
            stat.toProduct = prd
            stat.price = itemPrice.price
            stat.outlet_id = itemPrice.outletId
            ad.saveContext()
        } catch  {
            print("Products is not got from database")
        }

        
        
    }
    
    
    
    func importPricesFromFirebase(completion: @escaping ()->()) {
        
        FirebaseService.data.importPricesFromCloud { (itemPrices) in
            for item in itemPrices {
                self.savePrice(item)
            }
            completion()
        }
        
    }
    
    
    
    func addToShopList(_ item:ShopItem) {
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
            
            productExist.forEach {context.delete($0) }
            ad.saveContext()
        } catch {
            print("Products is not got from database")
        }

        
    }
    
    func loadShopList(outletId: String) -> ShopListModel?{
        let shopListModel = ShopListModel()
        
        do {
            let shpLstRequest = NSFetchRequest<ShopList>(entityName: "ShopList")
            
            let productExist = try context.fetch(shpLstRequest)
            productExist.forEach {
                
                if let prd = $0.toProduct, let id = prd.id, let prodUom = prd.toUom, let u = prodUom.uom, let name = prd.name, let prodCat = prd.toCategory, let category = prodCat.category {
                
                    let price = getPrice(id, outletId: outletId)
                    let minPrice = getMinPrice(id, outletId: outletId)
                    
                    let uom = ShopItemUom(uom: u, increment: prodUom.iterator)
                    
                    let itemCategory = ItemCategory(id: prodCat.id, name: category)
                    
                    let item = ShopItem(id: id, name: name, quantity: $0.quantity, minPrice: minPrice, price: price, itemCategory: itemCategory, uom: uom, outletId: outletId, scanned: prd.scanned, checked: $0.checked)
                    
                    shopListModel.append(item: item)
                }
            
            }
            return shopListModel
            
            
        } catch {
            print("Products is not got from database")
        }
        
        return nil
        
    }
}


//MARK: Firebase work
extension CoreDataService {
    
    func importGoodsFromFirebase(completion: @escaping ()->()) {
        FirebaseService.data.loadGoods { (goods) in
            goods.forEach {
                self.saveProduct($0)
                //print("coredata: goods recieved: \($0.id),\($0.name), -- \($0.itemCategory.name)")
            }
            completion()
            
        }
    }
}


//MARK: Product
extension CoreDataService {
    func getItemList(outletId: String) -> [ShopItem]? {
        var shopItems = [ShopItem]()
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            let productExist = try context.fetch(fetchRequest)
            if !productExist.isEmpty {
                productExist.forEach {
                    if let id = $0.id,
                        let name = $0.name,
                        let prodCat = $0.toCategory,
                        let category = prodCat.category,
                        let toUom = $0.toUom,
                        let u = toUom.uom  {
                        
                        let uom = ShopItemUom(uom: u, increment: toUom.iterator)
                        let price = getPrice(id, outletId: outletId)
                        let minPrice = getMinPrice(id, outletId: outletId)
                        
                        let itemCategory = ItemCategory(id: prodCat.id, name: category)
                        
                        let item = ShopItem(id: id, name: name,
                                            quantity: 1.0,
                                            minPrice: minPrice,
                                            price: price,
                                            itemCategory: itemCategory,
                                            uom: uom, outletId: outletId,
                                            scanned: true,
                                            checked: false)
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
                    if let id = prd.id, let name = prd.name, let toUom = prd.toUom, let prodCat = prd.toCategory, let category = prodCat.category, let u = toUom.uom  {
                        let uom = ShopItemUom(uom: u, increment: toUom.iterator)
                        let price = getPrice(barcode, outletId: outletId)
                        let minPrice = getMinPrice(barcode, outletId: outletId)
                        
                        let itemCategory = ItemCategory(id: prodCat.id, name: category)
                        
                        let item = ShopItem(id: id, name: name, quantity: 1.0, minPrice: minPrice, price: price, itemCategory: itemCategory, uom: uom, outletId: outletId, scanned: true, checked: false)
                        return item
                    }
                }
            }
        } catch  {
            print("Products is not got from database")
        }
        return nil
    }

    func saveProduct(_ item: ShopItem) {
        
        //TEST
        //categoryPrint()
        
        do {
            
            // search item in coredata
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", item.id)
            let productExist = try context.fetch(productRequest)
            
            // search category in coredata
            let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
            categoryRequest.predicate = NSPredicate(format: "id == %d", item.itemCategory.id)
            let category = try context.fetch(categoryRequest)
            
            //search uom in coredata
            let uomRequest = NSFetchRequest<Uom>(entityName: "Uom")
            uomRequest.predicate = NSPredicate(format: "uom == %@", item.uom.uom)
            let uom = try context.fetch(uomRequest)
            
            //product doesnt exists - create product in coredata
            if productExist.isEmpty {
                let product = Product(context: context)
                product.id = item.id
                product.name = item.name
                if category.isEmpty {
                    product.toCategory = setDefaultCategory()!
                } else {
                    product.toCategory = category.first
                }
                product.toUom = uom.first
                product.scanned = item.scanned
                //print("coredata loading from firebase: \(product.toCategory!.id)-\(product.toCategory!.category!):\(product.id!): \(product.name!)")
            } else  { // - just update it
                if let product = productExist.first {
                    product.name = item.name
                    if category.isEmpty {
                        product.toCategory = setDefaultCategory()!
                    } else {
                        product.toCategory = category.first
                    }
                    product.toUom = uom.first
                    product.scanned = item.scanned
                }
            }
            ad.saveContext()
        } catch  {
            print("Products is not got from database")
        }
        //AFTER
        //categoryPrint()
        
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


