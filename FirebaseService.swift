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
    private var refBarcodeInfo: DatabaseReference? = nil
    
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
        refBarcodeInfo = Database.database().reference().child("barcode_info")
        
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

    
    // FIXME: PAGINATION: WORKS WRONG !!!! ===========================================
    func getProductList(with pageOffset: Int, limit: Int, completion: @escaping (ResultType<[ProductEntity], FirebaseError>)->Void) {
        if pageOffset == 0 {
            self.refGoods.queryOrderedByKey().queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { snapshot in
                if let snapGoods = snapshot.value as? [String: Any] {
                    let goods = snapGoods.map { FirebaseParser.parseToFbProductModel(from: $0) }
                    
                    goods.forEach { print("\($0.id) \($0.name)") }
                    
                    self.goodCurrentId = goods.first?.id
                    completion(ResultType.success(goods))
                }
            }) { error in
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        } else {
            self.refGoods.queryOrderedByKey().queryEnding(atValue: self.goodCurrentId).queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { snapshot in
                if let snapGoods = snapshot.value as? [String: Any] {
                    let goods = snapGoods.map { FirebaseParser.parseToFbProductModel(from: $0) }
                    if self.goodCurrentId != goods.first?.id {
                        self.goodCurrentId = goods.first?.id
                        goods.forEach { print("\($0.id) \($0.name)") }
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
    // ===============================================================================================
    func getProductCount(completion: @escaping (ResultType<Int, FirebaseError>)->Void) {
        self.refGoods.observeSingleEvent(of: .value, with: { snapshot in
            completion(ResultType.success(Int(snapshot.childrenCount)))
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func getParametredUom(for uomId: Int32, completion: @escaping (ResultType<UomEntity, FirebaseError>)->Void) {
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
    
    func saveOrUpdate(_ item: ProductEntity) {
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

    func savePrice(for productId: String, statistic: PriceItemEntity) {
        let priceStat = [
            "date": statistic.date.getString(format: "dd.MM.yyyy hh:mm:ss"),
            "outlet_id": statistic.outletId,
            "price": statistic.price
            ] as [String: Any]
        
        refPriceStatistics.child(productId).childByAutoId().setValue(priceStat)
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
    
    func getCategoryName(for categoryId: Int32, completion: @escaping (ResultType<String, FirebaseError>)->Void) {
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
                completion(ResultType.failure(.syncError("No name")))
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
    
    func getUomName(for uomid: Int32, completion: @escaping (ResultType<String, FirebaseError>)->Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                for snapUom in snapUoms {
                    if let id = Int32(snapUom.key), let uomDict = snapUom.value as? Dictionary<String, Any> {
                        guard let name = uomDict["name"] as? String else { return }
                        
                        if id == uomid {
                            completion(ResultType.success(name))
                            return
                        }
                    }
                }
                completion(ResultType.failure(.syncError("No name")))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func getUomList(completion: @escaping (ResultType<[UomEntity]?, FirebaseError>)->Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                let fbUoms = FirebaseParser.transfromToFBUomModels(from: snapUoms)
                completion(ResultType.success(fbUoms))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    
    func getCategoryList(completion: @escaping (ResultType<[CategoryEntity]?, FirebaseError>)->Void) {
        self.refCategories?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                let fbCategories:[CategoryEntity] = snapCategories.map { (snapCategory) in
                    return FirebaseParser.parseCategory(from: snapCategory)
                }
                completion(ResultType.success(fbCategories))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }

    
    func getProduct(with productId: String, callback: @escaping (ProductEntity?) -> Void) {
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
    
    func getFiltredProductList(with searchedText: String, completion: @escaping (ResultType<[ProductEntity], FirebaseError>)->Void) {
        self.refGoods.observeSingleEvent(of: .value, with: { snapshot in
            if let snapGoods = snapshot.value as? [String: Any] {
                let goods = snapGoods
                    .map { FirebaseParser.parseToFbProductModel(from: $0) }
                    .filter { $0.fullName.lowercased().range(of: searchedText.lowercased()) != nil }
                completion(ResultType.success(goods))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }
    
    func getLastPrice(with productId: String, outletId: String, callback: @escaping (Double?) -> Void) {
        self.refPriceStatistics.child(productId)
            .observeSingleEvent(of: .value) { (snapshot) in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                let itemStatistics = snapPrices
                    .compactMap { FirebaseParser.parseToFBItemStatistic(from: $0) }
                    .filter { $0.outletId == outletId }
                    .sorted { $0.date > $1.date }
                
                guard let stat = itemStatistics.first else {
                    callback(nil)
                    return
                }
                callback(stat.price)
            }
        }
    }
    
    
    func getCountry(for productId: String, completion: @escaping (String?) -> Void) {
        var country = "Not defined"
        
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: productId)) else {
            completion(country)
            return
        }

        guard let countryCode = Int(productId.prefix(3)) else {
            completion(country)
            return
        }
        
        var isFound = false
        
        self.refBarcodeInfo?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let barcodeInfo = snapshot.children.allObjects as? [DataSnapshot] {
                
                for conditions in barcodeInfo {
                    if let conditions = conditions.value as? [String: Any] {
                        let lowerBound = conditions["lower_bound"] as! String
                        let upperBound = conditions["upper_bound"] as! String
                        
                        let min = Int(lowerBound)!
                        let max = Int(upperBound)!
                        
                        if min <= countryCode && countryCode <= max {
                            isFound = true
                            country = conditions["country"] as! String
                            break
                        }
                    }
                }
                completion(isFound ? country : "\(countryCode)")
            }
        })
    }
    
    func getPricesFor(_ productId: String, callback: @escaping ([PriceItemEntity]) -> Void) {
        self.refPriceStatistics.child(productId)
            .observeSingleEvent(of: .value, with: { snapshot in
            if let snapPrices = snapshot.children.allObjects as? [DataSnapshot] {
                let itemStatistic = snapPrices
                    .compactMap { FirebaseParser.parseToFBItemStatistic(from: $0) }
                    .sorted { $0.date > $1.date }
                
                var uniqArray: [PriceItemEntity] = []

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









