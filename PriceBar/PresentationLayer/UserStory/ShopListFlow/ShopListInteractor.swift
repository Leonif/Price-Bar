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
    case onItemNotFound(productId: String)
    case onProductHasNoPrice(productId: String)
    case onError(ShopListInteractorError)
    case onReload
}

protocol ShopListInteractor {
    var eventHandler: EventHandler<ShopListInteractorEvent>? { get set }
    
    func isProductHasPrice(for productId: String, outletId: String)
    func fetchCurrentOutlet(completion: @escaping (OutletEntity) -> Void)
    func fetchCategoryList(completion: @escaping ([CategoryEntity]) -> Void)
//    func fetchItem(with id: String, completion: @escaping (ProductEntity) -> Void)
    func addItemToShopList(with productId: String, outletId: String)
    func getPrice(for barcode: String, outletId: String, completion: @escaping (Double) -> Void)
    func loadShopList(for outletId: String, completion: @escaping ([ShopListViewItem]) -> Void)
    func removeItem(with productId: String)
    func fetchCurrentQuantity(for productId: String, completion: @escaping (QuantityEntity) -> Void)
    func clearShopList()
    func change(weight: Double, productId: String)
}

class ShopListInteractorImpl: ShopListInteractor {
    var locationService: LocationService!
    var shopListModel: ShopListModel!
    var productModel: ProductModel!
    var outletModel: OutletModel!
    var coordinates: (lat: Double, lon: Double)?
    var eventHandler: EventHandler<ShopListInteractorEvent>? = nil

    func change(weight: Double, productId: String) {
        self.shopListModel.changeShoplistItem(weight, for: productId)
    }

    func fetchCurrentOutlet(completion: @escaping (OutletEntity) -> Void) {
        locationService.getCoords()
        locationService.onStatusChanged = { [weak self] isAvailable in
            if !isAvailable {
                self?.eventHandler?(.noGPSAccess)
            } else {
                self?.locationService.getCoords()
            }
        }
        locationService.onCoordinatesUpdated = { [weak self] coordinates in
            self?.coordinates = coordinates
            self?.updateCurrentOutlet(completion: completion)
        }
    }

    func fetchCurrentQuantity(for productId: String, completion: @escaping (QuantityEntity) -> Void) {
        let currentValue = self.shopListModel.getProductQuantity(productId: productId)

        productModel.getProductEntity(for: productId) { [weak self] (result) in
            guard let `self` = self else {
                return
            }
            switch result {
            case let .success(product):
                self.productModel.getParametredUom(for: product.uomId ?? 1) { (uomEntity) in
                    let quantityModel: QuantityEntity = QuantityEntity(parameters: uomEntity.params,
                        currentValue: currentValue,
                        answerDict: ["productId": productId])
                    completion(quantityModel)
                }
            case let .failure(error):
                self.eventHandler?(.onError(.unknown(error.errorDescription)))
            }
        }
    }

    func removeItem(with productId: String) {
        self.shopListModel.remove(itemId: productId)
    }

    func clearShopList() {
        self.shopListModel.clearShoplist()
    }

    func getPrice(for barcode: String, outletId: String, completion: @escaping (Double) -> Void) {
        self.productModel.getPrice(for: barcode, and: outletId, completion: { (price) in
            completion(price)
        })
    }

    func loadShopList(for outletId: String, completion: @escaping ([ShopListViewItem]) -> Void) {
        var productEntities: [String: ProductEntity] = [:]
        var prices: [String: Double] = [:]

        self.shopListModel.loadShopList { [weak self] (items) in
            guard let `self` = self else {
                return
            }
            guard !items.isEmpty else {
                completion([])
                return
            }
            let ids = items.map {
                $0.productId
            }
            let shopListInfoGroup = DispatchGroup()
            shopListInfoGroup.enter()
            self.productModel.getProductInfoList(for: ids, completion: { (entities) in
                productEntities = entities
                shopListInfoGroup.leave()
            })
            
            shopListInfoGroup.enter()
            self.productModel.getPriceList(for: ids, and: outletId, completion: { (values) in
                prices = values
                shopListInfoGroup.leave()
            })
            shopListInfoGroup.notify(queue: .main) {
                self.mergeArrays(from: productEntities,
                    prices: prices,
                    shopListItems: items,
                    outletId: outletId, completion: { (shopListViewItems) in

                    completion(shopListViewItems)
                })
            }
        }
    }

