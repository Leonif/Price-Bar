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
    var initCategories = ["Бытовая техника", "Косметика","Мясо","Овощи и фрукты", "Пекарня", "Молочка, Сыры", "Сладости"]
    var unitsOfMeasure: [ShopItemUom] = [ShopItemUom(uom: "уп",increment: 1.0),ShopItemUom(uom: "мл",increment: 0.01),ShopItemUom(uom: "л",increment: 0.1),ShopItemUom(uom: "г",increment: 0.01),ShopItemUom(uom: "кг",increment: 0.1)]
    
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
    
    
    func save(_ item: ShopItem) {
        saveProduct(item)
        saveStatistic(item)
    }
    
    func saveStatistic(_ item: ShopItem)  {
        do {
            let stat = Statistic(context: context)
            stat.outlet_id = item.outletId
            stat.price = item.price
            let productRequest = NSFetchRequest<Product>(entityName: "Product")
            productRequest.predicate = NSPredicate(format: "id == %@", item.id)
            let productExist = try context.fetch(productRequest)
            stat.toProduct = productExist.first
            ad.saveContext()
        } catch  {
            print("Products is not got from database")
        }
    }
    
    func saveProduct(_ item: ShopItem) {
        if item.scanned {
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
                if productExist.isEmpty {
                    let product = Product(context: context)
                    product.id = item.id
                    product.name = item.name
                    product.toCategory = category.first
                    product.toUom = uom.first
                } else  {
                    let product = productExist.first
                    product?.name = item.name
                    product?.toCategory = category.first
                    product?.toUom = uom.first
                }
                ad.saveContext()
            } catch  {
                print("Products is not got from database")
            }
        }

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
                        let item = ShopItem(id: prd.id!, name: prd.name!, quantity: 1.0, price: 0.00, category: category, uom: uom, outletId: outletId, scanned: true)
                        return item
                    }
                }
            }
        } catch  {
            print("Products is not got from database")
        }
        return nil
    }
    
    
}
