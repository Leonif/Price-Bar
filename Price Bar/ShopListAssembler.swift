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

        let productModel = ProductModel()
        let adapter = ShopListAdapter(parent: view)
        view.adapter = adapter
        
        
        let presenter = ShoplistPresenterImpl()
        let locationModel = LocationModel()
        presenter.locationModel = locationModel
        presenter.productModel = productModel
        presenter.getProductDetailProvider = GetProductDetailsProvider(productModel: productModel)
        presenter.view = view
        view.presenter = presenter
        
        let router = ShoplistRouterImpl()
        router.fromVC = view
        
        presenter.router = router
        
        let outletModel = FoursqareOutletModelImpl()
        presenter.outletModel = outletModel
        
        
        return view
    }
}