    private func mergeArrays(from productEntities: [String: ProductEntity],
                             prices: [String: Double] = [:],
                             shopListItems: [ShoplistItemEntity],
                             outletId: String?, completion: @escaping ([ShopListViewItem]) -> Void) {
        var shopItems: [ShopListViewItem] = []

        let shopListItemsGroup = DispatchGroup()

        for item in shopListItems {
            shopListItemsGroup.enter()
            guard let productEntity = productEntities[item.productId] else {
                continue
            }
            guard let price = prices[item.productId] else {
                continue
            }

            var categoryName: String = ""
            var uomEntity: UomEntity = UomEntity()
            var country: String = "No country"

            let otherInfoGroup = DispatchGroup()
            otherInfoGroup.enter()

            let categoryId = productEntity.categoryId ?? 1
            productModel.getCategoryName(for: categoryId) { [weak self] (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                case let .failure(error):
                    self?.eventHandler?(.onError(.unknown(error.errorDescription)))
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
                let parameters = uomEntity.parameters.compactMap {
                    $0
                }

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
                shopListItemsGroup.leave()
            }
        }
        shopListItemsGroup.notify(queue: .main) {
            completion(shopItems)
        }
    }

    func addItemToShopList(with productId: String, outletId: String) {
        productModel.getItem(with: productId) { [weak self] (product) in
            guard let product = product else {
                self?.eventHandler?(.onItemNotFound(productId: productId))
                return
            }
            guard let `self` = self else {
                return
            }

            self.addItemToShopList2(product, outletId, completion: { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success:
                    self.eventHandler?(.onReload)
                case .failure(.alreadyAdded): break
                case let .failure(error):
                    self.eventHandler?(.onError(.unknown(error.errorDescription)))
                }
            })

        }
    }

    func addItemToShopList2(_ product: ProductEntity, _ outletId: String, completion: @escaping (ResultType<Bool, ProductModelError>) -> Void) {
        self.productModel.getProductDetail(productId: product.productId, outletId: outletId) { [weak self] (result) in

            guard let `self` = self else {
                return
            }
            switch result {
            case let .success(shoplistItem):
                self.shopListModel.saveToShopList(new: shoplistItem) { (result) in
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


    func updateCurrentOutlet(completion: @escaping (OutletEntity) -> Void) {
        guard let coordinates = self.coordinates else {
            return
        }
        self.outletModel.nearestOutletNearBy(coordinates: coordinates) { [weak self] result in
            guard let `self` = self else {
                return
            }

            switch result {
            case let .success(outlet):
                completion(outlet)

            case let .failure(error):
                self.eventHandler?(.onError(ShopListInteractorError.unknown(error.errorDescription)))
            }
        }
    }

    func isProductHasPrice(for productId: String, outletId: String) {
        self.productModel.getPrice(for: productId, and: outletId, completion: { [weak self] (price) in
            let isHasPrice = price > 0.0
            if !isHasPrice {
                self?.eventHandler?(.onProductHasNoPrice(productId: productId))
            }
        })
    }
}


// MARK: ShopListInteractor
extension ShopListInteractorImpl {
    func fetchCategoryList(completion: @escaping ([CategoryEntity]) -> Void) {
        productModel.getCategoryList { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(categoryList):
                completion(categoryList)
            case let .failure(error):
                self.eventHandler?(.onError(ShopListInteractorError.unknown(error.errorDescription)))
            }
        }
    }

//    func fetchItem(with id: String, completion: @escaping (ProductEntity) -> Void) {
//        productModel.getItem(with: productId) { [weak self] (product) in
//            self?.view.hideLoading()
//            guard let product = product else {
//                self?.eventHandler?(.onItemNotFound(productId))
//                return
//            }
//            completion(product)
////            eventHandler(ShopListInteractorEvent.onItemFetched(product))
//        }
//
//    }
}
