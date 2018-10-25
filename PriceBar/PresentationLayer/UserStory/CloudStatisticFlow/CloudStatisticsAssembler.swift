//
//  CloudStatisticsAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/21/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class CloudStatisticsAssembler {
    func assemble() -> BaseView {
        let view = CloudStatisticsVC()
        view.modalPresentationStyle = .overCurrentContext

        let productModel = ProductModelImpl()
        let presenter = CloudStatisticsPresenterImpl()
        presenter.productModel = productModel

        presenter.view = view
        view.presenter = presenter

        return view
    }
}
