//
//  FirebaseService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import Firebase


typealias BackendResult<T> = ResultType<T, BackendError>

enum BackendError: Error {
    case loginError(String)
    case syncError(String)
    case dataIsNotFound(String)
}

protocol BackEndInterface {
    func login(completion: @escaping (BackendResult<Void>) -> Void)
    func getProductList(with pageOffset: Int, limit: Int, completion: @escaping (BackendResult<[ProductEntity]>) -> Void)
    func getProductCount(completion: @escaping (BackendResult<Int>) -> Void)
    func getParametredUom(for uomId: Int32, completion: @escaping (BackendResult<UomEntity>) -> Void)
    
    func savePrice(for productId: String, statistic: PriceItemEntity)
    func saveOrUpdate(_ item: ProductEntity)
    
    func getCategoryId(for categoryName: String, completion: @escaping (BackendResult<Int?>) -> Void)
    func getCategoryName(for categoryId: Int32, completion: @escaping (BackendResult<String>) -> Void)
    
    func getUomId(for uomName: String, completion: @escaping (BackendResult<Int?>) -> Void)
    func getUomName(for uomid: Int32, completion: @escaping (BackendResult<String?>) -> Void)
 
    func getUomList(completion: @escaping (BackendResult<[UomEntity]?>) -> Void)
    func getCategoryList(completion: @escaping (BackendResult<[CategoryEntity]?>) -> Void)
    func getProduct(with productId: String, callback: @escaping (ProductEntity?) -> Void)
    func getFiltredProductList(with searchedText: String, completion: @escaping (BackendResult<[ProductEntity]>) -> Void)
    func getLastPrice(with productId: String, outletId: String, callback: @escaping (Double?) -> Void)
    func getCountry(for productId: String, completion: @escaping (String?) -> Void)
    func getPricesFor(_ productId: String, callback: @escaping ([PriceItemEntity]) -> Void)
}


class FirebaseService: BackEndInterface {
    private var refGoods = Database.database().reference().child("goods")

    private var refPriceStatistics: DatabaseReference

    private var refCategories: DatabaseReference?
    private var refUoms: DatabaseReference?
    private var refUomsParams: DatabaseReference?
    private var refBarcodeInfo: DatabaseReference?

    private var email = "good_getter@gmail.com"
    private var pwd = "123456"

    var goodCurrentId: String?

    init() {
        refGoods = Database.database().reference().child("goods")

        #if DEVELOPMENT
            let statistics = "price_statistics_dev"
        #else
            let statistics = "price_statistics_fq"
        #endif
        debugPrint(statistics)
        refPriceStatistics = Database.database().reference().child(statistics)

        refCategories = Database.database().reference().child("categories")
        refUoms = Database.database().reference().child("uoms")
        refUomsParams = Database.database().reference().child("uoms").child("parameters")
        refBarcodeInfo = Database.database().reference().child("barcode_info")

        email = "good_getter@gmail.com"
        pwd = "123456"
    }

