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
    func onReloadShopList()
    func onCleanShopList()
    func onRemoveItem(productId: String)
    func onQuantityChanged(productId: String)
    
    func onOpenStatistics()
    func onOpenUpdatePrice(for barcode: String)
    func openIssueVC(with issue: String)
    func onOpenItemCard(for item: ShopListViewItem)
    func onOpenNewItemCard(for productId: String)
    func onOpenScanner()
    func onOpenItemList()
    func onOpenOutletList()
    
    func viewDidLoadTrigger()
}

public final class ShopListPresenterImpl {
    weak var view: ShoplistView!
    var router: ShoplistRouter!
    var mapper: ShopListMapper!
    var interactor: ShopListInteractor!
    var storage: ShopListStorage!
    var isStatisticShown: Bool = false

    private func bindInteractorEvents() {
        interactor.eventHandler = { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .onError(.noGPSAccess):
                self.view.onIssue(error: R.string.localizable.no_gps_access())
            case let .onError(.unknown(description)):
                self.view.onError(with: description)
            case let .onItemNotFound(productId):
                self.view.hideLoading()
                self.onOpenNewItemCard(for: productId)
            case let .onProductHasNoPrice(productId):
                self.onOpenUpdatePrice(for: productId)
            case .onReload:
                self.view.hideLoading()
                self.onReloadShopList()
            }
        }
    }

    private func updateShopList(shopList: [ShopListViewItem]) {
        interactor.fetchCategoryList { [weak self] entities in
            guard let `self` = self else { return }

            let list: [String] = entities.map { CategoryMapper.transform(input: $0) }

            let formattedShopList = self.mapper
                .transform(input: shopList, categoryList: list)

            self.view.onUpdatedShoplist(formattedShopList)
            let sum = shopList.reduce(0) { $0 + ($1.productPrice * $1.quantity) }
            self.view.onUpdatedTotal(sum)
         }
    }

    private func onAddedItemToShoplist(productId: String) {
        guard let outlet = self.storage.currentUserOutlet else { return }
        self.interactor.isProductHasPrice(for: productId, outletId: outlet.outletId)
        self.addToShopList(with: productId)
    }
}

extension ShopListPresenterImpl: ShopListPresenter {
    func viewDidLoadTrigger() {
        interactor.fetchCurrentOutlet { [weak self] entity in
            guard let `self` = self else { return }
            let userOutlet = OutletMapper.mapper(from: entity)
            self.storage.setCurrent(outlet: userOutlet)
            self.view.onCurrentOutletUpdated(outlet: userOutlet)
            self.onReloadShopList()
        }
        bindInteractorEvents()
    }
    func addNewItemProduct(with name: String) {
        let productId = UUID().uuidString
        self.addToShopList(with: productId)
    }
    
    func addToShopList(with productId: String) {
        guard let outlet = self.storage.currentUserOutlet else { return }
        self.interactor.addItemToShopList(with: productId, outletId: outlet.outletId)
    }
    
    func onReloadShopList() {
        guard let outlet = self.storage.currentUserOutlet else { return }
        interactor.loadShopList(for: outlet.outletId) { items in
            self.updateShopList(shopList: items)
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
    
    func onOpenItemCard(for item: ShopListViewItem) {
        guard let outlet = storage.currentUserOutlet else { return }
        self.router.openItemCard(presenter: self, for: item.productId, outletId: outlet.outletId)
    }
    
    func onOpenScanner() {
        self.router.openScanner(presenter: self)
    }
    
    func onOpenItemList() {
        guard let outlet = storage.currentUserOutlet else { return }
        self.router.openItemList(for: outlet.outletId, presenter: self)
    }
    
    func onOpenOutletList() {
        self.router.openOutletList(presenter: self)
    }
    
    func onOpenNewItemCard(for productId: String) {
        guard let outlet = self.storage.currentUserOutlet else { return }
        self.router.openItemCard(presenter: self, for: productId, outletId: outlet.outletId)
    }
    
    func onCleanShopList() {
        self.interactor.clearShopList()
    }
    
    // TODO: refactoring .....
    func onQuantityChanged(productId: String) {
        view.showLoading(with: R.string.localizable.common_loading())
        interactor.fetchCurrentQuantity(for: productId) { [weak self] quantityModel in
            guard let `self` = self else { return }
            self.view.hideLoading()
            self.router.openQuantityController(presenter: self, quantityEntity: quantityModel)
        }
    }
    
    func onRemoveItem(productId: String) {
        interactor.removeItem(with: productId)
    }
    
    func onOpenUpdatePrice(for barcode: String) {
        guard let outlet = self.storage.currentUserOutlet else { return }
        
        interactor.getPrice(for: barcode, outletId: outlet.outletId) { [weak self] price in
            guard let `self` = self else { return }
            self.router.openUpdatePrice(presenter: self,
                                        for: barcode,
                                        currentPrice: price,
                                        outletId: outlet.outletId)
        }
    }
}

// MARK: delegates handling
extension ShopListPresenterImpl {
    func chosen(outlet: OutletViewItem) {
        storage.currentUserOutlet = outlet
        guard let outlet = self.storage.currentUserOutlet else { return }
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
        interactor.change(weight: weight, productId: productId)
        self.onReloadShopList()
    }
}
