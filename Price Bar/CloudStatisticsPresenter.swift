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
    var repository: Repository!
    weak var view: CloudStatisticsView!
    
    func onGetQuantityOfGood() {
        let goodCout = self.repository.getQuantityOfProducts()
        self.view.renderStatistic(goodQuantity: goodCout)
    }
}
