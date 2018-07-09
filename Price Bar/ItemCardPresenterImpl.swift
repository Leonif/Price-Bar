//
//  ItemCardPresenterImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


enum PickerType {
    case category, uom
}

enum ItemCardError: Error {
    case priceIsNotSaved(String)
}


protocol ItemCardPresenter {
 
    func onCategoryPressed(currentCategory: String)
    func onUomPressed(currentUom: String)
    func onUpdateOrCreateProduct(productCard: ProductCardEntity, for outletId: String)
    func onGetCardInfo(productId: String, outletId: String)
    
}

class ItemCardPresenterImpl: ItemCardPresenter {
    weak var view: ItemCardView!
    var repository: Repository!
    var router: ItemCardRouter!
    var pickerType: PickerType = .category
    var oldPrice: Double = 0.0
    
    func onGetCardInfo(productId: String, outletId: String) {
        self.view.showLoading(with: R.string.localizable.common_get_product_info())
        repository.getItem(with: productId, and: outletId) { (dpProduct) in
            guard let dpProduct = dpProduct else {
                self.combineGetForCategoryNamendUomName(categoryId: 1, uomId: 1, completion: { (categoryName, uomName, error) in
                    self.view.hideLoading()
                    if let error = error {
                        self.view.onError(with: error.localizedDescription)
                        return
                    }
                    
                    let product = ProductCardEntity(productId: productId,
                                                    productName: "",
                                                    brand: "",
                                                    weightPerPiece: "",
                                                    categoryName: categoryName ?? "",
                                                    newPrice: "\(0.0)",
                        oldPrice: "\(0.0)",
                        uomName: uomName ?? "")
                    
                    self.view.onCardInfoUpdated(productCard: product)
                })
                return
            }
            
            self.combineGetForCategoryNamendUomName(categoryId: dpProduct.categoryId, uomId: dpProduct.uomId, completion: { (categoryName, uomName, error) in
                if let error = error {
                    self.view.hideLoading()
                    self.view.onError(with: error.localizedDescription)
                    return
                }
                
                guard
                    let categoryName = categoryName,
                    let uomName = uomName else {
                        self.view.hideLoading()
                        self.view.onError(with: R.string.localizable.error_something_went_wrong())
                        return
                }
                
                self.repository.getPrice(for: dpProduct.id, and: outletId, completion: { (price) in
                    self.view.hideLoading()
                    let product = ProductCardEntity(productId: dpProduct.id,
                                                        productName: dpProduct.name,
                                                        brand: dpProduct.brand,
                                                        weightPerPiece: dpProduct.weightPerPiece,
                                                        categoryName: categoryName,
                                                        newPrice: "\(price)",
                        oldPrice: "\(price)",
                        uomName: uomName)
                    self.view.onCardInfoUpdated(productCard: product)
                })
            })
        }
    }
    
    private func combineGetForCategoryNamendUomName(categoryId: Int32, uomId: Int32, completion: @escaping (String?, String?, Error?) -> Void) {
        self.repository.getCategoryName(for: categoryId) { (result) in
            switch result {
            case let .success(categoryName):
                guard let categoryName = categoryName else {
                    fatalError()
                }
                self.repository.getUomName(for: uomId, completion: { (result) in
                    switch result {
                    case let .success(uomName):
                        guard let uomName = uomName else {
                            fatalError()
                        }
                        completion(categoryName, uomName, nil)
                    case let .failure(error):
                        completion(categoryName, nil, error)
                    }
                })
            case let .failure(error):
                completion(nil, nil, error)
            }
        }
    }
    
    
    
    
    private func combineGetForCategoryIdAndUomId(categoryName: String, uomName: String, completion: @escaping (Int?, Int?, Error?) -> Void) {
        self.repository.getCategoryId(for: categoryName) { (result) in
            switch result {
            case let .success(categoryId):
                guard let categoryId = categoryId else {
                    fatalError()
                }
                self.repository.getUomId(for: uomName, completion: { (result) in
                    switch result {
                    case let .success(uomId):
                        guard let uomId = uomId else {
                            fatalError()
                        }
                        completion(categoryId, uomId, nil)
                    case let .failure(error):
                        completion(categoryId, nil, error)
                    }
                })
            case let .failure(error):
                completion(nil, nil, error)
            }
        }
    }
    
    
    
