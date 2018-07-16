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
    func isProductHasPrice(for productId: String)
    func addToShoplist(with productId: String)
    func updateCurrentOutlet()
    
    func onOpenStatistics()
    func onOpenUpdatePrice(for barcode: String)
    func onOpenIssueVC(with issue: String)
    func onOpenItemCard(for item: ShoplistItem)
    func onOpenNewItemCard(for productId: String)
    func onOpenScanner()
    func onOpenItemList()
    func onOpenOutletList()
    func onReloadShoplist()
    func onCleanShopList()
    func onRemoveItem(productId: String)
    func onQuantityChanged(productId: String)
}

public final class ShoplistPresenterImpl: ShoplistPresenter {
    weak var view: ShoplistView!
    var router: ShoplistRouter!
    var repository: Repository!
    var isStatisticShown: Bool = false
    var userOutlet: Outlet!
    
    
    public func updateCurrentOutlet() {
        let outletService = OutletService()
        outletService.nearestOutlet { result in
            switch result {
            case let .success(outlet):
                self.userOutlet = OutletMapper.mapper(from: outlet)
                self.view.onCurrentOutletUpdated(outlet: self.userOutlet)
            case let .failure(error):
                self.view.onError(error: error.errorDescription)
            }
        }
    }
    
    private func updateShoplist(shoplist: [ShoplistItem]) {
        self.view.onUpdatedShoplist(shoplist)
        let sum = shoplist.reduce(0) { $0 + ($1.productPrice * $1.quantity) }
        self.view.onUpdatedTotal(sum)
    }
    
    func addToShoplist(with productId: String) {
        self.view.showLoading(with: R.string.localizable.getting_actual_price())
        repository.getItem(with: productId, and: self.userOutlet.id) { [weak self] (product) in
            self?.view.hideLoading()
            guard let product = product else {
                self?.view.onProductIsNotFound(productId: productId)
                return
            }
            guard let `self` = self else { return }
            
            self.addItemToShopList(product, completion: { result in
                switch result {
                case let .failure(error):
                    switch error {
                    case .alreadyAdded: break
                    default: self.view.onError(error: error.message)
                    }
                case .success:
                    self.onReloadShoplist()
                }
            })
        }
    }
    
    private func addItemToShopList(_ product: DPProductEntity, completion: @escaping (ResultType<Bool, RepositoryError>)-> Void) {
        
        repository.getPrice(for: product.id, and: self.userOutlet.id) { [weak self] (price) in
            guard let `self` = self else { return }
            
            
            self.repository.getCategoryName(for: product.categoryId, completion: { [weak self] (result) in
                switch result {
                case let .success(categoryName):
                    
                    guard let categoryName = categoryName else {
                        completion(ResultType.failure(RepositoryError.other(R.string.localizable.error_something_went_wrong())))
                        return
                    }
                    
                   
                    
                    self?.repository.getParametredUom(for: product.uomId, completion: { [weak self] (fbUom) in
                        guard let `self` = self else { return }
                        let newItem = ShoplistItem(productId: product.id,
                                                  productName: product.name,
                                                  brand: product.brand,
                                                  weightPerPiece: product.weightPerPiece,
                                                  categoryId: product.categoryId,
                                                  productCategory: categoryName,
                                                  productPrice: price,
                                                  uomId: product.uomId,
                                                  productUom: fbUom.name, quantity: 1.0, parameters: fbUom.parameters)
                        
                        
                        self.repository.saveToShopList(new: newItem) { (result) in
                            switch result {
                            case let .failure(error):
                                completion(ResultType.failure(error))
                            case .success:
                                completion(ResultType.success(true))
                            }
                        }
                    })
                case let .failure(error):
                    completion(ResultType.failure(error))
                }
            })
        }
    }
    
    func isProductHasPrice(for productId: String) {
        self.repository.getPrice(for: productId, and: self.userOutlet.id, completion: { [weak self] (price) in
            self?.view.onIsProductHasPrice(isHasPrice: price > 0.0, barcode: productId)
        })
    }
    
    
    
    
    func onReloadShoplist() {
        let loadingString = R.string.localizable.common_loading()
        let message = R.string.localizable.sync_process_prices(loadingString)
        self.view.showLoading(with: message)
        
        self.repository.loadShopList(for: self.userOutlet.id) { (shoplistWithPrices) in
            self.view.hideLoading()
            self.updateShoplist(shoplist: shoplistWithPrices)
            if !self.isStatisticShown {
                self.view.startIsCompleted()
                self.isStatisticShown = true
            }
        }
    }
    
    func onOpenStatistics() {
        self.router.openStatistics()
    }
    
    func onOpenIssueVC(with issue: String) {
        self.router.openIssue(with: issue)
    }
    
    func onOpenItemCard(for item: ShoplistItem) {
        self.router.openItemCard(presenter: self, for: item.productId, outletId: self.userOutlet.id)
    }
    
    func onOpenScanner() {
        self.router.openScanner(presenter: self)
    }
    
    func onOpenItemList() {
        self.router.openItemList(for: self.userOutlet.id, presenter: self)
    }
    
    func onOpenOutletList() {
        self.router.openOutletList(presenter: self)
    }
    
    func onOpenNewItemCard(for productId: String) {
        self.router.openItemCard(presenter: self, for: productId, outletId: self.userOutlet.id)
    }
    
    func onCleanShopList() {
        self.repository.clearShoplist()
        self.onReloadShoplist()
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
        
        self.onReloadShoplist()
    }
    
    func onOpenUpdatePrice(for barcode: String) {
        self.repository.getPrice(for: barcode, and: userOutlet.id, completion: { [weak self] (price) in
            guard let `self` = self else { return }
            self.router.openUpdatePrice(presenter: self, for: barcode, currentPrice: price, outletId: self.userOutlet.id)
        })
    }
    
    // MARK: delagates hadnling
    func choosen(outlet: Outlet) {
        self.userOutlet = outlet
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
        let productId = UUID().uuidString
        self.view.onAddedItemToShoplist(productId: productId)
    }
}

extension ShoplistPresenterImpl: ItemCardDelegate {
    func savedItem(productId: String) {
        self.onReloadShoplist()
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
