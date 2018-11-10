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

        let adapter = ShopListAdapter()
        adapter.dataSourceManager = ShoplistDatasourceManager()
        view.adapter = adapter

        let presenter = ShopListPresenterImpl()
        
        let provider = FirebaseService()
        
        let productModel = ProductModelImpl(provider: provider)
        let localStoreService = CoreDataServiceImpl()
        let shoplistModel = ShoplistModelImpl(localStoreService: localStoreService)
        let mapper = ShopListMapper()

        presenter.productModel = productModel
        presenter.shoplistModel = shoplistModel
        presenter.view = view
        presenter.mapper = mapper

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
