//
//  CloudStatisticsPresenterImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol CloudStatisticsPresenter {
    func onGetQuantityOfGood()
}


class CloudStatisticsPresenterImpl: CloudStatisticsPresenter {
    var productModel: ProductModelImpl!
    weak var view: CloudStatisticsView!
    
    func onGetQuantityOfGood() {
        self.productModel.getQuantityOfProducts { (result) in
            switch result {
            case let .success(count):
                self.view.renderStatistic(goodQuantity: count)
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }
}
