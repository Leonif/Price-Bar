//
//  LoginVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 11/9/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

protocol LoginView: BaseView {
}

class LoginVC: UIViewController, LoginView {
    var presenter: LoginPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.login()
    }
    func close() { }

}
