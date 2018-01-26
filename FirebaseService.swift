//
//  FirebaseService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import Firebase

//let DB_FIRBASE = Database.database().reference()

enum FirebaseError: Error {
    case loginError(String)
    case syncError(String)
    
}

class FirebaseService {
    static let data = FirebaseService()
    //var REF_BASE = Database.database().reference()
    var REF_GOODS = Database.database().reference().child("goods")
    var REF_PRICE_STATISTICS = Database.database().reference().child("price_statistics")
    var REF_CATEGORIES = Database.database().reference().child("categories")
    var REF_UOMS = Database.database().reference().child("uoms")
    
    
    
    
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
    
    func syncCategories(completion: @escaping (ResultType<[FBItemCategory], FirebaseError>)->()) {
        self.REF_CATEGORIES.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                var categories = [FBItemCategory]()
                for snapCategory in snapCategories {
                    if let id = Int32(snapCategory.key), let categoryDict = snapCategory.value as? Dictionary<String,Any> {
                        let itemCategory = FBItemCategory(key:id,itemCategoryDict: categoryDict)
                        categories.append(itemCategory)
                    }
                }
                completion(ResultType.success(categories))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func syncProducts(completion: @escaping (ResultType<[FBProductModel], FirebaseError>)->())  {
        self.REF_GOODS.observeSingleEvent(of: .value, with: { snapshot in
            if let snapGoods = snapshot.value as? [String: Any] {
                let goods = ProductMapper.transform(from: snapGoods)
                completion(ResultType.success(goods))
            }
        })  { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func syncStatistics(completion: @escaping (ResultType<[FBItemStatistic], FirebaseError>)->()) {
        REF_PRICE_STATISTICS.observeSingleEvent(of: .value, with: { snapshot in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                var itemStatistic = [FBItemStatistic]()
                for snapPrice in snapPrices {
                    if let priceDict = snapPrice.value as? Dictionary<String,Any> {
                        if let statistic = FBItemStatistic(priceData: priceDict) {
                            itemStatistic.append(statistic)
                        }
                        
                    }
                }
                completion(ResultType.success(itemStatistic))
            }
        })  { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    
    func syncUoms(completion: @escaping (ResultType<[FBUomModel], FirebaseError>)->()) {
        self.REF_UOMS.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                var uoms = [FBUomModel]()
                for snapUom in snapUoms {
                    let itemUom = self.uomMapper(from: snapUom)
                    uoms.append(itemUom)
                }
                completion(ResultType.success(uoms))
            }
        })   { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func uomMapper(from snapUom: DataSnapshot) -> FBUomModel {
        guard let id = Int32(snapUom.key),
            let uomDict = snapUom.value as? Dictionary<String,Any>,
            let uomName = uomDict["name"] as? String,
            let uomIterator = uomDict["iterator"] as? Double else {
            fatalError("Category os not parsed")
        }
        
        return FBUomModel(id: id, name: uomName, iterator: uomIterator)
        
    }
    
    
    func saveOrUpdate(_ item: FBProductModel) {
        
        let good = [
            "barcode": item.id,
            "name": item.name,
            "category_id": item.categoryId,
            "uom_id": item.uomId
        ] as [String : Any]
        REF_GOODS.child(item.id).setValue(good)
    }
    
    func save(new statistic: FBItemStatistic) {
        let priceStat = [
            "date": statistic.date.getString(format: "dd.MM.yyyy hh:mm:ss"),
            "product_id": statistic.productId,
            "outlet_id": statistic.outletId,
            "price": statistic.price
            ] as [String : Any]
        REF_PRICE_STATISTICS.childByAutoId().setValue(priceStat)
    }
    
    
//    func savePrice(for item: ShopItem) {
//        let priceStat = [
//            "date": Date().getString(format: "dd.MM.yyyy hh:mm:ss"),
//            "product_id": item.id,
//            "outlet_id": item.outletId,
//            "price": item.price
//            ] as [String : Any]
//        REF_PRICE_STATISTICS.childByAutoId().setValue(priceStat)
//    }
    
    
}
