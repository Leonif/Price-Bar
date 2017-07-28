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

class FirebaseService {
    
   
    static let data = FirebaseService()
    var REF_BASE = DB_FIRBASE
    var REF_GOODS = DB_FIRBASE.child("goods")
    var REF_PRICE_STATISTICS = DB_FIRBASE.child("price_statistics")
    var REF_CATEGORIES = DB_FIRBASE.child("categories")
    
    
    
    func loginToFirebase(_ success: @escaping ()->(), _ error: ()->()) {
        
        let email = "good_getter@gmail.com"
        let pwd = "123456"
        
        
        Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
            if error != nil {
                print("error of Email authorization!")
                Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                    if error != nil {
                        print("error of user creation!")
                        return
                    }
                    print("User \(email) is created!")
                    
                    return
                    
                })
            }
            success()
            print("Email authorization is successful!")
            
            
            
        })
        

    }
    
    func loadCategories(categoryList: @escaping (_ categories: [String])->()) {
        self.REF_CATEGORIES.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                var categories = [String]()
                for snapCategory in snapCategories {
                    if let categoryDict = snapCategory.value as? Dictionary<String,String> {
                        
                        if let categoryName = categoryDict["name"] {
                            categories.append(categoryName)
                            print("firebase loading categories: \(categoryName)")
                        }
                        
                    }
                    
                }
                categoryList(categories)
            }
        })
        
        
    }
    
    func loadGoods(goodList: @escaping (_ good: [ShopItem])->())  {
        
        loginToFirebase({ 
            self.REF_GOODS.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapGoods = snapshot.value as? [String: Any] {
                    
                    var goods = [ShopItem]()
                    for snapGood in snapGoods {
                        if let goodDict = snapGood.value as? Dictionary<String, Any> {
                            let key = snapGood.key
                            let good = ShopItem(id: key, goodData: goodDict)
                            goods.append(good)
                        }
                    }
                    goodList(goods)
                }
            })
        }) { 
            print("Error goods getting")
        }
    }
    
    
    func addGoodToCloud(_ item: ShopItem) {
        let good = [
            "barcode": item.id,
            "name": item.name,
            "category_id": item.
        ]
        REF_GOODS.child(item.id).setValue(good)
        
    }
    
    func importPricesFromCloud(comlete: @escaping (_ itemPrices: [ShopItem])->()) {
        
        REF_PRICE_STATISTICS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                var itemPrices = [ShopItem]()
                for snapPrice in snapPrices {
                    if let priceDict = snapPrice.value as? Dictionary<String,Any> {
                        
                        if let product_id = priceDict["product_id"] as? String {
                            if let price = priceDict["price"] as? Double, price != 0 {
                                let item = ShopItem(id: product_id, priceData: priceDict)
                                itemPrices.append(item)
                                
                                print("firebase import pricing: \(priceDict)")
                            }
                        }
                        
                    }
                    
                }
                comlete(itemPrices)
                
            }
        })
        
        

        
        
    }
    
    
    func savePriceSatistics(_ item: ShopItem) {
        let priceStat = [
            "date": Date().getString(format: "dd.MM.yyyy hh:mm:ss"),
            "product_id": item.id,
            "outlet_id": item.outletId,
            "price": item.price
            ] as [String : Any]
        REF_PRICE_STATISTICS.childByAutoId().setValue(priceStat)
    }
    
    
}
