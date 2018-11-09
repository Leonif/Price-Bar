//
//  LoginRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 11/10/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

protocol LoginRouter: BaseRouter {
    func showShopList()
}

class LoginRouterImpl: LoginRouter {
    
    private var vc: BaseView!
    
    init(vc: BaseView) {
        self.vc = vc
    }
    
    func showShopList() {
        
        let shoplistView = ShopListAssembler().assemble()
        
        let view = UINavigationController(rootViewController: shoplistView)
        
        presentController(fromModule: vc, to: view)
    }
}
