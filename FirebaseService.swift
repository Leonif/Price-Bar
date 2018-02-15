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
    var refGoods = Database.database().reference().child("goods")
    var refPriceStatistics = Database.database().reference().child("price_statistics")
    var refCategories = Database.database().reference().child("categories")
    var refUoms = Database.database().reference().child("uoms")
    var refUomsParams = Database.database().reference().child("uoms").child("parameters")
    
    let email = "good_getter@gmail.com"
    let pwd = "123456"
    
    var stateError: FirebaseError? = nil
    
    

    func loginToFirebase(completion: @escaping (ResultType<Bool, FirebaseError>)->Void) {
        Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
            if error != nil {
                print("error of Email authorization!")
                Auth.auth().createUser(withEmail: self.email,
                                       password: self.pwd,
                                       completion: { (user, error) in
                                        if error != nil {
                                            print("error of user creation!")
                                            self.stateError = .loginError("error of user creation!")
                                            completion(ResultType.failure(.loginError("error of user creation!")))
                                        }
                                        print("User \(self.email) is created!")
                                        return
                })
            }
            self.stateError = nil
            completion(ResultType.success(true))
            print("Email authorization is successful!")
        })
    }

    func syncCategories(completion: @escaping (ResultType<[FBItemCategory], FirebaseError>)->Void) {
        
        guard stateError == nil else {
            completion(ResultType.failure(.syncError("Попробуйте позже")))
            return
        }
        
        self.refCategories.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                var categories = [FBItemCategory]()
                for snapCategory in snapCategories {
                    if let id = Int32(snapCategory.key), let categoryDict = snapCategory.value as? Dictionary<String, Any> {
                        let itemCategory = FBItemCategory(key:id, itemCategoryDict: categoryDict)
                        categories.append(itemCategory)
                    }
                }
                completion(ResultType.success(categories))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }

    func syncProducts(completion: @escaping (ResultType<[FBProductModel], FirebaseError>)->Void) {
        self.refGoods.observeSingleEvent(of: .value, with: { snapshot in
            if let snapGoods = snapshot.value as? [String: Any] {
                let goods = FirebaseParser.transform(from: snapGoods)
                completion(ResultType.success(goods))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }

    func syncStatistics(completion: @escaping (ResultType<[FBItemStatistic], FirebaseError>)->Void) {
        refPriceStatistics.observeSingleEvent(of: .value, with: { snapshot in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                var itemStatistic = [FBItemStatistic]()
                for snapPrice in snapPrices {
                    if let priceDict = snapPrice.value as? Dictionary<String, Any> {
                        if let statistic = FBItemStatistic(priceData: priceDict) {
                            itemStatistic.append(statistic)
                        }

                    }
                }
                completion(ResultType.success(itemStatistic))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }

    func syncUoms(completion: @escaping (ResultType<[FBUomModel], FirebaseError>)->Void) {
        self.refUoms.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                let uoms: [FBUomModel] = FirebaseParser.parseUoms(from: snapUoms)
                completion(ResultType.success(uoms))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }

    func saveOrUpdate(_ item: FBProductModel) {

        let good = [
            "barcode": item.id,
            "name": item.name,
            "category_id": item.categoryId,
            "uom_id": item.uomId
        ] as [String: Any]
        refGoods.child(item.id).setValue(good)
    }

    func save(new statistic: FBItemStatistic) {
        let priceStat = [
            "date": statistic.date.getString(format: "dd.MM.yyyy hh:mm:ss"),
            "product_id": statistic.productId,
            "outlet_id": statistic.outletId,
            "price": statistic.price
            ] as [String: Any]
        refPriceStatistics.childByAutoId().setValue(priceStat)
    }

}
