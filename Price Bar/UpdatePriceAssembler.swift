//
//  UpdatePriceAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/22/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


class UpdatePriceAssembler {
    
    func assemble(productId: String, outletId: String, updatePriceOutput: UpdatePriceOutput) -> BaseView {
        
        let repository = Repository()
        
        let presenter = UpdatePricePresenterImpl()
        presenter.repository = repository
        presenter.updatePriceOutput = updatePriceOutput
        
        let vc = R.storyboard.main.updatePriceVC()!
        vc.productId = productId
        vc.presenter = presenter
        vc.outletId = outletId
        
        presenter.view = vc
        
        return vc
    }
}
