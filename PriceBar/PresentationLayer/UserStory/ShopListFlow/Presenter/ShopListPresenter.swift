//
//  ShopListInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import GooglePlaces

protocol ShopListPresenter: OutletListOutput, UpdatePriceOutput, ScannerOutput, ItemListOutput {
    func addToShopList(with productId: String)
    func onOpenStatistics()
    func onOpenUpdatePrice(for barcode: String)
    func openIssueVC(with issue: String)
    func onOpenItemCard(for item: ShopListViewItem)
    func onOpenNewItemCard(for productId: String)
    func onOpenScanner()
    func onOpenItemList()
    func onOpenOutletList()
    func onReloadShopList()
    func onCleanShopList()
    func onRemoveItem(productId: String)
    func onQuantityChanged(productId: String)

    func viewDidLoadTrigger()
}

public final class ShopListPresenterImpl: ShopListPresenter {
    weak var view: ShoplistView!
    var router: ShoplistRouter!
    var mapper: ShopListMapper!
    var interactor: ShopListInteractor!
    var isStatisticShown: Bool = false
//    var userOutlet: OutletViewItem?

    func viewDidLoadTrigger() {
        interactor.fetchCurrentOutlet()
        bindInteractorEvents()
    }

    private func bindInteractorEvents() {
        interactor.eventHandler = { [weak self] event in
            view.hideLoading()
            guard let `self` = self else { return }
            switch event {
            case .noGPSAccess:
                self.view.onIssue(error: R.string.localizable.no_gps_access())
            case let .onOutletFetched(entity):
                let userOutlet = OutletMapper.mapper(from: entity)
                self.view.onCurrentOutletUpdated(outlet: userOutlet)
                self.onReloadShopList()
            case let .onError(.unknown(description)):
                self.view.onError(with: description)
            case let .onCategoryListFetched(entities):
                let list: [String] = entities.map { CategoryMapper.transform(input: $0) }
                let formattedShopList = self?.mapper.transform(input: shoplist, categoryList: list)
                self.view.onUpdatedShoplist(formattedShopList!)
            case let .onItemNotFound(productId):
                self.onOpenNewItemCard(for: productId)
            case let .onItemFetched(entity):
                self.addItemToShopList(product, completion: { result in
                    switch result {
                    case let .failure(error) as ProductModelError.alreadyAdded:
                        break
                    case let .failure(error):
                        self.view.onError(with: error.errorDescription)
                    case .success:
                        self.onReloadShopList()

                    }
                })
            }
        }
    }

//    private func updateShopList(shopList: [ShopListViewItem]) {
//        interactor.fetchCategoryList()
//        let sum = shopList.reduce(0) { $0 + ($1.productPrice * $1.quantity) }
//        self.view.onUpdatedTotal(sum)
//    }

    func addNewItemProduct(with name: String) {
        let productId = UUID().uuidString
        self.addToShopList(with: productId)
    }

//    func addToShopList(with productId: String) {
//        self.view.showLoading(with: R.string.localizable.getting_actual_price())
//        productModel.getItem(with: productId) { [weak self] (product) in
//            self?.view.hideLoading()
//            guard let product = product else {
//                self?.onOpenNewItemCard(for: productId)
//                return
//            }
//            guard let `self` = self else { return }
//
//            self.addItemToShopList(product, completion: { result in
//                switch result {
//                case let .failure(error):
//                    switch error {
//                    case .alreadyAdded: break
//                    default: self.view.onError(with: error.errorDescription)
//                    }
//                case .success:
//                    self.onReloadShopList()
//                }
//            })
//        }
//    }

