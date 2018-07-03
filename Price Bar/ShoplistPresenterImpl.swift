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
    func startSyncronize()
    func isProductHasPrice(for productId: String, in outletId: String)
    func addToShoplist(with productId: String, and outletId: String)
    func updateCurrentOutlet()
    
    func onOpenStatistics()
    func onOpenUpdatePrice(for barcode: String, outletId: String)
    func onOpenIssueVC(with issue: String)
    func onOpenItemCard(for item: ShoplistItem, with outletId: String)
    func onOpenNewItemCard(for productId: String)
    func onOpenScanner()
    func onOpenItemList(for outletId: String)
    func onOpenOutletList()
    func onReloadShoplist(for outletId: String)
    func onCleanShopList()
    func onRemoveItem(productId: String)
}

public final class ShoplistPresenterImpl: ShoplistPresenter {
    
    
    weak var view: ShoplistView!
    var router: ShoplistRouter!
    private let repository: Repository!
    var isStatisticShown: Bool = false
    
    init(repository: Repository) {
        self.repository = repository
        self.repository.onSyncProgress = { [weak self] (progress, max, text) in
            self?.view.onSyncProgress(progress: Double(progress), max: Double(max), text: text)
        }
    }
    
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
    
    func startSyncronize() {
        repository.syncCloud { [weak self] result in
            switch result {
            case let .failure(error):
                self?.view.onSyncError(error: "\(error.message): \(error.localizedDescription)")
            case .success:
                self?.view.onUpdateCurrentOutlet()
            }
        }
    }
    
    func addToShoplist(with productId: String, and outletId: String) {
        self.view.showLoading(with: R.string.localizable.getting_actual_price())
        repository.getItem(with: productId, and: outletId) { [weak self] (product) in
            guard let product = product else { fatalError() }
            guard let `self` = self else { return }
            
            self.addItemToShopList(product, and: outletId, completion: { result in
                self.view.hideLoading()
                switch result {
                case let .failure(error):
                    self.view.onError(error: error.message)
                case .success:
                    self.view.onAddedItemToShoplist(productId: productId)
                    self.updateShoplist()
                }
            })
        }
    }
    
    private func addItemToShopList(_ product: DPProductEntity, and outletId: String, completion: @escaping (ResultType<Bool, RepositoryError>)-> Void) {
        
        repository.getPrice(for: product.id, and: outletId) { [weak self] (price) in
            guard let `self` = self else { return }
            
            //let shopListItem: ShoplistItem = ProductMapper.mapper(from: product, price: price, outletId: outletId)
            
            let result = self.repository.saveToShopList(new: ShoplistItem(productId: product.id,
                                                                          productName: product.name,
                                                                          brand: product.brand,
                                                                          weightPerPiece: product.weightPerPiece,
                                                                          categoryId: product.categoryId, productCategory: "",
                                                                          productPrice: price,
                                                                          uomId: product.uomId,
                                                                          productUom: "", quantity: 1.0))
            switch result {
            case let .failure(error):
                completion(ResultType.failure(error))
            case .success:
                completion(ResultType.success(true))
            }
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
        
        guard let shoplistWithoutPrices = self.repository.loadShopList() else { fatalError() }
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
    
    func onOpenStatistics() {
        self.router.openStatistics()
    }
    
    func onOpenIssueVC(with issue: String) {
        self.router.openIssue(with: issue)
    }
    
    func onOpenItemCard(for item: ShoplistItem, with outletId: String) {
        self.router.openItemCard(for: item, outletId: outletId)
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
    
    func onOpenNewItemCard(for productId: String) {
        //TODO: need to implement
    }
    
    func onCleanShopList() {
        self.repository.clearShoplist()
        self.updateShoplist()
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
