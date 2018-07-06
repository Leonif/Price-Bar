//
//  FirebaseService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import Firebase

enum FirebaseError: Error {
    case loginError(String)
    case syncError(String)
    case dataIsNotFound(String)

}

class FirebaseService {
    static let data = FirebaseService()
    private var refGoods = Database.database().reference().child("goods")
    
    private var refPriceStatistics: DatabaseReference

    
    private var refCategories: DatabaseReference? = nil
    private var refUoms: DatabaseReference? = nil
    private var refUomsParams: DatabaseReference? = nil
    
    private var email = "good_getter@gmail.com"
    private var pwd = "123456"

    var goodCurrentId: String?
    
    
    
    init() {
        refGoods = Database.database().reference().child("goods")
        
        #if DEVELOPMENT
        let statistics = "price_statistics_dev"
        #else
        let statistics = "price_statistics_fq"
        //        let statistics = "price_statistics_gp"
        
        #endif
        
        refPriceStatistics = Database.database().reference().child(statistics)
        
        refCategories = Database.database().reference().child("categories")
        refUoms = Database.database().reference().child("uoms")
        refUomsParams = Database.database().reference().child("uoms").child("parameters")
        
        email = "good_getter@gmail.com"
        pwd = "123456"
    }
    
    
    
    func loginToFirebase(completion: @escaping (ResultType<Bool, FirebaseError>)->Void) {
        Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
            if error != nil {
                print("error of Email authorization!")
                Auth.auth().createUser(withEmail: self.email,
                                       password: self.pwd,
                                       completion: { (user, error) in
                                        if error != nil {
                                            print("error of user creation!")
                                            completion(ResultType.failure(.loginError("error of user creation!")))
                                            return
                                        }
                                        print("User \(self.email) is created!")
                                        return
                })
            }
            completion(ResultType.success(true))
            print("Email authorization is successful!")
        })
    }

    func syncCategories(completion: @escaping (ResultType<[FBItemCategory], FirebaseError>)->Void) {
        self.refCategories?.observeSingleEvent(of: .value, with: { snapshot in
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

//    func syncProducts(completion: @escaping (ResultType<[FBProductModel], FirebaseError>)->Void) {
//        self.refGoods.observeSingleEvent(of: .value, with: { snapshot in
//            if let snapGoods = snapshot.value as? [String: Any] {
//                let goods = snapGoods.map { FirebaseParser.parseToFbProductModel(from: $0) }
//                completion(ResultType.success(goods))
//            }
//        }) { error in
//            completion(ResultType.failure(.syncError(error.localizedDescription)))
//        }
//    }
    
    
    func getProductList_OLD(with pageOffset: Int, limit: Int, completion: @escaping (ResultType<[FBProductModel], FirebaseError>)->Void) {
        self.refGoods.observeSingleEvent(of: .value, with: { snapshot in
            if let snapGoods = snapshot.value as? [String: Any] {
                let goods = snapGoods.map { FirebaseParser.parseToFbProductModel(from: $0) }
                
                let start = pageOffset
                let end = pageOffset + limit
                
                let batch = goods[start..<end].map({ $0 })
                
                completion(ResultType.success(batch))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func getProductList(with pageOffset: Int, limit: Int, completion: @escaping (ResultType<[FBProductModel], FirebaseError>)->Void) {
        if pageOffset == 0 {
            self.refGoods.queryOrderedByKey().queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { snapshot in
                if let snapGoods = snapshot.value as? [String: Any] {
                    let goods = snapGoods.map { FirebaseParser.parseToFbProductModel(from: $0) }
                    
                    self.goodCurrentId = goods.last?.id
                    completion(ResultType.success(goods))
                }
            }) { error in
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        } else {
            self.refGoods.queryOrderedByKey().queryEnding(atValue: self.goodCurrentId).queryLimited(toFirst: UInt(limit)).observeSingleEvent(of: .value, with: { snapshot in
                if let snapGoods = snapshot.value as? [String: Any] {
                    let goods = snapGoods.map { FirebaseParser.parseToFbProductModel(from: $0) }
                    if self.goodCurrentId != goods.last?.id {
                        self.goodCurrentId = goods.last?.id
                        completion(ResultType.success(goods))
                    } else {
                        completion(ResultType.success([]))
                    }
                    
                }
            }) { error in
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }
    
    
    
    
    func getProductCount(completion: @escaping (ResultType<Int, FirebaseError>)->Void) {
        self.refGoods.observeSingleEvent(of: .value, with: { snapshot in
            completion(ResultType.success(Int(snapshot.childrenCount)))
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    

//    func syncStatistics(completion: @escaping (ResultType<[FBItemStatistic], FirebaseError>)->Void) {
//        refPriceStatistics.observeSingleEvent(of: .value, with: { snapshot in
//            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
//                let itemStatistic = snapPrices.compactMap { FirebaseParser.parseToFBItemStatistic(from: $0) }
//                completion(ResultType.success(itemStatistic))
//            }
//        }) { error in
//            completion(ResultType.failure(.syncError(error.localizedDescription)))
//        }
//    }

    func syncUoms(completion: @escaping (ResultType<[FBUomModel], FirebaseError>)->Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                let uoms: [FBUomModel] = FirebaseParser.transfromToFBUomModels(from: snapUoms)
                completion(ResultType.success(uoms))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func getParametredUom(for uomId: Int32, completion: @escaping (ResultType<FBUomModel, FirebaseError>)->Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                let uoms = FirebaseParser.transfromToFBUomModels(from: snapUoms).filter { $0.id == uomId }
                guard let uom = uoms.first else { fatalError() }
                completion(ResultType.success(uom))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func saveOrUpdate(_ item: FBProductModel) {
        let good = [
            "barcode": item.id,
            "name": item.name,
            "brand": item.brand,
            "weight_per_piece": item.weightPerPiece,
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
    
    func getCategoryId(for categoryName: String, completion: @escaping (ResultType<Int?, FirebaseError>)->Void) {
        self.refCategories?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                for snapCategory in snapCategories {
                    if let id = Int32(snapCategory.key), let categoryDict = snapCategory.value as? Dictionary<String, Any> {
                        guard let name = categoryDict["name"] as? String else { return }
                        
                        if name == categoryName {
                            completion(ResultType.success(Int(id)))
                            return
                        }
                    }
                }
                completion(ResultType.success(nil))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func getCategoryName(for categoryId: Int32, completion: @escaping (ResultType<String?, FirebaseError>)->Void) {
        self.refCategories?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                for snapCategory in snapCategories {
                    if let id = Int32(snapCategory.key), let categoryDict = snapCategory.value as? Dictionary<String, Any> {
                        guard let name = categoryDict["name"] as? String else { return }
                        
                        if id == categoryId {
                            completion(ResultType.success(name))
                            return
                        }
                    }
                }
                completion(ResultType.success(nil))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func getUomId(for uomName: String, completion: @escaping (ResultType<Int?, FirebaseError>)->Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                for snapUom in snapUoms {
                    if let id = Int32(snapUom.key), let uomDict = snapUom.value as? Dictionary<String, Any> {
                        guard let name = uomDict["name"] as? String else { return }
                        
                        if name == uomName {
                            completion(ResultType.success(Int(id)))
                            return
                        }
                    }
                }
                completion(ResultType.success(nil))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func getUomName(for uomid: Int32, completion: @escaping (ResultType<String?, FirebaseError>)->Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                for snapUom in snapUoms {
                    if let id = Int32(snapUom.key), let uomDict = snapUom.value as? Dictionary<String, Any> {
                        guard let name = uomDict["name"] as? String else { return }
                        
                        if id == uomid {
                            completion(ResultType.success(name))
                        }
                    }
                }
                completion(ResultType.success(nil))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func getUomList(completion: @escaping (ResultType<[FBUomModel]?, FirebaseError>)->Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                let fbUoms = FirebaseParser.transfromToFBUomModels(from: snapUoms)
                completion(ResultType.success(fbUoms))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func getCategoryList(completion: @escaping (ResultType<[FBItemCategory]?, FirebaseError>)->Void) {
        self.refCategories?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                let fbCategories:[FBItemCategory] = snapCategories.map { (snapCategory) in
                    return FirebaseParser.parseCategory(from: snapCategory)
                }
                completion(ResultType.success(fbCategories))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    

}


extension FirebaseService {
    
    // MARK: Work ==========================
    func getProduct(with productId: String, callback: @escaping (FBProductModel?) -> Void) {
        self.refGoods.observeSingleEvent(of: .value) { (snapshot) in
            guard let snap = snapshot.value as? [String: Any] else { fatalError() }
            
            let goods = snap.map { FirebaseParser.parseToFbProductModel(from: $0) }.filter { $0.id == productId }
            
            guard !goods.isEmpty else {
                callback(nil)
                return
            }
            callback(goods.first)
        }
    }
    
    
    
    func getFiltredProductList(with searchedText: String, completion: @escaping (ResultType<[FBProductModel], FirebaseError>)->Void) {
        self.refGoods.observeSingleEvent(of: .value, with: { snapshot in
            if let snapGoods = snapshot.value as? [String: Any] {
                let goods = snapGoods.map { FirebaseParser.parseToFbProductModel(from: $0) }
                completion(ResultType.success(goods))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    
    
    
    
    
    
    
    func getPrice(with productId: String, outletId: String, callback: @escaping (Double?) -> Void) {
        self.refPriceStatistics.observeSingleEvent(of: .value) { (snapshot) in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                let itemStatistics = snapPrices
                    .compactMap { FirebaseParser.parseToFBItemStatistic(from: $0) }
                    .filter { $0.outletId == outletId && $0.productId == productId }
                    .sorted { $0.date > $1.date }
                
                guard let stat = itemStatistics.first else {
                    callback(nil)
                    return
                }
                callback(stat.price)
            }
        }
    }
    
    
    func getPrices(for outletId: String, callback: @escaping ([FBItemStatistic]) -> Void) {
        refPriceStatistics.observeSingleEvent(of: .value, with: { snapshot in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                let itemStatistic = snapPrices
                    .compactMap { FirebaseParser.parseToFBItemStatistic(from: $0) }
                    .filter { $0.outletId == outletId }
                    .sorted { $0.date > $1.date }
                
                var uniqArrray: [FBItemStatistic] = []
                
                itemStatistic.forEach { (item) in
                    if !uniqArrray.contains(where: { $0.productId == item.productId }) {
                        uniqArrray.append(item)
                    }
                }
                callback(uniqArrray)
            }
        }) { error in
            fatalError(error.localizedDescription)
        }
    }
    
    func getPricesFor(_ productId: String, callback: @escaping ([FBItemStatistic]) -> Void) {
        refPriceStatistics.observeSingleEvent(of: .value, with: { snapshot in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                let itemStatistic = snapPrices
                    .compactMap { FirebaseParser.parseToFBItemStatistic(from: $0) }
                    .filter { $0.productId == productId }
                    .sorted { $0.date > $1.date }
                
                var uniqArray: [FBItemStatistic] = []
                
                for item in itemStatistic {
                    if !uniqArray.contains(where: { $0.outletId == item.outletId }) {
                        uniqArray.append(item)
                    }
                }
                callback(uniqArray)
            }
        }) { error in
            fatalError(error.localizedDescription)
        }
    }
    
    
}









