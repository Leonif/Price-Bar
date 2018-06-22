//
//  BaseStatisticsInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol BaseStatisticsPresenter {
    func onGetQuantityOfGood()
}


class BaseStatisticsPresenterImpl: BaseStatisticsPresenter {

    var repository: Repository!
    weak var view: BaseStatisticsView!
    
    func onGetQuantityOfGood() {
        let goodCout = self.repository.getQuantityOfProducts()
        self.view.renderStatistic(goodQuantity: goodCout)
        
    }
}