    private func addItemToShopList(_ product: ProductEntity, completion: @escaping (ResultType<Bool, ProductModelError>) -> Void) {

        guard let userOutlet = self.userOutlet else { return }

        self.productModel.getProductDetail(productId: product.productId, outletId: userOutlet.outletId) { [weak self] (result) in

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
        self.productModel.getPrice(for: productId, and: userOutlet.outletId, completion: { [weak self] (price) in
            let isHasPrice = price > 0.0
            if !isHasPrice {
                self?.onOpenUpdatePrice(for: productId)
            }
        })
    }

    func onReloadShopList() {
        let loadingString = R.string.localizable.common_loading()
        let message = R.string.localizable.sync_process_prices(loadingString)
        var productEntities: [String: ProductEntity] = [:]
        var prices: [String: Double] = [:]

        guard let userOutlet = self.userOutlet else { return }

        self.shoplistModel.loadShopList { [weak self] (items) in
            guard let `self` = self else { return }
            guard !items.isEmpty else {
                self.updateShopList(shopList: [])
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
            self.productModel.getPriceList(for: ids, and: userOutlet.outletId, completion: { (values) in
                prices = values
                shoplistInfoGroup.leave()
            })
            shoplistInfoGroup.notify(queue: .main) {
                self.mergeArrays(from: productEntities,
                                 prices: prices,
                                 shoplistItems: items,
                                 outletId: userOutlet.outletId, completion: { [weak self] (shopListViewItems) in

                                    guard let `self` = self else { return }

                                    self.view.hideLoading()
                                    self.updateShopList(shopList: shopListViewItems)
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
                                outletId: String?, completion: @escaping ([ShopListViewItem]) -> Void) {
        var shopItems: [ShopListViewItem] = []

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
            
            let categoryId = productEntity.categoryId ?? 1
            productModel.getCategoryName(for: categoryId) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
                otherInfoGroup.leave()
            }
            otherInfoGroup.enter()
            
            let uomId = productEntity.uomId ?? 1
            
            productModel.getParametredUom(for: uomId) { (entity) in
                uomEntity = entity
                otherInfoGroup.leave()
            }

            otherInfoGroup.enter()
            productModel.getCountry(for: productEntity.productId) { (value) in
                country = value ?? "No info"
                otherInfoGroup.leave()
            }

            otherInfoGroup.notify(queue: .main) {
                
                let brand = productEntity.brand ?? ""
                let weightPerPiece = productEntity.weightPerPiece ?? ""
                let categoryId = productEntity.categoryId ?? 1
                let uomId = productEntity.uomId ?? 1
                let parameters = uomEntity.parameters.compactMap { $0 }
                
                
                let shopItem = ShopListViewItem(productId: item.productId,
                                                country: country,
                                                productName: productEntity.name,
                                                brand: brand,
                                                weightPerPiece: weightPerPiece,
                                                categoryId: categoryId,
                                                productCategory: categoryName,
                                                productPrice: price,
                                                uomId: uomId,
                                                productUom: uomEntity.name,
                                                quantity: item.quantity,
                                                parameters: parameters)

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

    func onOpenItemCard(for item: ShopListViewItem) {
        guard let userOutlet = self.userOutlet else { return }
        self.router.openItemCard(presenter: self, for: item.productId, outletId: userOutlet.outletId)
    }

    func onOpenScanner() {
        self.router.openScanner(presenter: self)
    }

    func onOpenItemList() {
        guard let userOutlet = self.userOutlet else { return }
        self.router.openItemList(for: userOutlet.outletId, presenter: self)
    }

    func onOpenOutletList() {
        self.router.openOutletList(presenter: self)
    }

    private func onOpenNewItemCard(for productId: String) {
        guard let userOutlet = self.userOutlet else { return }
        self.router.openItemCard(presenter: self, for: productId, outletId: userOutlet.outletId)
    }

    func onCleanShopList() {
        self.shoplistModel.clearShoplist()
        self.updateShopList(shopList: [])
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
                self.productModel.getParametredUom(for: product.uomId ?? 1) { [weak self] (uomEntity) in
                    guard let `self` = self else { return }

                    quantityModel.parameters = uomEntity.params
                    self.router.openQuantityController(presenter: self, quantityEntity: quantityModel)
                }

            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }

    func onRemoveItem(productId: String) {
        self.shoplistModel.remove(itemId: productId)
        self.onReloadShopList()
    }

    func onOpenUpdatePrice(for barcode: String) {
        guard let userOutlet = self.userOutlet else { return }
        self.productModel.getPrice(for: barcode, and: userOutlet.outletId, completion: { [weak self] (price) in
            guard let `self` = self else { return }
            self.router.openUpdatePrice(presenter: self, for: barcode, currentPrice: price, outletId: userOutlet.outletId)
        })
    }

    private func onAddedItemToShoplist(productId: String) {
        self.isProductHasPrice(for: productId)
        self.addToShopList(with: productId)
    }

    // MARK: delegates handling
    func chosen(outlet: OutletViewItem) {
        self.userOutlet = outlet
        self.view.onCurrentOutletUpdated(outlet: outlet)
        self.onReloadShopList()
    }

    func saved() {
        self.onReloadShopList()
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

extension ShopListPresenterImpl: ItemCardDelegate {
    func savedItem(productId: String) {
        self.addToShopList(with: productId)
        self.onReloadShopList()
    }
}

extension ShopListPresenterImpl: QuantityPickerPopupDelegate {
    func chosen(weight: Double, answer: [String: Any]) {
        guard let productId = answer["productId"] as? String else {
            return
        }
        self.shoplistModel.changeShoplistItem(weight, for: productId)
        self.onReloadShopList()
    }
}
