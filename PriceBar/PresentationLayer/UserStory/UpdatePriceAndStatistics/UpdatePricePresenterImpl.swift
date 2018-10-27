//
//  UpdatePriceInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol UpdatePriceOutput {
    func saved()
}

protocol UpdatePricePresenter {
    func onSavePrice(for productId: String, for outletId: String, with newPrice: Double, and oldPrice: Double)
    func onGetProductInfo(for productId: String, and outletId: String)
    func onGetPriceStatistics(for productId: String)
}

public final class UpdatePricePresenterImpl: UpdatePricePresenter {

    var productModel: ProductModelImpl!
    weak var view: UpdatePriceView!
    var updatePriceOutput: UpdatePriceOutput!

    func onGetProductInfo(for productId: String, and outletId: String) {
        self.view.showLoading(with: R.string.localizable.common_get_product_info())
        self.productModel.getItem(with: productId) { (dpProductEntity) in
            guard let dpProductEntity = dpProductEntity else {
                self.view.hideLoading()
                self.view.onError(with: R.string.localizable.error_something_went_wrong())
                return
            }
            self.productModel.getPrice(for: productId, and: outletId, completion: { (price) in
                self.productModel.getUomName(for: dpProductEntity.uomId!, completion: { (result) in
                    self.view.hideLoading()

                    switch result {
                    case let .success(uomName):
                        self.view.onGetProductInfo(price: price, name: dpProductEntity.fullName, uomName: uomName)
                    case let .failure(error):
                        self.view.onError(with: error.errorDescription)
                    }
                })

            })
        }
    }

    func onSavePrice(for productId: String, for outletId: String, with newPrice: Double, and oldPrice: Double) {
        defer { self.view.close() }
        guard newPrice != oldPrice && newPrice != 0
            else { return  }
        let dpStatModel = PriceStatisticViewItem(outletId: outletId,
                                                productId: productId,
                                                newPrice: newPrice, oldPrice: oldPrice, date: Date())
        self.productModel.savePrice(for: productId, statistic: dpStatModel)
        self.updatePriceOutput.saved()
    }

    func onGetPriceStatistics(for productId: String) {
        self.view.showLoading(with: "Получаем актуальные цены в других магазинах")
        self.productModel.getPricesFor(productId: productId) { (prices) in
            self.mergeOutletsWithPrices(productId: productId, fbPriceStatistics: prices)
        }
    }

    func mergeOutletsWithPrices(productId: String, fbPriceStatistics: [ProductPrice]) {
        let foursquareProvider = FoursquareProvider()
        let outletService = FoursqareOutletModelImpl(foursquareProvider)
        var statistic: [StatisticModel] = []

        let dispatchGroup = DispatchGroup()

        fbPriceStatistics.forEach { fbPriceStatistic in
            dispatchGroup.enter()
            outletService.getOutlet(with: fbPriceStatistic.outletId, completion: { (result) in
                switch result {
                case let .success(outlet):
                    statistic.append(StatisticModel(productId: fbPriceStatistic.productId,
                                                    productName: fbPriceStatistic.productName,
                                                    outlet: outlet,
                                                    price: fbPriceStatistic.currentPrice,
                                                    date: fbPriceStatistic.date))
                    dispatchGroup.leave()
                case let .failure(error):
                    self.view.hideLoading()
                    self.view.onError(with: error.localizedDescription)
                }
            })
        }

        dispatchGroup.notify(queue: .main) {
            self.view.hideLoading()
            statistic.sort(by: { $0.date > $1.date })
            self.view.onGetStatistics(statistic: statistic)
        }
    }
}
