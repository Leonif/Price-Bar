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
    func openIssueVC(with issue: String)
    func onOpenItemCard(for item: ShoplistItem)
    func onOpenNewItemCard(for productId: String)
    func onOpenScanner()
    func onOpenItemList()
    func onOpenOutletList()
    func onReloadShoplist()
    func onCleanShopList()
    func onRemoveItem(productId: String)
    func onQuantityChanged(productId: String)
    
    func viewDidLoadTrigger()
}

public final class ShoplistPresenterImpl: ShoplistPresenter {
    weak var view: ShoplistView!
    var router: ShoplistRouter!
    var outletModel: OutletModel!
    var locationModel: LocationModel!
    var currentCoords: (lat: Double, lon: Double)?
    
    
    //FIXME: move to UseCase
    var productModel: ProductModel!
    
    
    var isStatisticShown: Bool = false
    var userOutlet: Outlet!
    var getProductDetailProvider: GetProductDetailsProvider!
    
    func viewDidLoadTrigger() {
        self.subscribeOnLocationModel()
        self.locationModel.getCoords()
    }
    
    
    public func updateCurrentOutlet() {
        guard let coordinates = self.currentCoords else { return }
        self.outletModel.nearestOutlet(nearby: coordinates) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case let .success(outlet):
                self.userOutlet = OutletMapper.mapper(from: outlet)
                self.view.onCurrentOutletUpdated(outlet: self.userOutlet)
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }
    
    
    func subscribeOnLocationModel() {
        self.locationModel.onCoordinatesUpdated = { [weak self] coordinates in
            self?.currentCoords = coordinates
            self?.view.geoPositiongGot()
        }
        self.locationModel.onError = { [weak self] error in
            switch error {
            case let .servicesIsNotAvailable(mesage):
                self?.view.onIssue(error: mesage)
            case .other(let message), .notAuthorizedAccess(let message):
                self?.view.onError(with: message)
            }
        }
        self.locationModel.onStatusChanged = { [weak self] isGeoPositiongAllowed in
            if isGeoPositiongAllowed {
                self?.locationModel.getCoords()
            } else {
                self?.view.onIssue(error: "Geo position is not availabel")
            }
        }
    }
    
    private func updateShoplist(shoplist: [ShoplistItem]) {
        self.view.onUpdatedShoplist(shoplist)
        let sum = shoplist.reduce(0) { $0 + ($1.productPrice * $1.quantity) }
        self.view.onUpdatedTotal(sum)
    }
    
    func addNewItemProduct(with name: String) {
        let productId = UUID().uuidString
        self.addToShoplist(with: productId)
    }
    
    func addToShoplist(with productId: String) {
        self.view.showLoading(with: R.string.localizable.getting_actual_price())
        productModel.getItem(with: productId) { [weak self] (product) in
            self?.view.hideLoading()
            guard let product = product else {
                self?.onOpenNewItemCard(for: productId)
                return
            }
            guard let `self` = self else { return }
            
            self.addItemToShopList(product, completion: { result in
                switch result {
                case let .failure(error):
                    switch error {
                    case .alreadyAdded: break
                    default: self.view.onError(with: error.errorDescription)
                    }
                case .success:
                    self.onReloadShoplist()
                }
            })
        }
    }
    
    private func addItemToShopList(_ product: DPProductEntity, completion: @escaping (ResultType<Bool, ProductModelError>)-> Void) {
        self.getProductDetailProvider.getProductDetail(productId: product.id, outletId: self.userOutlet.id) { [weak self] (result) in
            
            guard let `self` = self else { return }
            
            switch result {
            case let .success(shoplistItem):
                self.productModel.saveToShopList(new: shoplistItem) { (result) in
                    switch result {
                    case let .failure(error):
                        completion(ResultType.failure(error))
                    case .success:
                        completion(ResultType.success(true))
                    }
                }
            case let .failure(error):
                completion(ResultType.failure(error))
            }
        }
    }
    
    func isProductHasPrice(for productId: String) {
        self.productModel.getPrice(for: productId, and: self.userOutlet.id, completion: { [weak self] (price) in
            self?.view.onIsProductHasPrice(isHasPrice: price > 0.0, barcode: productId)
        })
    }
    
    func onReloadShoplist() {
        let loadingString = R.string.localizable.common_loading()
        let message = R.string.localizable.sync_process_prices(loadingString)
        self.view.showLoading(with: message)
        
        self.productModel.loadShopList(for: self.userOutlet.id) { (shoplistWithPrices) in
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
    
    func openIssueVC(with issue: String) {
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
        self.productModel.clearShoplist()
        self.onReloadShoplist()
    }
    
    func onQuantityChanged(productId: String) {
        
        var quantityEntity: QuantityModel = QuantityModel(parameters: [], currentValue: 0.0, answerDict: ["productId": productId])
        
        let currentValue = self.productModel.getProductQuantity(productId: productId)
        quantityEntity.currentValue = currentValue
        
        productModel.getProductEntity(for: productId) { [weak self] (result) in
            
            guard let `self` = self else { return }
            
            switch result {
            case let .success(product):
                self.productModel.getParametredUom(for: product.uomId) { (uomModel) in
                    quantityEntity.parameters = uomModel.parameters
                    self.router.openQuantityController(presenter: self, quantityEntity: quantityEntity)
                }
                
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }
    
    
    func onRemoveItem(productId: String) {
        self.productModel.remove(itemId: productId)
        
        self.onReloadShoplist()
    }
    
    func onOpenUpdatePrice(for barcode: String) {
        self.productModel.getPrice(for: barcode, and: userOutlet.id, completion: { [weak self] (price) in
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
        self.addNewItemProduct(with: suggestedName)
    }
}

extension ShoplistPresenterImpl: ItemCardDelegate {
    func savedItem(productId: String) {
        self.addToShoplist(with: productId)
        self.onReloadShoplist()
    }
}



extension ShoplistPresenterImpl: QuantityPickerPopupDelegate {
    func choosen(weight: Double, answer: [String : Any]) {
        guard let productId = answer["productId"] as? String else {
            return
        }
        self.productModel.changeShoplistItem(weight, for: productId)
        self.view.onQuantityChanged()
        
    }
}
