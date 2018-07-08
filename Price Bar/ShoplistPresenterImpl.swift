//
//  ShoplistInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import GooglePlaces

protocol ShoplistPresenter: OutletListOutput, UpdatePriceOutput, ScannerOutput, ItemListOutput {
    func isProductHasPrice(for productId: String, in outletId: String)
    func addToShoplist(with productId: String, and outletId: String)
    func updateCurrentOutlet()
    
    func onOpenStatistics()
    func onOpenUpdatePrice(for barcode: String, outletId: String)
    func onOpenIssueVC(with issue: String)
    func onOpenItemCard(for item: ShoplistItem, with outletId: String)
    func onOpenNewItemCard(for productId: String, outletId: String)
    func onOpenScanner()
    func onOpenItemList(for outletId: String)
    func onOpenOutletList()
    func onReloadShoplist(for outletId: String)
    func onCleanShopList()
    func onRemoveItem(productId: String)
    func onQuantityChanged(productId: String)
}

public final class ShoplistPresenterImpl: ShoplistPresenter {
    weak var view: ShoplistView!
    var router: ShoplistRouter!
    var repository: Repository!
    var isStatisticShown: Bool = false
    
    public func updateCurrentOutlet() {
        let outletService = OutletService()
        outletService.nearestOutlet { result in
            switch result {
            case let .success(outlet):
                let outlet = OutletMapper.mapper(from: outlet)
                self.view.onCurrentOutletUpdated(outlet: outlet)
                self.updateShoplist()
            case let .failure(error):
                self.view.onError(error: error.errorDescription)
            }
        }
    }
    
    private func updateShoplist() {
        let dataSource = self.repository.shoplist
        self.view.onUpdatedShoplist(dataSource)
        self.view.onUpdatedTotal(self.repository.total)
    }
    
    func addToShoplist(with productId: String, and outletId: String) {
        self.view.showLoading(with: R.string.localizable.getting_actual_price())
        repository.getItem(with: productId, and: outletId) { [weak self] (product) in
            guard let product = product else {
                self?.view.onProductIsNotFound(productId: productId)
                return
            }
            guard let `self` = self else { return }
            
            self.addItemToShopList(product, and: outletId, completion: { result in
                self.view.hideLoading()
                switch result {
                case let .failure(error):
                    self.view.onError(error: error.message)
                case .success:
                    self.updateShoplist()
                }
            })
        }
    }
    
    private func addItemToShopList(_ product: DPProductEntity, and outletId: String, completion: @escaping (ResultType<Bool, RepositoryError>)-> Void) {
        
        repository.getPrice(for: product.id, and: outletId) { [weak self] (price) in
            guard let `self` = self else { return }
            
            
            self.repository.getCategoryName(for: product.categoryId, completion: { (result) in
                switch result {
                case let .success(categoryName):
                    
                    guard let categoryName = categoryName else {
                        completion(ResultType.failure(RepositoryError.other(R.string.localizable.error_something_went_wrong())))
                        return
                    }
                    
                    
                    self.repository.getParametredUom(for: product.uomId, completion: { (fbUom) in
                            let result = self.repository.saveToShopList(new: ShoplistItem(productId: product.id,
                                                                                          productName: product.name,
                                                                                          brand: product.brand,
                                                                                          weightPerPiece: product.weightPerPiece,
                                                                                          categoryId: product.categoryId,
                                                                                          productCategory: categoryName,
                                                                                          productPrice: price,
                                                                                          uomId: product.uomId,
                                                                                          productUom: fbUom.name, quantity: 1.0, parameters: fbUom.parameters))
                            switch result {
                            case let .failure(error):
                                completion(ResultType.failure(error))
                            case .success:
                                completion(ResultType.success(true))
                            }
                    })
                case let .failure(error):
                    completion(ResultType.failure(error))
                }
            })
        }
    }
    
    func isProductHasPrice(for productId: String, in outletId: String) {
        self.repository.getPrice(for: productId, and: outletId, completion: { [weak self] (price) in
            self?.view.onIsProductHasPrice(isHasPrice: price > 0.0, barcode: productId)
        })
    }
    
    
    
    
    
