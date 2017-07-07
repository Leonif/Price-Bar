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
    var initCategories = ["Неопредленно","Бытовая техника", "Косметика","Мясо","Овощи и фрукты", "Пекарня", "Молочка, Сыры", "Сладости"]
    var unitsOfMeasure: [ShopItemUom] = [ShopItemUom(),ShopItemUom(uom: "1 уп",increment: 1.0),ShopItemUom(uom: "100 мл",increment: 0.01),ShopItemUom(uom: "1 л",increment: 0.1),ShopItemUom(uom: "100 г",increment: 0.01),ShopItemUom(uom: "1 кг",increment: 0.1)]
    
    
    
    
    func getCategories() -> [Category] {
        var cats = [Category]()
        do {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            cats = try context.fetch(fetchRequest)
            if cats.count != initCategories.count {
                cats.removeAll()
                ad.saveContext()
                for c in initCategories {
                    let cat = Category(context: context)
                    cat.category = c
                }
                ad.saveContext()
                cats = try context.fetch(fetchRequest)
            }
            
        } catch  {
            print("Categories are not got from database")
        }
        
        return cats
    }
    
    func getUom() ->[Uom] {
        var uoms = [Uom]()
        do {
            let fetchRequest = NSFetchRequest<Uom>(entityName: "Uom")
            uoms = try context.fetch(fetchRequest)
            if uoms.count != unitsOfMeasure.count {
                uoms.removeAll()
                for u in unitsOfMeasure {
                    print(u)
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
        saveStatistic(item)
        addToShopList(item)
    }
    
    
    
    
    
    func saveStatistic(_ item: ShopItem)  {        
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
        //printPriceStatistics()
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
                
                if let prd = $0.toProduct {
                
                    let price = getPrice((prd.id)!, outletId: outletId)
                    let minPrice = getMinPrice((prd.id)!, outletId: outletId)
                    
                    let uom = ShopItemUom(uom: (prd.toUom?.uom)!, increment: (prd.toUom?.iterator)!)
                    
                    let item = ShopItem(id: (prd.id)!, name: (prd.name)!, quantity: $0.quantity, minPrice: minPrice, price: price, category: (prd.toCategory?.category)!, uom: uom, outletId: outletId, scanned: (prd.scanned), checked: $0.checked)
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

//MARK: Product
extension CoreDataService {
    
    
    func getItemList(outletId: String) -> [ShopItem]? {
        
        
        var shopItems = [ShopItem]()
        
        do {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            let productExist = try context.fetch(fetchRequest)
            if !productExist.isEmpty {
                productExist.forEach {
                    if let toUom = $0.toUom, let u = toUom.uom  {
                        let uom = ShopItemUom(uom: u, increment: toUom.iterator)
                        let category = ($0.toCategory?.category)!
                        let price = getPrice($0.id!, outletId: outletId)
                        let minPrice = getMinPrice($0.id!, outletId: outletId)
                        let item = ShopItem(id: $0.id!, name: $0.name!, quantity: 1.0, minPrice: minPrice, price: price, category: category, uom: uom, outletId: outletId, scanned: true, checked: false)
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
                    if let toUom = prd.toUom, let u = toUom.uom  {
                        let uom = ShopItemUom(uom: u, increment: toUom.iterator)
                        let category = (prd.toCategory?.category)!
                        let price = getPrice(barcode, outletId: outletId)
                        let minPrice = getMinPrice(barcode, outletId: outletId)
                        let item = ShopItem(id: prd.id!, name: prd.name!, quantity: 1.0, minPrice: minPrice, price: price, category: category, uom: uom, outletId: outletId, scanned: true, checked: false)
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
            do {
                let productRequest = NSFetchRequest<Product>(entityName: "Product")
                productRequest.predicate = NSPredicate(format: "id == %@", item.id)
                let productExist = try context.fetch(productRequest)
                
                let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
                categoryRequest.predicate = NSPredicate(format: "category == %@", item.category)
                let category = try context.fetch(categoryRequest)
                let uomRequest = NSFetchRequest<Uom>(entityName: "Uom")
                uomRequest.predicate = NSPredicate(format: "uom == %@", item.uom.uom)
                let uom = try context.fetch(uomRequest)
                
                //product doesnt exists - create productc on coredata
                if productExist.isEmpty {
                    let product = Product(context: context)
                    product.id = item.id
                    product.name = item.name
                    product.toCategory = category.first
                    product.toUom = uom.first
                    product.scanned = item.scanned
                } else  { // - just update it
                    if let product = productExist.first {
                        product.name = item.name
                        product.toCategory = category.first
                        product.toUom = uom.first
                        product.scanned = item.scanned
                    }
                }
                ad.saveContext()
            } catch  {
                print("Products is not got from database")
            }
        }
    
}


