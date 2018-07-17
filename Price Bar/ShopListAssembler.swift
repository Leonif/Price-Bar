//
//  ShopListAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


class ShopListAssembler {
    func assemble() -> UIViewController {
        let view = R.storyboard.main.shopListController()!

        let repository = Repository()
        let adapter = ShopListAdapter(parent: view)
        view.adapter = adapter
        
        let presenter = ShoplistPresenterImpl()
        presenter.repository = repository
        presenter.getProductDetailProvider = GetProductDetailsProvider(repository: repository)
        presenter.view = view
        view.presenter = presenter
        
        let router = ShoplistRouterImpl()
        router.fromVC = view
        router.repository = repository
        
        presenter.router = router
        
        return view
    }
}
