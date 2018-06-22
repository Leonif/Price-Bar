//
//  BaseStatisticsAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/21/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class BaseStatisticsAssembler {
    func assemble() -> UIViewController {
        let view = BaseStatisticsVC()
        view.modalPresentationStyle = .overCurrentContext
        
        let repository = Repository()
        let presenter = BaseStatisticsPresenterImpl()
        presenter.repository = repository
        
        presenter.view = view
        view.presenter = presenter
        
        return view
    }
}
