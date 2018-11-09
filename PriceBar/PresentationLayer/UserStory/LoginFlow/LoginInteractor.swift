//
//  LoginInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 11/9/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol LoginInteractor {
    func login(completion: @escaping (BackendResult<Void>) -> Void)
}

class LoginInteractorImpl: LoginInteractor {
    
    var provider: BackEndInterface!
    
    func login(completion: @escaping (BackendResult<Void>) -> Void) {
        provider.login { (result) in
            completion(result)
        }
    }
    
    
    
    
}