    func login(completion: @escaping (BackendResult<Void>) -> Void) {
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
            completion(ResultType.success(()))
            print("Email authorization is successful!")
        })
    }

    // FIXME: PAGINATION: WORKS WRONG !!!! ===========================================
    func getProductList(with pageOffset: Int, limit: Int, completion: @escaping (BackendResult<[ProductEntity]>) -> Void) {
        if pageOffset == 0 {
            self.refGoods.queryOrderedByKey().queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { snapshot in
                if let snapGoods = snapshot.value as? [String: Any] {
                    let goods = snapGoods.map { FirebaseParser.parse(from: $0) }
                    self.goodCurrentId = goods.first?.productId
                    completion(ResultType.success(goods))
                }
            }) { error in
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        } else {
            self.refGoods.queryOrderedByKey().queryEnding(atValue: self.goodCurrentId).queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { snapshot in
                if let snapGoods = snapshot.value as? [String: Any] {
                    let goods = snapGoods.map { FirebaseParser.parse(from: $0) }
                    if self.goodCurrentId != goods.first?.productId {
                        self.goodCurrentId = goods.first?.productId
                        goods.forEach { print("\($0.productId) \($0.name)") }
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
    func getProductCount(completion: @escaping (BackendResult<Int>) -> Void) {
        self.refGoods
            .observeSingleEvent(of: .value,
                                with: { snapshot in
                                    completion(ResultType.success(Int(snapshot.childrenCount))) },
                                withCancel: { error in
                                    let result: BackendResult<Int> = ResultType.failure(.syncError(error.localizedDescription))
                                    completion(result)})
    }

    func getParametredUom(for uomId: Int32, completion: @escaping (BackendResult<UomEntity>) -> Void) {
        self.refUoms?.child("\(uomId)").makeObjectRequest { (entity: UomEntity?) in
            guard let entity = entity else {
                completion(ResultType.failure(.dataIsNotFound("Uom is not found")))
                return
            }
            completion(ResultType.success(entity))
        }
    }

    func saveOrUpdate(_ item: ProductEntity) {
        let good: [String: Any] = [
            "barcode": item.productId,
            "name": item.name,
            "brand": item.brand ?? "",
            "weight_per_piece": item.weightPerPiece ?? "",
            "category_id": item.categoryId ?? 1,
            "uom_id": item.uomId ?? 1
        ]
        refGoods.child(item.productId).setValue(good)

    }

    func savePrice(for productId: String, statistic: PriceItemEntity) {
        let priceStat: [String: Any] = [
            "date": statistic.date!.getString(format: "dd.MM.yyyy hh:mm:ss"),
            "outlet_id": statistic.outletId,
            "price": statistic.price
            ]

        refPriceStatistics.child(productId).childByAutoId().setValue(priceStat)
    }

    func getCategoryId(for categoryName: String, completion: @escaping (BackendResult<Int?>) -> Void) {
        self.refCategories?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                for snapCategory in snapCategories {
                    if let categoryId = Int32(snapCategory.key),
                        let categoryDict = snapCategory.value as? [String: Any] {
                        guard let name = categoryDict["name"] as? String else { return }

                        if name == categoryName {
                            completion(ResultType.success(Int(categoryId)))
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

    func getCategoryName(for categoryId: Int32, completion: @escaping (BackendResult<String>) -> Void) {
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

    func getUomId(for uomName: String, completion: @escaping (BackendResult<Int?>) -> Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                for snapUom in snapUoms {
                    if let id = Int32(snapUom.key),
                        let uomDict = snapUom.value as? Dictionary<String, Any> {
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

    func getUomName(for uomid: Int32, completion: @escaping (BackendResult<String?>) -> Void) {
        self.refUoms?.child("\(uomid)").makeObjectRequest { (entity: UomEntity?) in
            completion(ResultType.success(entity?.name))
        }
    }

    func getUomList(completion: @escaping (BackendResult<[UomEntity]?>) -> Void) {
        self.refUoms?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapUoms = snapshot.children.allObjects as? [DataSnapshot] {
                let fbUoms = FirebaseParser.parse(from: snapUoms)
                completion(ResultType.success(fbUoms))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }

    func getCategoryList(completion: @escaping (BackendResult<[CategoryEntity]?>) -> Void) {
        self.refCategories?.observeSingleEvent(of: .value, with: { snapshot in
            if let snapCategories = snapshot.children.allObjects as? [DataSnapshot] {
                let fbCategories: [CategoryEntity] = snapCategories.map { (snapCategory) in
                    return FirebaseParser.parse(from: snapCategory)
                }
                completion(ResultType.success(fbCategories))
            }
        }) { error in
            completion(ResultType.failure(.syncError(error.localizedDescription)))
        }
    }

    func getProduct(with productId: String, callback: @escaping (ProductEntity?) -> Void) {
        self.refGoods.child(productId).makeObjectRequest { (product: ProductEntity? ) in
            callback(product)
        }
    }

    func getFiltredProductList(with searchedText: String, completion: @escaping (BackendResult<[ProductEntity]>) -> Void) {
        self.refGoods.makeArrayRequest { (list: [ProductEntity]) in
            let goods = list
                .filter {
                    $0.fullName.lowercased()
                        .range(of: searchedText.lowercased()) != nil
            }
            completion(ResultType.success(goods))
        }
    }

    func getLastPrice(with productId: String, outletId: String, callback: @escaping (Double?) -> Void) {
        self.refPriceStatistics.child(productId).makeArrayRequest { (priceList: [PriceItemEntity]) in
            let lastPrice = priceList
                .filter { $0.outletId == outletId }
                .sorted { $0.date! > $1.date! }.first?.price
            callback(lastPrice)
        }
    }

    func getCountry(for productId: String, completion: @escaping (String?) -> Void) {
        var country = "manually inserted"
        guard productId.isContains(type: .digit) else {
            completion(country)
            return
        }
        let mutableProductId = productId.dropFirst(contains: "0")
        var isFound = false
        
        self.refBarcodeInfo?.makeArrayRequest(completion: { (bounds: [BarcodeBounds]) in
            for bound in bounds {
                guard let min = Int(bound.lower), let max = Int(bound.upper) else {
                    break
                }
                guard let codeAdjusted = Int(mutableProductId.prefix(bound.lower.count)) else {
                    break
                }
                if min <= codeAdjusted && codeAdjusted <= max {
                    isFound = true
                    country = bound.country
                    break
                }
            }
            let countryCode = String(productId.prefix(3))
            completion(isFound ? country : "not found: \(countryCode)")
        })
    }
    func getPricesFor(_ productId: String, callback: @escaping ([PriceItemEntity]) -> Void) {
        self.refPriceStatistics.child(productId).makeArrayRequest { (priceList: [PriceItemEntity]) in
            let uniqArray: [PriceItemEntity] = priceList.uniq
            callback(uniqArray)
        }
    }
}
