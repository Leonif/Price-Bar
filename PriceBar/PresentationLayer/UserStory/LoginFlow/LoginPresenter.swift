//
//  LoginPresenter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 11/9/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


protocol LoginPresenter {
    func login(completion: () -> Void)
}

class LoginPresenterImpl: LoginPresenter {
    
    var loginInteractor: LoginInteractor!
    
    func login(completion: () -> Void) {
        loginInteractor.login(completion: completion)
    }
}
