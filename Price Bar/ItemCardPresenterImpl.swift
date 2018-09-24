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
    case other(String)
    
    var errorDescription: String {
        // TODO: localize it
        switch self {
        case .priceIsNotSaved:
            return "Price is not saved"
        default:
            return R.string.localizable.error_something_went_wrong()
        }
    }
    
}

protocol ItemCardDelegate: class {
    func savedItem(productId: String)
}

protocol ItemCardPresenter {
    func onCategoryPressed(currentCategory: String)
    func onUomPressed(currentUom: String)
    func onUpdateOrCreateProduct(productCard: ProductCardEntity, for outletId: String)
    func onGetCardInfo(productId: String, outletId: String)
}

class ItemCardPresenterImpl: ItemCardPresenter {
    weak var view: ItemCardView!
    var productModel: ProductModel!
    var router: ItemCardRouter!
    var pickerType: PickerType = .category
    var oldPrice: Double = 0.0
    weak var delegate: ItemCardDelegate?
    
    func onGetCardInfo(productId: String, outletId: String) {
        self.view.showLoading(with: R.string.localizable.common_get_product_info())
        productModel.getItem(with: productId) { (dpProduct) in
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
                
                self.productModel.getPrice(for: dpProduct.id, and: outletId, completion: { (price) in
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
        self.productModel.getCategoryName(for: categoryId) { (result) in
            switch result {
            case let .success(categoryName):
                self.productModel.getUomName(for: uomId, completion: { (result) in
                    switch result {
                    case let .success(uomName):
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
        self.productModel.getCategoryId(for: categoryName) { (result) in
            switch result {
            case let .success(categoryId):
                guard let categoryId = categoryId else {
                    fatalError()
                }
                self.productModel.getUomId(for: uomName, completion: { (result) in
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
//        var productId = productCard.productId
        
//        if productId.isEmpty {
//            productId = UUID().uuidString
//        }
        
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
            
            let dpProductCardModel = ProductEntity(id: productCard.productId,
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
            
            let priceStatistic = PriceStatisticViewItem(outletId: outletId,
                                                       productId: productCard.productId,
                                                       newPrice: newPrice,
                                                       oldPrice: oldPrice,
                                                       date: Date())
            
            self.savePrice(for: productCard.productId, statistic: priceStatistic, completion: { (result) in
                switch result {
                case let .failure(error):
                    switch error {
                    case .priceIsNotSaved:
                        self.view.close()
                        self.delegate?.savedItem(productId: productCard.productId)
                    default:
                        self.view.onError(with: error.errorDescription)
                    }
                case .success:
                    self.view.close()
                    self.delegate?.savedItem(productId: productCard.productId)
                }
            })
            
        }
    }
    
    
    private func saveProduct(product: ProductEntity) {
        self.productModel.save(new: product)
    }
    
    private func savePrice(for productId: String, statistic: PriceStatisticViewItem, completion: (ResultType<Bool, ItemCardError>) -> Void) {
        guard statistic.newPrice != 0.0 else {
            completion(ResultType.failure(ItemCardError.priceIsNotSaved(R.string.localizable.price_update_not_changed())))
            return
        }
        guard statistic.newPrice != statistic.oldPrice else {
            completion(ResultType.failure(ItemCardError.priceIsNotSaved(R.string.localizable.price_update_not_changed())))
            return
        }
        
        completion(ResultType.success(true))
        self.productModel.savePrice(for: productId, statistic: statistic)
    }
    
    func onCategoryPressed(currentCategory: String) {
        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .category
        
        // TODO: localize it
        self.view.showLoading(with: "Получаем список категорий")
        productModel.getCategoryList { [weak self] (result) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            switch result {
            case let .success(dpCategoryList):
                guard !dpCategoryList.isEmpty else {
                    // TODO: localize it
                    self.view.onError(with: "Cloud category list is empty")
                    return
                }
                let categories: [CategoryViewItem] = dpCategoryList.map { CategoryMapper.transform(input: $0) }
                for (index, category) in categories.enumerated() {
                    if category.name == currentCategory {
                        curentIndex = index
                    }
                    pickerData.append(PickerData(id: category.id, name: category.name))
                }
                self.router.openPickerController(presenter: self, currentIndex: curentIndex, dataSource: pickerData)
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }
    
    func onUomPressed(currentUom: String) {
        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .uom
        // TODO: localize it
        self.view.showLoading(with: "Получаем список ед.измерений")
        productModel.getUomList { [weak self] (result) in
            guard let `self` = self else { return }
            
            self.view.hideLoading()
            switch result {
            case let .success(dpUomList):
                guard let dpUomList = dpUomList else {
                    // TODO: localize it
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
                self.view.onError(with: error.errorDescription)
            }
        }
    }
}


extension ItemCardPresenterImpl: PickerControlDelegate {
    func choosen(id: Int32) {
        if pickerType == .category {
            self.productModel.getCategoryName(for: id) { (result) in
                switch result {
                case let .success(name):
                    self.view.onCategoryChoosen(name: name)
                case let .failure(error):
                    self.view.onError(with: error.errorDescription)
                }
            }
        } else {
            self.productModel.getUomName(for: id) { (result) in
                switch result {
                case let .success(name):
                    self.view.onUomChoosen(name: name)
                case let .failure(error):
                    self.view.onError(with: error.errorDescription)
                }
            }
            
        }
    }
}