    func onReloadShoplist(for outletId: String) {
        
        let loadingString = R.string.localizable.common_loading()
        let message = R.string.localizable.sync_process_prices(loadingString)
        
        self.view.showLoading(with: message)
        
        self.repository.loadShopList { (shoplistWithoutPrices) in
            var shoplistWithPrices: [ShoplistItem] = shoplistWithoutPrices
            let dispatchGroup = DispatchGroup()
            shoplistWithoutPrices.forEach {
                dispatchGroup.enter()
                guard let index = shoplistWithPrices.index(of: $0) else { fatalError() }
                self.repository.getPrice(for: $0.productId, and: outletId, completion: { (price) in
                    shoplistWithPrices[index].productPrice = price
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main) {
                self.view.hideLoading()
                self.repository.shoplist = shoplistWithPrices
                self.updateShoplist()
                if !self.isStatisticShown {
                    self.view.startIsCompleted()
                    self.isStatisticShown = true
                }
            }
        }
    }
    
    func onOpenStatistics() {
        self.router.openStatistics()
    }
    
    func onOpenIssueVC(with issue: String) {
        self.router.openIssue(with: issue)
    }
    
    func onOpenItemCard(for item: ShoplistItem, with outletId: String) {
        self.router.openItemCard(for: item.productId, outletId: outletId)
    }
    
    func onOpenScanner() {
        self.router.openScanner(presenter: self)
    }
    
    func onOpenItemList(for outletId: String) {
        self.router.openItemList(for: outletId, presenter: self)
    }
    
    func onOpenOutletList() {
        self.router.openOutletList(presenter: self)
    }
    
    func onOpenNewItemCard(for productId: String, outletId: String) {
        //TODO: need to implement
        self.router.openItemCard(for: productId, outletId: outletId)
    }
    
    func onCleanShopList() {
        self.repository.clearShoplist()
        self.updateShoplist()
    }
    
    func onQuantityChanged(productId: String) {
        
        var quantityEntity: QuantityModel = QuantityModel(parameters: [], currentValue: 0.0, answerDict: ["productId": productId])
        
        let currentValue = self.repository.getProductQuantity(productId: productId)
        quantityEntity.currentValue = currentValue
        
        repository.getProductEntity(for: productId) { (result) in
            switch result {
            case let .success(product):
                self.repository.getParametredUom(for: product.uomId) { (uomModel) in
                    quantityEntity.parameters = uomModel.parameters
                    self.router.openQuantityController(presenter: self, quantityEntity: quantityEntity)
                }
                
            case let .failure(error):
                self.view.onError(error: error.message)
            }
        }
    }
    
    
    func onRemoveItem(productId: String) {
        self.repository.remove(itemId: productId)
        self.updateShoplist()
    }
    
    func onOpenUpdatePrice(for barcode: String, outletId: String) {
        self.repository.getPrice(for: barcode, and: outletId, completion: { [weak self] (price) in
            guard let `self` = self else { return }
            self.router.openUpdatePrice(presenter: self, for: barcode, currentPrice: price, outletId: outletId)
        })
    }
    
    // MARK: delagates hadnling
    func choosen(outlet: Outlet) {
        self.view.onCurrentOutletUpdated(outlet: outlet)
    }
    
    func saved() {
        self.view.onSavePrice()
    }
    
    func scanned(barcode: String) {
        self.view.onAddedItemToShoplist(productId: barcode)
    }
    
    func itemChoosen(productId: String) {
        self.view.onAddedItemToShoplist(productId: productId)
    }
    
    func addNewItem(suggestedName: String) {
        // TODO: open new Item card with suggested name product
    }
    
}


extension ShoplistPresenterImpl: QuantityPickerPopupDelegate {
    func choosen(weight: Double, answer: [String : Any]) {
        guard let productId = answer["productId"] as? String else {
            return
        }
        repository.changeShoplistItem(weight, for: productId)
        self.view.onQuantityChanged()
        
    }
}
