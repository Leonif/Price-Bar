//
//  ShopListInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 11/10/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

enum ShopListInteractorError: Error {
    case unknown(String)
}


enum ShopListInteractorEvent {
    case noGPSAccess
    case onOutletFetched(OutletEntity)
    case onCategoryListFetched([CategoryEntity])
    case onItemFetched(ProductEntity)
    case onItemNotFound(productId: String)
    case onError(ShopListInteractorError)
}

protocol ShopListInteractor {
    var eventHandler: EventHandler<ShopListInteractorEvent>? { get set }

    func fetchCurrentOutlet()
    func fetchCategoryList()
    func fetchItem(with id: String)
}

class ShoplistInteractorImpl: ShopListInteractor {
    var locationService: LocationService!
    var shopListModel: ShopListModel!
    var productModel: ProductModel!
    var outletModel: OutletModel!
    var coordinates: (lat: Double, lon: Double)?
    var eventHandler: EventHandler<ShopListInteractorEvent>? = nil
    
    
    func getCurrentOutlet() {
        locationService.getCoords()
        locationService.onStatusChanged = { [weak self] isAvalaible in
            if !isAvalaible {
                self?.eventHandler?(.noGPSAccess)
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
                self.eventHandler?(.onOutletFetched(outlet))
                
            case let .failure(error):
                self.eventHandler?(.onError(ShopListInteractorError.unknown(error.errorDescription)))
            }
        }
    }
    
    func fetchCategoryList() {
        productModel.getCategoryList { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(categoryList):
                self.eventHandler?(.onCategoryListFetched(categoryList))
            case let .failure(error):
                self.eventHandler?(.onError(ShopListInteractorError.unknown(error.errorDescription)))
                
            }
        }
    }

    func fetchItem(with id: String) {
        productModel.getItem(with: productId) { [weak self] (product) in
            self?.view.hideLoading()
            guard let product = product else {
                self?.eventHandler?(.onItemNotFound(productId))
                return
            }
            eventHandler(ShopListInteractorEvent.onItemFetched(product))
        }

    }
}
