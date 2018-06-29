//
//  ItemCardAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ItemCardAssembler {
    func assemble(for productId: String, outletId: String) -> BaseView {
        
        let repository = Repository()
        let presenter = ItemCardPresenterImpl()
        presenter.repository = repository
        
        let view =  R.storyboard.main.itemCardVC()!//ItemCardVC(nib: R.nib.itemCardVC)
        
        view.presenter = presenter
        presenter.view = view
        
        view.productId = productId
        view.outletId = outletId
        
        return view
        
    }
}
