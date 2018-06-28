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



protocol ItemCardPresenter {
 
    func onCategoryPressed(currentCategory: String)
    func onUomPressed(currentUom: String)
    func onUpdateOrCreateProduct(productCard: ProductCardViewEntity)
    
}

class ItemCardPresenterImpl: ItemCardPresenter {
    weak var view: ItemCardView!
    var repository: Repository!
    var router: ItemCardRouter!
    var pickerType: PickerType = .category
    
    
    private func getIdsForCategoryAndUom(categoryName: String, uomName: String, completion: @escaping (Int?, Int?, Error?) -> Void) {
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
    
    
    
    func onUpdateOrCreateProduct(productCard: ProductCardViewEntity, for outletId: String) {
        guard !productCard.productName.isEmpty else {
            self.view.onError(with: R.string.localizable.empty_product_name())
        }
        
        var productId = productCard.productId
        
        if productId.isEmpty {
            productId = UUID().uuidString
        }
        
        
        
                let dpProductCardModel = DPUpdateProductModel(id: productId,
                                                              name: productCard.productName,
                                                              brand: productCard.brand,
                                                              weightPerPiece: productCard.weightPerPiece,
                                                              categoryId: Int32(categoryId),
                    uomId: productCard.uomId)
                
                
                
                self.saveProduct(dpProductCardModel)
                
                
                
                let priceStatistic = DPPriceStatisticModel(outletId: outletId, productId: productCard, price: <#T##Double#>, date: <#T##Date#>)
                
                
                
                self.saveStatistic(statistic: <#T##DPPriceStatisticModel#>)
                
                
                // define is ths product exists by id
                // if yeas - update
                //else create
                
                // save statistic
                
                
                
            case let .failure(error):
                
                
                
            }
        }
        
        
    }
    
    
    private func saveProduct(product: DPUpdateProductModel) {
        self.repository.save(new: product)
    }
    
    
    
    private func saveStatistic(statistic: DPPriceStatisticModel) {
        
        guard statistic.price != 0.0 else {
            self.view.onError(with: R.string.localizable.price_update_not_changed())
        }
        
        
        
        
        if let priceStr = itemPrice.text,
            let price = priceStr.numberFormatting(),
            price != 0.0 {
            
            guard productCard.productPrice != price  else {
                alert(title: R.string.localizable.thank_you(),
                      message: R.string.localizable.price_update_not_changed(), okAction: {
                        self.close()
                })
                return
            }
            
            let dpStatModel = DPPriceStatisticModel(outletId: outletId,
                                                    productId: productCard.productId,
                                                    price: price, date: Date())
            repository.save(new: dpStatModel)
            delegate.productUpdated()
            self.close()
            
        } else {
            alert(title: R.string.localizable.thank_you(),
                  message: R.string.localizable.update_price_we_cant_update(), okAction: {
                    self.close()
            })
        }
    }
    
    private saveStatistic() {
    
    
    
    }
    
    
    func onCategoryPressed(currentCategory: String) {

        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .category
        
        //load categories
        guard let dpCategoryList = repository.getCategoryList() else {
            fatalError("Category list is empty")
        }
        
        let categories = dpCategoryList.map { CategoryMapper.mapper(from: $0) }
        
        
        for (index, category) in categories.enumerated() {
            if category.name == currentCategory {
                curentIndex = index
            }
            pickerData.append(PickerData(id: category.id, name: category.name))
        }
        self.router.openPickerController(presenter: self, currentIndex: curentIndex, dataSource: pickerData)
    }
    
    func onUomPressed(currentUom: String) {
        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .uom
        
        guard let dpUomList = repository.getUomList() else {
            fatalError("Category list is empty")
        }
        
        for (index, uom) in dpUomList.enumerated() {
            if uom.name == currentUom {
                curentIndex = index
            }
            pickerData.append(PickerData(id: uom.id, name: uom.name))
        }
        
        self.router.openPickerController(presenter: self, currentIndex: curentIndex, dataSource: pickerData)
    }
    
}


extension ItemCardPresenterImpl: PickerControlDelegate {
    func choosen(id: Int32) {
        if pickerType == .category {
            guard let name = repository.getCategoryName(category: id) else { return }
            self.view.onCategoryChoosen(name: name)
        } else {
            guard let name = repository.getUomName(for: id) else { return }
            self.view.onUomChoosen(name: name)
            
        }
    }
}