    func onUpdateOrCreateProduct(productCard: ProductCardEntity, for outletId: String) {
        guard !productCard.productName.isEmpty else {
            self.view.onError(with: R.string.localizable.empty_product_name())
            return
        }
        
        var productId = productCard.productId
        
        if productId.isEmpty {
            productId = UUID().uuidString
        }
        
        self.combineGetForCategoryIdAndUomId(categoryName: productCard.categoryName, uomName: productCard.uomName) { (categoryId, uomId, error) in
            if let error = error {
                self.view.onError(with: error.localizedDescription)
                return
            }
            guard
                let categoryId = categoryId,
                let uomId = uomId else {
                    self.view.onError(with: R.string.localizable.error_something_went_wrong())
                    return
            }
            
            let dpProductCardModel = DPUpdateProductModel(id: productId,
                                                          name: productCard.productName,
                                                          brand: productCard.brand,
                                                          weightPerPiece: productCard.weightPerPiece,
                                                          categoryId: Int32(categoryId),
                                                          uomId: Int32(uomId))
            
            self.saveProduct(product: dpProductCardModel)
            
            guard let newPrice = productCard.newPrice.numberFormatting() else {
                self.view.onError(with: "Price is not save")
                return
            }
            
            guard let oldPrice = productCard.oldPrice.numberFormatting() else {
                self.view.onError(with: "Price is not save")
                return
            }
            
            let priceStatistic = DPPriceStatisticModel(outletId: outletId,
                                                       productId: productId,
                                                       newPrice: newPrice,
                                                       oldPrice: oldPrice,
                                                       date: Date())
            
            //self.savePrice(for: productId, statistic: priceStatistic, completion: ())
            self.savePrice(for: productId, statistic: priceStatistic, completion: { (result) in
                switch result {
                case let .failure(error):
                    self.view.onError(with: error.localizedDescription)
                case .success:
                    self.view.close()
                }
            })
            
        }
    }
    
    
    private func saveProduct(product: DPUpdateProductModel) {
        self.repository.save(new: product)
    }
    
    
    
    private func savePrice(for productId: String, statistic: DPPriceStatisticModel, completion: (ResultType<Bool, ItemCardError>) -> Void) {
        guard statistic.newPrice != 0.0 else {
            completion(ResultType.failure(ItemCardError.priceIsNotSaved(R.string.localizable.price_update_not_changed())))
            return
        }
        guard statistic.newPrice != statistic.oldPrice else {
            completion(ResultType.failure(ItemCardError.priceIsNotSaved(R.string.localizable.price_update_not_changed())))
            return
        }
        
        completion(ResultType.success(true))
        self.repository.savePrice(for: productId, statistic: statistic)
    }
    
    
    
    
    func onCategoryPressed(currentCategory: String) {

        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .category
        
        //load categories
        repository.getCategoryList { (result) in
            switch result {
            case let .success(dpCategoryList):
                guard let dpCategoryList = dpCategoryList else {
                    self.view.onError(with: "Cloud category list is empty")
                    return
                }
                
                let categories = dpCategoryList.map { CategoryMapper.mapper(from: $0) }
                for (index, category) in categories.enumerated() {
                    if category.name == currentCategory {
                        curentIndex = index
                    }
                    pickerData.append(PickerData(id: category.id, name: category.name))
                }
                self.router.openPickerController(presenter: self, currentIndex: curentIndex, dataSource: pickerData)
            case let .failure(error):
                self.view.onError(with: error.message)
            }
        }
    }
    
    func onUomPressed(currentUom: String) {
        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .uom
        
        repository.getUomList { (result) in
            switch result {
            case let .success(dpUomList):
                guard let dpUomList = dpUomList else {
                    self.view.onError(with: "Cloud category list is empty")
                    return
                }
                for (index, uom) in dpUomList.enumerated() {
                    if uom.name == currentUom {
                        curentIndex = index
                    }
                    pickerData.append(PickerData(id: uom.id, name: uom.name))
                }
                
                self.router.openPickerController(presenter: self, currentIndex: curentIndex, dataSource: pickerData)
            case let .failure(error):
                self.view.onError(with: error.message)
            }
        }
    }
}


extension ItemCardPresenterImpl: PickerControlDelegate {
    func choosen(id: Int32) {
        if pickerType == .category {
            self.repository.getCategoryName(for: id) { (result) in
                switch result {
                case let .success(name):
                    guard let name = name else {
                        self.view.onError(with: R.string.localizable.error_something_went_wrong())
                        return
                    }
                    self.view.onCategoryChoosen(name: name)
                case let .failure(error):
                    self.view.onError(with: error.message)
                }
            }
        } else {
            self.repository.getUomName(for: id) { (result) in
                switch result {
                case let .success(name):
                    guard let name = name else {
                        self.view.onError(with: R.string.localizable.error_something_went_wrong())
                        return
                    }
                    self.view.onUomChoosen(name: name)
                case let .failure(error):
                    self.view.onError(with: error.message)
                }
            }
            
        }
    }
}



