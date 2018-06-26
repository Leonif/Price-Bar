//
//  ItemCardAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ItemCardAssembler {
    func assemble(for item: ShoplistItem, outletId: String) -> BaseView {
        
        let repository = Repository()
        let presenter = ItemCardPresenterImpl()
        presenter.repository = repository
        
        let view = ItemCardVC(nib: R.nib.itemCardVC)
        
        view.presenter = presenter
        presenter.view = view
        
        view.item = item
        view.outletId = outletId
        
        return view
        
    }
}
