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
        adapter.dataSourceManager = ShopListDatasourceManager()
        view.adapter = adapter

        let presenter = ShopListPresenterImpl()
        
        let provider = FirebaseService()
        
        let productModel = ProductModelImpl(provider: provider)
        let localStoreService = CoreDataServiceImpl()
        let shoplistModel = ShoplistModelImpl(localStoreService: localStoreService)
        
        let locationService = LocationServiceImpl()
        let foursquareProvider = FoursquareProvider()
        let outletModel = FoursqareOutletModelImpl(foursquareProvider)
        
        let interactor = ShopListInteractorImpl()
        interactor.productModel = productModel
        interactor.shopListModel = shoplistModel
        interactor.outletModel = outletModel
        interactor.locationService = locationService
        
        let mapper = ShopListMapper()
        let storage = ShopListStorage()
        presenter.view = view
        presenter.mapper = mapper
        presenter.storage = storage
        presenter.interactor = interactor

        view.presenter = presenter

        let router = ShoplistRouterImpl()
        router.fromVC = view

        presenter.router = router

        return view
    }
}
