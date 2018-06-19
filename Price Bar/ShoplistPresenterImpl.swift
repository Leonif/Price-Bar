//
//  ShoplistInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import GooglePlaces


protocol ShoplistPresenter {
    func startSyncronize()
    func isProductHasPrice(for productId: String, in outletId: String)
    func addToShoplist(with productId: String, and outletId: String)
    func updateCurrentOutlet()
    func reloadProducts(outletId: String)
    
    func onOpenStatistics()
    func onOpenUpdatePrice(for barcode: String, outletId: String)
    func onOpenIssueVC(with issue: String)
    func onOpenItemCard(for item: DPShoplistItemModel, with outletId: String)
    func onOpenNewItemCard(for productId: String)
    func onOpenScanner()
    func onOpenItemList(for outletId: String)
    func onOpenOutletList()
    func onReloadShoplist(for outletId: String)
    func onCleanShopList()
    
}



public final class ShoplistPresenterImpl: ShoplistPresenter {
    
    weak var view: ShoplistView!
    var router: ShoplistRouter!
    
    private let outletService = OutletService()
    private let repository: Repository!
    
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
            case let .failure(error):
                self.view.onError(error: error.errorDescription)
            }
        }
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
        repository.getItem(with: productId, and: outletId) { (product) in
            
            guard let product = product else { fatalError() }
            
            self.addItemToShopList(product, and: outletId, completion: { result in
                switch result {
                case let .failure(error):
                    self.view.onError(error: error.message)
                case .success:
                    self.view.onAddedItemToShoplist(productId: productId)
                }
            })
        }
    }
    
    private func addItemToShopList(_ product: DPProductModel, and outletId: String, completion: @escaping (ResultType<Bool, RepositoryError>)-> Void) {
        
        repository.getPrice(for: product.id, and: outletId) { [weak self] (price) in
            guard let `self` = self else { return }
            
            let shopListItem: DPShoplistItemModel = ProductMapper.mapper(from: product, price: price)
            
            let result = self.repository.saveToShopList(new: shopListItem)
            switch result {
            case let .failure(error):
                completion(ResultType.failure(error))
            case .success:
                completion(ResultType.success(true))
                
            }
        }
    }
    
    func isProductHasPrice(for productId: String, in outletId: String) {
        self.repository.getPrice(for: productId, and: outletId, callback: { [weak self] (price) in
            self?.view.onIsProductHasPrice(isHasPrice: price > 0.0, barcode: productId)
            
        })
    }
    
    func reloadProducts(outletId: String) {
        self.repository.loadShopList(for: outletId)
    }
    
    
    
    func onOpenStatistics() {
        self.router.openStatistics()
    }
    
    
    func onOpenIssueVC(with issue: String) {
        self.router.openIssue(with: issue)

    }
    
    
    func onOpenItemCard(for item: DPShoplistItemModel, with outletId: String) {
        self.router.openItemCard(for: item, outletId: outletId)
    }
    
    
    func onOpenScanner() {
        self.router.openScanner()
    }
    
    func onOpenItemList(for outletId: String) {
        self.router.openItemList(for: outletId)
    }
    
    func onOpenOutletList() {
        self.router.openOutletList()
    }
    
    func onOpenNewItemCard(for productId: String) {
        
    }
    
    
    func onReloadShoplist(for outletId: String) {
        self.repository.loadShopList(for: outletId)
    }
    
    func onCleanShopList() {
        self.repository.clearShoplist()
    }
    
    
    func onOpenUpdatePrice(for barcode: String, outletId: String) {
        self.repository.getPrice(for: barcode, and: outletId, callback: { [weak self] (price) in
            self?.router.openUpdatePrice(for: barcode, currentPrice: price, outletId: outletId)
        })
    }
}
