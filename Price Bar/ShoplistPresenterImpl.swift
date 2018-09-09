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
    func addToShoplist(with productId: String)
    func onOpenStatistics()
    func onOpenUpdatePrice(for barcode: String)
    func openIssueVC(with issue: String)
    func onOpenItemCard(for item: ShoplistViewItem)
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

    var productModel: ProductModel!
    var shoplistModel: ShoplistModel!
    var isStatisticShown: Bool = false
    var userOutlet: OutletViewItem?
    var locationService: LocationService!
    var coordinates: (lat: Double, lon: Double)?
    
    func viewDidLoadTrigger() {
        locationService.getCoords()
        locationService.onStatusChanged = { [weak self] isAvalaible in
            if !isAvalaible {
                self?.view.onIssue(error: R.string.localizable.no_gps_access())
            } else {
                self?.locationService.getCoords()
            }
        }
        locationService.onCoordinatesUpdated = { [weak self] coordinates  in
            self?.coordinates = coordinates
            self?.updateCurrentOutlet()
        }
    }
    
    private func updateCurrentOutlet() {
        guard let coordinates = self.coordinates else { return }
        self.outletModel.nearestOutletNearBy(coordinates: coordinates) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case let .success(outlet):
                self.userOutlet = OutletMapper.mapper(from: outlet)
                guard let userOutlet = self.userOutlet else { return }
                self.view.onCurrentOutletUpdated(outlet: userOutlet)
                self.onReloadShoplist()
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }
    
    private func updateShoplist(shoplist: [ShoplistViewItem]) {
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
    
    private func addItemToShopList(_ product: ProductEntity, completion: @escaping (ResultType<Bool, ProductModelError>)-> Void) {
        
        guard let userOutlet = self.userOutlet else { return }
        
        self.productModel.getProductDetail(productId: product.id, outletId: userOutlet.id) { [weak self] (result) in
            
            guard let `self` = self else { return }
            switch result {
            case let .success(shoplistItem):
                self.shoplistModel.saveToShopList(new: shoplistItem) { (result) in
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
    
    private func isProductHasPrice(for productId: String) {
        guard let userOutlet = self.userOutlet else { return }
        self.productModel.getPrice(for: productId, and: userOutlet.id, completion: { [weak self] (price) in
            let isHasPrice = price > 0.0
            if !isHasPrice {
                self?.onOpenUpdatePrice(for: productId)
            }
        })
    }
    
    func onReloadShoplist() {
        let loadingString = R.string.localizable.common_loading()
        let message = R.string.localizable.sync_process_prices(loadingString)
        var productEntities: [String: ProductEntity] = [:]
        var prices: [String: Double] = [:]
        
        guard let userOutlet = self.userOutlet else { return }
        
        self.shoplistModel.loadShopList { [weak self] (items) in
            guard let `self` = self else { return }
            guard !items.isEmpty else {
                self.updateShoplist(shoplist: [])
                return
            }
            self.view.showLoading(with: message)
            
            let ids = items.map { $0.productId }
            let shoplistInfoGroup = DispatchGroup()
            shoplistInfoGroup.enter()
            self.productModel.getProductInfoList(for: ids, completion: { (entities) in
                productEntities = entities
                shoplistInfoGroup.leave()
            })
            shoplistInfoGroup.enter()
            self.productModel.getPriceList(for: ids, and: userOutlet.id, completion: { (values) in
                prices = values
                shoplistInfoGroup.leave()
            })
            shoplistInfoGroup.notify(queue: .main) {
                self.mergeArrays(from: productEntities,
                                 prices: prices,
                                 shoplistItems: items,
                                 outletId: userOutlet.id, completion: { [weak self] (shoplistViewItems) in
                                    
                                    guard let `self` = self else { return }
                                    
                                    self.view.hideLoading()
                                    self.updateShoplist(shoplist: shoplistViewItems)
                                    if !self.isStatisticShown {
                                        self.view.startIsCompleted()
                                        self.isStatisticShown = true
                                    }
                })
            }
        }
    }
    
    private func mergeArrays(from productEntities: [String: ProductEntity],
                                prices: [String: Double] = [:],
                                shoplistItems: [ShoplistItemEntity],
                                outletId: String?, completion: @escaping ([ShoplistViewItem]) -> Void)  {
        var shopItems: [ShoplistViewItem] = []
        
        let shoplistItemsGroup = DispatchGroup()

        for item in shoplistItems {
            shoplistItemsGroup.enter()
            guard let productEntity = productEntities[item.productId] else { continue }
            guard let price = prices[item.productId] else { continue }
            
            var categoryName: String = ""
            var uomEntity: UomEntity = UomEntity()
            var country: String = "No country"
            
            let otherInfoGroup = DispatchGroup()
            otherInfoGroup.enter()
            productModel.getCategoryName(for: productEntity.categoryId) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
                otherInfoGroup.leave()
            }
            otherInfoGroup.enter()
            productModel.getParametredUom(for: productEntity.uomId) { (entity) in
                uomEntity = entity
                otherInfoGroup.leave()
            }
            
            otherInfoGroup.enter()
            productModel.getCountry(for: productEntity.id) { (value) in
                country = value ?? "No info"
                otherInfoGroup.leave()
            }
            
            otherInfoGroup.notify(queue: .main) {
                let shopItem = ShoplistViewItem(productId: item.productId,
                                                country: country,
                                                productName: productEntity.name,
                                                brand: productEntity.brand,
                                                weightPerPiece: productEntity.weightPerPiece,
                                                categoryId: productEntity.categoryId,
                                                productCategory: categoryName,
                                                productPrice: price,
                                                uomId: productEntity.uomId,
                                                productUom: uomEntity.name,
                                                quantity: item.quantity,
                                                parameters: uomEntity.parameters)
                
                shopItems.append(shopItem)
                shoplistItemsGroup.leave()
            }
        }
        shoplistItemsGroup.notify(queue: .main) {
            completion(shopItems)
            self.view.hideLoading()
        }
    }
    
    func onOpenStatistics() {
        self.router.openStatistics()
    }
    
    func openIssueVC(with issue: String) {
        self.router.openIssue(with: issue)
    }
    
    func onOpenItemCard(for item: ShoplistViewItem) {
        guard let userOutlet = self.userOutlet else { return }
        self.router.openItemCard(presenter: self, for: item.productId, outletId: userOutlet.id)
    }
    
    func onOpenScanner() {
        self.router.openScanner(presenter: self)
    }
    
    func onOpenItemList() {
        guard let userOutlet = self.userOutlet else { return }
        self.router.openItemList(for: userOutlet.id, presenter: self)
    }
    
    func onOpenOutletList() {
        self.router.openOutletList(presenter: self)
    }
    
    func onOpenNewItemCard(for productId: String) {
        guard let userOutlet = self.userOutlet else { return }
        self.router.openItemCard(presenter: self, for: productId, outletId: userOutlet.id)
    }
    
    func onCleanShopList() {
        self.shoplistModel.clearShoplist()
        self.updateShoplist(shoplist: [])
    }
    
    // TODO: refactoring .....
    func onQuantityChanged(productId: String) {
        
        var quantityModel: QuantityEntity = QuantityEntity(parameters: [],
                                                           currentValue: 0.0,
                                                           answerDict: ["productId": productId])
        
        let currentValue = self.shoplistModel.getProductQuantity(productId: productId)
        quantityModel.currentValue = currentValue
        
        
        view.showLoading(with: R.string.localizable.common_loading())
        productModel.getProductEntity(for: productId) { [weak self] (result) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            switch result {
            case let .success(product):
                self.productModel.getParametredUom(for: product.uomId) { [weak self] (uomEntity) in
                    guard let `self` = self else { return }
                    
                    quantityModel.parameters = uomEntity.parameters
                    self.router.openQuantityController(presenter: self, quantityEntity: quantityModel)
                }
                
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }
    
    func onRemoveItem(productId: String) {
        self.shoplistModel.remove(itemId: productId)
        self.onReloadShoplist()
    }
    
    func onOpenUpdatePrice(for barcode: String) {
        guard let userOutlet = self.userOutlet else { return }
        self.productModel.getPrice(for: barcode, and: userOutlet.id, completion: { [weak self] (price) in
            guard let `self` = self else { return }
            self.router.openUpdatePrice(presenter: self, for: barcode, currentPrice: price, outletId: userOutlet.id)
        })
    }
    
    private func onAddedItemToShoplist(productId: String) {
        self.isProductHasPrice(for: productId)
        self.addToShoplist(with: productId)
    }
    
    
    // MARK: delagates hadnling
    func choosen(outlet: OutletViewItem) {
        self.userOutlet = outlet
        self.view.onCurrentOutletUpdated(outlet: outlet)
        self.onReloadShoplist()
    }
    
    
    func saved() {
        self.onReloadShoplist()
    }
    
    func scanned(barcode: String) {
        self.onAddedItemToShoplist(productId: barcode)
    }
    
    func itemChoosen(productId: String) {
        self.onAddedItemToShoplist(productId: productId)
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
        self.shoplistModel.changeShoplistItem(weight, for: productId)
        self.onReloadShoplist()
    }
}
