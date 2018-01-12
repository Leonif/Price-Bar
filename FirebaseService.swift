//
//  FirebaseService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import Firebase

let DB_FIRBASE = Database.database().reference()

enum FirebaseError: Error {
    case loginError(String)
    case syncError(String)
    
}



class FirebaseService {
   
    static let data = FirebaseService()
    var REF_BASE = DB_FIRBASE
    var REF_GOODS = DB_FIRBASE.child("goods")
    var REF_PRICE_STATISTICS = DB_FIRBASE.child("price_statistics")
    var REF_CATEGORIES = DB_FIRBASE.child("categories")
    var REF_UOMS = DB_FIRBASE.child("uoms")
    
    
    
    func loginToFirebase(completion: @escaping (ResultType<Bool, FirebaseError>)->()) {
        let email = "good_getter@gmail.com"
        let pwd = "123456"
        
        Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
            if error != nil {
                print("error of Email authorization!")
                Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                    if error != nil {
                        print("error of user creation!")
                        completion(ResultType.failure(.loginError("error of user creation!")))
                    }
                    print("User \(email) is created!")
                    return
                })
            }
            completion(ResultType.success(true))
            print("Email authorization is successful!")
        })
    }
    
    func syncCategories(completion: @escaping (ResultType<[ItemCategory], FirebaseError>)->()) {
        self.REF_CATEGORIES.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                var categories = [ItemCategory]()
                for snapCategory in snapCategories {
                    if let id = Int32(snapCategory.key), let categoryDict = snapCategory.value as? Dictionary<String,Any> {
                        let itemCategory = ItemCategory(key:id,itemCategoryDict: categoryDict)
                        categories.append(itemCategory)
                    }
                }
                completion(ResultType.success(categories))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func syncProducts(completion: @escaping (ResultType<[ShopItem], FirebaseError>)->())  {
        self.REF_GOODS.observeSingleEvent(of: .value, with: { snapshot in
            if let snapGoods = snapshot.value as? [String: Any] {
                var goods = [ShopItem]()
                for snapGood in snapGoods {
                    if let goodDict = snapGood.value as? Dictionary<String, Any> {
                        let key = snapGood.key
                        let good = ShopItem(id: key, goodData: goodDict)
                        goods.append(good)
                    }
                }
                completion(ResultType.success(goods))
            }
        })  { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func syncPrices(completion: @escaping (ResultType<[ShopItem], FirebaseError>)->()) {
        REF_PRICE_STATISTICS.observeSingleEvent(of: .value, with: { snapshot in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                var itemPrices = [ShopItem]()
                for snapPrice in snapPrices {
                    if let priceDict = snapPrice.value as? Dictionary<String,Any> {
                        if let product_id = priceDict["product_id"] as? String {
                            if let price = priceDict["price"] as? Double, price != 0 {
                                let item = ShopItem(id: product_id, priceData: priceDict)
                                itemPrices.append(item)
                            }
                        }
                    }
                }
                completion(ResultType.success(itemPrices))
            }
        })  { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    
    func syncUoms(completion: @escaping (ResultType<[ItemUom], FirebaseError>)->()) {
        self.REF_UOMS.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                var uoms = [ItemUom]()
                for snapUom in snapUoms {
                    if let id = Int32(snapUom.key), let uomDict = snapUom.value as? Dictionary<String,Any> {
                        let itemUom = ItemUom(key:id,itemUomDict: uomDict)
                        uoms.append(itemUom)
                    }
                }
                completion(ResultType.success(uoms))
            }
        })   { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func saveOrUpdate(_ item: ShopItem) {
        
        guard item.price != 0 else {
            return
        }
        
        let good = [
            "barcode": item.id,
            "name": item.name,
            "category_id": item.itemCategory.id,
            "uom_id": item.itemUom.id
        ] as [String : Any]
        REF_GOODS.child(item.id).setValue(good)
        
    }
    
    
    
    
    func savePrice(for item: ShopItem) {
        let priceStat = [
            "date": Date().getString(format: "dd.MM.yyyy hh:mm:ss"),
            "product_id": item.id,
            "outlet_id": item.outletId,
            "price": item.price
            ] as [String : Any]
        REF_PRICE_STATISTICS.childByAutoId().setValue(priceStat)
    }
    
    
}
