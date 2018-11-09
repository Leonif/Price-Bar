//
//  LoginPresenter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 11/9/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


protocol LoginPresenter {
    func login()
}

class LoginPresenterImpl: LoginPresenter {
    var interactor: LoginInteractor!
    var view: LoginVC!
    var router: LoginRouter!
    
    func login() {
        interactor.login { [weak self] (result) in
            switch result {
            case .success:
                self?.router.showShopList()
            case let .failure(error):
                self?.view.onError(with: error.localizedDescription)
            }
        }
    }
}
