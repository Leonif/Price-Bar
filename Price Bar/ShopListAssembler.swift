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
        
        let adapter = ShopListAdapter(parent: view)
        view.adapter = adapter
        
        let presenter = ShoplistPresenterImpl()
        let productModel = ProductModelImpl()
        let shoplistModel = ShoplistModelImpl()
        presenter.productModel = productModel
        presenter.shoplistModel = shoplistModel
        presenter.view = view
        
        
        view.presenter = presenter
        
        let router = ShoplistRouterImpl()
        router.fromVC = view
        
        presenter.router = router
        let locationService = LocationServiceImpl()
        presenter.locationService = locationService
        let foursquareProvider = FoursquareProvider()
        let outletModel = FoursqareOutletModelImpl(foursquareProvider)
        presenter.outletModel = outletModel
        
        
        return view
    }
}
