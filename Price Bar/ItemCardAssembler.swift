//
//  ItemCardAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ItemCardAssembler {
    func assemble(itemCardDelegate: ItemCardDelegate, for productId: String, outletId: String) -> BaseView {
        
        let repository = Repository()
        let presenter = ItemCardPresenterImpl()
        let router = ItemCardRouterImpl()
        
        
        presenter.repository = repository
        presenter.router = router
        presenter.delegate = itemCardDelegate
        
        let view =  R.storyboard.main.itemCardVC()!
        
        
        view.presenter = presenter
        presenter.view = view
        
        router.fromVC = view
        
        view.productId = productId
        view.outletId = outletId
        
        return view
        
    }
}
